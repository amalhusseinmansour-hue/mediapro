import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/config/backend_config.dart';

/// Settings Service
/// Fetches app settings from Laravel backend
class SettingsService extends GetxController {
  static String get baseUrl => BackendConfig.baseUrl;

  // Observable settings
  final RxMap<String, dynamic> appSettings = <String, dynamic>{}.obs;
  final RxBool isLoading = false.obs;
  final RxBool settingsLoaded = false.obs;

  // Cached settings
  Map<String, dynamic>? _cachedSettings;

  @override
  void onInit() {
    super.onInit();
    // Load settings on initialization
    fetchAppConfig();
  }

  /// Fetch app configuration from backend
  Future<bool> fetchAppConfig() async {
    try {
      isLoading.value = true;
      print('📤 Fetching app configuration from backend...');

      final response = await http.get(
        Uri.parse('$baseUrl/settings/app-config'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          appSettings.value = data['data'] ?? {};
          _cachedSettings = data['data'];
          settingsLoaded.value = true;

          print('✅ App configuration loaded successfully');
          print('📊 Settings: ${appSettings.length} groups');

          return true;
        } else {
          print('⚠️ Backend returned success=false');
          return false;
        }
      } else {
        print('❌ Failed to fetch settings: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error fetching app config: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch all public settings
  Future<Map<String, dynamic>?> fetchPublicSettings() async {
    try {
      print('📤 Fetching all public settings...');

      final response = await http.get(
        Uri.parse('$baseUrl/settings'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          print('✅ Public settings fetched successfully');
          return data['data'];
        }
      }

      return null;
    } catch (e) {
      print('❌ Error fetching public settings: $e');
      return null;
    }
  }

  /// Fetch settings by group
  Future<Map<String, dynamic>?> fetchSettingsByGroup(String group) async {
    try {
      print('📤 Fetching settings for group: $group');

      final response = await http.get(
        Uri.parse('$baseUrl/settings/group/$group'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          print('✅ Settings for group $group fetched successfully');
          return data['data'];
        }
      }

      return null;
    } catch (e) {
      print('❌ Error fetching settings for group $group: $e');
      return null;
    }
  }

  /// Get specific setting value
  Future<dynamic> fetchSetting(String key) async {
    try {
      print('📤 Fetching setting: $key');

      final response = await http.get(
        Uri.parse('$baseUrl/settings/$key'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          print('✅ Setting $key fetched successfully');
          return data['data']['value'];
        }
      }

      return null;
    } catch (e) {
      print('❌ Error fetching setting $key: $e');
      return null;
    }
  }

  /// Get app name
  String get appName {
    return appSettings['app']?['name'] ?? 'ميديا برو';
  }

  /// Get app name (English)
  String get appNameEn {
    return appSettings['app']?['name_en'] ?? 'Media Pro';
  }

  /// Get app logo URL
  String get appLogo {
    return appSettings['app']?['logo'] ?? '';
  }

  /// Get app version
  String get appVersion {
    return appSettings['app']?['version'] ?? '1.0.0';
  }

  /// Get minimum supported version
  String get minSupportedVersion {
    return appSettings['app']?['min_supported_version'] ?? '1.0.0';
  }

  /// Check if force update is required
  bool get forceUpdate {
    return appSettings['app']?['force_update'] ?? false;
  }

  /// Check if app is in maintenance mode
  bool get maintenanceMode {
    return appSettings['app']?['maintenance_mode'] ?? false;
  }

  /// Get maintenance message
  String get maintenanceMessage {
    return appSettings['app']?['maintenance_message'] ?? 'التطبيق تحت الصيانة حالياً';
  }

  /// Get support email
  String get supportEmail {
    return appSettings['support']?['email'] ?? 'support@mediaprosocial.io';
  }

  /// Get support phone
  String get supportPhone {
    return appSettings['support']?['phone'] ?? '';
  }

  /// Get currency
  String get currency {
    return appSettings['localization']?['currency'] ?? 'AED';
  }

  /// Get default language
  String get defaultLanguage {
    return appSettings['localization']?['default_language'] ?? 'ar';
  }

  /// Get supported languages
  List<String> get supportedLanguages {
    final langs = appSettings['localization']?['supported_languages'];
    if (langs is List) {
      return langs.cast<String>();
    }
    return ['ar', 'en'];
  }

  /// Get terms URL
  String get termsUrl {
    return appSettings['links']?['terms'] ?? 'https://mediaprosocial.io/terms';
  }

  /// Get privacy URL
  String get privacyUrl {
    return appSettings['links']?['privacy'] ?? 'https://mediaprosocial.io/privacy';
  }

  /// Get Facebook page URL
  String get facebookUrl {
    return appSettings['links']?['facebook'] ?? '';
  }

  /// Get Instagram URL
  String get instagramUrl {
    return appSettings['links']?['instagram'] ?? '';
  }

  /// Get Twitter URL
  String get twitterUrl {
    return appSettings['links']?['twitter'] ?? '';
  }

  /// Get LinkedIn URL
  String get linkedinUrl {
    return appSettings['links']?['linkedin'] ?? '';
  }

  /// Check if payments are enabled
  bool get paymentEnabled {
    return appSettings['features']?['payment_enabled'] ?? true;
  }

  /// Check if SMS is enabled
  bool get smsEnabled {
    return appSettings['features']?['sms_enabled'] ?? true;
  }

  /// Check if AI is enabled
  bool get aiEnabled {
    return appSettings['features']?['ai_enabled'] ?? true;
  }

  /// Check if Firebase is enabled
  bool get firebaseEnabled {
    return appSettings['features']?['firebase_enabled'] ?? false;
  }

  /// Get AI default model
  String get aiDefaultModel {
    return appSettings['ai']?['default_model'] ?? 'gpt-4';
  }

  /// Get meta title
  String get metaTitle {
    return appSettings['seo']?['meta_title'] ?? '';
  }

  /// Get meta description
  String get metaDescription {
    return appSettings['seo']?['meta_description'] ?? '';
  }

  /// Get meta keywords
  String get metaKeywords {
    return appSettings['seo']?['meta_keywords'] ?? '';
  }

  // ==================== PAYMENT SETTINGS ====================

  /// Get payment settings
  Map<String, dynamic> get paymentSettings {
    return appSettings['payment'] ?? {};
  }

  /// Check if Stripe is enabled
  bool get stripeEnabled {
    return paymentSettings['stripe_enabled'] ?? false;
  }

  /// Check if Paymob is enabled
  bool get paymobEnabled {
    return paymentSettings['paymob_enabled'] ?? false;
  }

  /// Check if PayPal is enabled
  bool get paypalEnabled {
    return paymentSettings['paypal_enabled'] ?? false;
  }

  /// Get default payment gateway
  String get defaultPaymentGateway {
    return paymentSettings['default_gateway'] ?? 'stripe';
  }

  /// Get Stripe public key
  String get stripePublicKey {
    return paymentSettings['stripe_public_key'] ?? '';
  }

  /// Get minimum payment amount
  double get minimumPaymentAmount {
    final amount = paymentSettings['minimum_amount'];
    if (amount is int) return amount.toDouble();
    if (amount is double) return amount;
    return 10.0;
  }

  /// Check if refunds are enabled
  bool get refundsEnabled {
    return paymentSettings['refunds_enabled'] ?? true;
  }

  /// Get refund period in days
  int get refundPeriodDays {
    return paymentSettings['refund_period_days'] ?? 30;
  }

  // ==================== GOOGLE PAY SETTINGS ====================

  /// Check if Google Pay is enabled
  bool get googlePayEnabled {
    return paymentSettings['google_pay_enabled'] ?? false;
  }

  /// Get Google Pay merchant ID
  String get googlePayMerchantId {
    return paymentSettings['google_pay_merchant_id'] ?? '';
  }

  /// Get Google Pay merchant name
  String get googlePayMerchantName {
    return paymentSettings['google_pay_merchant_name'] ?? 'Media Pro Social';
  }

  /// Get Google Pay environment (TEST or PRODUCTION)
  String get googlePayEnvironment {
    return paymentSettings['google_pay_environment'] ?? 'TEST';
  }

  /// Get Google Pay gateway
  String get googlePayGateway {
    return paymentSettings['google_pay_gateway'] ?? 'stripe';
  }

  /// Get Google Pay gateway merchant ID
  String get googlePayGatewayMerchantId {
    return paymentSettings['google_pay_gateway_merchant_id'] ?? '';
  }

  /// Check if billing address is required for Google Pay
  bool get googlePayBillingAddressRequired {
    return paymentSettings['google_pay_billing_address_required'] ?? false;
  }

  /// Check if shipping address is required for Google Pay
  bool get googlePayShippingAddressRequired {
    return paymentSettings['google_pay_shipping_address_required'] ?? false;
  }

  /// Check if email is required for Google Pay
  bool get googlePayEmailRequired {
    return paymentSettings['google_pay_email_required'] ?? false;
  }

  /// Check if phone is required for Google Pay
  bool get googlePayPhoneRequired {
    return paymentSettings['google_pay_phone_required'] ?? false;
  }

  /// Get Google Pay button color
  String get googlePayButtonColor {
    return paymentSettings['google_pay_button_color'] ?? 'default';
  }

  /// Get Google Pay button type
  String get googlePayButtonType {
    return paymentSettings['google_pay_button_type'] ?? 'pay';
  }

  // ==================== TWILIO OTP SETTINGS ====================

  /// Check if Twilio OTP is enabled
  bool get twilioEnabled {
    return appSettings['otp']?['twilio_enabled'] ?? false;
  }

  /// Get Twilio Account SID
  String get twilioAccountSid {
    return appSettings['otp']?['twilio_account_sid'] ?? '';
  }

  /// Get Twilio Auth Token
  String get twilioAuthToken {
    return appSettings['otp']?['twilio_auth_token'] ?? '';
  }

  /// Get Twilio Phone Number (Sender)
  String get twilioPhoneNumber {
    return appSettings['otp']?['twilio_phone_number'] ?? '';
  }

  /// Get OTP Message Template
  String get otpMessageTemplate {
    return appSettings['otp']?['message_template'] ?? 'Your verification code is: {code}';
  }

  /// Get OTP Code Length
  int get otpCodeLength {
    return appSettings['otp']?['code_length'] ?? 6;
  }

  /// Get OTP Expiry Time (in minutes)
  int get otpExpiryMinutes {
    return appSettings['otp']?['expiry_minutes'] ?? 5;
  }

  /// Check if test OTP is enabled
  bool get testOtpEnabled {
    return appSettings['otp']?['test_otp_enabled'] ?? true;
  }

  /// Get test OTP code
  String get testOtpCode {
    return appSettings['otp']?['test_otp_code'] ?? '123456';
  }

  // ==================== AI MEDIA GENERATION SETTINGS ====================

  /// Check if AI Image Generation is enabled
  bool get aiImageEnabled {
    return appSettings['ai']?['image_generation_enabled'] ?? false;
  }

  /// Check if AI Video Generation is enabled
  bool get aiVideoEnabled {
    return appSettings['ai']?['video_generation_enabled'] ?? false;
  }

  /// Get AI Image Provider (replicate, runway, stability, etc.)
  String get aiMediaImageProvider {
    return appSettings['ai']?['image_provider'] ?? 'replicate';
  }

  /// Get AI Video Provider
  String get aiMediaVideoProvider {
    return appSettings['ai']?['video_provider'] ?? 'runway';
  }

  // Replicate Settings
  String get replicateApiKey {
    return appSettings['ai']?['replicate_api_key'] ?? '';
  }

  String get replicateImageModel {
    // FLUX Schnell - fast image generation (like Nano Banana)
    return appSettings['ai']?['replicate_image_model'] ?? 'black-forest-labs/flux-schnell';
  }

  String get replicateVideoModel {
    return appSettings['ai']?['replicate_video_model'] ?? 'anotherjesse/zeroscope-v2-xl';
  }

  // Runway Settings
  String get runwayApiKey {
    return appSettings['ai']?['runway_api_key'] ?? '';
  }

  String get runwayBaseUrl {
    return appSettings['ai']?['runway_base_url'] ?? 'https://api.runwayml.com/v1';
  }

  // Stability AI Settings
  String get stabilityApiKey {
    return appSettings['ai']?['stability_api_key'] ?? '';
  }

  String get stabilityEngine {
    return appSettings['ai']?['stability_engine'] ?? 'stable-diffusion-xl-1024-v1-0';
  }

  // Leonardo AI Settings
  String get leonardoApiKey {
    return appSettings['ai']?['leonardo_api_key'] ?? '';
  }

  // General AI Settings
  int get aiImageWidth {
    return appSettings['ai']?['ai_image_width'] ?? 1024;
  }

  int get aiImageHeight {
    return appSettings['ai']?['ai_image_height'] ?? 1024;
  }

  int get aiVideoLength {
    return appSettings['ai']?['ai_video_length'] ?? 5;
  }

  double get aiGuidanceScale {
    return (appSettings['ai']?['ai_guidance_scale'] ?? 7.5).toDouble();
  }

  int get aiSteps {
    return appSettings['ai']?['ai_steps'] ?? 30;
  }

  // Cost Settings
  double get aiImageCostPerGeneration {
    return (appSettings['ai']?['ai_image_cost_per_generation'] ?? 0.05).toDouble();
  }

  double get aiVideoCostPerSecond {
    return (appSettings['ai']?['ai_video_cost_per_second'] ?? 0.10).toDouble();
  }

  // ==================== APPLE PAY SETTINGS ====================

  /// Check if Apple Pay is enabled
  bool get applePayEnabled {
    return paymentSettings['apple_pay_enabled'] ?? false;
  }

  /// Get Apple Pay merchant ID
  String get applePayMerchantId {
    return paymentSettings['apple_pay_merchant_id'] ?? '';
  }

  /// Get Apple Pay merchant name
  String get applePayMerchantName {
    return paymentSettings['apple_pay_merchant_name'] ?? 'Media Pro Social';
  }

  /// Get Apple Pay country code
  String get applePayCountryCode {
    return paymentSettings['apple_pay_country_code'] ?? 'AE';
  }

  /// Get Apple Pay currency code
  String get applePayCurrencyCode {
    return paymentSettings['apple_pay_currency_code'] ?? 'AED';
  }

  /// Get Apple Pay gateway
  String get applePayGateway {
    return paymentSettings['apple_pay_gateway'] ?? 'stripe';
  }

  /// Check if billing address is required for Apple Pay
  bool get applePayRequireBilling {
    return paymentSettings['apple_pay_require_billing'] ?? false;
  }

  /// Check if shipping address is required for Apple Pay
  bool get applePayRequireShipping {
    return paymentSettings['apple_pay_require_shipping'] ?? false;
  }

  /// Check if email is required for Apple Pay
  bool get applePayRequireEmail {
    return paymentSettings['apple_pay_require_email'] ?? false;
  }

  /// Check if phone is required for Apple Pay
  bool get applePayRequirePhone {
    return paymentSettings['apple_pay_require_phone'] ?? false;
  }

  /// Get Apple Pay button style
  String get applePayButtonStyle {
    return paymentSettings['apple_pay_button_style'] ?? 'black';
  }

  /// Get Apple Pay button type
  String get applePayButtonType {
    return paymentSettings['apple_pay_button_type'] ?? 'buy';
  }

  // ==================== AI CONTENT SETTINGS ====================

  /// Get AI content settings
  Map<String, dynamic> get aiContentSettings {
    return appSettings['ai_content'] ?? {};
  }

  /// Check if AI content generation is enabled
  bool get aiContentEnabled {
    return aiContentSettings['enabled'] ?? true;
  }

  /// Check if text generation is enabled
  bool get textGenerationEnabled {
    return aiContentSettings['text_generation_enabled'] ?? true;
  }

  /// Check if image generation is enabled
  bool get imageGenerationEnabled {
    return aiContentSettings['image_generation_enabled'] ?? true;
  }

  /// Check if video generation is enabled
  bool get videoGenerationEnabled {
    return aiContentSettings['video_generation_enabled'] ?? false;
  }

  /// Get AI provider
  String get aiProvider {
    return aiContentSettings['provider'] ?? 'openai';
  }

  /// Get text model
  String get aiTextModel {
    return aiContentSettings['text_model'] ?? 'gpt-4';
  }

  /// Get image provider
  String get aiImageProvider {
    return aiContentSettings['image_provider'] ?? 'dalle';
  }

  /// Get image size
  String get aiImageSize {
    return aiContentSettings['image_size'] ?? '1024x1024';
  }

  /// Get image quality
  String get aiImageQuality {
    return aiContentSettings['image_quality'] ?? 'standard';
  }

  /// Check if content ideas are enabled
  bool get contentIdeasEnabled {
    return aiContentSettings['content_ideas_enabled'] ?? true;
  }

  /// Check if hashtag generator is enabled
  bool get hashtagGeneratorEnabled {
    return aiContentSettings['hashtag_generator_enabled'] ?? true;
  }

  /// Check if caption generator is enabled
  bool get captionGeneratorEnabled {
    return aiContentSettings['caption_generator_enabled'] ?? true;
  }

  /// Get per user daily limit
  int get aiPerUserDailyLimit {
    return aiContentSettings['per_user_daily_limit'] ?? 50;
  }

  /// Get max tokens for text generation
  int get aiTextMaxTokens {
    return aiContentSettings['text_max_tokens'] ?? 2000;
  }

  /// Get temperature for text generation
  double get aiTextTemperature {
    final temp = aiContentSettings['text_temperature'];
    if (temp is int) return temp.toDouble();
    if (temp is double) return temp;
    return 0.7;
  }

  // ==================== ANALYTICS SETTINGS ====================

  /// Get analytics settings
  Map<String, dynamic> get analyticsSettings {
    return appSettings['analytics'] ?? {};
  }

  /// Check if analytics is enabled
  bool get analyticsEnabled {
    return analyticsSettings['enabled'] ?? true;
  }

  /// Check if tracking is enabled
  bool get analyticsTrackingEnabled {
    return analyticsSettings['tracking_enabled'] ?? true;
  }

  /// Check if Google Analytics is enabled
  bool get googleAnalyticsEnabled {
    return analyticsSettings['google_analytics_enabled'] ?? false;
  }

  /// Get Google Analytics tracking ID
  String get googleAnalyticsTrackingId {
    return analyticsSettings['google_analytics_tracking_id'] ?? '';
  }

  /// Get Google Analytics measurement ID
  String get googleAnalyticsMeasurementId {
    return analyticsSettings['google_analytics_measurement_id'] ?? '';
  }

  /// Check if Facebook Pixel is enabled
  bool get facebookPixelEnabled {
    return analyticsSettings['facebook_pixel_enabled'] ?? false;
  }

  /// Get Facebook Pixel ID
  String get facebookPixelId {
    return analyticsSettings['facebook_pixel_id'] ?? '';
  }

  /// Check if Firebase Analytics is enabled
  bool get firebaseAnalyticsEnabled {
    return analyticsSettings['firebase_analytics_enabled'] ?? false;
  }

  /// Check if user behavior tracking is enabled
  bool get trackUserBehavior {
    return analyticsSettings['track_user_behavior'] ?? true;
  }

  /// Check if post performance tracking is enabled
  bool get trackPostPerformance {
    return analyticsSettings['track_post_performance'] ?? true;
  }

  /// Check if social engagement tracking is enabled
  bool get trackSocialEngagement {
    return analyticsSettings['track_social_engagement'] ?? true;
  }

  /// Get data retention days
  int get analyticsDataRetentionDays {
    return analyticsSettings['data_retention_days'] ?? 90;
  }

  // ==================== GENERAL METHODS ====================

  /// Refresh settings from backend
  Future<bool> refresh() async {
    return await fetchAppConfig();
  }

  /// Check if settings are loaded
  bool get isSettingsLoaded => settingsLoaded.value;

  /// Get cached settings (for offline use)
  Map<String, dynamic>? get cachedSettings => _cachedSettings;

  /// Get raw setting value by key path (e.g., 'payment.stripe_enabled')
  dynamic getSetting(String keyPath) {
    final keys = keyPath.split('.');
    dynamic value = appSettings;

    for (final key in keys) {
      if (value is Map) {
        value = value[key];
      } else {
        return null;
      }
    }

    return value;
  }
}
