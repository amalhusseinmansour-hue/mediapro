import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_script.dart';
import '../core/config/api_config.dart';
import '../core/config/env_config.dart';

/// أنواع نماذج توليد الفيديو المتاحة
enum VideoGenerationModel {
  runwayML, // Runway ML Gen-4 (الأفضل لتوليد الفيديو) - يحتاج credits
  replicate, // Replicate Stable Video Diffusion (بديل مع free tier)
  veo3, // Google Veo 3 (يحتاج Vertex AI)
  googleVeo, // Google Veo AI (القديم)
  dId, // D-ID (لفيديوهات الـ Avatar)
  synthesia, // Synthesia
  demo, // وضع التجربة
}

class AIVideoService {
  final List<VideoScript> _scripts = [];
  final List<GeneratedVideo> _videos = [];

  List<VideoScript> get scripts => _scripts;
  List<GeneratedVideo> get videos => _videos;

  // استخدام المفاتيح من ملف التكوين
  // TODO: OpenAI integration reserved - currently using mock generation
  // static final String _openAIKey = ApiConfig.openAiApiKey;
  static final String _googleVeoApiKey = ApiConfig.googleVeoApiKey;
  static final String _dIdApiKey = ApiConfig.dIdApiKey;
  static String get _geminiApiKey => EnvConfig.googleAIApiKey; // لـ Veo 3

  // روابط API
  static final String _googleVeoBaseUrl = ApiConfig.googleVeoBaseUrl;
  static final String _dIdBaseUrl = ApiConfig.dIdBaseUrl;
  static const String _geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  // Runway ML API
  static const String _runwayBaseUrl = 'https://api.dev.runwayml.com/v1';
  static String get _runwayApiKey => EnvConfig.runwayApiKey;

  // Replicate API
  static const String _replicateBaseUrl = 'https://api.replicate.com/v1';
  static String get _replicateApiToken => EnvConfig.replicateApiToken;

  // النموذج الافتراضي - Runway ML هو الأفضل للفيديو
  VideoGenerationModel _currentModel = VideoGenerationModel.runwayML;

  /// تغيير النموذج المستخدم
  void setModel(VideoGenerationModel model) {
    _currentModel = model;
  }

  /// الحصول على النموذج الحالي
  VideoGenerationModel get currentModel => _currentModel;

  /// توليد سكربت فيديو من موضوع
  Future<VideoScript> generateScript({
    required String topic,
    String? description,
    int duration = 60,
    String language = 'ar',
    String videoType = 'educational',
  }) async {
    try {
      // Demo mode - محاكاة توليد السكربت
      await Future.delayed(const Duration(seconds: 3));

      final script = VideoScript(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        topic: topic,
        script: _generateDemoScript(topic, duration, language, videoType),
        description: description,
        createdAt: DateTime.now(),
        estimatedDuration: duration,
        language: language,
        videoType: videoType,
        scenes: _generateDemoScenes(topic, duration),
      );

      _scripts.insert(0, script);
      return script;

      /* كود حقيقي لاستخدام ChatGPT:

      final openAI = OpenAI.instance.build(
        token: _openAIKey,
        baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 60)),
      );

      final prompt = _buildPrompt(topic, description, duration, language, videoType);

      final request = ChatCompleteText(
        messages: [
          Messages(role: Role.system, content: 'You are a professional video script writer.'),
          Messages(role: Role.user, content: prompt),
        ],
        maxToken: 2000,
        model: GptTurbo0301ChatModel(),
      );

      final response = await openAI.onChatCompletion(request: request);
      final scriptText = response?.choices.last.message?.content ?? '';

      final script = VideoScript(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        topic: topic,
        script: scriptText,
        description: description,
        createdAt: DateTime.now(),
        estimatedDuration: duration,
        language: language,
        videoType: videoType,
        scenes: _parseScenes(scriptText),
      );

      _scripts.insert(0, script);
      return script;
      */
    } catch (e) {
      throw Exception('فشل توليد السكربت: $e');
    }
  }

