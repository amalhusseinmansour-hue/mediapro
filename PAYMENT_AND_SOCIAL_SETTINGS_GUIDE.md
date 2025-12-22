# 💳 دليل إعدادات الدفع وربط حسابات السوشال ميديا

## 📌 نظرة عامة

تم إضافة صفحتين جديدتين إلى لوحة التحكم:

1. **💳 إعدادات الدفع (Payment Settings)** - لإدارة بوابات الدفع
2. **📱 حسابات السوشال ميديا (Social Media Accounts)** - لربط حسابات منصات التواصل

---

## 💳 صفحة إعدادات الدفع

### 📍 الوصول
```
https://mediaprosocial.io/admin/payment-settings
```

أو من القائمة الجانبية:
```
Settings -> إعدادات الدفع
```

---

### 🎯 التبويبات المتاحة

#### 1️⃣ تبويب Stripe

**الإعدادات الأساسية:**
- ✅ **تفعيل Stripe** - تشغيل/إيقاف بوابة الدفع
- 🔑 **Public Key** - مفتاح API العام
- 🔒 **Secret Key** - مفتاح API السري
- 🔗 **Webhook Secret** - للتحقق من إشعارات Stripe

**إعدادات متقدمة:**
- 💵 **العملة** - اختر العملة (AED, USD, EUR, GBP, SAR)
- 🍎 **Apple Pay** - تفعيل الدفع عبر Apple Pay
- 📱 **Google Pay** - تفعيل الدفع عبر Google Pay
- 💳 **حفظ البطاقات** - السماح بحفظ بيانات البطاقات
- 🧪 **Test Mode** - وضع الاختبار

**كيفية الحصول على المفاتيح:**
```
1. اذهب إلى https://dashboard.stripe.com
2. سجل حساب أو سجل دخول
3. من Dashboard → Developers → API Keys
4. انسخ Publishable Key و Secret Key
5. من Webhooks → أضف endpoint جديد
6. انسخ Webhook Signing Secret
```

---

#### 2️⃣ تبويب Paymob

**الإعدادات الأساسية:**
- ✅ **تفعيل Paymob**
- 🔑 **API Key**
- 🆔 **Integration ID**
- 🖼️ **iFrame ID**
- 🔒 **HMAC Secret**

**إعدادات متقدمة:**
- 💵 **العملة** - EGP, AED, USD, SAR
- 💳 **طرق الدفع:**
  - البطاقات (Cards)
  - المحافظ الإلكترونية (Wallets)
  - التقسيط (Installments)

**كيفية الحصول على المفاتيح:**
```
1. اذهب إلى https://accept.paymob.com
2. سجل حساب تاجر
3. من Dashboard → Settings
4. انسخ API Key
5. من Integration → انسخ Integration ID و iFrame ID
6. HMAC Secret موجود في Settings
```

---

#### 3️⃣ تبويب PayPal

**الإعدادات الأساسية:**
- ✅ **تفعيل PayPal**
- 🔑 **Client ID**
- 🔒 **Client Secret**
- 🔗 **Webhook ID**

**إعدادات متقدمة:**
- 🌍 **الوضع:**
  - Sandbox (اختبار)
  - Live (حقيقي)
- 💵 **العملة**
- ✅ **تفعيل Venmo**
- 💳 **تفعيل PayPal Credit**
- 🏷️ **Brand Name** - اسم العلامة التجارية

**كيفية الحصول على المفاتيح:**
```
1. اذهب إلى https://developer.paypal.com
2. سجل دخول أو أنشئ حساب
3. من Dashboard → My Apps & Credentials
4. أنشئ تطبيق جديد (Create App)
5. انسخ Client ID و Secret
6. من Webhooks → أضف webhook جديد
```

---

#### 4️⃣ إعدادات عامة (General Settings)

**إعدادات أساسية:**
- 🎯 **البوابة الافتراضية:**
  - Stripe
  - Paymob
  - PayPal

**حدود الدفع:**
- 💰 **الحد الأدنى للدفع** - مثال: 10 AED
- 📊 **نسبة رسوم المعالجة** - مثال: 2.9%
- 💵 **رسوم ثابتة** - مثال: 1 AED

**سياسات الاسترجاع:**
- ✅ **تفعيل الاسترجاع**
- ⏱️ **مدة الاسترجاع** - من 1 إلى 90 يوم
- 💸 **رسوم الاسترجاع** - مثال: 5 AED

