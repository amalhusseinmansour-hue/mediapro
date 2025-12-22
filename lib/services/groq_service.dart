import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../core/config/env_config.dart';

/// Groq AI Service - مجاني 100% وسريع جداً
/// يستخدم Llama 3.3 70B - أفضل نموذج مفتوح المصدر
class GroqService extends GetxService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';

  // النماذج المتاحة (كلها مجانية!)
  static const String modelLlama70B = 'llama-3.3-70b-versatile'; // الأفضل للمحتوى
  static const String modelLlama8B = 'llama-3.1-8b-instant'; // الأسرع
  static const String modelMixtral = 'mixtral-8x7b-32768'; // جيد للنصوص الطويلة

  String get _apiKey => EnvConfig.groqApiKey;
  bool get isConfigured => _apiKey.isNotEmpty && !_apiKey.contains('your_');

  final RxBool isLoading = false.obs;
  final RxString lastError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('🚀 Groq Service initialized (FREE & Ultra Fast!)');
    if (isConfigured) {
      print('✅ Groq API key configured');
    } else {
      print('⚠️ Groq API key not configured - Get FREE key at https://console.groq.com');
    }
  }

  /// توليد محتوى نصي
  Future<String> generateContent({
    required String prompt,
    String? systemPrompt,
    String model = modelLlama70B,
    double temperature = 0.7,
    int maxTokens = 2048,
  }) async {
    if (!isConfigured) {
      throw Exception('Groq API key not configured');
    }

    try {
      isLoading.value = true;
      lastError.value = '';

      final messages = <Map<String, String>>[];

      if (systemPrompt != null) {
        messages.add({'role': 'system', 'content': systemPrompt});
      }
      messages.add({'role': 'user', 'content': prompt});

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': messages,
          'temperature': temperature,
          'max_tokens': maxTokens,
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];

        if (content != null && content.isNotEmpty) {
          print('✅ Groq response received (${data['usage']?['total_tokens']} tokens)');
          return content;
        }
        throw Exception('Empty response from Groq');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error']?['message'] ?? 'Groq API error: ${response.statusCode}');
      }
    } catch (e) {
      lastError.value = e.toString();
      print('❌ Groq error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// توليد محتوى سوشال ميديا
  Future<String> generateSocialMediaContent({
    required String topic,
    required String platform,
    String contentType = 'post',
    String language = 'ar',
    String tone = 'professional',
    int? maxLength,
    bool includeHashtags = true,
    bool includeEmoji = true,
  }) async {
    final platformLimits = {
      'twitter': 280,
      'instagram': 2200,
      'facebook': 63206,
      'linkedin': 3000,
      'tiktok': 2200,
    };

    final limit = maxLength ?? platformLimits[platform.toLowerCase()] ?? 500;
    final langName = language == 'ar' ? 'Arabic' : 'English';

    final systemPrompt = '''أنت خبير في إنشاء محتوى السوشال ميديا.
قواعد مهمة:
- اكتب بـ $langName فقط
- الأسلوب: $tone
- الحد الأقصى: $limit حرف
- المنصة: $platform
${includeHashtags ? '- أضف هاشتاقات مناسبة (5-10)' : ''}
${includeEmoji ? '- استخدم إيموجي مناسبة' : ''}
- اجعل المحتوى جذاباً ويشجع على التفاعل''';

    final prompt = '''اكتب $contentType لـ $platform عن:
$topic

اكتب المحتوى مباشرة بدون مقدمات.''';

    return generateContent(
      prompt: prompt,
      systemPrompt: systemPrompt,
      temperature: 0.8,
    );
  }

  /// توليد هاشتاقات
  Future<List<String>> generateHashtags({
    required String topic,
    String platform = 'instagram',
    String language = 'ar',
    int count = 10,
  }) async {
    final prompt = '''اقترح $count هاشتاق لمنصة $platform عن الموضوع التالي:
$topic

القواعد:
- كل هاشتاق في سطر منفصل
- ابدأ كل هاشتاق بـ #
- اللغة: ${language == 'ar' ? 'العربية' : 'الإنجليزية'}
- اجعلها متنوعة (شائعة + متخصصة)''';

    final result = await generateContent(
      prompt: prompt,
      model: modelLlama8B, // أسرع للمهام البسيطة
      temperature: 0.6,
      maxTokens: 500,
    );

    return result
        .split('\n')
        .map((h) => h.trim())
        .where((h) => h.startsWith('#') && h.length > 1)
        .toList();
  }

  /// توليد أفكار محتوى
  Future<List<String>> generateContentIdeas({
    required String topic,
    String platform = 'general',
    String language = 'ar',
    int count = 5,
  }) async {
    final prompt = '''اقترح $count أفكار محتوى إبداعية عن:
$topic

المنصة: $platform
اللغة: ${language == 'ar' ? 'العربية' : 'الإنجليزية'}

قدم قائمة مرقمة بالأفكار مع وصف قصير لكل فكرة.''';

    final result = await generateContent(
      prompt: prompt,
      temperature: 0.9,
      maxTokens: 1000,
    );

    return result
        .split('\n')
        .map((i) => i.trim())
        .where((i) => i.isNotEmpty)
        .toList();
  }

  /// تحسين المحتوى
  Future<String> improveContent({
    required String content,
    String platform = 'general',
    String language = 'ar',
  }) async {
    final prompt = '''حسّن هذا المحتوى لمنصة $platform:

$content

اجعله:
- أكثر جاذبية وتفاعلية
- مناسب للمنصة
- يحافظ على المعنى الأساسي
- بنفس اللغة الأصلية

اكتب المحتوى المحسن مباشرة.''';

    return generateContent(
      prompt: prompt,
      temperature: 0.7,
    );
  }

  /// تحليل المحتوى
  Future<Map<String, dynamic>> analyzeContent({
    required String content,
    String platform = 'general',
  }) async {
    final prompt = '''حلل هذا المحتوى لمنصة $platform:

$content

قدم التحليل بصيغة JSON:
{
  "score": (1-10),
  "strengths": ["نقطة قوة 1", "نقطة قوة 2"],
  "weaknesses": ["نقطة ضعف 1"],
  "suggestions": ["اقتراح 1", "اقتراح 2"],
  "estimated_engagement": "low/medium/high",
  "best_posting_time": "الوقت المثالي للنشر"
}''';

    final result = await generateContent(
      prompt: prompt,
      temperature: 0.3,
      maxTokens: 500,
    );

    try {
      // استخراج JSON من النص
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(result);
      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(0)!);
      }
    } catch (e) {
      print('⚠️ Failed to parse analysis JSON');
    }

    return {
      'score': 7,
      'analysis': result,
    };
  }

  /// ترجمة المحتوى
  Future<String> translateContent({
    required String content,
    required String targetLanguage,
  }) async {
    final langName = targetLanguage == 'ar' ? 'العربية' : 'English';

    final prompt = '''ترجم النص التالي إلى $langName:

$content

قواعد الترجمة:
- حافظ على المعنى والأسلوب
- اجعل الترجمة طبيعية وليست حرفية
- حافظ على الهاشتاقات والإيموجي

اكتب الترجمة مباشرة.''';

    return generateContent(
      prompt: prompt,
      temperature: 0.3,
    );
  }

  /// توليد سكريبت فيديو
  Future<String> generateVideoScript({
    required String topic,
    int durationSeconds = 60,
    String platform = 'tiktok',
    String language = 'ar',
  }) async {
    final prompt = '''اكتب سكريبت فيديو قصير ($durationSeconds ثانية) لمنصة $platform عن:
$topic

الصيغة:
- مقدمة جذابة (5 ثواني)
- المحتوى الرئيسي
- خاتمة مع CTA

اكتب بـ ${language == 'ar' ? 'العربية' : 'English'}.''';

    return generateContent(
      prompt: prompt,
      temperature: 0.8,
      maxTokens: 1500,
    );
  }
}
