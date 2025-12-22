import 'package:get/get.dart';
import 'telegram_bot_service.dart';
import 'auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة إشعارات التليجرام الذكية
/// تدير إرسال الإشعارات الفورية للمستخدم عبر بوتات التليجرام المربوطة
class TelegramNotificationService extends GetxService {
  final TelegramBotService _botService = Get.find<TelegramBotService>();
  final AuthService _authService = Get.find<AuthService>();

  // إعدادات الإشعارات
  final RxBool notificationsEnabled = true.obs;
  final RxBool postNotifications = true.obs;
  final RxBool analyticsNotifications = true.obs;
  final RxBool subscriptionNotifications = true.obs;
  final RxBool errorNotifications = true.obs;

  // بيانات البوت المفعل للإشعارات
  final Rx<TelegramBotModel?> notificationBot = Rx<TelegramBotModel?>(null);
  final RxString notificationChatId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  /// تحميل إعدادات الإشعارات من التخزين المحلي
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      notificationsEnabled.value = prefs.getBool('telegram_notifications_enabled') ?? true;
      postNotifications.value = prefs.getBool('telegram_post_notifications') ?? true;
      analyticsNotifications.value = prefs.getBool('telegram_analytics_notifications') ?? true;
      subscriptionNotifications.value = prefs.getBool('telegram_subscription_notifications') ?? true;
      errorNotifications.value = prefs.getBool('telegram_error_notifications') ?? true;

      notificationChatId.value = prefs.getString('telegram_notification_chat_id') ?? '';

      // تحميل بيانات البوت المفعل
      final botData = prefs.getString('telegram_notification_bot');
      if (botData != null) {
        // يمكن تحويله من JSON لاحقاً
      }

