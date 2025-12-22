/// ملف تكوين مفاتيح API
///
/// هذا الملف يحتوي على جميع مفاتيح API المستخدمة في التطبيق
///
/// ⚠️ تحذير أمني:
/// - لا تضع المفاتيح الحقيقية في هذا الملف مباشرة في الإنتاج
/// - استخدم ملف .env أو متغيرات البيئة لتخزين المفاتيح الحساسة
/// - أضف .env إلى .gitignore لتجنب رفع المفاتيح إلى Git
library;

class ApiConfig {
  // ========== مفاتيح توليد الصور ==========

  /// مفتاح Nano Banana API
  /// احصل على المفتاح من: https://nanobanana.ai
  static const String nanoBananaApiKey = String.fromEnvironment(
    'NANO_BANANA_API_KEY',
    defaultValue: 'YOUR_NANO_BANANA_API_KEY',
  );

  /// مفتاح Stability AI API
  /// احصل على المفتاح من: https://platform.stability.ai
  static const String stabilityAiApiKey = String.fromEnvironment(
    'STABILITY_AI_API_KEY',
    defaultValue: 'YOUR_STABILITY_AI_API_KEY',
  );

  // ========== مفاتيح توليد الفيديو ==========

  /// مفتاح Google Veo API
  /// احصل على المفتاح من: https://ai.google.dev
  static const String googleVeoApiKey = String.fromEnvironment(
    'GOOGLE_VEO_API_KEY',
    defaultValue: 'YOUR_GOOGLE_VEO_API_KEY',
  );

  /// مفتاح D-ID API
  /// احصل على المفتاح من: https://www.d-id.com
  static const String dIdApiKey = String.fromEnvironment(
    'DID_API_KEY',
    defaultValue: 'YOUR_DID_API_KEY',
  );

  /// مفتاح Synthesia API
  /// احصل على المفتاح من: https://www.synthesia.io
  static const String synthesiaApiKey = String.fromEnvironment(
    'SYNTHESIA_API_KEY',
    defaultValue: 'YOUR_SYNTHESIA_API_KEY',
  );

  // ========== مفاتيح الذكاء الاصطناعي ==========

