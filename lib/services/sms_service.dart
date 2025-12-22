import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/sms_model.dart';
import 'package:dio/dio.dart';

class SmsService extends GetxController {
  static const String _messagesBoxName = 'smsMessages';
  static const String _settingsBoxName = 'smsSettings';

  final RxList<SmsMessage> messages = <SmsMessage>[].obs;
  final Rx<SmsSettings?> settings = Rx<SmsSettings?>(null);
  final RxBool isLoading = false.obs;

  Box<SmsMessage>? _messagesBox;
  Box<SmsSettings>? _settingsBox;

  final Dio _dio = Dio();

  @override
  void onInit() {
    super.onInit();
    _initializeBoxes();
  }

  Future<void> _initializeBoxes() async {
    isLoading.value = true;
    try {
      _messagesBox = await Hive.openBox<SmsMessage>(_messagesBoxName);
      _settingsBox = await Hive.openBox<SmsSettings>(_settingsBoxName);
      await loadMessages();
      await loadSettings();
    } catch (e) {
      print('Error initializing SMS boxes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // تحميل الرسائل
  Future<void> loadMessages() async {
    try {
      if (_messagesBox == null) return;

      messages.value = _messagesBox!.values.toList();
      messages.sort((a, b) => b.sentAt.compareTo(a.sentAt));
    } catch (e) {
      print('Error loading SMS messages: $e');
    }
  }

  // تحميل الإعدادات
  Future<void> loadSettings() async {
    try {
      if (_settingsBox == null) return;

      if (_settingsBox!.isEmpty) {
        // إنشاء إعدادات افتراضية
        final defaultSettings = SmsSettings(
          isEnabled: false,
          costPerMessage: 0.05,
        );
        await _settingsBox!.put('default', defaultSettings);
        settings.value = defaultSettings;
      } else {
        settings.value = _settingsBox!.get('default');
      }
    } catch (e) {
      print('Error loading SMS settings: $e');
    }
  }

  // حفظ الإعدادات
  Future<bool> saveSettings(SmsSettings newSettings) async {
    try {
      if (_settingsBox == null) {
        Get.snackbar('خطأ', 'الرجاء الانتظار حتى يتم تحميل البيانات');
        return false;
      }

      await _settingsBox!.put('default', newSettings);
      settings.value = newSettings;
      return true;
    } catch (e) {
      print('Error saving SMS settings: $e');
      Get.snackbar('خطأ', 'حدث خطأ أثناء حفظ الإعدادات');
      return false;
    }
  }

  // إرسال رسالة SMS
  Future<SmsMessage?> sendSms({
    required String recipient,
    required String message,
    required SmsPurpose purpose,
  }) async {
    try {
      if (_messagesBox == null) {
        Get.snackbar('خطأ', 'الرجاء الانتظار حتى يتم تحميل البيانات');
        return null;
      }

      const uuid = Uuid();
      final parts = (message.length / 70).ceil();
      final cost = parts * (settings.value?.costPerMessage ?? 0.05);

      final smsMessage = SmsMessage(
        id: uuid.v4(),
        recipient: recipient,
        message: message,
        status: SmsStatus.pending,
        purpose: purpose,
        parts: parts,
        cost: cost,
        sentAt: DateTime.now(),
      );

      // محاولة إرسال الرسالة عبر API
      if (settings.value?.isEnabled == true &&
          settings.value?.apiKey != null &&
          settings.value?.apiUrl != null) {
        try {
          await _sendViaApi(smsMessage);
          smsMessage.status = SmsStatus.delivered;
          smsMessage.deliveredAt = DateTime.now();
        } catch (e) {
          smsMessage.status = SmsStatus.failed;
          smsMessage.errorMessage = e.toString();
        }
      } else {
        // في وضع التطوير - محاكاة إرسال فاشل
        smsMessage.status = SmsStatus.failed;
        smsMessage.errorMessage = 'الخدمة غير مفعلة';
      }

      await _messagesBox!.put(smsMessage.id, smsMessage);
      messages.insert(0, smsMessage);

      return smsMessage;
    } catch (e) {
      print('Error sending SMS: $e');
      Get.snackbar('خطأ', 'حدث خطأ أثناء إرسال الرسالة');
      return null;
    }
  }

  // إرسال عبر API
  Future<void> _sendViaApi(SmsMessage message) async {
    if (settings.value?.apiUrl == null || settings.value?.apiKey == null) {
      throw Exception('API غير مكونة');
    }

    final response = await _dio.post(
      settings.value!.apiUrl!,
      data: {
        'recipient': message.recipient,
        'message': message.message,
        'sender_id': settings.value!.senderId,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer ${settings.value!.apiKey}',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('فشل الإرسال: ${response.statusMessage}');
    }
  }

  // إرسال رمز التحقق
  Future<String?> sendVerificationCode(String phoneNumber) async {
    final code = (1000 + DateTime.now().millisecond % 9000).toString();
    final message = 'رمز التحقق الخاص بك هو: $code\nYour verification code is: $code';

    final result = await sendSms(
      recipient: phoneNumber,
      message: message,
      purpose: SmsPurpose.verification,
    );

    return result != null ? code : null;
  }

  // إحصائيات
  int get totalMessages => messages.length;

  int get todayMessages {
    final today = DateTime.now();
    return messages.where((msg) {
      return msg.sentAt.year == today.year &&
          msg.sentAt.month == today.month &&
          msg.sentAt.day == today.day;
    }).length;
  }

  int get deliveredCount => messages.where((msg) => msg.status == SmsStatus.delivered).length;
  int get failedCount => messages.where((msg) => msg.status == SmsStatus.failed).length;

  double get successRate {
    if (messages.isEmpty) return 0.0;
    return (deliveredCount / messages.length) * 100;
  }

  double get totalCost {
    return messages
        .where((msg) => msg.status == SmsStatus.delivered)
        .fold(0.0, (sum, msg) => sum + msg.cost);
  }

  // مسح الذاكرة المؤقتة
  Future<void> clearCache() async {
    try {
      if (_messagesBox == null) return;

      await _messagesBox!.clear();
      messages.clear();
      Get.snackbar('تم', 'تم مسح جميع الرسائل بنجاح');
    } catch (e) {
      print('Error clearing SMS cache: $e');
      Get.snackbar('خطأ', 'حدث خطأ أثناء مسح الذاكرة المؤقتة');
    }
  }

  // حذف رسالة
  Future<bool> deleteMessage(String messageId) async {
    try {
      if (_messagesBox == null) return false;

      await _messagesBox!.delete(messageId);
      messages.removeWhere((msg) => msg.id == messageId);
      return true;
    } catch (e) {
      print('Error deleting SMS message: $e');
      return false;
    }
  }

  // البحث في الرسائل
  List<SmsMessage> searchMessages(String query) {
    if (query.isEmpty) return messages;

    return messages.where((msg) {
      return msg.recipient.contains(query) ||
          msg.message.contains(query);
    }).toList();
  }

  // تصفية حسب الحالة
  List<SmsMessage> filterByStatus(SmsStatus status) {
    return messages.where((msg) => msg.status == status).toList();
  }

  // تصفية حسب الغرض
  List<SmsMessage> filterByPurpose(SmsPurpose purpose) {
    return messages.where((msg) => msg.purpose == purpose).toList();
  }
}
