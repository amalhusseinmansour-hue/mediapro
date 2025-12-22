import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pay/pay.dart';
import '../services/google_apple_pay_service.dart';
import '../services/settings_service.dart';

/// Google Pay & Apple Pay Button Widget
/// Displays Google Pay button on Android and Apple Pay button on iOS
class GoogleApplePayButton extends StatelessWidget {
  final double amount;
  final String description;
  final String? orderId;
  final Function(Map<String, dynamic>) onPaymentSuccess;
  final Function(String)? onPaymentError;
  final EdgeInsets? padding;
  final double? width;
  final double? height;

  const GoogleApplePayButton({
    Key? key,
    required this.amount,
    required this.description,
    this.orderId,
    required this.onPaymentSuccess,
    this.onPaymentError,
    this.padding,
    this.width,
    this.height = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final payService = Get.find<GoogleApplePayService>();
    final settingsService = Get.find<SettingsService>();

    // Check if amount is valid
    if (!payService.isValidAmount(amount)) {
      return _buildMinimumAmountMessage(settingsService.minimumPaymentAmount);
    }

    // Show Google Pay on Android
    if (Platform.isAndroid && payService.isGooglePayAvailable) {
      return _buildGooglePayButton(payService, settingsService);
    }

    // Show Apple Pay on iOS
    if (Platform.isIOS && payService.isApplePayAvailable) {
      return _buildApplePayButton(payService, settingsService);
    }

    // No payment method available
    return _buildUnavailableMessage();
  }

  /// Build Google Pay button
  Widget _buildGooglePayButton(
    GoogleApplePayService payService,
    SettingsService settingsService,
  ) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: GooglePayButton(
        paymentConfiguration: PaymentConfiguration.fromJsonString(
          payService.getGooglePayConfiguration(),
        ),
        paymentItems: payService.createPaymentItems(
          label: description,
          amount: amount,
        ),
        type: _getGooglePayButtonType(settingsService.googlePayButtonType),
        margin: EdgeInsets.zero,
        width: width ?? double.infinity,
        height: height ?? 50,
        onPaymentResult: (result) => _handlePaymentResult(
          result,
          'google_pay',
          payService,
        ),
        loadingIndicator: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  /// Build Apple Pay button
  Widget _buildApplePayButton(
    GoogleApplePayService payService,
    SettingsService settingsService,
  ) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: ApplePayButton(
        paymentConfiguration: PaymentConfiguration.fromJsonString(
          payService.getApplePayConfiguration(),
        ),
        paymentItems: payService.createPaymentItems(
          label: description,
          amount: amount,
        ),
        style: _getApplePayButtonStyle(settingsService.applePayButtonStyle),
        type: _getApplePayButtonType(settingsService.applePayButtonType),
        margin: EdgeInsets.zero,
        width: width ?? double.infinity,
        height: height ?? 50,
        onPaymentResult: (result) => _handlePaymentResult(
          result,
          'apple_pay',
          payService,
        ),
        loadingIndicator: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  /// Build minimum amount message
  Widget _buildMinimumAmountMessage(double minAmount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'الحد الأدنى للدفع: \$$minAmount',
              style: const TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  /// Build unavailable message
  Widget _buildUnavailableMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Google Pay أو Apple Pay غير متاح حالياً',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle payment result
  void _handlePaymentResult(
    Map<String, dynamic> result,
    String paymentMethod,
    GoogleApplePayService payService,
  ) async {
    try {
      print('💳 Payment result received: $result');

      // Process payment based on method
      Map<String, dynamic>? processedResult;

      if (paymentMethod == 'google_pay') {
        processedResult = await payService.processGooglePayPayment(
          amount: amount,
          description: description,
          orderId: orderId,
        );
      } else if (paymentMethod == 'apple_pay') {
        processedResult = await payService.processApplePayPayment(
          amount: amount,
          description: description,
          orderId: orderId,
        );
      }

      if (processedResult != null && processedResult['success'] == true) {
        onPaymentSuccess(processedResult);
      } else {
        final error = processedResult?['error'] ?? 'فشل معالجة الدفع';
        onPaymentError?.call(error);
      }
    } catch (e) {
      print('❌ Payment processing error: $e');
      onPaymentError?.call(e.toString());
    }
  }

  /// Get Google Pay button type
  GooglePayButtonType _getGooglePayButtonType(String type) {
    switch (type.toLowerCase()) {
      case 'buy':
        return GooglePayButtonType.buy;
      case 'donate':
        return GooglePayButtonType.donate;
      case 'pay':
        return GooglePayButtonType.pay;
      case 'plain':
        return GooglePayButtonType.plain;
      default:
        return GooglePayButtonType.pay;
    }
  }

  /// Get Apple Pay button style
  ApplePayButtonStyle _getApplePayButtonStyle(String style) {
    switch (style.toLowerCase()) {
      case 'white':
        return ApplePayButtonStyle.white;
      case 'whiteOutline':
        return ApplePayButtonStyle.whiteOutline;
      case 'automatic':
        return ApplePayButtonStyle.automatic;
      default:
        return ApplePayButtonStyle.black;
    }
  }

  /// Get Apple Pay button type
  ApplePayButtonType _getApplePayButtonType(String type) {
    switch (type.toLowerCase()) {
      case 'plain':
        return ApplePayButtonType.plain;
      case 'buy':
        return ApplePayButtonType.buy;
      case 'setUp':
        return ApplePayButtonType.setUp;
      case 'inStore':
        return ApplePayButtonType.inStore;
      case 'donate':
        return ApplePayButtonType.donate;
      case 'checkout':
        return ApplePayButtonType.checkout;
      case 'book':
        return ApplePayButtonType.book;
      case 'subscribe':
        return ApplePayButtonType.subscribe;
      default:
        return ApplePayButtonType.buy;
    }
  }
}
