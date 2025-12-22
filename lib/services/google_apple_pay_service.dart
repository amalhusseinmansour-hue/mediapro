import 'dart:convert';
import 'package:get/get.dart';
import 'package:pay/pay.dart';
import 'settings_service.dart';

/// Google Pay & Apple Pay Service
/// Handles both Google Pay and Apple Pay payments
class GoogleApplePayService extends GetxController {
  final SettingsService _settingsService = Get.find<SettingsService>();

  // Observable payment status
  final RxBool isProcessing = false.obs;
  final RxString lastError = ''.obs;

  /// Check if Google Pay is available
  bool get isGooglePayAvailable {
    return _settingsService.googlePayEnabled &&
           _settingsService.googlePayMerchantId.isNotEmpty;
  }

  /// Check if Apple Pay is available
  bool get isApplePayAvailable {
    return _settingsService.applePayEnabled &&
           _settingsService.applePayMerchantId.isNotEmpty;
  }

  /// Get Google Pay configuration
  String getGooglePayConfiguration() {
    final gateway = _settingsService.googlePayGateway;
    final gatewayMerchantId = _settingsService.googlePayGatewayMerchantId;
    final merchantId = _settingsService.googlePayMerchantId;
    final merchantName = _settingsService.googlePayMerchantName;
    final environment = _settingsService.googlePayEnvironment;

    return json.encode({
      'provider': 'google_pay',
      'data': {
        'environment': environment,
        'apiVersion': 2,
        'apiVersionMinor': 0,
        'allowedPaymentMethods': [
          {
            'type': 'CARD',
            'tokenizationSpecification': {
              'type': 'PAYMENT_GATEWAY',
              'parameters': {
                'gateway': gateway,
                'gatewayMerchantId': gatewayMerchantId,
              }
            },
            'parameters': {
              'allowedCardNetworks': ['VISA', 'MASTERCARD', 'AMEX'],
              'allowedAuthMethods': ['PAN_ONLY', 'CRYPTOGRAM_3DS'],
              'billingAddressRequired': _settingsService.googlePayBillingAddressRequired,
              'billingAddressParameters': {
                'format': 'FULL',
                'phoneNumberRequired': _settingsService.googlePayPhoneRequired,
              }
            }
          }
        ],
        'merchantInfo': {
          'merchantId': merchantId,
          'merchantName': merchantName,
        },
        'transactionInfo': {
          'countryCode': 'AE',
          'currencyCode': _settingsService.currency,
        }
      }
    });
  }

  /// Get Apple Pay configuration
  String getApplePayConfiguration() {
    final merchantId = _settingsService.applePayMerchantId;
    final merchantName = _settingsService.applePayMerchantName;
    final countryCode = _settingsService.applePayCountryCode;
    final currencyCode = _settingsService.applePayCurrencyCode;

    return json.encode({
      'provider': 'apple_pay',
      'data': {
        'merchantIdentifier': merchantId,
        'displayName': merchantName,
        'merchantCapabilities': ['3DS', 'debit', 'credit'],
        'supportedNetworks': ['visa', 'mastercard', 'amex'],
        'countryCode': countryCode,
        'currencyCode': currencyCode,
        'requiredBillingContactFields': _settingsService.applePayRequireBilling
            ? ['postalAddress']
            : [],
        'requiredShippingContactFields': _settingsService.applePayRequireShipping
            ? ['postalAddress', 'name', 'phone']
            : [],
      }
    });
  }

  /// Create payment items for Google/Apple Pay
  List<PaymentItem> createPaymentItems({
    required String label,
    required double amount,
    String? type,
  }) {
    return [
      PaymentItem(
        label: label,
        amount: amount.toStringAsFixed(2),
        status: PaymentItemStatus.final_price,
        type: type != null
            ? (type == 'pending'
                ? PaymentItemType.item
                : PaymentItemType.total)
            : PaymentItemType.total,
      )
    ];
  }

  /// Process Google Pay payment
  Future<Map<String, dynamic>?> processGooglePayPayment({
    required double amount,
    required String description,
    String? orderId,
  }) async {
    try {
      isProcessing.value = true;
      lastError.value = '';

      print('📱 Processing Google Pay payment: \$$amount');

      // Create payment configuration
      final paymentConfiguration = PaymentConfiguration.fromJsonString(
        getGooglePayConfiguration(),
      );

      // TODO: Implement actual payment processing
      // This is where you would integrate with your backend
      // to process the payment through the configured gateway (Stripe, Paymob, etc.)

      // Return success response
      return {
        'success': true,
        'payment_method': 'google_pay',
        'amount': amount,
        'order_id': orderId,
        'description': description,
      };
    } catch (e) {
      lastError.value = e.toString();
      print('❌ Google Pay payment error: $e');
      return null;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Process Apple Pay payment
  Future<Map<String, dynamic>?> processApplePayPayment({
    required double amount,
    required String description,
    String? orderId,
  }) async {
    try {
      isProcessing.value = true;
      lastError.value = '';

      print('🍎 Processing Apple Pay payment: \$$amount');

      // Create payment configuration
      final paymentConfiguration = PaymentConfiguration.fromJsonString(
        getApplePayConfiguration(),
      );

      // TODO: Implement actual payment processing
      // This is where you would integrate with your backend
      // to process the payment through the configured gateway (Stripe, Paymob, etc.)

      // Return success response
      return {
        'success': true,
        'payment_method': 'apple_pay',
        'amount': amount,
        'order_id': orderId,
        'description': description,
      };
    } catch (e) {
      lastError.value = e.toString();
      print('❌ Apple Pay payment error: $e');
      return null;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Get available payment methods
  List<String> getAvailablePaymentMethods() {
    final methods = <String>[];

    if (_settingsService.stripeEnabled) methods.add('stripe');
    if (_settingsService.paymobEnabled) methods.add('paymob');
    if (_settingsService.paypalEnabled) methods.add('paypal');
    if (isGooglePayAvailable) methods.add('google_pay');
    if (isApplePayAvailable) methods.add('apple_pay');

    return methods;
  }

  /// Check if payment amount is valid
  bool isValidAmount(double amount) {
    return amount >= _settingsService.minimumPaymentAmount;
  }

  /// Get minimum payment amount
  double get minimumAmount => _settingsService.minimumPaymentAmount;

  /// Get payment currency
  String get currency => _settingsService.currency;
}
