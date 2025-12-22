/// Paymob Payment Gateway Configuration - UAE LIVE MODE
class PaymobConfig {
  // Paymob UAE API Configuration - LIVE
  static const String apiKey =
      'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TmpFME1qTXNJbTVoYldVaU9pSXhOelkwTkRReU5UY3dMakl4TXpnNEluMC5iR2g0ZTVHSGY2YjhpNzc4Yjl0YVVwLWZYUThrN0xzUE5GT2dtUmRxS1I1UnZhc1YtMW51TEVVbFJUYlN4TTVzZVRIRlltdFdvUTV6R0sxbDM1TjJpZw==';
  static const String secretKey =
      'are_sk_live_9de41b699c84f1cdda78478ac87ce590916495a6f563df9a17692e33fd9023c5';
  static const String publicKey =
      'are_pk_live_SgS4VDIjkSDiJoPPrDx4Q3uQJjKgr37n';
  static const String hmacSecret = 'BA095DD5F6DADC3FF2D6C9BE9E8CFB8C';

  // UAE Paymob Base URL
  static const String baseUrl = 'https://uae.paymob.com/api';

  // Integration IDs (MIGS - Online Card)
  static const int cardIntegrationId = 81249; // MIGS-online
  static const int amexIntegrationId = 81250; // MIGS-onlineAmex
  static const int walletIntegrationId = 0; // Not configured yet
  static const int kifIntegrationId = 0; // Not configured yet

  // Primary iframe ID
  static const int iframeId = 81249;

  // URLs - UAE
  static const String iframeUrl =
      'https://uae.paymob.com/api/acceptance/iframes/';

  // Currency
  static const String currency = 'AED'; // الدرهم الإماراتي

  // Endpoints
  static const String authEndpoint = '$baseUrl/auth/tokens';
  static const String orderEndpoint = '$baseUrl/ecommerce/orders';
  static const String paymentKeyEndpoint = '$baseUrl/acceptance/payment_keys';

  // Callback URLs - Deep Link للعودة للتطبيق بعد الدفع
  static String get callbackUrl => 'socialmediamanager://payment/callback';
  // Webhook يبقى على السيرفر لتسجيل المعاملات
  static String get webhookUrl => 'https://mediaprosocial.io/payment/webhook';
}
