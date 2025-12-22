# دليل تكامل OAuth - طريقة String

## نظرة عامة
تم تعديل نظام ربط حسابات السوشال ميديا ليعمل بنفس أسلوب تطبيق String في السعودية:
- ضغط → OAuth مباشر
- رجوع للتطبيق عبر Deep Link
- حفظ تلقائي
- تحديث الحالة

---

## ما تم تنفيذه

### 1. Laravel Backend

#### الملفات الجديدة:
```
backend/app/Http/Controllers/Api/SocialAuthController.php
backend/resources/views/oauth/redirect.blade.php
```

#### الملفات المعدلة:
```
backend/routes/api.php
backend/config/services.php
```

#### الـ Endpoints الجديدة:
- `GET /api/auth/{platform}/redirect` - الحصول على رابط OAuth
- `GET /api/auth/{platform}/callback` - استقبال OAuth callback
- `GET /api/auth/connected-accounts` - الحسابات المربوطة

#### المنصات المدعومة:
- Instagram
- Facebook
- Twitter (X)
- LinkedIn
- TikTok
- YouTube
- Snapchat

---

### 2. Flutter Frontend

#### الملفات الجديدة:
```
lib/services/string_style_oauth_service.dart
lib/screens/accounts/accounts_screen_updated.dart (تعليمات)
```

#### الملفات المعدلة:
```
lib/services/api_service.dart
lib/screens/accounts/accounts_screen.dart (يحتاج تطبيق التعديلات)
```

---

## خطوات التفعيل

### الخطوة 1: تكوين OAuth Credentials

أضف المتغيرات التالية في `.env`:

```env
# Instagram
INSTAGRAM_CLIENT_ID=your_instagram_client_id
INSTAGRAM_CLIENT_SECRET=your_instagram_client_secret

# Facebook
FACEBOOK_APP_ID=your_facebook_app_id
FACEBOOK_APP_SECRET=your_facebook_app_secret

# Twitter (X)
TWITTER_API_KEY=your_twitter_api_key
TWITTER_API_SECRET=your_twitter_api_secret

# LinkedIn
LINKEDIN_CLIENT_ID=your_linkedin_client_id
LINKEDIN_CLIENT_SECRET=your_linkedin_client_secret

# TikTok
TIKTOK_CLIENT_ID=your_tiktok_client_id
TIKTOK_CLIENT_SECRET=your_tiktok_client_secret

# Google (for YouTube)
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

# Snapchat
SNAPCHAT_CLIENT_ID=your_snapchat_client_id
SNAPCHAT_CLIENT_SECRET=your_snapchat_client_secret

# Mobile App Deep Link Scheme
# استخدم: socialmediamanager://
```

### الخطوة 2: تكوين Deep Links في Flutter

#### Android (`android/app/src/main/AndroidManifest.xml`):

```xml
<activity android:name=".MainActivity">
    <!-- ... existing code ... -->

    <!-- Deep Link for OAuth Callback -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />

        <!-- Custom scheme -->
        <data
            android:scheme="socialmediamanager"
            android:host="oauth" />
    </intent-filter>
</activity>
```

#### iOS (`ios/Runner/Info.plist`):

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.yourdomain.socialmediamanager</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>socialmediamanager</string>
        </array>
    </dict>
</array>
```

### الخطوة 3: إضافة Dependencies في Flutter

في `pubspec.yaml`:

```yaml
dependencies:
  url_launcher: ^6.2.4
  uni_links: ^0.5.1
```

ثم قم بتشغيل:
```bash
flutter pub get
```

### الخطوة 4: تطبيق التعديلات على accounts_screen.dart

افتح ملف `accounts_screen_updated.dart` وقم بنسخ التعديلات المطلوبة إلى `accounts_screen.dart` الأصلي.

التعديلات الأساسية:
1. استيراد `StringStyleOAuthService`
2. إضافة متغير `_oauthService`
3. استبدال `_buildAddAccountButton()`
4. إضافة `_showPlatformSelectionDialog()`
5. إضافة `_buildPlatformCard()`
6. إضافة `_connectPlatform()`
7. إضافة `_confirmDisconnect()`

### الخطوة 5: تسجيل Service في main.dart

في `main.dart`:

```dart
import 'services/string_style_oauth_service.dart';

void main() {
  // ... existing code ...

  // Register OAuth Service
  Get.put(StringStyleOAuthService());

  // ... rest of code ...
}
```

### الخطوة 6: رفع التعديلات إلى السيرفر

```bash
cd backend
git add .
git commit -m "Add String-style OAuth integration for social media accounts"
git push
```

ثم على السيرفر:
```bash
cd /home/u126213189/domains/mediaprosocial.io/public_html
git pull
php artisan config:clear
php artisan cache:clear
php artisan route:clear
```

---

## كيفية الحصول على OAuth Credentials

### Instagram
1. اذهب إلى: https://developers.facebook.com/apps
2. أنشئ تطبيق جديد
3. أضف منتج "Instagram"
4. في الإعدادات، أضف Redirect URI: `https://yourdomain.com/api/auth/instagram/callback`
5. احصل على App ID و App Secret

