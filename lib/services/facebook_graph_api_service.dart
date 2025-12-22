import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'social_accounts_service.dart';

/// Facebook Graph API Service
/// Real posting to Facebook & Instagram (via Facebook Business)
class FacebookGraphApiService extends GetxController {
  final SocialAccountsService _accountsService = Get.find<SocialAccountsService>();

  // ========== Configuration ==========

  /// Facebook App credentials (will be configured in .env)
  static const String graphApiVersion = 'v18.0';
  static const String baseUrl = 'https://graph.facebook.com/$graphApiVersion';

  // ========== State Management ==========

  final RxBool isLoading = false.obs;
  final RxString lastError = ''.obs;
  final RxString userAccessToken = ''.obs;
  final RxList<FacebookPage> userPages = <FacebookPage>[].obs;

  // ========== Facebook Login & Authentication ==========

  /// Login with Facebook and get user access token
  Future<bool> loginWithFacebook() async {
    try {
      print('🔵 Starting Facebook login...');
      isLoading.value = true;

      // Request Facebook login with required permissions
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: [
          'pages_manage_posts',         // Post to pages
          'pages_read_engagement',      // Read page data
          'instagram_basic',            // Instagram basic info
          'instagram_content_publish',  // Post to Instagram
          'pages_show_list',            // Get list of pages
        ],
      );

      if (result.status == LoginStatus.success) {
        final AccessToken? accessToken = result.accessToken;
        if (accessToken != null) {
          userAccessToken.value = accessToken.token;
          print('✅ Facebook login successful!');
          print('   Token: ${accessToken.token.substring(0, 20)}...');

          // Load user's Facebook pages
          await loadUserPages();

          return true;
        } else {
          // Success status but no access token
          print('❌ Facebook login succeeded but no access token received');
          lastError.value = 'فشل الحصول على رمز الوصول من فيسبوك';
          return false;
        }
      } else if (result.status == LoginStatus.cancelled) {
        print('⚠️ Facebook login cancelled by user');
        lastError.value = 'تم إلغاء تسجيل الدخول';
        return false;
      } else if (result.status == LoginStatus.failed) {
        print('❌ Facebook login failed: ${result.message}');
        lastError.value = result.message ?? 'فشل تسجيل الدخول إلى فيسبوك';
        return false;
      } else {
        // Unknown status
        print('❌ Facebook login unknown status: ${result.status}');
        lastError.value = 'حدث خطأ غير متوقع أثناء تسجيل الدخول';
        return false;
      }
    } catch (e) {
      print('❌ Error during Facebook login: $e');
      print('   Error type: ${e.runtimeType}');

      // Provide user-friendly error message
      if (e.toString().contains('CANCELLED') || e.toString().contains('cancelled')) {
        lastError.value = 'تم إلغاء تسجيل الدخول';
      } else if (e.toString().contains('PERMISSION') || e.toString().contains('permission')) {
        lastError.value = 'تم رفض الأذونات المطلوبة';
      } else if (e.toString().contains('NETWORK') || e.toString().contains('network')) {
        lastError.value = 'خطأ في الاتصال بالإنترنت';
      } else {
        lastError.value = 'حدث خطأ أثناء تسجيل الدخول: ${e.toString()}';
      }

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Load user's Facebook pages
  Future<void> loadUserPages() async {
    try {
      if (userAccessToken.value.isEmpty) {
        print('⚠️ No access token available');
        return;
      }

      print('📄 Loading user pages...');

      final response = await http.get(
        Uri.parse('$baseUrl/me/accounts'),
        headers: {
          'Authorization': 'Bearer ${userAccessToken.value}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pagesData = data['data'] as List;

        userPages.value = pagesData.map((pageJson) => FacebookPage.fromJson(pageJson)).toList();

        print('✅ Loaded ${userPages.length} pages');

        // Save pages to local storage
        for (final page in userPages) {
          await _accountsService.addAccount(
            platform: 'facebook',
            accountName: page.name,
            accountId: page.id,
            accessToken: page.accessToken,
            platformData: {
              'page_id': page.id,
              'page_name': page.name,
              'category': page.category,
              'access_token': page.accessToken,
            },
          );
        }
      } else {
        print('❌ Failed to load pages: ${response.statusCode}');
        print('   Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Error loading pages: $e');
    }
  }

  /// Logout from Facebook
  Future<void> logout() async {
    try {
      await FacebookAuth.instance.logOut();
      userAccessToken.value = '';
      userPages.clear();
      print('✅ Logged out from Facebook');
    } catch (e) {
      print('❌ Error during logout: $e');
    }
  }

  // ========== Post to Facebook Page ==========

  /// Post text to Facebook page
  Future<Map<String, dynamic>> postTextToPage({
    required String pageId,
    required String pageAccessToken,
    required String message,
  }) async {
    try {
      print('📝 Posting text to Facebook page $pageId');

      final response = await http.post(
        Uri.parse('$baseUrl/$pageId/feed'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'message': message,
          'access_token': pageAccessToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Post published! Post ID: ${data['id']}');
        return {
          'success': true,
          'post_id': data['id'],
        };
      } else {
        print('❌ Failed to post: ${response.statusCode}');
        print('   Response: ${response.body}');
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      print('❌ Error posting to Facebook: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Post photo to Facebook page
  Future<Map<String, dynamic>> postPhotoToPage({
    required String pageId,
    required String pageAccessToken,
    required String photoUrl,
    String? caption,
  }) async {
    try {
      print('📷 Posting photo to Facebook page $pageId');

      final response = await http.post(
        Uri.parse('$baseUrl/$pageId/photos'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'url': photoUrl,
          'caption': caption ?? '',
          'access_token': pageAccessToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Photo published! Post ID: ${data['post_id']}');
        return {
          'success': true,
          'post_id': data['post_id'],
        };
      } else {
        print('❌ Failed to post photo: ${response.statusCode}');
        print('   Response: ${response.body}');
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      print('❌ Error posting photo to Facebook: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Post video to Facebook page
  Future<Map<String, dynamic>> postVideoToPage({
    required String pageId,
    required String pageAccessToken,
    required String videoUrl,
    String? title,
    String? description,
  }) async {
    try {
      print('🎬 Posting video to Facebook page $pageId');

      final response = await http.post(
        Uri.parse('$baseUrl/$pageId/videos'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'file_url': videoUrl,
          'title': title ?? '',
          'description': description ?? '',
          'access_token': pageAccessToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Video published! Video ID: ${data['id']}');
        return {
          'success': true,
          'video_id': data['id'],
        };
      } else {
        print('❌ Failed to post video: ${response.statusCode}');
        print('   Response: ${response.body}');
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      print('❌ Error posting video to Facebook: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ========== Post to Instagram (via Facebook Business) ==========

  /// Post photo to Instagram Business Account
  Future<Map<String, dynamic>> postPhotoToInstagram({
    required String instagramAccountId,
    required String pageAccessToken,
    required String imageUrl,
    String? caption,
  }) async {
    try {
      print('📸 Posting photo to Instagram account $instagramAccountId');

      // Step 1: Create media container
      final containerResponse = await http.post(
        Uri.parse('$baseUrl/$instagramAccountId/media'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'image_url': imageUrl,
          'caption': caption ?? '',
          'access_token': pageAccessToken,
        }),
      );

      if (containerResponse.statusCode != 200) {
        print('❌ Failed to create media container: ${containerResponse.statusCode}');
        return {
          'success': false,
          'error': 'Failed to create container: ${containerResponse.body}',
        };
      }

      final containerData = json.decode(containerResponse.body);
      final containerId = containerData['id'];
      print('✅ Media container created: $containerId');

      // Step 2: Publish the container
      final publishResponse = await http.post(
        Uri.parse('$baseUrl/$instagramAccountId/media_publish'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'creation_id': containerId,
          'access_token': pageAccessToken,
        }),
      );

      if (publishResponse.statusCode == 200) {
        final publishData = json.decode(publishResponse.body);
        print('✅ Photo published to Instagram! Post ID: ${publishData['id']}');
        return {
          'success': true,
          'post_id': publishData['id'],
        };
      } else {
        print('❌ Failed to publish: ${publishResponse.statusCode}');
        return {
          'success': false,
          'error': 'Failed to publish: ${publishResponse.body}',
        };
      }
    } catch (e) {
      print('❌ Error posting to Instagram: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get Instagram Business Account ID from Facebook Page
  Future<String?> getInstagramAccountId(String pageId, String pageAccessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$pageId?fields=instagram_business_account&access_token=$pageAccessToken'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final igAccount = data['instagram_business_account'];
        if (igAccount != null) {
          return igAccount['id'];
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getting Instagram account: $e');
      return null;
    }
  }

  // ========== Page Insights & Analytics ==========

  /// Get page insights (followers, engagement, etc.)
  Future<Map<String, dynamic>> getPageInsights({
    required String pageId,
    required String pageAccessToken,
  }) async {
    try {
      print('📊 Fetching insights for page $pageId');

      // Get page info with fan_count (followers)
      final pageResponse = await http.get(
        Uri.parse('$baseUrl/$pageId?fields=fan_count,followers_count,name,engagement&access_token=$pageAccessToken'),
      );

      if (pageResponse.statusCode == 200) {
        final pageData = json.decode(pageResponse.body);

        // Get page posts count
        final postsResponse = await http.get(
          Uri.parse('$baseUrl/$pageId/posts?fields=id&limit=100&access_token=$pageAccessToken'),
        );

        int postsCount = 0;
        if (postsResponse.statusCode == 200) {
          final postsData = json.decode(postsResponse.body);
          postsCount = (postsData['data'] as List?)?.length ?? 0;
        }

        // Calculate engagement rate (simplified)
        final followers = pageData['fan_count'] ?? pageData['followers_count'] ?? 0;
        final engagement = pageData['engagement'] ?? {};
        final engagementCount = engagement['count'] ?? 0;
        final engagementRate = followers > 0 ? (engagementCount / followers * 100) : 0.0;

        print('✅ Page insights loaded: $followers followers, $postsCount posts');

        return {
          'success': true,
          'followers': followers,
          'postsCount': postsCount,
          'engagementRate': engagementRate,
          'engagement': engagement,
        };
      } else {
        print('❌ Failed to get page insights: ${pageResponse.statusCode}');
        print('   Response: ${pageResponse.body}');
        return {
          'success': false,
          'error': 'HTTP ${pageResponse.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error getting page insights: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get user profile insights (for personal accounts)
  Future<Map<String, dynamic>> getUserInsights({
    required String accessToken,
  }) async {
    try {
      print('📊 Fetching user insights...');

      final response = await http.get(
        Uri.parse('$baseUrl/me?fields=id,name,friends&access_token=$accessToken'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final friendsCount = data['friends']?['summary']?['total_count'] ?? 0;

        return {
          'success': true,
          'followers': friendsCount,
          'postsCount': 0,
          'engagementRate': 0.0,
        };
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error getting user insights: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}

// ========== Models ==========

/// Facebook Page Model
class FacebookPage {
  final String id;
  final String name;
  final String accessToken;
  final String? category;

  FacebookPage({
    required this.id,
    required this.name,
    required this.accessToken,
    this.category,
  });

  factory FacebookPage.fromJson(Map<String, dynamic> json) {
    return FacebookPage(
      id: json['id'],
      name: json['name'],
      accessToken: json['access_token'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'access_token': accessToken,
      'category': category,
    };
  }
}
