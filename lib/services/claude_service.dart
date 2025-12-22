import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../core/config/env_config.dart';

/// Claude AI Service (Anthropic)
/// خدمة موحدة للتعامل مع Claude API
class ClaudeService extends GetxService {
  static const String _baseUrl = 'https://api.anthropic.com/v1';

  final RxBool isLoading = false.obs;
  final RxString lastError = ''.obs;

  String get _apiKey => EnvConfig.claudeApiKey;

  @override
  void onInit() {
    super.onInit();
    print('🤖 Claude Service initialized');
    _validateApiKey();
  }

  void _validateApiKey() {
    if (_apiKey.isEmpty || _apiKey.contains('your_')) {
      print('⚠️ Warning: Claude API key not configured');
    } else {
      print('✅ Claude API key configured');
    }
  }

  /// Check if API is configured
  bool get isConfigured => _apiKey.isNotEmpty && !_apiKey.contains('your_') && _apiKey.startsWith('sk-ant-');

  /// توليد محتوى نصي باستخدام Claude
  Future<String> generateContent({
    required String prompt,
    String model = 'claude-3-haiku-20240307',
    double temperature = 0.7,
    int maxTokens = 2048,
  }) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      if (!isConfigured) {
        throw Exception('Claude API key not configured. Please add your API key.');
      }

      print('🔄 Calling Claude API...');
      print('📝 Model: $model');

      final response = await http.post(
        Uri.parse('$_baseUrl/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': model,
          'max_tokens': maxTokens,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
        }),
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['content'];
        if (content != null && content.isNotEmpty) {
          final text = content[0]['text'] ?? '';
          print('✅ Claude response received');
          return text;
        }
        throw Exception('Empty response from Claude');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error']?['message'] ?? 'Claude API error: ${response.statusCode}');
      }
    } catch (e) {
      lastError.value = e.toString();
      print('❌ Claude API error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// توليد محتوى سوشال ميديا
  Future<String> generateSocialMediaContent({
    required String topic,
    required String platform,
    required String contentType,
    String language = 'ar',
    String tone = 'professional',
    int maxLength = 300,
    bool includeHashtags = true,
    bool includeEmoji = true,
  }) async {
    final langName = language == 'ar' ? 'العربية' : 'English';
    final toneAr = _getToneInArabic(tone);

    final prompt = '''
أنت خبير في كتابة محتوى السوشال ميديا. اكتب محتوى احترافي وجذاب.

المطلوب: $topic
المنصة: $platform
نوع المحتوى: $contentType
اللغة: $langName
الأسلوب: $toneAr
الطول: حوالي $maxLength حرف

${includeHashtags ? 'أضف هاشتاقات مناسبة في نهاية المحتوى.' : ''}
${includeEmoji ? 'استخدم إيموجي مناسب لجعل المحتوى أكثر جاذبية.' : ''}

اكتب المحتوى مباشرة بدون مقدمات أو شروحات.
''';

    return await generateContent(
      prompt: prompt,
      maxTokens: maxLength * 2,
    );
  }

  /// توليد هاشتاقات
  Future<List<String>> generateHashtags({
    required String content,
    String platform = 'instagram',
    String language = 'ar',
    int count = 10,
  }) async {
    final prompt = '''
اقترح $count هاشتاق مناسب للمحتوى التالي على منصة $platform.
اكتب الهاشتاقات فقط بدون شرح، كل هاشتاق في سطر جديد.

المحتوى:
$content
''';

    try {
      final response = await generateContent(prompt: prompt, maxTokens: 500);
      final hashtags = response
          .split('\n')
          .map((h) => h.trim())
          .where((h) => h.startsWith('#') && h.length > 1)
          .take(count)
          .toList();

      return hashtags.isNotEmpty ? hashtags : _getDefaultHashtags(language);
    } catch (e) {
      return _getDefaultHashtags(language);
    }
  }

  /// تحسين محتوى موجود
  Future<String> improveContent({
    required String content,
    String improvement = 'general',
  }) async {
    final improvementDesc = _getImprovementDescription(improvement);

    final prompt = '''
حسّن المحتوى التالي: $improvementDesc

المحتوى الأصلي:
$content

اكتب المحتوى المحسّن مباشرة بدون مقدمات.
''';

    return await generateContent(prompt: prompt);
  }

  /// ترجمة محتوى
  Future<String> translateContent({
    required String content,
    required String targetLanguage,
  }) async {
    final langName = targetLanguage == 'ar' ? 'العربية' : 'English';

    final prompt = '''
ترجم المحتوى التالي إلى $langName مع الحفاظ على الأسلوب والنبرة:

$content

اكتب الترجمة مباشرة بدون مقدمات.
''';

    return await generateContent(prompt: prompt);
  }

  String _getToneInArabic(String tone) {
    switch (tone.toLowerCase()) {
      case 'professional':
        return 'احترافي';
      case 'casual':
        return 'عفوي';
      case 'friendly':
        return 'ودود';
      case 'inspirational':
        return 'تحفيزي';
      case 'humorous':
        return 'فكاهي';
      case 'educational':
        return 'تعليمي';
      default:
        return 'احترافي';
    }
  }

  String _getImprovementDescription(String improvement) {
    switch (improvement.toLowerCase()) {
      case 'engagement':
        return 'لزيادة التفاعل';
      case 'clarity':
        return 'لزيادة الوضوح';
      case 'seo':
        return 'لتحسين SEO';
      case 'shorter':
        return 'لجعله أقصر';
      case 'longer':
        return 'لجعله أطول';
      default:
        return 'بشكل عام';
    }
  }

  List<String> _getDefaultHashtags(String language) {
    if (language == 'ar') {
      return ['#محتوى', '#سوشال_ميديا', '#تسويق', '#نجاح', '#أعمال'];
    }
    return ['#content', '#socialmedia', '#marketing', '#success', '#business'];
  }
}
