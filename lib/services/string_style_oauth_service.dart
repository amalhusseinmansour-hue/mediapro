import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'api_service.dart';
import 'social_accounts_service.dart';

/// OAuth Service - String-style implementation
/// Direct OAuth redirect like String app in Saudi Arabia
class StringStyleOAuthService extends GetxController {
  final RxBool isConnecting = false.obs;
  final RxString currentPlatform = ''.obs;

  final ApiService _apiService = ApiService();

  SocialAccountsService? get _socialAccountsService {
    try {
      return Get.find<SocialAccountsService>();
    } catch (e) {
      print('⚠️ SocialAccountsService not available');
      return null;
    }
  }

  // App links instance
  late AppLinks _appLinks;
  StreamSubscription? _deepLinkSubscription;

  @override
  void onInit() {
    super.onInit();
    _initDeepLinkListener();
  }

  @override
  void onClose() {
    _deepLinkSubscription?.cancel();
    super.onClose();
  }

  /// Initialize deep link listener for OAuth callbacks
  void _initDeepLinkListener() {
    try {
      _appLinks = AppLinks();

      // Listen to deep links
      _deepLinkSubscription = _appLinks.uriLinkStream.listen(
        (Uri? uri) {
          if (uri != null) {
            _handleDeepLink(uri.toString());
          }
        },
        onError: (err) {
          print('❌ Deep link error: $err');
        },
      );

      // Check initial link (when app is opened from deep link)
      _appLinks.getInitialLink().then((Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri.toString());
        }
      });
    } catch (e) {
      print('❌ Failed to initialize deep link listener: $e');
    }
  }

  /// Handle deep link callback from OAuth
  Future<void> _handleDeepLink(String link) async {
    print('🔗 Received deep link: $link');

    try {
      // Parse deep link: socialmediamanager://oauth/callback?success=true&platform=instagram&...
      final uri = Uri.parse(link);

      if (uri.scheme == 'socialmediamanager' &&
          uri.host == 'oauth' &&
          uri.path == '/callback') {
        final success = uri.queryParameters['success'] == 'true';
        final platform = uri.queryParameters['platform'] ?? '';
        final message = uri.queryParameters['message'] ?? '';
        // final accountId = uri.queryParameters['account_id']; // Future use
        final username = uri.queryParameters['username'];

        isConnecting.value = false;
        currentPlatform.value = '';

        if (success) {
          // Reload accounts from backend
          await _socialAccountsService?.loadAccounts();

          Get.snackbar(
            'تم الربط بنجاح',
            'تم ربط حساب $platform: ${username ?? ""}',
            backgroundColor: Colors.green.withValues(alpha: 0.9),
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar(
            'فشل الربط',
            message.isNotEmpty ? message : 'حدث خطأ أثناء ربط الحساب',
            backgroundColor: Colors.red.withValues(alpha: 0.9),
            colorText: Colors.white,
            icon: const Icon(Icons.error, color: Colors.white),
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      print('❌ Error handling deep link: $e');
    }
  }

  /// Connect social media account (String-style)
  /// - Fetches OAuth URL from backend
  /// - Opens in browser/webview
  /// - Returns via deep link
  Future<bool> connectPlatform(String platform) async {
    try {
      if (isConnecting.value) {
        Get.snackbar(
          'تنبيه',
          'جاري الربط مع منصة أخرى، الرجاء الانتظار',
          backgroundColor: Colors.orange.withValues(alpha: 0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      isConnecting.value = true;
      currentPlatform.value = platform;

      print('🔵 Starting OAuth for $platform (String-style)');

      // Step 1: Get OAuth redirect URL from backend
      final response = await _apiService.getOAuthRedirectUrl(platform);

      if (response['success'] != true || response['redirect_url'] == null) {
        throw Exception(response['message'] ?? 'فشل الحصول على رابط OAuth');
      }

      final redirectUrl = response['redirect_url'] as String;
      print('✅ Got OAuth URL: $redirectUrl');

      // Step 2: Open OAuth URL in browser
      final uri = Uri.parse(redirectUrl);

      if (await canLaunchUrl(uri)) {
        // Launch in external browser (recommended for OAuth security)
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        print('✅ Opened OAuth page for $platform');

        // Show loading dialog
        Get.dialog(
          PopScope(
            canPop: true,
            onPopInvokedWithResult: (bool didPop, dynamic result) {
              if (didPop) {
                isConnecting.value = false;
                currentPlatform.value = '';
              }
            },
            child: AlertDialog(
              backgroundColor: const Color(0xFF1E1E2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: _getPlatformColor(platform)),
                  const SizedBox(height: 20),
                  Text(
                    'جاري الربط مع ${_getPlatformName(platform)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'الرجاء إكمال عملية الربط في المتصفح',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      isConnecting.value = false;
                      currentPlatform.value = '';
                    },
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );

        // Set timeout for OAuth process (2 minutes)
        Future.delayed(const Duration(minutes: 2), () {
          if (isConnecting.value && currentPlatform.value == platform) {
            isConnecting.value = false;
            currentPlatform.value = '';
            if (Get.isDialogOpen == true) {
              Get.back();
            }
            Get.snackbar(
              'انتهت المهلة',
              'انتهت مهلة عملية الربط',
              backgroundColor: Colors.orange.withValues(alpha: 0.9),
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        });

        return true;
      } else {
        throw Exception('لا يمكن فتح رابط OAuth');
      }
    } catch (e) {
      print('❌ OAuth error for $platform: $e');

      isConnecting.value = false;
      currentPlatform.value = '';

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.snackbar(
        'خطأ في الربط',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    }
  }

  /// Get platform display name in Arabic
  String _getPlatformName(String platform) {
    return {
          'instagram': 'إنستغرام',
          'facebook': 'فيسبوك',
          'twitter': 'تويتر (X)',
          'linkedin': 'لينكد إن',
          'tiktok': 'تيك توك',
          'youtube': 'يوتيوب',
          'snapchat': 'سناب شات',
        }[platform.toLowerCase()] ??
        platform;
  }

  /// Get platform color
  Color _getPlatformColor(String platform) {
    return {
          'instagram': const Color(0xFFE4405F),
          'facebook': const Color(0xFF1877F2),
          'twitter': const Color(0xFF1DA1F2),
          'linkedin': const Color(0xFF0A66C2),
          'tiktok': Colors.black,
          'youtube': const Color(0xFFFF0000),
          'snapchat': const Color(0xFFFFFC00),
        }[platform.toLowerCase()] ??
        Colors.blue;
  }

  /// Disconnect platform
  Future<bool> disconnectPlatform(String accountId) async {
    try {
      final service = _socialAccountsService;
      if (service == null) return false;

      final success = await service.deleteAccount(accountId);

      if (success) {
        Get.snackbar(
          'تم بنجاح',
          'تم فك ربط الحساب',
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      return success;
    } catch (e) {
      print('❌ Error disconnecting: $e');
      return false;
    }
  }
}
