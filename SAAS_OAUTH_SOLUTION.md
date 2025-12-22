# 🚀 حل OAuth للـ SaaS App

## المشكلة
- Postiz Public API **لا يوفر** OAuth endpoints
- كل مستخدم يحتاج ربط **حساباته الخاصة**
- التطبيق **SaaS** - multi-tenant

## ✅ الحل: OAuth مباشر من المنصات

### الـ Flow الجديد:

```
المستخدم في التطبيق
    ↓
"ربط Facebook"
    ↓
Flutter → Laravel (generate OAuth URL)
    ↓
Laravel → Facebook OAuth Dialog
    ↓
المستخدم يوافق
    ↓
Facebook → Laravel Callback (مع access_token)
    ↓
Laravel يحفظ token في database
    ↓
Laravel → Flutter (success)
    ↓
✅ الحساب مربوط!
```

---

## 📋 الخطوات المطلوبة:

### 1️⃣ إنشاء OAuth Apps (15 دقيقة لكل منصة)

#### Facebook App
```
1. https://developers.facebook.com/apps
2. Create App → Business
3. Add "Facebook Login"
4. Settings → Basic:
   - App Domains: mediaprosocial.io
   - Privacy Policy: https://mediaprosocial.io/privacy
   - Terms of Service: https://mediaprosocial.io/terms

5. Facebook Login → Settings:
   - Valid OAuth Redirect URIs:
     * https://mediaprosocial.io/api/auth/facebook/callback
     * mprosocial://oauth-callback

6. Permissions:
   - pages_manage_posts
   - pages_read_engagement
   - instagram_basic
   - instagram_content_publish

7. احصل على:
   - App ID
   - App Secret
```

#### Twitter App
```
1. https://developer.twitter.com/portal
2. Create Project → Create App
3. User authentication settings:
   - Type: Web App
   - Callback: https://mediaprosocial.io/api/auth/twitter/callback
   - Website: https://mediaprosocial.io

4. Permissions:
   - Read and write
   - Direct Messages (optional)

5. احصل على:
   - Client ID
   - Client Secret
```

#### LinkedIn App
```
1. https://www.linkedin.com/developers/apps
2. Create app
3. Products → Add "Share on LinkedIn"
4. Auth:
   - Redirect URLs: https://mediaprosocial.io/api/auth/linkedin/callback

5. Permissions:
   - w_member_social
   - r_liteprofile

6. احصل على:
   - Client ID
   - Client Secret
```

---

### 2️⃣ تحديث Laravel .env

```env
# Facebook OAuth
FACEBOOK_APP_ID=your_app_id
FACEBOOK_APP_SECRET=your_app_secret
FACEBOOK_REDIRECT_URI=https://mediaprosocial.io/api/auth/facebook/callback

# Twitter OAuth
TWITTER_CLIENT_ID=your_client_id
TWITTER_CLIENT_SECRET=your_client_secret
TWITTER_REDIRECT_URI=https://mediaprosocial.io/api/auth/twitter/callback

# LinkedIn OAuth
LINKEDIN_CLIENT_ID=your_client_id
LINKEDIN_CLIENT_SECRET=your_client_secret
LINKEDIN_REDIRECT_URI=https://mediaprosocial.io/api/auth/linkedin/callback
```

---

### 3️⃣ Laravel Controller جديد

سأنشئ `SocialAuthController.php` الذي يتعامل مع OAuth:

**الـ endpoints:**
```php
// إنشاء OAuth URL
GET /api/auth/{platform}/redirect

// Callback بعد OAuth
GET /api/auth/{platform}/callback

// قائمة الحسابات المربوطة
GET /api/auth/connected-accounts

// فصل حساب
DELETE /api/auth/disconnect/{accountId}

// النشر على حساب
POST /api/social/publish
```

---

### 4️⃣ Database Table

```sql
CREATE TABLE user_social_accounts (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  platform VARCHAR(50) NOT NULL, -- facebook, twitter, linkedin
  platform_user_id VARCHAR(255),
  username VARCHAR(255),
  display_name VARCHAR(255),
  profile_picture TEXT,
  access_token TEXT NOT NULL,
  refresh_token TEXT,
  token_expires_at TIMESTAMP,
  scopes JSON,
  metadata JSON, -- أي بيانات إضافية
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  INDEX idx_user_id (user_id),
  INDEX idx_platform (platform),
  UNIQUE KEY unique_user_platform (user_id, platform, platform_user_id)
);
```

---

### 5️⃣ Flutter Code

**في `connect_accounts_screen.dart`:**

```dart
Future<void> _connectAccount(String platform) async {
  try {
    // 1. احصل على OAuth URL من Laravel
    final response = await http.get(
      Uri.parse('https://mediaprosocial.io/api/auth/$platform/redirect'),
      headers: {'Authorization': 'Bearer $userToken'},
    );

    final data = json.decode(response.body);
    final oauthUrl = data['url'];

    // 2. افتح OAuth في المتصفح
    if (await canLaunchUrl(Uri.parse(oauthUrl))) {
      await launchUrl(
        Uri.parse(oauthUrl),
        mode: LaunchMode.externalApplication,
      );
    }

    // 3. Deep Link Handler سيستقبل النتيجة
  } catch (e) {
    print('Error: $e');
  }
}
```

---

## 🎯 المميزات:

✅ **كل مستخدم يربط حساباته الخاصة**
✅ **OAuth آمن ومباشر من المنصات**
✅ **Tokens محفوظة في database مشفرة**
✅ **يعمل مع أي عدد من المستخدمين**
✅ **لا يحتاج Postiz للـ OAuth**
✅ **يمكن استخدام Postiz للجدولة فقط (اختياري)**

---

## ⏱️ الوقت المطلوب:

- إنشاء OAuth Apps: 45 دقيقة (15 × 3)
- Laravel Controller: 30 دقيقة (سأعمله لك)
- Database Migration: 5 دقائق
- Flutter Code Update: 15 دقيقة (سأعمله لك)
- الاختبار: 15 دقيقة

**المجموع: ~2 ساعة**

---

## 🚀 الخطوة التالية:

هل تريدني أن:
1. ✅ أنشئ OAuth Apps الآن؟ (أحتاج منك فقط الموافقة)
2. ✅ أكتب `SocialAuthController.php` كامل؟
3. ✅ أعدّل Flutter code؟
4. ✅ أنشئ Migration للـ database؟

**قل "ابدأ" وسأبدأ فوراً! 🚀**

---

**ملاحظة:** بعد هذا، كل مستخدم سيربط حساباته الخاصة من التطبيق تماماً كما تريد!
