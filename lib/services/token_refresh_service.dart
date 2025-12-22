import 'package:get/get.dart';
import 'dart:async';
import 'api_service.dart';

/// خدمة تحديث tokens تلقائياً لحسابات السوشال ميديا
class TokenRefreshService extends GetxController {
  late final ApiService _apiService;

  // Timer للتحديث الدوري
  Timer? _refreshTimer;

  // المدة قبل انتهاء صلاحية Token للبدء بالتحديث
  static const Duration _refreshBefore = Duration(minutes: 5);

  // فترة المراقبة الدورية
  static const Duration _monitoringInterval = Duration(minutes: 10);

  // حالة الخدمة
  final RxBool isMonitoring = false.obs;
  final RxInt lastRefreshTime = 0.obs;
  final RxMap<String, dynamic> tokenStats = <String, dynamic>{}.obs;

  @override
  void onInit() {
    _apiService = ApiService();
    super.onInit();
    startMonitoring();
  }

  /// بدء مراقبة و تحديث tokens
  void startMonitoring() {
    if (isMonitoring.value) {
      print('⚠️ Token monitoring already running');
      return;
    }

    print('🟢 بدء مراقبة tokens');
    isMonitoring.value = true;

    // إجراء فحص أولي
    refreshExpiredTokens();

    // بدء المراقبة الدورية
    _refreshTimer = Timer.periodic(_monitoringInterval, (_) {
      refreshExpiredTokens();
    });
  }

  /// التحقق من tokens المنتهية وتحديثها
  Future<void> refreshExpiredTokens() async {
    try {
      print('🔵 بدء فحص tokens المنتهية الصلاحية...');

      // الحصول على جميع الحسابات المتصلة
      final response = await _apiService.getSocialAccounts();

      if (response['success'] != true || response['accounts'] == null) {
        print('⚠️ لا توجد حسابات للفحص');
        return;
      }

      final List<dynamic> accounts = response['accounts'] as List<dynamic>;
      int refreshedCount = 0;
      int expiredCount = 0;

      for (final account in accounts) {
        final accountId = account['id'];
        final expiresAt = account['token_expires_at'];

        // تخطي إذا لم تكن هناك معلومات انتهاء الصلاحية
        if (expiresAt == null) continue;

        try {
          final expiryDateTime = DateTime.parse(expiresAt.toString());
          final now = DateTime.now();
          final timeDifference = expiryDateTime.difference(now);

          // إذا كان الـ Token سينتهي في أقل من 5 دقائق
          if (timeDifference.inMinutes <= _refreshBefore.inMinutes) {
            print(
              '🟡 Token ${account['platform']} سينتهي قريباً، جاري التحديث...',
            );

            final updateResult = await refreshAccountToken(accountId);
            if (updateResult) {
              refreshedCount++;
            }
          }

          // إذا انتهت الصلاحية فعلاً
          if (timeDifference.isNegative) {
            expiredCount++;
            print('🔴 Token ${account['platform']} منتهي الصلاحية!');
          }
        } catch (e) {
          print('⚠️ خطأ في معالجة account $accountId: $e');
        }
      }

      // تحديث الإحصائيات
      lastRefreshTime.value = DateTime.now().millisecondsSinceEpoch;
      tokenStats.value = {
        'refreshed': refreshedCount,
        'expired': expiredCount,
        'total': accounts.length,
        'lastCheck': DateTime.now().toString(),
      };

      if (refreshedCount > 0) {
        print('✅ تم تحديث $refreshedCount token(s) بنجاح');
      }

      if (expiredCount > 0) {
        print('🚨 هناك $expiredCount token(s) منتهية الصلاحية');
        // يمكن إرسال إشعار للمستخدم هنا
      }
    } catch (e) {
      print('❌ خطأ في مراقبة tokens: $e');
    }
  }

  /// تحديث token حساب معين
  Future<bool> refreshAccountToken(dynamic accountId) async {
    try {
      // استدعاء backend لتحديث token
      final response = await _apiService.put(
        '/social-accounts/$accountId/refresh-token',
        data: {},
      );

      if (response['success'] == true) {
        print('✅ تم تحديث token للحساب $accountId');
        return true;
      } else {
        print('❌ فشل تحديث token: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('❌ خطأ في تحديث token: $e');
      return false;
    }
  }

  /// إيقاف المراقبة
  void stopMonitoring() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    isMonitoring.value = false;
    print('⏹️  تم إيقاف مراقبة tokens');
  }

  /// الحصول على إحصائيات التحديث
  Map<String, dynamic> getStats() {
    return tokenStats.toJson().isNotEmpty
        ? tokenStats.toJson()
        : {'status': 'no_data_yet'};
  }

  @override
  void onClose() {
    stopMonitoring();
    super.onClose();
  }
}
