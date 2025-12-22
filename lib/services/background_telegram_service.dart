import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';
import 'laravel_api_service.dart';

/// خدمة التليجرام الخفية
/// تعمل في الخلفية بدون تدخل المستخدم
/// تستخدم بوتات مملوكة للتطبيق من Backend
class BackgroundTelegramService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();
  final LaravelApiService _laravelApi = Get.find<LaravelApiService>();

  // حالة الخدمة
  final RxBool isEnabled = false.obs;
  final RxString errorMessage = ''.obs;

  // معلومات البوت (تُحمّل من Backend)
  String? _systemBotToken;
  String? _systemBotChatId;
  bool _isInitialized = false;

  static const String _telegramApiBase = 'https://api.telegram.org/bot';

  @override
  void onInit() {
    super.onInit();
    _initializeBackgroundService();
  }

  /// تهيئة الخدمة الخفية
  Future<void> _initializeBackgroundService() async {
    try {
      print('🤖 Initializing Background Telegram Service...');

      // جلب معلومات البوت من Backend
      final config = await _fetchBotConfiguration();

      if (config != null) {
        _systemBotToken = config['bot_token'];
        _systemBotChatId = config['chat_id'];
        _isInitialized = true;
        isEnabled.value = true;

        print('✅ Background Telegram Service initialized');
        print('   Bot enabled: ${isEnabled.value}');

        // إرسال إشعار تجريبي (اختياري)
        // await _sendWelcomeNotification();
      } else {
        print('⚠️ No bot configuration found in backend');
        _isInitialized = false;
        isEnabled.value = false;
      }
    } catch (e) {
      print('❌ Failed to initialize Background Telegram: $e');
      errorMessage.value = e.toString();
      _isInitialized = false;
      isEnabled.value = false;
    }
  }

  /// جلب إعدادات البوت من Backend
  Future<Map<String, dynamic>?> _fetchBotConfiguration() async {
    try {
      final response = await http.get(
        Uri.parse('${LaravelApiService.baseUrl}/api/telegram/bot-config'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_laravelApi.authToken.value}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['config'];
      }

      return null;
    } catch (e) {
      print('❌ Error fetching bot config: $e');
      return null;
    }
  }

  /// إرسال رسالة عبر البوت الخفي
  Future<bool> _sendTelegramMessage({
    required String message,
    String? parseMode = 'HTML',
    bool silent = true,
  }) async {
    if (!_isInitialized || _systemBotToken == null) {
      print('⚠️ Telegram service not initialized');
      return false;
    }

    try {
      final url = '$_telegramApiBase$_systemBotToken/sendMessage';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'chat_id': _systemBotChatId,
          'text': message,
          'parse_mode': parseMode,
          'disable_notification': silent,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ok'] ?? false;
      }

      return false;
    } catch (e) {
      print('❌ Error sending Telegram message: $e');
      return false;
    }
  }

  /// إرسال صورة عبر البوت الخفي
  Future<bool> _sendTelegramPhoto({
    required String photoUrl,
    String? caption,
    bool silent = true,
  }) async {
    if (!_isInitialized || _systemBotToken == null) {
      return false;
    }

    try {
      final url = '$_telegramApiBase$_systemBotToken/sendPhoto';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'chat_id': _systemBotChatId,
          'photo': photoUrl,
          if (caption != null) 'caption': caption,
          'parse_mode': 'HTML',
          'disable_notification': silent,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ok'] ?? false;
      }

      return false;
    } catch (e) {
      print('❌ Error sending photo: $e');
      return false;
    }
  }

  // ==================== وظائف عامة للاستخدام ====================

  /// تتبع حدث في التطبيق (خفي)
  Future<void> trackEvent(String eventName, {Map<String, dynamic>? data}) async {
    if (!isEnabled.value) return;

    try {
      final user = _authService.currentUser.value;
      if (user == null) return;

      final message = '''
📌 <b>حدث جديد</b>

الحدث: $eventName
المستخدم: ${user.name} (${user.phoneNumber})
التوقيت: ${DateTime.now().toString().substring(0, 19)}
${data != null ? '\nالبيانات:\n${data.entries.map((e) => '  • ${e.key}: ${e.value}').join('\n')}' : ''}
''';

      await _sendTelegramMessage(message: message, silent: true);
    } catch (e) {
      print('Error tracking event: $e');
    }
  }

  /// تسجيل نجاح نشر منشور
  Future<void> logPostSuccess({
    required String platform,
    required String postTitle,
    String? postUrl,
  }) async {
    if (!isEnabled.value) return;

    try {
      final user = _authService.currentUser.value;
      final message = '''
✅ <b>نشر ناجح</b>

المنصة: $platform
المنشور: $postTitle
المستخدم: ${user?.name ?? 'Unknown'}
${postUrl != null ? 'الرابط: $postUrl' : ''}

⏰ ${DateTime.now().toString().substring(0, 19)}
''';

      await _sendTelegramMessage(message: message, silent: true);
    } catch (e) {
      print('Error logging post success: $e');
    }
  }

  /// تسجيل فشل نشر منشور
  Future<void> logPostFailure({
    required String platform,
    required String postTitle,
    required String error,
  }) async {
    if (!isEnabled.value) return;

    try {
      final user = _authService.currentUser.value;
      final message = '''
❌ <b>فشل النشر</b>

المنصة: $platform
المنشور: $postTitle
المستخدم: ${user?.name ?? 'Unknown'}
الخطأ: <code>$error</code>

⏰ ${DateTime.now().toString().substring(0, 19)}
''';

      await _sendTelegramMessage(message: message, silent: true);
    } catch (e) {
      print('Error logging post failure: $e');
    }
  }

  /// تسجيل مستخدم جديد
  Future<void> logNewUser(String userName, String phoneNumber) async {
    if (!isEnabled.value) return;

    try {
      final message = '''
🎉 <b>مستخدم جديد</b>

الاسم: $userName
الهاتف: $phoneNumber
التوقيت: ${DateTime.now().toString().substring(0, 19)}
''';

      await _sendTelegramMessage(message: message, silent: false);
    } catch (e) {
      print('Error logging new user: $e');
    }
  }

  /// تسجيل ترقية اشتراك
  Future<void> logSubscriptionUpgrade({
    required String userName,
    required String oldTier,
    required String newTier,
    required double amount,
  }) async {
    if (!isEnabled.value) return;

    try {
      final message = '''
💎 <b>ترقية اشتراك</b>

المستخدم: $userName
من: $oldTier → إلى: $newTier
المبلغ: $amount EGP

⏰ ${DateTime.now().toString().substring(0, 19)}
''';

      await _sendTelegramMessage(message: message, silent: false);
    } catch (e) {
      print('Error logging subscription upgrade: $e');
    }
  }

  /// تسجيل خطأ حرج
  Future<void> logCriticalError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) async {
    if (!isEnabled.value) return;

    try {
      final user = _authService.currentUser.value;
      final message = '''
🚨 <b>خطأ حرج</b>

النوع: $errorType
المستخدم: ${user?.name ?? 'System'}
الرسالة: <code>$errorMessage</code>
${stackTrace != null ? '\nStack Trace:\n<code>${stackTrace.substring(0, stackTrace.length > 500 ? 500 : stackTrace.length)}</code>' : ''}

⏰ ${DateTime.now().toString().substring(0, 19)}
''';

      await _sendTelegramMessage(message: message, silent: false);
    } catch (e) {
      print('Error logging critical error: $e');
    }
  }

  /// إرسال تقرير يومي تلقائي
  Future<void> sendDailyReport({
    required int totalUsers,
    required int activeUsers,
    required int totalPosts,
    required int successfulPosts,
    required int failedPosts,
    required double revenue,
  }) async {
    if (!isEnabled.value) return;

    try {
      final successRate = totalPosts > 0
          ? ((successfulPosts / totalPosts) * 100).toStringAsFixed(1)
          : '0.0';

      final message = '''
📊 <b>التقرير اليومي</b>

━━━━━━━━━━━━━━━━
👥 المستخدمين:
   • الإجمالي: $totalUsers
   • النشطين: $activeUsers

📝 المنشورات:
   • الإجمالي: $totalPosts
   • الناجحة: $successfulPosts ✅
   • الفاشلة: $failedPosts ❌
   • معدل النجاح: $successRate%

💰 الإيرادات:
   • اليوم: ${revenue.toStringAsFixed(2)} EGP

━━━━━━━━━━━━━━━━
📅 ${DateTime.now().toString().substring(0, 10)}
''';

      await _sendTelegramMessage(message: message, silent: false);
    } catch (e) {
      print('Error sending daily report: $e');
    }
  }

  /// تتبع استخدام ميزة معينة
  Future<void> trackFeatureUsage(String featureName, {String? details}) async {
    if (!isEnabled.value) return;

    try {
      final user = _authService.currentUser.value;
      final message = '''
📱 <b>استخدام ميزة</b>

الميزة: $featureName
المستخدم: ${user?.name ?? 'Unknown'}
${details != null ? 'التفاصيل: $details' : ''}

⏰ ${DateTime.now().toString().substring(0, 19)}
''';

      await _sendTelegramMessage(message: message, silent: true);
    } catch (e) {
      print('Error tracking feature usage: $e');
    }
  }

  /// تسجيل محاولة دفع
  Future<void> logPaymentAttempt({
    required String userName,
    required double amount,
    required String paymentMethod,
    required bool success,
    String? errorMessage,
  }) async {
    if (!isEnabled.value) return;

    try {
      final message = '''
${success ? '💳 <b>عملية دفع ناجحة</b>' : '❌ <b>فشل الدفع</b>'}

المستخدم: $userName
المبلغ: ${amount.toStringAsFixed(2)} EGP
الطريقة: $paymentMethod
${!success && errorMessage != null ? 'الخطأ: $errorMessage' : ''}

⏰ ${DateTime.now().toString().substring(0, 19)}
''';

      await _sendTelegramMessage(message: message, silent: false);
    } catch (e) {
      print('Error logging payment attempt: $e');
    }
  }

  /// تسجيل محاولة تسجيل دخول مشبوهة
  Future<void> logSuspiciousLogin({
    required String phoneNumber,
    required String ipAddress,
    String? deviceInfo,
  }) async {
    if (!isEnabled.value) return;

    try {
      final message = '''
🚨 <b>محاولة تسجيل دخول مشبوهة</b>

الهاتف: $phoneNumber
IP: $ipAddress
${deviceInfo != null ? 'الجهاز: $deviceInfo' : ''}

⏰ ${DateTime.now().toString().substring(0, 19)}
''';

      await _sendTelegramMessage(message: message, silent: false);
    } catch (e) {
      print('Error logging suspicious login: $e');
    }
  }

  /// إرسال إشعار مخصص للإدارة
  Future<void> sendAdminNotification({
    required String title,
    required String message,
    bool urgent = false,
  }) async {
    if (!isEnabled.value) return;

    try {
      final emoji = urgent ? '🚨' : 'ℹ️';
      final formattedMessage = '''
$emoji <b>$title</b>

$message

⏰ ${DateTime.now().toString().substring(0, 19)}
''';

      await _sendTelegramMessage(
        message: formattedMessage,
        silent: !urgent,
      );
    } catch (e) {
      print('Error sending admin notification: $e');
    }
  }

  /// إعادة تهيئة الخدمة (في حالة تغيير الإعدادات)
  Future<void> reinitialize() async {
    _isInitialized = false;
    await _initializeBackgroundService();
  }

  /// التحقق من حالة الخدمة
  bool get isReady => _isInitialized && isEnabled.value;

  /// الحصول على معلومات الحالة
  Map<String, dynamic> getStatus() {
    return {
      'initialized': _isInitialized,
      'enabled': isEnabled.value,
      'has_bot_token': _systemBotToken != null,
      'has_chat_id': _systemBotChatId != null,
      'error': errorMessage.value,
    };
  }
}
