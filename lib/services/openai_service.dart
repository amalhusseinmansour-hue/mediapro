import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../core/config/env_config.dart';

/// OpenAI Service - خدمة شاملة لجميع منتجات OpenAI
/// GPT-4 للنصوص | DALL-E 3 للصور | Whisper للصوت | TTS للتحويل لصوت
class OpenAIService extends GetxService {
  static const String _baseUrl = 'https://api.openai.com/v1';

  final RxBool isLoading = false.obs;
  final RxString lastError = ''.obs;
  final RxDouble progress = 0.0.obs;

  String get _apiKey => EnvConfig.openAIApiKey;

  @override
  void onInit() {
    super.onInit();
    print('🤖 OpenAI Service initialized');
    _validateApiKey();
  }

  void _validateApiKey() {
    if (_apiKey.isEmpty || _apiKey.contains('your_')) {
      print('⚠️ Warning: OpenAI API key not configured');
    } else {
      print('✅ OpenAI API key configured');
    }
  }

  bool get isConfigured => _apiKey.isNotEmpty && !_apiKey.contains('your_');

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      };

  // ============================================
  // 📝 GPT-4 - توليد النصوص
  // ============================================

  /// توليد محتوى نصي باستخدام GPT-4
  Future<String> generateText({
    required String prompt,
    String model = 'gpt-4o-mini', // أرخص وأسرع، استخدم gpt-4o للجودة العالية
    double temperature = 0.7,
    int maxTokens = 2000,
    String? systemPrompt,
  }) async {
    if (!isConfigured) {
      throw Exception('OpenAI API key not configured');
    }

    try {
      isLoading.value = true;
      lastError.value = '';

      final messages = <Map<String, String>>[];

      // إضافة system prompt إذا وجد
      if (systemPrompt != null) {
        messages.add({'role': 'system', 'content': systemPrompt});
      }

      messages.add({'role': 'user', 'content': prompt});

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers,
        body: jsonEncode({
          'model': model,
          'messages': messages,
          'temperature': temperature,
          'max_tokens': maxTokens,
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        print('✅ GPT text generated successfully');
        return content.trim();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error']['message'] ?? 'Unknown error');
      }
    } catch (e) {
      lastError.value = e.toString();
      print('❌ OpenAI GPT error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// توليد محتوى سوشال ميديا احترافي
  Future<String> generateSocialMediaContent({
    required String topic,
    required String platform,
    String language = 'ar',
    String tone = 'professional',
    bool includeHashtags = true,
    bool includeEmoji = true,
  }) async {
    final systemPrompt = '''
أنت كاتب محتوى محترف متخصص في السوشال ميديا مع خبرة 10+ سنوات.
تكتب محتوى viral يحقق ملايين المشاهدات.
تتبع أفضل الممارسات لكل منصة.
''';

    final prompt = '''
اكتب محتوى ${language == 'ar' ? 'بالعربية' : 'in English'} لمنصة $platform عن: $topic

الأسلوب: $tone

المتطلبات:
1. Hook قوي في البداية يجذب من أول 3 ثواني
2. قيمة حقيقية ومعلومات مفيدة
3. ${includeEmoji ? 'إيموجي جذابة (5-8)' : 'بدون إيموجي'}
4. فقرات قصيرة وسهلة القراءة
5. Call-to-Action قوي في النهاية
6. ${includeHashtags ? 'هاشتاقات استراتيجية (8-12)' : 'بدون هاشتاقات'}

اكتب المحتوى مباشرة بدون مقدمات.
''';

    return generateText(
      prompt: prompt,
      systemPrompt: systemPrompt,
      temperature: 0.85,
      maxTokens: 1500,
    );
  }

  /// توليد أفكار محتوى
  Future<List<String>> generateContentIdeas({
    required String topic,
    required String platform,
    int count = 10,
    String language = 'ar',
  }) async {
    final prompt = '''
اقترح $count أفكار محتوى مبتكرة ${language == 'ar' ? 'بالعربية' : 'in English'} لمنصة $platform عن: $topic

لكل فكرة:
- عنوان جذاب
- نوع المحتوى (تعليمي/ترفيهي/ملهم/جدلي)
- سبب نجاحها المتوقع

قدم الأفكار كقائمة مرقمة.
''';

    final result = await generateText(
      prompt: prompt,
      temperature: 0.9,
      maxTokens: 2000,
    );

    return result
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.replaceAll(RegExp(r'^\d+[\.\)]\s*'), '').trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  // ============================================
  // 🖼️ DALL-E 3 - توليد الصور
  // ============================================

  /// توليد صورة باستخدام DALL-E 3
  Future<String> generateImage({
    required String prompt,
    String size = '1024x1024', // 1024x1024, 1024x1792, 1792x1024
    String quality = 'standard', // standard, hd
    String style = 'vivid', // vivid, natural
  }) async {
    if (!isConfigured) {
      throw Exception('OpenAI API key not configured');
    }

    try {
      isLoading.value = true;
      progress.value = 0.3;

      final response = await http.post(
        Uri.parse('$_baseUrl/images/generations'),
        headers: _headers,
        body: jsonEncode({
          'model': 'dall-e-3',
          'prompt': prompt,
          'n': 1,
          'size': size,
          'quality': quality,
          'style': style,
          'response_format': 'url',
        }),
      ).timeout(const Duration(seconds: 120));

      progress.value = 0.8;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl = data['data'][0]['url'] as String;
        print('✅ DALL-E image generated successfully');
        progress.value = 1.0;
        return imageUrl;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error']['message'] ?? 'Image generation failed');
      }
    } catch (e) {
      lastError.value = e.toString();
      print('❌ DALL-E error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
      progress.value = 0.0;
    }
  }

  /// توليد صورة لمنصة سوشال ميديا
  Future<String> generateSocialMediaImage({
    required String description,
    required String platform,
    String style = 'modern',
  }) async {
    // تحسين البرومبت للحصول على أفضل نتيجة
    final enhancedPrompt = '''
Create a professional, high-quality social media image for $platform:
$description

Style: $style, vibrant colors, eye-catching, professional lighting
Requirements: Safe for all audiences, no text overlay, clean composition
''';

    // اختيار الحجم المناسب للمنصة
    String size;
    switch (platform.toLowerCase()) {
      case 'instagram':
      case 'facebook':
        size = '1024x1024'; // مربع
        break;
      case 'pinterest':
      case 'tiktok':
        size = '1024x1792'; // طولي
        break;
      case 'twitter':
      case 'linkedin':
        size = '1792x1024'; // عرضي
        break;
      default:
        size = '1024x1024';
    }

    return generateImage(
      prompt: enhancedPrompt,
      size: size,
      quality: 'standard',
      style: 'vivid',
    );
  }

  // ============================================
  // 🎤 Whisper - تحويل الصوت لنص
  // ============================================

  /// تحويل ملف صوتي إلى نص
  Future<String> transcribeAudio({
    required Uint8List audioData,
    required String fileName,
    String language = 'ar',
  }) async {
    if (!isConfigured) {
      throw Exception('OpenAI API key not configured');
    }

    try {
      isLoading.value = true;
      progress.value = 0.2;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/audio/transcriptions'),
      );

      request.headers['Authorization'] = 'Bearer $_apiKey';
      request.fields['model'] = 'whisper-1';
      request.fields['language'] = language;
      request.fields['response_format'] = 'text';

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        audioData,
        filename: fileName,
      ));

      progress.value = 0.5;

      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 120),
          );

      progress.value = 0.8;

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('✅ Audio transcribed successfully');
        progress.value = 1.0;
        return response.body.trim();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error']['message'] ?? 'Transcription failed');
      }
    } catch (e) {
      lastError.value = e.toString();
      print('❌ Whisper error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
      progress.value = 0.0;
    }
  }

  // ============================================
  // 🔊 TTS - تحويل النص لصوت
  // ============================================

  /// تحويل نص إلى صوت
  Future<Uint8List> textToSpeech({
    required String text,
    String voice = 'alloy', // alloy, echo, fable, onyx, nova, shimmer
    String model = 'tts-1', // tts-1, tts-1-hd
    double speed = 1.0,
  }) async {
    if (!isConfigured) {
      throw Exception('OpenAI API key not configured');
    }

    try {
      isLoading.value = true;
      progress.value = 0.3;

      final response = await http.post(
        Uri.parse('$_baseUrl/audio/speech'),
        headers: _headers,
        body: jsonEncode({
          'model': model,
          'input': text,
          'voice': voice,
          'speed': speed,
          'response_format': 'mp3',
        }),
      ).timeout(const Duration(seconds: 60));

      progress.value = 0.8;

      if (response.statusCode == 200) {
        print('✅ Text-to-speech generated successfully');
        progress.value = 1.0;
        return response.bodyBytes;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error']['message'] ?? 'TTS failed');
      }
    } catch (e) {
      lastError.value = e.toString();
      print('❌ TTS error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
      progress.value = 0.0;
    }
  }

  /// توليد صوت لمحتوى سوشال ميديا
  Future<Uint8List> generateVoiceOver({
    required String text,
    String voiceType = 'professional', // professional, friendly, energetic
    String language = 'ar',
  }) async {
    // اختيار الصوت المناسب
    String voice;
    switch (voiceType) {
      case 'professional':
        voice = 'onyx'; // صوت احترافي
        break;
      case 'friendly':
        voice = 'nova'; // صوت ودود
        break;
      case 'energetic':
        voice = 'echo'; // صوت نشيط
        break;
      default:
        voice = 'alloy';
    }

    return textToSpeech(
      text: text,
      voice: voice,
      model: 'tts-1-hd', // جودة عالية
      speed: language == 'ar' ? 0.9 : 1.0, // أبطأ قليلاً للعربية
    );
  }

  // ============================================
  // 🎨 Vision - تحليل الصور
  // ============================================

  /// تحليل صورة ووصفها
  Future<String> analyzeImage({
    required String imageUrl,
    String prompt = 'صف هذه الصورة بالتفصيل',
  }) async {
    if (!isConfigured) {
      throw Exception('OpenAI API key not configured');
    }

    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers,
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': prompt},
                {
                  'type': 'image_url',
                  'image_url': {'url': imageUrl}
                }
              ]
            }
          ],
          'max_tokens': 1000,
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        print('✅ Image analyzed successfully');
        return content.trim();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error']['message'] ?? 'Image analysis failed');
      }
    } catch (e) {
      lastError.value = e.toString();
      print('❌ Vision error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// توليد caption لصورة سوشال ميديا
  Future<String> generateImageCaption({
    required String imageUrl,
    required String platform,
    String language = 'ar',
    bool includeHashtags = true,
  }) async {
    final prompt = '''
أنت خبير سوشال ميديا. انظر لهذه الصورة واكتب caption احترافي ${language == 'ar' ? 'بالعربية' : 'in English'} لمنصة $platform.

المتطلبات:
1. Hook قوي في البداية
2. وصف جذاب للصورة
3. Call-to-action
4. ${includeHashtags ? 'هاشتاقات مناسبة (8-12)' : 'بدون هاشتاقات'}
5. إيموجي معبرة

اكتب الـ caption فقط بدون مقدمات.
''';

    return analyzeImage(imageUrl: imageUrl, prompt: prompt);
  }

  // ============================================
  // 📊 حساب التكلفة
  // ============================================

  /// حساب تكلفة تقريبية للعملية
  static Map<String, double> getEstimatedCost({
    int textTokens = 0,
    int images = 0,
    int audioMinutes = 0,
    int ttsCharacters = 0,
  }) {
    return {
      'text': textTokens * 0.00001, // GPT-4o-mini تقريباً
      'images': images * 0.04, // DALL-E 3 standard
      'audio': audioMinutes * 0.006, // Whisper
      'tts': ttsCharacters * 0.000015, // TTS
      'total': (textTokens * 0.00001) +
          (images * 0.04) +
          (audioMinutes * 0.006) +
          (ttsCharacters * 0.000015),
    };
  }
}
