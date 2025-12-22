import 'http_service.dart';

/// Postiz Manager - إدارة شاملة لجميع وظائف Postiz
/// يتضمن: ربط الحسابات، النشر، الجدولة، التحليلات
class PostizManager {
  static final PostizManager _instance = PostizManager._internal();
  factory PostizManager() => _instance;
  PostizManager._internal();

  final HttpService _httpService = HttpService();

  // ==================== ربط حسابات Social Media ====================

  /// الحصول على رابط OAuth لربط منصة معينة
  /// يفتح المستخدم الرابط ويوافق على الربط
  Future<Map<String, dynamic>> connectSocialAccount({
    required String platform,
    required String userId,
  }) async {
    try {
      print('🔗 Connecting $platform for user $userId...');

      final response = await _httpService.post(
        '/api/postiz/oauth-link',
        body: {'platform': platform, 'user_id': userId},
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'oauth_url': response['data']['url'],
          'state': response['data']['state'],
        };
      } else {
        throw Exception(response['message'] ?? 'Failed to generate OAuth link');
      }
    } catch (e) {
      print('❌ Error connecting account: $e');
      rethrow;
    }
  }

  /// الحصول على جميع الحسابات المربوطة للمستخدم الحالي
  Future<List<SocialAccount>> getConnectedAccounts() async {
    try {
      print('📱 Fetching connected accounts...');

      final response = await _httpService.get('/api/postiz/integrations');

      if (response['success'] == true) {
        final List<dynamic> integrations = response['data']['integrations'];

        return integrations
            .map((data) => SocialAccount.fromJson(data))
            .toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch accounts');
      }
    } catch (e) {
      print('❌ Error fetching accounts: $e');
      return [];
    }
  }

  /// فصل حساب معين
  Future<bool> disconnectAccount(String integrationId) async {
    try {
      print('🔌 Disconnecting account $integrationId...');

      final response = await _httpService.delete(
        '/api/postiz/integrations/$integrationId',
      );

      return response['success'] == true;
    } catch (e) {
      print('❌ Error disconnecting account: $e');
      return false;
    }
  }

  // ==================== النشر والجدولة ====================

  /// نشر منشور فوري أو مجدول على منصات متعددة
  Future<PostResult> publishPost({
    required List<String> integrationIds,
    required String content,
    List<String>? mediaUrls,
    DateTime? scheduleDate,
    Map<String, dynamic>? platformSettings,
  }) async {
    try {
      print('📤 Publishing post to ${integrationIds.length} accounts...');

      final body = {
        'integration_ids': integrationIds,
        'content': [
          {
            'text': content,
            if (mediaUrls != null && mediaUrls.isNotEmpty)
              'media': mediaUrls.map((url) => {'url': url}).toList(),
          },
        ],
        if (scheduleDate != null)
          'schedule_date': scheduleDate.toIso8601String(),
        if (platformSettings != null) 'settings': platformSettings,
      };

      final response = await _httpService.post('/api/postiz/posts', body: body);

      if (response['success'] == true) {
        return PostResult.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to publish post');
      }
    } catch (e) {
      print('❌ Error publishing post: $e');
      rethrow;
    }
  }

  /// الحصول على جميع المنشورات (المنشورة والمجدولة)
  Future<List<Post>> getPosts({
    DateTime? startDate,
    DateTime? endDate,
    PostStatus? status,
  }) async {
    try {
      print('📋 Fetching posts...');

      final queryParams = <String, String>{};
      if (startDate != null)
        queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (status != null) queryParams['status'] = status.name;

      final response = await _httpService.get(
        '/api/postiz/posts',
        queryParameters: queryParams,
      );

      if (response['success'] == true) {
        final List<dynamic> posts = response['data']['posts'];
        return posts.map((data) => Post.fromJson(data)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch posts');
      }
    } catch (e) {
      print('❌ Error fetching posts: $e');
      return [];
    }
  }

  /// تحديث منشور مجدول
  Future<bool> updateScheduledPost({
    required String postId,
    String? newContent,
    DateTime? newScheduleDate,
    List<String>? newMediaUrls,
  }) async {
    try {
      print('✏️ Updating scheduled post $postId...');

      final body = <String, dynamic>{};
      if (newContent != null) {
        body['content'] = [
          {
            'text': newContent,
            if (newMediaUrls != null)
              'media': newMediaUrls.map((url) => {'url': url}).toList(),
          },
        ];
      }
      if (newScheduleDate != null) {
        body['schedule_date'] = newScheduleDate.toIso8601String();
      }

      final response = await _httpService.put(
        '/api/postiz/posts/$postId',
        body: body,
      );

      return response['success'] == true;
    } catch (e) {
      print('❌ Error updating post: $e');
      return false;
    }
  }

  /// حذف منشور
  Future<bool> deletePost(String postId) async {
    try {
      print('🗑️ Deleting post $postId...');

      final response = await _httpService.delete('/api/postiz/posts/$postId');
      return response['success'] == true;
    } catch (e) {
      print('❌ Error deleting post: $e');
      return false;
    }
  }

  // ==================== التحليلات والإحصائيات ====================

  /// الحصول على إحصائيات شاملة لجميع الحسابات
  Future<AnalyticsSummary> getAnalyticsSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('📊 Fetching analytics summary...');

      final queryParams = <String, String>{};
      if (startDate != null)
        queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _httpService.get(
        '/api/postiz/analytics/summary',
        queryParameters: queryParams,
      );

      if (response['success'] == true) {
        return AnalyticsSummary.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch analytics');
      }
    } catch (e) {
      print('❌ Error fetching analytics: $e');
      rethrow;
    }
  }

  /// الحصول على تحليلات منشور معين
  Future<PostAnalytics> getPostAnalytics(String postId) async {
    try {
      print('📈 Fetching analytics for post $postId...');

      final response = await _httpService.get(
        '/api/postiz/analytics/post/$postId',
      );

      if (response['success'] == true) {
        return PostAnalytics.fromJson(response['data']);
      } else {
        throw Exception(
          response['message'] ?? 'Failed to fetch post analytics',
        );
      }
    } catch (e) {
      print('❌ Error fetching post analytics: $e');
      rethrow;
    }
  }

  /// الحصول على تحليلات حساب معين
  Future<AccountAnalytics> getAccountAnalytics({
    required String integrationId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('📊 Fetching analytics for account $integrationId...');

      final queryParams = <String, String>{};
      if (startDate != null)
        queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _httpService.get(
        '/api/postiz/analytics/account/$integrationId',
        queryParameters: queryParams,
      );

      if (response['success'] == true) {
        return AccountAnalytics.fromJson(response['data']);
      } else {
        throw Exception(
          response['message'] ?? 'Failed to fetch account analytics',
        );
      }
    } catch (e) {
      print('❌ Error fetching account analytics: $e');
      rethrow;
    }
  }

  // ==================== رفع الوسائط ====================

  /// رفع صورة أو فيديو
  Future<String?> uploadMedia(String filePath) async {
    try {
      print('📤 Uploading media...');

      final response = await _httpService.post(
        '/api/postiz/upload',
        body: {'file_path': filePath},
      );

      if (response['success'] == true) {
        return response['data']['url'] as String;
      }
      return null;
    } catch (e) {
      print('❌ Error uploading media: $e');
      return null;
    }
  }

  /// رفع من URL خارجي
  Future<String?> uploadMediaFromUrl(String url) async {
    try {
      print('📥 Uploading media from URL...');

      final response = await _httpService.post(
        '/api/postiz/upload-from-url',
        body: {'url': url},
      );

      if (response['success'] == true) {
        return response['data']['url'] as String;
      }
      return null;
    } catch (e) {
      print('❌ Error uploading from URL: $e');
      return null;
    }
  }

  // ==================== أفضل أوقات النشر ====================

  /// الحصول على أفضل وقت للنشر لحساب معين
  Future<DateTime?> getBestTimeToPost(String integrationId) async {
    try {
      print('⏰ Getting best time to post...');

      final response = await _httpService.get(
        '/api/postiz/find-slot/$integrationId',
      );

      if (response['success'] == true) {
        final slotString = response['data']['slot'] as String;
        return DateTime.parse(slotString);
      }
      return null;
    } catch (e) {
      print('❌ Error getting best time: $e');
      return null;
    }
  }

  // ==================== توليد محتوى بالذكاء الاصطناعي ====================

  /// توليد فيديو بالذكاء الاصطناعي
  Future<String?> generateAIVideo({
    required String prompt,
    String model = 'image-text-slides',
  }) async {
    try {
      print('🎬 Generating AI video...');

      final response = await _httpService.post(
        '/api/postiz/generate-video',
        body: {'prompt': prompt, 'model': model},
      );

      if (response['success'] == true) {
        return response['data']['video_url'] as String;
      }
      return null;
    } catch (e) {
      print('❌ Error generating video: $e');
      return null;
    }
  }
}

