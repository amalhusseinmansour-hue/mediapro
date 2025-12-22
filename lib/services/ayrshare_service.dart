import 'http_service.dart';

/// خدمة Ayrshare للربط التلقائي مع منصات التواصل الاجتماعي
/// توفر ربط سهل وسريع بدون تعقيد OAuth
class AyrshareService {
  static final AyrshareService _instance = AyrshareService._internal();
  factory AyrshareService() => _instance;
  AyrshareService._internal();

  final HttpService _httpService = HttpService();

  // Ayrshare API Configuration
  // TODO: Ayrshare integration constants reserved for future implementation
  // static const String _ayrshareBaseUrl = 'https://app.ayrshare.com/api';
  // String? _apiKey;

  // TODO: API key initialization reserved for future Ayrshare integration
  /*
  /// تهيئة الخدمة بـ API Key
  void init(String apiKey) {
    _apiKey = apiKey;
    print('✅ Ayrshare Service initialized');
  }
  */

  /// إنشاء Ayrshare Profile للمستخدم (Business Plan Workflow)
  ///
  /// [userId] - معرف المستخدم في تطبيقك
  /// Returns: Profile Key
  Future<String?> createProfile({required String userId}) async {
    try {
      print('🔄 Creating Ayrshare Profile for user $userId...');

      final response = await _httpService.post(
        '/api/ayrshare/create-profile',
        body: {'user_id': userId, 'title': 'User $userId'},
      );

      if (response['success'] == true) {
        final profileKey = response['data']['profile_key'] as String;
        print('✅ Profile created successfully: $profileKey');
        return profileKey;
      } else {
        throw Exception(response['message'] ?? 'Failed to create profile');
      }
    } catch (e) {
      print('❌ Error creating profile: $e');
      return null;
    }
  }

  /// إنشاء JWT URL للـ Single Sign-On
  /// هذا هو الرابط الذي يفتحه المستخدم لربط حساباته
  ///
  /// [userId] - معرف المستخدم في تطبيقك
  /// Returns: JWT URL
  Future<Map<String, dynamic>> generateJWT({required String userId}) async {
    try {
      print('🔄 Generating JWT for user $userId...');

      final response = await _httpService.post(
        '/api/ayrshare/generate-jwt',
        body: {'user_id': userId},
      );

      if (response['success'] == true) {
        print('✅ JWT generated successfully');
        return {
          'success': true,
          'url': response['data']['url'],
          'profile_key': response['data']['profile_key'],
        };
      } else {
        throw Exception(response['message'] ?? 'Failed to generate JWT');
      }
    } catch (e) {
      print('❌ Error generating JWT: $e');
      rethrow;
    }
  }

  /// الحصول على قائمة الحسابات المربوطة للمستخدم
  ///
  /// Returns: قائمة الحسابات المربوطة
  Future<List<Map<String, dynamic>>> getConnectedProfiles() async {
    try {
      print('🔄 Fetching connected profiles...');

      final response = await _httpService.get('/api/ayrshare/profiles');

      if (response['success'] == true) {
        final profiles = response['data']['profiles'] as List;
        print('✅ Found ${profiles.length} connected profiles');
        return profiles.cast<Map<String, dynamic>>();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch profiles');
      }
    } catch (e) {
      print('❌ Error fetching profiles: $e');
      return [];
    }
  }

  /// نشر محتوى على منصة أو أكثر
  /// يستخدم Profile Key للنشر نيابة عن المستخدم (Business Plan)
  ///
  /// [userId] - معرف المستخدم (مهم!)
  /// [platforms] - قائمة المنصات للنشر عليها
  /// [text] - النص المراد نشره
  /// [mediaUrls] - روابط الصور/الفيديو (اختياري)
  /// [scheduleDate] - موعد النشر المجدول (اختياري)
  /// Returns: معلومات المنشور المنشور
  Future<Map<String, dynamic>> publishPost({
    required String userId,
    required List<String> platforms,
    required String text,
    List<String>? mediaUrls,
    DateTime? scheduleDate,
    Map<String, dynamic>? platformSpecific,
  }) async {
    try {
      print(
        '🔄 Publishing post for user $userId to ${platforms.join(", ")}...',
      );

      final body = {
        'user_id': userId, // مهم جداً للـ Business Plan!
        'platforms': platforms,
        'post': text,
        if (mediaUrls != null && mediaUrls.isNotEmpty) 'mediaUrls': mediaUrls,
        if (scheduleDate != null)
          'scheduleDate': scheduleDate.toIso8601String(),
        if (platformSpecific != null) ...platformSpecific,
      };

      final response = await _httpService.post(
        '/api/ayrshare/post',
        body: body,
      );

      if (response['success'] == true) {
        print('✅ Post published successfully');
        return {
          'success': true,
          'post_id': response['data']['id'],
          'post_ids': response['data']['postIds'],
          'status': response['data']['status'],
        };
      } else {
        throw Exception(response['message'] ?? 'Failed to publish post');
      }
    } catch (e) {
      print('❌ Error publishing post: $e');
      rethrow;
    }
  }

