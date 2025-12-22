import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../core/config/env_config.dart';
import 'http_service.dart';

/// خدمة AI Proxy - تتصل بـ Cloudflare Worker
/// توفر Rate Limiting و Caching تلقائياً
class AIProxyService extends GetxService {
  // رابط الـ Cloudflare Worker
  static const String _proxyUrl = 'https://mediapro-ai-proxy.YOUR_SUBDOMAIN.workers.dev';

  // استخدام Backend كـ fallback
  HttpService? get _httpService {
    try {
      return Get.find<HttpService>();
    } catch (e) {
      return null;
    }
  }

  final RxBool isLoading = false.obs;
  final RxString lastError = ''.obs;
  final RxInt remainingRequests = (-1).obs;
  final RxString currentProvider = 'proxy'.obs;

  // إحصائيات الاستخدام
  final RxMap<String, dynamic> usageStats = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    print('🤖 AI Proxy Service initialized');
    print('📡 Proxy URL: $_proxyUrl');
    _loadUsage();
  }

  /// توليد محتوى باستخدام AI Proxy
  Future<String> generateContent({
    required String prompt,
    String type = 'content', // content, hashtags, ideas, improve
    String platform = 'general',
    String language = 'ar',
    String tone = 'professional',
  }) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      // محاولة استخدام Proxy أولاً
      final result = await _callProxy(
        endpoint: '/api/generate',
        body: {
          'prompt': prompt,
          'type': type,
          'platform': platform,
          'language': language,
          'tone': tone,
          'userId': await _getUserId(),
          'subscriptionTier': await _getSubscriptionTier(),
        },
      );

      if (result['success'] == true) {
        currentProvider.value = result['provider'] ?? 'proxy';
        if (result['usage'] != null) {
          remainingRequests.value = result['usage']['remaining'] ?? -1;
        }
        return result['content'];
      }

      // إذا فشل Proxy، استخدم Backend مباشرة
      return await _fallbackToBackend(prompt, type, platform, language, tone);

    } catch (e) {
      lastError.value = e.toString();
      // Fallback to backend
      return await _fallbackToBackend(prompt, type, platform, language, tone);
    } finally {
      isLoading.value = false;
    }
  }

  /// توليد محتوى سوشال ميديا
  Future<String> generateSocialContent({
    required String topic,
    required String platform,
    String language = 'ar',
    String tone = 'professional',
    bool includeHashtags = true,
  }) async {
    final prompt = '''
أنشئ محتوى لمنصة $platform عن الموضوع التالي:
$topic

المتطلبات:
- اللغة: ${language == 'ar' ? 'العربية' : 'الإنجليزية'}
- الأسلوب: $tone
${includeHashtags ? '- أضف هاشتاقات مناسبة' : ''}
''';

    return generateContent(
      prompt: prompt,
      type: 'content',
      platform: platform,
      language: language,
      tone: tone,
    );
  }

  /// توليد هاشتاقات
  Future<List<String>> generateHashtags({
    required String topic,
    String platform = 'instagram',
    String language = 'ar',
    int count = 10,
  }) async {
    final prompt = '''
اقترح $count هاشتاقات لـ $platform عن:
$topic

أرجع الهاشتاقات فقط، كل هاشتاق في سطر منفصل.
''';

    final result = await generateContent(
      prompt: prompt,
      type: 'hashtags',
      platform: platform,
      language: language,
    );

    return result
        .split('\n')
        .map((h) => h.trim())
        .where((h) => h.startsWith('#') || h.isNotEmpty)
        .map((h) => h.startsWith('#') ? h : '#$h')
        .toList();
  }

  /// توليد أفكار محتوى
  Future<List<String>> generateIdeas({
    required String topic,
    String platform = 'general',
    String language = 'ar',
    int count = 5,
  }) async {
    final prompt = '''
اقترح $count أفكار محتوى إبداعية عن:
$topic

المنصة: $platform
اللغة: ${language == 'ar' ? 'العربية' : 'الإنجليزية'}

أرجع قائمة مرقمة بالأفكار.
''';

    final result = await generateContent(
      prompt: prompt,
      type: 'ideas',
      platform: platform,
      language: language,
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
    final prompt = '''
حسّن هذا المحتوى للسوشال ميديا:

$content

اجعله أكثر جاذبية وتفاعلية مع الحفاظ على المعنى الأساسي.
''';

    return generateContent(
      prompt: prompt,
      type: 'improve',
      platform: platform,
      language: language,
    );
  }

  /// الحصول على إحصائيات الاستخدام
  Future<Map<String, dynamic>> getUsage() async {
    try {
      final userId = await _getUserId();
      final tier = await _getSubscriptionTier();

      final response = await http.get(
        Uri.parse('$_proxyUrl/api/usage?userId=$userId&tier=$tier'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        usageStats.value = data;
        remainingRequests.value = data['remaining'] ?? -1;
        return data;
      }
    } catch (e) {
      print('⚠️ Failed to get usage: $e');
    }

    return {};
  }

  /// استدعاء الـ Proxy
  Future<Map<String, dynamic>> _callProxy({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_proxyUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 60));

      final data = json.decode(response.body);

      if (response.statusCode == 429) {
        // Rate limit exceeded
        throw Exception(data['message_ar'] ?? 'تم تجاوز الحد المسموح');
      }

      return data;
    } catch (e) {
      print('⚠️ Proxy call failed: $e');
      rethrow;
    }
  }

  /// Fallback إلى Backend
  Future<String> _fallbackToBackend(
    String prompt,
    String type,
    String platform,
    String language,
    String tone,
  ) async {
    print('🔄 Falling back to backend...');
    currentProvider.value = 'backend';

    if (_httpService == null) {
      throw Exception('No AI service available');
    }

    try {
      final response = await _httpService!.post(
        '/ai/optimize/platform',
        body: {
          'content': prompt,
          'platform': platform,
          'language': language,
          'tone': tone,
        },
      );

      if (response['success'] == true) {
        return response['data']['optimized_content'] ?? response['data']['content'] ?? prompt;
      }

      throw Exception(response['message'] ?? 'Backend AI failed');
    } catch (e) {
      print('❌ Backend fallback failed: $e');
      throw Exception('جميع خدمات AI غير متاحة حالياً');
    }
  }

  Future<String> _getUserId() async {
    // الحصول على ID المستخدم من التطبيق
    try {
      final authController = Get.find<dynamic>();
      return authController.user?.id?.toString() ?? 'anonymous';
    } catch (e) {
      return 'anonymous';
    }
  }

  Future<String> _getSubscriptionTier() async {
    // الحصول على مستوى الاشتراك
    try {
      final authController = Get.find<dynamic>();
      return authController.user?.subscriptionTier ?? 'free';
    } catch (e) {
      return 'free';
    }
  }

  Future<void> _loadUsage() async {
    await getUsage();
  }
}
