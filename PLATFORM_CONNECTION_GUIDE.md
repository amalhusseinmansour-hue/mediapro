# 📱 دليل ربط منصات السوشيال ميديا (String-Style)

## 🎯 نظرة عامة

تم تطوير تطبيقك ليعمل بنفس طريقة **String** - اتصال مباشر مع منصات الإعلانات والسوشيال ميديا.

---

## 🔐 المنصات المدعومة

✅ **Meta (Facebook & Instagram)**
✅ **TikTok for Business**
✅ **Snapchat Marketing**
✅ **Google Ads**
✅ **Twitter/X**
✅ **LinkedIn**

---

## 📋 خطوات الإعداد

### 1️⃣ Meta (Facebook & Instagram)

#### التسجيل والحصول على API Keys:
1. اذهب إلى: https://developers.facebook.com
2. أنشئ تطبيق جديد (Create App)
3. اختر نوع التطبيق: **Business**
4. أضف منتجات:
   - **Facebook Login**
   - **Instagram Graph API**
   - **Marketing API**
5. احصل على:
   - App ID
   - App Secret
   - Access Token (طويل الأمد)

#### إعداد Webhook:
1. في لوحة التحكم → Products → Webhooks
2. أضف Callback URL: `https://mediaprosocial.io/api/webhooks/meta`
3. Verify Token: اختر كلمة سرية وضعها في `.env` كـ `META_WEBHOOK_VERIFY_TOKEN`
4. اشترك في Events:
   - `leadgen` (نماذج العملاء المحتملين)
   - `page` (أحداث الصفحة)
   - `instagram` (أحداث Instagram)

#### إضافة المتغيرات في `.env`:
```env
META_APP_ID=your_app_id_here
META_APP_SECRET=your_app_secret_here
META_WEBHOOK_VERIFY_TOKEN=your_secret_token
META_ACCESS_TOKEN=your_long_lived_token
```

---

### 2️⃣ TikTok for Business

#### التسجيل:
1. اذهب إلى: https://ads.tiktok.com
2. أنشئ Business Account
3. اذهب إلى: https://developers.tiktok.com
4. أنشئ App جديد
5. فعّل **TikTok for Business**

#### إعداد API:
```env
TIKTOK_APP_ID=your_tiktok_app_id
TIKTOK_APP_SECRET=your_tiktok_secret
```

#### Webhook:
```
https://mediaprosocial.io/api/webhooks/tiktok
```

---

### 3️⃣ Snapchat Marketing

#### التسجيل:
1. اذهب إلى: https://businesshelp.snapchat.com
2. أنشئ Snapchat Business Account
3. اذهب إلى: https://businesshelp.snapchat.com/s/article/api-apply
4. قدم طلب للحصول على Marketing API Access

#### API Keys:
```env
SNAPCHAT_CLIENT_ID=your_client_id
SNAPCHAT_CLIENT_SECRET=your_client_secret
```

---

### 4️⃣ Google Ads

#### التسجيل:
1. اذهب إلى: https://console.cloud.google.com
2. أنشئ مشروع جديد
3. فعّل Google Ads API
4. أنشئ OAuth 2.0 Credentials
5. أضف Redirect URI: `https://mediaprosocial.io/api/oauth/callback/google`

#### API Keys:
```env
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GOOGLE_REDIRECT_URI=https://mediaprosocial.io/api/oauth/callback/google
```

---

### 5️⃣ Twitter/X

#### التسجيل:
1. اذهب إلى: https://developer.twitter.com
2. أنشئ App جديد
3. احصل على API Keys & Tokens
4. فعّل OAuth 2.0

#### API Keys:
```env
TWITTER_CLIENT_ID=your_twitter_client_id
TWITTER_CLIENT_SECRET=your_twitter_client_secret
```

---

### 6️⃣ LinkedIn

#### التسجيل:
1. اذهب إلى: https://developer.linkedin.com
2. أنشئ App جديد
3. أضف Products:
   - **Sign In with LinkedIn**
   - **Marketing Developer Platform**
4. أضف Redirect URL: `https://mediaprosocial.io/api/oauth/callback/linkedin`

