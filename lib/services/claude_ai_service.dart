import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../core/config/api_config.dart';
import 'auth_service.dart';

/// Claude AI Service - خدمة Claude AI لتوليد المحتوى
/// تدعم توليد المحتوى لجميع منصات التواصل الاجتماعي
class ClaudeAIService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();

  // حالة الخدمة
  final RxBool isLoading = false.obs;
  final RxString lastError = ''.obs;
  final RxBool isConfigured = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkStatus();
  }

  /// الحصول على headers
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${_authService.currentUser.value?.id ?? ''}',
  };

  /// فحص حالة الخدمة
  Future<void> checkStatus() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.backendBaseUrl}/claude/status'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        isConfigured.value = data['configured'] ?? false;
      }
    } catch (e) {
      print('Error checking Claude status: $e');
    }
  }

  /// توليد محتوى سوشال ميديا شامل
  Future<Map<String, dynamic>> generateContent({
    required String topic,
    required String platform,
    String contentType = 'post',
    String language = 'ar',
    String tone = 'professional',
    bool includeHashtags = true,
    bool includeEmojis = true,
    String targetAudience = 'general',
    String? brand,
    List<String>? keywords,
    int variations = 1,
  }) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final response = await http.post(
        Uri.parse('${ApiConfig.backendBaseUrl}/claude/generate'),
        headers: _headers,
        body: json.encode({
          'topic': topic,
          'platform': platform,
          'content_type': contentType,
          'language': language,
          'tone': tone,
          'include_hashtags': includeHashtags,
          'include_emojis': includeEmojis,
          'target_audience': targetAudience,
          'brand': brand,
          'keywords': keywords,
          'variations': variations,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['error'] ?? 'Failed to generate content');
      }
    } catch (e) {
      lastError.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// توليد هاشتاقات
  Future<Map<String, dynamic>> generateHashtags({
    required String topic,
    String platform = 'instagram',
    int count = 15,
    String language = 'ar',
  }) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final response = await http.post(
        Uri.parse('${ApiConfig.backendBaseUrl}/claude/hashtags'),
        headers: _headers,
        body: json.encode({
          'topic': topic,
          'platform': platform,
          'count': count,
          'language': language,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['error'] ?? 'Failed to generate hashtags');
      }
    } catch (e) {
      lastError.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// توليد أفكار محتوى
  Future<Map<String, dynamic>> generateIdeas({
    required String niche,
    String platform = 'instagram',
    int count = 10,
    String timeframe = 'week',
  }) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final response = await http.post(
        Uri.parse('${ApiConfig.backendBaseUrl}/claude/ideas'),
        headers: _headers,
        body: json.encode({
          'niche': niche,
          'platform': platform,
          'count': count,
          'timeframe': timeframe,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['error'] ?? 'Failed to generate ideas');
      }
    } catch (e) {
      lastError.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// تحسين محتوى موجود
  Future<Map<String, dynamic>> improveContent({
    required String content,
    String platform = 'instagram',
    List<String> improvements = const ['engagement', 'clarity', 'hashtags'],
  }) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final response = await http.post(
        Uri.parse('${ApiConfig.backendBaseUrl}/claude/improve'),
        headers: _headers,
        body: json.encode({
          'content': content,
          'platform': platform,
          'improvements': improvements,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['error'] ?? 'Failed to improve content');
      }
    } catch (e) {
      lastError.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// توليد سكريبت فيديو
  Future<Map<String, dynamic>> generateVideoScript({
    required String topic,
    String platform = 'tiktok',
    int duration = 60,
    String style = 'educational',
    String language = 'ar',
  }) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final response = await http.post(
        Uri.parse('${ApiConfig.backendBaseUrl}/claude/video-script'),
        headers: _headers,
        body: json.encode({
          'topic': topic,
          'platform': platform,
          'duration': duration,
          'style': style,
          'language': language,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['error'] ?? 'Failed to generate video script');
      }
    } catch (e) {
      lastError.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// تحليل محتوى
  Future<Map<String, dynamic>> analyzeContent({
    required String content,
    String platform = 'instagram',
  }) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final response = await http.post(
        Uri.parse('${ApiConfig.backendBaseUrl}/claude/analyze'),
        headers: _headers,
        body: json.encode({
          'content': content,
          'platform': platform,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['error'] ?? 'Failed to analyze content');
      }
    } catch (e) {
      lastError.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// توليد جدول محتوى
  Future<Map<String, dynamic>> generateCalendar({
    required String niche,
    List<String> platforms = const ['instagram'],
    int days = 7,
    int postsPerDay = 1,
  }) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final response = await http.post(
        Uri.parse('${ApiConfig.backendBaseUrl}/claude/calendar'),
        headers: _headers,
        body: json.encode({
          'niche': niche,
          'platforms': platforms,
          'days': days,
          'posts_per_day': postsPerDay,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['error'] ?? 'Failed to generate calendar');
      }
    } catch (e) {
      lastError.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// توليد محتوى شامل لجميع المنصات
  Future<Map<String, dynamic>> generateComprehensive({
    required String topic,
    List<String> platforms = const ['instagram', 'facebook', 'twitter'],
    String language = 'ar',
    String tone = 'professional',
    String? brand,
  }) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final response = await http.post(
        Uri.parse('${ApiConfig.backendBaseUrl}/claude/comprehensive'),
        headers: _headers,
        body: json.encode({
          'topic': topic,
          'platforms': platforms,
          'language': language,
          'tone': tone,
          'brand': brand,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['error'] ?? 'Failed to generate comprehensive content');
      }
    } catch (e) {
      lastError.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// الحصول على النغمات المتاحة
  static List<Map<String, String>> getAvailableTones() {
    return [
      {'id': 'professional', 'name': 'احترافي', 'name_en': 'Professional'},
      {'id': 'casual', 'name': 'غير رسمي', 'name_en': 'Casual'},
      {'id': 'funny', 'name': 'فكاهي', 'name_en': 'Funny'},
      {'id': 'inspiring', 'name': 'ملهم', 'name_en': 'Inspiring'},
      {'id': 'educational', 'name': 'تعليمي', 'name_en': 'Educational'},
      {'id': 'urgent', 'name': 'عاجل', 'name_en': 'Urgent'},
      {'id': 'friendly', 'name': 'ودود', 'name_en': 'Friendly'},
      {'id': 'formal', 'name': 'رسمي', 'name_en': 'Formal'},
    ];
  }

  /// الحصول على المنصات المدعومة
  static List<Map<String, String>> getSupportedPlatforms() {
    return [
      {'id': 'instagram', 'name': 'Instagram', 'icon': 'instagram'},
      {'id': 'facebook', 'name': 'Facebook', 'icon': 'facebook'},
      {'id': 'twitter', 'name': 'Twitter/X', 'icon': 'twitter'},
      {'id': 'tiktok', 'name': 'TikTok', 'icon': 'tiktok'},
      {'id': 'linkedin', 'name': 'LinkedIn', 'icon': 'linkedin'},
      {'id': 'youtube', 'name': 'YouTube', 'icon': 'youtube'},
      {'id': 'snapchat', 'name': 'Snapchat', 'icon': 'snapchat'},
    ];
  }

  /// الحصول على أنواع المحتوى لكل منصة
  static Map<String, List<Map<String, String>>> getContentTypes() {
    return {
      'instagram': [
        {'id': 'post', 'name': 'منشور'},
        {'id': 'story', 'name': 'قصة'},
        {'id': 'reel', 'name': 'ريل'},
        {'id': 'carousel', 'name': 'كاروسيل'},
      ],
      'facebook': [
        {'id': 'post', 'name': 'منشور'},
        {'id': 'story', 'name': 'قصة'},
        {'id': 'video', 'name': 'فيديو'},
      ],
      'twitter': [
        {'id': 'tweet', 'name': 'تغريدة'},
        {'id': 'thread', 'name': 'ثريد'},
      ],
      'tiktok': [
        {'id': 'video', 'name': 'فيديو'},
        {'id': 'caption', 'name': 'كابشن'},
      ],
      'linkedin': [
        {'id': 'post', 'name': 'منشور'},
        {'id': 'article', 'name': 'مقالة'},
      ],
      'youtube': [
        {'id': 'title', 'name': 'عنوان'},
        {'id': 'description', 'name': 'وصف'},
        {'id': 'script', 'name': 'سكريبت'},
      ],
      'snapchat': [
        {'id': 'story', 'name': 'قصة'},
      ],
    };
  }
}
