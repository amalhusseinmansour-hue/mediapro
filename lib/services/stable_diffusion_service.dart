import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../core/config/env_config.dart';

/// Stable Diffusion Service - خدمة توليد صور AI بكميات كبيرة وتكلفة منخفضة
/// تستخدم Stability AI API (SDXL, SD3)
class StableDiffusionService extends GetxService {
  static const String _baseUrl = 'https://api.stability.ai/v2beta';

  final RxBool isLoading = false.obs;
  final RxString lastError = ''.obs;
  final RxDouble progress = 0.0.obs;

  String get _apiKey => EnvConfig.stabilityAIApiKey;

  @override
  void onInit() {
    super.onInit();
    print('🎨 Stable Diffusion Service initialized');
    _validateApiKey();
  }

  void _validateApiKey() {
    if (_apiKey.isEmpty || _apiKey.contains('your_')) {
      print('⚠️ Warning: Stability AI API key not configured');
    } else {
      print('✅ Stability AI API key configured');
    }
  }

  bool get isConfigured => _apiKey.isNotEmpty && !_apiKey.contains('your_');

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_apiKey',
        'Accept': 'application/json',
      };

  // ============================================
  // 🖼️ توليد الصور - SDXL (سريع ورخيص)
  // ============================================

  /// توليد صورة باستخدام SDXL 1.0
  Future<Uint8List> generateImageSDXL({
    required String prompt,
    String negativePrompt = '',
    int width = 1024,
    int height = 1024,
    int steps = 30,
    double cfgScale = 7.0,
    String style = 'photographic', // photographic, digital-art, anime, etc.
  }) async {
    if (!isConfigured) {
      throw Exception('Stability AI API key not configured');
    }

    try {
      isLoading.value = true;
      progress.value = 0.2;

      // تحسين البرومبت
      final enhancedPrompt = _enhancePrompt(prompt, style);

      final response = await http.post(
        Uri.parse('$_baseUrl/stable-image/generate/sd3'),
        headers: {
          ..._headers,
          'Content-Type': 'multipart/form-data',
        },
        body: jsonEncode({
          'prompt': enhancedPrompt,
          'negative_prompt': negativePrompt.isEmpty
              ? 'blurry, bad quality, distorted, ugly, deformed'
              : negativePrompt,
          'aspect_ratio': _getAspectRatio(width, height),
          'output_format': 'png',
          'model': 'sd3-large', // sd3-large, sd3-large-turbo, sd3-medium
        }),
      ).timeout(const Duration(seconds: 120));

      progress.value = 0.8;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['artifacts'] != null && data['artifacts'].isNotEmpty) {
          final base64Image = data['artifacts'][0]['base64'] as String;
          print('✅ SDXL image generated successfully');
          progress.value = 1.0;
          return base64Decode(base64Image);
        }
        throw Exception('No image data in response');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Image generation failed');
      }
    } catch (e) {
      lastError.value = e.toString();
      print('❌ SDXL error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
      progress.value = 0.0;
    }
  }

  /// توليد صور بتقنية Ultra (جودة عالية جداً)
  Future<String> generateImageUltra({
    required String prompt,
    String negativePrompt = '',
    String aspectRatio = '1:1',
  }) async {
    if (!isConfigured) {
      throw Exception('Stability AI API key not configured');
    }

    try {
      isLoading.value = true;
      progress.value = 0.2;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/stable-image/generate/ultra'),
      );

      request.headers['Authorization'] = 'Bearer $_apiKey';
      request.headers['Accept'] = 'image/*';

      request.fields['prompt'] = prompt;
      request.fields['output_format'] = 'png';
      request.fields['aspect_ratio'] = aspectRatio;

      if (negativePrompt.isNotEmpty) {
        request.fields['negative_prompt'] = negativePrompt;
      }

      progress.value = 0.5;

      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 180),
          );

      progress.value = 0.8;

      if (streamedResponse.statusCode == 200) {
        final bytes = await streamedResponse.stream.toBytes();
        // تحويل لـ base64 URL
        final base64 = base64Encode(bytes);
        print('✅ Ultra image generated successfully');
        progress.value = 1.0;
        return 'data:image/png;base64,$base64';
      } else {
        final response = await http.Response.fromStream(streamedResponse);
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Ultra generation failed');
      }
    } catch (e) {
      lastError.value = e.toString();
      print('❌ Ultra error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
      progress.value = 0.0;
    }
  }

  /// توليد عدة صور دفعة واحدة (رخيص جداً)
  Future<List<String>> generateBulkImages({
    required String prompt,
    int count = 4,
    String style = 'photographic',
    String aspectRatio = '1:1',
  }) async {
    if (!isConfigured) {
      throw Exception('Stability AI API key not configured');
    }

    final List<String> images = [];
    final enhancedPrompt = _enhancePrompt(prompt, style);

    try {
      isLoading.value = true;

      for (int i = 0; i < count; i++) {
        progress.value = (i + 1) / count;

        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$_baseUrl/stable-image/generate/core'),
        );

        request.headers['Authorization'] = 'Bearer $_apiKey';
        request.headers['Accept'] = 'image/*';

        request.fields['prompt'] = enhancedPrompt;
        request.fields['output_format'] = 'png';
        request.fields['aspect_ratio'] = aspectRatio;
        request.fields['seed'] = (DateTime.now().millisecondsSinceEpoch + i).toString();

        final streamedResponse = await request.send().timeout(
              const Duration(seconds: 60),
            );

        if (streamedResponse.statusCode == 200) {
          final bytes = await streamedResponse.stream.toBytes();
          final base64 = base64Encode(bytes);
          images.add('data:image/png;base64,$base64');
          print('✅ Bulk image ${i + 1}/$count generated');
        }
      }

      return images;
    } catch (e) {
      lastError.value = e.toString();
      print('❌ Bulk generation error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
      progress.value = 0.0;
    }
  }

  // ============================================
  // 🎨 تعديل الصور
  // ============================================

  /// تعديل صورة موجودة (Image-to-Image)
  Future<Uint8List> editImage({
    required Uint8List imageData,
    required String prompt,
    double strength = 0.7, // 0.0-1.0 (كلما زاد كلما تغيرت الصورة أكثر)
    String style = 'photographic',
  }) async {
    if (!isConfigured) {
      throw Exception('Stability AI API key not configured');
    }

    try {
      isLoading.value = true;
      progress.value = 0.2;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/stable-image/generate/sd3'),
      );

      request.headers['Authorization'] = 'Bearer $_apiKey';
      request.headers['Accept'] = 'image/*';

      request.fields['prompt'] = _enhancePrompt(prompt, style);
      request.fields['strength'] = strength.toString();
      request.fields['output_format'] = 'png';
      request.fields['mode'] = 'image-to-image';

      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageData,
        filename: 'input.png',
      ));

      progress.value = 0.5;

      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 120),
          );

      progress.value = 0.8;

      if (streamedResponse.statusCode == 200) {
        final bytes = await streamedResponse.stream.toBytes();
        print('✅ Image edited successfully');
        progress.value = 1.0;
        return bytes;
      } else {
        final response = await http.Response.fromStream(streamedResponse);
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Image editing failed');
      }
    } catch (e) {
      lastError.value = e.toString();
      print('❌ Edit error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
      progress.value = 0.0;
    }
  }

  /// إزالة خلفية الصورة
  Future<Uint8List> removeBackground({
    required Uint8List imageData,
  }) async {
    if (!isConfigured) {
      throw Exception('Stability AI API key not configured');
    }

    try {
      isLoading.value = true;
      progress.value = 0.3;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/stable-image/edit/remove-background'),
      );

      request.headers['Authorization'] = 'Bearer $_apiKey';
      request.headers['Accept'] = 'image/*';

      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageData,
        filename: 'input.png',
      ));

      progress.value = 0.6;

      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 60),
          );

      if (streamedResponse.statusCode == 200) {
        final bytes = await streamedResponse.stream.toBytes();
        print('✅ Background removed successfully');
        progress.value = 1.0;
        return bytes;
      } else {
        final response = await http.Response.fromStream(streamedResponse);
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Background removal failed');
      }
    } catch (e) {
      lastError.value = e.toString();
      print('❌ Remove background error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
      progress.value = 0.0;
    }
  }

  /// تكبير الصورة (Upscale)
  Future<Uint8List> upscaleImage({
    required Uint8List imageData,
    int scale = 4, // 2x or 4x
  }) async {
    if (!isConfigured) {
      throw Exception('Stability AI API key not configured');
    }

    try {
      isLoading.value = true;
      progress.value = 0.3;

      final endpoint = scale == 4
          ? '$_baseUrl/stable-image/upscale/creative'
          : '$_baseUrl/stable-image/upscale/fast';

      final request = http.MultipartRequest('POST', Uri.parse(endpoint));

      request.headers['Authorization'] = 'Bearer $_apiKey';
      request.headers['Accept'] = 'image/*';

      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageData,
        filename: 'input.png',
      ));

      request.fields['output_format'] = 'png';

      progress.value = 0.6;

      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 120),
          );

      if (streamedResponse.statusCode == 200) {
        final bytes = await streamedResponse.stream.toBytes();
        print('✅ Image upscaled ${scale}x successfully');
        progress.value = 1.0;
        return bytes;
      } else {
        final response = await http.Response.fromStream(streamedResponse);
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Upscale failed');
      }
    } catch (e) {
      lastError.value = e.toString();
      print('❌ Upscale error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
      progress.value = 0.0;
    }
  }

  // ============================================
  // 🎨 Styles للسوشال ميديا
  // ============================================

  /// توليد صورة بستايل محدد للسوشال ميديا
  Future<String> generateSocialMediaImage({
    required String description,
    required String platform,
    String style = 'modern',
  }) async {
    // تحديد الأبعاد حسب المنصة
    String aspectRatio;
    switch (platform.toLowerCase()) {
      case 'instagram':
      case 'facebook':
        aspectRatio = '1:1';
        break;
      case 'pinterest':
      case 'tiktok':
        aspectRatio = '9:16';
        break;
      case 'twitter':
      case 'linkedin':
      case 'youtube':
        aspectRatio = '16:9';
        break;
      default:
        aspectRatio = '1:1';
    }

    // تحسين الوصف للمنصة
    final prompt = '''
$description
Style: $style, professional, high quality, social media optimized
Platform: $platform
''';

    return generateImageUltra(
      prompt: prompt,
      aspectRatio: aspectRatio,
      negativePrompt: 'text, watermark, logo, blurry, low quality',
    );
  }

  /// الحصول على قائمة الستايلات المتاحة
  List<Map<String, String>> get availableStyles => [
        {'id': 'photographic', 'name': 'تصوير فوتوغرافي', 'name_en': 'Photographic'},
        {'id': 'digital-art', 'name': 'فن رقمي', 'name_en': 'Digital Art'},
        {'id': 'anime', 'name': 'أنمي', 'name_en': 'Anime'},
        {'id': '3d-model', 'name': 'نموذج 3D', 'name_en': '3D Model'},
        {'id': 'cinematic', 'name': 'سينمائي', 'name_en': 'Cinematic'},
        {'id': 'comic-book', 'name': 'كوميكس', 'name_en': 'Comic Book'},
        {'id': 'fantasy-art', 'name': 'فن خيالي', 'name_en': 'Fantasy Art'},
        {'id': 'line-art', 'name': 'رسم خطي', 'name_en': 'Line Art'},
        {'id': 'neon-punk', 'name': 'نيون بانك', 'name_en': 'Neon Punk'},
        {'id': 'origami', 'name': 'أوريغامي', 'name_en': 'Origami'},
        {'id': 'pixel-art', 'name': 'بكسل آرت', 'name_en': 'Pixel Art'},
        {'id': 'isometric', 'name': 'متساوي القياس', 'name_en': 'Isometric'},
      ];

  // ============================================
  // 🔧 Helper Methods
  // ============================================

  String _enhancePrompt(String prompt, String style) {
    final styleEnhancements = {
      'photographic': 'professional photography, high resolution, sharp focus, natural lighting',
      'digital-art': 'digital art, vibrant colors, detailed illustration',
      'anime': 'anime style, japanese animation, detailed anime art',
      '3d-model': '3D render, octane render, realistic 3D model',
      'cinematic': 'cinematic lighting, movie scene, dramatic atmosphere',
      'comic-book': 'comic book style, bold lines, comic art',
      'fantasy-art': 'fantasy art, magical, ethereal, mystical',
      'neon-punk': 'neon lights, cyberpunk, futuristic, glowing',
      'modern': 'modern design, clean, professional, contemporary',
    };

    final enhancement = styleEnhancements[style] ?? styleEnhancements['modern']!;
    return '$prompt, $enhancement, masterpiece, best quality';
  }

  String _getAspectRatio(int width, int height) {
    final ratio = width / height;
    if (ratio > 1.5) return '16:9';
    if (ratio < 0.7) return '9:16';
    if (ratio > 1.2) return '3:2';
    if (ratio < 0.9) return '2:3';
    return '1:1';
  }

  // ============================================
  // 📊 حساب التكلفة
  // ============================================

  static Map<String, double> getEstimatedCost({
    int coreImages = 0,
    int sd3Images = 0,
    int ultraImages = 0,
    int upscales = 0,
    int backgroundRemovals = 0,
  }) {
    return {
      'core': coreImages * 0.003, // Core ~$0.003/image
      'sd3': sd3Images * 0.035, // SD3 ~$0.035/image
      'ultra': ultraImages * 0.08, // Ultra ~$0.08/image
      'upscale': upscales * 0.01, // Upscale ~$0.01/image
      'bgRemoval': backgroundRemovals * 0.02, // BG Removal ~$0.02/image
      'total': (coreImages * 0.003) +
          (sd3Images * 0.035) +
          (ultraImages * 0.08) +
          (upscales * 0.01) +
          (backgroundRemovals * 0.02),
    };
  }
}
