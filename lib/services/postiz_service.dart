import 'http_service.dart';

/// خدمة Postiz للربط مع منصات التواصل الاجتماعي
/// Postiz هو بديل مفتوح المصدر يدعم OAuth الرسمي لجميع المنصات
class PostizService {
  static final PostizService _instance = PostizService._internal();
  factory PostizService() => _instance;
  PostizService._internal();

  final HttpService _httpService = HttpService();

  // Postiz API Configuration
  // TODO: Postiz integration credentials reserved for future implementation
  // String? _apiKey;
  // String? _baseUrl;

  // TODO: Service initialization reserved for future Postiz integration
  /*
  /// تهيئة الخدمة بـ API Key وBase URL
  void init({required String apiKey, required String baseUrl}) {
    _apiKey = apiKey;
    _baseUrl = baseUrl;
    print('✅ Postiz Service initialized');
  }
  */

  /// الحصول على قائمة القنوات/الحسابات المربوطة
  ///
  /// Returns: قائمة الحسابات المربوطة مع معلومات كل حساب
  Future<List<Map<String, dynamic>>> getConnectedIntegrations() async {
    try {
      print('🔄 Fetching connected integrations...');

      final response = await _httpService.get('/api/postiz/integrations');

      if (response['success'] == true) {
        final integrations = response['data']['integrations'] as List;
        print('✅ Found ${integrations.length} connected integrations');
        return integrations.cast<Map<String, dynamic>>();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch integrations');
      }
    } catch (e) {
      print('❌ Error fetching integrations: $e');
      return [];
    }
  }

  /// الحصول على رابط OAuth للربط بمنصة معينة
  ///
  /// [platform] - اسم المنصة (facebook, instagram, twitter, linkedin, etc.)
  /// Returns: رابط OAuth للربط
  Future<Map<String, dynamic>> generateOAuthLink({
    required String platform,
    required String userId,
  }) async {
    try {
      print('🔄 Generating OAuth link for $platform...');

      final response = await _httpService.post(
        '/api/postiz/oauth-link',
        body: {'platform': platform, 'user_id': userId},
      );

      if (response['success'] == true) {
        print('✅ OAuth link generated successfully');
        return {
          'success': true,
          'url': response['data']['url'],
          'state': response['data']['state'],
        };
      } else {
        throw Exception(response['message'] ?? 'Failed to generate OAuth link');
      }
    } catch (e) {
      print('❌ Error generating OAuth link: $e');
      rethrow;
    }
  }

