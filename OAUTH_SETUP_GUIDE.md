# 🔐 دليل إعداد OAuth للمنصات الاجتماعية

## 📌 نظرة عامة

لربط حسابات السوشال ميديا، تحتاج للحصول على API Keys من كل منصة.

**الحالة الحالية:**
- ✅ **Google/YouTube** - جاهز ويعمل
- ❌ **Facebook** - يحتاج App ID
- ❌ **Twitter** - يحتاج API Keys
- ❌ **LinkedIn** - يحتاج Client ID
- ❌ **TikTok** - يحتاج Client Key

---

## 1️⃣ Facebook App Setup

### الخطوات:

#### أ) إنشاء التطبيق
1. اذهب إلى: https://developers.facebook.com/apps
2. اضغط **Create App**
3. اختر **Consumer** كنوع التطبيق
4. أدخل:
   - **App Name:** MediaPro Social Manager
   - **Contact Email:** بريدك الإلكتروني

#### ب) تفعيل Facebook Login
1. من Dashboard → Add Product
2. اختر **Facebook Login**
3. اختر **Android**
4. أدخل:
   - **Package Name:** `com.socialmedia.social_media_manager`
   - **Class Name:** `com.socialmedia.social_media_manager.MainActivity`
   - **Key Hashes:** (استخدم SHA-1 من `GET_SHA1.bat`)

#### ج) نسخ App ID و Client Token
1. من Settings → Basic
2. انسخ:
   - **App ID**
   - **Client Token**

#### د) التعديل في التطبيق

**1. ملف `android/app/src/main/res/values/strings.xml`:**
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">MediaPro</string>
    <string name="facebook_app_id">YOUR_APP_ID_HERE</string>
    <string name="facebook_client_token">YOUR_CLIENT_TOKEN_HERE</string>
    <string name="fb_login_protocol_scheme">fbYOUR_APP_ID_HERE</string>
</resources>
```

**2. ملف `lib/core/config/api_config.dart`:**
```dart
static const String facebookAppId = 'YOUR_APP_ID_HERE';
static const String facebookClientToken = 'YOUR_CLIENT_TOKEN_HERE';
```

---

## 2️⃣ Twitter (X) API Setup

### الخطوات:

#### أ) إنشاء التطبيق
1. اذهب إلى: https://developer.twitter.com/en/portal/dashboard
2. اضغط **Create Project**
3. أدخل:
   - **Project Name:** MediaPro Social
   - **Use Case:** Making a bot أو Exploring the API
4. بعد إنشاء Project، أنشئ **App** داخله

#### ب) الحصول على API Keys
1. من App Settings → Keys and Tokens
2. انسخ:
   - **API Key** (Consumer Key)
   - **API Key Secret** (Consumer Secret)
3. اضغط **Generate** تحت **Access Token and Secret**
4. انسخ:
   - **Access Token**
   - **Access Token Secret**

#### ج) تفعيل OAuth 1.0a
1. من App Settings → User authentication settings
2. اضغط **Set up**
3. اختر:
   - **App permissions:** Read and write
   - **Type of App:** Native App
   - **Callback URLs:** `mediapro://twitter-callback`
   - **Website URL:** https://mediaprosocial.io

#### د) التعديل في التطبيق

**ملف `lib/core/config/api_config.dart`:**
```dart
static const String twitterApiKey = 'YOUR_API_KEY_HERE';
static const String twitterApiSecret = 'YOUR_API_SECRET_HERE';
static const String twitterAccessToken = 'YOUR_ACCESS_TOKEN_HERE';
static const String twitterAccessTokenSecret = 'YOUR_ACCESS_TOKEN_SECRET_HERE';
```

---

## 3️⃣ LinkedIn API Setup

### الخطوات:

#### أ) إنشاء التطبيق
1. اذهب إلى: https://www.linkedin.com/developers/apps
2. اضغط **Create app**
3. أدخل:
   - **App name:** MediaPro Social Manager
   - **LinkedIn Page:** أنشئ صفحة أو اختر موجودة
   - **Privacy policy URL:** https://mediaprosocial.io/privacy
   - **App logo:** شعار التطبيق

#### ب) طلب الصلاحيات (Products)
1. من Products → اطلب:
   - **Sign In with LinkedIn using OpenID Connect**
   - **Share on LinkedIn** (إذا متاح)

#### ج) إعداد OAuth 2.0
1. من Auth → OAuth 2.0 settings
2. أضف **Redirect URLs:**
   - `https://mediaprosocial.io/auth/linkedin/callback`
   - `mediapro://linkedin-callback`

#### د) نسخ Credentials
1. من Auth → Application credentials
2. انسخ:
   - **Client ID**
   - **Client Secret**

#### هـ) التعديل في التطبيق

**ملف `lib/core/config/api_config.dart`:**
```dart
static const String linkedinClientId = 'YOUR_CLIENT_ID_HERE';
static const String linkedinClientSecret = 'YOUR_CLIENT_SECRET_HERE';
static const String linkedinRedirectUri = 'mediapro://linkedin-callback';
```

