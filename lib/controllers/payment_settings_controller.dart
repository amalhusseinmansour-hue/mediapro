import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../services/paymob_service.dart';
import '../models/payment_transaction_model.dart' as transaction_models;
import '../models/payment_gateway_config_model.dart';

/// كونترولر إعدادات الدفع
class PaymentSettingsController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();
  final PaymobService _paymobService = Get.find<PaymobService>();

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isTesting = false.obs;
  final RxString selectedTab =
      'statistics'.obs; // statistics, gateways, test, transactions

  // Payment statistics
  final RxDouble totalAmount = 0.0.obs;
  final RxDouble successfulAmount = 0.0.obs;
  final RxInt totalCount = 0.obs;
  final RxInt successfulCount = 0.obs;
  final RxInt failedCount = 0.obs;
  final RxInt pendingCount = 0.obs;
  final RxDouble successRate = 0.0.obs;

  // Payment gateways
  final RxList<PaymentGatewayConfigModel> gateways =
      <PaymentGatewayConfigModel>[].obs;

  // Payment transactions
  final RxList<transaction_models.PaymentTransactionModel> transactions =
      <transaction_models.PaymentTransactionModel>[].obs;

  // Stream subscriptions
  StreamSubscription? _transactionsSubscription;
  StreamSubscription? _gatewaysSubscription;

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
    await Future.wait([loadStatistics(), loadGateways(), loadTransactions()]);
  }

  /// تحميل الإحصائيات
  Future<void> loadStatistics() async {
    try {
      isLoading.value = true;

      final userId = _authService.currentUser.value?.id;
      if (userId == null) return;

      final stats = await _firestoreService.getPaymentStatistics(userId);

      totalAmount.value = stats['totalAmount'] ?? 0.0;
      successfulAmount.value = stats['successfulAmount'] ?? 0.0;
      totalCount.value = stats['totalCount'] ?? 0;
      successfulCount.value = stats['successfulCount'] ?? 0;
      failedCount.value = stats['failedCount'] ?? 0;
      pendingCount.value = stats['pendingCount'] ?? 0;
      successRate.value = stats['successRate'] ?? 0.0;
    } catch (e) {
      print('خطأ في تحميل الإحصائيات: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// تحميل بوابات الدفع
  Future<void> loadGateways() async {
    try {
      isLoading.value = true;

      var gatewaysList = await _firestoreService.getAllPaymentGatewayConfigs();

      // إذا لم توجد بوابات، أنشئ البوابات الافتراضية
      if (gatewaysList.isEmpty) {
        gatewaysList = PaymentGatewayConfigModel.getDefaultGateways();
        for (var gateway in gatewaysList) {
          await _firestoreService.savePaymentGatewayConfig(gateway);
        }
      }

      gateways.value = gatewaysList;
    } catch (e) {
      print('خطأ في تحميل بوابات الدفع: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// تحميل المعاملات
  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;

      final userId = _authService.currentUser.value?.id;
      if (userId == null) return;

      final transactionsList = await _firestoreService
          .getUserPaymentTransactions(userId);

      transactions.value = transactionsList;
    } catch (e) {
      print('خطأ في تحميل المعاملات: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// بدء الاستماع للتحديثات
  void startListening() {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return;

    // الاستماع للمعاملات
    _transactionsSubscription = _firestoreService
        .listenToUserPaymentTransactions(userId)
        .listen((transactionsList) {
          transactions.value = transactionsList;
          loadStatistics(); // تحديث الإحصائيات
        });

    // الاستماع لبوابات الدفع
    _gatewaysSubscription = _firestoreService
        .listenToPaymentGatewayConfigs()
        .listen((gatewaysList) {
          gateways.value = gatewaysList;
        });
  }

  /// إيقاف الاستماع
  void stopListening() {
    _transactionsSubscription?.cancel();
    _gatewaysSubscription?.cancel();
  }

  /// حفظ إعدادات البوابة
  Future<bool> saveGatewayConfig(PaymentGatewayConfigModel config) async {
    try {
      isLoading.value = true;

      final success = await _firestoreService.savePaymentGatewayConfig(config);

      if (success) {
        Get.snackbar(
          'نجح',
          'تم حفظ إعدادات ${config.displayName} بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await loadGateways();
      } else {
        Get.snackbar(
          'خطأ',
          'فشل حفظ إعدادات البوابة',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

      return success;
    } catch (e) {
      print('خطأ في حفظ إعدادات البوابة: $e');
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

  /// اختبار بوابة الدفع
  Future<void> testGateway(PaymentGatewayConfigModel gateway) async {
    try {
      isTesting.value = true;

      Get.snackbar(
        'اختبار',
        'جاري اختبار ${gateway.displayName}...',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      final userId = _authService.currentUser.value?.id;
      final userEmail = _authService.currentUser.value?.email;
      final userName = _authService.currentUser.value?.name ?? 'Test User';
      final userPhone =
          _authService.currentUser.value?.phoneNumber ?? '+971000000000';

      if (userId == null || userEmail == null) {
        throw 'المستخدم غير مسجل دخول';
      }

      // إنشاء معاملة اختبار بمبلغ 1 درهم
      final result = await _paymobService.initiatePayment(
        userId: userId,
        userEmail: userEmail,
        userName: userName,
        userPhone: userPhone,
        subscriptionTier: 'test',
        amount: 1.0,
        currency: 'AED',
      );

      if (result.isSuccess) {
        Get.snackbar(
          'نجح الاختبار',
          'تم إنشاء معاملة اختبار بنجاح!\nمعرف الطلب: ${result.orderId}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );

        // إنشاء معاملة في قاعدة البيانات
        final transaction = transaction_models.PaymentTransactionModel(
          id: '',
          userId: userId,
          orderId: result.orderId.toString(),
          paymentKey: result.paymentKey,
          amount: 1.0,
          currency: 'AED',
          gateway: gateway.name,
          status: transaction_models.PaymentStatus.pending,
          metadata: {'isTest': true},
          createdAt: DateTime.now(),
        );

        await _firestoreService.createPaymentTransaction(transaction);
      } else {
        throw result.errorMessage ?? 'فشل الاختبار';
      }
    } catch (e) {
      print('خطأ في اختبار البوابة: $e');
      Get.snackbar(
        'فشل الاختبار',
        'حدث خطأ أثناء الاختبار: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isTesting.value = false;
    }
  }

  /// حذف بوابة دفع
  Future<void> deleteGateway(String gatewayId) async {
    try {
      isLoading.value = true;

      final success = await _firestoreService.deletePaymentGatewayConfig(
        gatewayId,
      );

      if (success) {
        Get.snackbar(
          'نجح',
          'تم حذف البوابة بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await loadGateways();
      }
    } catch (e) {
      print('خطأ في حذف البوابة: $e');
      Get.snackbar(
        'خطأ',
        'فشل حذف البوابة: $e',
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

  /// تصدير المعاملات إلى CSV
  String exportTransactionsToCSV() {
    final buffer = StringBuffer();

    // الرؤوس
    buffer.writeln('ID,Date,Amount,Currency,Gateway,Status');

    // البيانات
    for (var transaction in transactions) {
      buffer.writeln(
        '${transaction.orderId},'
        '${transaction.createdAt.toString()},'
        '${transaction.amount},'
        '${transaction.currency},'
        '${transaction.gateway},'
        '${transaction.statusNameAr}',
      );
    }

    return buffer.toString();
  }

  /// فلترة المعاملات حسب الحالة
  List<transaction_models.PaymentTransactionModel> getTransactionsByStatus(
    transaction_models.PaymentStatus status,
  ) {
    return transactions.where((t) => t.status == status).toList();
  }

  /// فلترة المعاملات حسب البوابة
  List<transaction_models.PaymentTransactionModel> getTransactionsByGateway(
    String gateway,
  ) {
    return transactions.where((t) => t.gateway == gateway).toList();
  }
}
