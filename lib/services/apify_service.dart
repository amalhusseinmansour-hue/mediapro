import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

/// خدمة Apify لجلب بيانات السوشال ميديا بدون OAuth
///
/// المزايا:
/// ✅ جلب بيانات أي حساب (حتى بدون ربط OAuth)
/// ✅ إحصائيات مفصلة وبيانات تاريخية
/// ✅ تحليل المنافسين
/// ✅ حفظ البيانات محلياً في Hive
///
/// العيوب:
/// ❌ لا يمكن النشر (scraping فقط)
/// ❌ يحتاج Apify subscription ($49/شهر)
class ApifyService extends GetxController {
  // 🔑 API Token من Apify Console
  static const String _apiToken = 'apify_api_IthXMTCSnmkj0lbEtIyBncXIPDPVBy2Ho9ns';
  static const String _baseUrl = 'https://api.apify.com/v2';

  final RxBool isLoading = false.obs;
  final RxString lastError = ''.obs;

  // Hive boxes للتخزين المحلي
  late Box<Map> _accountsBox;
  late Box<Map> _postsBox;
  late Box<Map> _analyticsBox;

  @override
  void onInit() {
    super.onInit();
    _initHiveBoxes();
  }

  /// تهيئة Hive boxes للتخزين
  Future<void> _initHiveBoxes() async {
    try {
      _accountsBox = await Hive.openBox<Map>('apify_accounts');
      _postsBox = await Hive.openBox<Map>('apify_posts');
      _analyticsBox = await Hive.openBox<Map>('apify_analytics');
      print('✅ Hive boxes initialized');
    } catch (e) {
      print('❌ Error initializing Hive: $e');
    }
  }

  // ============================================
  // 📸 INSTAGRAM - Apify Actor: apify/instagram-scraper
  // ============================================

  /// جلب ملف Instagram كامل مع المنشورات
  ///
  /// Example:
  /// ```dart
  /// final profile = await apifyService.scrapeInstagramProfile('nike');
  /// print('Followers: ${profile.followers}');
  /// print('Posts: ${profile.postsCount}');
  /// ```
  Future<InstagramProfileFull?> scrapeInstagramProfile(
    String username, {
    int maxPosts = 50,
    bool saveLocally = true,
  }) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      // Input للـ Actor
      final input = {
        'usernames': [username],
        'resultsLimit': maxPosts,
        'addParentData': true,
      };

      print('🌐 Starting Instagram scrape for: $username');

      // تشغيل Actor
      final runData = await _runActor(
        actorId: 'apify/instagram-scraper',
        input: input,
        timeout: const Duration(minutes: 5),
      );

      if (runData == null) {
        throw Exception('Actor run failed');
      }

      // جلب النتائج
      final results = await _getDatasetItems(runData['defaultDatasetId']);

      if (results.isEmpty) {
        print('⚠️ No data found for: $username');
        return null;
      }

      // تحليل البيانات
      final profileData = results.first;
      final profile = InstagramProfileFull.fromApify(profileData);

      // حفظ محلياً
      if (saveLocally) {
        await _saveAccountData(
          platform: 'instagram',
          username: username,
          data: profileData,
        );
        print('💾 Data saved locally for: $username');
      }