  /// مفتاح OpenAI API (ChatGPT)
  /// احصل على المفتاح من: https://platform.openai.com
  static const String openAiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: 'YOUR_OPENAI_API_KEY',
  );

  /// مفتاح Google Gemini API
  /// احصل على المفتاح من: https://ai.google.dev
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'YOUR_GEMINI_API_KEY',
  );

  // ========== Paymob Payment Gateway ==========
  // Live Account Credentials
  // Account Created: 26 Oct 2025
  // HMAC: BA095DD5F6DADC3FF2D6C9BE9E8CFB8C
  //
  // ✅ تم تحديث API Key - يجب أن يعمل الآن بدون أخطاء 403
  // المفتاح الجديد تم توليده من لوحة التحكم بنجاح
  //
  // 🔧 لتفعيل Paymob الحقيقي:
  // - تأكد من أن enableTestMode = false
  // - جرّب عملية دفع لاختبار الاتصال

  /// تفعيل الوضع التجريبي للدفع (لا يتطلب Paymob API صحيح)
  /// ✅ الدفع الحقيقي مُفعّل - Paymob UAE
  static const bool enableTestMode =
      String.fromEnvironment('PAYMOB_TEST_MODE', defaultValue: 'false') ==
      'true';

  /// مفتاح Paymob API
  /// احصل عليه من: https://accept.paymob.com/portal2/en/settings
  /// خطوات الحصول على API Key:
  /// 1. تسجيل الدخول إلى https://accept.paymob.com/portal2/en/login
  /// 2. الذهاب إلى Settings → Account Info أو API Keys
  /// 3. نسخ API Key (وليس Secret Key أو Public Key)
  /// 4. إذا كان المفتاح لا يعمل، اضغط "Regenerate" للحصول على مفتاح جديد
  static const String paymobApiKey = String.fromEnvironment(
    'PAYMOB_API_KEY',
    defaultValue:
        'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TmpFME1qTXNJbTVoYldVaU9pSXhOelkwTkRReU5UY3dMakl4TXpnNEluMC5iR2g0ZTVHSGY2YjhpNzc4Yjl0YVVwLWZYUThrN0xzUE5GT2dtUmRxS1I1UnZhc1YtMW51TEVVbFJUYlN4TTVzZVRIRlltdFdvUTV6R0sxbDM1TjJpZw==',
  );

  /// Paymob Public Key
  static const String paymobPublicKey = String.fromEnvironment(
    'PAYMOB_PUBLIC_KEY',
    defaultValue: 'are_pk_live_SgS4VDIjkSDiJoPPrDx4Q3uQJjKgr37n',
  );

  /// Paymob Secret Key (للخدمات الخلفية)
  static const String paymobSecretKey = String.fromEnvironment(
    'PAYMOB_SECRET_KEY',
    defaultValue:
        'are_sk_live_9de41b699c84f1cdda78478ac87ce590916495a6f563df9a17692e33fd9023c5',
  );

  /// Paymob HMAC Secret (للتحقق من Callbacks)
  static const String paymobHmacSecret = String.fromEnvironment(
    'PAYMOB_HMAC_SECRET',
    defaultValue: 'BA095DD5F6DADC3FF2D6C9BE9E8CFB8C',
  );

  /// Paymob Integration ID (لطريقة الدفع - بطاقات، محافظ، إلخ)
  /// احصل عليه من: https://accept.paymob.com/portal2/en/integrations
  /// Integration IDs:
  /// - 81249: MIGS-online (Online Card) - Live
  /// - 81250: MIGS-onlineAmex (Online Card Amex) - Live
  static const String paymobIntegrationId = String.fromEnvironment(
    'PAYMOB_INTEGRATION_ID',
    defaultValue: '81249', // MIGS-online (Online Card)
  );

  /// Paymob Iframe ID (لصفحة الدفع)
  /// احصل عليه من: https://accept.paymob.com/portal2/en/iframes
  /// يجب تحديثه بعد إنشاء Iframe في لوحة التحكم
  static const String paymobIframeId = String.fromEnvironment(
    'PAYMOB_IFRAME_ID',
    defaultValue: '81249', // تحديث هذا الرقم من لوحة التحكم
  );

  /// العملة الافتراضية
  /// 'EGP' = جنيه مصري
  /// 'SAR' = ريال سعودي
  /// 'USD' = دولار أمريكي
  /// 'AED' = درهم إماراتي
  static const String defaultCurrency = String.fromEnvironment(
    'DEFAULT_CURRENCY',
    defaultValue: 'AED',
  );

  // ========== Social Media OAuth ==========

  /// Twitter API Keys
  /// احصل عليها من: https://developer.twitter.com/en/portal/dashboard
  static const String twitterApiKey = String.fromEnvironment(
    'TWITTER_API_KEY',
    defaultValue: 'B0ll5GjDtgoEzeqAJ7lWi701O',
  );

  static const String twitterApiSecret = String.fromEnvironment(
    'TWITTER_API_SECRET',
    defaultValue: 'NanHU7o1ybLNzCG4MekjknAYbadq2x4ph1QSWG3Mp2XDGuUgiW',
  );

  /// LinkedIn API Keys
  /// احصل عليها من: https://www.linkedin.com/developers/apps
  static const String linkedinClientId = String.fromEnvironment(
    'LINKEDIN_CLIENT_ID',
    defaultValue: '771flta29hpfws',
  );

  static const String linkedinClientSecret = String.fromEnvironment(
    'LINKEDIN_CLIENT_SECRET',
    defaultValue: 'WPL_AP1.oiphgRU2qvIm7NiB.++u//w==',
  );

  /// LinkedIn Redirect URI
  static const String linkedinRedirectUri = 'https://mediaprosocial.io/api/auth/linkedin/callback';

  /// TikTok API Keys
  /// احصل عليها من: https://developers.tiktok.com
  static const String tiktokClientKey = String.fromEnvironment(
    'TIKTOK_CLIENT_KEY',
    defaultValue: '',
  );

  static const String tiktokClientSecret = String.fromEnvironment(
    'TIKTOK_CLIENT_SECRET',
    defaultValue: '',
  );

  // ========== Google Drive ==========

  /// Google Drive Media Folder ID (for storing uploaded images)
  static const String googleDriveMediaFolderId = String.fromEnvironment(
    'GOOGLE_DRIVE_MEDIA_FOLDER_ID',
    defaultValue: '',
  );

  // ========== روابط API ==========

  /// Backend base URL
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'https://mediaprosocial.io',
  );

  static const String nanoBananaBaseUrl = 'https://api.nanobanana.ai/v1';
  static const String stabilityAiBaseUrl =
      'https://api.stability.ai/v1/generation';
  static const String googleVeoBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String dIdBaseUrl = 'https://api.d-id.com';
  static const String synthesiaBaseUrl = 'https://api.synthesia.io/v2';

  // ========== دوال مساعدة ==========

  /// التحقق من صحة مفتاح API
  static bool isValidApiKey(String apiKey) {
    return apiKey.isNotEmpty &&
        !apiKey.startsWith('YOUR_') &&
        apiKey.length > 10;
  }

  /// الحصول على حالة جميع مفاتيح API
  static Map<String, bool> getApiKeysStatus() {
    return {
      'Nano Banana': isValidApiKey(nanoBananaApiKey),
      'Stability AI': isValidApiKey(stabilityAiApiKey),
      'Google Veo': isValidApiKey(googleVeoApiKey),
      'D-ID': isValidApiKey(dIdApiKey),
      'Synthesia': isValidApiKey(synthesiaApiKey),
      'OpenAI': isValidApiKey(openAiApiKey),
      'Gemini': isValidApiKey(geminiApiKey),
      'Paymob': isValidApiKey(paymobApiKey),
    };
  }

  /// التحقق من توفر خدمة معينة
  static bool isServiceAvailable(String serviceName) {
    switch (serviceName.toLowerCase()) {
      case 'nano_banana':
      case 'nanobanana':
        return isValidApiKey(nanoBananaApiKey);
      case 'stability':
      case 'stability_ai':
        return isValidApiKey(stabilityAiApiKey);
      case 'veo':
      case 'google_veo':
        return isValidApiKey(googleVeoApiKey);
      case 'did':
      case 'd-id':
        return isValidApiKey(dIdApiKey);
      case 'synthesia':
        return isValidApiKey(synthesiaApiKey);
      case 'openai':
      case 'chatgpt':
        return isValidApiKey(openAiApiKey);
      case 'gemini':
        return isValidApiKey(geminiApiKey);
      case 'paymob':
        return isValidApiKey(paymobApiKey);
      default:
        return false;
    }
  }

  /// طباعة حالة جميع الخدمات (للتطوير فقط)
  static void printServicesStatus() {
    print('========== API Services Status ==========');
    getApiKeysStatus().forEach((service, isAvailable) {
      final status = isAvailable ? '✅ Available' : '❌ Not configured';
      print('$service: $status');
    });
    print('=========================================');
  }
}
