import 'package:get/get.dart';
import 'paymob_service.dart';
import 'app_events_tracker.dart';
import '../screens/payment/payment_webview_screen.dart';
import '../core/config/paymob_config.dart';

class PaymentService extends GetxService {
  final RxBool isLoading = false.obs;
  final RxString lastPaymentStatus = ''.obs;
  final PaymobService _paymobService = PaymobService();

  Future<PaymentService> init() async {
    print('🔷 Initializing PaymentService...');
    print('✅ PaymentService initialized');
    return this;
  }

  /// Process payment via Paymob (actual implementation)
  Future<bool> processPayment({
    required double amount,
    required String description,
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      isLoading.value = true;
      lastPaymentStatus.value = 'processing';

      print('💳 Processing payment: $amount AED');
      print('📝 Description: $description');

      // Initiate payment with Paymob
      final paymentResult = await _paymobService.initiatePayment(
        userId: userId ?? 'guest',
        userEmail: metadata?['userEmail'] ?? 'user@example.com',
        userName: metadata?['userName'] ?? 'User',
        userPhone: metadata?['userPhone'] ?? '+971500000000',
        subscriptionTier: description,
        amount: amount,
        currency: 'AED',
      );

      if (!paymentResult.isSuccess) {
        print('❌ Payment failed: ${paymentResult.errorMessage}');
        lastPaymentStatus.value = 'failed';

        // تتبع فشل الدفع في Telegram (خفي)
        try {
          final tracker = Get.find<AppEventsTracker>();
          await tracker.trackPaymentAttempt(
            amount: amount,
            paymentMethod: 'Paymob',
            success: false,
            errorMessage: paymentResult.errorMessage,
          );
          print('📊 Failed payment tracked in background Telegram service');
        } catch (e) {
          print('⚠️ Failed to track payment attempt (non-critical): $e');
        }

        return false;
      }

      // Open payment WebView
      if (paymentResult.paymentUrl != null) {
        final success = await _openPaymentWebView(paymentResult.paymentUrl!);

        if (success) {
          lastPaymentStatus.value = 'completed';
          print('✅ Payment completed successfully');

          // تتبع نجاح الدفع في Telegram (خفي)
          try {
            final tracker = Get.find<AppEventsTracker>();
            await tracker.trackPaymentAttempt(
              amount: amount,
              paymentMethod: 'Paymob',
              success: true,
            );
            print('📊 Successful payment tracked in background Telegram service');
          } catch (e) {
            print('⚠️ Failed to track payment attempt (non-critical): $e');
          }

          return true;
        } else {
          lastPaymentStatus.value = 'failed';
          print('❌ Payment was cancelled or failed');

          // تتبع إلغاء الدفع في Telegram (خفي)
          try {
            final tracker = Get.find<AppEventsTracker>();
            await tracker.trackPaymentAttempt(
              amount: amount,
              paymentMethod: 'Paymob',
              success: false,
              errorMessage: 'Payment cancelled by user',
            );
            print('📊 Cancelled payment tracked in background Telegram service');
          } catch (e) {
            print('⚠️ Failed to track payment attempt (non-critical): $e');
          }

          return false;
        }
      }

      lastPaymentStatus.value = 'failed';
      return false;
    } catch (e) {
      print('❌ Payment error: $e');
      lastPaymentStatus.value = 'failed';

      // تتبع خطأ الدفع في Telegram (خفي)
      try {
        final tracker = Get.find<AppEventsTracker>();
        await tracker.trackPaymentAttempt(
          amount: amount,
          paymentMethod: 'Paymob',
          success: false,
          errorMessage: e.toString(),
        );
        print('📊 Payment error tracked in background Telegram service');
      } catch (trackError) {
        print('⚠️ Failed to track payment attempt (non-critical): $trackError');
      }

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Open payment WebView for user to complete payment
  Future<bool> _openPaymentWebView(String paymentUrl) async {
    // In test mode, simulate successful payment
    if (paymentUrl == 'test_mode') {
      print('⚠️ Test mode: Simulating successful payment');
      await Future.delayed(const Duration(seconds: 2));
      return true;
    }

    print('🌐 Opening payment WebView: $paymentUrl');

    try {
      // Navigate to payment WebView screen
      final result = await Get.to<bool>(
        () => PaymentWebViewScreen(
          paymentUrl: paymentUrl,
          callbackUrl: PaymobConfig.callbackUrl,
        ),
        transition: Transition.cupertino,
        fullscreenDialog: true,
      );

      // Return the result (true if payment succeeded, false if cancelled/failed)
      return result ?? false;
    } catch (e) {
      print('❌ Error opening payment WebView: $e');
      return false;
    }
  }

  /// Get payment status
  String getPaymentStatus() {
    return lastPaymentStatus.value;
  }

  /// Reset payment service
  void reset() {
    lastPaymentStatus.value = '';
    isLoading.value = false;
  }
}