// ==================== Data Models ====================

enum PostStatus { draft, scheduled, published, failed }

enum SocialPlatform {
  facebook,
  instagram,
  twitter,
  linkedin,
  tiktok,
  youtube,
  reddit,
  pinterest,
  threads,
  discord,
  slack,
  mastodon,
  bluesky,
}

class SocialAccount {
  final String id;
  final String integrationId;
  final SocialPlatform platform;
  final String name;
  final String username;
  final String? profilePicture;
  final bool isActive;
  final DateTime connectedAt;

  SocialAccount({
    required this.id,
    required this.integrationId,
    required this.platform,
    required this.name,
    required this.username,
    this.profilePicture,
    required this.isActive,
    required this.connectedAt,
  });

  factory SocialAccount.fromJson(Map<String, dynamic> json) {
    return SocialAccount(
      id: json['id']?.toString() ?? '',
      integrationId:
          json['integration_id']?.toString() ?? json['id']?.toString() ?? '',
      platform: _parsePlatform(json['provider'] ?? json['platform']),
      name: json['name'] ?? '',
      username: json['username'] ?? json['profile']?['username'] ?? '',
      profilePicture: json['profile_picture'] ?? json['picture'],
      isActive: json['is_active'] ?? json['disabled'] != true,
      connectedAt: DateTime.parse(
        json['connected_at'] ??
            json['created_at'] ??
            DateTime.now().toIso8601String(),
      ),
    );
  }

