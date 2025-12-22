import 'dart:async';
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'social_accounts_service.dart';
import 'api_service.dart';

/// خدمة OAuth للويب - تستخدم Popup Windows و PostMessage API
class WebOAuthService extends GetxController {
  final RxBool isLoading = false.obs;
  final ApiService _apiService = ApiService();

  SocialAccountsService? get _socialAccountsService {
    try {
      return Get.find<SocialAccountsService>();
    } catch (e) {
      print('⚠️ SocialAccountsService not available: $e');
      return null;
    }
  }

  /// فتح نافذة OAuth منبثقة
  Future<Map<String, dynamic>?> _openOAuthPopup(
    String url,
    String platform,
  ) async {
    final completer = Completer<Map<String, dynamic>?>();
    html.WindowBase? popupWindow;

    try {
      // فتح نافذة منبثقة
      popupWindow = html.window.open(
        url,
        '_blank',
        'width=600,height=700,menubar=no,toolbar=no,location=no,status=no',
      );

      // popupWindow is always non-null on web platform
      // (null return is only possible on mobile/desktop platforms)

      // الاستماع للرسائل من النافذة المنبثقة
      final subscription = html.window.onMessage.listen((event) {
        try {
          final data = event.data;

          if (data is Map) {
            if (data['type'] == 'oauth_success') {
              completer.complete(data['data'] as Map<String, dynamic>?);
            } else if (data['type'] == 'oauth_error') {
              print('❌ OAuth error: ${data['error']}');
              completer.complete(null);
            }
          }
        } catch (e) {
          print('Error parsing message: $e');
        }
      });

      // التحقق من إغلاق النافذة
      Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (popupWindow?.closed ?? true) {
          timer.cancel();
          if (!completer.isCompleted) {
            // التحقق من localStorage للحصول على البيانات
            final storedData = html.window.localStorage['oauth_callback_data'];
            if (storedData != null) {
              try {
                final data = json.decode(storedData);
                html.window.localStorage.remove('oauth_callback_data');
                completer.complete(data as Map<String, dynamic>);
              } catch (e) {
                print('Error parsing stored data: $e');
                completer.complete(null);
              }
            } else {
              completer.complete(null);
            }
          }
        }
      });

