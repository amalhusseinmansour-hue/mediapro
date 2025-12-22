import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart'; // معطل مؤقتاً
import 'social_accounts_service.dart';
import '../screens/auth/linkedin_oauth_screen.dart';
import '../screens/auth/twitter_oauth_screen.dart';
import '../screens/auth/tiktok_oauth_screen.dart';
import '../screens/auth/youtube_oauth_screen.dart';
import '../screens/auth/instagram_oauth_screen.dart';

/// خدمة OAuth للربط التلقائي مع حسابات التواصل الاجتماعي
class OAuthService extends GetxController {
  final RxBool isLoading = false.obs;

  // Get SocialAccountsService
  SocialAccountsService? get _socialAccountsService {
    try {
      return Get.find<SocialAccountsService>();
    } catch (e) {
      print('⚠️ SocialAccountsService not available: $e');
      return null;
    }
  }

  /// ربط حساب Facebook تلقائياً
  Future<bool> connectFacebook() async {
    try {
      isLoading.value = true;
      print('🔵 Starting Facebook OAuth...');

      // التحقق من تهيئة Facebook SDK
      // ملاحظة: يجب تكوين Facebook App ID أولاً في:
      // android/app/src/main/res/values/strings.xml
      // قم بالحصول على App ID من: https://developers.facebook.com/apps

      // طلب تسجيل الدخول - استخدام أذونات أساسية فقط
      // ملاحظة: pages_show_list و pages_read_engagement تحتاج App Review من Facebook
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile'],
      );

      if (result.status == LoginStatus.success) {
        // الحصول على بيانات المستخدم
        final userData = await FacebookAuth.instance.getUserData(
          fields: 'id,name,email,picture.width(200)',
        );

        print('✅ Facebook login successful!');
        print('📊 User data: $userData');

        // حفظ الحساب
        final account = await _socialAccountsService?.addAccount(
          platform: 'facebook',
          accountName: userData['name'] ?? 'Facebook User',
          accountId: userData['id'] ?? '',
          profileImageUrl: userData['picture']?['data']?['url'],
          accessToken: result.accessToken?.token,
          platformData: {
            'email': userData['email'],
            'connected_via': 'oauth',
            'permissions': result.accessToken?.grantedPermissions ?? [],
          },
        );

        if (account != null) {
          Get.snackbar(
            'تم بنجاح',
            'تم ربط حساب Facebook: ${userData['name']}',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
          );
          return true;
        }
      } else if (result.status == LoginStatus.cancelled) {
        print('⚠️ User cancelled Facebook login');
        Get.snackbar(
          'تم الإلغاء',
          'تم إلغاء عملية الربط',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        print('❌ Facebook login failed: ${result.status}');
        Get.snackbar(
          'فشل الربط',
          'حدث خطأ أثناء الربط مع Facebook',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

      return false;
    } catch (e) {
      print('❌ Facebook OAuth error: $e');

      // التحقق من نوع الخطأ
      String errorMessage = 'حدث خطأ: ${e.toString()}';
      if (e.toString().contains('SDK has not been initialized') ||
          e.toString().contains('MissingPluginException')) {
        errorMessage = 'يجب تكوين Facebook App ID أولاً\n\n'
            'الخطوات:\n'
            '1. قم بزيارة https://developers.facebook.com/apps\n'
            '2. أنشئ تطبيق جديد\n'
            '3. انسخ App ID\n'
            '4. ضعه في android/app/src/main/res/values/strings.xml';
      }

      Get.snackbar(
        'خطأ في تكوين Facebook',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 8),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ربط حساب Instagram Business تلقائياً عبر Facebook OAuth
  /// يتطلب حساب Instagram Business مرتبط بصفحة Facebook
  Future<bool> connectInstagram() async {
    try {
      isLoading.value = true;
      print('🔵 Starting Instagram Business OAuth...');

      // فتح شاشة Instagram OAuth (WebView)
      final result = await Get.to<Map<String, dynamic>>(
        () => const InstagramOAuthScreen(),
      );

      if (result != null && result['success'] == true) {
        print('✅ Instagram OAuth successful!');
        final data = result['data'];

        // حفظ الحساب
        final account = await _socialAccountsService?.addAccount(
          platform: 'instagram',
          accountName: '@${data['username']}',
          accountId: data['id']?.toString() ?? '',
          profileImageUrl: data['profile_picture_url'],
          accessToken: data['access_token'],
          platformData: {
            'ig_user_id': data['id'],
            'username': data['username'],
            'name': data['name'],
            'page_id': data['page_id'],
            'page_name': data['page_name'],
            'followers_count': data['followers_count'],
            'follows_count': data['follows_count'],
            'media_count': data['media_count'],
            'user_access_token': data['user_access_token'],
            'connected_via': 'oauth',
            'connected_at': DateTime.now().toIso8601String(),
          },
        );

        if (account != null) {
          Get.snackbar(
            'تم بنجاح',
            'تم ربط حساب Instagram: @${data['username']}',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
          );
          return true;
        }
      } else if (result != null && result['cancelled'] == true) {
        print('⚠️ User cancelled Instagram login');
        Get.snackbar(
          'تم الإلغاء',
          'تم إلغاء عملية الربط',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        print('❌ Instagram login failed');
        Get.snackbar(
          'فشل الربط',
          result?['error'] ?? 'حدث خطأ أثناء الربط مع Instagram\n\nتأكد من أن لديك حساب Instagram Business مرتبط بصفحة Facebook',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }

      return false;
    } catch (e) {
      print('❌ Instagram OAuth error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ربط حساب Twitter/X تلقائياً عبر OAuth
  Future<bool> connectTwitter() async {
    try {
      isLoading.value = true;
      print('🔵 Starting Twitter OAuth...');

      // فتح شاشة Twitter OAuth (WebView)
      final result = await Get.to<Map<String, dynamic>>(
        () => const TwitterOAuthScreen(),
      );

      if (result != null && result['success'] == true) {
        print('✅ Twitter OAuth successful!');
        final data = result['data'];

        // حفظ الحساب
        final account = await _socialAccountsService?.addAccount(
          platform: 'twitter',
          accountName: data['name'] ?? 'Twitter User',
          accountId: data['id']?.toString() ?? '',
          profileImageUrl: data['profile_image_url'],
          accessToken: data['access_token'],
          platformData: {
            'username': data['username'],
            'connected_via': 'oauth',
            'refresh_token': data['refresh_token'],
          },
        );

        if (account != null) {
          Get.snackbar(
            'تم بنجاح',
            'تم ربط حساب Twitter: @${data['username']}',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
          );
          return true;
        }
      } else if (result != null && result['cancelled'] == true) {
        print('⚠️ User cancelled Twitter login');
        Get.snackbar(
          'تم الإلغاء',
          'تم إلغاء عملية الربط',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        print('❌ Twitter login failed');
        Get.snackbar(
          'فشل الربط',
          result?['error'] ?? 'حدث خطأ أثناء الربط مع Twitter',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

      return false;
    } catch (e) {
      print('❌ Twitter OAuth error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ربط حساب LinkedIn تلقائياً عبر OAuth
  Future<bool> connectLinkedIn() async {
    try {
      isLoading.value = true;
      print('🔵 Starting LinkedIn OAuth...');

      // فتح شاشة LinkedIn OAuth
      final result = await Get.to<Map<String, dynamic>>(
        () => const LinkedInOAuthScreen(),
      );

      if (result != null && result['success'] == true) {
        print('✅ LinkedIn OAuth successful!');

        // حفظ الحساب
        final account = await _socialAccountsService?.addAccount(
          platform: 'linkedin',
          accountName: result['name'] ?? 'LinkedIn User',
          accountId: result['id'] ?? '',
          profileImageUrl: result['picture'],
          accessToken: result['access_token'],
          platformData: {
            'email': result['email'],
            'connected_via': 'oauth',
            'vanity_name': result['vanity_name'],
          },
        );

        if (account != null) {
          Get.snackbar(
            'تم بنجاح',
            'تم ربط حساب LinkedIn: ${result['name']}',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
          );
          return true;
        }
      } else if (result != null && result['cancelled'] == true) {
        print('⚠️ User cancelled LinkedIn login');
        Get.snackbar(
          'تم الإلغاء',
          'تم إلغاء عملية الربط',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        print('❌ LinkedIn login failed');
        Get.snackbar(
          'فشل الربط',
          result?['error'] ?? 'حدث خطأ أثناء الربط مع LinkedIn',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

      return false;
    } catch (e) {
      print('❌ LinkedIn OAuth error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ربط حساب YouTube تلقائياً عبر WebView OAuth
  Future<bool> connectYouTube() async {
    try {
      isLoading.value = true;
      print('🔵 Starting YouTube OAuth via WebView...');

      // فتح شاشة OAuth WebView
      final result = await Get.to<Map<String, dynamic>>(
        () => const YouTubeOAuthScreen(),
      );

      if (result != null && result['success'] == true) {
        final data = result['data'];
        print('✅ YouTube OAuth successful!');
        print('📊 Channel: ${data['name']}');

        // حفظ الحساب
        final socialAccount = await _socialAccountsService?.addAccount(
          platform: 'youtube',
          accountName: data['name'] ?? data['channel_title'] ?? 'YouTube Channel',
          accountId: data['channel_id']?.toString() ?? data['id']?.toString() ?? '',
          profileImageUrl: data['picture'],
          accessToken: data['access_token'],
          platformData: {
            'channel_id': data['channel_id'],
            'email': data['email'],
            'channel_title': data['channel_title'],
            'channel_description': data['channel_description'],
            'custom_url': data['custom_url'],
            'subscriber_count': data['subscriber_count'],
            'video_count': data['video_count'],
            'view_count': data['view_count'],
            'refresh_token': data['refresh_token'],
            'connected_via': 'oauth_webview',
            'connected_at': DateTime.now().toIso8601String(),
          },
        );

        if (socialAccount != null) {
          Get.snackbar(
            'تم بنجاح',
            'تم ربط قناة YouTube: ${data['name'] ?? data['channel_title']}',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
          );
          return true;
        }
      } else if (result != null && result['cancelled'] == true) {
        print('⚠️ User cancelled YouTube OAuth');
        Get.snackbar(
          'تم الإلغاء',
          'تم إلغاء عملية الربط',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else if (result != null && result['error'] != null) {
        throw Exception(result['error']);
      }

      return false;
    } catch (e) {
      print('❌ YouTube OAuth error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ربط حساب TikTok تلقائياً عبر WebView OAuth
  Future<bool> connectTikTok() async {
    try {
      isLoading.value = true;
      print('🔵 Starting TikTok OAuth...');

      // فتح شاشة OAuth عبر WebView
      final result = await Get.to<Map<String, dynamic>>(
        () => const TikTokOAuthScreen(),
      );

      if (result != null && result['success'] == true) {
        final data = result['data'];

        // حفظ الحساب في قاعدة البيانات المحلية
        final account = await _socialAccountsService?.addAccount(
          platform: 'tiktok',
          accountName: data['name'] ?? 'TikTok User',
          accountId: data['open_id']?.toString() ?? data['id']?.toString() ?? '',
          profileImageUrl: data['avatar_url'],
          accessToken: data['access_token'],
          platformData: {
            'open_id': data['open_id'],
            'username': data['username'],
            'bio': data['bio'],
            'follower_count': data['follower_count'],
            'following_count': data['following_count'],
            'likes_count': data['likes_count'],
            'video_count': data['video_count'],
            'is_verified': data['is_verified'],
            'profile_url': data['profile_url'],
            'connected_via': 'oauth',
            'refresh_token': data['refresh_token'],
          },
        );

        if (account != null) {
          Get.snackbar(
            'تم بنجاح',
            'تم ربط حساب TikTok: ${data['name']}',
            backgroundColor: Colors.black,
            colorText: Colors.white,
            icon: const Icon(Icons.music_note, color: Color(0xFF00F2EA)),
          );
          return true;
        }
      } else if (result != null && result['cancelled'] == true) {
        print('⚠️ User cancelled TikTok login');
        Get.snackbar(
          'تم الإلغاء',
          'تم إلغاء عملية الربط',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else if (result != null && result['error'] != null) {
        print('❌ TikTok OAuth error: ${result['error']}');
        Get.snackbar(
          'فشل الربط',
          result['error'].toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

      return false;
    } catch (e) {
      print('❌ TikTok OAuth error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء الربط: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ربط حساب Snapchat تلقائياً
  Future<bool> connectSnapchat() async {
    try {
      isLoading.value = true;
      print('🔵 Starting Snapchat OAuth...');

      // Snapchat يتطلب WebView OAuth
      Get.snackbar(
        'قريباً',
        'ربط Snapchat سيتوفر قريباً عبر WebView OAuth',
        backgroundColor: Colors.yellow,
        colorText: Colors.black,
      );

      return false;
    } catch (e) {
      print('❌ Snapchat OAuth error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// تسجيل خروج من منصة معينة
  Future<void> disconnectPlatform(String platform) async {
    try {
      switch (platform.toLowerCase()) {
        case 'facebook':
        case 'instagram':
          await FacebookAuth.instance.logOut();
          break;
        case 'youtube':
          final googleSignIn = GoogleSignIn();
          await googleSignIn.signOut();
          break;
        default:
          print('⚠️ No logout method for platform: $platform');
      }
    } catch (e) {
      print('❌ Error disconnecting platform $platform: $e');
    }
  }
}
