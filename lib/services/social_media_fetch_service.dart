import 'package:get/get.dart';
import '../models/post_model.dart';
import 'api_service.dart';

/// خدمة جلب البوستات من منصات التواصل الاجتماعي
class SocialMediaFetchService {
  // يمكن استخدام APIs رسمية أو خدمات third-party
  ApiService? _apiService;

  ApiService get apiService {
    _apiService ??= Get.find<ApiService>();
    return _apiService!;
  }

  /// جلب البوستات من جميع المنصات المتصلة
  Future<List<PostModel>> fetchAllPosts() async {
    try {
      // أولاً: جلب البوستات من Backend API
      final backendPosts = await _fetchPostsFromBackend();
      if (backendPosts.isNotEmpty) {
        return backendPosts;
      }

      // Fallback: جلب من المنصات مباشرة
      final facebookPosts = await fetchFacebookPosts();
      final instagramPosts = await fetchInstagramPosts();
      final twitterPosts = await fetchTwitterPosts();
      final tiktokPosts = await fetchTikTokPosts();

      final allPosts = [
        ...facebookPosts,
        ...instagramPosts,
        ...twitterPosts,
        ...tiktokPosts,
      ];

      // لا نعرض بيانات وهمية - نعرض قائمة فارغة إذا لم تكن هناك بيانات حقيقية
      if (allPosts.isEmpty) {
        return [];
      }

      return allPosts..sort((a, b) => (b.publishedAt ?? b.createdAt).compareTo(a.publishedAt ?? a.createdAt));
    } catch (e) {
      print('خطأ في جلب البوستات: $e');
      return []; // عرض قائمة فارغة بدلاً من البيانات الوهمية
    }
  }

  /// جلب البوستات من Backend API
  Future<List<PostModel>> _fetchPostsFromBackend() async {
    try {
      final response = await apiService.getPostHistory();
      if (response['success'] == true) {
        final postsData = response['data'] as List? ?? [];
        final List<PostModel> posts = [];
        for (var postData in postsData) {
          final scheduledTime = postData['scheduled_at'] != null
              ? DateTime.parse(postData['scheduled_at'])
              : null;
          posts.add(PostModel(
            id: postData['id']?.toString() ?? '',
            content: postData['content'] ?? '',
            platforms: (postData['platforms'] as List?)?.map((e) => e.toString()).toList() ?? [],
            createdAt: postData['created_at'] != null
                ? DateTime.parse(postData['created_at'])
                : DateTime.now(),
            publishedAt: postData['published_at'] != null
                ? DateTime.parse(postData['published_at'])
                : null,
            isScheduled: scheduledTime != null,
            scheduledTime: scheduledTime,
            status: _parsePostStatus(postData['status']),
            analytics: {
              'likes': postData['likes'] ?? 0,
              'comments': postData['comments'] ?? 0,
              'shares': postData['shares'] ?? 0,
              'views': postData['views'] ?? 0,
            },
            imageUrls: (postData['media_urls'] as List?)?.map((e) => e.toString()).toList() ?? [],
          ));
        }
        return posts;
      }
      return [];
    } catch (e) {
      print('خطأ في جلب البوستات من Backend: $e');
      return [];
    }
  }