  /// نشر محتوى على منصة أو أكثر
  ///
  /// [integrationIds] - قائمة معرفات القنوات للنشر عليها
  /// [text] - النص المراد نشره
  /// [mediaUrls] - روابط الصور/الفيديو (اختياري)
  /// [scheduleDate] - موعد النشر المجدول (اختياري)
  /// [platformSpecific] - إعدادات خاصة بكل منصة (اختياري)
  /// Returns: معلومات المنشور المنشور
  Future<Map<String, dynamic>> publishPost({
    required List<String> integrationIds,
    required String text,
    List<String>? mediaUrls,
    DateTime? scheduleDate,
    Map<String, dynamic>? platformSpecific,
  }) async {
    try {
      print('🔄 Publishing post to ${integrationIds.length} integrations...');

      final body = {
        'integration_ids': integrationIds,
        'content': [
          {
            'text': text,
            if (mediaUrls != null && mediaUrls.isNotEmpty)
              'media': mediaUrls.map((url) => {'url': url}).toList(),
          },
        ],
        if (scheduleDate != null)
          'schedule_date': scheduleDate.toIso8601String(),
        if (platformSpecific != null) 'settings': platformSpecific,
      };

      final response = await _httpService.post('/api/postiz/posts', body: body);

      if (response['success'] == true) {
        print('✅ Post published successfully');
        return {
          'success': true,
          'post_id': response['data']['id'],
          'post_ids': response['data']['postIds'],
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

      final response = await _httpService.delete('/api/postiz/posts/$postId');

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

  /// الحصول على قائمة المنشورات
  ///
  /// [startDate] - تاريخ البداية
  /// [endDate] - تاريخ النهاية
  /// Returns: قائمة المنشورات
  Future<List<Map<String, dynamic>>> getPosts({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('🔄 Fetching posts...');

      final queryParams = <String, String>{};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final response = await _httpService.get(
        '/api/postiz/posts',
        queryParameters: queryParams,
      );

      if (response['success'] == true) {
        final posts = response['data']['posts'] as List;
        print('✅ Found ${posts.length} posts');
        return posts.cast<Map<String, dynamic>>();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch posts');
      }
    } catch (e) {
      print('❌ Error fetching posts: $e');
      return [];
    }
  }

  /// رفع صورة/فيديو إلى Postiz
  ///
  /// [filePath] - مسار الملف المحلي
  /// Returns: رابط الملف المرفوع
  Future<String?> uploadMedia(String filePath) async {
    try {
      print('🔄 Uploading media file...');

      final response = await _httpService.post(
        '/api/postiz/upload',
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

  /// رفع صورة/فيديو من URL خارجي
  ///
  /// [url] - رابط الملف الخارجي
  /// Returns: رابط الملف المرفوع على Postiz
  Future<String?> uploadMediaFromUrl(String url) async {
    try {
      print('🔄 Uploading media from URL...');

      final response = await _httpService.post(
        '/api/postiz/upload-from-url',
        body: {'url': url},
      );

      if (response['success'] == true) {
        final uploadedUrl = response['data']['url'] as String;
        print('✅ Media uploaded from URL successfully: $uploadedUrl');
        return uploadedUrl;
      }
      return null;
    } catch (e) {
      print('❌ Error uploading media from URL: $e');
      return null;
    }
  }

  /// الحصول على أفضل وقت للنشر على قناة معينة
  ///
  /// [integrationId] - معرف القناة
  /// Returns: أفضل وقت للنشر
  Future<DateTime?> getNextAvailableSlot(String integrationId) async {
    try {
      print(
        '🔄 Fetching next available slot for integration $integrationId...',
      );

      final response = await _httpService.get(
        '/api/postiz/find-slot/$integrationId',
      );

      if (response['success'] == true) {
        final slotString = response['data']['slot'] as String;
        final slot = DateTime.parse(slotString);
        print('✅ Next available slot: $slot');
        return slot;
      }
      return null;
    } catch (e) {
      print('❌ Error fetching next slot: $e');
      return null;
    }
  }

  /// توليد فيديو بالذكاء الاصطناعي
  ///
  /// [prompt] - وصف الفيديو المطلوب
  /// [model] - نوع النموذج (image-text-slides أو veo3)
  /// Returns: رابط الفيديو المولد
  Future<Map<String, dynamic>> generateVideo({
    required String prompt,
    String model = 'image-text-slides',
    Map<String, dynamic>? options,
  }) async {
    try {
      print('🔄 Generating video with AI...');

      final body = {
        'prompt': prompt,
        'model': model,
        if (options != null) ...options,
      };

      final response = await _httpService.post(
        '/api/postiz/generate-video',
        body: body,
      );

      if (response['success'] == true) {
        print('✅ Video generated successfully');
        return {
          'success': true,
          'video_url': response['data']['video_url'],
          'id': response['data']['id'],
        };
      } else {
        throw Exception(response['message'] ?? 'Failed to generate video');
      }
    } catch (e) {
      print('❌ Error generating video: $e');
      rethrow;
    }
  }

  /// فصل حساب مرتبط (integration)
  ///
  /// [integrationId] - معرف القناة/الحساب
  /// Returns: true إذا تم الفصل بنجاح
  Future<bool> unlinkIntegration(String integrationId) async {
    try {
      print('🔄 Unlinking integration $integrationId...');

      final response = await _httpService.delete(
        '/api/postiz/integrations/$integrationId',
      );

      if (response['success'] == true) {
        print('✅ Integration unlinked successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error unlinking integration: $e');
      return false;
    }
  }

  /// التحقق من حالة Postiz API
  ///
  /// Returns: true إذا كان API يعمل
  Future<bool> checkApiStatus() async {
    try {
      final response = await _httpService.get('/api/postiz/status');
      return response['success'] == true;
    } catch (e) {
      print('❌ Postiz API is down: $e');
      return false;
    }
  }
}
