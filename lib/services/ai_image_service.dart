import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/generated_image.dart';
import '../core/config/env_config.dart';
import 'http_service.dart';

/// أنواع نماذج توليد الصور المتاحة
/// Gemini Imagen هو المزود الأساسي (Primary Provider)
enum ImageGenerationModel {
  geminiImagen, // Google Gemini Imagen - PRIMARY (الأفضل والأسرع)
  stabilityAI, // Stability AI (SDXL, SD3) - Backup
  openaiDalle, // OpenAI DALL-E 3 (الأفضل جودة) - Backup
  backend, // Backend API
  demo, // وضع التجربة
}

class AIImageService {
  // استخدام المفاتيح من ملف التكوين
  static String get _openaiApiKey => EnvConfig.openAIApiKey;
  static String get _stabilityApiKey => EnvConfig.stabilityAIApiKey;
  static String get _geminiApiKey => EnvConfig.googleAIApiKey;

  // روابط API
  static const String _openaiBaseUrl = 'https://api.openai.com/v1';
  static const String _stabilityBaseUrl = 'https://api.stability.ai/v2beta';
  static const String _geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  // HttpService للاتصال بالباك اند
  HttpService? get _httpService {
    try {
      return Get.find<HttpService>();
    } catch (e) {
      return null;
    }
  }

  // النموذج الافتراضي - Gemini Imagen (Primary Provider)
  ImageGenerationModel _currentModel = ImageGenerationModel.geminiImagen;

  final List<GeneratedImage> _generatedImages = [];

  /// تغيير النموذج المستخدم
  void setModel(ImageGenerationModel model) {
    _currentModel = model;
  }

  /// الحصول على النموذج الحالي
  ImageGenerationModel get currentModel => _currentModel;

  List<GeneratedImage> get generatedImages => _generatedImages;

  /// توليد صورة من نص
  Future<GeneratedImage> generateImage({
    required String prompt,
    String? negativePrompt,
    int width = 512,
    int height = 512,
    int steps = 30,
    double cfgScale = 7.0,
    int? seed,
    ImageGenerationModel? model,
  }) async {
    try {
      final useModel = model ?? _currentModel;

      switch (useModel) {
        case ImageGenerationModel.openaiDalle:
          return await _generateWithOpenAIDalle(
            prompt: prompt,
            width: width,
            height: height,
          );
        case ImageGenerationModel.stabilityAI:
          return await _generateWithStabilityAI(
            prompt: prompt,
            negativePrompt: negativePrompt,
            width: width,
            height: height,
            steps: steps,
            cfgScale: cfgScale,
            seed: seed,
          );
        case ImageGenerationModel.geminiImagen:
          return await _generateWithGeminiImagen(
            prompt: prompt,
            negativePrompt: negativePrompt,
            width: width,
            height: height,
            steps: steps,
            cfgScale: cfgScale,
            seed: seed,
          );
        case ImageGenerationModel.backend:
          return await _generateWithBackend(
            prompt: prompt,
            negativePrompt: negativePrompt,
            width: width,
            height: height,
            steps: steps,
            cfgScale: cfgScale,
            seed: seed,
          );
        case ImageGenerationModel.demo:
          return await _generateDemo(
            prompt: prompt,
            negativePrompt: negativePrompt,
            width: width,
            height: height,
            steps: steps,
            cfgScale: cfgScale,
            seed: seed,
          );
      }
    } catch (e) {
      throw Exception('خطأ في توليد الصورة: $e');
    }
  }

