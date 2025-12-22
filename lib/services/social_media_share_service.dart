import 'dart:io';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_meta_sdk/flutter_meta_sdk.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

/// Social Media Share Service
/// خدمة موحدة للمشاركة على منصات السوشال ميديا مع دعم Meta SDK
class SocialMediaShareService extends GetxService {
  final RxBool isSharing = false.obs;
  final RxString lastError = ''.obs;
  final RxBool isMetaSdkInitialized = false.obs;

  // Facebook Auth State
  final Rx<AccessToken?> facebookAccessToken = Rx<AccessToken?>(null);
  final RxBool isFacebookLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('📱 Social Media Share Service initialized');
    _initMetaSdk();
    _checkFacebookLoginStatus();
  }

  // Meta SDK instance
  final FlutterMetaSdk _metaSdk = FlutterMetaSdk();

  /// Initialize Meta SDK
  Future<void> _initMetaSdk() async {
    try {
      // Activate app for Meta SDK
      await _metaSdk.activateApp();
      isMetaSdkInitialized.value = true;
      print('✅ Meta SDK initialized successfully');

      // Get SDK version for logging
      final version = await _metaSdk.getSdkVersion();
      print('📱 Meta SDK Version: $version');
    } catch (e) {
      print('⚠️ Meta SDK initialization error: $e');
    }
  }

  /// Log Meta App Event
  Future<void> logMetaEvent(String eventName, {Map<String, dynamic>? parameters, double? valueToSum}) async {
    try {
      if (!isMetaSdkInitialized.value) return;

      await _metaSdk.logEvent(
        name: eventName,
        parameters: parameters,
        valueToSum: valueToSum,
      );
      print('📊 Meta event logged: $eventName');
    } catch (e) {
      print('⚠️ Meta event error: $e');
    }
  }

  /// Log Purchase Event for Meta
  Future<void> logMetaPurchase(double amount, String currency, {Map<String, dynamic>? parameters}) async {
    try {
      if (!isMetaSdkInitialized.value) return;

      await _metaSdk.logPurchase(
        amount: amount,
        currency: currency,
        parameters: parameters,
      );
      print('💰 Meta purchase logged: $amount $currency');
    } catch (e) {
      print('⚠️ Meta purchase error: $e');
    }
  }

  /// Log Completed Registration
  Future<void> logMetaRegistration({String? registrationMethod}) async {
    try {
      if (!isMetaSdkInitialized.value) return;
      await _metaSdk.logCompletedRegistration(registrationMethod: registrationMethod);
      print('📝 Meta registration logged');
    } catch (e) {
      print('⚠️ Meta registration error: $e');
    }
  }

  /// Log View Content
  Future<void> logMetaViewContent({String? contentId, String? contentType, double? price, String? currency}) async {
    try {
      if (!isMetaSdkInitialized.value) return;
      await _metaSdk.logViewContent(
        id: contentId,
        type: contentType,
        price: price,
        currency: currency,
      );
      print('👁️ Meta view content logged');
    } catch (e) {
      print('⚠️ Meta view content error: $e');
    }
  }

  /// Log Add to Cart
  Future<void> logMetaAddToCart({required String id, required String type, required double price, required String currency}) async {
    try {
      if (!isMetaSdkInitialized.value) return;
      await _metaSdk.logAddToCart(
        id: id,
        type: type,
        price: price,
        currency: currency,
      );
      print('🛒 Meta add to cart logged');
    } catch (e) {
      print('⚠️ Meta add to cart error: $e');
    }
  }

  /// Set User ID for Meta
  Future<void> setMetaUserId(String userId) async {
    try {
      await _metaSdk.setUserID(userId);
      print('👤 Meta user ID set: $userId');
    } catch (e) {
      print('⚠️ Meta set user ID error: $e');
    }
  }

  /// Set User Data for Meta
  Future<void> setMetaUserData({String? email, String? firstName, String? lastName, String? phone}) async {
    try {
      await _metaSdk.setUserData(
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      print('📋 Meta user data set');
    } catch (e) {
      print('⚠️ Meta set user data error: $e');
    }
  }

  /// Check Facebook Login Status
  Future<void> _checkFacebookLoginStatus() async {
    try {
      final accessToken = await FacebookAuth.instance.accessToken;
      if (accessToken != null && !accessToken.isExpired) {
        facebookAccessToken.value = accessToken;
        isFacebookLoggedIn.value = true;
        print('✅ Facebook: User already logged in');
      }
    } catch (e) {
      print('⚠️ Facebook check error: $e');
    }
  }

  /// ============== Facebook Integration ==============

  /// Login with Facebook
  Future<Map<String, dynamic>?> loginWithFacebook() async {
    try {
      isSharing.value = true;
      lastError.value = '';

      final LoginResult result = await FacebookAuth.instance.login(
        permissions: [
          'public_profile',
          'email',
          'pages_show_list',
          'pages_read_engagement',
          'pages_manage_posts',
          'instagram_basic',
          'instagram_content_publish',
        ],
      );

      if (result.status == LoginStatus.success) {
        facebookAccessToken.value = result.accessToken;
        isFacebookLoggedIn.value = true;

        final userData = await FacebookAuth.instance.getUserData();
        print('✅ Facebook login success: ${userData['name']}');

        return userData;
      } else if (result.status == LoginStatus.cancelled) {
        lastError.value = 'تم إلغاء تسجيل الدخول';
        return null;
      } else {
        lastError.value = result.message ?? 'فشل تسجيل الدخول';
        return null;
      }
    } catch (e) {
      lastError.value = e.toString();
      print('❌ Facebook login error: $e');
      return null;
    } finally {
      isSharing.value = false;
    }
  }

  /// Logout from Facebook
  Future<void> logoutFromFacebook() async {
    try {
      await FacebookAuth.instance.logOut();
      facebookAccessToken.value = null;
      isFacebookLoggedIn.value = false;
      print('✅ Facebook logout success');
    } catch (e) {
      print('❌ Facebook logout error: $e');
    }
  }

  /// Share to Facebook via URL
  Future<bool> shareToFacebook({
    required String message,
    String? url,
  }) async {
    try {
      isSharing.value = true;
      lastError.value = '';

      final encodedMessage = Uri.encodeComponent(message);
      final encodedUrl = url != null ? Uri.encodeComponent(url) : '';

      // Try Facebook app first
      final facebookAppUrl = Uri.parse('fb://share?quote=$encodedMessage');
      if (await canLaunchUrl(facebookAppUrl)) {
        await launchUrl(facebookAppUrl, mode: LaunchMode.externalApplication);
        return true;
      }

      // Fallback to web share
      final webUrl = 'https://www.facebook.com/sharer/sharer.php?quote=$encodedMessage&u=$encodedUrl';
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
      return true;
    } catch (e) {
      lastError.value = e.toString();
      print('❌ Facebook share error: $e');
      return false;
    } finally {
      isSharing.value = false;
    }
  }

  /// ============== Instagram Integration ==============

  /// Share to Instagram (opens Instagram with content)
  Future<bool> shareToInstagram({
    required String message,
    String? imagePath,
  }) async {
    try {
      isSharing.value = true;
      lastError.value = '';

      // Instagram doesn't have direct sharing API
      // We can only open the app
      final instagramUrl = Uri.parse('instagram://');
      if (await canLaunchUrl(instagramUrl)) {
        await launchUrl(instagramUrl, mode: LaunchMode.externalApplication);

        // Copy message to clipboard for user to paste
        if (message.isNotEmpty) {
          // Use share_plus to share if we have an image
          if (imagePath != null && File(imagePath).existsSync()) {
            await Share.shareXFiles(
              [XFile(imagePath)],
              text: message,
            );
          }
        }
        return true;
      }

      // Fallback to web
      await launchUrl(
        Uri.parse('https://www.instagram.com'),
        mode: LaunchMode.externalApplication,
      );
      return true;
    } catch (e) {
      lastError.value = e.toString();
      print('❌ Instagram share error: $e');
      return false;
    } finally {
      isSharing.value = false;
    }
  }

  /// ============== WhatsApp Integration ==============

  /// Share to WhatsApp
  Future<bool> shareToWhatsApp({
    required String message,
    String? phoneNumber,
  }) async {
    try {
      isSharing.value = true;
      lastError.value = '';

      final encodedMessage = Uri.encodeComponent(message);

      Uri whatsappUrl;
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        // Direct message to specific number
        whatsappUrl = Uri.parse('whatsapp://send?phone=$phoneNumber&text=$encodedMessage');
      } else {
        // Share without specific number
        whatsappUrl = Uri.parse('whatsapp://send?text=$encodedMessage');
      }

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        return true;
      }

      // Fallback to web
      if (phoneNumber != null) {
        await launchUrl(
          Uri.parse('https://wa.me/$phoneNumber?text=$encodedMessage'),
          mode: LaunchMode.externalApplication,
        );
      } else {
        await launchUrl(
          Uri.parse('https://wa.me/?text=$encodedMessage'),
          mode: LaunchMode.externalApplication,
        );
      }
      return true;
    } catch (e) {
      lastError.value = e.toString();
      print('❌ WhatsApp share error: $e');
      return false;
    } finally {
      isSharing.value = false;
    }
  }

  /// ============== Twitter/X Integration ==============

  /// Share to Twitter
  Future<bool> shareToTwitter({
    required String message,
    String? url,
  }) async {
    try {
      isSharing.value = true;
      lastError.value = '';

      final encodedMessage = Uri.encodeComponent(message);
      final encodedUrl = url != null ? Uri.encodeComponent(url) : '';

      // Try Twitter app
      final twitterAppUrl = Uri.parse('twitter://post?message=$encodedMessage');
      if (await canLaunchUrl(twitterAppUrl)) {
        await launchUrl(twitterAppUrl, mode: LaunchMode.externalApplication);
        return true;
      }

      // Fallback to web intent
      final webUrl = 'https://twitter.com/intent/tweet?text=$encodedMessage&url=$encodedUrl';
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
      return true;
    } catch (e) {
      lastError.value = e.toString();
      print('❌ Twitter share error: $e');
      return false;
    } finally {
      isSharing.value = false;
    }
  }

  /// ============== Telegram Integration ==============

  /// Share to Telegram
  Future<bool> shareToTelegram({
    required String message,
    String? url,
  }) async {
    try {
      isSharing.value = true;
      lastError.value = '';

      final encodedMessage = Uri.encodeComponent(message);
      final encodedUrl = url != null ? Uri.encodeComponent(url) : '';

      // Try Telegram app
      final telegramUrl = Uri.parse('tg://msg?text=$encodedMessage');
      if (await canLaunchUrl(telegramUrl)) {
        await launchUrl(telegramUrl, mode: LaunchMode.externalApplication);
        return true;
      }

      // Fallback to web
      await launchUrl(
        Uri.parse('https://t.me/share/url?url=$encodedUrl&text=$encodedMessage'),
        mode: LaunchMode.externalApplication,
      );
      return true;
    } catch (e) {
      lastError.value = e.toString();
      print('❌ Telegram share error: $e');
      return false;
    } finally {
      isSharing.value = false;
    }
  }

  /// ============== TikTok Integration ==============

  /// Open TikTok App
  Future<bool> openTikTok() async {
    try {
      final tiktokUrl = Uri.parse('tiktok://');
      if (await canLaunchUrl(tiktokUrl)) {
        await launchUrl(tiktokUrl, mode: LaunchMode.externalApplication);
        return true;
      }
      // Fallback to web
      await launchUrl(
        Uri.parse('https://www.tiktok.com'),
        mode: LaunchMode.externalApplication,
      );
      return true;
    } catch (e) {
      lastError.value = e.toString();
      return false;
    }
  }

  /// ============== Snapchat Integration ==============

  /// Open Snapchat App
  Future<bool> openSnapchat() async {
    try {
      final snapchatUrl = Uri.parse('snapchat://');
      if (await canLaunchUrl(snapchatUrl)) {
        await launchUrl(snapchatUrl, mode: LaunchMode.externalApplication);
        return true;
      }
      // Fallback to web
      await launchUrl(
        Uri.parse('https://www.snapchat.com'),
        mode: LaunchMode.externalApplication,
      );
      return true;
    } catch (e) {
      lastError.value = e.toString();
      return false;
    }
  }

  /// ============== LinkedIn Integration ==============

  /// Share to LinkedIn
  Future<bool> shareToLinkedIn({
    required String message,
    String? url,
  }) async {
    try {
      isSharing.value = true;

      final encodedMessage = Uri.encodeComponent(message);
      final encodedUrl = url != null ? Uri.encodeComponent(url) : '';

      final linkedInUrl = 'https://www.linkedin.com/shareArticle?mini=true&url=$encodedUrl&title=$encodedMessage';

      await launchUrl(
        Uri.parse(linkedInUrl),
        mode: LaunchMode.externalApplication,
      );

      print('✅ LinkedIn share initiated');
      return true;
    } catch (e) {
      lastError.value = e.toString();
      print('❌ LinkedIn share error: $e');
      return false;
    } finally {
      isSharing.value = false;
    }
  }

  /// ============== System Share ==============

  /// Share using system share dialog
  Future<bool> shareToSystem({
    required String message,
    String? imagePath,
    String? subject,
  }) async {
    try {
      isSharing.value = true;

      if (imagePath != null && File(imagePath).existsSync()) {
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: message,
          subject: subject,
        );
      } else {
        await Share.share(
          message,
          subject: subject,
        );
      }

      return true;
    } catch (e) {
      lastError.value = e.toString();
      print('❌ System share error: $e');
      return false;
    } finally {
      isSharing.value = false;
    }
  }

  /// Share with files
  Future<bool> shareWithFiles({
    required String message,
    required List<String> filePaths,
    String? subject,
  }) async {
    try {
      isSharing.value = true;

      final xFiles = filePaths
          .where((path) => File(path).existsSync())
          .map((path) => XFile(path))
          .toList();

      if (xFiles.isNotEmpty) {
        await Share.shareXFiles(
          xFiles,
          text: message,
          subject: subject,
        );
        return true;
      } else {
        await Share.share(message, subject: subject);
        return true;
      }
    } catch (e) {
      lastError.value = e.toString();
      print('❌ Share with files error: $e');
      return false;
    } finally {
      isSharing.value = false;
    }
  }

  /// ============== Helper Methods ==============

  /// Get list of available platforms
  List<SocialPlatform> getAvailablePlatforms() {
    return [
      SocialPlatform(
        name: 'Instagram',
        icon: 'instagram',
        color: 0xFFE1306C,
        isAvailable: true,
      ),
      SocialPlatform(
        name: 'Facebook',
        icon: 'facebook',
        color: 0xFF1877F2,
        isAvailable: true,
      ),
      SocialPlatform(
        name: 'Twitter',
        icon: 'twitter',
        color: 0xFF1DA1F2,
        isAvailable: true,
      ),
      SocialPlatform(
        name: 'WhatsApp',
        icon: 'whatsapp',
        color: 0xFF25D366,
        isAvailable: true,
      ),
      SocialPlatform(
        name: 'Telegram',
        icon: 'telegram',
        color: 0xFF0088CC,
        isAvailable: true,
      ),
      SocialPlatform(
        name: 'TikTok',
        icon: 'tiktok',
        color: 0xFF000000,
        isAvailable: true,
      ),
      SocialPlatform(
        name: 'Snapchat',
        icon: 'snapchat',
        color: 0xFFFFFC00,
        isAvailable: true,
      ),
      SocialPlatform(
        name: 'LinkedIn',
        icon: 'linkedin',
        color: 0xFF0A66C2,
        isAvailable: true,
      ),
    ];
  }

  /// Share to multiple platforms
  Future<Map<String, bool>> shareToMultiplePlatforms({
    required String message,
    required List<String> platforms,
    String? imagePath,
    String? url,
  }) async {
    final results = <String, bool>{};

    for (final platform in platforms) {
      switch (platform.toLowerCase()) {
        case 'instagram':
          results['instagram'] = await shareToInstagram(message: message, imagePath: imagePath);
          break;
        case 'facebook':
          results['facebook'] = await shareToFacebook(message: message, url: url);
          break;
        case 'twitter':
          results['twitter'] = await shareToTwitter(message: message, url: url);
          break;
        case 'whatsapp':
          results['whatsapp'] = await shareToWhatsApp(message: message);
          break;
        case 'telegram':
          results['telegram'] = await shareToTelegram(message: message, url: url);
          break;
        case 'linkedin':
          results['linkedin'] = await shareToLinkedIn(message: message, url: url);
          break;
        case 'tiktok':
          results['tiktok'] = await openTikTok();
          break;
        case 'snapchat':
          results['snapchat'] = await openSnapchat();
          break;
      }

      // Small delay between shares
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return results;
  }

  /// Open platform app directly
  Future<bool> openPlatformApp(String platform) async {
    try {
      String scheme;
      String webFallback;

      switch (platform.toLowerCase()) {
        case 'instagram':
          scheme = 'instagram://';
          webFallback = 'https://www.instagram.com';
          break;
        case 'facebook':
          scheme = 'fb://';
          webFallback = 'https://www.facebook.com';
          break;
        case 'twitter':
          scheme = 'twitter://';
          webFallback = 'https://twitter.com';
          break;
        case 'whatsapp':
          scheme = 'whatsapp://';
          webFallback = 'https://www.whatsapp.com';
          break;
        case 'telegram':
          scheme = 'tg://';
          webFallback = 'https://telegram.org';
          break;
        case 'tiktok':
          scheme = 'tiktok://';
          webFallback = 'https://www.tiktok.com';
          break;
        case 'snapchat':
          scheme = 'snapchat://';
          webFallback = 'https://www.snapchat.com';
          break;
        case 'linkedin':
          scheme = 'linkedin://';
          webFallback = 'https://www.linkedin.com';
          break;
        case 'youtube':
          scheme = 'youtube://';
          webFallback = 'https://www.youtube.com';
          break;
        default:
          return false;
      }

      final appUrl = Uri.parse(scheme);
      if (await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl, mode: LaunchMode.externalApplication);
        return true;
      }

      await launchUrl(Uri.parse(webFallback), mode: LaunchMode.externalApplication);
      return true;
    } catch (e) {
      print('❌ Error opening $platform: $e');
      return false;
    }
  }
}

/// Social Platform Model
class SocialPlatform {
  final String name;
  final String icon;
  final int color;
  final bool isAvailable;

  SocialPlatform({
    required this.name,
    required this.icon,
    required this.color,
    required this.isAvailable,
  });
}
