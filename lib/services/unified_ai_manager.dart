import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'openai_service.dart';
import 'stable_diffusion_service.dart';
import 'runway_service.dart';
import 'gemini_service.dart';
import 'groq_service.dart';

/// Unified AI Manager - مدير موحد لجميع خدمات الذكاء الاصطناعي
/// يدير الحدود والاستخدام ويختار الخدمة المناسبة تلقائياً
/// Groq (FREE) هو المزود الأساسي - مجاني 100%!
class UnifiedAIManager extends GetxService {
  // الخدمات
  GroqService? _groq; // FREE - Primary!
  OpenAIService? _openAI;
  StableDiffusionService? _stableDiffusion;
  RunwayService? _runway;
  GeminiService? _gemini;

  // حالة التحميل
  final RxBool isLoading = false.obs;
  final RxString lastError = ''.obs;
  final RxDouble progress = 0.0.obs;

  // إحصائيات الاستخدام الشهري
  final RxInt textGenerations = 0.obs;
  final RxInt imageGenerations = 0.obs;
  final RxInt videoGenerations = 0.obs;
  final RxInt voiceGenerations = 0.obs;

  // حدود الاشتراكات
  late Box _usageBox;

  @override
  void onInit() async {
    super.onInit();
    print('🤖 Unified AI Manager initialized');
    await _initServices();
    await _loadUsageData();
  }

  Future<void> _initServices() async {
    // Groq (FREE) - Primary AI Provider!
    try {
      _groq = Get.find<GroqService>();
      print('✅ Groq Service found (FREE - Primary!)');
    } catch (e) {
      print('⚠️ Groq Service not available');
    }

    try {
      _openAI = Get.find<OpenAIService>();
    } catch (e) {
      print('⚠️ OpenAI Service not available');
    }

    try {
      _stableDiffusion = Get.find<StableDiffusionService>();
    } catch (e) {
      print('⚠️ Stable Diffusion Service not available');
    }

    try {
      _runway = Get.find<RunwayService>();
    } catch (e) {
      print('⚠️ Runway Service not available');
    }

    try {
      _gemini = Get.find<GeminiService>();
    } catch (e) {
      print('⚠️ Gemini Service not available');
    }
  }

  Future<void> _loadUsageData() async {
    try {
      _usageBox = await Hive.openBox('ai_usage');
      final currentMonth = _getCurrentMonth();

      textGenerations.value = _usageBox.get('text_$currentMonth', defaultValue: 0);
      imageGenerations.value = _usageBox.get('image_$currentMonth', defaultValue: 0);
      videoGenerations.value = _usageBox.get('video_$currentMonth', defaultValue: 0);
      voiceGenerations.value = _usageBox.get('voice_$currentMonth', defaultValue: 0);

      print('📊 Usage loaded: Text=${textGenerations.value}, Images=${imageGenerations.value}, Videos=${videoGenerations.value}');
    } catch (e) {
      print('❌ Error loading usage data: $e');
    }
  }

  String _getCurrentMonth() {
    final now = DateTime.now();
    return '${now.year}_${now.month}';
  }

  Future<void> _incrementUsage(String type) async {
    final currentMonth = _getCurrentMonth();
    final key = '${type}_$currentMonth';

    switch (type) {
      case 'text':
        textGenerations.value++;
        break;
      case 'image':
        imageGenerations.value++;
        break;
      case 'video':
        videoGenerations.value++;
        break;
      case 'voice':
        voiceGenerations.value++;
        break;
    }

    await _usageBox.put(key, _usageBox.get(key, defaultValue: 0) + 1);
  }

  // ============================================
  // 📊 حدود الاشتراكات
  // ============================================

  /// حدود باقة الأفراد (99 درهم)
  static const Map<String, int> individualLimits = {
    'text_per_day': 100,
    'images_per_month': 100,
    'videos_per_month': 10,
    'voice_per_month': 20,
    'connected_accounts': 5,
  };