  /// توليد صورة باستخدام OpenAI DALL-E 3
  Future<GeneratedImage> _generateWithOpenAIDalle({
    required String prompt,
    required int width,
    required int height,
  }) async {
    try {
      print('🎨 ========== OPENAI DALL-E 3 IMAGE GENERATION ==========');
      print('📝 Prompt: $prompt');
      print('🔑 API Key present: ${_openaiApiKey.isNotEmpty && !_openaiApiKey.contains('your_')}');

      if (_openaiApiKey.isEmpty || _openaiApiKey.contains('your_')) {
        print('⚠️ OpenAI API key not configured, falling back to Stability AI...');
        return await _generateWithStabilityAI(
          prompt: prompt,
          width: width,
          height: height,
          steps: 30,
          cfgScale: 7.0,
        );
      }

      // تحديد الحجم المناسب لـ DALL-E 3
      String size = '1024x1024';
      if (width > height) {
        size = '1792x1024';
      } else if (height > width) {
        size = '1024x1792';
      }

      print('📐 Size: $size');
      print('🌐 Calling OpenAI DALL-E 3 API...');

      final response = await http.post(
        Uri.parse('$_openaiBaseUrl/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openaiApiKey',
        },
        body: jsonEncode({
          'model': 'dall-e-3',
          'prompt': prompt,
          'n': 1,
          'size': size,
          'quality': 'standard',
          'response_format': 'b64_json',
        }),
      ).timeout(const Duration(seconds: 120));

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageData = data['data'][0]['b64_json'];

        if (imageData != null) {
          final imageUrl = await _saveBase64Image(imageData);

          final generatedImage = GeneratedImage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            imageUrl: imageUrl,
            prompt: prompt,
            createdAt: DateTime.now(),
            width: width,
            height: height,
            seed: 'dalle3-${DateTime.now().millisecondsSinceEpoch}',
            cfgScale: 7.0,
            steps: 1,
          );

          _generatedImages.insert(0, generatedImage);
          print('✅ SUCCESS! Image generated with OpenAI DALL-E 3');
          return generatedImage;
        }
      }

      // Handle errors
      final errorData = jsonDecode(response.body);
      final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
      print('❌ OpenAI DALL-E Error: $errorMessage');