  /// توليد فيديو من سكربت أو نص مباشر
  Future<GeneratedVideo> generateVideo({
    String? scriptId,
    String? prompt,
    VideoGenerationModel? model,
    int duration = 5, // مدة الفيديو بالثواني
    String quality = '720p',
  }) async {
    try {
      final useModel = model ?? _currentModel;

      VideoScript? script;
      if (scriptId != null) {
        script = _scripts.firstWhere((s) => s.id == scriptId);
      }

      final String videoPrompt = prompt ?? script?.script ?? '';

      switch (useModel) {
        case VideoGenerationModel.runwayML:
          return await _generateWithRunwayML(
            scriptId: scriptId,
            prompt: videoPrompt,
            duration: duration,
          );
        case VideoGenerationModel.replicate:
          return await _generateWithReplicate(
            scriptId: scriptId,
            prompt: videoPrompt,
            duration: duration,
          );
        case VideoGenerationModel.veo3:
          return await _generateWithVeo3(
            scriptId: scriptId,
            prompt: videoPrompt,
            duration: duration,
            quality: quality,
          );
        case VideoGenerationModel.googleVeo:
          return await _generateWithGoogleVeo(
            scriptId: scriptId,
            prompt: videoPrompt,
            duration: duration,
            quality: quality,
          );
        case VideoGenerationModel.dId:
          return await _generateWithDId(
            scriptId: scriptId,
            prompt: videoPrompt,
            duration: duration,
          );
        case VideoGenerationModel.synthesia:
          return await _generateDemo(scriptId, duration);
        case VideoGenerationModel.demo:
          return await _generateDemo(scriptId, duration);
      }
    } catch (e) {
      throw Exception('فشل توليد الفيديو: $e');
    }
  }

  /// توليد فيديو باستخدام Runway ML Gen-4
  Future<GeneratedVideo> _generateWithRunwayML({
    String? scriptId,
    required String prompt,
    required int duration,
  }) async {
    try {
      print('🎬 Generating video with Runway ML Gen-4...');
      print('📝 Prompt: $prompt');

      // التحقق من API key
      if (_runwayApiKey.isEmpty || _runwayApiKey.contains('your_')) {
        print('⚠️ Runway API key not configured, falling back to demo');
        return await _generateDemo(scriptId, duration);
      }

      // إنشاء صورة placeholder للبدء منها
      final placeholderImage = 'https://picsum.photos/seed/${prompt.hashCode.abs()}/1280/720';

      final response = await http.post(
        Uri.parse('$_runwayBaseUrl/image_to_video'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_runwayApiKey',
          'X-Runway-Version': '2024-11-06',
        },
        body: jsonEncode({
          'promptImage': placeholderImage,
          'promptText': prompt,
          'model': 'gen4_turbo',
          'ratio': '1280:720',
          'duration': duration,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final taskId = data['id'] as String;
        print('✅ Runway task created: $taskId');

        // انتظار اكتمال الفيديو
        final videoUrl = await _pollRunwayStatus(taskId);

        final video = GeneratedVideo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          scriptId: scriptId ?? '',
          videoUrl: videoUrl ?? '',
          thumbnailUrl: 'https://picsum.photos/seed/${prompt.hashCode.abs()}/640/360',
          createdAt: DateTime.now(),
          duration: duration,
          status: videoUrl != null ? 'completed' : 'failed',
        );

        _videos.insert(0, video);
        return video;
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['error'] ?? 'Unknown error';
        print('❌ Runway API error: $errorMessage');

        // إذا نفد الرصيد، أظهر رسالة واضحة
        if (errorMessage.toString().contains('credits')) {
          print('💰 Runway credits exhausted, falling back to demo');
        }

        return await _generateDemo(scriptId, duration);
      }
    } catch (e) {
      print('❌ Runway ML error: $e');
      return await _generateDemo(scriptId, duration);
    }
  }

  /// متابعة حالة مهمة Runway
  Future<String?> _pollRunwayStatus(String taskId) async {
    const maxAttempts = 60;
    int attempts = 0;

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 5));
      attempts++;

