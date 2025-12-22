/// Backend API Configuration
///
/// This file contains the configuration for the Laravel backend API
library;

class BackendConfig {
  // ========== Base URLs ==========

  /// Production API Base URL
  static const String productionBaseUrl = 'https://mediaprosocial.io/api';

  /// Development API Base URL (for local testing)
  static const String developmentBaseUrl = 'http://localhost:8000/api';

  /// Current environment (change to false for local development)
  /// ✅ Set to true to use Production backend (https://mediaprosocial.io/api)
  static const bool isProduction = true;

  /// Get the appropriate base URL based on environment
  static String get baseUrl =>
      isProduction ? productionBaseUrl : developmentBaseUrl;

  // ========== API Endpoints ==========

  /// Authentication endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String verifyOtpEndpoint = '/auth/verify-otp';
  static const String sendOtpEndpoint = '/auth/send-otp';
  static const String refreshTokenEndpoint = '/auth/refresh';

  /// User endpoints
  static const String userProfileEndpoint = '/user/profile';
  static const String updateProfileEndpoint = '/user/update';
  static const String deleteAccountEndpoint = '/user/delete';

  /// Subscription endpoints
  static const String subscriptionsEndpoint = '/subscriptions';
  static const String subscriptionPlansEndpoint = '/subscription-plans';
  static const String userSubscriptionEndpoint = '/user/subscription';
  static const String subscribeEndpoint = '/subscriptions/subscribe';
  static const String cancelSubscriptionEndpoint = '/subscriptions/cancel';

  /// Payment endpoints
  static const String paymentsEndpoint = '/payments';
  static const String initiatePaymentEndpoint = '/payments/initiate';
  static const String verifyPaymentEndpoint = '/payments/verify';
  static const String paymentHistoryEndpoint = '/payments/history';

  /// Content endpoints
  static const String postsEndpoint = '/posts';
  static const String createPostEndpoint = '/posts/create';
  static const String updatePostEndpoint = '/posts/update';
  static const String deletePostEndpoint = '/posts/delete';
  static const String schedulePostEndpoint = '/posts/schedule';

  /// Analytics endpoints
  static const String analyticsEndpoint = '/analytics';
  static const String postAnalyticsEndpoint = '/analytics/posts';
  static const String accountAnalyticsEndpoint = '/analytics/accounts';

  /// Settings endpoints
  static const String settingsEndpoint = '/settings';
  static const String updateSettingsEndpoint = '/settings/update';

  // ========== Postiz Integration Endpoints ==========

  /// Postiz base configuration
  static const String postizBaseUrl = 'https://api.postiz.com/public/v1';
  // Using Postiz Cloud API - can be changed to self-hosted later

  /// Postiz OAuth endpoints
  static const String postizOAuthLinkEndpoint = '/postiz/oauth-link';
  static const String postizOAuthCallbackEndpoint = '/postiz/oauth-callback';

  /// Postiz integrations endpoints
  static const String postizIntegrationsEndpoint = '/postiz/integrations';
  static const String postizUnlinkIntegrationEndpoint = '/postiz/integrations';

  /// Postiz posts endpoints
  static const String postizPostsEndpoint = '/postiz/posts';
  static const String postizCreatePostEndpoint = '/postiz/posts';
  static const String postizUpdatePostEndpoint = '/postiz/posts';
  static const String postizDeletePostEndpoint = '/postiz/posts';

  /// Postiz analytics endpoints
  static const String postizAnalyticsSummaryEndpoint =
      '/postiz/analytics/summary';
  static const String postizPostAnalyticsEndpoint = '/postiz/analytics/post';
  static const String postizAccountAnalyticsEndpoint =
      '/postiz/analytics/account';

  /// Postiz media endpoints
  static const String postizUploadEndpoint = '/postiz/upload';
  static const String postizUploadFromUrlEndpoint = '/postiz/upload-from-url';

  /// Postiz utilities
  static const String postizFindSlotEndpoint = '/postiz/find-slot';
  static const String postizGenerateVideoEndpoint = '/postiz/generate-video';
  static const String postizStatusEndpoint = '/postiz/status';

  // ========== API Headers ==========

  /// Get default headers for API requests
  static Map<String, String> getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Get headers for multipart/form-data requests
  static Map<String, String> getMultipartHeaders({String? token}) {
    final headers = {
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ========== Helper Methods ==========

  /// Build full URL for an endpoint
  static String buildUrl(String endpoint) {
    // Remove leading slash if present
    final cleanEndpoint = endpoint.startsWith('/')
        ? endpoint.substring(1)
        : endpoint;
    return '$baseUrl/$cleanEndpoint';
  }

  /// Check if backend is configured
  static bool get isConfigured {
    return baseUrl.isNotEmpty && !baseUrl.contains('localhost') ||
        !isProduction;
  }

  /// Get API version info
  static String get apiVersion => 'v1';

  /// Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ========== Status Codes ==========

  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusAccepted = 202;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusValidationError = 422;
  static const int statusServerError = 500;

  // ========== Error Messages ==========

  static const String networkErrorMessage =
      'فشل الاتصال بالخادم. تحقق من اتصالك بالإنترنت.';
  static const String serverErrorMessage =
      'حدث خطأ في الخادم. حاول مرة أخرى لاحقاً.';
  static const String unauthorizedErrorMessage =
      'جلستك منتهية. يرجى تسجيل الدخول مرة أخرى.';
  static const String validationErrorMessage = 'البيانات المدخلة غير صحيحة.';
  static const String notFoundErrorMessage = 'البيانات المطلوبة غير موجودة.';
  static const String unknownErrorMessage = 'حدث خطأ غير متوقع.';

  /// Get error message based on status code
  static String getErrorMessage(int statusCode) {
    switch (statusCode) {
      case statusBadRequest:
        return validationErrorMessage;
      case statusUnauthorized:
        return unauthorizedErrorMessage;
      case statusForbidden:
        return 'لا تملك صلاحية للقيام بهذا الإجراء.';
      case statusNotFound:
        return notFoundErrorMessage;
      case statusValidationError:
        return validationErrorMessage;
      case statusServerError:
        return serverErrorMessage;
      default:
        return unknownErrorMessage;
    }
  }

  // ========== Debug Methods ==========

  /// Print configuration (for debugging)
  static void printConfiguration() {
    print('========== Backend API Configuration ==========');
    print('Environment: ${isProduction ? "Production" : "Development"}');
    print('Base URL: $baseUrl');
    print('API Version: $apiVersion');
    print('Is Configured: $isConfigured');
    print('Connect Timeout: ${connectTimeout.inSeconds}s');
    print('============================================');
  }
}
