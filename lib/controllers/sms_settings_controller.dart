import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/sms_message_model.dart';
import '../models/sms_provider_model.dart';

/// كونترولر إعدادات SMS
class SMSSettingsController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxString selectedTab =
      'statistics'.obs; // statistics, providers, messages, test

  // SMS statistics
  final RxInt totalCount = 0.obs;
  final RxInt sentCount = 0.obs;
  final RxInt deliveredCount = 0.obs;
  final RxInt failedCount = 0.obs;
  final RxInt pendingCount = 0.obs;
  final RxDouble totalCost = 0.0.obs;
  final RxDouble deliveryRate = 0.0.obs;
  final RxDouble failureRate = 0.0.obs;

  // SMS providers
  final RxList<SMSProviderModel> providers = <SMSProviderModel>[].obs;

  // SMS messages
  final RxList<SMSMessageModel> messages = <SMSMessageModel>[].obs;

  // Stream subscriptions
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _providersSubscription;

  // Test phone number
  final RxString testPhoneNumber = '+971'.obs;
  final RxString testMessage =
      'هذه رسالة اختبار من تطبيق Social Media Manager'.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
    startListening();
  }

  @override
  void onClose() {
    stopListening();
    super.onClose();
  }

  /// تحميل البيانات
  Future<void> loadData() async {
    await Future.wait([loadStatistics(), loadProviders(), loadMessages()]);
  }

  /// تحميل الإحصائيات
  Future<void> loadStatistics() async {
    try {
      isLoading.value = true;

      final userId = _authService.currentUser.value?.id;
      if (userId == null) return;

      final stats = await _firestoreService.getSMSStatistics(userId);

      totalCount.value = stats['totalCount'] ?? 0;
      sentCount.value = stats['sentCount'] ?? 0;
      deliveredCount.value = stats['deliveredCount'] ?? 0;
      failedCount.value = stats['failedCount'] ?? 0;
      pendingCount.value = stats['pendingCount'] ?? 0;
      totalCost.value = stats['totalCost'] ?? 0.0;
      deliveryRate.value = stats['deliveryRate'] ?? 0.0;
      failureRate.value = stats['failureRate'] ?? 0.0;
    } catch (e) {
      print('خطأ في تحميل الإحصائيات: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// تحميل المزودين
  Future<void> loadProviders() async {
    try {
      isLoading.value = true;

      var providersList = await _firestoreService.getAllSMSProviderConfigs();

      // إذا لم توجد مزودين، أنشئ المزودين الافتراضيين
      if (providersList.isEmpty) {
        providersList = SMSProviderModel.getDefaultProviders();
        for (var provider in providersList) {
          await _firestoreService.saveSMSProviderConfig(provider);
        }
      }

      providers.value = providersList;
    } catch (e) {
      print('خطأ في تحميل المزودين: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// تحميل الرسائل
  Future<void> loadMessages() async {
    try {
      isLoading.value = true;

      final userId = _authService.currentUser.value?.id;
      if (userId == null) return;

      final messagesList = await _firestoreService.getUserSMSMessages(userId);

      messages.value = messagesList;
    } catch (e) {
      print('خطأ في تحميل الرسائل: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// بدء الاستماع للتحديثات
  void startListening() {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return;

    // الاستماع للرسائل
    _messagesSubscription = _firestoreService
        .listenToUserSMSMessages(userId)
        .listen((messagesList) {
          messages.value = messagesList;
          loadStatistics(); // تحديث الإحصائيات
        });

    // الاستماع للمزودين
    _providersSubscription = _firestoreService
        .listenToSMSProviderConfigs()
        .listen((providersList) {
          providers.value = providersList;
        });
  }

  /// إيقاف الاستماع
  void stopListening() {
    _messagesSubscription?.cancel();
    _providersSubscription?.cancel();
  }

  /// حفظ إعدادات المزود
  Future<bool> saveProviderConfig(SMSProviderModel config) async {
    try {
      isLoading.value = true;

      final success = await _firestoreService.saveSMSProviderConfig(config);

      if (success) {
        Get.snackbar(
          'نجح',
          'تم حفظ إعدادات ${config.displayName} بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await loadProviders();
      } else {
        Get.snackbar(
          'خطأ',
          'فشل حفظ إعدادات المزود',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

      return success;
    } catch (e) {
      print('خطأ في حفظ إعدادات المزود: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء الحفظ: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// اختبار المزود
  Future<void> testProvider(SMSProviderModel provider) async {
    try {
      if (testPhoneNumber.value.length < 10) {
        Get.snackbar(
          'خطأ',
          'الرجاء إدخال رقم هاتف صحيح',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isSending.value = true;

      Get.snackbar(
        'إرسال',
        'جاري إرسال رسالة اختبار...',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      final userId = _authService.currentUser.value?.id;
      if (userId == null) {
        throw 'المستخدم غير مسجل دخول';
      }

      // إنشاء رسالة اختبار
      final message = SMSMessageModel(
        id: '',
        userId: userId,
        phoneNumber: testPhoneNumber.value,
        message: testMessage.value,
        provider: provider.name,
        status: SMSStatus.pending,
        cost: provider.costPerMessage,
        metadata: {'isTest': true},
        createdAt: DateTime.now(),
      );

      final messageId = await _firestoreService.createSMSMessage(message);

      if (messageId != null) {
        // محاكاة الإرسال (في التطبيق الحقيقي، ستستدعي API المزود)
        await Future.delayed(const Duration(seconds: 2));

        await _firestoreService.updateSMSMessage(messageId, {
          'status': SMSStatus.sent.toString().split('.').last,
          'messageId': 'test_msg_${DateTime.now().millisecondsSinceEpoch}',
          'sentAt': Timestamp.fromDate(DateTime.now()),
        });

        Get.snackbar(
          'نجح',
          'تم إرسال رسالة الاختبار بنجاح!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        throw 'فشل إنشاء الرسالة';
      }
    } catch (e) {
      print('خطأ في اختبار المزود: $e');
      Get.snackbar(
        'فشل',
        'حدث خطأ أثناء الإرسال: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isSending.value = false;
    }
  }

  /// حذف مزود
  Future<void> deleteProvider(String providerId) async {
    try {
      isLoading.value = true;

      final success = await _firestoreService.deleteSMSProviderConfig(
        providerId,
      );

      if (success) {
        Get.snackbar(
          'نجح',
          'تم حذف المزود بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await loadProviders();
      }
    } catch (e) {
      print('خطأ في حذف المزود: $e');
      Get.snackbar(
        'خطأ',
        'فشل حذف المزود: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// تغيير التبويب
  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  /// تحديث البيانات
  @override
  Future<void> refresh() async {
    await loadData();
  }

  /// تصدير الرسائل إلى CSV
  String exportMessagesToCSV() {
    final buffer = StringBuffer();

    // الرؤوس
    buffer.writeln('Date,Phone Number,Message,Provider,Status,Cost');

    // البيانات
    for (var message in messages) {
      buffer.writeln(
        '${message.createdAt.toString()},'
        '${message.phoneNumber},'
        '"${message.message}",'
        '${message.provider},'
        '${message.statusNameAr},'
        '${message.cost ?? 0.0}',
      );
    }

    return buffer.toString();
  }

  /// فلترة الرسائل حسب الحالة
  List<SMSMessageModel> getMessagesByStatus(SMSStatus status) {
    return messages.where((m) => m.status == status).toList();
  }

  /// فلترة الرسائل حسب المزود
  List<SMSMessageModel> getMessagesByProvider(String provider) {
    return messages.where((m) => m.provider == provider).toList();
  }

  /// الحصول على إحصائيات لكل مزود
  Map<String, int> getMessageCountByProvider() {
    final counts = <String, int>{};
    for (var message in messages) {
      counts[message.provider] = (counts[message.provider] ?? 0) + 1;
    }
    return counts;
  }
}
