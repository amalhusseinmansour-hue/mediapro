# 🔐 إعداد بيانات اعتماد Facebook للتطبيق

## 📋 المعلومات المطلوبة

لقد قمت بتزويدنا بالمعلومات التالية:

| البيان | القيمة |
|--------|---------|
| **Facebook App ID** | `584590888044068` |
| **Facebook App Secret** | `f547157879e29e24569369745dc3dd06` |

---

## ✅ التحديثات التي تمت

### 1️⃣ ملف Android Strings (✅ تم)
**الملف:** `android/app/src/main/res/values/strings.xml`

```xml
<string name="facebook_app_id">584590888044068</string>
<string name="fb_login_protocol_scheme">fb584590888044068</string>
<string name="facebook_client_token">f547157879e29e24569369745dc3dd06</string>
```

### 2️⃣ ملف .env (✅ تم)
**الملف:** `.env`

```env
FACEBOOK_APP_ID=584590888044068
FACEBOOK_APP_SECRET=f547157879e29e24569369745dc3dd06
```

⚠️ **مهم:** ملف `.env` محمي ولن يتم رفعه إلى Git (موجود في `.gitignore`)

---

## 🔧 إعدادات Facebook Developers المطلوبة

### 1. إعدادات التطبيق الأساسية

اذهب إلى: https://developers.facebook.com/apps/584590888044068/settings/basic/

تأكد من:
- ✅ **App ID:** 584590888044068
- ✅ **App Secret:** موجود وصحيح
- ✅ **Display Name:** اسم تطبيقك (مثلاً: ميديا برو)
- ✅ **Contact Email:** بريدك الإلكتروني
- ✅ **App Domains:** (اختياري) النطاقات المسموح بها

### 2. إضافة منتج Facebook Login

اذهب إلى: https://developers.facebook.com/apps/584590888044068/fb-login/settings/

قم بـ:
1. إضافة منتج **Facebook Login**
2. اختر **Android** كمنصة
3. أدخل معلومات التطبيق:

```
Package Name: com.socialmedia.social_media_manager
Default Activity Class Name: com.socialmedia.social_media_manager.MainActivity
```

### 3. إضافة Key Hashes

لتوليد Key Hash لتطبيق Android:

#### أ. للتطوير (Debug):
```bash
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
```

الكلمة السرية الافتراضية: `android`

#### ب. للإنتاج (Release):
```bash
keytool -exportcert -alias YOUR_RELEASE_KEY_ALIAS -keystore YOUR_RELEASE_KEY_PATH | openssl sha1 -binary | openssl base64
```

**ضع Key Hash في:**
https://developers.facebook.com/apps/584590888044068/settings/basic/

### 4. إضافة الأذونات المطلوبة

في **App Review > Permissions and Features**:

طلب الأذونات التالية:
- ✅ `pages_manage_posts` - للنشر على الصفحات
- ✅ `pages_read_engagement` - لقراءة تفاعل الصفحة
- ✅ `pages_show_list` - لعرض قائمة الصفحات
- ✅ `instagram_basic` - معلومات Instagram الأساسية
- ✅ `instagram_content_publish` - النشر على Instagram

⚠️ **ملاحظة:** بعض الأذونات تحتاج موافقة Facebook (App Review)

### 5. إضافة OAuth Redirect URIs

في **Facebook Login > Settings > Valid OAuth Redirect URIs**:

```
https://mediaprosocial.io/auth/facebook/callback
https://www.mediaprosocial.io/auth/facebook/callback
http://localhost/auth/facebook/callback
```

---

## 📱 إعدادات التطبيق Android

### 1. Android Manifest
**الملف:** `android/app/src/main/AndroidManifest.xml`

تأكد من وجود:

```xml
<!-- Facebook Content Provider -->
<provider
    android:authorities="com.facebook.app.FacebookContentProvider584590888044068"
    android:name="com.facebook.FacebookContentProvider"
    android:exported="true" />

<!-- Facebook Login Activities -->
<activity android:name="com.facebook.FacebookActivity"
    android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
    android:label="@string/app_name" />

<activity
    android:name="com.facebook.CustomTabActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="@string/fb_login_protocol_scheme" />
    </intent-filter>
</activity>
```

### 2. تطبيق التغييرات
```bash
flutter clean
flutter pub get
flutter run -d R9KY902X3HW
```

---

## 🧪 اختبار OAuth

### 1. في التطبيق:
1. افتح التطبيق
2. اذهب إلى **الحسابات** → **ربط حساب جديد**
3. اضغط على **Facebook**
4. سيفتح متصفح Facebook OAuth
5. سجل الدخول وامنح الأذونات
6. يجب أن يتم الربط بنجاح

### 2. رسائل Console المتوقعة:
```
🔵 Starting Facebook login...
✅ Facebook login successful!
   Token: EAAIVkl...
📄 Loading user pages...
✅ Loaded 3 pages
```

---

## ❓ استكشاف الأخطاء

### ⚠️ خطأ: "Invalid key hash"
**الحل:** تأكد من إضافة Key Hash في Facebook Developers

### ⚠️ خطأ: "App not setup"
**الحل:** تأكد من:
1. Facebook App ID صحيح في `strings.xml`
2. `FacebookContentProvider` موجود في Manifest مع رقم App ID الصحيح
3. أعد بناء التطبيق بعد التعديلات

### ⚠️ خطأ: "Login cancelled"
**الحل:** هذا طبيعي إذا ألغى المستخدم عملية تسجيل الدخول

### ⚠️ خطأ: "Permissions denied"
**الحل:**
1. بعض الأذونات تحتاج App Review من Facebook
2. استخدم أذونات أساسية أولاً (public_profile, email)

---

## 📊 استخدام API

### نشر نص على صفحة Facebook:
```dart
final result = await _facebookService.postTextToPage(
  pageId: 'YOUR_PAGE_ID',
  pageAccessToken: 'YOUR_PAGE_ACCESS_TOKEN',
  message: 'مرحباً من تطبيق ميديا برو!',
);

if (result['success']) {
  print('تم النشر بنجاح! Post ID: ${result['post_id']}');
}
```

### نشر صورة على Instagram:
```dart
final result = await _facebookService.postPhotoToInstagram(
  instagramAccountId: 'YOUR_IG_ACCOUNT_ID',
  pageAccessToken: 'YOUR_PAGE_ACCESS_TOKEN',
  imageUrl: 'https://example.com/image.jpg',
  caption: 'صورة جميلة من ميديا برو',
);
```

---

## 🔒 أمان المفاتيح

### ✅ ما تم حمايته:
- ✅ `.env` موجود في `.gitignore`
- ✅ `FACEBOOK_APP_SECRET` لن يتم رفعه إلى Git
- ✅ `strings.xml` يحتوي فقط على App ID (آمن للمشاركة)

### ⚠️ تحذيرات:
- ⚠️ **لا تشارك** `FACEBOOK_APP_SECRET` مع أي شخص
- ⚠️ **لا ترفع** ملف `.env` إلى GitHub
- ⚠️ **استخدم** `.env.example` للمشاركة (بدون قيم حقيقية)

---

## 📚 المراجع

- [Facebook Login for Android](https://developers.facebook.com/docs/facebook-login/android)
- [Facebook Graph API](https://developers.facebook.com/docs/graph-api)
- [Instagram Graph API](https://developers.facebook.com/docs/instagram-api)
- [Flutter Facebook Auth Plugin](https://pub.dev/packages/flutter_facebook_auth)

---

**تم إعداده بتاريخ:** 2025-11-14
**حالة الإعداد:** ✅ جاهز للاختبار