      print('✅ Instagram scrape completed for: $username');
      return profile;
    } catch (e) {
      print('❌ Instagram scrape error: $e');
      lastError.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// جلب منشورات من هاشتاق معين
  Future<List<InstagramPost>> scrapeInstagramHashtag(
    String hashtag, {
    int maxPosts = 100,
  }) async {
    try {
      final cleanHashtag = hashtag.replaceAll('#', '');

      final input = {
        'hashtags': [cleanHashtag],
        'resultsLimit': maxPosts,
      };

      final runData = await _runActor(
        actorId: 'apify/instagram-scraper',
        input: input,
      );

      if (runData == null) return [];

      final results = await _getDatasetItems(runData['defaultDatasetId']);

      return results
          .map((item) => InstagramPost.fromApify(item))
          .toList();
    } catch (e) {
      print('❌ Hashtag scrape error: $e');
      return [];
    }
  }

  // ============================================
  // 🐦 TWITTER/X - Apify Actor: apidojo/tweet-scraper
  // ============================================

  /// جلب ملف Twitter/X كامل
  Future<TwitterProfileFull?> scrapeTwitterProfile(
    String username, {
    int maxTweets = 50,
    bool saveLocally = true,
  }) async {
    try {
      isLoading.value = true;

      final cleanUsername = username.replaceAll('@', '');

      final input = {
        'searchMode': 'user',
        'searchQueries': [cleanUsername],
        'maxTweets': maxTweets,
        'addUserInfo': true,
      };

      print('🌐 Starting Twitter scrape for: $cleanUsername');

      final runData = await _runActor(
        actorId: 'apidojo/tweet-scraper',
        input: input,
      );

      if (runData == null) return null;

      final results = await _getDatasetItems(runData['defaultDatasetId']);

      if (results.isEmpty) return null;

      final profile = TwitterProfileFull.fromApify(results);

      if (saveLocally) {
        await _saveAccountData(
          platform: 'twitter',
          username: cleanUsername,
          data: results.first,
        );
      }

      print('✅ Twitter scrape completed');
      return profile;
    } catch (e) {
      print('❌ Twitter scrape error: $e');
      lastError.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // 🎵 TIKTOK - Apify Actor: clockworks/tiktok-scraper
  // ============================================

  /// جلب ملف TikTok كامل
  Future<TikTokProfileFull?> scrapeTikTokProfile(
    String username, {
    int maxVideos = 30,
    bool saveLocally = true,
  }) async {
    try {
      isLoading.value = true;

      final input = {
        'profiles': [username],
        'resultsPerPage': maxVideos,
      };

      print('🌐 Starting TikTok scrape for: $username');

      final runData = await _runActor(
        actorId: 'clockworks/tiktok-scraper',
        input: input,
      );

      if (runData == null) return null;

      final results = await _getDatasetItems(runData['defaultDatasetId']);

      if (results.isEmpty) return null;

      final profile = TikTokProfileFull.fromApify(results.first);

      if (saveLocally) {
        await _saveAccountData(
          platform: 'tiktok',
          username: username,
          data: results.first,
        );
      }

      print('✅ TikTok scrape completed');
      return profile;
    } catch (e) {
      print('❌ TikTok scrape error: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // 🔥 FACEBOOK - Apify Actor: apify/facebook-pages-scraper
  // ============================================

  /// جلب صفحة Facebook
  Future<FacebookPageFull?> scrapeFacebookPage(
    String pageUrl, {
    int maxPosts = 50,
    bool saveLocally = true,
  }) async {
    try {
      isLoading.value = true;

      final input = {
        'startUrls': [{'url': pageUrl}],
        'maxPosts': maxPosts,
      };

      print('🌐 Starting Facebook scrape for: $pageUrl');

      final runData = await _runActor(
        actorId: 'apify/facebook-pages-scraper',
        input: input,
      );

      if (runData == null) return null;

      final results = await _getDatasetItems(runData['defaultDatasetId']);

      if (results.isEmpty) return null;

      final page = FacebookPageFull.fromApify(results.first);

      if (saveLocally) {
        await _saveAccountData(
          platform: 'facebook',
          username: pageUrl.split('/').last,
          data: results.first,
        );
      }

      print('✅ Facebook scrape completed');
      return page;
    } catch (e) {
      print('❌ Facebook scrape error: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // 🎯 MULTI-PLATFORM FEATURES
  // ============================================

  /// جلب بيانات حساب من أي منصة
  Future<dynamic> scrapeAccount({
    required String platform,
    required String username,
    int maxContent = 50,
  }) async {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return await scrapeInstagramProfile(username, maxPosts: maxContent);
      case 'twitter':
      case 'x':
        return await scrapeTwitterProfile(username, maxTweets: maxContent);
      case 'tiktok':
        return await scrapeTikTokProfile(username, maxVideos: maxContent);
      case 'facebook':
        return await scrapeFacebookPage(username, maxPosts: maxContent);
      default:
        throw Exception('Platform not supported: $platform');
    }
  }

  /// جلب وحفظ بيانات عدة حسابات دفعة واحدة
  Future<List<Map<String, dynamic>>> scrapeMultipleAccounts({
    required List<Map<String, String>> accounts, // [{platform, username}]
    Function(int current, int total)? onProgress,
  }) async {
    final results = <Map<String, dynamic>>[];

    for (int i = 0; i < accounts.length; i++) {
      final account = accounts[i];
      onProgress?.call(i + 1, accounts.length);

      try {
        final data = await scrapeAccount(
          platform: account['platform']!,
          username: account['username']!,
        );

        if (data != null) {
          results.add({
            'platform': account['platform'],
            'username': account['username'],
            'data': data,
            'success': true,
          });
        }
      } catch (e) {
        results.add({
          'platform': account['platform'],
          'username': account['username'],
          'error': e.toString(),
          'success': false,
        });
      }

      // تأخير لتجنب rate limiting
      await Future.delayed(const Duration(seconds: 3));
    }

    return results;
  }

  // ============================================
  // 💾 LOCAL STORAGE - حفظ البيانات محلياً
  // ============================================

  /// حفظ بيانات حساب في Hive
  Future<void> _saveAccountData({
    required String platform,
    required String username,
    required Map<String, dynamic> data,
  }) async {
    try {
      final key = '${platform}_$username';
      await _accountsBox.put(key, {
        'platform': platform,
        'username': username,
        'data': data,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Error saving account data: $e');
    }
  }

  /// جلب بيانات محفوظة
  Map<String, dynamic>? getLocalAccountData({
    required String platform,
    required String username,
  }) {
    try {
      final key = '${platform}_$username';
      final data = _accountsBox.get(key);
      if (data == null) return null;
      return Map<String, dynamic>.from(data);
    } catch (e) {
      print('❌ Error getting local data: $e');
      return null;
    }
  }

  /// جلب جميع الحسابات المحفوظة لمنصة معينة
  List<Map<String, dynamic>> getLocalAccountsByPlatform(String platform) {
    try {
      return _accountsBox.values
          .where((item) => item['platform'] == platform)
          .toList()
          .cast<Map<String, dynamic>>();
    } catch (e) {
      print('❌ Error getting accounts by platform: $e');
      return [];
    }
  }

  /// حذف بيانات حساب محفوظ
  Future<void> deleteLocalAccountData({
    required String platform,
    required String username,
  }) async {
    try {
      final key = '${platform}_$username';
      await _accountsBox.delete(key);
      print('🗑️ Deleted local data for: $username');
    } catch (e) {
      print('❌ Error deleting local data: $e');
    }
  }

  /// مسح جميع البيانات المحلية
  Future<void> clearAllLocalData() async {
    try {
      await _accountsBox.clear();
      await _postsBox.clear();
      await _analyticsBox.clear();
      print('🗑️ All local data cleared');
    } catch (e) {
      print('❌ Error clearing data: $e');
    }
  }

  // ============================================
  // 🔧 APIFY API HELPERS
  // ============================================

  /// تشغيل Apify Actor
  Future<Map<String, dynamic>?> _runActor({
    required String actorId,
    required Map<String, dynamic> input,
    Duration? timeout,
  }) async {
    try {
      final url = '$_baseUrl/acts/$actorId/runs?token=$_apiToken';

      print('🚀 Running actor: $actorId');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(input),
      ).timeout(
        timeout ?? const Duration(minutes: 10),
        onTimeout: () {
          throw Exception('Actor run timeout');
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final runId = data['id'];

        print('⏳ Actor started, waiting for completion...');

        // انتظار اكتمال التشغيل
        return await _waitForRun(runId);
      } else {
        throw Exception('Failed to start actor: ${response.body}');
      }
    } catch (e) {
      print('❌ Actor run error: $e');
      lastError.value = e.toString();
      return null;
    }
  }

  /// انتظار اكتمال تشغيل Actor
  Future<Map<String, dynamic>?> _waitForRun(String runId) async {
    const maxAttempts = 60; // 5 دقائق (60 * 5 ثانية)
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final url = '$_baseUrl/actor-runs/$runId?token=$_apiToken';
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body)['data'];
          final status = data['status'];

          print('📊 Actor status: $status');

          if (status == 'SUCCEEDED') {
            print('✅ Actor completed successfully');
            return data;
          } else if (status == 'FAILED' || status == 'ABORTED') {
            throw Exception('Actor failed with status: $status');
          }

          // لا يزال قيد التشغيل، انتظر 5 ثوان
          await Future.delayed(const Duration(seconds: 5));
          attempts++;
        }
      } catch (e) {
        print('❌ Error checking run status: $e');
        return null;
      }
    }

    throw Exception('Actor timeout - exceeded maximum wait time');
  }

  /// جلب عناصر Dataset
  Future<List<Map<String, dynamic>>> _getDatasetItems(String datasetId) async {
    try {
      final url = '$_baseUrl/datasets/$datasetId/items?token=$_apiToken';

      print('📥 Fetching dataset: $datasetId');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List items = json.decode(response.body);
        print('✅ Fetched ${items.length} items');
        return items.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch dataset: ${response.body}');
      }
    } catch (e) {
      print('❌ Dataset fetch error: $e');
      return [];
    }
  }

  /// حساب التكلفة التقديرية
  double estimateCost({
    required String platform,
    required int accounts,
    required int contentPerAccount,
  }) {
    // أسعار تقريبية بناءً على Apify pricing
    const prices = {
      'instagram': 0.01, // $0.01 لكل profile
      'twitter': 0.40,   // $0.40 لكل 1000 tweets
      'tiktok': 0.02,    // $0.02 لكل profile
      'facebook': 0.015, // $0.015 لكل page
    };

    final pricePerUnit = prices[platform.toLowerCase()] ?? 0.01;
    return accounts * pricePerUnit;
  }
}

// ============================================
// 📦 DATA MODELS
// ============================================

class InstagramProfileFull {
  final String username;
  final String fullName;
  final String bio;
  final int followers;
  final int following;
  final int postsCount;
  final bool isVerified;
  final bool isPrivate;
  final String? profilePicUrl;
  final String? externalUrl;
  final List<InstagramPost> latestPosts;

  InstagramProfileFull({
    required this.username,
    required this.fullName,
    required this.bio,
    required this.followers,
    required this.following,
    required this.postsCount,
    required this.isVerified,
    required this.isPrivate,
    this.profilePicUrl,
    this.externalUrl,
    this.latestPosts = const [],
  });

  factory InstagramProfileFull.fromApify(Map<String, dynamic> data) {
    return InstagramProfileFull(
      username: data['username'] ?? '',
      fullName: data['fullName'] ?? '',
      bio: data['biography'] ?? '',
      followers: data['followersCount'] ?? 0,
      following: data['followsCount'] ?? 0,
      postsCount: data['postsCount'] ?? 0,
      isVerified: data['verified'] ?? false,
      isPrivate: data['private'] ?? false,
      profilePicUrl: data['profilePicUrl'],
      externalUrl: data['externalUrl'],
      latestPosts: data['latestPosts'] != null
          ? (data['latestPosts'] as List)
              .map((post) => InstagramPost.fromApify(post))
              .toList()
          : [],
    );
  }

  double get engagementRate {
    if (postsCount == 0 || followers == 0) return 0.0;
    final totalEngagement = latestPosts.fold<int>(
      0,
      (sum, post) => sum + post.likesCount + post.commentsCount,
    );
    return (totalEngagement / postsCount / followers) * 100;
  }
}

class InstagramPost {
  final String id;
  final String? caption;
  final String? imageUrl;
  final String? videoUrl;
  final int likesCount;
  final int commentsCount;
  final DateTime timestamp;
  final String type; // 'Image', 'Video', 'Sidecar'

  InstagramPost({
    required this.id,
    this.caption,
    this.imageUrl,
    this.videoUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.timestamp,
    required this.type,
  });

  factory InstagramPost.fromApify(Map<String, dynamic> data) {
    return InstagramPost(
      id: data['id'] ?? '',
      caption: data['caption'],
      imageUrl: data['displayUrl'],
      videoUrl: data['videoUrl'],
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      timestamp: DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String()),
      type: data['type'] ?? 'Image',
    );
  }
}

class TwitterProfileFull {
  final String username;
  final String displayName;
  final String bio;
  final int followers;
  final int following;
  final int tweetsCount;
  final bool isVerified;
  final String? profileImageUrl;
  final List<Tweet> latestTweets;

  TwitterProfileFull({
    required this.username,
    required this.displayName,
    required this.bio,
    required this.followers,
    required this.following,
    required this.tweetsCount,
    required this.isVerified,
    this.profileImageUrl,
    this.latestTweets = const [],
  });

  factory TwitterProfileFull.fromApify(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return TwitterProfileFull(
        username: '',
        displayName: '',
        bio: '',
        followers: 0,
        following: 0,
        tweetsCount: 0,
        isVerified: false,
      );
    }

    final first = data.first;
    final author = first['author'] ?? {};

    return TwitterProfileFull(
      username: author['userName'] ?? '',
      displayName: author['name'] ?? '',
      bio: author['description'] ?? '',
      followers: author['followers'] ?? 0,
      following: author['following'] ?? 0,
      tweetsCount: author['statusesCount'] ?? 0,
      isVerified: author['isBlueVerified'] ?? false,
      profileImageUrl: author['profilePicture'],
      latestTweets: data.map((item) => Tweet.fromApify(item)).toList(),
    );
  }
}

class Tweet {
  final String id;
  final String text;
  final int likes;
  final int retweets;
  final int replies;
  final DateTime createdAt;

  Tweet({
    required this.id,
    required this.text,
    required this.likes,
    required this.retweets,
    required this.replies,
    required this.createdAt,
  });

  factory Tweet.fromApify(Map<String, dynamic> data) {
    return Tweet(
      id: data['id'] ?? '',
      text: data['text'] ?? '',
      likes: data['likeCount'] ?? 0,
      retweets: data['retweetCount'] ?? 0,
      replies: data['replyCount'] ?? 0,
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class TikTokProfileFull {
  final String username;
  final String nickname;
  final String bio;
  final int followers;
  final int following;
  final int likes;
  final int videosCount;
  final bool isVerified;
  final String? avatarUrl;

  TikTokProfileFull({
    required this.username,
    required this.nickname,
    required this.bio,
    required this.followers,
    required this.following,
    required this.likes,
    required this.videosCount,
    required this.isVerified,
    this.avatarUrl,
  });

  factory TikTokProfileFull.fromApify(Map<String, dynamic> data) {
    return TikTokProfileFull(
      username: data['authorMeta']?['name'] ?? '',
      nickname: data['authorMeta']?['nickName'] ?? '',
      bio: data['authorMeta']?['signature'] ?? '',
      followers: data['authorMeta']?['fans'] ?? 0,
      following: data['authorMeta']?['following'] ?? 0,
      likes: data['authorMeta']?['heart'] ?? 0,
      videosCount: data['authorMeta']?['video'] ?? 0,
      isVerified: data['authorMeta']?['verified'] ?? false,
      avatarUrl: data['authorMeta']?['avatar'],
    );
  }
}

class FacebookPageFull {
  final String name;
  final String category;
  final String? about;
  final int likes;
  final int followers;
  final String? profilePicUrl;
  final String? coverPhotoUrl;

  FacebookPageFull({
    required this.name,
    required this.category,
    this.about,
    required this.likes,
    required this.followers,
    this.profilePicUrl,
    this.coverPhotoUrl,
  });

  factory FacebookPageFull.fromApify(Map<String, dynamic> data) {
    return FacebookPageFull(
      name: data['name'] ?? '',
      category: data['categories']?.first ?? '',
      about: data['about'],
      likes: data['likes'] ?? 0,
      followers: data['followersCount'] ?? 0,
      profilePicUrl: data['profilePicture'],
      coverPhotoUrl: data['coverPhoto'],
    );
  }
}
