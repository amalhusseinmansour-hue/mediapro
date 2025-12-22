# دليل إعداد OAuth للربط التلقائي مع حسابات التواصل الاجتماعي

## نظرة عامة
تم تطوير نظام OAuth للربط التلقائي مع منصات التواصل الاجتماعي. يتيح هذا للمستخدمين ربط حساباتهم بنقرة واحدة دون الحاجة لإدخال بيانات يدوياً.

## المنصات المدعومة

### ✅ جاهز للتشغيل (بعد التكوين):
- **Facebook** - عبر Facebook Login SDK
- **Instagram** - عبر Facebook Graph API
- **Twitter/X** - عبر Twitter Login
- **YouTube** - عبر Google Sign-In

### 📝 قيد التطوير:
- **TikTok** - يتطلب WebView OAuth
- **Snapchat** - يتطلب WebView OAuth
- **LinkedIn** - يتطلب WebView OAuth

---

## 1. Facebook & Instagram Setup

### الخطوة 1: إنشاء تطبيق Facebook
1. اذهب إلى [Facebook for Developers](https://developers.facebook.com/)
2. اضغط **"My Apps"** → **"Create App"**
3. اختر **"Consumer"** كنوع التطبيق
4. أدخل اسم التطبيق: **"ميديا برو"** أو اسم من اختيارك
5. أدخل بريدك الإلكتروني

### الخطوة 2: الحصول على App ID
1. من Dashboard، انسخ **App ID**
2. افتح الملف: `android/app/src/main/res/values/strings.xml`
3. استبدل `YOUR_FACEBOOK_APP_ID` بالـ App ID الذي حصلت عليه
4. استبدل `{YOUR_FACEBOOK_APP_ID}` في `android/app/src/main/AndroidManifest.xml`

### الخطوة 3: إضافة Android Platform
1. في Facebook Dashboard → **Settings** → **Basic**
2. اضغط **"Add Platform"** → اختر **Android**
3. أدخل:
   - **Package Name**: `com.example.social_media_manager`
   - **Class Name**: `com.example.social_media_manager.MainActivity`
   - **Key Hashes**: احصل عليه عبر:
   ```bash
   keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
   ```
   (كلمة المرور الافتراضية: `android`)

### الخطوة 4: تفعيل Facebook Login
1. في Dashboard → **Products** → اضغط **"Set Up"** بجانب **Facebook Login**
2. في **Settings** → **Facebook Login**:
   - فعّل **"Login from Devices"**
   - أضف `com.facebook.app.FacebookContentProvider{YOUR_APP_ID}` إلى **Valid OAuth Redirect URIs**

### الخطوة 5: Instagram Integration (اختياري)
1. في Dashboard → **Products** → أضف **Instagram Basic Display**
2. املأ معلومات التطبيق المطلوبة
3. في **Instagram Basic Display** → **User Token Generator**

---

## 2. Twitter/X Setup

### الخطوة 1: إنشاء Twitter App
1. اذهب إلى [Twitter Developer Portal](https://developer.twitter.com/en/portal/dashboard)
2. سجل حساب Developer إذا لم يكن لديك
3. اضغط **"Create Project"** → **"Create App"**
4. أدخل اسم التطبيق

### الخطوة 2: الحصول على API Keys
1. في App Settings → **Keys and Tokens**
2. انسخ:
   - **API Key** (Consumer Key)
   - **API Secret Key** (Consumer Secret)
3. افتح ملف `lib/core/config/api_config.dart`
4. ضع المفاتيح:
```dart
static const String twitterApiKey = 'YOUR_TWITTER_API_KEY';
static const String twitterApiSecret = 'YOUR_TWITTER_API_SECRET';
```

### الخطوة 3: إعدادات OAuth
1. في App Settings → **User authentication settings** → **Set up**
2. فعّل **OAuth 1.0a**
3. أدخل:
   - **Callback URL**: `social-media-manager://callback`
   - **Website URL**: `https://mediaprosocial.io`
4. Permissions: **Read and Write**

---

## 3. YouTube/Google Setup

### الخطوة 1: إنشاء Google Cloud Project
1. اذهب إلى [Google Cloud Console](https://console.cloud.google.com/)
2. اضغط **"Create Project"**
3. أدخل اسم المشروع: **"Social Media Manager"**

### الخطوة 2: تفعيل YouTube API
1. في Dashboard → **APIs & Services** → **Library**
2. ابحث عن **"YouTube Data API v3"**
3. اضغط **"Enable"**

### الخطوة 3: إنشاء OAuth Credentials
1. في **APIs & Services** → **Credentials**
2. اضغط **"Create Credentials"** → **OAuth client ID**
3. اختر **Android** كنوع التطبيق
4. أدخل:
   - **Package Name**: `com.example.social_media_manager`
   - **SHA-1**: احصل عليه عبر:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey
   ```
5. احفظ OAuth Client ID

---

## 4. TikTok Setup (قيد التطوير)

TikTok يتطلب WebView OAuth Flow:
1. سجل في [TikTok for Developers](https://developers.tiktok.com/)
2. أنشئ تطبيق جديد
3. احصل على **Client Key** و **Client Secret**
4. ضعهما في `api_config.dart`

> **ملاحظة**: سيتم إضافة دعم TikTok OAuth قريباً عبر WebView

---

## 5. LinkedIn Setup (قيد التطوير)

> **ملاحظة**: تم تعطيل LinkedIn مؤقتاً بسبب تعارض في المكتبات. سيتم إضافته لاحقاً.

---

## الاختبار

### 1. Facebook/Instagram
```bash
# قم بتشغيل التطبيق
flutter run

# اذهب إلى الحسابات → ربط حساب → Facebook
# سيفتح نافذة Facebook Login
# سجل الدخول وامنح الصلاحيات
```

### 2. Twitter
```bash
# تأكد من تعيين API Keys في api_config.dart
# اذهب إلى الحسابات → ربط حساب → Twitter
# سيفتح نافذة Twitter Login
```

### 3. YouTube
```bash
# تأكد من تفعيل YouTube API في Google Cloud
# اذهب إلى الحسابات → ربط حساب → YouTube
# سيفتح Google Sign-In
# اختر الحساب الذي يحتوي على قناة YouTube
```

---

## استكشاف الأخطاء

### Facebook Login لا يعمل:
- ✅ تأكد من إضافة App ID في `strings.xml`
- ✅ تأكد من إضافة Package Name في Facebook Dashboard
- ✅ تأكد من صحة Key Hash
- ✅ تأكد من تفعيل Facebook Login في Products

### Twitter Login يعطي خطأ:
- ✅ تأكد من صحة API Keys في `api_config.dart`
- ✅ تأكد من إعداد OAuth 1.0a في Twitter Developer Portal
- ✅ تأكد من صحة Callback URL

### YouTube يطلب تسجيل دخول Google فقط:
- ✅ تأكد من تفعيل YouTube Data API v3
- ✅ تأكد من إضافة SHA-1 fingerprint
- ✅ تأكد من وجود قناة YouTube على الحساب

---

## ملفات مهمة للتعديل

### Android Configuration:
- `android/app/src/main/AndroidManifest.xml` - Facebook & OAuth setup
- `android/app/src/main/res/values/strings.xml` - Facebook App ID
- `android/app/build.gradle` - Package name

### Flutter Configuration:
- `lib/core/config/api_config.dart` - API Keys للمنصات
- `lib/services/oauth_service.dart` - منطق OAuth
- `lib/screens/accounts/accounts_screen.dart` - واجهة ربط الحسابات

---

## الخطوات التالية

### مطلوب للإنتاج:
1. ✅ إضافة Facebook App ID حقيقي
2. ✅ إضافة Twitter API Keys
3. ✅ تكوين Google Cloud Project
4. 📝 إضافة TikTok OAuth عبر WebView
5. 📝 إضافة Snapchat OAuth
6. 📝 إعادة تفعيل LinkedIn OAuth

### تحسينات مستقبلية:
- 🚀 إضافة Refresh Tokens للحفاظ على الجلسة
- 🚀 إضافة Error Handling محسّن
- 🚀 إضافة تنبيهات انتهاء صلاحية Token
- 🚀 إضافة Multi-Account Support لنفس المنصة

---

## الدعم

إذا واجهت مشاكل:
1. تحقق من logs في Android Studio
2. تأكد من جميع الإعدادات في Developer Portals
3. راجع توثيق كل منصة:
   - [Facebook Login Docs](https://developers.facebook.com/docs/facebook-login/android)
   - [Twitter OAuth Docs](https://developer.twitter.com/en/docs/authentication/oauth-1-0a)
   - [Google Sign-In Docs](https://developers.google.com/identity/sign-in/android)