---

## 4️⃣ TikTok for Developers

### الخطوات:

#### أ) إنشاء التطبيق
1. اذهب إلى: https://developers.tiktok.com/apps/
2. اضغط **Create an app**
3. أدخل:
   - **App name:** MediaPro Social Manager
   - **App type:** Direct
4. اقرأ ووافق على الشروط

#### ب) إعداد Login Kit
1. من Products → أضف **Login Kit**
2. في Redirect URI أضف:
   - `https://mediaprosocial.io/auth/tiktok/callback`

#### ج) نسخ Credentials
1. من App Details
2. انسخ:
   - **Client Key**
   - **Client Secret**

#### د) التعديل في التطبيق

**ملف `lib/core/config/api_config.dart`:**
```dart
static const String tiktokClientKey = 'YOUR_CLIENT_KEY_HERE';
static const String tiktokClientSecret = 'YOUR_CLIENT_SECRET_HERE';
static const String tiktokRedirectUri = 'https://mediaprosocial.io/auth/tiktok/callback';
```

---

## 5️⃣ Instagram (عبر Facebook)

Instagram يستخدم نفس Facebook App:

1. من Facebook App Dashboard
2. اذهب إلى Products → Instagram Basic Display
3. اضغط **Create New App**
4. أدخل:
   - **Display Name:** MediaPro
   - **Valid OAuth Redirect URIs:** `https://mediaprosocial.io/auth/instagram/callback`
   - **Deauthorize Callback URL:** `https://mediaprosocial.io/auth/instagram/deauthorize`
   - **Data Deletion Request URL:** `https://mediaprosocial.io/auth/instagram/data-deletion`

5. انسخ **Instagram App ID** و **Instagram App Secret**

---

## ✅ قائمة التحقق النهائية

بعد الحصول على جميع المفاتيح:

### 1. تحديث `lib/core/config/api_config.dart`
```dart
class ApiConfig {
  // Facebook
  static const String facebookAppId = '123456789012345'; // ✅ تم
  static const String facebookClientToken = 'abc123def456'; // ✅ تم

  // Twitter
  static const String twitterApiKey = 'your_api_key'; // ✅ تم
  static const String twitterApiSecret = 'your_api_secret'; // ✅ تم

  // LinkedIn
  static const String linkedinClientId = 'your_client_id'; // ✅ تم
  static const String linkedinClientSecret = 'your_client_secret'; // ✅ تم

  // TikTok
  static const String tiktokClientKey = 'your_client_key'; // ✅ تم
  static const String tiktokClientSecret = 'your_client_secret'; // ✅ تم

  // Instagram (نفس Facebook)
  static const String instagramAppId = facebookAppId; // ✅ تم
}
```

### 2. تحديث `android/app/src/main/res/values/strings.xml`
```xml
<resources>
    <string name="app_name">MediaPro</string>
    <string name="facebook_app_id">123456789012345</string> <!-- ✅ تم -->
    <string name="facebook_client_token">abc123def456</string> <!-- ✅ تم -->
    <string name="fb_login_protocol_scheme">fb123456789012345</string> <!-- ✅ تم -->
</resources>
```

### 3. اختبار الربط
```bash
flutter clean
flutter pub get
flutter run
```

ثم جرب ربط كل منصة من التطبيق.

---

## 🔒 ملاحظات أمنية مهمة

### ⚠️ لا تشارك المفاتيح السرية!
- ❌ **لا ترفع** `api_config.dart` إلى GitHub بالمفاتيح الحقيقية
- ✅ استخدم `.env` files أو Firebase Remote Config
- ✅ أضف `api_config.dart` إلى `.gitignore`

### 🔐 استخدام Environment Variables (موصى به)
```dart
// بدلاً من hardcoding:
static const String facebookAppId = String.fromEnvironment(
  'FACEBOOK_APP_ID',
  defaultValue: 'YOUR_FACEBOOK_APP_ID', // للتطوير فقط
);
```

---

## 📚 موارد إضافية

- **Facebook Developer Docs:** https://developers.facebook.com/docs/
- **Twitter API Docs:** https://developer.twitter.com/en/docs
- **LinkedIn API Docs:** https://learn.microsoft.com/en-us/linkedin/
- **TikTok Developer Docs:** https://developers.tiktok.com/doc/

---

## 🆘 مشاكل شائعة

### Facebook: "App not in development mode"
**الحل:** من Dashboard → App Mode → اجعله **Development** أثناء التطوير

### Twitter: "Invalid callback URL"
**الحل:** تأكد من إضافة `mediapro://twitter-callback` في Callback URLs

### LinkedIn: "redirect_uri_mismatch"
**الحل:** تأكد من مطابقة Redirect URI في الكود مع المسجل في LinkedIn

### TikTok: "The redirect_uri does not match"
**الحل:** استخدم HTTPS redirect URI (TikTok لا يدعم custom schemes)

---

**آخر تحديث:** 2025-11-09
**الوقت المتوقع للإعداد الكامل:** 2-3 ساعات