  /// حذف منشور
  ///
  /// [postId] - معرف المنشور
  /// Returns: true إذا تم الحذف بنجاح
  Future<bool> deletePost(String postId) async {
    try {
      print('🔄 Deleting post $postId...');

      final response = await _httpService.delete('/api/ayrshare/post/$postId');

      if (response['success'] == true) {
        print('✅ Post deleted successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error deleting post: $e');
      return false;
    }
  }

  /// الحصول على إحصائيات الحسابات
  ///
  /// [platforms] - قائمة المنصات للحصول على إحصائياتها
  /// Returns: إحصائيات الحسابات
  Future<Map<String, dynamic>> getAnalytics({List<String>? platforms}) async {
    try {
      print('🔄 Fetching analytics...');

      final queryParams = platforms != null && platforms.isNotEmpty
          ? {'platforms': platforms.join(',')}
          : null;

      final response = await _httpService.get(
        '/api/ayrshare/analytics',
        queryParameters: queryParams,
      );

      if (response['success'] == true) {
        print('✅ Analytics fetched successfully');
        return response['data'];
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch analytics');
      }
    } catch (e) {
      print('❌ Error fetching analytics: $e');
      return {};
    }
  }

  /// الحصول على إحصائيات منشور معين
  ///
  /// [postId] - معرف المنشور
  /// Returns: إحصائيات المنشور
  Future<Map<String, dynamic>> getPostAnalytics(String postId) async {
    try {
      print('🔄 Fetching post analytics for $postId...');

      final response = await _httpService.get(
        '/api/ayrshare/analytics/post/$postId',
      );

      if (response['success'] == true) {
        print('✅ Post analytics fetched successfully');
        return response['data'];
      } else {
        throw Exception(
          response['message'] ?? 'Failed to fetch post analytics',
        );
      }
    } catch (e) {
      print('❌ Error fetching post analytics: $e');
      return {};
    }
  }

  /// الحصول على تاريخ المنشورات
  ///
  /// [platform] - المنصة (اختياري)
  /// [limit] - عدد المنشورات (افتراضي: 50)
  /// Returns: قائمة المنشورات
  Future<List<Map<String, dynamic>>> getPostHistory({
    String? platform,
    int limit = 50,
  }) async {
    try {
      print('🔄 Fetching post history...');

      final queryParams = {
        'limit': limit.toString(),
        if (platform != null) 'platform': platform,
      };

      final response = await _httpService.get(
        '/api/ayrshare/history',
        queryParameters: queryParams,
      );

      if (response['success'] == true) {
        final history = response['data']['history'] as List;
        print('✅ Found ${history.length} posts in history');
        return history.cast<Map<String, dynamic>>();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch history');
      }
    } catch (e) {
      print('❌ Error fetching post history: $e');
      return [];
    }
  }

  /// فصل حساب مرتبط
  ///
  /// [profileKey] - مفتاح الملف الشخصي
  /// Returns: true إذا تم الفصل بنجاح
  Future<bool> unlinkProfile(String profileKey) async {
    try {
      print('🔄 Unlinking profile $profileKey...');

      final response = await _httpService.delete(
        '/api/ayrshare/profile/$profileKey',
      );

      if (response['success'] == true) {
        print('✅ Profile unlinked successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error unlinking profile: $e');
      return false;
    }
  }

  /// تحديث منشور مجدول
  ///
  /// [postId] - معرف المنشور
  /// [text] - النص الجديد (اختياري)
  /// [scheduleDate] - الموعد الجديد (اختياري)
  /// Returns: true إذا تم التحديث بنجاح
  Future<bool> updateScheduledPost({
    required String postId,
    String? text,
    DateTime? scheduleDate,
  }) async {
    try {
      print('🔄 Updating scheduled post $postId...');

      final body = <String, dynamic>{};
      if (text != null) body['post'] = text;
      if (scheduleDate != null) {
        body['scheduleDate'] = scheduleDate.toIso8601String();
      }

      final response = await _httpService.put(
        '/api/ayrshare/post/$postId',
        body: body,
      );

      if (response['success'] == true) {
        print('✅ Post updated successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error updating post: $e');
      return false;
    }
  }

  /// رفع صورة/فيديو إلى Ayrshare
  ///
  /// [filePath] - مسار الملف المحلي
  /// Returns: رابط الملف المرفوع
  Future<String?> uploadMedia(String filePath) async {
    try {
      print('🔄 Uploading media file...');

      final response = await _httpService.post(
        '/api/ayrshare/upload',
        body: {'file_path': filePath},
      );

      if (response['success'] == true) {
        final url = response['data']['url'] as String;
        print('✅ Media uploaded successfully: $url');
        return url;
      }
      return null;
    } catch (e) {
      print('❌ Error uploading media: $e');
      return null;
    }
  }

  /// التحقق من حالة Ayrshare API
  ///
  /// Returns: true إذا كان API يعمل
  Future<bool> checkApiStatus() async {
    try {
      final response = await _httpService.get('/api/ayrshare/status');
      return response['success'] == true;
    } catch (e) {
      print('❌ Ayrshare API is down: $e');
      return false;
    }
  }

  /// الحصول على أفضل وقت للنشر على منصة
  ///
  /// [platform] - المنصة
  /// Returns: أفضل أوقات النشر
  Future<List<Map<String, dynamic>>> getBestTimesToPost(String platform) async {
    try {
      print('🔄 Fetching best times to post for $platform...');

      final response = await _httpService.get(
        '/api/ayrshare/best-times',
        queryParameters: {'platform': platform},
      );

      if (response['success'] == true) {
        final times = response['data']['times'] as List;
        print('✅ Found ${times.length} best times');
        return times.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('❌ Error fetching best times: $e');
      return [];
    }
  }
}
