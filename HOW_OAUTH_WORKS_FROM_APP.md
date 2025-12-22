# 🔗 كيف يربط المستخدم حسابه من التطبيق

## ✅ الطريقة الصحيحة (من التطبيق)

### السيناريو:

```
1. المستخدم يفتح التطبيق
2. يذهب إلى "إدارة Social Media"
3. يضغط "ربط حساب"
4. يختار "Facebook" مثلاً
5. يفتح صفحة OAuth في المتصفح
6. يسجل دخول في Facebook ويوافق
7. يرجع للتطبيق
8. ✅ الحساب مربوط!
```

---

## 🔍 كيف يعمل تقنياً؟

### الخطوة 1: المستخدم يضغط "ربط Facebook"

**في التطبيق (Flutter):**

```dart
// في connect_accounts_screen.dart السطر 150+
Future<void> _connectAccount(SocialPlatform platform) async {
  setState(() => _isConnecting = true);

  try {
    // 1️⃣ التطبيق يطلب OAuth Link من Laravel
    final result = await _postizManager.connectSocialAccount(
      platform: platform.name,  // 'facebook'
      userId: 'USER_ID',
    );

    // 2️⃣ يستلم رابط OAuth
    final oauthUrl = result['oauth_url'];

    // 3️⃣ يفتح المتصفح
    if (await canLaunchUrl(Uri.parse(oauthUrl))) {
      await launchUrl(
        Uri.parse(oauthUrl),
        mode: LaunchMode.externalApplication, // يفتح في متصفح خارجي
      );
    }
  } catch (e) {
    _showError('فشل الربط: $e');
  }
}
```

---

### الخطوة 2: التطبيق يطلب من Laravel

**Flutter → Laravel:**

```http
POST https://mediaprosocial.io/api/postiz/oauth-link
Authorization: Bearer {USER_TOKEN}
Content-Type: application/json

{
  "platform": "facebook",
  "user_id": "123"
}
```

---

### الخطوة 3: Laravel يطلب من Postiz

**Laravel → Postiz:**

```php
// في PostizController.php السطر 50+
$response = Http::withHeaders([
    'Authorization' => $this->apiKey, // Postiz API Key
])->post($this->baseUrl . '/integrations/social/facebook', [
    'callback' => 'mprosocial://oauth-success',
    'state' => $userId,
]);

$oauthUrl = $response['url'];
```

**Postiz يرجع:**
```json
{
  "url": "https://www.facebook.com/v18.0/dialog/oauth?client_id=xxx&redirect_uri=..."
}
```

---

### الخطوة 4: Laravel يرجع الرابط للتطبيق

**Laravel → Flutter:**

```json
{
  "success": true,
  "data": {
    "url": "https://www.facebook.com/v18.0/dialog/oauth?..."
  }
}
```

---

### الخطوة 5: التطبيق يفتح المتصفح

**Flutter يفتح:**
```
https://www.facebook.com/v18.0/dialog/oauth?
  client_id=POSTIZ_FACEBOOK_APP_ID
  &redirect_uri=https://api.postiz.com/callback
  &state=USER_123
  &scope=pages_manage_posts,pages_read_engagement
```

**المستخدم يرى:**
```
┌──────────────────────────────────┐
│  Facebook                     [×]│
├──────────────────────────────────┤
│                                  │
│  MediaProSocial wants to:        │
│  ✓ Manage your Pages             │
│  ✓ Publish posts                 │
│  ✓ Read engagement               │
│                                  │
│  [Cancel]    [Continue]          │
└──────────────────────────────────┘
```

---

### الخطوة 6: المستخدم يوافق

**عند الضغط على "Continue":**

Facebook يرجع المستخدم إلى:
```
https://api.postiz.com/callback?
  code=FACEBOOK_AUTH_CODE
  &state=USER_123
```

**Postiz:**
- يستلم الـ code
- يستبدله بـ Access Token من Facebook
- يحفظ الـ token
- يرجع المستخدم للتطبيق

**الرجوع للتطبيق:**
```
mprosocial://oauth-success?
  integration_id=POSTIZ_INTEGRATION_ID
  &user_id=USER_123
```

---

### الخطوة 7: التطبيق يستقبل النتيجة

**في Flutter:**

```dart
// Deep Link Handler
void _handleDeepLink(Uri uri) {
  if (uri.scheme == 'mprosocial') {
    if (uri.host == 'oauth-success') {
      // ✅ نجح الربط!
      final integrationId = uri.queryParameters['integration_id'];
      _showSuccess('تم ربط الحساب بنجاح!');
      _loadAccounts(); // تحديث القائمة
    } else if (uri.host == 'oauth-failed') {
      // ❌ فشل الربط
      _showError('فشل الربط');
    }
  }
}
```