**الأمان:**
- 🔐 **3D Secure** - تفعيل إلزامي
- 🛡️ **كشف الاحتيال** - Fraud Detection
- ✉️ **رسائل تأكيد الدفع** - إرسال إيميلات تلقائية

**الإشعارات:**
- 📧 **Email للدفعات الناجحة**
- 📧 **Email للدفعات الفاشلة**
- 📧 **Email للاسترجاع**

---

## 📱 صفحة حسابات السوشال ميديا

### 📍 الوصول
```
https://mediaprosocial.io/admin/social-media-accounts
```

أو من القائمة الجانبية:
```
Settings -> حسابات السوشال ميديا
```

---

### 🎯 المنصات المتاحة

#### 1️⃣ Facebook

**المعلومات المطلوبة:**
- ✅ تفعيل Facebook
- 🆔 Facebook App ID
- 🔒 Facebook App Secret
- 🔑 Facebook Access Token
- 📄 Facebook Page ID

**خطوات الربط:**
```
1. اذهب إلى https://developers.facebook.com
2. أنشئ تطبيق جديد (Create App)
3. اختر نوع التطبيق: Business
4. املأ معلومات التطبيق
5. من Settings → Basic:
   - انسخ App ID
   - انسخ App Secret
6. من Tools → Graph API Explorer:
   - اختر التطبيق
   - اطلب Token
   - انسخ Access Token
7. من Page Settings:
   - انسخ Page ID
```

---

#### 2️⃣ Instagram

**المعلومات المطلوبة:**
- ✅ تفعيل Instagram
- 🆔 Instagram App ID
- 🔒 Instagram App Secret
- 🔑 Instagram Access Token
- 👤 Instagram User ID

**ملاحظة مهمة:**
⚠️ يتطلب Instagram حساب **Business** أو **Creator** متصل بصفحة Facebook

**خطوات الربط:**
```
1. حوّل حسابك إلى Business Account
2. اربط الحساب بصفحة Facebook
3. استخدم نفس App ID و Secret من Facebook
4. استخدم Facebook Login للحصول على Access Token
5. انسخ Instagram User ID من Instagram Insights
```

---

#### 3️⃣ Twitter / X

**المعلومات المطلوبة:**
- ✅ تفعيل Twitter/X
- 🔑 API Key
- 🔒 API Secret
- 🎫 Access Token
- 🔐 Access Token Secret
- 🎟️ Bearer Token

**خطوات الربط:**
```
1. اذهب إلى https://developer.twitter.com
2. قدم طلب Developer Account
3. أنشئ مشروع (Project) وتطبيق (App)
4. من Keys and Tokens:
   - انسخ API Key و API Secret
   - ولّد Access Token و Secret
   - ولّد Bearer Token
5. فعّل OAuth 1.0a و OAuth 2.0
```

---

#### 4️⃣ LinkedIn

**المعلومات المطلوبة:**
- ✅ تفعيل LinkedIn
- 🆔 Client ID
- 🔒 Client Secret
- 🔑 Access Token
- 🏢 Organization ID

**خطوات الربط:**
```
1. اذهب إلى https://www.linkedin.com/developers
2. أنشئ تطبيق (Create App)
3. املأ معلومات التطبيق
4. من Auth → OAuth 2.0 Settings:
   - انسخ Client ID و Secret
   - أضف Redirect URLs
5. من Products:
   - اطلب Sign In with LinkedIn
   - اطلب Share on LinkedIn
6. استخدم OAuth للحصول على Access Token
7. انسخ Organization ID من صفحة الشركة
```

---

#### 5️⃣ TikTok

**المعلومات المطلوبة:**
- ✅ تفعيل TikTok
- 🔑 Client Key
- 🔒 Client Secret
- 🎫 Access Token

**خطوات الربط:**
```
1. اذهب إلى https://developers.tiktok.com
2. سجل حساب مطور
3. أنشئ تطبيق جديد
4. من Settings:
   - انسخ Client Key و Client Secret
5. استخدم TikTok Login Kit للحصول على Access Token
```

---

#### 6️⃣ YouTube

**المعلومات المطلوبة:**
- ✅ تفعيل YouTube
- 🆔 Client ID
- 🔒 Client Secret
- 🔑 Access Token
- 🔄 Refresh Token
- 📺 Channel ID

