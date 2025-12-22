import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:get/get.dart';

/// خدمة Scrapfly لجلب البيانات العامة من منصات السوشال ميديا
///
/// استخدامات:
/// - تحليل الهاشتاقات الشائعة
/// - مراقبة المنافسين
/// - اكتشاف المحتوى
/// - تحليل الترندات
class ScrapflyService extends GetxController {
  // 🔑 احصل على API Key من: https://scrapfly.io
  static const String _apiKey = 'YOUR_SCRAPFLY_API_KEY'; // ⚠️ ضع API key هنا
  static const String _baseUrl = 'https://api.scrapfly.io/scrape';

  final RxBool isLoading = false.obs;
  final RxString lastError = ''.obs;

  /// Scrape أي URL باستخدام Scrapfly
  Future<Map<String, dynamic>?> scrapeUrl({
    required String url,
    bool renderJs = true,
    String country = 'us',
    Map<String, String>? headers,
  }) async {
    try {
      isLoading.value = true;
      lastError.value = '';

      final queryParams = {
        'key': _apiKey,
        'url': url,
        'render_js': renderJs.toString(),
        'country': country,
        'format': 'json',
      };

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

      print('🌐 Scraping: $url');

      final response = await http
          .get(uri, headers: headers ?? {'Accept': 'application/json'})
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Scraping successful');
        return data;
      } else {
        throw Exception(
          'Scraping failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Scraping error: $e');
      lastError.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // 📊 INSTAGRAM FEATURES
  // ============================================

  /// جلب الهاشتاقات الشائعة من Instagram
  Future<List<HashtagData>> getInstagramTrendingHashtags({
    int limit = 20,
  }) async {
    try {
      final data = await scrapeUrl(
        url: 'https://www.instagram.com/explore/tags/',
        renderJs: true,
      );

      if (data == null || data['content'] == null) {
        return [];
      }

      final htmlContent = data['content'] as String;
      return _extractInstagramHashtags(htmlContent, limit);
    } catch (e) {
      print('❌ Error fetching Instagram hashtags: $e');
      return [];
    }
  }

  /// تحليل ملف Instagram عام
  Future<InstagramProfileData?> analyzeInstagramProfile(String username) async {
    try {
      final url = 'https://www.instagram.com/$username/';
      final data = await scrapeUrl(url: url, renderJs: true);

      if (data == null || data['content'] == null) {
        return null;
      }

      final htmlContent = data['content'] as String;
      return _parseInstagramProfile(htmlContent, username);
    } catch (e) {
      print('❌ Error analyzing Instagram profile: $e');
      return null;
    }
  }

  /// البحث عن منشورات بهاشتاق معين
  Future<List<InstagramPost>> searchInstagramHashtag(
    String hashtag, {
    int limit = 50,
  }) async {
    try {
      final cleanHashtag = hashtag.replaceAll('#', '');
      final url = 'https://www.instagram.com/explore/tags/$cleanHashtag/';

      final data = await scrapeUrl(url: url, renderJs: true);

      if (data == null || data['content'] == null) {
        return [];
      }

      final htmlContent = data['content'] as String;
      return _extractInstagramPosts(htmlContent, limit);
    } catch (e) {
      print('❌ Error searching Instagram hashtag: $e');
      return [];
    }
  }

  // ============================================
  // 🐦 TWITTER FEATURES
  // ============================================

  /// جلب الترندات من Twitter
  Future<List<String>> getTwitterTrending({String country = 'US'}) async {
    try {
      final data = await scrapeUrl(
        url: 'https://twitter.com/explore/tabs/trending',
        renderJs: true,
        country: country.toLowerCase(),
      );

      if (data == null || data['content'] == null) {
        return [];
      }

      final htmlContent = data['content'] as String;
      return _extractTwitterTrends(htmlContent);
    } catch (e) {
      print('❌ Error fetching Twitter trends: $e');
      return [];
    }
  }

  /// تحليل حساب Twitter عام
  Future<TwitterProfileData?> analyzeTwitterProfile(String username) async {
    try {
      final cleanUsername = username.replaceAll('@', '');
      final url = 'https://twitter.com/$cleanUsername';

      final data = await scrapeUrl(url: url, renderJs: true);

      if (data == null || data['content'] == null) {
        return null;
      }

      final htmlContent = data['content'] as String;
      return _parseTwitterProfile(htmlContent, username);
    } catch (e) {
      print('❌ Error analyzing Twitter profile: $e');
      return null;
    }
  }

  // ============================================
  // 🎯 COMPETITOR ANALYSIS
  // ============================================

  /// مقارنة عدة حسابات (منافسين)
  Future<List<CompetitorData>> compareCompetitors({
    required String platform,
    required List<String> usernames,
  }) async {
    final competitors = <CompetitorData>[];

    for (final username in usernames) {
      try {
        dynamic profileData;

        if (platform.toLowerCase() == 'instagram') {
          profileData = await analyzeInstagramProfile(username);
        } else if (platform.toLowerCase() == 'twitter') {
          profileData = await analyzeTwitterProfile(username);
        }

        if (profileData != null) {
          competitors.add(
            CompetitorData(
              username: username,
              platform: platform,
              followers: profileData.followers ?? 0,
              following: profileData.following ?? 0,
              posts: profileData.posts ?? 0,
              engagement: profileData.engagement ?? 0.0,
            ),
          );
        }
      } catch (e) {
        print('⚠️ Error analyzing competitor $username: $e');
      }

      // تأخير بسيط لتجنب rate limiting
      await Future.delayed(const Duration(seconds: 2));
    }

    return competitors;
  }

  // ============================================
  // 🔍 PRIVATE HELPER METHODS
  // ============================================

  List<HashtagData> _extractInstagramHashtags(String html, int limit) {
    final hashtags = <HashtagData>[];

    try {
      // استخراج الهاشتاقات من HTML
      final RegExp hashtagRegex = RegExp(r'#(\w+)');
      final matches = hashtagRegex.allMatches(html);

      final uniqueHashtags = <String>{};

      for (final match in matches) {
        if (uniqueHashtags.length >= limit) break;

        final hashtag = match.group(1);
        if (hashtag != null && hashtag.isNotEmpty) {
          uniqueHashtags.add(hashtag);
        }
      }

      for (final tag in uniqueHashtags) {
        hashtags.add(
          HashtagData(
            hashtag: '#$tag',
            platform: 'instagram',
            postCount: 0, // يمكن استخراجه من البيانات
          ),
        );
      }
    } catch (e) {
      print('❌ Error extracting hashtags: $e');
    }

    return hashtags;
  }

  InstagramProfileData? _parseInstagramProfile(String html, String username) {
    try {
      // تحليل بيانات الملف الشخصي من HTML
      // ملاحظة: Instagram يستخدم JSON embedded في HTML
      final RegExp jsonRegex = RegExp(r'window\._sharedData = ({.*?});');
      final match = jsonRegex.firstMatch(html);

      if (match != null) {
        final jsonStr = match.group(1);
        if (jsonStr != null) {
          final data = json.decode(jsonStr);

          // استخراج البيانات
          final userInfo =
              data['entry_data']?['ProfilePage']?[0]?['graphql']?['user'];

          if (userInfo != null) {
            return InstagramProfileData(
              username: username,
              fullName: userInfo['full_name'] ?? '',
              bio: userInfo['biography'] ?? '',
              followers: userInfo['edge_followed_by']?['count'] ?? 0,
              following: userInfo['edge_follow']?['count'] ?? 0,
              posts: userInfo['edge_owner_to_timeline_media']?['count'] ?? 0,
              isVerified: userInfo['is_verified'] ?? false,
              profilePicUrl: userInfo['profile_pic_url_hd'] ?? '',
            );
          }
        }
      }
    } catch (e) {
      print('❌ Error parsing Instagram profile: $e');
    }

    return null;
  }

  List<InstagramPost> _extractInstagramPosts(String html, int limit) {
    // استخراج المنشورات من HTML
    // هذا مثال مبسط - قد تحتاج لتحليل أعمق
    return [];
  }

  List<String> _extractTwitterTrends(String html) {
    final trends = <String>[];

    try {
      final RegExp trendRegex = RegExp(r'<span class="trend">(.*?)</span>');
      final matches = trendRegex.allMatches(html);

      for (final match in matches) {
        final trend = match.group(1);
        if (trend != null && trend.isNotEmpty) {
          trends.add(trend);
        }
      }
    } catch (e) {
      print('❌ Error extracting Twitter trends: $e');
    }

    return trends;
  }

  TwitterProfileData? _parseTwitterProfile(String html, String username) {
    // تحليل ملف Twitter
    // مشابه لـ Instagram
    return null;
  }
}

// ============================================
// 📦 DATA MODELS
// ============================================

class HashtagData {
  final String hashtag;
  final String platform;
  final int postCount;

  HashtagData({
    required this.hashtag,
    required this.platform,
    required this.postCount,
  });
}

class InstagramProfileData {
  final String username;
  final String fullName;
  final String bio;
  final int followers;
  final int following;
  final int posts;
  final bool isVerified;
  final String profilePicUrl;
  double? engagement;

  InstagramProfileData({
    required this.username,
    required this.fullName,
    required this.bio,
    required this.followers,
    required this.following,
    required this.posts,
    required this.isVerified,
    required this.profilePicUrl,
    this.engagement,
  });
}

class InstagramPost {
  final String id;
  final String imageUrl;
  final String caption;
  final int likes;
  final int comments;
  final DateTime timestamp;

  InstagramPost({
    required this.id,
    required this.imageUrl,
    required this.caption,
    required this.likes,
    required this.comments,
    required this.timestamp,
  });
}

class TwitterProfileData {
  final String username;
  final String displayName;
  final String bio;
  final int followers;
  final int following;
  final int tweets;
  final bool isVerified;
  double? engagement;

  TwitterProfileData({
    required this.username,
    required this.displayName,
    required this.bio,
    required this.followers,
    required this.following,
    required this.tweets,
    required this.isVerified,
    this.engagement,
  });
}

class CompetitorData {
  final String username;
  final String platform;
  final int followers;
  final int following;
  final int posts;
  final double engagement;

  CompetitorData({
    required this.username,
    required this.platform,
    required this.followers,
    required this.following,
    required this.posts,
    required this.engagement,
  });

  double get followersToFollowingRatio {
    if (following == 0) return followers.toDouble();
    return followers / following;
  }

  double get postsPerDay {
    // يمكن حسابها إذا كان لديك تاريخ التسجيل
    return 0.0;
  }
}