      // Timeout بعد 5 دقائق
      Future.delayed(const Duration(minutes: 5), () {
        if (!completer.isCompleted) {
          subscription.cancel();
          popupWindow?.close();
          completer.complete(null);
        }
      });
    } catch (e) {
      print('❌ Error opening popup: $e');
      completer.complete(null);
    }

    return completer.future;
  }

  /// ربط حساب Facebook
  Future<bool> connectFacebook() async {
    try {
      isLoading.value = true;
      print('🔵 Starting Facebook OAuth (Web)...');

      // طلب redirect URL من Backend
      final response = await _apiService.post('/api/auth/facebook/redirect');

      if (response['success'] != true || response['redirect_url'] == null) {
        throw Exception('Failed to get OAuth URL');
      }

      final redirectUrl = response['redirect_url'] as String;

      // فتح نافذة OAuth
      final result = await _openOAuthPopup(redirectUrl, 'facebook');

      if (result == null) {
        Get.snackbar(
          'تم الإلغاء',
          'تم إلغاء عملية الربط',
          backgroundColor: Colors.orange.withValues(alpha: 0.2),
          colorText: Colors.white,
        );
        return false;
      }

      // إعادة تحميل الحسابات من Backend
      await _socialAccountsService?.loadAccounts();

      Get.snackbar(
        'نجح!',
        'تم ربط حساب Facebook بنجاح',
        backgroundColor: Colors.green.withValues(alpha: 0.2),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );

      return true;
    } catch (e) {
      print('❌ Facebook OAuth error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء الربط: ${e.toString()}',
        backgroundColor: Colors.red.withValues(alpha: 0.2),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ربط حساب Instagram
  Future<bool> connectInstagram() async {
    try {
      isLoading.value = true;
      print('🔵 Starting Instagram OAuth (Web)...');

      final response = await _apiService.post('/api/auth/instagram/redirect');

      if (response['success'] != true || response['redirect_url'] == null) {
        throw Exception('Failed to get OAuth URL');
      }

      final redirectUrl = response['redirect_url'] as String;
      final result = await _openOAuthPopup(redirectUrl, 'instagram');

      if (result == null) {
        Get.snackbar(
          'تم الإلغاء',
          'تم إلغاء عملية الربط',
          backgroundColor: Colors.orange.withValues(alpha: 0.2),
          colorText: Colors.white,
        );
        return false;
      }

      await _socialAccountsService?.loadAccounts();

      Get.snackbar(
        'نجح!',
        'تم ربط حساب Instagram بنجاح',
        backgroundColor: Colors.green.withValues(alpha: 0.2),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );

      return true;
    } catch (e) {
      print('❌ Instagram OAuth error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ: ${e.toString()}',
        backgroundColor: Colors.red.withValues(alpha: 0.2),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ربط حساب Twitter/X
  Future<bool> connectTwitter() async {
    try {
      isLoading.value = true;
      print('🔵 Starting Twitter OAuth (Web)...');

      final response = await _apiService.post('/api/auth/twitter/redirect');

      if (response['success'] != true || response['redirect_url'] == null) {
        throw Exception('Failed to get OAuth URL');
      }

      final redirectUrl = response['redirect_url'] as String;
      final result = await _openOAuthPopup(redirectUrl, 'twitter');

      if (result == null) {
        Get.snackbar(
          'تم الإلغاء',
          'تم إلغاء عملية الربط',
          backgroundColor: Colors.orange.withValues(alpha: 0.2),
          colorText: Colors.white,
        );
        return false;
      }

      await _socialAccountsService?.loadAccounts();

      Get.snackbar(
        'نجح!',
        'تم ربط حساب Twitter بنجاح',
        backgroundColor: Colors.green.withValues(alpha: 0.2),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );

      return true;
    } catch (e) {
      print('❌ Twitter OAuth error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ: ${e.toString()}',
        backgroundColor: Colors.red.withValues(alpha: 0.2),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ربط حساب LinkedIn
  Future<bool> connectLinkedIn() async {
    try {
      isLoading.value = true;
      print('🔵 Starting LinkedIn OAuth (Web)...');

      final response = await _apiService.post('/api/auth/linkedin/redirect');

      if (response['success'] != true || response['redirect_url'] == null) {
        throw Exception('Failed to get OAuth URL');
      }

      final redirectUrl = response['redirect_url'] as String;
      final result = await _openOAuthPopup(redirectUrl, 'linkedin');

      if (result == null) {
        Get.snackbar(
          'تم الإلغاء',
          'تم إلغاء عملية الربط',
          backgroundColor: Colors.orange.withValues(alpha: 0.2),
          colorText: Colors.white,
        );
        return false;
      }

      await _socialAccountsService?.loadAccounts();

      Get.snackbar(
        'نجح!',
        'تم ربط حساب LinkedIn بنجاح',
        backgroundColor: Colors.green.withValues(alpha: 0.2),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );

      return true;
    } catch (e) {
      print('❌ LinkedIn OAuth error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ: ${e.toString()}',
        backgroundColor: Colors.red.withValues(alpha: 0.2),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ربط حساب YouTube
  Future<bool> connectYouTube() async {
    try {
      isLoading.value = true;
      print('🔵 Starting YouTube OAuth (Web)...');

      final response = await _apiService.post('/api/auth/youtube/redirect');

      if (response['success'] != true || response['redirect_url'] == null) {
        throw Exception('Failed to get OAuth URL');
      }

      final redirectUrl = response['redirect_url'] as String;
      final result = await _openOAuthPopup(redirectUrl, 'youtube');

      if (result == null) {
        Get.snackbar(
          'تم الإلغاء',
          'تم إلغاء عملية الربط',
          backgroundColor: Colors.orange.withValues(alpha: 0.2),
          colorText: Colors.white,
        );
        return false;
      }

      await _socialAccountsService?.loadAccounts();

      Get.snackbar(
        'نجح!',
        'تم ربط قناة YouTube بنجاح',
        backgroundColor: Colors.green.withValues(alpha: 0.2),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );

      return true;
    } catch (e) {
      print('❌ YouTube OAuth error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ: ${e.toString()}',
        backgroundColor: Colors.red.withValues(alpha: 0.2),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ربط حساب TikTok
  Future<bool> connectTikTok() async {
    try {
      isLoading.value = true;
      print('🔵 Starting TikTok OAuth (Web)...');

      final response = await _apiService.post('/api/auth/tiktok/redirect');

      if (response['success'] != true || response['redirect_url'] == null) {
        throw Exception('Failed to get OAuth URL');
      }

      final redirectUrl = response['redirect_url'] as String;
      final result = await _openOAuthPopup(redirectUrl, 'tiktok');

      if (result == null) {
        Get.snackbar(
          'تم الإلغاء',
          'تم إلغاء عملية الربط',
          backgroundColor: Colors.orange.withValues(alpha: 0.2),
          colorText: Colors.white,
        );
        return false;
      }

      await _socialAccountsService?.loadAccounts();

      Get.snackbar(
        'نجح!',
        'تم ربط حساب TikTok بنجاح',
        backgroundColor: Colors.green.withValues(alpha: 0.2),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );

      return true;
    } catch (e) {
      print('❌ TikTok OAuth error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ: ${e.toString()}',
        backgroundColor: Colors.red.withValues(alpha: 0.2),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