**خطوات الربط:**
```
1. اذهب إلى https://console.cloud.google.com
2. أنشئ مشروع جديد
3. فعّل YouTube Data API v3:
   - من Library
   - ابحث عن YouTube Data API v3
   - اضغط Enable
4. أنشئ OAuth 2.0 Client ID:
   - من Credentials → Create Credentials
   - اختر OAuth Client ID
   - اختر Web Application
   - أضف Authorized Redirect URIs
5. انسخ Client ID و Client Secret
6. استخدم OAuth Playground للحصول على Tokens:
   - https://developers.google.com/oauthplayground
   - اختر YouTube Data API v3
   - Authorize APIs
   - انسخ Access Token و Refresh Token
7. Channel ID من YouTube Studio → Settings
```

---

#### 7️⃣ Pinterest

**المعلومات المطلوبة:**
- ✅ تفعيل Pinterest
- 🆔 App ID
- 🔒 App Secret
- 🔑 Access Token

**خطوات الربط:**
```
1. اذهب إلى https://developers.pinterest.com
2. أنشئ تطبيق (Create App)
3. من Settings:
   - انسخ App ID و App Secret
4. من OAuth:
   - أضف Redirect URI
   - اطلب الأذونات المطلوبة
5. استخدم OAuth للحصول على Access Token
```

---

#### 8️⃣ Telegram

**المعلومات المطلوبة:**
- ✅ تفعيل Telegram
- 🤖 Bot Token
- 💬 Chat ID / Channel ID

**خطوات الربط:**
```
1. افتح Telegram
2. ابحث عن @BotFather
3. أرسل /newbot
4. اتبع التعليمات:
   - اختر اسم البوت
   - اختر username للبوت
5. انسخ Bot Token
6. أضف البوت إلى قناتك:
   - افتح القناة
   - Add Members → أضف البوت
   - امنح البوت صلاحيات Admin
7. للحصول على Chat ID:
   - أرسل رسالة في القناة
   - اذهب إلى: https://api.telegram.org/bot<TOKEN>/getUpdates
   - انسخ Chat ID من الـ response
```

---

## 🔒 الأمان والخصوصية

### ⚠️ تنبيهات مهمة:

1. **لا تشارك المفاتيح السرية مع أحد**
   - API Keys
   - Secrets
   - Tokens

2. **استخدم HTTPS دائماً**
   - جميع الاتصالات مشفرة

3. **قم بتحديث المفاتيح دورياً**
   - كل 3-6 أشهر

4. **فعّل Two-Factor Authentication**
   - على جميع الحسابات

5. **راقب نشاط API**
   - تحقق من Logs بانتظام

---

## 📊 الإعدادات في قاعدة البيانات

جميع الإعدادات تُحفظ في جدول `settings`:

```sql
-- Payment Settings
stripe_enabled, stripe_public_key, stripe_secret_key
paymob_enabled, paymob_api_key, paymob_integration_id
paypal_enabled, paypal_client_id, paypal_client_secret

-- Social Media Settings
facebook_enabled, facebook_app_id, facebook_access_token
instagram_enabled, instagram_app_id, instagram_access_token
twitter_enabled, twitter_api_key, twitter_access_token
linkedin_enabled, linkedin_client_id, linkedin_access_token
tiktok_enabled, tiktok_client_key, tiktok_access_token
youtube_enabled, youtube_client_id, youtube_access_token
pinterest_enabled, pinterest_app_id, pinterest_access_token
telegram_enabled, telegram_bot_token, telegram_chat_id
```

**ملاحظة:** جميع هذه الإعدادات `is_public = false` (خاصة وآمنة)

---

## 🧪 اختبار الإعدادات

### اختبار إعدادات الدفع:

```bash
# 1. تفعيل Stripe Test Mode
# 2. استخدم Test Cards:
#    - Visa: 4242 4242 4242 4242
#    - Mastercard: 5555 5555 5555 4444
# 3. CVV: أي 3 أرقام
# 4. Expiry: أي تاريخ مستقبلي

# 5. اختبر API:
curl -X POST https://mediaprosocial.io/api/payments/test \
  -H "Content-Type: application/json" \
  -d '{"amount": 100, "currency": "AED"}'
```

### اختبار ربط السوشال ميديا:

