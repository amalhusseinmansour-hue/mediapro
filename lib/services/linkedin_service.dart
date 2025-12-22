import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/config/backend_config.dart';

/// LinkedIn Service - للنشر المباشر على LinkedIn
/// يدعم النشر عبر API أو المشاركة المباشرة عبر share_plus
class LinkedInService extends GetxService {
  static LinkedInService get to => Get.find<LinkedInService>();

  final String _baseUrl = BackendConfig.baseUrl;

  // LinkedIn URLs
  static const String _linkedInShareUrl = 'https://www.linkedin.com/sharing/share-offsite/';
  static const String _linkedInPostUrl = 'https://www.linkedin.com/feed/';

  /// Auth token (يُعيَّن من الخارج)
  String? _authToken;

  /// تعيين token المصادقة
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Headers for API requests
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // ========== Posting Methods ==========

  /// نشر منشور نصي على LinkedIn
  Future<LinkedInPostResult> postText(String content,
      {int? accountId}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/linkedin/post/text'),
        headers: _headers,
        body: jsonEncode({
          'content': content,
          if (accountId != null) 'account_id': accountId,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return LinkedInPostResult(
        success: false,
        error: 'خطأ في الاتصال: $e',
      );
    }
  }

  /// نشر منشور مع صورة على LinkedIn
  Future<LinkedInPostResult> postWithImage(
    String content,
    String imageUrl, {
    int? accountId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/linkedin/post/image'),
        headers: _headers,
        body: jsonEncode({
          'content': content,
          'image_url': imageUrl,
          if (accountId != null) 'account_id': accountId,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return LinkedInPostResult(
        success: false,
        error: 'خطأ في الاتصال: $e',
      );
    }
  }

  /// نشر منشور مع رابط على LinkedIn
  Future<LinkedInPostResult> postWithLink(
    String content,
    String linkUrl, {
    String? title,
    String? description,
    int? accountId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/linkedin/post/link'),
        headers: _headers,
        body: jsonEncode({
          'content': content,
          'link_url': linkUrl,
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (accountId != null) 'account_id': accountId,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return LinkedInPostResult(
        success: false,
        error: 'خطأ في الاتصال: $e',
      );
    }
  }

  /// نشر عام (يكتشف النوع تلقائياً)
  Future<LinkedInPostResult> post({
    required String content,
    String? imageUrl,
    String? linkUrl,
    String? title,
    String? description,
    int? accountId,
  }) async {
    try {
      final body = <String, dynamic>{
        'content': content,
        if (imageUrl != null) 'image_url': imageUrl,
        if (linkUrl != null) 'link_url': linkUrl,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (accountId != null) 'account_id': accountId,
      };

      // Determine type
      if (imageUrl != null) {
        body['type'] = 'image';
      } else if (linkUrl != null) {
        body['type'] = 'link';
      } else {
        body['type'] = 'text';
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/linkedin/post'),
        headers: _headers,
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      return LinkedInPostResult(
        success: false,
        error: 'خطأ في الاتصال: $e',
      );
    }
  }

  // ========== Account Management ==========

  /// التحقق من صلاحية حساب LinkedIn
  Future<LinkedInValidationResult> validateAccount({int? accountId}) async {
    try {
      final queryParams = accountId != null ? '?account_id=$accountId' : '';
      final response = await http.get(
        Uri.parse('$_baseUrl/linkedin/validate$queryParams'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      return LinkedInValidationResult(
        isValid: data['is_valid'] ?? false,
        account: data['account'] != null
            ? LinkedInAccount.fromJson(data['account'])
            : null,
        message: data['message'],
      );
    } catch (e) {
      return LinkedInValidationResult(
        isValid: false,
        message: 'خطأ في التحقق: $e',
      );
    }
  }

  /// حذف منشور من LinkedIn
  Future<LinkedInPostResult> deletePost(String postUrn,
      {int? accountId}) async {
    try {
      final queryParams = accountId != null ? '?account_id=$accountId' : '';
      final response = await http.delete(
        Uri.parse('$_baseUrl/linkedin/post/$postUrn$queryParams'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return LinkedInPostResult(
        success: false,
        error: 'خطأ في الحذف: $e',
      );
    }
  }

  // ========== Direct Share Methods (بدون API) ==========

  /// مشاركة مباشرة على LinkedIn عبر share_plus
  /// يفتح نافذة المشاركة الأصلية للجهاز
  Future<LinkedInPostResult> shareDirectly({
    required String content,
    String? url,
  }) async {
    try {
      final textToShare = url != null ? '$content\n\n$url' : content;

      await Share.share(
        textToShare,
        subject: 'مشاركة على LinkedIn',
      );

      return LinkedInPostResult(
        success: true,
        message: 'تم فتح نافذة المشاركة',
      );
    } catch (e) {
      return LinkedInPostResult(
        success: false,
        error: 'خطأ في المشاركة: $e',
      );
    }
  }

  /// فتح LinkedIn مباشرة للنشر (عبر الرابط)
  /// يفتح صفحة LinkedIn للمشاركة مع النص المحدد
  Future<LinkedInPostResult> openLinkedInShare({
    required String content,
    String? url,
  }) async {
    try {
      // LinkedIn share URL with parameters
      final encodedUrl = url != null ? Uri.encodeComponent(url) : '';
      final shareUrl = Uri.parse(
        '$_linkedInShareUrl?url=$encodedUrl',
      );

      if (await canLaunchUrl(shareUrl)) {
        await launchUrl(shareUrl, mode: LaunchMode.externalApplication);

        // Copy content to clipboard for easy paste
        // await Clipboard.setData(ClipboardData(text: content));

        return LinkedInPostResult(
          success: true,
          message: 'تم فتح LinkedIn للمشاركة',
        );
      } else {
        // Fallback: open LinkedIn feed
        final feedUrl = Uri.parse(_linkedInPostUrl);
        if (await canLaunchUrl(feedUrl)) {
          await launchUrl(feedUrl, mode: LaunchMode.externalApplication);
          return LinkedInPostResult(
            success: true,
            message: 'تم فتح LinkedIn',
          );
        }

        return LinkedInPostResult(
          success: false,
          error: 'لا يمكن فتح LinkedIn',
        );
      }
    } catch (e) {
      return LinkedInPostResult(
        success: false,
        error: 'خطأ في فتح LinkedIn: $e',
      );
    }
  }

  /// فتح تطبيق LinkedIn مباشرة
  Future<LinkedInPostResult> openLinkedInApp() async {
    try {
      // Try LinkedIn app scheme
      final linkedInAppUri = Uri.parse('linkedin://');

      if (await canLaunchUrl(linkedInAppUri)) {
        await launchUrl(linkedInAppUri);
        return LinkedInPostResult(
          success: true,
          message: 'تم فتح تطبيق LinkedIn',
        );
      } else {
        // Fallback to web
        final webUri = Uri.parse('https://www.linkedin.com/feed/');
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        return LinkedInPostResult(
          success: true,
          message: 'تم فتح LinkedIn في المتصفح',
        );
      }
    } catch (e) {
      return LinkedInPostResult(
        success: false,
        error: 'خطأ في فتح LinkedIn: $e',
      );
    }
  }

  /// مشاركة مع رابط على LinkedIn
  Future<LinkedInPostResult> shareWithLink({
    required String content,
    required String linkUrl,
    String? title,
  }) async {
    try {
      final encodedUrl = Uri.encodeComponent(linkUrl);
      final encodedTitle = title != null ? Uri.encodeComponent(title) : '';
      final encodedContent = Uri.encodeComponent(content);

      // LinkedIn share URL
      final shareUrl = Uri.parse(
        'https://www.linkedin.com/shareArticle?mini=true&url=$encodedUrl&title=$encodedTitle&summary=$encodedContent',
      );

      if (await canLaunchUrl(shareUrl)) {
        await launchUrl(shareUrl, mode: LaunchMode.externalApplication);
        return LinkedInPostResult(
          success: true,
          message: 'تم فتح LinkedIn لمشاركة الرابط',
        );
      }

      return LinkedInPostResult(
        success: false,
        error: 'لا يمكن فتح رابط المشاركة',
      );
    } catch (e) {
      return LinkedInPostResult(
        success: false,
        error: 'خطأ في المشاركة: $e',
      );
    }
  }

  /// الطريقة الموصى بها للنشر - تجرب API أولاً ثم المشاركة المباشرة
  Future<LinkedInPostResult> smartPost({
    required String content,
    String? imageUrl,
    String? linkUrl,
    String? title,
    bool preferDirectShare = true,
  }) async {
    // إذا كان المستخدم يفضل المشاركة المباشرة
    if (preferDirectShare) {
      if (linkUrl != null) {
        return shareWithLink(content: content, linkUrl: linkUrl, title: title);
      }
      return shareDirectly(content: content);
    }

    // جرب API أولاً
    final apiResult = await post(
      content: content,
      imageUrl: imageUrl,
      linkUrl: linkUrl,
      title: title,
    );

    // إذا فشل API، استخدم المشاركة المباشرة
    if (!apiResult.success) {
      if (linkUrl != null) {
        return shareWithLink(content: content, linkUrl: linkUrl, title: title);
      }
      return shareDirectly(content: content);
    }

    return apiResult;
  }

  // ========== Analytics Methods ==========

  /// الحصول على لوحة تحليلات كاملة
  Future<LinkedInAnalyticsResult> getAnalyticsDashboard({int? accountId}) async {
    try {
      final queryParams = accountId != null ? '?account_id=$accountId' : '';
      final response = await http.get(
        Uri.parse('$_baseUrl/linkedin/analytics/dashboard$queryParams'),
        headers: _headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return LinkedInAnalyticsResult(
          success: true,
          dashboard: LinkedInAnalyticsDashboard.fromJson(data),
        );
      }

      return LinkedInAnalyticsResult(
        success: false,
        error: 'فشل في جلب التحليلات',
      );
    } catch (e) {
      return LinkedInAnalyticsResult(
        success: false,
        error: 'خطأ في الاتصال: $e',
      );
    }
  }

  /// الحصول على إحصائيات الملف الشخصي
  Future<LinkedInAnalyticsResult> getProfileStats({int? accountId}) async {
    try {
      final queryParams = accountId != null ? '?account_id=$accountId' : '';
      final response = await http.get(
        Uri.parse('$_baseUrl/linkedin/analytics/profile$queryParams'),
        headers: _headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return LinkedInAnalyticsResult(
          success: true,
          profile: data['profile'] != null
              ? LinkedInProfile.fromJson(data['profile'])
              : null,
          network: data['network'] != null
              ? LinkedInNetwork.fromJson(data['network'])
              : null,
        );
      }

      return LinkedInAnalyticsResult(
        success: false,
        error: 'فشل في جلب إحصائيات الملف الشخصي',
      );
    } catch (e) {
      return LinkedInAnalyticsResult(
        success: false,
        error: 'خطأ في الاتصال: $e',
      );
    }
  }

  /// الحصول على تحليلات المنشورات
  Future<LinkedInAnalyticsResult> getPostsAnalytics({
    int? accountId,
    int count = 10,
  }) async {
    try {
      var queryParams = 'count=$count';
      if (accountId != null) queryParams += '&account_id=$accountId';

      final response = await http.get(
        Uri.parse('$_baseUrl/linkedin/analytics/posts?$queryParams'),
        headers: _headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final posts = (data['posts'] as List?)
                ?.map((p) => LinkedInPostAnalytics.fromJson(p))
                .toList() ??
            [];
        return LinkedInAnalyticsResult(
          success: true,
          posts: posts,
        );
      }

      return LinkedInAnalyticsResult(
        success: false,
        error: 'فشل في جلب تحليلات المنشورات',
      );
    } catch (e) {
      return LinkedInAnalyticsResult(
        success: false,
        error: 'خطأ في الاتصال: $e',
      );
    }
  }

  /// الحصول على ملخص التفاعل
  Future<LinkedInAnalyticsResult> getEngagementSummary({
    int? accountId,
    int postsCount = 20,
  }) async {
    try {
      var queryParams = 'posts_count=$postsCount';
      if (accountId != null) queryParams += '&account_id=$accountId';

      final response = await http.get(
        Uri.parse('$_baseUrl/linkedin/analytics/engagement?$queryParams'),
        headers: _headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return LinkedInAnalyticsResult(
          success: true,
          engagementSummary: data['summary'] != null
              ? LinkedInEngagementSummary.fromJson(data['summary'])
              : null,
        );
      }

      return LinkedInAnalyticsResult(
        success: false,
        error: 'فشل في جلب ملخص التفاعل',
      );
    } catch (e) {
      return LinkedInAnalyticsResult(
        success: false,
        error: 'خطأ في الاتصال: $e',
      );
    }
  }

  /// الحصول على إحصائيات المتابعين
  Future<LinkedInAnalyticsResult> getFollowerStats({
    int? accountId,
    String timeRange = 'month',
  }) async {
    try {
      var queryParams = 'time_range=$timeRange';
      if (accountId != null) queryParams += '&account_id=$accountId';

      final response = await http.get(
        Uri.parse('$_baseUrl/linkedin/analytics/followers?$queryParams'),
        headers: _headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return LinkedInAnalyticsResult(
          success: true,
          followerStats: LinkedInFollowerStats.fromJson(data),
        );
      }

      return LinkedInAnalyticsResult(
        success: false,
        error: 'فشل في جلب إحصائيات المتابعين',
      );
    } catch (e) {
      return LinkedInAnalyticsResult(
        success: false,
        error: 'خطأ في الاتصال: $e',
      );
    }
  }

  // ========== Helper Methods ==========

  LinkedInPostResult _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return LinkedInPostResult(
          success: data['success'] ?? true,
          postId: data['post_id'],
          message: data['message'] ?? 'تم النشر بنجاح',
        );
      } else {
        return LinkedInPostResult(
          success: false,
          error: data['error'] ?? data['message'] ?? 'فشل في النشر',
          errorDetails: data['error_details'],
        );
      }
    } catch (e) {
      return LinkedInPostResult(
        success: false,
        error: 'خطأ في معالجة الاستجابة: $e',
      );
    }
  }
}

// ========== Models ==========

class LinkedInPostResult {
  final bool success;
  final String? postId;
  final String? message;
  final String? error;
  final Map<String, dynamic>? errorDetails;

  LinkedInPostResult({
    required this.success,
    this.postId,
    this.message,
    this.error,
    this.errorDetails,
  });
}

class LinkedInValidationResult {
  final bool isValid;
  final LinkedInAccount? account;
  final String? message;

  LinkedInValidationResult({
    required this.isValid,
    this.account,
    this.message,
  });
}

class LinkedInAnalyticsResult {
  final bool success;
  final String? error;
  final LinkedInAnalyticsDashboard? dashboard;
  final LinkedInProfile? profile;
  final LinkedInNetwork? network;
  final LinkedInEngagementSummary? engagementSummary;
  final LinkedInFollowerStats? followerStats;
  final List<LinkedInPostAnalytics>? posts;

  LinkedInAnalyticsResult({
    required this.success,
    this.error,
    this.dashboard,
    this.profile,
    this.network,
    this.engagementSummary,
    this.followerStats,
    this.posts,
  });
}

class LinkedInAccount {
  final int id;
  final String? username;
  final String? displayName;
  final bool isActive;

  LinkedInAccount({
    required this.id,
    this.username,
    this.displayName,
    required this.isActive,
  });

  factory LinkedInAccount.fromJson(Map<String, dynamic> json) {
    return LinkedInAccount(
      id: json['id'],
      username: json['username'],
      displayName: json['display_name'],
      isActive: json['is_active'] ?? false,
    );
  }
}

// ========== Analytics Models ==========

class LinkedInAnalyticsDashboard {
  final LinkedInProfile? profile;
  final LinkedInNetwork? network;
  final LinkedInEngagementSummary? engagementSummary;
  final LinkedInFollowerStats? followerStats;
  final List<LinkedInPostAnalytics> recentPosts;
  final String? updatedAt;

  LinkedInAnalyticsDashboard({
    this.profile,
    this.network,
    this.engagementSummary,
    this.followerStats,
    this.recentPosts = const [],
    this.updatedAt,
  });

  factory LinkedInAnalyticsDashboard.fromJson(Map<String, dynamic> json) {
    final dashboard = json['dashboard'] ?? json;
    return LinkedInAnalyticsDashboard(
      profile: dashboard['profile'] != null
          ? LinkedInProfile.fromJson(dashboard['profile'])
          : null,
      network: dashboard['network'] != null
          ? LinkedInNetwork.fromJson(dashboard['network'])
          : null,
      engagementSummary: dashboard['engagement_summary'] != null
          ? LinkedInEngagementSummary.fromJson(dashboard['engagement_summary'])
          : null,
      followerStats: dashboard['follower_stats'] != null
          ? LinkedInFollowerStats.fromJson(dashboard['follower_stats'])
          : null,
      recentPosts: (dashboard['recent_posts'] as List?)
              ?.map((p) => LinkedInPostAnalytics.fromJson(p))
              .toList() ??
          [],
      updatedAt: json['updated_at'],
    );
  }
}

class LinkedInProfile {
  final String? id;
  final String? name;
  final String? email;
  final String? picture;
  final String? vanityName;

  LinkedInProfile({
    this.id,
    this.name,
    this.email,
    this.picture,
    this.vanityName,
  });

  factory LinkedInProfile.fromJson(Map<String, dynamic> json) {
    return LinkedInProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      picture: json['picture'],
      vanityName: json['vanity_name'],
    );
  }
}

class LinkedInNetwork {
  final int connections;
  final int followers;

  LinkedInNetwork({
    this.connections = 0,
    this.followers = 0,
  });

  factory LinkedInNetwork.fromJson(Map<String, dynamic> json) {
    return LinkedInNetwork(
      connections: json['connections'] ?? 0,
      followers: json['followers'] ?? 0,
    );
  }
}

class LinkedInEngagementSummary {
  final int totalPosts;
  final int totalLikes;
  final int totalComments;
  final int totalShares;
  final int totalImpressions;
  final int totalClicks;
  final int totalEngagement;
  final double engagementRate;
  final double avgLikesPerPost;
  final double avgCommentsPerPost;
  final double avgSharesPerPost;

  LinkedInEngagementSummary({
    this.totalPosts = 0,
    this.totalLikes = 0,
    this.totalComments = 0,
    this.totalShares = 0,
    this.totalImpressions = 0,
    this.totalClicks = 0,
    this.totalEngagement = 0,
    this.engagementRate = 0,
    this.avgLikesPerPost = 0,
    this.avgCommentsPerPost = 0,
    this.avgSharesPerPost = 0,
  });

  factory LinkedInEngagementSummary.fromJson(Map<String, dynamic> json) {
    return LinkedInEngagementSummary(
      totalPosts: json['total_posts'] ?? 0,
      totalLikes: json['total_likes'] ?? 0,
      totalComments: json['total_comments'] ?? 0,
      totalShares: json['total_shares'] ?? 0,
      totalImpressions: json['total_impressions'] ?? 0,
      totalClicks: json['total_clicks'] ?? 0,
      totalEngagement: json['total_engagement'] ?? 0,
      engagementRate: (json['engagement_rate'] ?? 0).toDouble(),
      avgLikesPerPost: (json['avg_likes_per_post'] ?? 0).toDouble(),
      avgCommentsPerPost: (json['avg_comments_per_post'] ?? 0).toDouble(),
      avgSharesPerPost: (json['avg_shares_per_post'] ?? 0).toDouble(),
    );
  }
}

class LinkedInFollowerStats {
  final int currentFollowers;
  final String timeRange;
  final String? startDate;
  final String? endDate;

  LinkedInFollowerStats({
    this.currentFollowers = 0,
    this.timeRange = 'month',
    this.startDate,
    this.endDate,
  });

  factory LinkedInFollowerStats.fromJson(Map<String, dynamic> json) {
    return LinkedInFollowerStats(
      currentFollowers: json['current_followers'] ?? 0,
      timeRange: json['time_range'] ?? 'month',
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }
}

class LinkedInPostAnalytics {
  final Map<String, dynamic>? post;
  final int likes;
  final int comments;
  final int shares;
  final int impressions;
  final int clicks;
  final double engagement;

  LinkedInPostAnalytics({
    this.post,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.impressions = 0,
    this.clicks = 0,
    this.engagement = 0,
  });

  factory LinkedInPostAnalytics.fromJson(Map<String, dynamic> json) {
    final analytics = json['analytics'] ?? {};
    return LinkedInPostAnalytics(
      post: json['post'],
      likes: analytics['likes'] ?? 0,
      comments: analytics['comments'] ?? 0,
      shares: analytics['shares'] ?? 0,
      impressions: analytics['impressions'] ?? 0,
      clicks: analytics['clicks'] ?? 0,
      engagement: (analytics['engagement'] ?? 0).toDouble(),
    );
  }
}
