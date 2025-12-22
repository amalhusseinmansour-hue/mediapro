import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../core/config/env_config.dart';

/// Runway ML Service - خدمة توليد الفيديوهات بالذكاء الاصطناعي
/// Gen-2 لتوليد فيديو من نص أو صورة
class RunwayService extends GetxService {
  // Updated to correct API URL (api.dev.runwayml.com not api.runwayml.com)
  static const String _baseUrl = 'https://api.dev.runwayml.com/v1';

  final RxBool isLoading = false.obs;
  final RxString lastError = ''.obs;
  final RxDouble progress = 0.0.obs;
  final RxString currentTaskId = ''.obs;

  String get _apiKey => EnvConfig.runwayApiKey;

  @override
  void onInit() {
    super.onInit();
    print('🎬 Runway ML Service initialized');
    _validateApiKey();
  }

  void _validateApiKey() {
    if (_apiKey.isEmpty || _apiKey.contains('your_')) {
      print('⚠️ Warning: Runway API key not configured');
    } else {
      print('✅ Runway API key configured');
    }
  }

  bool get isConfigured => _apiKey.isNotEmpty && !_apiKey.contains('your_');

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
        'X-Runway-Version': '2024-11-06',
      };

  // ============================================
  // 🎬 Gen-3 Alpha - توليد فيديو من نص
  // ============================================

  /// توليد فيديو من نص (Text-to-Video)
  Future<String> generateVideoFromText({
    required String prompt,
    int duration = 5, // 5 أو 10 ثواني
    String aspectRatio = '16:9', // 16:9, 9:16, 1:1
    bool watermark = false,
  }) async {
    if (!isConfigured) {
      throw Exception('Runway API key not configured');
    }

    try {
      isLoading.value = true;
      progress.value = 0.1;
      lastError.value = '';

      // إنشاء مهمة توليد الفيديو - يحتاج صورة مع النص
      // Note: Runway API لا يدعم text-to-video مباشرة، يحتاج image-to-video
      // سنستخدم صورة placeholder ثم نطبق عليها النص
      final placeholderImage = 'https://picsum.photos/seed/${prompt.hashCode.abs()}/1280/720';

      final response = await http.post(
        Uri.parse('$_baseUrl/image_to_video'),
        headers: _headers,
        body: jsonEncode({
          'promptImage': placeholderImage,
          'promptText': prompt,
          'model': 'gen4_turbo', // أحدث نموذج
          'ratio': aspectRatio == '16:9' ? '1280:720' : (aspectRatio == '9:16' ? '720:1280' : '720:720'),
          'duration': duration,
          'watermark': watermark,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final taskId = data['id'] as String;
        currentTaskId.value = taskId;
        print('✅ Video generation started: $taskId');

        // انتظار اكتمال الفيديو
        return await _pollForCompletion(taskId);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Video generation failed');
      }
    } catch (e) {
      lastError.value = e.toString();
      print('❌ Runway Text-to-Video error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
      progress.value = 0.0;
    }
  }

  /// توليد فيديو من صورة (Image-to-Video)
  Future<String> generateVideoFromImage({
    required String imageUrl,
    required String prompt,
    int duration = 5,
    String aspectRatio = '16:9',
  }) async {
    if (!isConfigured) {
      throw Exception('Runway API key not configured');
    }

    try {
      isLoading.value = true;
      progress.value = 0.1;

      final response = await http.post(
        Uri.parse('$_baseUrl/image_to_video'),
        headers: _headers,
        body: jsonEncode({
          'promptImage': imageUrl,
          'promptText': prompt,
          'model': 'gen4_turbo', // أحدث نموذج
          'ratio': aspectRatio == '16:9' ? '1280:720' : (aspectRatio == '9:16' ? '720:1280' : '720:720'),
          'duration': duration,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final taskId = data['id'] as String;
        currentTaskId.value = taskId;
        print('✅ Image-to-Video generation started: $taskId');

        return await _pollForCompletion(taskId);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Image-to-Video failed');
      }
    } catch (e) {
      lastError.value = e.toString();
      print('❌ Runway Image-to-Video error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
      progress.value = 0.0;
    }
  }

  /// متابعة حالة المهمة حتى الاكتمال
  Future<String> _pollForCompletion(String taskId) async {
    const maxAttempts = 120; // 10 دقائق كحد أقصى
    int attempts = 0;

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 5));
      attempts++;

      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/tasks/$taskId'),
          headers: _headers,
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final status = data['status'] as String;
          final progressValue = data['progress'] as double? ?? 0.0;

          progress.value = 0.1 + (progressValue * 0.9);
          print('📊 Video progress: ${(progressValue * 100).toInt()}%');

          if (status == 'SUCCEEDED') {
            final outputUrl = data['output'][0] as String;
            print('✅ Video generated successfully!');
            progress.value = 1.0;
            return outputUrl;
          } else if (status == 'FAILED') {
            final error = data['error'] ?? 'Unknown error';
            throw Exception('Video generation failed: $error');
          }
          // PENDING أو RUNNING - استمر في الانتظار
        }
      } catch (e) {
        if (attempts >= maxAttempts) rethrow;
      }
    }

    throw Exception('Video generation timeout');
  }

  /// الحصول على حالة مهمة محددة
  Future<Map<String, dynamic>> getTaskStatus(String taskId) async {
    if (!isConfigured) {
      throw Exception('Runway API key not configured');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/tasks/$taskId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to get task status');
      }
    } catch (e) {
      print('❌ Get task status error: $e');
      rethrow;
    }
  }

  /// إلغاء مهمة قيد التنفيذ
  Future<bool> cancelTask(String taskId) async {
    if (!isConfigured) {
      throw Exception('Runway API key not configured');
    }

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/tasks/$taskId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Task $taskId cancelled');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Cancel task error: $e');
      return false;
    }
  }

  // ============================================
  // 🎬 فيديوهات سوشال ميديا
  // ============================================

  /// توليد فيديو قصير لسوشال ميديا
  Future<String> generateSocialMediaVideo({
    required String description,
    required String platform,
    String? imageUrl,
    String style = 'dynamic',
  }) async {
    // تحديد الأبعاد حسب المنصة
    String aspectRatio;
    int duration;

    switch (platform.toLowerCase()) {
      case 'tiktok':
      case 'reels':
      case 'shorts':
        aspectRatio = '9:16';
        duration = 5;
        break;
      case 'twitter':
      case 'linkedin':
        aspectRatio = '16:9';
        duration = 5;
        break;
      case 'instagram':
      case 'facebook':
        aspectRatio = '1:1';
        duration = 5;
        break;
      default:
        aspectRatio = '16:9';
        duration = 5;
    }

    // تحسين البرومبت للفيديو
    final enhancedPrompt = _enhanceVideoPrompt(description, style, platform);

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return generateVideoFromImage(
        imageUrl: imageUrl,
        prompt: enhancedPrompt,
        duration: duration,
        aspectRatio: aspectRatio,
      );
    } else {
      return generateVideoFromText(
        prompt: enhancedPrompt,
        duration: duration,
        aspectRatio: aspectRatio,
      );
    }
  }

  /// توليد فيديو إعلاني
  Future<String> generateAdVideo({
    required String product,
    required String targetAudience,
    String style = 'professional',
    int duration = 5,
  }) async {
    final prompt = '''
Professional advertisement video for: $product
Target audience: $targetAudience
Style: $style, cinematic lighting, high quality, engaging
Movement: smooth camera motion, dynamic transitions
Mood: compelling, trust-building, call-to-action
''';

    return generateVideoFromText(
      prompt: prompt,
      duration: duration,
      aspectRatio: '16:9',
    );
  }

  /// توليد فيديو من قالب
  Future<String> generateFromTemplate({
    required String templateType,
    required String customText,
    String? brandColor,
  }) async {
    final templates = {
      'product_showcase': '''
Product showcase video: $customText
Style: clean, modern, product-focused, smooth rotation
Background: gradient, minimalist
Movement: slow zoom, elegant reveal
${brandColor != null ? 'Color scheme: $brandColor' : ''}
''',
      'testimonial': '''
Testimonial video style: $customText
Style: warm, authentic, conversational
Background: soft, blurred
Movement: gentle, natural
''',
      'announcement': '''
Announcement video: $customText
Style: exciting, energetic, attention-grabbing
Effects: dynamic text, bold colors
Movement: fast cuts, zoom effects
''',
      'tutorial': '''
Tutorial video introduction: $customText
Style: clear, educational, step-by-step
Background: clean, professional
Movement: smooth transitions, focus points
''',
      'promo': '''
Promotional video: $customText
Style: vibrant, exciting, sales-focused
Effects: flashy, eye-catching
Movement: fast-paced, dynamic
''',
    };

    final prompt = templates[templateType] ?? templates['promo']!;

    return generateVideoFromText(
      prompt: prompt,
      duration: 5,
      aspectRatio: '16:9',
    );
  }

  // ============================================
  // 🔧 Helper Methods
  // ============================================

  String _enhanceVideoPrompt(String description, String style, String platform) {
    final styleEnhancements = {
      'dynamic': 'dynamic camera movement, energetic, fast-paced, vibrant colors',
      'cinematic': 'cinematic, dramatic lighting, film-like, high production value',
      'minimal': 'minimal, clean, simple motion, elegant, subtle',
      'professional': 'professional, corporate, polished, business-appropriate',
      'playful': 'playful, fun, colorful, upbeat, cheerful movement',
      'luxury': 'luxury, premium, sophisticated, slow motion, elegant',
      'modern': 'modern, contemporary, trendy, smooth transitions',
    };

    final platformTips = {
      'tiktok': 'vertical format, attention-grabbing in first second, trendy',
      'reels': 'vertical, instagram-optimized, engaging',
      'shorts': 'youtube shorts style, vertical, quick hook',
      'twitter': 'horizontal, concise, twitter-friendly',
      'linkedin': 'professional, business-appropriate, horizontal',
      'instagram': 'square format, visually appealing',
      'facebook': 'social-friendly, engaging',
    };

    final styleText = styleEnhancements[style] ?? styleEnhancements['modern']!;
    final platformText = platformTips[platform.toLowerCase()] ?? '';

    return '''
$description
Style: $styleText
Platform optimization: $platformText
Quality: high resolution, smooth motion, professional
''';
  }

  /// الحصول على قائمة القوالب المتاحة
  List<Map<String, String>> get availableTemplates => [
        {'id': 'product_showcase', 'name': 'عرض منتج', 'name_en': 'Product Showcase'},
        {'id': 'testimonial', 'name': 'شهادة عميل', 'name_en': 'Testimonial'},
        {'id': 'announcement', 'name': 'إعلان', 'name_en': 'Announcement'},
        {'id': 'tutorial', 'name': 'شرح/تعليمي', 'name_en': 'Tutorial'},
        {'id': 'promo', 'name': 'ترويجي', 'name_en': 'Promotional'},
      ];

  /// الحصول على قائمة الستايلات المتاحة
  List<Map<String, String>> get availableStyles => [
        {'id': 'dynamic', 'name': 'ديناميكي', 'name_en': 'Dynamic'},
        {'id': 'cinematic', 'name': 'سينمائي', 'name_en': 'Cinematic'},
        {'id': 'minimal', 'name': 'بسيط', 'name_en': 'Minimal'},
        {'id': 'professional', 'name': 'احترافي', 'name_en': 'Professional'},
        {'id': 'playful', 'name': 'مرح', 'name_en': 'Playful'},
        {'id': 'luxury', 'name': 'فاخر', 'name_en': 'Luxury'},
        {'id': 'modern', 'name': 'عصري', 'name_en': 'Modern'},
      ];

  // ============================================
  // 📊 حساب التكلفة
  // ============================================

  static Map<String, double> getEstimatedCost({
    int fiveSecondVideos = 0,
    int tenSecondVideos = 0,
  }) {
    // تقريباً: 5 ثواني = 5 credits = $0.25, 10 ثواني = 10 credits = $0.50
    return {
      'fiveSecond': fiveSecondVideos * 0.25,
      'tenSecond': tenSecondVideos * 0.50,
      'total': (fiveSecondVideos * 0.25) + (tenSecondVideos * 0.50),
    };
  }

  /// الحصول على عدد الـ credits المتبقية
  Future<int> getRemainingCredits() async {
    if (!isConfigured) return 0;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/account'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['credits_remaining'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      print('❌ Get credits error: $e');
      return 0;
    }
  }
}
