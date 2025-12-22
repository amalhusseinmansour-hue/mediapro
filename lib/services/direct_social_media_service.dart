import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'social_accounts_service.dart';

/// Direct Social Media Integration Service
/// Opens social media apps directly for connection and sharing
class DirectSocialMediaService extends GetxController {
  final SocialAccountsService _accountsService = Get.find<SocialAccountsService>();

  // ========== Platform Deep Links ==========

  /// Deep link URLs for each social media platform
  static const Map<String, String> _platformAppUrls = {
    'instagram': 'instagram://user?username=',
    'facebook': 'fb://profile',
    'twitter': 'twitter://user?screen_name=',
    'x': 'twitter://user?screen_name=',
    'tiktok': 'tiktok://@',
    'youtube': 'youtube://user/',
    'linkedin': 'linkedin://profile/',
    'threads': 'instagram://user?username=', // Threads uses Instagram deep link
  };

  /// Web fallback URLs for platforms
  static const Map<String, String> _platformWebUrls = {
    'instagram': 'https://www.instagram.com/',
    'facebook': 'https://www.facebook.com/',
    'twitter': 'https://twitter.com/',
    'x': 'https://x.com/',
    'tiktok': 'https://www.tiktok.com/@',
    'youtube': 'https://www.youtube.com/',
    'linkedin': 'https://www.linkedin.com/',
    'threads': 'https://www.threads.net/',
  };

  // ========== Open Social Media App ==========

  /// Open social media app for connection/login
  Future<bool> openPlatformApp(String platform) async {
    try {
      print('📱 Opening ${platform} app...');

      final appUrl = _platformAppUrls[platform.toLowerCase()];
      final webUrl = _platformWebUrls[platform.toLowerCase()];

      if (appUrl == null || webUrl == null) {
        print('❌ Platform $platform not supported');
        Get.snackbar(
          'خطأ',
          'المنصة $platform غير مدعومة حالياً',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return false;
      }

      // Try to launch app deep link first
      final appUri = Uri.parse(appUrl);
      final canLaunchApp = await canLaunchUrl(appUri);

      if (canLaunchApp) {
        print('✅ Launching ${platform} app');
        final launched = await launchUrl(
          appUri,
          mode: LaunchMode.externalApplication,
        );

        if (launched) {
          // Show success message and ask user to return after connection
          await Future.delayed(const Duration(milliseconds: 500));
          _showConnectionInstructions(platform);
          return true;
        }
      }

      // Fallback to web browser
      print('⚠️ App not installed, opening web browser');
      final webUri = Uri.parse(webUrl);
      final launched = await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        await Future.delayed(const Duration(milliseconds: 500));
        _showConnectionInstructions(platform);
        return true;
      }

      throw Exception('Failed to open $platform');
    } catch (e) {
      print('❌ Error opening ${platform} app: $e');
      Get.snackbar(
        'خطأ',
        'فشل فتح تطبيق $platform: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// Show instructions after opening social media app
  void _showConnectionInstructions(String platform) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 12),
            Text(
              'تعليمات الربط',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تم فتح تطبيق $platform',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '1. سجل دخول لحسابك في التطبيق\n'
              '2. تأكد من اسم المستخدم الخاص بك\n'
              '3. ارجع لهذا التطبيق\n'
              '4. أدخل اسم المستخدم لإكمال الربط',
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              _showManualEntryDialog(platform);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'إدخال اسم المستخدم',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Show manual entry dialog after user returns from social media app
  void _showManualEntryDialog(String platform) {
    final TextEditingController usernameController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: Text(
          'ربط حساب $platform',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'اسم المستخدم',
                hintText: '@username',
                labelStyle: const TextStyle(color: Colors.white70),
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              final username = usernameController.text.trim();
              if (username.isEmpty) {
                Get.snackbar(
                  'خطأ',
                  'يرجى إدخال اسم المستخدم',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              Get.back(); // Close dialog

              // Add account to local storage
              final account = await _accountsService.addAccount(
                platform: platform,
                accountName: username,
                accountId: 'direct_${DateTime.now().millisecondsSinceEpoch}',
                platformData: {
                  'connection_type': 'direct_app',
                  'connected_at': DateTime.now().toIso8601String(),
                },
              );

              if (account != null) {
                Get.snackbar(
                  'تم بنجاح! 🎉',
                  'تم ربط حساب $platform: $username',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.withValues(alpha: 0.8),
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('ربط الحساب', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ========== Share Content ==========

  /// Share text content to social media
  Future<void> shareText(String text, {String? platform}) async {
    try {
      if (platform != null) {
        // Try to open specific platform
        await _shareToSpecificPlatform(text, platform);
      } else {
        // Use system share sheet
        await Share.share(text);
      }
    } catch (e) {
      print('❌ Error sharing: $e');
      Get.snackbar(
        'خطأ',
        'فشل مشاركة المحتوى: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Share image/video to social media
  Future<void> shareFile(String filePath, {String? caption, String? platform}) async {
    try {
      final XFile file = XFile(filePath);

      if (platform != null) {
        // Try to open specific platform with file
        await Share.shareXFiles(
          [file],
          text: caption,
        );
      } else {
        // Use system share sheet
        await Share.shareXFiles(
          [file],
          text: caption,
        );
      }
    } catch (e) {
      print('❌ Error sharing file: $e');
      Get.snackbar(
        'خطأ',
        'فشل مشاركة الملف: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Share to specific platform (opens app if installed)
  Future<void> _shareToSpecificPlatform(String text, String platform) async {
    try {
      // Open platform app
      await openPlatformApp(platform);

      // Show share instructions
      await Future.delayed(const Duration(milliseconds: 800));
      Get.snackbar(
        'تعليمات',
        'قم بنسخ النص ولصقه في $platform:\n\n$text',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.blue.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error sharing to $platform: $e');
      // Fallback to system share
      await Share.share(text);
    }
  }

  // ========== Helper Methods ==========

  /// Check if platform app is installed
  Future<bool> isPlatformAppInstalled(String platform) async {
    try {
      final appUrl = _platformAppUrls[platform.toLowerCase()];
      if (appUrl == null) return false;

      final uri = Uri.parse(appUrl);
      return await canLaunchUrl(uri);
    } catch (e) {
      print('❌ Error checking if $platform app is installed: $e');
      return false;
    }
  }

  /// Get supported platforms
  List<String> getSupportedPlatforms() {
    return _platformAppUrls.keys.toList();
  }
}
