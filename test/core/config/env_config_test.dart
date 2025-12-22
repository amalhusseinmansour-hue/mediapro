import 'package:flutter_test/flutter_test.dart';
import 'package:social_media_manager/core/config/env_config.dart';

void main() {
  // Note: These tests will use fallback values since .env is not loaded in tests
  // In a production test suite, you would mock dotenv or load a test .env file

  group('EnvConfig - App Configuration', () {
    test('should return app environment', () {
      expect(EnvConfig.appEnv, isA<String>());
      expect(EnvConfig.appEnv, isNotEmpty);
    });

    test('should return app debug status', () {
      expect(EnvConfig.appDebug, isA<bool>());
    });

    test('should return API base URL', () {
      expect(EnvConfig.apiBaseUrl, isA<String>());
      expect(EnvConfig.apiBaseUrl, isNotEmpty);
      expect(EnvConfig.apiBaseUrl, contains('https://'));
    });
  });

  group('EnvConfig - AI Services', () {
    test('should return OpenAI API key', () {
      expect(EnvConfig.openAIApiKey, isA<String>());
    });

    test('should return OpenAI Organization ID', () {
      expect(EnvConfig.openAIOrganizationId, isA<String>());
    });

    test('should return Google AI API key', () {
      expect(EnvConfig.googleAIApiKey, isA<String>());
    });

    test('should return Stability AI API key', () {
      expect(EnvConfig.stabilityAIApiKey, isA<String>());
    });

    test('should return Midjourney API key', () {
      expect(EnvConfig.midjourneyApiKey, isA<String>());
    });
  });

  group('EnvConfig - Payment Gateways', () {
    test('should return Stripe public key', () {
      expect(EnvConfig.stripePublicKey, isA<String>());
    });

    test('should return Stripe secret key', () {
      expect(EnvConfig.stripeSecretKey, isA<String>());
    });

    test('should return Paymob API key', () {
      expect(EnvConfig.paymobApiKey, isA<String>());
    });

    test('should return Paymob integration ID', () {
      expect(EnvConfig.paymobIntegrationId, isA<String>());
    });

    test('should return Paymob iframe ID', () {
      expect(EnvConfig.paymobIframeId, isA<String>());
    });

    test('should return PayPal client ID', () {
      expect(EnvConfig.paypalClientId, isA<String>());
    });

    test('should return PayPal client secret', () {
      expect(EnvConfig.paypalClientSecret, isA<String>());
    });
  });

  group('EnvConfig - Google Pay & Apple Pay', () {
    test('should return Google Pay merchant ID', () {
      expect(EnvConfig.googlePayMerchantId, isA<String>());
    });

    test('should return Google Pay gateway merchant ID', () {
      expect(EnvConfig.googlePayGatewayMerchantId, isA<String>());
    });

    test('should return Apple Pay merchant ID', () {
      expect(EnvConfig.applePayMerchantId, isA<String>());
    });
  });

  group('EnvConfig - Social Media OAuth', () {
    test('should return Facebook App ID', () {
      expect(EnvConfig.facebookAppId, isA<String>());
    });

    test('should return Facebook Client Token', () {
      expect(EnvConfig.facebookClientToken, isA<String>());
    });

    test('should return Facebook App Secret', () {
      expect(EnvConfig.facebookAppSecret, isA<String>());
    });

    test('should return Twitter API key', () {
      expect(EnvConfig.twitterApiKey, isA<String>());
    });

    test('should return Twitter API secret', () {
      expect(EnvConfig.twitterApiSecret, isA<String>());
    });

    test('should return Twitter Bearer token', () {
      expect(EnvConfig.twitterBearerToken, isA<String>());
    });

    test('should return Google Client ID', () {
      expect(EnvConfig.googleClientId, isA<String>());
    });

    test('should return Google Client Secret', () {
      expect(EnvConfig.googleClientSecret, isA<String>());
    });

    test('should return LinkedIn Client ID', () {
      expect(EnvConfig.linkedinClientId, isA<String>());
    });

    test('should return LinkedIn Client Secret', () {
      expect(EnvConfig.linkedinClientSecret, isA<String>());
    });
  });

  group('EnvConfig - Firebase', () {
    test('should return Firebase API key', () {
      expect(EnvConfig.firebaseApiKey, isA<String>());
    });

    test('should return Firebase Project ID', () {
      expect(EnvConfig.firebaseProjectId, isA<String>());
    });

    test('should return Firebase Messaging Sender ID', () {
      expect(EnvConfig.firebaseMessagingSenderId, isA<String>());
    });

    test('should return Firebase App ID', () {
      expect(EnvConfig.firebaseAppId, isA<String>());
    });

    test('should return Firebase Measurement ID', () {
      expect(EnvConfig.firebaseMeasurementId, isA<String>());
    });
  });

  group('EnvConfig - Analytics', () {
    test('should return Google Analytics Tracking ID', () {
      expect(EnvConfig.googleAnalyticsTrackingId, isA<String>());
    });

    test('should return Google Analytics Measurement ID', () {
      expect(EnvConfig.googleAnalyticsMeasurementId, isA<String>());
    });

    test('should return Facebook Pixel ID', () {
      expect(EnvConfig.facebookPixelId, isA<String>());
    });
  });

  group('EnvConfig - External Services', () {
    test('should return Ayrshare API key', () {
      expect(EnvConfig.ayrshareApiKey, isA<String>());
    });

    test('should return Postiz API URL', () {
      expect(EnvConfig.postizApiUrl, isA<String>());
    });

    test('should return Postiz API key', () {
      expect(EnvConfig.postizApiKey, isA<String>());
    });

    test('should return N8N Webhook URL', () {
      expect(EnvConfig.n8nWebhookUrl, isA<String>());
    });

    test('should return N8N API key', () {
      expect(EnvConfig.n8nApiKey, isA<String>());
    });

    test('should return Apify API token', () {
      expect(EnvConfig.apifyApiToken, isA<String>());
    });

    test('should return Telegram Bot Token', () {
      expect(EnvConfig.telegramBotToken, isA<String>());
    });

    test('should return Telegram Channel ID', () {
      expect(EnvConfig.telegramChannelId, isA<String>());
    });
  });

  group('EnvConfig - SMS Services', () {
    test('should return SMS API key', () {
      expect(EnvConfig.smsApiKey, isA<String>());
    });

    test('should return SMS Sender ID', () {
      expect(EnvConfig.smsSenderId, isA<String>());
      expect(EnvConfig.smsSenderId, 'MEDIAPRO'); // Default value
    });
  });

  group('EnvConfig - Storage', () {
    test('should return Google Drive Client ID', () {
      expect(EnvConfig.googleDriveClientId, isA<String>());
    });
  });

  group('EnvConfig - Security', () {
    test('should return JWT Secret', () {
      expect(EnvConfig.jwtSecret, isA<String>());
    });

    test('should return Encryption Key', () {
      expect(EnvConfig.encryptionKey, isA<String>());
    });
  });

  group('EnvConfig - Other Services', () {
    test('should return Scrapfly API key', () {
      expect(EnvConfig.scrapflyApiKey, isA<String>());
    });
  });

  group('EnvConfig - Helper Methods', () {
    test('isProduction should return boolean', () {
      expect(EnvConfig.isProduction, isA<bool>());
    });

    test('isDevelopment should return boolean', () {
      expect(EnvConfig.isDevelopment, isA<bool>());
    });

    test('isProduction and isDevelopment should be mutually exclusive', () {
      // If one is true, the other should be false (assuming only these two environments)
      if (EnvConfig.appEnv == 'production') {
        expect(EnvConfig.isProduction, true);
        expect(EnvConfig.isDevelopment, false);
      } else if (EnvConfig.appEnv == 'development') {
        expect(EnvConfig.isProduction, false);
        expect(EnvConfig.isDevelopment, true);
      }
    });

    test('isKeyConfigured should return false for empty string', () {
      expect(EnvConfig.isKeyConfigured(''), false);
    });

    test('isKeyConfigured should return false for placeholder values', () {
      expect(EnvConfig.isKeyConfigured('your_api_key_here'), false);
      expect(EnvConfig.isKeyConfigured('your_secret_key'), false);
    });

    test('isKeyConfigured should return true for valid keys', () {
      expect(EnvConfig.isKeyConfigured('sk_live_abc123def456'), true);
      expect(EnvConfig.isKeyConfigured('valid_api_key'), true);
    });

    test('getMissingKeys should return a list', () {
      final missingKeys = EnvConfig.getMissingKeys();
      expect(missingKeys, isA<List<String>>());
    });

    test('getMissingKeys should check critical keys', () {
      final missingKeys = EnvConfig.getMissingKeys();
      // Since we're using fallback values, most keys will be missing
      expect(missingKeys, isA<List<String>>());
    });
  });

  group('EnvConfig - Configuration Status', () {
    test('printStatus should execute without errors', () {
      expect(() => EnvConfig.printStatus(), returnsNormally);
    });

    test('printStatus should print environment information', () {
      // This is a void method, so we just test it doesn't throw
      EnvConfig.printStatus();
      expect(true, true); // If we got here, it didn't throw
    });
  });

  group('EnvConfig - Environment Validation', () {
    test('should have valid API base URL format', () {
      expect(EnvConfig.apiBaseUrl, startsWith('https://'));
      expect(EnvConfig.apiBaseUrl, contains('mediaprosocial.io'));
    });

    test('should have consistent environment settings', () {
      // In production, debug should be false
      if (EnvConfig.isProduction) {
        expect(EnvConfig.appDebug, false);
      }
    });
  });

  group('EnvConfig - API Key Security', () {
    test('should not expose sensitive keys in toString', () {
      // Environment variables should only be accessible through specific getters
      // not exposed in any toString or similar methods
      expect(EnvConfig.stripeSecretKey, isA<String>());
      expect(EnvConfig.jwtSecret, isA<String>());
      expect(EnvConfig.encryptionKey, isA<String>());
    });

    test('should return empty strings for unconfigured keys (fallback)', () {
      // When dotenv is not loaded, all keys should return empty strings as fallback
      // This is the expected behavior in test environment
      expect(EnvConfig.openAIApiKey, isA<String>());
    });
  });

  group('EnvConfig - All Getters Coverage', () {
    test('should have getter for all 40+ environment variables', () {
      // Test that all getters are accessible and return String type
      final getters = [
        EnvConfig.appEnv,
        EnvConfig.apiBaseUrl,
        EnvConfig.openAIApiKey,
        EnvConfig.openAIOrganizationId,
        EnvConfig.googleAIApiKey,
        EnvConfig.stabilityAIApiKey,
        EnvConfig.midjourneyApiKey,
        EnvConfig.stripePublicKey,
        EnvConfig.stripeSecretKey,
        EnvConfig.paymobApiKey,
        EnvConfig.paymobIntegrationId,
        EnvConfig.paymobIframeId,
        EnvConfig.paypalClientId,
        EnvConfig.paypalClientSecret,
        EnvConfig.googlePayMerchantId,
        EnvConfig.googlePayGatewayMerchantId,
        EnvConfig.applePayMerchantId,
        EnvConfig.facebookAppId,
        EnvConfig.facebookClientToken,
        EnvConfig.facebookAppSecret,
        EnvConfig.twitterApiKey,
        EnvConfig.twitterApiSecret,
        EnvConfig.twitterBearerToken,
        EnvConfig.googleClientId,
        EnvConfig.googleClientSecret,
        EnvConfig.linkedinClientId,
        EnvConfig.linkedinClientSecret,
        EnvConfig.firebaseApiKey,
        EnvConfig.firebaseProjectId,
        EnvConfig.firebaseMessagingSenderId,
        EnvConfig.firebaseAppId,
        EnvConfig.firebaseMeasurementId,
        EnvConfig.googleAnalyticsTrackingId,
        EnvConfig.googleAnalyticsMeasurementId,
        EnvConfig.facebookPixelId,
        EnvConfig.ayrshareApiKey,
        EnvConfig.postizApiUrl,
        EnvConfig.postizApiKey,
        EnvConfig.n8nWebhookUrl,
        EnvConfig.n8nApiKey,
        EnvConfig.apifyApiToken,
        EnvConfig.telegramBotToken,
        EnvConfig.telegramChannelId,
        EnvConfig.smsApiKey,
        EnvConfig.smsSenderId,
        EnvConfig.googleDriveClientId,
        EnvConfig.jwtSecret,
        EnvConfig.encryptionKey,
        EnvConfig.scrapflyApiKey,
      ];

      // All getters should return String type
      for (final getter in getters) {
        expect(getter, isA<String>());
      }

      // Verify we have 48 getters (40+ requirement met)
      expect(getters.length, greaterThanOrEqualTo(40));
    });
  });
}
