/// Environment Configuration
/// All sensitive API keys are now fetched from backend for security
/// This file only contains non-sensitive configuration
class EnvConfig {
  // ==================== App ====================

  static const String appEnv = 'production';
  static const bool appDebug = false;
  static const String apiBaseUrl = 'https://mediaprosocial.io/api';

  // ==================== Non-sensitive Config ====================

  // Facebook App ID (public, required for SDK initialization)
  static const String facebookAppId = '1925148181364576';

  // Cloudinary (public cloud name only - secret stays on backend)
  static const String cloudinaryCloudName = 'dobnm2dz7';
  static const String cloudinaryUploadPreset = 'ml_default';

  // SMS Sender ID (public)
  static const String smsSenderId = 'MEDIAPRO';

  // ==================== Backend API Endpoints for Keys ====================
  // All sensitive API keys are now fetched from the backend securely

  /// Endpoint to get AI service configuration
  static const String aiConfigEndpoint = '/config/ai';

  /// Endpoint to get payment configuration
  static const String paymentConfigEndpoint = '/config/payment';

  /// Endpoint to get social OAuth configuration
  static const String socialConfigEndpoint = '/config/social';

  // ==================== Helper Methods ====================

  /// Check if running in production
  static bool get isProduction => appEnv == 'production';

  /// Check if running in development
  static bool get isDevelopment => appEnv == 'development';

  /// Print configuration status
  static void printStatus() {
    print('Environment Configuration:');
    print('   Environment: $appEnv');
    print('   Debug Mode: $appDebug');
    print('   API Base URL: $apiBaseUrl');
    print('   All sensitive keys fetched from backend securely');
  }

  // ==================== Deprecated - For Backward Compatibility ====================
  // These return empty strings - actual values come from backend

  @Deprecated('Use backend API to get AI keys')
  static String get groqApiKey => '';

  @Deprecated('Use backend API to get AI keys')
  static String get openAIApiKey => '';

  @Deprecated('Use backend API to get AI keys')
  static String get claudeApiKey => '';

  @Deprecated('Use backend API to get AI keys')
  static String get googleAIApiKey => '';

  @Deprecated('Use backend API to get AI keys')
  static String get stabilityAIApiKey => '';

  @Deprecated('Use backend API to get AI keys')
  static String get runwayApiKey => '';

  @Deprecated('Use backend API to get AI keys')
  static String get replicateApiToken => '';

  @Deprecated('Use backend API to get payment keys')
  static String get stripePublicKey => '';

  @Deprecated('Use backend API to get payment keys')
  static String get paymobApiKey => '';

  @Deprecated('Use backend API to get payment keys')
  static String get paymobIntegrationId => '';

  @Deprecated('Use backend API to get payment keys')
  static String get paymobIframeId => '';

  @Deprecated('Use backend API for Cloudinary')
  static String get cloudinaryApiKey => '';

  @Deprecated('Use backend API for Cloudinary')
  static String get cloudinaryApiSecret => '';
}