  /// حدود باقة الشركات (179 درهم)
  static const Map<String, int> businessLimits = {
    'text_per_day': -1, // غير محدود
    'images_per_month': 300,
    'videos_per_month': 30,
    'voice_per_month': 100,
    'connected_accounts': -1, // غير محدود
  };

  /// التحقق من الحدود
  bool canUseFeature(String feature, String subscriptionType) {
    final limits = subscriptionType == 'business' ? businessLimits : individualLimits;
    final limit = limits[feature] ?? 0;

    if (limit == -1) return true; // غير محدود

    switch (feature) {
      case 'text_per_day':
        return textGenerations.value < limit;
      case 'images_per_month':
        return imageGenerations.value < limit;
      case 'videos_per_month':
        return videoGenerations.value < limit;
      case 'voice_per_month':
        return voiceGenerations.value < limit;
      default:
        return true;
    }
  }

  /// الحصول على الاستخدام المتبقي
  Map<String, int> getRemainingUsage(String subscriptionType) {
    final limits = subscriptionType == 'business' ? businessLimits : individualLimits;

    return {
      'text': limits['text_per_day'] == -1 ? -1 : limits['text_per_day']! - textGenerations.value,
      'images': limits['images_per_month'] == -1 ? -1 : limits['images_per_month']! - imageGenerations.value,
      'videos': limits['videos_per_month'] == -1 ? -1 : limits['videos_per_month']! - videoGenerations.value,
      'voice': limits['voice_per_month'] == -1 ? -1 : limits['voice_per_month']! - voiceGenerations.value,
    };
  }

  // ============================================
  // 📝 توليد النصوص
  // ============================================

  /// توليد محتوى نصي (يختار الخدمة المناسبة تلقائياً)
  /// Groq (FREE) هو المزود الأساسي - مجاني 100% وسريع جداً!
  Future<String> generateText({
    required String prompt,
    String? systemPrompt,
    String preferredProvider = 'groq', // groq (FREE primary), openai (backup)
    double temperature = 0.7,
  }) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      String result;

      // Groq هو المزود الأساسي (FREE - Llama 3.3 70B)
      if (_groq?.isConfigured == true) {
        print('🚀 Using Groq as PRIMARY (FREE - Llama 3.3 70B)...');
        result = await _groq!.generateContent(
          prompt: prompt,
          systemPrompt: systemPrompt,
          temperature: temperature,
        );
      } else if (_openAI?.isConfigured == true) {
        // OpenAI كـ backup
        print('🔄 Using OpenAI as backup...');
        result = await _openAI!.generateText(
          prompt: prompt,
          systemPrompt: systemPrompt,
          temperature: temperature,
        );
      } else if (_gemini?.isConfigured == true) {
        // Gemini كـ backup ثاني
        print('🔄 Using Gemini as second backup...');
        result = await _gemini!.generateContent(
          prompt: systemPrompt != null ? '$systemPrompt\n\n$prompt' : prompt,
          temperature: temperature,
        );
      } else {
        throw Exception('لا توجد خدمة AI متاحة - احصل على مفتاح Groq المجاني من https://console.groq.com');
      }

