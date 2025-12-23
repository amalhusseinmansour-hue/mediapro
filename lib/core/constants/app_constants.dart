import 'package:get/get.dart';
import '../../services/settings_service.dart';

class AppConstants {
  // App Info (الآن يتم جلبها من Settings Service)
  // استخدم SettingsService للحصول على القيم الديناميكية من Backend
  static const String appName = 'ميديا برو'; // Default fallback
  static const String appVersion = '1.0.0'; // Default fallback

  // ⚠️ DEPRECATED: API Keys يجب عدم حفظها في الكود
  // استخدم Backend API للتعامل مع AI Services بدلاً من الوصول المباشر
  // جميع AI Requests يجب أن تمر عبر Laravel Backend الذي يحتوي على API Keys
  @Deprecated('Use Backend API instead of direct API access')
  static const String openAIApiKey = ''; // Removed for security
  @Deprecated('Use Backend API instead of direct API access')
  static const String geminiApiKey = ''; // Removed for security

  /// Get app name from settings service
  static String getAppName() {
    try {
      final settings = Get.find<SettingsService>();
      return settings.appName;
    } catch (e) {
      return appName; // Fallback
    }
  }

  /// Get app version from settings service
  static String getAppVersion() {
    try {
      final settings = Get.find<SettingsService>();
      return settings.appVersion;
    } catch (e) {
      return appVersion; // Fallback
    }
  }

  /// Get currency from settings service
  static String getCurrency() {
    try {
      final settings = Get.find<SettingsService>();
      return settings.currency;
    } catch (e) {
      return 'AED'; // Fallback
    }
  }

  /// Check if AI is enabled
  static bool isAIEnabled() {
    try {
      final settings = Get.find<SettingsService>();
      return settings.aiEnabled;
    } catch (e) {
      return true; // Fallback
    }
  }

  /// Check if payments are enabled
  static bool isPaymentEnabled() {
    try {
      final settings = Get.find<SettingsService>();
      return settings.paymentEnabled;
    } catch (e) {
      return true; // Fallback
    }
  }

  // Storage Keys
  static const String userKey = 'user_data';
  static const String authTokenKey = 'auth_token';
  static const String subscriptionKey = 'subscription_type';
  static const String isDarkModeKey = 'is_dark_mode';

  // Subscription Types
  static const String individualSubscription = 'individual';
  static const String businessSubscription = 'business';

  // Social Media Platforms
  static const List<String> socialPlatforms = [
    'Facebook',
    'Instagram',
    'Twitter',
    'LinkedIn',
    'TikTok',
    'YouTube',
    'Pinterest',
  ];

  // Content Types
  static const List<String> contentTypes = [
    'Image Post',
    'Video Post',
    'Story',
    'Reel',
    'Carousel',
    'Text Post',
  ];

  // AI Models
  static const String gpt4Model = 'gpt-4';
  static const String gpt35Model = 'gpt-3.5-turbo';
  static const String geminiProModel = 'gemini-pro';

  // Image Generation
  static const String dalleModel = 'dall-e-3';

  // Pagination
  static const int postsPerPage = 20;
  static const int accountsPerPage = 10;

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String displayDateFormat = 'MMM dd, yyyy';

  // Error Messages
  static const String networkError = 'فشل الاتصال بالإنترنت';
  static const String serverError = 'حدث خطأ في الخادم';
  static const String unknownError = 'حدث خطأ غير متوقع';
}