---

## ✅ الحساب الآن مربوط!

**المستخدم يمكنه:**
- ✅ رؤية الحساب في قائمة "الحسابات المربوطة"
- ✅ النشر عليه من التطبيق
- ✅ جدولة منشورات
- ✅ رؤية التحليلات

---

## 🎯 المهم: لا يحتاج المستخدم فعل أي شيء في Postiz Dashboard!

**كل شيء من التطبيق:**
```
✅ الربط → من التطبيق
✅ النشر → من التطبيق
✅ الجدولة → من التطبيق
✅ التحليلات → من التطبيق
✅ الفصل → من التطبيق
```

**Postiz يعمل في الخلفية فقط!**

---

## ⚠️ لكن... هناك خطوة واحدة مهمة!

### يجب أن يكون Postiz لديه OAuth Apps!

**Postiz يحتاج:**
- ✅ Facebook App ID & Secret
- ✅ Twitter Client ID & Secret
- ✅ LinkedIn Client ID & Secret
- إلخ...

**لحسن الحظ:**

### ✅ Postiz Platform (Ultimate) لديه OAuth Apps جاهزة!

عندما اشتركت في **Postiz Ultimate**، حصلت على:
- ✅ Facebook OAuth App (خاص بـ Postiz)
- ✅ Twitter OAuth App (خاص بـ Postiz)
- ✅ LinkedIn OAuth App (خاص بـ Postiz)
- ✅ جميع المنصات الأخرى

**يعني:**
- ❌ **لا تحتاج** إنشاء Facebook Developer App
- ❌ **لا تحتاج** إنشاء Twitter Developer App
- ✅ **تستخدم** OAuth Apps الخاصة بـ Postiz

---

## 🧪 اختبار الآن!

### الخطوة 1: شغّل التطبيق

```bash
cd C:\Users\HP\social_media_manager
flutter run
```

### الخطوة 2: في التطبيق

```
1. "إدارة Social Media"
2. "ربط حساب"
3. اختر "Facebook"
4. يفتح متصفح بصفحة Facebook OAuth ✅
5. سجل دخول ووافق
6. يرجع للتطبيق ✅
7. الحساب يظهر في القائمة ✅
```

---

## 🔍 إذا لم يعمل OAuth

### مشكلة محتملة 1: Deep Link غير معدّ

**الحل:**

**Android** (`android/app/src/main/AndroidManifest.xml`):

تأكد من وجود:
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="mprosocial" />
</intent-filter>
```

**iOS** (`ios/Runner/Info.plist`):

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

### مشكلة محتملة 2: Postiz OAuth غير معدّ

**تحقق:**

```
1. https://platform.postiz.com
2. Settings → Integrations
3. تأكد أن Facebook, Twitter, LinkedIn مفعّلة
```

**إذا لم تكن مفعّلة:**
- Postiz Platform Ultimate **يجب** أن تكون معدّة مسبقاً
- تواصل مع Postiz Support إذا لم تكن كذلك

---

## 📊 Flow Chart كامل

```
المستخدم
   │
   ├─> يفتح التطبيق
   │
   ├─> "ربط حساب" → "Facebook"
   │
   ├─> Flutter يطلب من Laravel
   │       │
   │       ├─> Laravel يطلب من Postiz
   │       │       │
   │       │       └─> Postiz يرجع OAuth URL
   │       │
   │       └─> Laravel يرجع URL للتطبيق
   │
   ├─> التطبيق يفتح المتصفح
   │
   ├─> Facebook OAuth Page
   │       │
   │       └─> المستخدم يوافق
   │
   ├─> Facebook → Postiz (مع code)
   │
   ├─> Postiz يحفظ Access Token
   │
   ├─> Postiz → التطبيق (Deep Link)
   │
   └─> ✅ تم الربط!
```

---

## 💡 الخلاصة

**نعم! المستخدم يربط حسابه من التطبيق مباشرة!**

```
✅ لا يحتاج فتح Postiz Dashboard
✅ لا يحتاج إنشاء OAuth Apps
✅ لا يحتاج أي إعدادات خارجية
✅ كل شيء من التطبيق!
```

**فقط:**
- ✅ Postiz API Key موجود (تم ✅)
- ✅ Postiz OAuth Apps جاهزة (Ultimate Plan ✅)
- ✅ Deep Links معدّة في التطبيق (موجودة ✅)

---

## 🚀 جرّب الآن!

```bash
flutter run
```

**ثم:**
```
إدارة Social Media → ربط حساب → Facebook
```

**يجب أن يفتح صفحة Facebook OAuth!** ✅

---

**آخر تحديث:** 2025-01-15
**الحالة:** ✅ جاهز للاختبار من التطبيق مباشرة!
