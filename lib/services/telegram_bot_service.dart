import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';

/// خدمة شاملة للتعامل مع Telegram Bot API
/// توفر إشعارات فورية، نشر على القنوات، وإدارة تفاعلية
class TelegramBotService extends GetxService {
  // Telegram Bot API Base URL
  static const String _telegramApiBase = 'https://api.telegram.org/bot';

  // القائمة المراقبة للبوتات المربوطة
  final RxList<TelegramBotModel> connectedBots = <TelegramBotModel>[].obs;

  // حالة الخدمة
  final RxBool isInitialized = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      print('🤖 Initializing Telegram Bot Service...');
      // يمكن تحميل البوتات المحفوظة من التخزين المحلي
      isInitialized.value = true;
      print('✅ Telegram Bot Service initialized');
    } catch (e) {
      print('❌ Failed to initialize Telegram Bot Service: $e');
      errorMessage.value = e.toString();
    }
  }

  /// إرسال رسالة نصية عبر البوت
  Future<bool> sendMessage({
    required String botToken,
    required String chatId,
    required String message,
    String? parseMode = 'HTML',
    bool disableNotification = false,
  }) async {
    try {
      final url = '$_telegramApiBase$botToken/sendMessage';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'chat_id': chatId,
          'text': message,
          'parse_mode': parseMode,
          'disable_notification': disableNotification,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ok'] ?? false;
      }

      print('❌ Failed to send message: ${response.body}');
      return false;
    } catch (e) {
      print('❌ Error sending Telegram message: $e');
      return false;
    }
  }

  /// إرسال صورة مع نص عبر البوت
  Future<bool> sendPhoto({
    required String botToken,
    required String chatId,
    required String photoUrl,
    String? caption,
    String? parseMode = 'HTML',
  }) async {
    try {
      final url = '$_telegramApiBase$botToken/sendPhoto';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'chat_id': chatId,
          'photo': photoUrl,
          if (caption != null) 'caption': caption,
          if (parseMode != null) 'parse_mode': parseMode,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ok'] ?? false;
      }

      print('❌ Failed to send photo: ${response.body}');
      return false;
    } catch (e) {
      print('❌ Error sending Telegram photo: $e');
      return false;
    }
  }

  /// إرسال مستند عبر البوت
  Future<bool> sendDocument({
    required String botToken,
    required String chatId,
    required String documentUrl,
    String? caption,
  }) async {
    try {
      final url = '$_telegramApiBase$botToken/sendDocument';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'chat_id': chatId,
          'document': documentUrl,
          if (caption != null) 'caption': caption,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ok'] ?? false;
      }

      return false;
    } catch (e) {
      print('❌ Error sending document: $e');
      return false;
    }
  }

  /// الحصول على معلومات البوت
  Future<Map<String, dynamic>?> getBotInfo(String botToken) async {
    try {
      final url = '$_telegramApiBase$botToken/getMe';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['ok'] == true) {
          return data['result'];
        }
      }

      return null;
    } catch (e) {
      print('❌ Error getting bot info: $e');
      return null;
    }
  }

  /// إرسال إشعار نجاح عملية
  Future<void> sendSuccessNotification({
    required String botToken,
    required String chatId,
    required String title,
    required String message,
  }) async {
    final formattedMessage = '''
✅ <b>$title</b>

$message

━━━━━━━━━━━━━━━━
⏰ ${DateTime.now().toString().substring(0, 19)}
''';

    await sendMessage(
      botToken: botToken,
      chatId: chatId,
      message: formattedMessage,
      parseMode: 'HTML',
    );
  }

  /// إرسال إشعار خطأ
  Future<void> sendErrorNotification({
    required String botToken,
    required String chatId,
    required String title,
    required String error,
  }) async {
    final formattedMessage = '''
❌ <b>$title</b>

<code>$error</code>

━━━━━━━━━━━━━━━━
⏰ ${DateTime.now().toString().substring(0, 19)}
''';

    await sendMessage(
      botToken: botToken,
      chatId: chatId,
      message: formattedMessage,
      parseMode: 'HTML',
    );
  }

  /// إرسال إشعار تحذير
  Future<void> sendWarningNotification({
    required String botToken,
    required String chatId,
    required String title,
    required String message,
  }) async {
    final formattedMessage = '''
⚠️ <b>$title</b>

$message

━━━━━━━━━━━━━━━━
⏰ ${DateTime.now().toString().substring(0, 19)}
''';

    await sendMessage(
      botToken: botToken,
      chatId: chatId,
      message: formattedMessage,
      parseMode: 'HTML',
    );
  }

  /// إرسال تقرير إحصائيات
  Future<void> sendAnalyticsReport({
    required String botToken,
    required String chatId,
    required Map<String, dynamic> stats,
  }) async {
    final message = '''
📊 <b>تقرير الإحصائيات اليومي</b>

━━━━━━━━━━━━━━━━
📝 المنشورات: ${stats['posts'] ?? 0}
👁 المشاهدات: ${stats['views'] ?? 0}
❤️ الإعجابات: ${stats['likes'] ?? 0}
💬 التعليقات: ${stats['comments'] ?? 0}
🔄 المشاركات: ${stats['shares'] ?? 0}

📈 معدل التفاعل: ${stats['engagement_rate'] ?? '0'}%

━━━━━━━━━━━━━━━━
⏰ ${DateTime.now().toString().substring(0, 19)}
''';

    await sendMessage(
      botToken: botToken,
      chatId: chatId,
      message: message,
      parseMode: 'HTML',
    );
  }

  /// إرسال تنبيه اشتراك
  Future<void> sendSubscriptionAlert({
    required String botToken,
    required String chatId,
    required String alertType,
    required String message,
  }) async {
    String emoji = '💎';
    if (alertType == 'expiring') emoji = '⚠️';
    if (alertType == 'expired') emoji = '❌';
    if (alertType == 'upgraded') emoji = '🎉';

    final formattedMessage = '''
$emoji <b>تنبيه الاشتراك</b>

$message

━━━━━━━━━━━━━━━━
⏰ ${DateTime.now().toString().substring(0, 19)}
''';

    await sendMessage(
      botToken: botToken,
      chatId: chatId,
      message: formattedMessage,
      parseMode: 'HTML',
    );
  }

  /// نشر محتوى على قناة/مجموعة تليجرام
  Future<Map<String, dynamic>> publishToTelegram({
    required String botToken,
    required String channelUsername,
    required String content,
    String? imageUrl,
    List<String>? hashtags,
  }) async {
    try {
      // إضافة الهاشتاجات للمحتوى
      String finalContent = content;
      if (hashtags != null && hashtags.isNotEmpty) {
        finalContent += '\n\n' + hashtags.map((tag) => '#$tag').join(' ');
      }

      bool success = false;

      if (imageUrl != null && imageUrl.isNotEmpty) {
        // نشر مع صورة
        success = await sendPhoto(
          botToken: botToken,
          chatId: '@$channelUsername',
          photoUrl: imageUrl,
          caption: finalContent,
        );
      } else {
        // نشر نص فقط
        success = await sendMessage(
          botToken: botToken,
          chatId: '@$channelUsername',
          message: finalContent,
        );
      }

      return {
        'success': success,
        'platform': 'telegram',
        'channel': channelUsername,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ Error publishing to Telegram: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// التحقق من صحة البوت
  Future<bool> validateBot(String botToken) async {
    final info = await getBotInfo(botToken);
    return info != null;
  }

  /// الحصول على تحديثات البوت (للرسائل الواردة)
  Future<List<Map<String, dynamic>>> getUpdates({
    required String botToken,
    int? offset,
    int limit = 100,
  }) async {
    try {
      final url = '$_telegramApiBase$botToken/getUpdates';

      final params = <String, dynamic>{
        'limit': limit,
        if (offset != null) 'offset': offset,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(params),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['ok'] == true) {
          return List<Map<String, dynamic>>.from(data['result'] ?? []);
        }
      }

      return [];
    } catch (e) {
      print('❌ Error getting updates: $e');
      return [];
    }
  }

  /// ضبط Webhook للبوت
  Future<bool> setWebhook({
    required String botToken,
    required String webhookUrl,
  }) async {
    try {
      final url = '$_telegramApiBase$botToken/setWebhook';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'url': webhookUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ok'] ?? false;
      }

      return false;
    } catch (e) {
      print('❌ Error setting webhook: $e');
      return false;
    }
  }

  /// إنشاء أزرار تفاعلية (Inline Keyboard)
  Map<String, dynamic> createInlineKeyboard(List<List<Map<String, String>>> buttons) {
    return {
      'inline_keyboard': buttons.map((row) {
        return row.map((button) {
          return {
            'text': button['text'],
            if (button['url'] != null) 'url': button['url'],
            if (button['callback_data'] != null) 'callback_data': button['callback_data'],
          };
        }).toList();
      }).toList(),
    };
  }

  /// إرسال رسالة مع أزرار تفاعلية
  Future<bool> sendMessageWithButtons({
    required String botToken,
    required String chatId,
    required String message,
    required List<List<Map<String, String>>> buttons,
  }) async {
    try {
      final url = '$_telegramApiBase$botToken/sendMessage';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'chat_id': chatId,
          'text': message,
          'parse_mode': 'HTML',
          'reply_markup': createInlineKeyboard(buttons),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ok'] ?? false;
      }

      return false;
    } catch (e) {
      print('❌ Error sending message with buttons: $e');
      return false;
    }
  }
}

/// نموذج بيانات البوت
class TelegramBotModel {
  final String id;
  final String botToken;
  final String botUsername;
  final String? chatId;
  final bool isActive;
  final DateTime? connectedAt;

  TelegramBotModel({
    required this.id,
    required this.botToken,
    required this.botUsername,
    this.chatId,
    this.isActive = true,
    this.connectedAt,
  });

  factory TelegramBotModel.fromJson(Map<String, dynamic> json) {
    return TelegramBotModel(
      id: json['id']?.toString() ?? '',
      botToken: json['bot_token'] ?? '',
      botUsername: json['bot_username'] ?? json['username'] ?? '',
      chatId: json['chat_id']?.toString(),
      isActive: json['is_active'] ?? true,
      connectedAt: json['connected_at'] != null
        ? DateTime.tryParse(json['connected_at'])
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bot_token': botToken,
      'bot_username': botUsername,
      'chat_id': chatId,
      'is_active': isActive,
      'connected_at': connectedAt?.toIso8601String(),
    };
  }
}
