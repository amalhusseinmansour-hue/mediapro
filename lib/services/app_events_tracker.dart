import 'package:get/get.dart';
import 'background_telegram_service.dart';
import 'auth_service.dart';

/// خدمة تتبع الأحداث في التطبيق
/// تستخدم BackgroundTelegramService تلقائياً لإرسال التتبع
class AppEventsTracker extends GetxService {
  final BackgroundTelegramService _telegramService = Get.find<BackgroundTelegramService>();
  final AuthService _authService = Get.find<AuthService>();

  // ==================== تتبع أحداث المستخدم ====================

  /// تتبع تسجيل دخول
  Future<void> trackLogin() async {
    final user = _authService.currentUser.value;
    if (user == null) return;

    await _telegramService.trackEvent('User Login', data: {
      'user_name': user.name,
      'phone': user.phoneNumber,
      'tier': user.tierDisplayName,
    });
  }

  /// تتبع تسجيل مستخدم جديد
  Future<void> trackNewRegistration() async {
    final user = _authService.currentUser.value;
    if (user == null) return;

    await _telegramService.logNewUser(
      user.name,
      user.phoneNumber,
    );
  }

  /// تتبع ترقية اشتراك
  Future<void> trackSubscriptionUpgrade({
    required String oldTier,
    required String newTier,
    required double amount,
  }) async {
    final user = _authService.currentUser.value;
    if (user == null) return;

    await _telegramService.logSubscriptionUpgrade(
      userName: user.name,
      oldTier: oldTier,
      newTier: newTier,
      amount: amount,
    );
  }

  // ==================== تتبع أحداث المنشورات ====================

  /// تتبع نجاح نشر منشور
  Future<void> trackPostSuccess({
    required String platform,
    required String postTitle,
    String? postUrl,
  }) async {
    await _telegramService.logPostSuccess(
      platform: platform,
      postTitle: postTitle,
      postUrl: postUrl,
    );
  }

  /// تتبع فشل نشر منشور
  Future<void> trackPostFailure({
    required String platform,
    required String postTitle,
    required String error,
  }) async {
    await _telegramService.logPostFailure(
      platform: platform,
      postTitle: postTitle,
      error: error,
    );
  }

  // ==================== تتبع استخدام الميزات ====================

  /// تتبع استخدام ميزة AI
  Future<void> trackAIUsage(String aiType) async {
    await _telegramService.trackFeatureUsage(
      'AI Content Generation',
      details: 'Type: $aiType',
    );
  }

  /// تتبع استخدام ميزة الجدولة
  Future<void> trackSchedulingUsage() async {
    await _telegramService.trackFeatureUsage('Post Scheduling');
  }

  /// تتبع استخدام ميزة التحليلات
  Future<void> trackAnalyticsViewed() async {
    await _telegramService.trackFeatureUsage('Analytics Dashboard');
  }

  /// تتبع ربط حساب جديد
  Future<void> trackAccountConnected(String platform) async {
    await _telegramService.trackFeatureUsage(
      'Social Account Connected',
      details: 'Platform: $platform',
    );
  }

  /// تتبع فصل حساب
  Future<void> trackAccountDisconnected(String platform) async {
    await _telegramService.trackFeatureUsage(
      'Social Account Disconnected',
      details: 'Platform: $platform',
    );
  }

  // ==================== تتبع أحداث الدفع ====================

  /// تتبع محاولة دفع
  Future<void> trackPaymentAttempt({
    required double amount,
    required String paymentMethod,
    required bool success,
    String? errorMessage,
  }) async {
    final user = _authService.currentUser.value;
    if (user == null) return;

    await _telegramService.logPaymentAttempt(
      userName: user.name,
      amount: amount,
      paymentMethod: paymentMethod,
      success: success,
      errorMessage: errorMessage,
    );
  }

  // ==================== تتبع الأخطاء ====================

  /// تتبع خطأ حرج
  Future<void> trackCriticalError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) async {
    await _telegramService.logCriticalError(
      errorType: errorType,
      errorMessage: errorMessage,
      stackTrace: stackTrace,
    );
  }

  /// تتبع محاولة تسجيل دخول مشبوهة
  Future<void> trackSuspiciousLogin({
    required String phoneNumber,
    required String ipAddress,
    String? deviceInfo,
  }) async {
    await _telegramService.logSuspiciousLogin(
      phoneNumber: phoneNumber,
      ipAddress: ipAddress,
      deviceInfo: deviceInfo,
    );
  }

  // ==================== إرسال تقارير ====================

  /// إرسال تقرير يومي
  Future<void> sendDailyReport({
    required int totalUsers,
    required int activeUsers,
    required int totalPosts,
    required int successfulPosts,
    required int failedPosts,
    required double revenue,
  }) async {
    await _telegramService.sendDailyReport(
      totalUsers: totalUsers,
      activeUsers: activeUsers,
      totalPosts: totalPosts,
      successfulPosts: successfulPosts,
      failedPosts: failedPosts,
      revenue: revenue,
    );
  }

  /// إرسال إشعار للإدارة
  Future<void> sendAdminAlert({
    required String title,
    required String message,
    bool urgent = false,
  }) async {
    await _telegramService.sendAdminNotification(
      title: title,
      message: message,
      urgent: urgent,
    );
  }

  // ==================== أمثلة استخدام متقدمة ====================

  /// تتبع رحلة المستخدم (User Journey)
  Future<void> trackUserJourney(String milestone) async {
    await _telegramService.trackEvent('User Journey', data: {
      'milestone': milestone,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// تتبع معدل التحويل (Conversion Rate)
  Future<void> trackConversion(String conversionType, double value) async {
    await _telegramService.trackEvent('Conversion', data: {
      'type': conversionType,
      'value': value,
    });
  }

  /// تتبع التفاعل مع الميزات
  Future<void> trackEngagement(String feature, int duration) async {
    await _telegramService.trackEvent('Feature Engagement', data: {
      'feature': feature,
      'duration_seconds': duration,
    });
  }
}