  /// تحويل حالة البوست من String إلى PostStatus
  PostStatus _parsePostStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'published':
        return PostStatus.published;
      case 'scheduled':
        return PostStatus.scheduled;
      case 'draft':
        return PostStatus.draft;
      case 'failed':
        return PostStatus.failed;
      default:
        return PostStatus.draft;
    }
  }

  /// جلب بوستات Facebook
  Future<List<PostModel>> fetchFacebookPosts() async {
    try {
      // هنا يمكن استخدام Facebook Graph API
      // حالياً يرجع قائمة فارغة حتى يتم ربط الحساب
      return [];

      /* كود حقيقي لاستخدام Facebook API:

      final accessToken = 'YOUR_FACEBOOK_ACCESS_TOKEN';
      final response = await http.get(
        Uri.parse('https://graph.facebook.com/v18.0/me/posts?fields=id,message,created_time,likes.summary(true),comments.summary(true),shares&access_token=$accessToken'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final posts = <PostModel>[];

        for (var post in data['data']) {
          posts.add(PostModel(
            id: post['id'],
            title: 'منشور Facebook',
            content: post['message'] ?? '',
            platforms: ['Facebook'],
            publishDate: DateTime.parse(post['created_time']),
            engagement: {
              'likes': post['likes']?['summary']?['total_count'] ?? 0,
              'comments': post['comments']?['summary']?['total_count'] ?? 0,
              'shares': post['shares']?['count'] ?? 0,
            },
          ));
        }

        return posts;
      }
      */

    } catch (e) {
      print('خطأ في جلب بوستات Facebook: $e');
      return [];
    }
  }

  /// جلب بوستات Instagram
  Future<List<PostModel>> fetchInstagramPosts() async {
    try {
      // حالياً يرجع قائمة فارغة حتى يتم ربط الحساب
      return [];

      /* كود حقيقي لاستخدام Instagram API:

      final accessToken = 'YOUR_INSTAGRAM_ACCESS_TOKEN';
      final response = await http.get(
        Uri.parse('https://graph.instagram.com/me/media?fields=id,caption,media_type,media_url,permalink,timestamp,like_count,comments_count&access_token=$accessToken'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final posts = <PostModel>[];

        for (var post in data['data']) {
          posts.add(PostModel(
            id: post['id'],
            title: 'منشور Instagram',
            content: post['caption'] ?? '',
            platforms: ['Instagram'],
            publishDate: DateTime.parse(post['timestamp']),
            mediaUrl: post['media_url'],
            engagement: {
              'likes': post['like_count'] ?? 0,
              'comments': post['comments_count'] ?? 0,
            },
          ));
        }

        return posts;
      }
      */

    } catch (e) {
      print('خطأ في جلب بوستات Instagram: $e');
      return [];
    }
  }

  /// جلب بوستات Twitter/X
  Future<List<PostModel>> fetchTwitterPosts() async {
    try {
      // حالياً يرجع قائمة فارغة حتى يتم ربط الحساب
      return [];

      /* كود حقيقي لاستخدام Twitter API v2:

      final bearerToken = 'YOUR_TWITTER_BEARER_TOKEN';
      final userId = 'YOUR_USER_ID';

      final response = await http.get(
        Uri.parse('https://api.twitter.com/2/users/$userId/tweets?tweet.fields=created_at,public_metrics&max_results=10'),
        headers: {
          'Authorization': 'Bearer $bearerToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final posts = <PostModel>[];

        for (var tweet in data['data']) {
          final metrics = tweet['public_metrics'];
          posts.add(PostModel(
            id: tweet['id'],
            title: 'تغريدة',
            content: tweet['text'],
            platforms: ['Twitter'],
            publishDate: DateTime.parse(tweet['created_at']),
            engagement: {
              'likes': metrics['like_count'] ?? 0,
              'retweets': metrics['retweet_count'] ?? 0,
              'replies': metrics['reply_count'] ?? 0,
            },
          ));
        }

        return posts;
      }
      */

    } catch (e) {
      print('خطأ في جلب تغريدات Twitter: $e');
      return [];
    }
  }

  /// جلب فيديوهات TikTok
  Future<List<PostModel>> fetchTikTokPosts() async {
    try {
      // حالياً يرجع قائمة فارغة حتى يتم ربط الحساب
      return [];

      /* كود حقيقي لاستخدام TikTok API:

      // TikTok requires OAuth 2.0 authentication
      final accessToken = 'YOUR_TIKTOK_ACCESS_TOKEN';

      final response = await http.get(
        Uri.parse('https://open-api.tiktok.com/video/list/?access_token=$accessToken&open_id=YOUR_OPEN_ID&cursor=0&max_count=20'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final posts = <PostModel>[];

        for (var video in data['data']['videos']) {
          posts.add(PostModel(
            id: video['video_id'],
            title: 'فيديو TikTok',
            content: video['video_description'] ?? '',
            platforms: ['TikTok'],
            publishDate: DateTime.fromMillisecondsSinceEpoch(video['create_time'] * 1000),
            mediaUrl: video['cover_image_url'],
            engagement: {
              'likes': video['like_count'] ?? 0,
              'comments': video['comment_count'] ?? 0,
              'shares': video['share_count'] ?? 0,
              'views': video['view_count'] ?? 0,
            },
          ));
        }

        return posts;
      }
      */

    } catch (e) {
      print('خطأ في جلب فيديوهات TikTok: $e');
      return [];
    }
  }

  /// جلب إحصائيات البوستات
  Future<Map<String, dynamic>> getPostsAnalytics() async {
    try {
      final posts = await fetchAllPosts();

      int totalLikes = 0;
      int totalComments = 0;
      int totalShares = 0;
      int totalViews = 0;

      for (var post in posts) {
        if (post.analytics != null) {
          totalLikes += (post.analytics!['likes'] as int? ?? 0);
          totalComments += (post.analytics!['comments'] as int? ?? 0);
          totalShares += (post.analytics!['shares'] as int? ?? 0);
          totalViews += (post.analytics!['views'] as int? ?? 0);
        }
      }

      return {
        'totalPosts': posts.length,
        'totalLikes': totalLikes,
        'totalComments': totalComments,
        'totalShares': totalShares,
        'totalViews': totalViews,
        'avgEngagement': posts.isNotEmpty
            ? (totalLikes + totalComments + totalShares) / posts.length
            : 0,
      };
    } catch (e) {
      print('خطأ في حساب الإحصائيات: $e');
      return {};
    }
  }

  /// بيانات تجريبية للعرض
  List<PostModel> _getDemoPosts() {
    return [
      PostModel(
        id: '1',
        content: '🚀 إطلاق منتج جديد - نحن سعداء بالإعلان عن إطلاق منتجنا الجديد!',
        platforms: ['Facebook', 'Instagram'],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: PostStatus.published,
        analytics: {'likes': 234, 'comments': 45, 'shares': 12},
      ),
      PostModel(
        id: '2',
        content: '✨ نصائح التسويق - 5 نصائح ذهبية للتسويق الرقمي في 2024',
        platforms: ['Twitter', 'LinkedIn'],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
        status: PostStatus.published,
        analytics: {'likes': 567, 'comments': 89, 'shares': 34, 'retweets': 78},
      ),
      PostModel(
        id: '3',
        content: '🎥 فيديو ترويجي - شاهد الفيديو الجديد عن خدماتنا المميزة',
        platforms: ['TikTok', 'Instagram'],
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
        status: PostStatus.published,
        analytics: {'likes': 1234, 'comments': 234, 'shares': 89, 'views': 12500},
      ),
      PostModel(
        id: '4',
        content: '🎉 عرض خاص - عرض لمدة محدودة! خصم 50% على جميع المنتجات',
        platforms: ['Facebook', 'Instagram', 'Twitter'],
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        publishedAt: DateTime.now().subtract(const Duration(hours: 12)),
        status: PostStatus.published,
        analytics: {'likes': 890, 'comments': 156, 'shares': 67},
      ),
      PostModel(
        id: '5',
        content: '❤️ شكر للمتابعين - شكراً لكم على وصولنا 10K متابع!',
        platforms: ['Instagram'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        status: PostStatus.published,
        analytics: {'likes': 2345, 'comments': 456, 'shares': 123},
      ),
      PostModel(
        id: '6',
        content: '💪 نصيحة اليوم - النجاح يبدأ بخطوة واحدة. ابدأ الآن!',
        platforms: ['Facebook', 'Twitter'],
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
        publishedAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
        status: PostStatus.published,
        analytics: {'likes': 445, 'comments': 67, 'shares': 23},
      ),
    ];
  }

  /// تحديث حالة البوست
  Future<bool> updatePostStatus(String postId, PostStatus newStatus) async {
    try {
      // هنا يمكن إضافة logic لتحديث الحالة في الـ backend
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      print('خطأ في تحديث حالة البوست: $e');
      return false;
    }
  }

  /// حذف بوست من منصة معينة
  Future<bool> deletePost(String postId, String platform) async {
    try {
      // هنا يمكن إضافة logic للحذف من الـ API المناسب
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      print('خطأ في حذف البوست: $e');
      return false;
    }
  }
}