  static SocialPlatform _parsePlatform(String? platform) {
    if (platform == null) return SocialPlatform.facebook;

    switch (platform.toLowerCase()) {
      case 'facebook':
        return SocialPlatform.facebook;
      case 'instagram':
        return SocialPlatform.instagram;
      case 'twitter':
      case 'x':
        return SocialPlatform.twitter;
      case 'linkedin':
        return SocialPlatform.linkedin;
      case 'tiktok':
        return SocialPlatform.tiktok;
      case 'youtube':
        return SocialPlatform.youtube;
      case 'reddit':
        return SocialPlatform.reddit;
      case 'pinterest':
        return SocialPlatform.pinterest;
      case 'threads':
        return SocialPlatform.threads;
      case 'discord':
        return SocialPlatform.discord;
      case 'slack':
        return SocialPlatform.slack;
      case 'mastodon':
        return SocialPlatform.mastodon;
      case 'bluesky':
        return SocialPlatform.bluesky;
      default:
        return SocialPlatform.facebook;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'integration_id': integrationId,
      'platform': platform.name,
      'name': name,
      'username': username,
      'profile_picture': profilePicture,
      'is_active': isActive,
      'connected_at': connectedAt.toIso8601String(),
    };
  }
}

class Post {
  final String id;
  final String content;
  final List<String> mediaUrls;
  final PostStatus status;
  final DateTime? scheduledAt;
  final DateTime? publishedAt;
  final List<String> integrationIds;
  final Map<String, dynamic>? analytics;