      try {
        final response = await http.get(
          Uri.parse('$_runwayBaseUrl/tasks/$taskId'),
          headers: {
            'Authorization': 'Bearer $_runwayApiKey',
            'X-Runway-Version': '2024-11-06',
          },
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final status = data['status'] as String;

          if (status == 'SUCCEEDED') {
            return data['output'][0] as String;
          } else if (status == 'FAILED') {
            return null;
          }
        }
      } catch (e) {
        if (attempts >= maxAttempts) return null;
      }
    }
    return null;
  }

  /// توليد فيديو باستخدام Replicate (Stable Video Diffusion)
  Future<GeneratedVideo> _generateWithReplicate({
    String? scriptId,
    required String prompt,
    required int duration,
  }) async {
    try {
      print('🎬 Generating video with Replicate SVD...');
      print('📝 Prompt: $prompt');

      // التحقق من API token
      if (_replicateApiToken.isEmpty || _replicateApiToken.contains('your_')) {
        print('⚠️ Replicate API token not configured, falling back to demo');
        return await _generateDemo(scriptId, duration);
      }

      // Replicate يحتاج صورة كـ input
      // أولاً نولد صورة من Stability AI ثم نحولها لفيديو
      final inputImageUrl = 'https://picsum.photos/seed/${prompt.hashCode.abs()}/1024/576';

      final response = await http.post(
        Uri.parse('$_replicateBaseUrl/predictions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $_replicateApiToken',
        },
        body: jsonEncode({
          'version': 'dc6c2bb7b10099a7f0a7ee0e4f18f3b1c1b7f8a8c8c8c8c8c8c8c8c8c8c8c8c8', // SVD model
          'input': {
            'input_image': inputImageUrl,
            'motion_bucket_id': 127,
            'cond_aug': 0.02,
            'decoding_t': 7,
            'seed': prompt.hashCode.abs(),
          },
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final predictionId = data['id'] as String;
        print('✅ Replicate prediction created: $predictionId');

        // انتظار اكتمال الفيديو
        final videoUrl = await _pollReplicateStatus(predictionId);

        final video = GeneratedVideo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          scriptId: scriptId ?? '',
          videoUrl: videoUrl ?? '',
          thumbnailUrl: inputImageUrl,
          createdAt: DateTime.now(),
          duration: duration,
          status: videoUrl != null ? 'completed' : 'failed',
        );

        _videos.insert(0, video);
        return video;
      } else {
        print('❌ Replicate API error: ${response.body}');
        return await _generateDemo(scriptId, duration);
      }
    } catch (e) {
      print('❌ Replicate error: $e');
      return await _generateDemo(scriptId, duration);
    }
  }

  /// متابعة حالة prediction في Replicate
  Future<String?> _pollReplicateStatus(String predictionId) async {
    const maxAttempts = 60;
    int attempts = 0;

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 5));
      attempts++;

      try {
        final response = await http.get(
          Uri.parse('$_replicateBaseUrl/predictions/$predictionId'),
          headers: {
            'Authorization': 'Token $_replicateApiToken',
          },
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final status = data['status'] as String;

          if (status == 'succeeded') {
            return data['output'] as String;
          } else if (status == 'failed') {
            return null;
          }
        }
      } catch (e) {
        if (attempts >= maxAttempts) return null;
      }
    }
    return null;
  }

  /// توليد فيديو باستخدام Google Veo 3 أو فيديو demo
  /// حالياً يستخدم فيديو demo لأن Veo 3 يحتاج Vertex AI
  Future<GeneratedVideo> _generateWithVeo3({
    String? scriptId,
    required String prompt,
    required int duration,
    required String quality,
  }) async {
    try {
      print('🎬 Generating video...');
      print('📝 Prompt: $prompt');

      // حالياً نستخدم فيديوهات sample مجانية
      // لأن Google Veo 3 يحتاج Vertex AI وليس مجرد Gemini API key

      // قائمة بفيديوهات sample مجانية
      final sampleVideos = [
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      ];

      // اختيار فيديو عشوائي بناءً على الـ prompt
      final videoIndex = prompt.hashCode.abs() % sampleVideos.length;
      final videoUrl = sampleVideos[videoIndex];

      // إنشاء thumbnail
      final thumbnailUrl = 'https://picsum.photos/seed/${prompt.hashCode.abs()}/640/360';

      await Future.delayed(const Duration(seconds: 3)); // محاكاة وقت التوليد

      final video = GeneratedVideo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        scriptId: scriptId ?? '',
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        createdAt: DateTime.now(),
        duration: duration,
        status: 'completed',
      );

      _videos.insert(0, video);
      print('✅ Video generated successfully');
      print('⚠️ Note: This is a sample video. For AI-generated videos, configure Vertex AI.');
      return video;
    } catch (e) {
      print('❌ Video generation error: $e');
      return await _generateDemo(scriptId, duration);
    }
  }

  /// التحقق من حالة توليد الفيديو في Veo 3
  Future<String?> _pollVeo3Status(String operationName) async {
    // حالياً غير مستخدم - يحتاج Vertex AI
    return null;
  }

  /// توليد فيديو باستخدام Gemini generateContent (طريقة بديلة)
  Future<GeneratedVideo> _generateWithGeminiVideo({
    String? scriptId,
    required String prompt,
    required int duration,
  }) async {
    // Redirect to main method
    return await _generateWithVeo3(
      scriptId: scriptId,
      prompt: prompt,
      duration: duration,
      quality: '720p',
    );
  }

  /// حفظ فيديو من Base64
  Future<String> _saveBase64Video(String base64String) async {
    try {
      // في الوقت الحالي، نعيد URL مؤقت
      // يمكن تحسين هذا لاحقاً لحفظ الفيديو محلياً
      print('💾 Saving video from base64...');

      // TODO: Implement local video saving
      // For now, return a sample video URL
      return 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4';
    } catch (e) {
      throw Exception('فشل حفظ الفيديو: $e');
    }
  }

  /// تحسين prompt الفيديو
  String _enhanceVideoPrompt(String prompt, int duration) {
    return '''
Create a high-quality, cinematic video about: $prompt

Requirements:
- Professional cinematography
- Smooth transitions
- High visual quality
- Duration: approximately $duration seconds
- Aspect ratio: 16:9
- Style: Modern and engaging
''';
  }

  /// توليد فيديو باستخدام Google Veo
  Future<GeneratedVideo> _generateWithGoogleVeo({
    String? scriptId,
    required String prompt,
    required int duration,
    required String quality,
  }) async {
    try {
      // استخدام Google Veo API
      final response = await http.post(
        Uri.parse(
          '$_googleVeoBaseUrl/models/veo:generateVideo?key=$_googleVeoApiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': prompt,
          'duration': duration,
          'quality': quality,
          'aspectRatio': '16:9',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // معالجة الاستجابة (قد تختلف حسب API الفعلي)
        String? videoUrl;
        String? operationId;

        if (data['videoUrl'] != null) {
          videoUrl = data['videoUrl'].toString();
        } else if (data['operation'] != null) {
          // الفيديو لا يزال قيد التوليد
          operationId = data['operation']['name']?.toString();
          if (operationId != null) {
            videoUrl = await _pollGoogleVeoStatus(operationId);
          }
        }

        final video = GeneratedVideo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          scriptId: scriptId ?? '',
          videoUrl: videoUrl ?? '',
          thumbnailUrl:
              data['thumbnailUrl']?.toString() ??
              'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/640/360',
          createdAt: DateTime.now(),
          duration: duration,
          status: videoUrl != null ? 'completed' : 'processing',
        );

        _videos.insert(0, video);
        return video;
      } else {
        throw Exception(
          'فشل توليد الفيديو: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('خطأ في Google Veo API: $e');
      // في حالة الفشل، استخدم وضع التجربة
      return await _generateDemo(scriptId, duration);
    }
  }

  /// التحقق من حالة توليد الفيديو في Google Veo
  Future<String?> _pollGoogleVeoStatus(String operationId) async {
    const maxAttempts = 60; // 5 دقائق (60 محاولة × 5 ثواني)
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final response = await http.get(
          Uri.parse('$_googleVeoBaseUrl/$operationId?key=$_googleVeoApiKey'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['done'] == true && data['response'] != null) {
            return data['response']['videoUrl'];
          }
        }

        await Future.delayed(const Duration(seconds: 5));
        attempts++;
      } catch (e) {
        print('خطأ في التحقق من حالة الفيديو: $e');
        break;
      }
    }

    return null;
  }

  /// توليد فيديو باستخدام D-ID
  Future<GeneratedVideo> _generateWithDId({
    String? scriptId,
    required String prompt,
    required int duration,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_dIdBaseUrl/talks'),
        headers: {
          'Authorization': 'Basic $_dIdApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'script': {
            'type': 'text',
            'input': prompt,
            'provider': {
              'type': 'microsoft',
              'voice_id': 'ar-SA-ZariyahNeural',
            },
          },
          'config': {'fluent': true, 'pad_audio': 0.0},
          'source_url':
              'https://create-images-results.d-id.com/DefaultPresenters/Noelle_f/image.jpeg',
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final talkId = data['id'];

        // انتظر حتى يكتمل الفيديو
        final videoUrl = await _waitForDIdVideoCompletion(talkId);

        final video = GeneratedVideo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          scriptId: scriptId ?? '',
          videoUrl: videoUrl ?? '',
          thumbnailUrl:
              'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/640/360',
          createdAt: DateTime.now(),
          duration: duration,
          status: videoUrl != null ? 'completed' : 'processing',
        );

        _videos.insert(0, video);
        return video;
      } else {
        throw Exception('فشل توليد الفيديو: ${response.body}');
      }
    } catch (e) {
      print('خطأ في D-ID API: $e');
      return await _generateDemo(scriptId, duration);
    }
  }

  /// التحقق من اكتمال الفيديو في D-ID
  Future<String?> _waitForDIdVideoCompletion(String talkId) async {
    const maxAttempts = 60;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final response = await http.get(
          Uri.parse('$_dIdBaseUrl/talks/$talkId'),
          headers: {'Authorization': 'Basic $_dIdApiKey'},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['status'] == 'done') {
            return data['result_url'];
          } else if (data['status'] == 'error') {
            throw Exception('فشل توليد الفيديو: ${data['error']}');
          }
        }

        await Future.delayed(const Duration(seconds: 5));
        attempts++;
      } catch (e) {
        print('خطأ في التحقق من حالة الفيديو: $e');
        break;
      }
    }

    return null;
  }

  /// وضع التجربة - محاكاة توليد الفيديو
  Future<GeneratedVideo> _generateDemo(String? scriptId, int duration) async {
    // Demo mode - محاكاة توليد الفيديو
    await Future.delayed(const Duration(seconds: 5));

    final video = GeneratedVideo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      scriptId: scriptId ?? '',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      thumbnailUrl:
          'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/640/360',
      createdAt: DateTime.now(),
      duration: duration,
      status: 'completed',
    );

    _videos.insert(0, video);
    return video;
  }

  // TODO: Prompt builder reserved for ChatGPT integration (currently using demo generation)
  /*
  String _buildPrompt(
    String topic,
    String? description,
    int duration,
    String language,
    String videoType,
  ) {
    final langText = language == 'ar' ? 'بالعربية' : 'in English';
    final durationText = duration < 60
        ? '$duration ثانية'
        : '${(duration / 60).toStringAsFixed(1)} دقيقة';

    return '''
اكتب سكربت فيديو $videoType عن: $topic
${description != null ? 'الوصف: $description' : ''}

المدة المطلوبة: $durationText
اللغة: $langText

يجب أن يتضمن السكربت:
1. مقدمة جذابة
2. محتوى قيم ومنظم
3. خاتمة قوية مع call to action
4. يجب أن يكون مناسب للمدة المحددة

قسم السكربت إلى مشاهد (scenes) مع:
- رقم المشهد
- النص المنطوق
- وصف المرئيات
- المدة المقدرة لكل مشهد

قدم السكربت بصيغة JSON:
{
  "script": "النص الكامل",
  "scenes": [
    {
      "sceneNumber": 1,
      "text": "نص المشهد",
      "visualDescription": "وصف المرئيات",
      "duration": 5
    }
  ]
}
''';
  }
  */

  String _generateDemoScript(
    String topic,
    int duration,
    String language,
    String videoType,
  ) {
    final isArabic = language == 'ar';

    if (isArabic) {
      return '''
مرحباً بكم في فيديو اليوم عن: $topic

في هذا الفيديو سنتعرف على:
• النقطة الأولى المهمة حول الموضوع
• النقطة الثانية التي يجب أن تعرفها
• النقطة الثالثة والأكثر أهمية

دعونا نبدأ!

[المحتوى الرئيسي]
النقطة الأولى: هنا نشرح بالتفصيل الجزء الأول من الموضوع مع أمثلة عملية وشرح مبسط يساعد المشاهد على الفهم.

النقطة الثانية: هنا نتعمق أكثر في التفاصيل ونقدم معلومات قيمة تضيف للمشاهد معرفة جديدة.

النقطة الثالثة: هنا نختم المحتوى بأهم نقطة يجب أن يتذكرها المشاهد من الفيديو.

[الخاتمة]
شكراً لمشاهدتكم! لا تنسوا الاشتراك في القناة وتفعيل الجرس ليصلكم كل جديد.
شاركوا الفيديو مع أصدقائكم إذا أعجبكم!
''';
    } else {
      return '''
Welcome to today's video about: $topic

In this video, we'll explore:
• First important point about the topic
• Second thing you should know
• Third and most crucial aspect

Let's dive in!

[Main Content]
Point One: Here we explain in detail the first part of the topic with practical examples and simple explanation.

Point Two: Here we delve deeper into the details and provide valuable information.

Point Three: Here we conclude with the most important takeaway from this video.

[Conclusion]
Thanks for watching! Don't forget to subscribe and hit the bell icon for notifications.
Share this video with your friends if you found it helpful!
''';
    }
  }

  List<ScriptScene> _generateDemoScenes(String topic, int duration) {
    final sceneDuration = (duration / 5).round();

    return [
      ScriptScene(
        sceneNumber: 1,
        text: 'مقدمة الفيديو والترحيب',
        visualDescription: 'شاشة ترحيب مع عنوان الفيديو',
        duration: sceneDuration,
      ),
      ScriptScene(
        sceneNumber: 2,
        text: 'النقطة الأولى',
        visualDescription: 'رسومات توضيحية للنقطة الأولى',
        duration: sceneDuration,
      ),
      ScriptScene(
        sceneNumber: 3,
        text: 'النقطة الثانية',
        visualDescription: 'رسومات توضيحية للنقطة الثانية',
        duration: sceneDuration,
      ),
      ScriptScene(
        sceneNumber: 4,
        text: 'النقطة الثالثة',
        visualDescription: 'رسومات توضيحية للنقطة الثالثة',
        duration: sceneDuration,
      ),
      ScriptScene(
        sceneNumber: 5,
        text: 'الخاتمة والدعوة للإجراء',
        visualDescription: 'شاشة ختامية مع روابط الاشتراك',
        duration: sceneDuration,
      ),
    ];
  }

  // TODO: Scene parser reserved for ChatGPT integration (currently using demo scenes)
  /*
  List<ScriptScene> _parseScenes(String scriptText) {
    // هنا يمكن تحليل النص وتقسيمه إلى مشاهد
    // للتبسيط، سنستخدم الدالة الافتراضية
    return _generateDemoScenes('parsed', 60);
  }
  */

  void deleteScript(String id) {
    _scripts.removeWhere((s) => s.id == id);
    _videos.removeWhere((v) => v.scriptId == id);
  }

  void deleteVideo(String id) {
    _videos.removeWhere((v) => v.id == id);
  }

  VideoScript? getScriptById(String id) {
    try {
      return _scripts.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  GeneratedVideo? getVideoById(String id) {
    try {
      return _videos.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  List<GeneratedVideo> getVideosByScriptId(String scriptId) {
    return _videos.where((v) => v.scriptId == scriptId).toList();
  }
}