      // Fallback to Stability AI
      print('⚠️ Falling back to Stability AI...');
      return await _generateWithStabilityAI(
        prompt: prompt,
        width: width,
        height: height,
        steps: 30,
        cfgScale: 7.0,
      );
    } catch (e) {
      print('❌ OpenAI DALL-E Exception: $e');
      // Fallback to Stability AI
      print('⚠️ Falling back to Stability AI...');
      return await _generateWithStabilityAI(
        prompt: prompt,
        width: width,
        height: height,
        steps: 30,
        cfgScale: 7.0,
      );
    }
  }

  /// توليد صورة باستخدام Backend API (الطريقة الموصى بها لـ SaaS)
  /// يرسل الطلب للباك اند الذي يتعامل مع AI APIs بشكل آمن
  Future<GeneratedImage> _generateWithBackend({
    required String prompt,
    String? negativePrompt,
    required int width,
    required int height,
    required int steps,
    required double cfgScale,
    int? seed,
  }) async {
    try {
      print('🎨 ========== BACKEND IMAGE GENERATION ==========');
      print('📝 User Prompt: $prompt');
      print('🌐 Calling Backend API...');

      final httpService = _httpService;
      if (httpService == null) {
        print('⚠️ HttpService not available, falling back to Gemini...');
        return await _generateWithGeminiImagen(
          prompt: prompt,
          negativePrompt: negativePrompt,
          width: width,
          height: height,
          steps: steps,
          cfgScale: cfgScale,
          seed: seed,
        );
      }

      // إرسال طلب للباك اند
      final response = await httpService.post(
        '/ai/images/generate',
        body: {
          'prompt': prompt,
          if (negativePrompt != null) 'negative_prompt': negativePrompt,
          'width': width,
          'height': height,
          'steps': steps,
          'cfg_scale': cfgScale,
          if (seed != null) 'seed': seed,
        },
      );

      print('📥 Backend Response received');

      // التحقق من نجاح الاستجابة
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        String imageUrl;

        // التعامل مع الصورة - قد تكون URL أو base64
        if (data['image_url'] != null) {
          imageUrl = data['image_url'];
        } else if (data['image_base64'] != null) {
          imageUrl = await _saveBase64Image(data['image_base64']);
        } else {
          throw Exception('No image in response');
        }

        final generatedImage = GeneratedImage(
          id: data['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          imageUrl: imageUrl,
          prompt: prompt,
          negativePrompt: negativePrompt,
          createdAt: DateTime.now(),
          width: width,
          height: height,
          seed: seed?.toString() ?? data['seed']?.toString() ?? 'backend-${DateTime.now().millisecondsSinceEpoch}',
          cfgScale: cfgScale,
          steps: steps,
        );

        _generatedImages.insert(0, generatedImage);
        print('✅ SUCCESS! Image generated via Backend');
        return generatedImage;
      } else {
        final errorMessage = response['message'] ?? 'Unknown error';
        print('❌ Backend API Error: $errorMessage');

        // Fallback to Gemini if backend fails
        print('⚠️ Falling back to Gemini...');
        return await _generateWithGeminiImagen(
          prompt: prompt,
          negativePrompt: negativePrompt,
          width: width,
          height: height,
          steps: steps,
          cfgScale: cfgScale,
          seed: seed,
        );
      }
    } catch (e) {
      print('❌ Backend Exception: $e');
      // Fallback to Gemini
      print('⚠️ Falling back to Gemini...');
      return await _generateWithGeminiImagen(
        prompt: prompt,
        negativePrompt: negativePrompt,
        width: width,
        height: height,
        steps: steps,
        cfgScale: cfgScale,
        seed: seed,
      );
    }
  }

  /// توليد صورة باستخدام Google Gemini Imagen 3 API
  /// أفضل نموذج لتوليد الصور من Google - متوفر مع Gemini Pro subscription
  Future<GeneratedImage> _generateWithGeminiImagen({
    required String prompt,
    String? negativePrompt,
    required int width,
    required int height,
    required int steps,
    required double cfgScale,
    int? seed,
  }) async {
    try {
      print('🎨 ========== GEMINI IMAGEN 3 IMAGE GENERATION ==========');
      print('📝 User Prompt: $prompt');
      print('🔑 API Key present: ${_geminiApiKey.isNotEmpty && !_geminiApiKey.contains('your_')}');

      if (_geminiApiKey.isEmpty || _geminiApiKey.contains('your_')) {
        throw Exception('Gemini API key not configured');
      }

      // استخدام Imagen 3 - أفضل نموذج لتوليد الصور من Google
      // متوفر مع اشتراك Gemini Pro
      final url = '$_geminiBaseUrl/models/imagen-3.0-generate-001:predict?key=$_geminiApiKey';

      // تحسين الـ prompt للحصول على نتائج أفضل
      String enhancedPrompt = prompt;

      // إضافة تفاصيل جودة للصورة
      if (!prompt.toLowerCase().contains('quality') &&
          !prompt.toLowerCase().contains('detailed') &&
          !prompt.toLowerCase().contains('جودة')) {
        enhancedPrompt = '$prompt, high quality, detailed, professional';
      }

      // إضافة negative prompt
      if (negativePrompt != null && negativePrompt.isNotEmpty) {
        enhancedPrompt = '$enhancedPrompt. Avoid: $negativePrompt';
      }

      // تحديد نسبة العرض إلى الارتفاع
      final aspectRatio = _getAspectRatio(width, height);

      print('📤 Enhanced Prompt: $enhancedPrompt');
      print('📐 Aspect Ratio: $aspectRatio');
      print('🌐 Calling Gemini Imagen 3 API...');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'instances': [
            {
              'prompt': enhancedPrompt,
            }
          ],
          'parameters': {
            'sampleCount': 1,
            'aspectRatio': aspectRatio,
            'personGeneration': 'allow_adult',
            'safetyFilterLevel': 'block_some',
          }
        }),
      ).timeout(const Duration(seconds: 120));

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['predictions'] != null && data['predictions'].isNotEmpty) {
          final prediction = data['predictions'][0];
          if (prediction['bytesBase64Encoded'] != null) {
            final imageData = prediction['bytesBase64Encoded'];
            final imageUrl = await _saveBase64Image(imageData);

            final generatedImage = GeneratedImage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              imageUrl: imageUrl,
              prompt: prompt,
              negativePrompt: negativePrompt,
              createdAt: DateTime.now(),
              width: width,
              height: height,
              seed: seed?.toString() ?? 'imagen3-${DateTime.now().millisecondsSinceEpoch}',
              cfgScale: cfgScale,
              steps: steps,
            );

            _generatedImages.insert(0, generatedImage);
            print('✅ SUCCESS! Image generated with Gemini Imagen 3');
            return generatedImage;
          }
        }
        print('❌ No image data in Imagen 3 response');
        print('📋 Response: ${response.body}');
        // Try fallback to gemini-2.0-flash-exp
        print('⚠️ Trying gemini-2.0-flash-exp as fallback...');
        return await _generateWithGeminiGenerateContent(
          prompt: prompt,
          negativePrompt: negativePrompt,
          width: width,
          height: height,
          steps: steps,
          cfgScale: cfgScale,
          seed: seed,
        );
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? response.body;
        print('❌ Imagen 3 API Error: $errorMessage');
        print('📋 Full response: ${response.body}');

        // جرب النموذج البديل gemini-2.0-flash-exp
        print('⚠️ Trying gemini-2.0-flash-exp as fallback...');
        return await _generateWithGeminiGenerateContent(
          prompt: prompt,
          negativePrompt: negativePrompt,
          width: width,
          height: height,
          steps: steps,
          cfgScale: cfgScale,
          seed: seed,
        );
      }
    } catch (e) {
      print('❌ Gemini Imagen 3 Exception: $e');
      // جرب الطريقة البديلة
      print('⚠️ Trying gemini-2.0-flash-exp as fallback...');
      return await _generateWithGeminiGenerateContent(
        prompt: prompt,
        negativePrompt: negativePrompt,
        width: width,
        height: height,
        steps: steps,
        cfgScale: cfgScale,
        seed: seed,
      );
    }
  }

  /// توليد صورة باستخدام Gemini generateContent API (طريقة بديلة)
  Future<GeneratedImage> _generateWithGeminiGenerateContent({
    required String prompt,
    String? negativePrompt,
    required int width,
    required int height,
    required int steps,
    required double cfgScale,
    int? seed,
  }) async {
    try {
      print('🎨 ========== GEMINI FLASH IMAGE GENERATION ==========');
      print('📝 User Prompt: $prompt');

      // استخدام gemini-2.0-flash-exp الذي يدعم توليد الصور
      final url = '$_geminiBaseUrl/models/gemini-2.0-flash-exp:generateContent?key=$_geminiApiKey';

      // تحسين الـ prompt للحصول على نتائج أفضل
      String enhancedPrompt = 'Create a high-quality, detailed image of: $prompt';

      // إضافة تفاصيل الجودة
      if (!prompt.toLowerCase().contains('style')) {
        enhancedPrompt = '$enhancedPrompt. Style: professional, photorealistic, high resolution';
      }

      // إضافة ما يجب تجنبه
      if (negativePrompt != null && negativePrompt.isNotEmpty) {
        enhancedPrompt = '$enhancedPrompt. Avoid: $negativePrompt, blurry, low quality, distorted';
      } else {
        enhancedPrompt = '$enhancedPrompt. Avoid: blurry, low quality, distorted, watermark';
      }

      print('📤 Enhanced Prompt: $enhancedPrompt');
      print('🌐 Calling Gemini Flash API...');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': enhancedPrompt}
              ]
            }
          ],
          'generationConfig': {
            'responseModalities': ['image', 'text'],
            'temperature': 1.0,
          }
        }),
      ).timeout(const Duration(seconds: 120));

      print('📥 Gemini Flash Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final content = data['candidates'][0]['content'];
          if (content != null && content['parts'] != null) {
            for (var part in content['parts']) {
              if (part['inlineData'] != null) {
                final imageData = part['inlineData']['data'];
                final imageUrl = await _saveBase64Image(imageData);

                final generatedImage = GeneratedImage(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  imageUrl: imageUrl,
                  prompt: prompt,
                  negativePrompt: negativePrompt,
                  createdAt: DateTime.now(),
                  width: width,
                  height: height,
                  seed: seed?.toString() ?? 'gemini-${DateTime.now().millisecondsSinceEpoch}',
                  cfgScale: cfgScale,
                  steps: steps,
                );

                _generatedImages.insert(0, generatedImage);
                print('✅ SUCCESS! Image generated with Gemini Flash');
                return generatedImage;
              }
            }
          }
        }
        print('❌ No image data in Gemini Flash response');
        print('📋 Response body: ${response.body}');
        throw Exception('No image in response - Gemini Flash did not return an image');
      } else {
        print('❌ Gemini Flash API Error: ${response.statusCode}');
        print('📋 Full response: ${response.body}');
        throw Exception('Gemini generateContent failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Gemini Flash Exception: $e');
      print('⚠️ Falling back to Stability AI...');
      // استخدام Stability AI كـ fallback (لديه مفتاح معد)
      return await _generateWithStabilityAI(
        prompt: prompt,
        negativePrompt: negativePrompt,
        width: width,
        height: height,
        steps: steps,
        cfgScale: cfgScale,
        seed: seed,
      );
    }
  }

  /// تحديد نسبة العرض للطول
  String _getAspectRatio(int width, int height) {
    final ratio = width / height;
    if (ratio >= 1.7) return '16:9';
    if (ratio >= 1.3) return '4:3';
    if (ratio <= 0.6) return '9:16';
    if (ratio <= 0.8) return '3:4';
    return '1:1';
  }

  /// توليد صورة باستخدام OpenAI DALL-E مباشرة (بدون fallback لـ Stability)
  Future<GeneratedImage> _generateWithOpenAIDalleDirect({
    required String prompt,
    required int width,
    required int height,
  }) async {
    print('🎨 ========== OPENAI DALL-E 3 DIRECT ==========');
    print('📝 Prompt: $prompt');

    if (_openaiApiKey.isEmpty || _openaiApiKey.contains('your_')) {
      throw Exception('OpenAI API key not configured');
    }

    // تحديد الحجم المناسب لـ DALL-E 3
    String size = '1024x1024';
    if (width > height) {
      size = '1792x1024';
    } else if (height > width) {
      size = '1024x1792';
    }

    print('📐 Size: $size');
    print('🌐 Calling OpenAI DALL-E 3 API...');

    final response = await http.post(
      Uri.parse('$_openaiBaseUrl/images/generations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_openaiApiKey',
      },
      body: jsonEncode({
        'model': 'dall-e-3',
        'prompt': prompt,
        'n': 1,
        'size': size,
        'quality': 'standard',
        'response_format': 'b64_json',
      }),
    ).timeout(const Duration(seconds: 120));

    print('📥 Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final imageData = data['data'][0]['b64_json'];

      if (imageData != null) {
        final imageUrl = await _saveBase64Image(imageData);

        final generatedImage = GeneratedImage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          imageUrl: imageUrl,
          prompt: prompt,
          createdAt: DateTime.now(),
          width: width,
          height: height,
          seed: 'dalle3-${DateTime.now().millisecondsSinceEpoch}',
          cfgScale: 7.0,
          steps: 1,
        );

        _generatedImages.insert(0, generatedImage);
        print('✅ SUCCESS! Image generated with OpenAI DALL-E 3');
        return generatedImage;
      }
    }

    // Handle errors
    final errorData = jsonDecode(response.body);
    final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
    print('❌ OpenAI DALL-E Error: $errorMessage');
    throw Exception('DALL-E error: $errorMessage');
  }

  /// توليد صورة باستخدام Stability AI (SDXL)
  Future<GeneratedImage> _generateWithStabilityAI({
    required String prompt,
    String? negativePrompt,
    required int width,
    required int height,
    required int steps,
    required double cfgScale,
    int? seed,
  }) async {
    try {
      print('🎨 ========== STABILITY AI IMAGE GENERATION ==========');
      print('📝 Prompt: $prompt');
      print('🔑 API Key present: ${_stabilityApiKey.isNotEmpty && !_stabilityApiKey.contains('your_')}');

      if (_stabilityApiKey.isEmpty || _stabilityApiKey.contains('your_')) {
        print('⚠️ Stability AI API key not configured, falling back to demo...');
        return await _generateDemo(
          prompt: prompt,
          negativePrompt: negativePrompt,
          width: width,
          height: height,
          steps: steps,
          cfgScale: cfgScale,
          seed: seed,
        );
      }

      // استخدام Stable Image Core API (v2beta)
      print('🌐 Calling Stability AI Core API...');

      // تجهيز البيانات كـ multipart/form-data
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_stabilityBaseUrl/stable-image/generate/core'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $_stabilityApiKey',
        'Accept': 'application/json',
      });

      request.fields['prompt'] = prompt;
      if (negativePrompt != null) {
        request.fields['negative_prompt'] = negativePrompt;
      }
      request.fields['output_format'] = 'png';

      // تحديد aspect ratio
      String aspectRatio = '1:1';
      if (width > height) {
        aspectRatio = '16:9';
      } else if (height > width) {
        aspectRatio = '9:16';
      }
      request.fields['aspect_ratio'] = aspectRatio;

      final streamedResponse = await request.send().timeout(const Duration(seconds: 120));
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Response Status: ${response.statusCode}');
      print('📋 Response Content-Type: ${response.headers['content-type']}');

      if (response.statusCode == 200) {
        // Stability AI Core API returns image directly as binary, not JSON
        final contentType = response.headers['content-type'] ?? '';

        String? base64Image;

        if (contentType.contains('image/')) {
          // Response is raw image bytes
          print('📷 Received raw image data (${response.bodyBytes.length} bytes)');
          base64Image = base64Encode(response.bodyBytes);
        } else if (contentType.contains('application/json')) {
          // Response is JSON with base64 image
          final data = jsonDecode(response.body);
          print('📋 JSON Response keys: ${data.keys.toList()}');
          base64Image = data['image'] ?? data['artifacts']?[0]?['base64'];
        }

        if (base64Image != null && base64Image.isNotEmpty) {
          print('📷 Base64 image length: ${base64Image.length}');
          final imageUrl = await _saveBase64Image(base64Image);
          print('💾 Image saved to: $imageUrl');

          final generatedImage = GeneratedImage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            imageUrl: imageUrl,
            prompt: prompt,
            negativePrompt: negativePrompt,
            createdAt: DateTime.now(),
            width: width,
            height: height,
            seed: seed?.toString() ?? 'stability-${DateTime.now().millisecondsSinceEpoch}',
            cfgScale: cfgScale,
            steps: steps,
          );

          _generatedImages.insert(0, generatedImage);
          print('✅ SUCCESS! Image generated with Stability AI');
          return generatedImage;
        } else {
          print('❌ No image data found in response');
          print('📋 Response body preview: ${response.body.substring(0, response.body.length.clamp(0, 500))}');
        }
      }

      // Handle error
      print('❌ Stability AI Error: ${response.statusCode}');
      print('📋 Response: ${response.body}');

      // Try OpenAI DALL-E as fallback
      if (_openaiApiKey.isNotEmpty && !_openaiApiKey.contains('your_')) {
        print('⚠️ Trying OpenAI DALL-E as fallback...');
        return await _generateWithOpenAIDalleDirect(
          prompt: prompt,
          width: width,
          height: height,
        );
      }
      throw Exception('فشل توليد الصورة: ${response.body}');
    } catch (e) {
      print('❌ Stability AI Exception: $e');

      // Try OpenAI DALL-E as fallback
      if (_openaiApiKey.isNotEmpty && !_openaiApiKey.contains('your_')) {
        print('⚠️ Trying OpenAI DALL-E as fallback...');
        try {
          return await _generateWithOpenAIDalleDirect(
            prompt: prompt,
            width: width,
            height: height,
          );
        } catch (dalleError) {
          print('❌ DALL-E also failed: $dalleError');
        }
      }

      print('⚠️ Falling back to demo mode...');
      return await _generateDemo(
        prompt: prompt,
        negativePrompt: negativePrompt,
        width: width,
        height: height,
        steps: steps,
        cfgScale: cfgScale,
        seed: seed,
      );
    }
  }

  /// وضع التجربة - يستخدم صور Picsum كـ placeholder
  Future<GeneratedImage> _generateDemo({
    required String prompt,
    String? negativePrompt,
    required int width,
    required int height,
    required int steps,
    required double cfgScale,
    int? seed,
  }) async {
    print('📝 Demo mode - Using placeholder image');
    print('📝 Prompt was: $prompt');

    // محاكاة وقت التوليد
    await Future.delayed(const Duration(seconds: 2));

    // استخدام Picsum لصور placeholder احترافية
    final seedValue = seed ?? prompt.hashCode.abs();
    final imageUrl = 'https://picsum.photos/seed/$seedValue/$width/$height';

    final generatedImage = GeneratedImage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imageUrl: imageUrl,
      prompt: prompt,
      negativePrompt: negativePrompt,
      createdAt: DateTime.now(),
      width: width,
      height: height,
      seed: seedValue.toString(),
      cfgScale: cfgScale,
      steps: steps,
    );

    _generatedImages.insert(0, generatedImage);
    print('✅ Demo image generated');
    return generatedImage;
  }

  /// حفظ صورة من Base64
  Future<String> _saveBase64Image(String base64String) async {
    try {
      final bytes = base64Decode(base64String);
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/generated_$timestamp.png';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      throw Exception('فشل حفظ الصورة: $e');
    }
  }

  /// حذف صورة
  void deleteImage(String id) {
    _generatedImages.removeWhere((img) => img.id == id);
  }

  /// مسح جميع الصور
  void clearAllImages() {
    _generatedImages.clear();
  }

  /// الحصول على صورة بواسطة ID
  GeneratedImage? getImageById(String id) {
    try {
      return _generatedImages.firstWhere((img) => img.id == id);
    } catch (e) {
      return null;
    }
  }
}
