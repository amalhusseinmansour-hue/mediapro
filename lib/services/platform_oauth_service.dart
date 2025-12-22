import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'oauth_service.dart';
import 'web_oauth_service.dart' if (dart.library.io) 'oauth_service.dart';

/// Platform-aware OAuth Service
/// يستخدم WebOAuthService على الويب و OAuthService على الموبايل
class PlatformOAuthService extends GetxController {
  late final dynamic _oauthService;

  @override
  void onInit() {
    super.onInit();

    // اختيار الخدمة المناسبة حسب المنصة
    if (kIsWeb) {
      // على الويب، استخدم WebOAuthService
      try {
        _oauthService = Get.find<WebOAuthService>();
      } catch (e) {
        _oauthService = Get.put(WebOAuthService());
      }
      print('✅ Using WebOAuthService for Web platform');
    } else {
      // على الموبايل، استخدم OAuthService الأصلي
      try {
        _oauthService = Get.find<OAuthService>();
      } catch (e) {
        _oauthService = Get.put(OAuthService());
      }
      print('✅ Using OAuthService for Mobile platform');
    }
  }

  /// ربط حساب Facebook
  Future<bool> connectFacebook() async {
    return await _oauthService.connectFacebook();
  }

  /// ربط حساب Instagram
  Future<bool> connectInstagram() async {
    return await _oauthService.connectInstagram();
  }

  /// ربط حساب Twitter/X
  Future<bool> connectTwitter() async {
    return await _oauthService.connectTwitter();
  }

  /// ربط حساب LinkedIn
  Future<bool> connectLinkedIn() async {
    return await _oauthService.connectLinkedIn();
  }

  /// ربط حساب YouTube
  Future<bool> connectYouTube() async {
    return await _oauthService.connectYouTube();
  }

  /// ربط حساب TikTok
  Future<bool> connectTikTok() async {
    return await _oauthService.connectTikTok();
  }

  /// ربط حساب Snapchat
  Future<bool> connectSnapchat() async {
    if (_oauthService is OAuthService) {
      return await _oauthService.connectSnapchat();
    }
    return false;
  }

  /// تسجيل خروج من منصة معينة
  Future<void> disconnectPlatform(String platform) async {
    if (_oauthService is OAuthService) {
      await _oauthService.disconnectPlatform(platform);
    }
  }

  /// حالة التحميل
  bool get isLoading => _oauthService.isLoading.value;
}