      print('✅ Telegram notification settings loaded');
    } catch (e) {
      print('❌ Error loading notification settings: $e');
    }
  }

  /// حفظ إعدادات الإشعارات
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('telegram_notifications_enabled', notificationsEnabled.value);
      await prefs.setBool('telegram_post_notifications', postNotifications.value);
      await prefs.setBool('telegram_analytics_notifications', analyticsNotifications.value);
      await prefs.setBool('telegram_subscription_notifications', subscriptionNotifications.value);
      await prefs.setBool('telegram_error_notifications', errorNotifications.value);

      if (notificationChatId.value.isNotEmpty) {
        await prefs.setString('telegram_notification_chat_id', notificationChatId.value);
      }

      print('✅ Notification settings saved');
    } catch (e) {
      print('❌ Error saving notification settings: $e');
    }
  }

  /// تفعيل/تعطيل الإشعارات
  Future<void> toggleNotifications(bool enabled) async {
    notificationsEnabled.value = enabled;
    await _saveSettings();
  }

  /// تعيين البوت المستخدم للإشعارات
  Future<void> setNotificationBot(TelegramBotModel bot, String chatId) async {
    notificationBot.value = bot;
    notificationChatId.value = chatId;
    await _saveSettings();
  }

  /// إرسال إشعار نجاح نشر منشور
  Future<void> notifyPostSuccess({
    required String platform,
    required String postTitle,
    String? postUrl,
  }) async {
    if (!notificationsEnabled.value || !postNotifications.value) return;
    if (notificationBot.value == null || notificationChatId.value.isEmpty) return;

    try {
      String message = 'تم نشر المنشور بنجاح على $platform';
      if (postUrl != null) {
        message += '\n\n🔗 <a href="$postUrl">عرض المنشور</a>';
      }

      await _botService.sendSuccessNotification(
        botToken: notificationBot.value!.botToken,
        chatId: notificationChatId.value,
        title: 'نشر ناجح: $postTitle',
        message: message,
      );
    } catch (e) {
      print('❌ Error sending post success notification: $e');
    }
  }

  /// إرسال إشعار فشل نشر منشور
  Future<void> notifyPostFailure({
    required String platform,
    required String postTitle,
    required String error,
  }) async {
    if (!notificationsEnabled.value || !errorNotifications.value) return;
    if (notificationBot.value == null || notificationChatId.value.isEmpty) return;

    try {
      await _botService.sendErrorNotification(
        botToken: notificationBot.value!.botToken,
        chatId: notificationChatId.value,
        title: 'فشل النشر على $platform',
        error: 'المنشور: $postTitle\n\nالخطأ: $error',
      );
    } catch (e) {
      print('❌ Error sending post failure notification: $e');
    }
  }

  /// إرسال تقرير إحصائيات يومي
  Future<void> sendDailyAnalyticsReport(Map<String, dynamic> stats) async {
    if (!notificationsEnabled.value || !analyticsNotifications.value) return;
    if (notificationBot.value == null || notificationChatId.value.isEmpty) return;

    try {
      await _botService.sendAnalyticsReport(
        botToken: notificationBot.value!.botToken,
        chatId: notificationChatId.value,
        stats: stats,
      );
    } catch (e) {
      print('❌ Error sending analytics report: $e');
    }
  }

  /// إرسال تنبيه قرب انتهاء الاشتراك
  Future<void> notifySubscriptionExpiring(int daysRemaining) async {
    if (!notificationsEnabled.value || !subscriptionNotifications.value) return;
    if (notificationBot.value == null || notificationChatId.value.isEmpty) return;

    try {
      await _botService.sendSubscriptionAlert(
        botToken: notificationBot.value!.botToken,
        chatId: notificationChatId.value,
        alertType: 'expiring',
        message: 'اشتراكك سينتهي خلال $daysRemaining ${daysRemaining == 1 ? "يوم" : "أيام"}!\n\nقم بالتجديد للاستمرار في الاستفادة من جميع الميزات.',
      );
    } catch (e) {
      print('❌ Error sending subscription expiring notification: $e');
    }
  }

  /// إرسال تنبيه انتهاء الاشتراك
  Future<void> notifySubscriptionExpired() async {
    if (!notificationsEnabled.value || !subscriptionNotifications.value) return;
    if (notificationBot.value == null || notificationChatId.value.isEmpty) return;

    try {
      await _botService.sendSubscriptionAlert(
        botToken: notificationBot.value!.botToken,
        chatId: notificationChatId.value,
        alertType: 'expired',
        message: 'انتهى اشتراكك!\n\nتم تحويلك للباقة المجانية. قم بالترقية لاستعادة جميع الميزات.',
      );
    } catch (e) {
      print('❌ Error sending subscription expired notification: $e');
    }
  }

  /// إرسال إشعار ترقية الاشتراك
  Future<void> notifySubscriptionUpgraded(String newTier) async {
    if (!notificationsEnabled.value || !subscriptionNotifications.value) return;
    if (notificationBot.value == null || notificationChatId.value.isEmpty) return;

    try {
      await _botService.sendSubscriptionAlert(
        botToken: notificationBot.value!.botToken,
        chatId: notificationChatId.value,
        alertType: 'upgraded',
        message: 'تم ترقية اشتراكك لباقة $newTier بنجاح!\n\nاستمتع بجميع الميزات الجديدة 🎉',
      );
    } catch (e) {
      print('❌ Error sending subscription upgraded notification: $e');
    }
  }

  /// إرسال إشعار مشكلة في حساب متصل
  Future<void> notifyAccountIssue({
    required String platform,
    required String accountName,
    required String issue,
  }) async {
    if (!notificationsEnabled.value || !errorNotifications.value) return;
    if (notificationBot.value == null || notificationChatId.value.isEmpty) return;

    try {
      await _botService.sendWarningNotification(
        botToken: notificationBot.value!.botToken,
        chatId: notificationChatId.value,
        title: 'مشكلة في حساب $platform',
        message: 'الحساب: $accountName\n\nالمشكلة: $issue\n\nقد تحتاج لإعادة ربط الحساب.',
      );
    } catch (e) {
      print('❌ Error sending account issue notification: $e');
    }
  }

  /// إرسال إشعار بلوغ حد الاستخدام
  Future<void> notifyLimitReached({
    required String limitType,
    required int currentLimit,
  }) async {
    if (!notificationsEnabled.value || !errorNotifications.value) return;
    if (notificationBot.value == null || notificationChatId.value.isEmpty) return;

    try {
      await _botService.sendWarningNotification(
        botToken: notificationBot.value!.botToken,
        chatId: notificationChatId.value,
        title: 'بلوغ الحد الأقصى',
        message: 'لقد وصلت للحد الأقصى من $limitType ($currentLimit)\n\nقم بالترقية لزيادة الحدود.',
      );
    } catch (e) {
      print('❌ Error sending limit reached notification: $e');
    }
  }

  /// إرسال إشعار مخصص
  Future<void> sendCustomNotification({
    required String title,
    required String message,
    String type = 'info',
  }) async {
    if (!notificationsEnabled.value) return;
    if (notificationBot.value == null || notificationChatId.value.isEmpty) return;

    try {
      switch (type) {
        case 'success':
          await _botService.sendSuccessNotification(
            botToken: notificationBot.value!.botToken,
            chatId: notificationChatId.value,
            title: title,
            message: message,
          );
          break;
        case 'error':
          await _botService.sendErrorNotification(
            botToken: notificationBot.value!.botToken,
            chatId: notificationChatId.value,
            title: title,
            error: message,
          );
          break;
        case 'warning':
          await _botService.sendWarningNotification(
            botToken: notificationBot.value!.botToken,
            chatId: notificationChatId.value,
            title: title,
            message: message,
          );
          break;
        default:
          await _botService.sendMessage(
            botToken: notificationBot.value!.botToken,
            chatId: notificationChatId.value,
            message: '<b>$title</b>\n\n$message',
          );
      }
    } catch (e) {
      print('❌ Error sending custom notification: $e');
    }
  }

  /// إرسال ملخص أسبوعي
  Future<void> sendWeeklySummary({
    required int totalPosts,
    required int totalViews,
    required int totalEngagements,
    required Map<String, int> platformBreakdown,
  }) async {
    if (!notificationsEnabled.value || !analyticsNotifications.value) return;
    if (notificationBot.value == null || notificationChatId.value.isEmpty) return;

    try {
      String platformStats = '';
      platformBreakdown.forEach((platform, count) {
        platformStats += '\n   • $platform: $count منشور';
      });

      final message = '''
📊 <b>الملخص الأسبوعي</b>

━━━━━━━━━━━━━━━━
📝 إجمالي المنشورات: $totalPosts
👁 إجمالي المشاهدات: $totalViews
💫 إجمالي التفاعلات: $totalEngagements

<b>توزيع المنشورات:</b>$platformStats

━━━━━━━━━━━━━━━━
⏰ ${DateTime.now().toString().substring(0, 19)}
''';

      await _botService.sendMessage(
        botToken: notificationBot.value!.botToken,
        chatId: notificationChatId.value,
        message: message,
        parseMode: 'HTML',
      );
    } catch (e) {
      print('❌ Error sending weekly summary: $e');
    }
  }

  /// التحقق من إعداد الإشعارات
  bool get isConfigured {
    return notificationBot.value != null && notificationChatId.value.isNotEmpty;
  }

  /// تحديث إعدادات نوع الإشعارات
  Future<void> updateNotificationTypes({
    bool? posts,
    bool? analytics,
    bool? subscription,
    bool? errors,
  }) async {
    if (posts != null) postNotifications.value = posts;
    if (analytics != null) analyticsNotifications.value = analytics;
    if (subscription != null) subscriptionNotifications.value = subscription;
    if (errors != null) errorNotifications.value = errors;

    await _saveSettings();
  }
}