### Facebook
1. نفس التطبيق من Instagram
2. أضف منتج "Facebook Login"
3. أضف Redirect URI: `https://yourdomain.com/api/auth/facebook/callback`

### Twitter (X)
1. اذهب إلى: https://developer.twitter.com/en/portal/dashboard
2. أنشئ مشروع وتطبيق
3. في OAuth 2.0 Settings، أضف: `https://yourdomain.com/api/auth/twitter/callback`
4. احصل على Client ID و Client Secret

### LinkedIn
1. اذهب إلى: https://www.linkedin.com/developers/apps
2. أنشئ تطبيق جديد
3. في "Auth" tab، أضف Redirect URL: `https://yourdomain.com/api/auth/linkedin/callback`
4. احصل على Client ID و Client Secret

### TikTok
1. اذهب إلى: https://developers.tiktok.com/
2. أنشئ تطبيق
3. أضف Redirect URI: `https://yourdomain.com/api/auth/tiktok/callback`

### YouTube (Google)
1. اذهب إلى: https://console.cloud.google.com/
2. أنشئ مشروع
3. فعّل YouTube Data API v3
4. في OAuth consent screen، أضف scope: YouTube
5. في Credentials، أنشئ OAuth 2.0 Client ID
6. أضف Redirect URI: `https://yourdomain.com/api/auth/youtube/callback`

---

## Flow التنفيذ

```
1. User clicks platform button (e.g., Instagram)
   ↓
2. Flutter calls: /api/auth/instagram/redirect
   ↓
3. Laravel returns OAuth URL
   ↓
4. Flutter opens URL in browser
   ↓
5. User authorizes on platform
   ↓
6. Platform redirects to: /api/auth/instagram/callback
   ↓
7. Laravel exchanges code for access_token
   ↓
8. Laravel saves account to connected_accounts table
   ↓
9. Laravel redirects to deep link: socialmediamanager://oauth/callback?success=true&platform=instagram
   ↓
10. Flutter receives deep link
   ↓
11. Flutter closes dialog and reloads accounts
   ↓
12. UI shows "Linked ✓"
```

---

## Testing

### Test Deep Links:
```bash
# Android
adb shell am start -W -a android.intent.action.VIEW -d "socialmediamanager://oauth/callback?success=true&platform=instagram&username=test_user"

# iOS (Simulator)
xcrun simctl openurl booted "socialmediamanager://oauth/callback?success=true&platform=instagram&username=test_user"
```

### Test OAuth Flow:
1. افتح التطبيق
2. اذهب إلى شاشة "إدارة الحسابات"
3. اضغط "ربط حساب جديد"
4. اختر منصة (مثلاً Instagram)
5. سيتم فتح صفحة OAuth في المتصفح
6. قم بتسجيل الدخول والموافقة
7. يجب أن يعود التطبيق تلقائياً ويظهر "تم الربط بنجاح"

---

## Troubleshooting

### المشكلة: Deep link لا يعمل
**الحل:**
- تأكد من تكوين AndroidManifest.xml و Info.plist بشكل صحيح
- تأكد من تثبيت uni_links package
- أعد بناء التطبيق بالكامل

### المشكلة: OAuth يعيد خطأ "redirect_uri_mismatch"
**الحل:**
- تأكد من أن Redirect URI في إعدادات المنصة مطابق تماماً لما في الكود
- يجب استخدام HTTPS في الإنتاج

### المشكلة: لا يتم حفظ الحساب
**الحل:**
- تحقق من logs في Laravel: `tail -f storage/logs/laravel.log`
- تأكد من أن جدول connected_accounts موجود في قاعدة البيانات
- تأكد من أن User مُصادق عليه (Bearer token صحيح)

---

## Security Notes

1. **لا تشارك أبداً** Client Secrets في الكود
2. استخدم HTTPS فقط في الإنتاج
3. قم بتدوير Tokens بانتظام
4. تحقق من State parameter للحماية من CSRF
5. استخدم token encryption في قاعدة البيانات

---

## Next Steps

بعد تفعيل OAuth:
1. اختبر جميع المنصات
2. أضف error handling إضافي
3. أضف token refresh logic للـ tokens منتهية الصلاحية
4. أضف analytics لتتبع نجاح/فشل الربط
5. أضف rate limiting للـ OAuth endpoints

---

## Support

للمشاكل أو الأسئلة:
- تحقق من Laravel logs
- تحقق من Flutter console
- راجع documentation الرسمية لكل منصة
