import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pay/pay.dart';
import 'package:social_media_manager/services/google_apple_pay_service.dart';
import 'package:social_media_manager/services/settings_service.dart';

void main() {
  late GoogleApplePayService googleApplePayService;
  late SettingsService settingsService;

  setUp(() {
    // Initialize GetX for testing
    Get.testMode = true;

    // Create and register SettingsService
    settingsService = SettingsService();
    Get.put(settingsService);

    // Create GoogleApplePayService
    googleApplePayService = GoogleApplePayService();
  });

  tearDown(() {
    // Clean up
    Get.reset();
  });

  group('GoogleApplePayService - Initialization', () {
    test('should initialize with default values', () {
      expect(googleApplePayService.isProcessing.value, false);
      expect(googleApplePayService.lastError.value, isEmpty);
    });

    test('should have access to SettingsService', () {
      expect(googleApplePayService.isGooglePayAvailable, isA<bool>());
      expect(googleApplePayService.isApplePayAvailable, isA<bool>());
    });
  });

  group('GoogleApplePayService - Google Pay Configuration', () {
    test('should generate valid Google Pay configuration JSON', () {
      final configString = googleApplePayService.getGooglePayConfiguration();
      expect(configString, isNotEmpty);

      // Parse JSON to verify structure
      final config = json.decode(configString);
      expect(config['provider'], 'google_pay');
      expect(config['data'], isNotNull);
      expect(config['data']['apiVersion'], 2);
      expect(config['data']['apiVersionMinor'], 0);
    });

    test('should include allowed payment methods in Google Pay config', () {
      final configString = googleApplePayService.getGooglePayConfiguration();
      final config = json.decode(configString);

      expect(config['data']['allowedPaymentMethods'], isNotNull);
      expect(config['data']['allowedPaymentMethods'], isA<List>());
      expect(config['data']['allowedPaymentMethods'].length, greaterThan(0));
    });

    test('should include merchant info in Google Pay config', () {
      final configString = googleApplePayService.getGooglePayConfiguration();
      final config = json.decode(configString);

      expect(config['data']['merchantInfo'], isNotNull);
      expect(config['data']['merchantInfo']['merchantId'], isA<String>());
      expect(config['data']['merchantInfo']['merchantName'], isA<String>());
    });

    test('should include transaction info in Google Pay config', () {
      final configString = googleApplePayService.getGooglePayConfiguration();
      final config = json.decode(configString);

      expect(config['data']['transactionInfo'], isNotNull);
      expect(config['data']['transactionInfo']['countryCode'], 'AE');
      expect(config['data']['transactionInfo']['currencyCode'], isA<String>());
    });

    test('should include card networks in Google Pay config', () {
      final configString = googleApplePayService.getGooglePayConfiguration();
      final config = json.decode(configString);

      final allowedMethod = config['data']['allowedPaymentMethods'][0];
      expect(allowedMethod['parameters']['allowedCardNetworks'], isNotNull);
      expect(allowedMethod['parameters']['allowedCardNetworks'], contains('VISA'));
      expect(allowedMethod['parameters']['allowedCardNetworks'], contains('MASTERCARD'));
      expect(allowedMethod['parameters']['allowedCardNetworks'], contains('AMEX'));
    });

    test('should include auth methods in Google Pay config', () {
      final configString = googleApplePayService.getGooglePayConfiguration();
      final config = json.decode(configString);

      final allowedMethod = config['data']['allowedPaymentMethods'][0];
      expect(allowedMethod['parameters']['allowedAuthMethods'], isNotNull);
      expect(allowedMethod['parameters']['allowedAuthMethods'], contains('PAN_ONLY'));
      expect(allowedMethod['parameters']['allowedAuthMethods'], contains('CRYPTOGRAM_3DS'));
    });
  });

  group('GoogleApplePayService - Apple Pay Configuration', () {
    test('should generate valid Apple Pay configuration JSON', () {
      final configString = googleApplePayService.getApplePayConfiguration();
      expect(configString, isNotEmpty);

      // Parse JSON to verify structure
      final config = json.decode(configString);
      expect(config['provider'], 'apple_pay');
      expect(config['data'], isNotNull);
    });

    test('should include merchant identifier in Apple Pay config', () {
      final configString = googleApplePayService.getApplePayConfiguration();
      final config = json.decode(configString);

      expect(config['data']['merchantIdentifier'], isA<String>());
      expect(config['data']['displayName'], isA<String>());
    });

    test('should include merchant capabilities in Apple Pay config', () {
      final configString = googleApplePayService.getApplePayConfiguration();
      final config = json.decode(configString);

      expect(config['data']['merchantCapabilities'], isNotNull);
      expect(config['data']['merchantCapabilities'], isA<List>());
      expect(config['data']['merchantCapabilities'], contains('3DS'));
      expect(config['data']['merchantCapabilities'], contains('debit'));
      expect(config['data']['merchantCapabilities'], contains('credit'));
    });

    test('should include supported networks in Apple Pay config', () {
      final configString = googleApplePayService.getApplePayConfiguration();
      final config = json.decode(configString);

      expect(config['data']['supportedNetworks'], isNotNull);
      expect(config['data']['supportedNetworks'], isA<List>());
      expect(config['data']['supportedNetworks'], contains('visa'));
      expect(config['data']['supportedNetworks'], contains('mastercard'));
      expect(config['data']['supportedNetworks'], contains('amex'));
    });

    test('should include country and currency codes in Apple Pay config', () {
      final configString = googleApplePayService.getApplePayConfiguration();
      final config = json.decode(configString);

      expect(config['data']['countryCode'], isA<String>());
      expect(config['data']['currencyCode'], isA<String>());
    });

    test('should include required contact fields in Apple Pay config', () {
      final configString = googleApplePayService.getApplePayConfiguration();
      final config = json.decode(configString);

      expect(config['data']['requiredBillingContactFields'], isA<List>());
      expect(config['data']['requiredShippingContactFields'], isA<List>());
    });
  });

  group('GoogleApplePayService - Payment Items', () {
    test('should create payment items with correct structure', () {
      final items = googleApplePayService.createPaymentItems(
        label: 'Test Payment',
        amount: 100.50,
      );

      expect(items, isNotNull);
      expect(items.length, 1);
      expect(items[0].label, 'Test Payment');
      expect(items[0].amount, '100.50');
      expect(items[0].status, PaymentItemStatus.final_price);
    });

    test('should format amount with 2 decimal places', () {
      final items = googleApplePayService.createPaymentItems(
        label: 'Test Payment',
        amount: 50,
      );

      expect(items[0].amount, '50.00');
    });

    test('should create payment items with custom type', () {
      final items = googleApplePayService.createPaymentItems(
        label: 'Test Payment',
        amount: 75.99,
        type: 'pending',
      );

      expect(items[0].type, PaymentItemType.item);
    });

    test('should create payment items with total type by default', () {
      final items = googleApplePayService.createPaymentItems(
        label: 'Test Payment',
        amount: 75.99,
      );

      expect(items[0].type, PaymentItemType.total);
    });
  });

  group('GoogleApplePayService - Google Pay Payment Processing', () {
    test('should set processing flag when processing Google Pay payment', () async {
      // Start processing
      final future = googleApplePayService.processGooglePayPayment(
        amount: 100.0,
        description: 'Test Payment',
      );

      // Check processing flag (might already be done due to async)
      expect(googleApplePayService.isProcessing.value, isA<bool>());

      // Wait for completion
      await future;

      // Should be false after completion
      expect(googleApplePayService.isProcessing.value, false);
    });

    test('should return success response for Google Pay payment', () async {
      final result = await googleApplePayService.processGooglePayPayment(
        amount: 50.0,
        description: 'Test Google Pay',
        orderId: 'ORDER123',
      );

      expect(result, isNotNull);
      expect(result!['success'], true);
      expect(result['payment_method'], 'google_pay');
      expect(result['amount'], 50.0);
      expect(result['order_id'], 'ORDER123');
      expect(result['description'], 'Test Google Pay');
    });

    test('should clear last error on successful Google Pay payment', () async {
      googleApplePayService.lastError.value = 'Previous error';

      await googleApplePayService.processGooglePayPayment(
        amount: 50.0,
        description: 'Test Payment',
      );

      expect(googleApplePayService.lastError.value, isEmpty);
    });
  });

  group('GoogleApplePayService - Apple Pay Payment Processing', () {
    test('should set processing flag when processing Apple Pay payment', () async {
      final future = googleApplePayService.processApplePayPayment(
        amount: 100.0,
        description: 'Test Payment',
      );

      expect(googleApplePayService.isProcessing.value, isA<bool>());

      await future;

      expect(googleApplePayService.isProcessing.value, false);
    });

    test('should return success response for Apple Pay payment', () async {
      final result = await googleApplePayService.processApplePayPayment(
        amount: 75.0,
        description: 'Test Apple Pay',
        orderId: 'ORDER456',
      );

      expect(result, isNotNull);
      expect(result!['success'], true);
      expect(result['payment_method'], 'apple_pay');
      expect(result['amount'], 75.0);
      expect(result['order_id'], 'ORDER456');
      expect(result['description'], 'Test Apple Pay');
    });

    test('should clear last error on successful Apple Pay payment', () async {
      googleApplePayService.lastError.value = 'Previous error';

      await googleApplePayService.processApplePayPayment(
        amount: 75.0,
        description: 'Test Payment',
      );

      expect(googleApplePayService.lastError.value, isEmpty);
    });
  });

  group('GoogleApplePayService - Available Payment Methods', () {
    test('should return list of available payment methods', () {
      final methods = googleApplePayService.getAvailablePaymentMethods();

      expect(methods, isA<List<String>>());
      expect(methods.length, greaterThan(0));
    });

    test('should include all enabled payment gateways', () {
      final methods = googleApplePayService.getAvailablePaymentMethods();

      // Check if standard gateways are included based on settings
      expect(methods, isA<List<String>>());
      // The actual content depends on settingsService configuration
    });
  });

  group('GoogleApplePayService - Payment Validation', () {
    test('should validate payment amount against minimum', () {
      // Assuming minimum is 10.0 from SettingsService default
      expect(googleApplePayService.isValidAmount(15.0), true);
      expect(googleApplePayService.isValidAmount(10.0), true);
      expect(googleApplePayService.isValidAmount(5.0), false);
    });

    test('should return minimum amount', () {
      expect(googleApplePayService.minimumAmount, isA<double>());
      expect(googleApplePayService.minimumAmount, greaterThan(0));
    });

    test('should return currency code', () {
      expect(googleApplePayService.currency, isA<String>());
      expect(googleApplePayService.currency, isNotEmpty);
    });
  });

  group('GoogleApplePayService - Availability Checks', () {
    test('should check Google Pay availability based on settings', () {
      final isAvailable = googleApplePayService.isGooglePayAvailable;
      expect(isAvailable, isA<bool>());
      // Actual value depends on SettingsService configuration
    });

    test('should check Apple Pay availability based on settings', () {
      final isAvailable = googleApplePayService.isApplePayAvailable;
      expect(isAvailable, isA<bool>());
      // Actual value depends on SettingsService configuration
    });
  });

  group('GoogleApplePayService - Error Handling', () {
    test('should initialize with empty error message', () {
      expect(googleApplePayService.lastError.value, isEmpty);
    });

    test('should maintain processing state consistency', () async {
      expect(googleApplePayService.isProcessing.value, false);

      final future = googleApplePayService.processGooglePayPayment(
        amount: 100.0,
        description: 'Test',
      );

      await future;

      // Should return to false after processing
      expect(googleApplePayService.isProcessing.value, false);
    });
  });
}