  Post({
    required this.id,
    required this.content,
    required this.mediaUrls,
    required this.status,
    this.scheduledAt,
    this.publishedAt,
    required this.integrationIds,
    this.analytics,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    PostStatus status = PostStatus.published;
    if (json['status'] != null) {
      switch (json['status'].toString().toLowerCase()) {
        case 'draft':
          status = PostStatus.draft;
          break;
        case 'scheduled':
          status = PostStatus.scheduled;
          break;
        case 'published':
          status = PostStatus.published;
          break;
        case 'failed':
          status = PostStatus.failed;
          break;
      }
    }

    return Post(
      id: json['id']?.toString() ?? '',
      content: json['content']?[0]?['text'] ?? json['text'] ?? '',
      mediaUrls: _parseMediaUrls(
        json['content']?[0]?['media'] ?? json['media'],
      ),
      status: status,
      scheduledAt: json['schedule_date'] != null
          ? DateTime.parse(json['schedule_date'])
          : null,
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'])
          : null,
      integrationIds: _parseIntegrationIds(
        json['integrations'] ?? json['integration_ids'],
      ),
      analytics: json['analytics'],
    );
  }

  static List<String> _parseMediaUrls(dynamic media) {
    if (media == null) return [];
    if (media is List) {
      return media
          .map((m) => m['url']?.toString() ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
    }
    return [];
  }

  static List<String> _parseIntegrationIds(dynamic integrations) {
    if (integrations == null) return [];
    if (integrations is List) {
      return integrations.map((i) => i.toString()).toList();
    }
    return [];
  }
}

class PostResult {
  final String postId;
  final List<String> platformPostIds;
  final bool success;

  PostResult({
    required this.postId,
    required this.platformPostIds,
    required this.success,
  });

  factory PostResult.fromJson(Map<String, dynamic> json) {
    return PostResult(
      postId: json['id']?.toString() ?? '',
      platformPostIds:
          (json['postIds'] as List<dynamic>?)
              ?.map((id) => id.toString())
              .toList() ??
          [],
      success: true,
    );
  }
}

class AnalyticsSummary {
  final int totalPosts;
  final int totalReach;
  final int totalEngagement;
  final int totalFollowers;
  final double engagementRate;

  AnalyticsSummary({
    required this.totalPosts,
    required this.totalReach,
    required this.totalEngagement,
    required this.totalFollowers,
    required this.engagementRate,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      totalPosts: json['total_posts'] ?? 0,
      totalReach: json['total_reach'] ?? 0,
      totalEngagement: json['total_engagement'] ?? 0,
      totalFollowers: json['total_followers'] ?? 0,
      engagementRate: (json['engagement_rate'] ?? 0.0).toDouble(),
    );
  }
}

class PostAnalytics {
  final String postId;
  final int likes;
  final int comments;
  final int shares;
  final int views;
  final int reach;
  final double engagementRate;

  PostAnalytics({
    required this.postId,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.views,
    required this.reach,
    required this.engagementRate,
  });

  factory PostAnalytics.fromJson(Map<String, dynamic> json) {
    return PostAnalytics(
      postId: json['post_id']?.toString() ?? '',
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      views: json['views'] ?? 0,
      reach: json['reach'] ?? 0,
      engagementRate: (json['engagement_rate'] ?? 0.0).toDouble(),
    );
  }
}

class AccountAnalytics {
  final String integrationId;
  final int followers;
  final int totalPosts;
  final int totalReach;
  final int totalEngagement;
  final double averageEngagementRate;
  final Map<String, int> postsPerDay;

  AccountAnalytics({
    required this.integrationId,
    required this.followers,
    required this.totalPosts,
    required this.totalReach,
    required this.totalEngagement,
    required this.averageEngagementRate,
    required this.postsPerDay,
  });

  factory AccountAnalytics.fromJson(Map<String, dynamic> json) {
    return AccountAnalytics(
      integrationId: json['integration_id']?.toString() ?? '',
      followers: json['followers'] ?? 0,
      totalPosts: json['total_posts'] ?? 0,
      totalReach: json['total_reach'] ?? 0,
      totalEngagement: json['total_engagement'] ?? 0,
      averageEngagementRate: (json['average_engagement_rate'] ?? 0.0)
          .toDouble(),
      postsPerDay: Map<String, int>.from(json['posts_per_day'] ?? {}),
    );
  }
}