```bash
# 1. احفظ الإعدادات في لوحة التحكم
# 2. اختبر الاتصال:

# Facebook
curl https://graph.facebook.com/me?access_token=YOUR_TOKEN

# Instagram
curl https://graph.instagram.com/me?fields=id,username&access_token=YOUR_TOKEN

# Twitter
curl https://api.twitter.com/2/users/me \
  -H "Authorization: Bearer YOUR_BEARER_TOKEN"

# Telegram
curl https://api.telegram.org/botYOUR_TOKEN/getMe
```

---

## 📈 الاستخدام

### من تطبيق الموبايل:

التطبيق يجلب الإعدادات تلقائياً عند:
- فتح التطبيق
- محاولة الدفع
- محاولة النشر على السوشال ميديا

### من Backend:

```php
use App\Models\Setting;

// جلب إعدادات الدفع
$stripeEnabled = Setting::getValue('stripe_enabled');
$stripeKey = Setting::getValue('stripe_public_key');

// جلب إعدادات السوشال ميديا
$facebookToken = Setting::getValue('facebook_access_token');
$twitterKey = Setting::getValue('twitter_api_key');
```

---

## 🆘 المشاكل الشائعة

### المشكلة: مفتاح API لا يعمل

**الحل:**
1. تأكد من نسخ المفتاح بالكامل
2. تحقق من عدم وجود مسافات إضافية
3. تأكد من صلاحية المفتاح
4. راجع Logs في منصة API

---

### المشكلة: Access Token منتهي

**الحل:**
1. ولّد Token جديد
2. احفظه في الإعدادات
3. استخدم Refresh Token إن وُجد

---

### المشكلة: الدفع لا يعمل

**الحل:**
1. تأكد من تفعيل البوابة
2. تحقق من صحة المفاتيح
3. تأكد من Test Mode في البداية
4. راجع Webhooks في Dashboard

---

### المشكلة: لا يمكن النشر على السوشال ميديا

**الحل:**
1. تأكد من تفعيل المنصة
2. تحقق من صلاحية Access Token
3. تأكد من الأذونات (Permissions)
4. راجع API Limits و Rate Limits

---

## 🎯 Best Practices

### ✅ افعل:

1. **ابدأ بـ Test Mode**
   - اختبر كل شيء قبل Live

2. **احفظ نسخة احتياطية من المفاتيح**
   - في مكان آمن

3. **راقب المعاملات**
   - تحقق من Logs يومياً

4. **حدّث Tokens دورياً**
   - قبل انتهاء صلاحيتها

5. **فعّل Webhooks**
   - لتلقي التحديثات الفورية

### ❌ لا تفعل:

1. **لا تشارك المفاتيح في GitHub**
   - استخدم .env

2. **لا تستخدم Live Keys في التطوير**
   - Test Mode فقط

3. **لا تنسى تحديث الإعدادات**
   - عند تغيير الحسابات

4. **لا تفعّل جميع البوابات مرة واحدة**
   - واحدة تلو الأخرى

---

## 📚 الخلاصة

تم إضافة نظام شامل لإدارة:

✅ **إعدادات الدفع:**
- Stripe
- Paymob
- PayPal
- إعدادات عامة شاملة

✅ **ربط حسابات السوشال ميديا:**
- Facebook
- Instagram
- Twitter/X
- LinkedIn
- TikTok
- YouTube
- Pinterest
- Telegram

✅ **الميزات:**
- واجهة سهلة ومنظمة
- تبويبات واضحة
- إرشادات مدمجة
- حفظ آمن في قاعدة البيانات
- تطبيق فوري على التطبيق

---

## 🔗 الروابط السريعة

**صفحات لوحة التحكم:**
- إعدادات الدفع: `https://mediaprosocial.io/admin/payment-settings`
- حسابات السوشال ميديا: `https://mediaprosocial.io/admin/social-media-accounts`
- إعدادات التطبيق: `https://mediaprosocial.io/admin/manage-app-settings`

**مستندات مساعدة:**
- `ADMIN_SETTINGS_PAGE_GUIDE.md` - دليل إعدادات التطبيق
- `HOW_SETTINGS_WORK.md` - كيف تعمل الإعدادات
- `TEST_SETTINGS_FLOW.md` - دليل الاختبار

---

**تم التحديث:** نوفمبر 2024
**الإصدار:** 1.0.0