      await _incrementUsage('text');
      return result;
    } catch (e) {
      lastError.value = e.toString();
      // محاولة المزود الاحتياطي
      if (_openAI?.isConfigured == true) {
        print('⚠️ Groq failed, trying OpenAI backup...');
        try {
          final backupResult = await _openAI!.generateText(
            prompt: prompt,
            systemPrompt: systemPrompt,
            temperature: temperature,
          );
          await _incrementUsage('text');
          return backupResult;
        } catch (_) {}
      }
      if (_gemini?.isConfigured == true) {
        print('⚠️ Trying Gemini backup...');
        try {
          final backupResult = await _gemini!.generateContent(
            prompt: systemPrompt != null ? '$systemPrompt\n\n$prompt' : prompt,
            temperature: temperature,
          );
          await _incrementUsage('text');
          return backupResult;
        } catch (_) {}
      }
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// توليد محتوى سوشال ميديا
  /// Groq (FREE) هو المزود الأساسي - مجاني 100%!
  Future<String> generateSocialMediaContent({
    required String topic,
    required String platform,
    String language = 'ar',
    String tone = 'professional',
    bool includeHashtags = true,
  }) async {
    try {
      isLoading.value = true;

      String result;

      // Groq هو المزود الأساسي (FREE - Llama 3.3 70B)
      if (_groq?.isConfigured == true) {
        print('🚀 Using Groq for social media content (FREE - PRIMARY)...');
        result = await _groq!.generateSocialMediaContent(
          topic: topic,
          platform: platform,
          language: language,
          tone: tone,
          includeHashtags: includeHashtags,
        );
      } else if (_openAI?.isConfigured == true) {
        // OpenAI كـ backup
        print('🔄 Using OpenAI as backup...');
        result = await _openAI!.generateSocialMediaContent(
          topic: topic,
          platform: platform,
          language: language,
          tone: tone,
          includeHashtags: includeHashtags,
        );
      } else if (_gemini?.isConfigured == true) {
        // Gemini كـ backup ثاني
        print('🔄 Using Gemini as second backup...');
        result = await _gemini!.generateSocialMediaContent(
          topic: topic,
          platform: platform,
          contentType: 'post',
          language: language,
          tone: tone,
          includeHashtags: includeHashtags,
        );
      } else {
        throw Exception('لا توجد خدمة AI متاحة - احصل على مفتاح Groq المجاني من https://console.groq.com');
      }

      await _incrementUsage('text');
      return result;
    } catch (e) {
      lastError.value = e.toString();
      // محاولة المزود الاحتياطي
      if (_openAI?.isConfigured == true) {
        print('⚠️ Groq failed, trying OpenAI backup...');
        try {
          final backupResult = await _openAI!.generateSocialMediaContent(
            topic: topic,
            platform: platform,
            language: language,
            tone: tone,
            includeHashtags: includeHashtags,
          );
          await _incrementUsage('text');
          return backupResult;
        } catch (_) {}
      }
      if (_gemini?.isConfigured == true) {
        print('⚠️ Trying Gemini backup...');
        try {
          final backupResult = await _gemini!.generateSocialMediaContent(
            topic: topic,
            platform: platform,
            contentType: 'post',
            language: language,
            tone: tone,
            includeHashtags: includeHashtags,
          );
          await _incrementUsage('text');
          return backupResult;
        } catch (_) {}
      }
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // 🖼️ توليد الصور
  // ============================================

  /// توليد صورة (يختار الخدمة المناسبة)
  Future<String> generateImage({
    required String prompt,
    String preferredProvider = 'auto', // auto, dalle, stable_diffusion
    String size = '1024x1024',
    String style = 'vivid',
  }) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      String result;

      if (preferredProvider == 'dalle' && _openAI?.isConfigured == true) {
        // DALL-E للجودة العالية
        result = await _openAI!.generateImage(
          prompt: prompt,
          size: size,
          style: style,
        );
      } else if (_stableDiffusion?.isConfigured == true) {
        // Stable Diffusion للكمية (أرخص)
        result = await _stableDiffusion!.generateImageUltra(
          prompt: prompt,
          aspectRatio: _sizeToAspectRatio(size),
        );
      } else if (_openAI?.isConfigured == true) {
        result = await _openAI!.generateImage(
          prompt: prompt,
          size: size,
          style: style,
        );
      } else {
        throw Exception('لا توجد خدمة توليد صور متاحة');
      }

      await _incrementUsage('image');
      return result;
    } catch (e) {
      lastError.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// توليد صورة لسوشال ميديا
  Future<String> generateSocialMediaImage({
    required String description,
    required String platform,
    String style = 'modern',
    String preferredProvider = 'auto',
  }) async {
    try {
      isLoading.value = true;

      String result;

      if (preferredProvider == 'dalle' && _openAI?.isConfigured == true) {
        result = await _openAI!.generateSocialMediaImage(
          description: description,
          platform: platform,
          style: style,
        );
      } else if (_stableDiffusion?.isConfigured == true) {
        result = await _stableDiffusion!.generateSocialMediaImage(
          description: description,
          platform: platform,
          style: style,
        );
      } else if (_openAI?.isConfigured == true) {
        result = await _openAI!.generateSocialMediaImage(
          description: description,
          platform: platform,
          style: style,
        );
      } else {
        throw Exception('لا توجد خدمة توليد صور متاحة');
      }

      await _incrementUsage('image');
      return result;
    } catch (e) {
      lastError.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// توليد عدة صور دفعة واحدة
  Future<List<String>> generateBulkImages({
    required String prompt,
    int count = 4,
    String style = 'photographic',
  }) async {
    if (_stableDiffusion?.isConfigured != true) {
      throw Exception('Stable Diffusion غير متاح');
    }

    try {
      isLoading.value = true;

      final results = await _stableDiffusion!.generateBulkImages(
        prompt: prompt,
        count: count,
        style: style,
      );

      // تسجيل الاستخدام لكل صورة
      for (int i = 0; i < results.length; i++) {
        await _incrementUsage('image');
      }

      return results;
    } catch (e) {
      lastError.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // 🎬 توليد الفيديو
  // ============================================

  /// توليد فيديو من نص
  Future<String> generateVideo({
    required String prompt,
    int duration = 5,
    String aspectRatio = '16:9',
  }) async {
    if (_runway?.isConfigured != true) {
      throw Exception('Runway غير متاح');
    }

    try {
      isLoading.value = true;
      lastError.value = '';
      progress.value = 0.0;

      // ربط progress من Runway
      _runway!.progress.listen((value) {
        progress.value = value;
      });

      final result = await _runway!.generateVideoFromText(
        prompt: prompt,
        duration: duration,
        aspectRatio: aspectRatio,
      );

      await _incrementUsage('video');
      return result;
    } catch (e) {
      lastError.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
      progress.value = 0.0;
    }
  }

  /// توليد فيديو من صورة
  Future<String> generateVideoFromImage({
    required String imageUrl,
    required String prompt,
    int duration = 5,
    String aspectRatio = '16:9',
  }) async {
    if (_runway?.isConfigured != true) {
      throw Exception('Runway غير متاح');
    }

    try {
      isLoading.value = true;

      final result = await _runway!.generateVideoFromImage(
        imageUrl: imageUrl,
        prompt: prompt,
        duration: duration,
        aspectRatio: aspectRatio,
      );

      await _incrementUsage('video');
      return result;
    } catch (e) {
      lastError.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// توليد فيديو لسوشال ميديا
  Future<String> generateSocialMediaVideo({
    required String description,
    required String platform,
    String? imageUrl,
    String style = 'dynamic',
  }) async {
    if (_runway?.isConfigured != true) {
      throw Exception('Runway غير متاح');
    }

    try {
      isLoading.value = true;

      final result = await _runway!.generateSocialMediaVideo(
        description: description,
        platform: platform,
        imageUrl: imageUrl,
        style: style,
      );

      await _incrementUsage('video');
      return result;
    } catch (e) {
      lastError.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // 🔊 توليد الصوت
  // ============================================

  /// تحويل نص لصوت
  Future<Uint8List> textToSpeech({
    required String text,
    String voice = 'alloy',
    String voiceType = 'professional',
  }) async {
    if (_openAI?.isConfigured != true) {
      throw Exception('OpenAI غير متاح');
    }

    try {
      isLoading.value = true;

      final result = await _openAI!.generateVoiceOver(
        text: text,
        voiceType: voiceType,
      );

      await _incrementUsage('voice');
      return result;
    } catch (e) {
      lastError.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// تحويل صوت لنص
  Future<String> speechToText({
    required Uint8List audioData,
    required String fileName,
    String language = 'ar',
  }) async {
    if (_openAI?.isConfigured != true) {
      throw Exception('OpenAI غير متاح');
    }

    try {
      isLoading.value = true;

      final result = await _openAI!.transcribeAudio(
        audioData: audioData,
        fileName: fileName,
        language: language,
      );

      return result;
    } catch (e) {
      lastError.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // 🔧 أدوات إضافية
  // ============================================

  /// تحليل صورة وتوليد caption
  Future<String> generateImageCaption({
    required String imageUrl,
    required String platform,
    String language = 'ar',
  }) async {
    if (_openAI?.isConfigured != true) {
      throw Exception('OpenAI غير متاح');
    }

    try {
      isLoading.value = true;

      final result = await _openAI!.generateImageCaption(
        imageUrl: imageUrl,
        platform: platform,
        language: language,
      );

      await _incrementUsage('text');
      return result;
    } catch (e) {
      lastError.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// إزالة خلفية صورة
  Future<Uint8List> removeBackground({
    required Uint8List imageData,
  }) async {
    if (_stableDiffusion?.isConfigured != true) {
      throw Exception('Stable Diffusion غير متاح');
    }

    try {
      isLoading.value = true;
      return await _stableDiffusion!.removeBackground(imageData: imageData);
    } catch (e) {
      lastError.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// تكبير صورة
  Future<Uint8List> upscaleImage({
    required Uint8List imageData,
    int scale = 4,
  }) async {
    if (_stableDiffusion?.isConfigured != true) {
      throw Exception('Stable Diffusion غير متاح');
    }

    try {
      isLoading.value = true;
      return await _stableDiffusion!.upscaleImage(
        imageData: imageData,
        scale: scale,
      );
    } catch (e) {
      lastError.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // 📊 إحصائيات وتكلفة
  // ============================================

  /// الحصول على إحصائيات الاستخدام
  Map<String, dynamic> getUsageStats() {
    return {
      'text': textGenerations.value,
      'images': imageGenerations.value,
      'videos': videoGenerations.value,
      'voice': voiceGenerations.value,
      'month': _getCurrentMonth(),
    };
  }

  /// حساب التكلفة التقريبية
  Map<String, double> getEstimatedCost() {
    final openAICost = OpenAIService.getEstimatedCost(
      textTokens: textGenerations.value * 500,
      images: imageGenerations.value ~/ 3, // ثلث الصور من DALL-E
      ttsCharacters: voiceGenerations.value * 500,
    );

    final sdCost = StableDiffusionService.getEstimatedCost(
      coreImages: (imageGenerations.value * 2) ~/ 3, // ثلثين من SD
    );

    final runwayCost = RunwayService.getEstimatedCost(
      fiveSecondVideos: videoGenerations.value,
    );

    return {
      'openai': openAICost['total'] ?? 0,
      'stable_diffusion': sdCost['total'] ?? 0,
      'runway': runwayCost['total'] ?? 0,
      'total': (openAICost['total'] ?? 0) +
          (sdCost['total'] ?? 0) +
          (runwayCost['total'] ?? 0),
    };
  }

  /// إعادة تعيين الاستخدام (للشهر الجديد)
  Future<void> resetUsage() async {
    final currentMonth = _getCurrentMonth();
    textGenerations.value = 0;
    imageGenerations.value = 0;
    videoGenerations.value = 0;
    voiceGenerations.value = 0;

    await _usageBox.put('text_$currentMonth', 0);
    await _usageBox.put('image_$currentMonth', 0);
    await _usageBox.put('video_$currentMonth', 0);
    await _usageBox.put('voice_$currentMonth', 0);

    print('✅ Usage reset for $currentMonth');
  }

  /// الحصول على الخدمات المتاحة
  Map<String, bool> getAvailableServices() {
    return {
      'groq': _groq?.isConfigured ?? false, // FREE - Primary!
      'openai': _openAI?.isConfigured ?? false,
      'stable_diffusion': _stableDiffusion?.isConfigured ?? false,
      'runway': _runway?.isConfigured ?? false,
      'gemini': _gemini?.isConfigured ?? false,
    };
  }

  // Helper method
  String _sizeToAspectRatio(String size) {
    switch (size) {
      case '1024x1792':
        return '9:16';
      case '1792x1024':
        return '16:9';
      default:
        return '1:1';
    }
  }
}
