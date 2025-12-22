import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'settings_service.dart';
import '../core/config/env_config.dart';
import 'gemini_service.dart';
import 'http_service.dart';

/// خدمة موحدة لتوليد وتعديل الصور والفيديو باستخدام AI
/// Supports Gemini (Imagen & Veo), Replicate, Stability AI, Leonardo AI, Runway
class AIMediaService extends GetxService {
  final SettingsService _settings = Get.find<SettingsService>();

  final RxBool isGenerating = false.obs;
  final RxString currentProvider = 'backend'.obs;  // Default to Backend API (Gemini/Claude)
  final RxDouble progress = 0.0.obs;

  // Gemini API configuration
  static String get _geminiApiKey => EnvConfig.googleAIApiKey;
  static const String _geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  // GeminiService for AI features
  GeminiService? get _geminiService {
    try {
      return Get.find<GeminiService>();
    } catch (e) {
      return null;
    }
  }

  // HttpService for backend API calls
  HttpService? get _httpService {
    try {
      return Get.find<HttpService>();
    } catch (e) {
      return null;
    }
  }

  bool get _useGemini => _geminiApiKey.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    print('🎨 AI Media Service initialized');
    _loadSettings();
  }

  void _loadSettings() {
    // Use Backend API for secure SaaS image generation (Gemini/Claude on server)
    currentProvider.value = 'backend';
    print('🎯 AI Provider: Backend API (Gemini/Claude on server)');
  }

  // ==================== IMAGE GENERATION ====================

  /// توليد صورة عبر Backend API (الطريقة الموصى بها لـ SaaS)
  Future<Map<String, dynamic>> _generateImageBackend({
    required String prompt,
    String? negativePrompt,
    int width = 1024,
    int height = 1024,
  }) async {
    try {
      print('🎨 ========== BACKEND IMAGE GENERATION ==========');
      print('📝 Prompt: $prompt');
      progress.value = 0.2;

      final httpService = _httpService;
      if (httpService == null) {
        print('⚠️ HttpService not available, falling back to Gemini...');
        return await _generateImageGemini(prompt: prompt, width: width, height: height);
      }

      // إرسال طلب للباك اند
      print('🌐 Calling Backend API at /ai/images/generate...');
      final response = await httpService.post(
        '/ai/images/generate',
        body: {
          'prompt': prompt,
          if (negativePrompt != null) 'negative_prompt': negativePrompt,
          'width': width,
          'height': height,
        },
      );

      progress.value = 0.7;
      print('📥 Backend Response received');

      // التحقق من نجاح الاستجابة
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        String? imagePath;
        String? imageUrl;
        String? imageBase64;

        // التعامل مع الصورة - قد تكون URL أو base64
        if (data['image_url'] != null) {
          imageUrl = data['image_url'];
        }

        if (data['image_base64'] != null) {
          imageBase64 = data['image_base64'] as String;
          // حفظ الصورة محلياً
          final directory = await getTemporaryDirectory();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          imagePath = '${directory.path}/generated_backend_$timestamp.png';

          final imageBytes = base64Decode(imageBase64);
          await File(imagePath).writeAsBytes(imageBytes);
          imageUrl = 'file://$imagePath';
        }

        if (imageUrl == null && imagePath == null) {
          throw Exception('No image in backend response');
        }

        print('✅ SUCCESS! Image generated via Backend');
        progress.value = 1.0;

        return {
          'success': true,
          'image_path': imagePath,
          'image_url': imageUrl,
          'image_base64': imageBase64,
          'provider': 'backend',
        };
      } else {
        final errorMessage = response['message'] ?? response['error'] ?? 'Backend error';
        print('❌ Backend API Error: $errorMessage');

        // Fallback to Gemini if backend fails
        print('⚠️ Falling back to Gemini...');
        return await _generateImageGemini(prompt: prompt, width: width, height: height);
      }
    } catch (e) {
      print('❌ Backend Exception: $e');
      // Fallback to Gemini
      print('⚠️ Falling back to Gemini...');
      return await _generateImageGemini(prompt: prompt, width: width, height: height);
    }
  }

  /// توليد صورة من نص
  Future<Map<String, dynamic>> generateImage({
    required String prompt,
    String? negativePrompt,
    int? width,
    int? height,
    int? steps,
    double? guidanceScale,
  }) async {
    try {
      // Check if AI Image is enabled (skip check if using Gemini)
      if (!_useGemini && !_settings.aiImageEnabled) {
        throw Exception('AI Image Generation is disabled. Enable it from admin panel.');
      }

      isGenerating.value = true;
      progress.value = 0.0;

      // Use backend API for secure and reliable image generation
      String provider = currentProvider.value;
      print('📸 Generating image with provider: $provider');

      Map<String, dynamic> result;

      switch (provider) {
        case 'backend':
          result = await _generateImageBackend(
            prompt: prompt,
            negativePrompt: negativePrompt,
            width: width ?? 1024,
            height: height ?? 1024,
          );
          break;

        case 'gemini':
          result = await _generateImageGemini(
            prompt: prompt,
            width: width ?? 1024,
            height: height ?? 1024,
          );
          break;

        case 'replicate':
          result = await _generateImageReplicate(
            prompt: prompt,
            negativePrompt: negativePrompt,
            width: width ?? _settings.aiImageWidth,
            height: height ?? _settings.aiImageHeight,
            steps: steps ?? _settings.aiSteps,
            guidanceScale: guidanceScale ?? _settings.aiGuidanceScale,
          );
          break;

        case 'stability':
          result = await _generateImageStability(
            prompt: prompt,
            negativePrompt: negativePrompt,
            width: width ?? _settings.aiImageWidth,
            height: height ?? _settings.aiImageHeight,
            steps: steps ?? _settings.aiSteps,
            guidanceScale: guidanceScale ?? _settings.aiGuidanceScale,
          );
          break;

        case 'leonardo':
          result = await _generateImageLeonardo(
            prompt: prompt,
            negativePrompt: negativePrompt,
            width: width ?? _settings.aiImageWidth,
            height: height ?? _settings.aiImageHeight,
          );
          break;

        default:
          throw Exception('Unknown AI provider: $provider');
      }

      isGenerating.value = false;
      progress.value = 1.0;

      return result;
    } catch (e) {
      isGenerating.value = false;
      print('❌ Image generation error: $e');
      rethrow;
    }
  }

  /// توليد صورة عبر Gemini Imagen
  Future<Map<String, dynamic>> _generateImageGemini({
    required String prompt,
    int width = 1024,
    int height = 1024,
  }) async {
    try {
      print('🔄 Generating image with Gemini Imagen...');
      progress.value = 0.2;

      // Determine aspect ratio
      String aspectRatio = '1:1';
      if (width > height) {
        aspectRatio = '16:9';
      } else if (height > width) {
        aspectRatio = '9:16';
      }

      // Try Imagen 3 first
      final response = await http.post(
        Uri.parse('$_geminiBaseUrl/models/imagen-3.0-generate-002:predict?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'instances': [
            {'prompt': prompt}
          ],
          'parameters': {
            'sampleCount': 1,
            'aspectRatio': aspectRatio,
            'personGeneration': 'allow_adult',
          }
        }),
      );

      progress.value = 0.7;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final predictions = data['predictions'] as List?;

        if (predictions != null && predictions.isNotEmpty) {
          final base64Image = predictions[0]['bytesBase64Encoded'];
          if (base64Image != null) {
            // Save image to temp file
            final directory = await getTemporaryDirectory();
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final filePath = '${directory.path}/generated_image_$timestamp.png';

            final imageBytes = base64Decode(base64Image);
            await File(filePath).writeAsBytes(imageBytes);

            print('✅ Image generated successfully with Gemini Imagen');
            return {
              'success': true,
              'image_path': filePath,
              'image_url': 'file://$filePath',
              'image_base64': base64Image,
              'provider': 'gemini_imagen',
            };
          }
        }
      }

      // Fallback to Gemini Flash image generation
      print('⚠️ Imagen failed, trying Gemini Flash...');
      return await _generateImageGeminiFlash(prompt);
    } catch (e) {
      print('❌ Gemini image generation error: $e');
      // Fallback to other providers if Gemini fails
      if (_settings.aiImageEnabled) {
        return await _generateImageReplicate(
          prompt: prompt,
          width: 1024,
          height: 1024,
          steps: 30,
          guidanceScale: 7.5,
        );
      }
      rethrow;
    }
  }

  /// توليد صورة عبر Gemini Flash (fallback)
  Future<Map<String, dynamic>> _generateImageGeminiFlash(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$_geminiBaseUrl/models/gemini-2.0-flash-exp:generateContent?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'Generate an image: $prompt'}
              ]
            }
          ],
          'generationConfig': {
            'responseModalities': ['image', 'text'],
            'temperature': 0.8,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final parts = data['candidates']?[0]?['content']?['parts'] as List?;

        if (parts != null) {
          for (final part in parts) {
            if (part['inlineData'] != null) {
              final base64Image = part['inlineData']['data'];
              if (base64Image != null) {
                final directory = await getTemporaryDirectory();
                final timestamp = DateTime.now().millisecondsSinceEpoch;
                final filePath = '${directory.path}/generated_image_$timestamp.png';

                final imageBytes = base64Decode(base64Image);
                await File(filePath).writeAsBytes(imageBytes);

                print('✅ Image generated with Gemini Flash');
                return {
                  'success': true,
                  'image_path': filePath,
                  'image_url': 'file://$filePath',
                  'image_base64': base64Image,
                  'provider': 'gemini_flash',
                };
              }
            }
          }
        }
      }

      throw Exception('Gemini Flash image generation failed');
    } catch (e) {
      print('❌ Gemini Flash generation failed: $e');
      rethrow;
    }
  }

  /// توليد صورة عبر Backend Replicate (FLUX Schnell - Nano Banana)
  /// Uses server-side Replicate API for secure SaaS model
  Future<Map<String, dynamic>> _generateImageReplicate({
    required String prompt,
    String? negativePrompt,
    required int width,
    required int height,
    required int steps,
    required double guidanceScale,
  }) async {
    try {
      print('🎨 ========== BACKEND REPLICATE IMAGE GENERATION ==========');
      print('📝 Prompt: $prompt');
      print('📐 Size: ${width}x$height');
      progress.value = 0.2;

      final httpService = _httpService;
      if (httpService == null) {
        print('⚠️ HttpService not available, falling back to Gemini...');
        return await _generateImageGemini(prompt: prompt, width: width, height: height);
      }

      // الموديل المستخدم - FLUX Schnell للسرعة
      final model = _settings.replicateImageModel;
      print('🚀 Model: $model (FLUX Schnell / Nano Banana)');

      // إرسال طلب للباك اند Replicate endpoint
      print('🌐 Calling Backend Replicate API at /ai/images/replicate...');
      final response = await httpService.post(
        '/ai/images/replicate',
        body: {
          'prompt': prompt,
          'model': model,
          if (negativePrompt != null) 'negative_prompt': negativePrompt,
          'width': width,
          'height': height,
          'num_outputs': 1,
        },
      );

      progress.value = 0.8;
      print('📥 Backend Replicate Response received');

      // التحقق من نجاح الاستجابة
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        String? imageUrl = data['image_url'];
        List<String>? imageUrls = data['image_urls'] != null
            ? List<String>.from(data['image_urls'])
            : null;

        if (imageUrl == null && (imageUrls == null || imageUrls.isEmpty)) {
          throw Exception('No image in backend Replicate response');
        }

        // استخدام أول صورة إذا كان هناك أكثر من واحدة
        imageUrl ??= imageUrls!.first;

        print('✅ SUCCESS! Image generated via Backend Replicate (FLUX Schnell)');
        progress.value = 1.0;

        return {
          'success': true,
          'image_url': imageUrl,
          'image_urls': imageUrls,
          'provider': 'replicate',
          'model': data['model'] ?? model,
        };
      } else {
        final errorMessage = response['message'] ?? response['error'] ?? 'Backend Replicate error';
        print('❌ Backend Replicate API Error: $errorMessage');

        // Fallback to Gemini if backend fails
        print('⚠️ Falling back to Gemini...');
        return await _generateImageGemini(prompt: prompt, width: width, height: height);
      }
    } catch (e) {
      print('❌ Backend Replicate Exception: $e');
      // Fallback to Gemini
      print('⚠️ Falling back to Gemini...');
      return await _generateImageGemini(prompt: prompt, width: width, height: height);
    }
  }

  /// توليد صورة عبر Stability AI
  Future<Map<String, dynamic>> _generateImageStability({
    required String prompt,
    String? negativePrompt,
    required int width,
    required int height,
    required int steps,
    required double guidanceScale,
  }) async {
    final apiKey = _settings.stabilityApiKey;
    if (apiKey.isEmpty) {
      throw Exception('Stability AI API key not configured');
    }

    final engine = _settings.stabilityEngine;

    print('🔄 Calling Stability AI...');

    final response = await http.post(
      Uri.parse('https://api.stability.ai/v1/generation/$engine/text-to-image'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'text_prompts': [
          {'text': prompt, 'weight': 1.0},
          if (negativePrompt != null) {'text': negativePrompt, 'weight': -1.0},
        ],
        'cfg_scale': guidanceScale,
        'height': height,
        'width': width,
        'steps': steps,
        'samples': 1,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final artifacts = data['artifacts'] as List;

      if (artifacts.isNotEmpty) {
        final base64Image = artifacts.first['base64'];

        return {
          'success': true,
          'image_base64': base64Image,
          'provider': 'stability',
        };
      }
    }

    throw Exception('Stability AI error: ${response.statusCode}');
  }

  /// توليد صورة عبر Leonardo AI
  Future<Map<String, dynamic>> _generateImageLeonardo({
    required String prompt,
    String? negativePrompt,
    required int width,
    required int height,
  }) async {
    final apiKey = _settings.leonardoApiKey;
    if (apiKey.isEmpty) {
      throw Exception('Leonardo AI API key not configured');
    }

    print('🔄 Calling Leonardo AI...');

    final response = await http.post(
      Uri.parse('https://cloud.leonardo.ai/api/rest/v1/generations'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'prompt': prompt,
        if (negativePrompt != null) 'negative_prompt': negativePrompt,
        'width': width,
        'height': height,
        'num_images': 1,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final generationId = data['sdGenerationJob']['generationId'];

      // Poll for result
      return await _pollLeonardoResult(generationId);
    }

    throw Exception('Leonardo AI error: ${response.statusCode}');
  }

  /// استطلاع نتيجة Leonardo
  Future<Map<String, dynamic>> _pollLeonardoResult(String generationId) async {
    final apiKey = _settings.leonardoApiKey;
    int attempts = 0;
    const maxAttempts = 30;

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 3));
      attempts++;
      progress.value = attempts / maxAttempts;

      final response = await http.get(
        Uri.parse('https://cloud.leonardo.ai/api/rest/v1/generations/$generationId'),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generation = data['generations_by_pk'];

        if (generation['status'] == 'COMPLETE') {
          final images = generation['generated_images'] as List;
          if (images.isNotEmpty) {
            return {
              'success': true,
              'image_url': images.first['url'],
              'provider': 'leonardo',
            };
          }
        }
      }
    }

    throw Exception('Leonardo generation timeout');
  }

  // ==================== VIDEO GENERATION ====================

  /// توليد فيديو من نص
  Future<Map<String, dynamic>> generateVideo({
    required String prompt,
    int? duration,
    int? width,
    int? height,
    String? aspectRatio,
    String? provider,
    bool? fast,
  }) async {
    try {
      isGenerating.value = true;
      progress.value = 0.0;

      // Use Backend API with Gemini Veo 3.1 as default (most reliable)
      print('🎬 Generating video with Backend API (Gemini Veo 3.1)...');

      Map<String, dynamic> result;

      // Try Backend API first (recommended)
      result = await _generateVideoBackend(
        prompt: prompt,
        duration: duration ?? 8,
        aspectRatio: aspectRatio ?? '16:9',
        provider: provider ?? 'veo3',
        fast: fast ?? false,
      );

      isGenerating.value = false;
      progress.value = 1.0;

      return result;
    } catch (e) {
      isGenerating.value = false;
      print('❌ Video generation error: $e');
      rethrow;
    }
  }

  /// توليد فيديو عبر Backend API (Gemini Veo 3.1)
  Future<Map<String, dynamic>> _generateVideoBackend({
    required String prompt,
    int duration = 8,
    String aspectRatio = '16:9',
    String provider = 'veo3',
    bool fast = false,
  }) async {
    try {
      print('🎬 ========== BACKEND VIDEO GENERATION (Veo 3.1) ==========');
      print('📝 Prompt: $prompt');
      print('⏱️ Duration: $duration seconds');
      print('📐 Aspect Ratio: $aspectRatio');
      progress.value = 0.1;

      final httpService = _httpService;
      if (httpService == null) {
        print('⚠️ HttpService not available, falling back to Gemini Veo...');
        return await _generateVideoGeminiVeo(prompt: prompt, duration: duration);
      }

      // Choose endpoint based on provider
      String endpoint;
      switch (provider) {
        case 'veo3':
        case 'gemini':
          endpoint = '/ai/video/veo3';
          break;
        case 'veo2':
          endpoint = '/ai/video/veo2';
          break;
        case 'runway':
          endpoint = '/ai/video/runway';
          break;
        case 'replicate':
          endpoint = '/ai/video/replicate';
          break;
        default:
          endpoint = '/ai/video/veo3';
      }

      print('🌐 Calling Backend API at $endpoint...');

      final response = await httpService.post(
        endpoint,
        body: {
          'prompt': prompt,
          'duration': duration,
          'aspect_ratio': aspectRatio,
          'fast': fast,
        },
      );

      progress.value = 0.3;
      print('📥 Backend Response received');

      // Check for immediate success (video ready)
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        // Check if video URL is available
        String? videoUrl = data['video_url'];

        if (videoUrl != null && videoUrl.isNotEmpty) {
          print('✅ SUCCESS! Video generated via Backend Veo 3.1');
          progress.value = 1.0;

          return {
            'success': true,
            'video_url': videoUrl,
            'provider': data['provider'] ?? 'gemini_veo',
            'model': data['model'] ?? 'veo-3.1-generate-preview',
            'duration': data['duration'] ?? duration,
            'aspect_ratio': data['aspect_ratio'] ?? aspectRatio,
          };
        }

        // Check if video is still processing (async generation)
        String? operationId = data['operation_id'];
        String? status = data['status'];

        if (operationId != null && status == 'processing') {
          print('⏳ Video is processing... Polling for status');
          return await _pollBackendVideoStatus(operationId, data['id']);
        }
      }

      // Handle error response
      final errorMessage = response['message'] ?? response['error'] ?? 'Backend video generation error';
      print('❌ Backend Video Error: $errorMessage');

      // Fallback to direct Gemini Veo
      print('⚠️ Falling back to direct Gemini Veo...');
      return await _generateVideoGeminiVeo(prompt: prompt, duration: duration);

    } catch (e) {
      print('❌ Backend Video Exception: $e');
      // Fallback to Gemini Veo
      print('⚠️ Falling back to Gemini Veo...');
      return await _generateVideoGeminiVeo(prompt: prompt, duration: duration);
    }
  }

  /// Poll backend for video generation status
  Future<Map<String, dynamic>> _pollBackendVideoStatus(String operationId, dynamic videoId) async {
    final httpService = _httpService;
    if (httpService == null) {
      throw Exception('HttpService not available');
    }

    int attempts = 0;
    const maxAttempts = 150; // 5 minutes max

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 2));
      attempts++;
      progress.value = 0.3 + (attempts / maxAttempts) * 0.6;

      try {
        final response = await httpService.get('/ai/video/$videoId');

        if (response['success'] == true && response['data'] != null) {
          final data = response['data'];
          final status = data['status']?.toString().toLowerCase();

          if (status == 'completed' || status == 'succeeded') {
            String? videoUrl = data['video_url'];
            if (videoUrl != null) {
              print('✅ Video generation completed!');
              return {
                'success': true,
                'video_url': videoUrl,
                'provider': data['provider'] ?? 'gemini_veo',
                'model': data['model'] ?? 'veo-3.1-generate-preview',
                'duration': data['duration'],
                'aspect_ratio': data['aspect_ratio'],
              };
            }
          } else if (status == 'failed') {
            throw Exception(data['error'] ?? 'Video generation failed');
          }
        }
      } catch (e) {
        print('⚠️ Poll error (attempt $attempts): $e');
        if (attempts >= maxAttempts) rethrow;
      }
    }

    throw Exception('Video generation timeout');
  }

  /// توليد فيديو عبر Gemini Veo
  Future<Map<String, dynamic>> _generateVideoGeminiVeo({
    required String prompt,
    int duration = 5,
  }) async {
    try {
      print('🔄 Generating video with Gemini Veo...');
      progress.value = 0.1;

      // Enhance prompt for better video output
      final enhancedPrompt = '''$prompt

Style: Professional, cinematic quality
Movement: Smooth, natural motion
Lighting: Professional lighting setup''';

      // Start video generation
      final response = await http.post(
        Uri.parse('$_geminiBaseUrl/models/veo-2.0-generate-001:predictLongRunning?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'instances': [
            {'prompt': enhancedPrompt}
          ],
          'parameters': {
            'aspectRatio': '16:9',
            'durationSeconds': duration,
            'personGeneration': 'allow_adult',
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final operationName = data['name'];

        if (operationName != null) {
          print('📊 Video generation started, polling status...');
          return await _pollVeoVideoStatus(operationName);
        }
      }

      print('❌ Veo generation failed: ${response.statusCode}');
      print('Response: ${response.body}');

      // Fallback to other providers
      if (_settings.aiVideoEnabled) {
        return await _generateVideoReplicate(prompt: prompt, duration: duration);
      }

      throw Exception('Veo video generation failed');
    } catch (e) {
      print('❌ Gemini Veo error: $e');
      // Fallback to other providers
      if (_settings.aiVideoEnabled) {
        return await _generateVideoReplicate(prompt: prompt, duration: 5);
      }
      rethrow;
    }
  }

  /// Poll Veo video generation status
  Future<Map<String, dynamic>> _pollVeoVideoStatus(String operationName) async {
    int attempts = 0;
    const maxAttempts = 120; // 4 minutes max

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 2));
      attempts++;
      progress.value = 0.1 + (attempts / maxAttempts) * 0.8;

      final response = await http.get(
        Uri.parse('$_geminiBaseUrl/$operationName?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['done'] == true) {
          final videoResponse = data['response'];
          if (videoResponse != null) {
            final generatedVideos = videoResponse['generatedVideos'] as List?;
            if (generatedVideos != null && generatedVideos.isNotEmpty) {
              final base64Video = generatedVideos[0]['video']?['bytesBase64Encoded'];
              if (base64Video != null) {
                // Save video to file
                final directory = await getTemporaryDirectory();
                final timestamp = DateTime.now().millisecondsSinceEpoch;
                final filePath = '${directory.path}/generated_video_$timestamp.mp4';

                final videoBytes = base64Decode(base64Video);
                await File(filePath).writeAsBytes(videoBytes);

                print('✅ Video generated successfully with Gemini Veo');
                return {
                  'success': true,
                  'video_path': filePath,
                  'video_url': 'file://$filePath',
                  'provider': 'gemini_veo',
                };
              }
            }
          }

          // Check for error
          if (data['error'] != null) {
            throw Exception('Veo error: ${data['error']['message']}');
          }
        }
      }
    }

    throw Exception('Video generation timeout');
  }

  /// توليد فيديو عبر Runway
  Future<Map<String, dynamic>> _generateVideoRunway({
    required String prompt,
    required int duration,
  }) async {
    // استخدام EnvConfig مباشرة لأن المفتاح في ملف .env
    final apiKey = EnvConfig.runwayApiKey;
    if (apiKey.isEmpty || apiKey.contains('your_')) {
      throw Exception('Runway API key not configured');
    }

    final baseUrl = 'https://api.runwayml.com/v1';

    print('🔄 Calling Runway API...');

    final response = await http.post(
      Uri.parse('$baseUrl/generate'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'prompt': prompt,
        'duration': duration,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final taskId = data['task_id'];

      return await _pollRunwayResult(taskId);
    }

    throw Exception('Runway API error: ${response.statusCode}');
  }

  /// استطلاع نتيجة Runway
  Future<Map<String, dynamic>> _pollRunwayResult(String taskId) async {
    final apiKey = EnvConfig.runwayApiKey;
    final baseUrl = 'https://api.runwayml.com/v1';
    int attempts = 0;
    const maxAttempts = 120; // 2 minutes max

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 2));
      attempts++;
      progress.value = attempts / maxAttempts;

      final response = await http.get(
        Uri.parse('$baseUrl/tasks/$taskId'),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'];

        if (status == 'succeeded') {
          return {
            'success': true,
            'video_url': data['output'],
            'provider': 'runway',
          };
        } else if (status == 'failed') {
          throw Exception('Video generation failed');
        }
      }
    }

    throw Exception('Video generation timeout');
  }

  /// توليد فيديو عبر Replicate
  Future<Map<String, dynamic>> _generateVideoReplicate({
    required String prompt,
    required int duration,
  }) async {
    final apiKey = _settings.replicateApiKey;
    if (apiKey.isEmpty) {
      throw Exception('Replicate API key not configured');
    }

    final model = _settings.replicateVideoModel;

    print('🔄 Calling Replicate Video API...');

    final response = await http.post(
      Uri.parse('https://api.replicate.com/v1/predictions'),
      headers: {
        'Authorization': 'Token $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'version': model,
        'input': {
          'prompt': prompt,
          'num_frames': duration * 24, // 24 fps
        },
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final predictionId = data['id'];

      return await _pollReplicateVideoResult(predictionId);
    }

    throw Exception('Replicate Video API error: ${response.statusCode}');
  }

  /// استطلاع نتيجة فيديو Replicate
  Future<Map<String, dynamic>> _pollReplicateVideoResult(String predictionId) async {
    final apiKey = _settings.replicateApiKey;
    int attempts = 0;
    const maxAttempts = 180; // 3 minutes max

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 2));
      attempts++;
      progress.value = attempts / maxAttempts;

      final response = await http.get(
        Uri.parse('https://api.replicate.com/v1/predictions/$predictionId'),
        headers: {
          'Authorization': 'Token $apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'];

        if (status == 'succeeded') {
          final output = data['output'];
          final videoUrl = output is List ? output.first : output;

          return {
            'success': true,
            'video_url': videoUrl,
            'provider': 'replicate',
          };
        } else if (status == 'failed') {
          throw Exception('Video generation failed');
        }
      }
    }

    throw Exception('Video generation timeout');
  }

  // ==================== IMAGE EDITING ====================

  /// تعديل صورة
  Future<Map<String, dynamic>> editImage({
    required String imageUrl,
    required String prompt,
    String? mask,
  }) async {
    try {
      isGenerating.value = true;
      progress.value = 0.0;

      // Use Replicate for consistent results
      final provider = 'replicate';

      // Currently only Replicate and Stability support image editing
      if (provider == 'replicate') {
        return await _editImageReplicate(
          imageUrl: imageUrl,
          prompt: prompt,
          mask: mask,
        );
      } else if (provider == 'stability') {
        return await _editImageStability(
          imageUrl: imageUrl,
          prompt: prompt,
          mask: mask,
        );
      }

      throw Exception('Image editing not supported for provider: $provider');
    } finally {
      isGenerating.value = false;
    }
  }

  /// تعديل صورة عبر Gemini
  Future<Map<String, dynamic>> _editImageGemini({
    required String imageUrl,
    required String prompt,
  }) async {
    try {
      print('🎨 Editing image with Gemini...');
      progress.value = 0.2;

      // First, analyze the image and describe it
      String base64Image;
      String mimeType = 'image/jpeg';

      // Check if it's a local file or URL
      if (imageUrl.startsWith('file://') || imageUrl.startsWith('/')) {
        final filePath = imageUrl.replaceFirst('file://', '');
        final file = File(filePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          base64Image = base64Encode(bytes);

          final ext = filePath.split('.').last.toLowerCase();
          if (ext == 'png') mimeType = 'image/png';
          else if (ext == 'gif') mimeType = 'image/gif';
          else if (ext == 'webp') mimeType = 'image/webp';
        } else {
          throw Exception('Image file not found');
        }
      } else {
        // Fetch image from URL
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          base64Image = base64Encode(response.bodyBytes);
          final contentType = response.headers['content-type'];
          if (contentType != null) {
            if (contentType.contains('png')) mimeType = 'image/png';
            else if (contentType.contains('gif')) mimeType = 'image/gif';
            else if (contentType.contains('webp')) mimeType = 'image/webp';
          }
        } else {
          throw Exception('Failed to fetch image');
        }
      }

      progress.value = 0.4;

      // Analyze image and generate description
      final analysisResponse = await http.post(
        Uri.parse('$_geminiBaseUrl/models/gemini-2.0-flash-exp:generateContent?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'inlineData': {
                    'mimeType': mimeType,
                    'data': base64Image,
                  }
                },
                {
                  'text': '''Describe this image in detail. Then describe how it would look after applying this edit: "$prompt"
Focus on all visual elements that should be in the edited version.
Provide a complete description for generating the edited image.'''
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (analysisResponse.statusCode != 200) {
        throw Exception('Failed to analyze image');
      }

      final analysisData = jsonDecode(analysisResponse.body);
      final description = analysisData['candidates']?[0]?['content']?['parts']?[0]?['text'];

      if (description == null) {
        throw Exception('Failed to get image description');
      }

      progress.value = 0.6;

      // Generate edited image with Imagen
      final editResponse = await http.post(
        Uri.parse('$_geminiBaseUrl/models/imagen-3.0-generate-002:predict?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'instances': [
            {'prompt': description}
          ],
          'parameters': {
            'sampleCount': 1,
            'aspectRatio': '1:1',
            'personGeneration': 'allow_adult',
          }
        }),
      );

      progress.value = 0.8;

      if (editResponse.statusCode == 200) {
        final data = jsonDecode(editResponse.body);
        final predictions = data['predictions'] as List?;

        if (predictions != null && predictions.isNotEmpty) {
          final outputBase64 = predictions[0]['bytesBase64Encoded'];
          if (outputBase64 != null) {
            final directory = await getTemporaryDirectory();
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final filePath = '${directory.path}/edited_image_$timestamp.png';

            final imageBytes = base64Decode(outputBase64);
            await File(filePath).writeAsBytes(imageBytes);

            print('✅ Image edited successfully with Gemini');
            return {
              'success': true,
              'image_path': filePath,
              'image_url': 'file://$filePath',
              'image_base64': outputBase64,
              'provider': 'gemini',
            };
          }
        }
      }

      throw Exception('Gemini image editing failed');
    } catch (e) {
      print('❌ Gemini image editing error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _editImageReplicate({
    required String imageUrl,
    required String prompt,
    String? mask,
  }) async {
    // Implementation for Replicate image editing
    throw UnimplementedError('Replicate image editing coming soon');
  }

  Future<Map<String, dynamic>> _editImageStability({
    required String imageUrl,
    required String prompt,
    String? mask,
  }) async {
    // Implementation for Stability image editing
    throw UnimplementedError('Stability image editing coming soon');
  }

  // ==================== IMAGE TO VIDEO ====================

  /// تحويل صورة إلى فيديو
  Future<Map<String, dynamic>> imageToVideo({
    required String imageUrl,
    required String prompt,
    int duration = 5,
  }) async {
    try {
      isGenerating.value = true;
      progress.value = 0.0;

      print('🎬 Converting image to video...');
      print('📷 Image URL: $imageUrl');
      print('📝 Prompt: $prompt');

      // Use video generation with the prompt enhanced with image description
      final enhancedPrompt = '''Based on this image concept: $prompt

Create a smooth, cinematic video with natural motion and professional quality.
Duration: $duration seconds
Style: Professional, engaging motion''';

      final result = await generateVideo(
        prompt: enhancedPrompt,
        duration: duration,
      );

      isGenerating.value = false;
      progress.value = 1.0;

      return result;
    } catch (e) {
      isGenerating.value = false;
      print('❌ Image to video error: $e');
      rethrow;
    }
  }
}
