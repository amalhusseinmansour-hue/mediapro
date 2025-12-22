# 🚀 دليل إعداد OAuth الكامل - MediaPro Social (Multi-Tenant SaaS)

## ✅ ما تم إنجازه (Backend جاهز 100%)

### Laravel Backend
- ✅ `SocialAuthController.php` - موجود في السيرفر
- ✅ Routes في `routes/api.php` - مُعدّة
- ✅ Database table `social_accounts` - موجودة
- ✅ Models (`SocialAccount` + `ConnectedAccount`) - موجودة

### API Endpoints الجاهزة:
```
GET  /api/auth/{platform}/redirect       - توليد OAuth URL
GET  /api/auth/{platform}/callback       - استقبال OAuth callback
GET  /api/auth/connected-accounts        - قائمة الحسابات المربوطة
DELETE /api/connected-accounts/{id}      - فصل حساب
POST /api/social-posts                   - نشر على المنصات
```

---

## 📋 الخطوات المتبقية (3 خطوات فقط)

### ✅ الخطوة 1: إنشاء OAuth Apps (30-45 دقيقة)

راجع الملفات التفصيلية:
- 📄 `FACEBOOK_OAUTH_SETUP.md` - دليل Facebook (15 دقيقة)
- 📄 `TWITTER_OAUTH_SETUP.md` - دليل Twitter (15 دقيقة)
- 📄 `LINKEDIN_OAUTH_SETUP.md` - دليل LinkedIn (15 دقيقة)

**الناتج المطلوب:**
```env
FACEBOOK_APP_ID=xxxxxxxxxxxx
FACEBOOK_APP_SECRET=xxxxxxxxxxxx

TWITTER_CLIENT_ID=xxxxxxxxxxxx
TWITTER_CLIENT_SECRET=xxxxxxxxxxxx

LINKEDIN_CLIENT_ID=xxxxxxxxxxxx
LINKEDIN_CLIENT_SECRET=xxxxxxxxxxxx
```

---

### ✅ الخطوة 2: تحديث Laravel .env

بعد الحصول على credentials، أرسلها لي وسأقوم بإضافتها إلى `.env` على السيرفر.

أو يمكنك إضافتها يدوياً:

```bash
# SSH إلى السيرفر
ssh u126213189@82.25.83.217 -p 65002

# تعديل .env
cd /home/u126213189/domains/mediaprosocial.io/public_html
nano .env

# أضف في نهاية الملف:
FACEBOOK_APP_ID=your_app_id
FACEBOOK_APP_SECRET=your_app_secret
FACEBOOK_REDIRECT_URI=https://mediaprosocial.io/api/auth/facebook/callback

TWITTER_CLIENT_ID=your_client_id
TWITTER_CLIENT_SECRET=your_client_secret
TWITTER_REDIRECT_URI=https://mediaprosocial.io/api/auth/twitter/callback

LINKEDIN_CLIENT_ID=your_client_id
LINKEDIN_CLIENT_SECRET=your_client_secret
LINKEDIN_REDIRECT_URI=https://mediaprosocial.io/api/auth/linkedin/callback

# احفظ: Ctrl+O ثم Enter
# اخرج: Ctrl+X

# امسح الـ cache
php artisan config:clear
php artisan cache:clear
```

---

### ✅ الخطوة 3: تحديث Flutter

سأقوم بتحديث `connect_accounts_screen.dart` ليربط الحسابات عبر OAuth.

**التعديلات المطلوبة:**

1. **إضافة دالة للربط:**
```dart
Future<void> _connectSocialAccount(String platform) async {
  try {
    setState(() => _isLoading = true);

    // 1. احصل على OAuth URL من Backend
    final response = await http.get(
      Uri.parse('${BackendConfig.baseUrl}/api/auth/$platform/redirect'),
      headers: {
        'Authorization': 'Bearer ${Get.find<AuthController>().token}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final oauthUrl = data['url'];

      // 2. افتح OAuth URL في المتصفح
      if (await canLaunchUrl(Uri.parse(oauthUrl))) {
        await launchUrl(
          Uri.parse(oauthUrl),
          mode: LaunchMode.externalApplication,
        );

        Get.snackbar(
          'جاري الربط',
          'سيتم فتح المتصفح لإكمال عملية الربط',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      }
    } else {
      throw Exception('فشل في الحصول على رابط المصادقة');
    }
  } catch (e) {
    Get.snackbar(
      'خطأ',
      'فشل في ربط الحساب: $e',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    setState(() => _isLoading = false);
  }
}
```