#### API Keys:
```env
LINKEDIN_CLIENT_ID=your_linkedin_client_id
LINKEDIN_CLIENT_SECRET=your_linkedin_client_secret
```

---

## 🔌 API Endpoints المتاحة

### ربط الحسابات:
```
POST /api/oauth/connect/facebook
POST /api/oauth/connect/instagram
POST /api/oauth/connect/tiktok
POST /api/oauth/connect/snapchat
POST /api/oauth/connect/google
POST /api/oauth/connect/twitter
POST /api/oauth/connect/linkedin
```

### استقبال البيانات (Webhooks):
```
POST /api/webhooks/meta
POST /api/webhooks/tiktok
POST /api/webhooks/snapchat
POST /api/webhooks/google
```

### إدارة الحسابات المربوطة:
```
GET  /api/connected-accounts
GET  /api/connected-accounts/status
DELETE /api/connected-accounts/{id}
```

### الحسابات الاجتماعية:
```
GET    /api/social-accounts
POST   /api/social-accounts
GET    /api/social-accounts/{id}
PUT    /api/social-accounts/{id}
DELETE /api/social-accounts/{id}
```

---

## 📊 جدول قاعدة البيانات

### `social_accounts` - الحسابات المربوطة
```sql
- id
- user_id
- platform (facebook, instagram, tiktok, etc)
- account_name
- account_id
- access_token (مشفر)
- refresh_token (مشفر)
- expires_at
- is_active
- created_at
- updated_at
```

### `platform_leads` - العملاء المحتملين
```sql
- id
- user_id
- social_account_id
- platform
- campaign_id
- ad_id
- ad_name
- lead_name
- lead_email
- lead_phone
- lead_data (JSON)
- source_url
- utm_* (tracking parameters)
- status (new, contacted, converted, rejected)
- notes
- contacted_at
- created_at
- updated_at
```

---

## 🎨 كيفية الاستخدام في Flutter

### 1. ربط حساب:
```dart
final response = await http.post(
  Uri.parse('https://mediaprosocial.io/api/oauth/connect/facebook'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
);
```

### 2. عرض الحسابات المربوطة:
```dart
final response = await http.get(
  Uri.parse('https://mediaprosocial.io/api/connected-accounts'),
  headers: {
    'Authorization': 'Bearer $token',
  },
);
```

### 3. فصل حساب:
```dart
final response = await http.delete(
  Uri.parse('https://mediaprosocial.io/api/connected-accounts/$id'),
  headers: {
    'Authorization': 'Bearer $token',
  },
);
```

---

## 🚀 الخطوات التالية

1. ✅ احصل على API Keys من كل منصة
2. ✅ أضف المتغيرات في ملف `.env`
3. ✅ اختبر ربط كل منصة
4. ✅ راقب Webhooks لاستقبال البيانات
5. ✅ طور واجهة المستخدم في Flutter

---

## 📞 الدعم

إذا واجهتك أي مشاكل:
1. تحقق من ملف `.env` - تأكد من صحة جميع API Keys
2. راجع logs في: `storage/logs/laravel.log`
3. تأكد من تفعيل Webhooks في لوحة تحكم كل منصة
4. تحقق من صلاحيات التطبيق (Permissions/Scopes)

---

## ⚡ ملاحظات مهمة

- **الأمان**: جميع tokens مشفرة في قاعدة البيانات
- **التحديث التلقائي**: النظام يحدث refresh tokens تلقائياً
- **Webhooks**: تأكد أن URL الخاص بك يدعم HTTPS
- **Rate Limits**: كل منصة لديها حدود للطلبات - راجع توثيق كل منصة

---

## 🎯 الفرق بين نظامك و String

| الميزة | String | نظامك |
|-------|--------|-------|
| الاتصال المباشر | ✅ | ✅ |
| Webhooks | ✅ | ✅ |
| تتبع المصدر | ✅ | ✅ |
| CRM مدمج | ✅ | ⏳ قيد التطوير |
| تحليلات متقدمة | ✅ | ⏳ قيد التطوير |

---

تم إنشاء هذا النظام بنفس معايير **String** للاتصال المباشر مع منصات السوشيال ميديا! 🚀
