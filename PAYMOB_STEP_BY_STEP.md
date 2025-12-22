# 📸 دليل مصور خطوة بخطوة - Paymob

## 🎯 الهدف: الحصول على API Key صحيح

---

## الخطوة 1: تسجيل الدخول

```
┌─────────────────────────────────────────┐
│  🌐 https://accept.paymob.com          │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  📧 Email: your@email.com         │ │
│  │  🔒 Password: ••••••••            │ │
│  │                                   │ │
│  │  [  تسجيل الدخول  ]              │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

**الرابط:** https://accept.paymob.com/portal2/en/login

---

## الخطوة 2: الذهاب لإعدادات الحساب

بعد تسجيل الدخول، ستجد القائمة الجانبية:

```
┌─ القائمة الرئيسية ────────────────┐
│                                    │
│  🏠 Dashboard                      │
│  💳 Transactions                   │
│  📊 Reports                        │
│  🔧 Settings  ← ⭐ اضغط هنا       │
│  └─ Account Info  ← ⭐ ثم هنا    │
│  └─ API Keys                       │
│  └─ Payment Integrations           │
└────────────────────────────────────┘
```

**المسار:** Settings → Account Info

---

## الخطوة 3: نسخ API Key

في صفحة Account Info، ستجد:

```
┌─ Account Information ──────────────────────────────┐
│                                                    │
│  👤 Profile Information                           │
│     Name: Your Business Name                      │
│     Email: your@email.com                         │
│                                                    │
│  🔑 API Credentials                               │
│  ┌────────────────────────────────────────────┐  │
│  │ API Key (Private) ⚠️ Keep Secret           │  │
│  │                                             │  │
│  │ ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklr │  │
│  │ cFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWV │  │
│  │ c0MElpd2ljSEp2Wm1sc1pWOXdheUk2TmpFME1q │  │
│  │ TXNJbTVoYldVaU9pSXhOell5TmpBM...        │  │
│  │                                             │  │
│  │  [📋 Copy]  [🔄 Regenerate]                │  │
│  └────────────────────────────────────────────┘  │
│                                                    │
│  🔓 Public Key (Client-side)                      │
│  ┌────────────────────────────────────────────┐  │
│  │ are_pk_live_SgS4VDIjkSDiJoPPrDx4Q3uQJj... │  │
│  │  [📋 Copy]                                  │  │
│  └────────────────────────────────────────────┘  │
│                                                    │
│  🔐 Secret Key (Server-side)                      │
│  ┌────────────────────────────────────────────┐  │
│  │ are_sk_live_9de41b699c84f1cdda784...      │  │
│  │  [📋 Copy]  [🔄 Regenerate]                │  │
│  └────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────┘
```

**⭐ المطلوب:** انسخ **فقط** المفتاح الأول (API Key)

**⚠️ تحذير:**
- لا تنسخ Public Key
- لا تنسخ Secret Key
- انسخ فقط **API Key**

---

## الخطوة 4: الحصول على Integration ID

اذهب إلى: Settings → Payment Integrations

```
┌─ Payment Integrations ─────────────────────────────┐
│                                                    │
│  💳 Active Integrations:                          │
│                                                    │
│  ┌────────────────────────────────────────────┐  │
│  │ 🏦 Online Card Payment (MIGS)              │  │
│  │                                             │  │
│  │ Integration ID: 81249  [📋 Copy]           │  │
│  │ Status: ✅ Active                           │  │
│  │ Type: Card Payment                          │  │
│  └────────────────────────────────────────────┘  │
│                                                    │
│  ┌────────────────────────────────────────────┐  │
│  │ 📱 Mobile Wallet                           │  │
│  │                                             │  │
│  │ Integration ID: 81250  [📋 Copy]           │  │
│  │ Status: ✅ Active                           │  │
│  │ Type: Mobile Payment                        │  │
│  └────────────────────────────────────────────┘  │
│                                                    │
│  ┌────────────────────────────────────────────┐  │
│  │ 🏪 Kiosk (Fawry)                           │  │
│  │                                             │  │
│  │ Integration ID: 81251  [📋 Copy]           │  │
│  │ Status: ⏸️ Pending Approval                 │  │
│  └────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────┘
```

**⭐ المطلوب:** انسخ Integration ID للطريقة التي تريدها
- للبطاقات: عادة `Online Card` أو `MIGS`
- رقم مثل: `81249`

---

## الخطوة 5: تحديث التطبيق

### 5.1 افتح ملف الإعدادات

```
📁 social_media_manager/
  └── 📁 lib/
      └── 📁 core/
          └── 📁 config/
              └── 📄 api_config.dart  ← افتح هذا الملف