2. **إضافة Deep Link Handler** (في `main.dart`)
```dart
// في main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Deep Link Listener
  _handleDeepLinks();

  runApp(MyApp());
}

void _handleDeepLinks() {
  // Listen to deep links
  getInitialLink().then((String? link) {
    if (link != null) {
      _handleOAuthCallback(link);
    }
  });

  linkStream.listen((String? link) {
    if (link != null) {
      _handleOAuthCallback(link);
    }
  });
}

void _handleOAuthCallback(String link) {
  // mprosocial://oauth-callback?success=true&platform=facebook
  final uri = Uri.parse(link);

  if (uri.scheme == 'mprosocial' && uri.host == 'oauth-callback') {
    final success = uri.queryParameters['success'] == 'true';
    final platform = uri.queryParameters['platform'];
    final error = uri.queryParameters['error'];

    if (success) {
      Get.snackbar(
        'نجح الربط',
        'تم ربط حساب $platform بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // Refresh connected accounts list
    } else {
      Get.snackbar(
        'فشل الربط',
        'خطأ: $error',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
```

3. **تحديث أزرار الربط:**
```dart
// في _buildPlatformCard
ElevatedButton(
  onPressed: account.isConnected
      ? null
      : () => _connectSocialAccount(account.platform),
  child: Text(account.isConnected ? 'مربوط ✓' : 'ربط الحساب'),
)
```

---

## 🧪 اختبار OAuth Flow

### 1. اختبار يدوي (من المتصفح)
```
https://mediaprosocial.io/api/auth/facebook/redirect
```
ستحتاج Bearer token صالح في الـ header

### 2. اختبار من التطبيق
1. افتح التطبيق
2. اذهب إلى **إدارة الحسابات**
3. اضغط **ربط Facebook**
4. سيفتح المتصفح
5. سجل دخول ووافق
6. سيرجع إلى التطبيق مع رسالة نجاح

---

## 📊 Flow Diagram

```
[User في Flutter]
    ↓
يضغط "ربط Facebook"
    ↓
[Flutter] → GET /api/auth/facebook/redirect (مع token)
    ↓
[Laravel] → يولد OAuth URL من Facebook
    ↓
[Flutter] → يفتح URL في المتصفح
    ↓
[User] → يسجل دخول Facebook + يوافق
    ↓
[Facebook] → يرجع إلى /api/auth/facebook/callback?code=xxx
    ↓
[Laravel] → يستبدل code بـ access_token
    ↓
[Laravel] → يحفظ token في social_accounts table (encrypted)
    ↓
[Laravel] → يعمل redirect: mprosocial://oauth-callback?success=true
    ↓
[Flutter Deep Link] → يستقبل النتيجة
    ↓
[Flutter] → يعرض رسالة نجاح + يحدث القائمة
    ↓
✅ الحساب مربوط!
```

---

## 🔒 الأمان

1. **Tokens مشفرة** - Laravel `encrypt()` function
2. **State parameter** - حماية من CSRF attacks
3. **HTTPS only** - كل الـ callbacks عبر HTTPS
4. **Token expiry** - يتم حفظ `expires_at` والتحقق منه
5. **Sanctum auth** - كل endpoints محمية بـ auth:sanctum

---

## 💾 Database Schema

جدول `social_accounts`:
```sql
id                  BIGINT
user_id             BIGINT (FK to users)
platform            VARCHAR (facebook, twitter, linkedin)
account_name        VARCHAR
account_id          VARCHAR (platform user ID)
access_token        TEXT (encrypted)
refresh_token       TEXT (encrypted, nullable)
expires_at          TIMESTAMP (nullable)
is_active           BOOLEAN (default: true)
created_at          TIMESTAMP
updated_at          TIMESTAMP
```

---

## 📱 Deep Link Configuration

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="mprosocial"
        android:host="oauth-callback" />
</intent-filter>
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>mprosocial</string>
        </array>
    </dict>
</array>
```

---

## 🎯 الخطوات التالية

1. ✅ أنشئ OAuth Apps (راجع الملفات التفصيلية)
2. ✅ أعطني الـ credentials لأضيفها في `.env`
3. ✅ سأحدث Flutter code
4. ✅ اختبر OAuth flow

**الوقت المتوقع**: 1 ساعة (معظمها إنشاء OAuth Apps)

---

## ❓ FAQ

**س: هل أحتاج إنشاء apps لكل منصة؟**
ج: نعم، لكن لمرة واحدة فقط. بعدها كل المستخدمين سيستخدمون نفس الـ apps.

**س: هل يمكن البدء بمنصة واحدة أولاً؟**
ج: نعم! ابدأ بـ Facebook فقط، ثم أضف Twitter و LinkedIn لاحقاً.

**س: ماذا عن Instagram؟**
ج: Instagram يُربط عبر Facebook (نفس الـ OAuth app).

**س: ماذا لو انتهت صلاحية الـ token؟**
ج: Controller يحفظ `refresh_token` ويمكن تجديده تلقائياً (سأضيف هذه الميزة إذا احتجتها).

**س: كم عدد المستخدمين المدعومين؟**
ج: غير محدود! كل مستخدم له tokens خاصة به في الـ database.