```

### 5.2 ابحث عن السطر 94

```dart
// السطر 91-95 تقريباً
static const String paymobApiKey = String.fromEnvironment(
  'PAYMOB_API_KEY',
  defaultValue: 'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJ...', // ← استبدل هذا
);
```

### 5.3 استبدل المفتاح

```dart
// قبل:
defaultValue: 'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5...',

// بعد:
defaultValue: 'YOUR_NEW_API_KEY_FROM_PAYMOB_DASHBOARD',
```

### 5.4 حدّث Integration ID (اختياري)

```dart
// السطر 121-124 تقريباً
static const String paymobIntegrationId = String.fromEnvironment(
  'PAYMOB_INTEGRATION_ID',
  defaultValue: '81249', // ← ضع رقمك هنا
);
```

### 5.5 احفظ الملف

اضغط `Ctrl + S` أو `File → Save`

---

## الخطوة 6: إعادة البناء

افتح Terminal وشغّل:

```bash
# 1. نظّف Build القديم
flutter clean

# 2. احصل على الحزم
flutter pub get

# 3. شغّل التطبيق
flutter run
```

---

## الخطوة 7: اختبر!

```
┌─ التطبيق ─────────────────────────┐
│                                    │
│  1️⃣ افتح الاشتراكات              │
│  2️⃣ اختر "باقة الأفراد"           │
│  3️⃣ اضغط "اشترك الآن"             │
│                                    │
│  النتيجة المتوقعة:                │
│  ✅ تفتح صفحة الدفع بنجاح         │
│  ✅ يمكنك إدخال بيانات البطاقة    │
│                                    │
└────────────────────────────────────┘
```

---

## 🧪 اختبار سريع (قبل التحديث)

لاختبار المفتاح قبل تحديث التطبيق:

### Windows (PowerShell):

```powershell
.\Test-PaymobKey.ps1 -ApiKey "YOUR_NEW_API_KEY"
```

### Linux/Mac:

```bash
bash test_paymob_quick.sh YOUR_NEW_API_KEY
```

### النتيجة المتوقعة:

```
✅ SUCCESS! API Key is valid
🎉 You can now use Paymob payment
🎫 Token: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1...
```

---

## ❌ إذا فشل الاختبار:

```
❌ FAILED: Incorrect API Key

💡 Solutions:
   1. تأكد أنك نسخت API Key (وليس Public Key)
   2. تأكد أنك في Live Mode (وليس Test Mode)
   3. جرّب الضغط على "Regenerate" للحصول على مفتاح جديد
   4. تأكد من عدم وجود مسافات في بداية أو نهاية المفتاح
```

---

## 📊 مقارنة المفاتيح

| الاسم | الشكل | الاستخدام | هل مطلوب؟ |
|-------|-------|-----------|------------|
| **API Key** | `ZXlKaGJHY2lP...` (طويل جداً ~200 حرف) | المصادقة | ✅ **نعم** |
| **Public Key** | `are_pk_live_...` (متوسط ~40 حرف) | للعميل | ⚠️ اختياري |
| **Secret Key** | `are_sk_live_...` (متوسط ~64 حرف) | للخادم | ⚠️ اختياري |
| **Integration ID** | `81249` (رقم قصير 5-6 أرقام) | طريقة الدفع | ✅ **نعم** |

---

## 🎉 تم!

بعد اتباع هذه الخطوات، يجب أن يعمل الدفع بنجاح!

إذا استمرت المشكلة، راجع الملف الكامل: `PAYMOB_FIX_GUIDE_AR.md`

---

**تم إعداد هذا الدليل في:** 19 نوفمبر 2025
