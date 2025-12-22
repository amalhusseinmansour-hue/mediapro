# حل مشكلة المصادقة مع Paymob - شاشة الاشتراكات

## المشكلة
عند محاولة الاشتراك في شاشة الاشتراكات، يحدث خطأ في المصادقة مع Paymob:
```
❌ Paymob Auth Error: 403
❌ Response: {"error": "incorrect credentials"}
```

## السبب الجذري
مفتاح Paymob API المستخدم في الملف `lib/core/config/api_config.dart` غير صحيح أو منتهي الصلاحية.

## الأعراض
1. عند الضغط على "اشترك" في أي خطة
2. عند محاولة الدفع عبر Paymob
3. رسالة خطأ: "فشل في تجهيز الدفع"

## حلول التصحيح

### الحل 1: تحديث مفتاح Paymob API (الأفضل)

الخطوات:
1. اذهب إلى https://accept.paymob.com/portal2/en/login
2. سجل الدخول بحسابك
3. اذهب إلى Settings → API Keys
4. انسخ API Key الصحيح
5. ضعه في المكان المناسب

**في الملف الحالي:**
- المفتاح المستخدم مشفر (Base64)
- يحتاج إلى تحديث

### الحل 2: استخدام البيئة التطريبية الحالية

الملف يدعم بالفعل الوضع التجريبي:
```dart
static const bool enableTestMode = String.fromEnvironment(
  'PAYMOB_TEST_MODE',
  defaultValue: 'false',
);
```

عند تفعيل `enableTestMode = true`:
- لا يحتاج إلى مفتاح Paymob صحيح
- يعرض محاكاة للعملية
- يخزن بيانات الدفع محلياً فقط

### الحل 3: التحقق من معلومات الحساب

في Paymob:
1. تحقق من أن الحساب مفعّل بالكامل
2. تأكد من استخدام Live Mode وليس Test Mode
3. تحقق من صلاحيات الـ API Key
4. جرب "Regenerate" لإنشاء مفتاح جديد

## المفاتيح الحالية المستخدمة

**File:** `lib/core/config/api_config.dart`

### مفاتيح Paymob:

```dart
// API Key (مشفر)
static const String paymobApiKey = String.fromEnvironment(
  'PAYMOB_API_KEY',
  defaultValue: 'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TmpFME1qTXNJbTVoYldVaU9pSnBibWwwYVdGc0luMC5SWE9vTEk4S0FXZnlKVmdQeVZnZDZkTVRGLUZEMktaM09HVS1RbmVnNmlrOFJsbUJ0V2VGQ1BIZ3FDUXdRMklwaTAtTDFsMlA0QXU3MDJDMU9LbWJ5dw==',
);

// Public Key
static const String paymobPublicKey = String.fromEnvironment(
  'PAYMOB_PUBLIC_KEY',
  defaultValue: 'are_pk_live_SgS4VDIjkSDiJoPPrDx4Q3uQJjKgr37n',
);

// Integration ID
static const String paymobIntegrationId = String.fromEnvironment(
  'PAYMOB_INTEGRATION_ID',
  defaultValue: '81249', // MIGS-online
);
```

## مكان المشكلة في الكود

**File:** `lib/services/paymob_service.dart` - دالة `getAuthToken()`

```dart
Future<String?> getAuthToken() async {
  try {
    final apiKey = ApiConfig.paymobApiKey;  // ← يستخدم المفتاح من api_config
    
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/tokens'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'api_key': apiKey}),
    );

    if (response.statusCode == 201) {
      // ✅ نجح
      return data['token'];
    } else if (response.statusCode == 403) {
      // ❌ فشل المصادقة - المفتاح غير صحيح
      print('❌ Paymob Auth Error: 403');
      return null;
    }
  }
}
```

## خطوات الإصلاح الموصى بها

### 1. تحديث مفتاح API في Paymob

```bash
# الخطوات:
1. اذهب إلى https://accept.paymob.com/portal2/en/settings
2. ابحث عن "API Keys" أو "Account Settings"
3. انسخ API Key
4. إذا كان لا يعمل، اضغط "Regenerate"
5. انسخ المفتاح الجديد
```

### 2. تحديث المفتاح في التطبيق

**Option A: تحديث مباشر في الكود (ليس آمن)**

```dart
// لا ننصح به - سيظهر المفتاح في الـ Git history
static const String paymobApiKey = 'YOUR_NEW_API_KEY';
```

**Option B: استخدام متغيرات البيئة (الأفضل)**

```bash
# في ملف .env أو build configuration:
PAYMOB_API_KEY=YOUR_NEW_API_KEY
```

ثم في الكود:
```dart
static const String paymobApiKey = String.fromEnvironment(
  'PAYMOB_API_KEY',
  defaultValue: 'fallback_key',
);
```

### 3. اختبار الاتصال

بعد التحديث، جرّب:

```dart
// في ملف test أو كمثال:
void testPaymobConnection() async {
  final paymobService = PaymobService();
  final token = await paymobService.getAuthToken();
  
  if (token != null) {
    print('✅ Paymob authentication successful');
  } else {
    print('❌ Paymob authentication failed');
  }
}
```

## تفعيل الوضع التجريبي (للاختبار السريع)

إذا كنت تريد اختبار الوضع التجريبي بدون مفتاح Paymob صحيح:

**في `lib/core/config/api_config.dart`:**

```dart
static const bool enableTestMode = String.fromEnvironment(
  'PAYMOB_TEST_MODE',
  defaultValue: 'true',  // ← غيّر إلى true
);
```

عند التفعيل:
- التطبيق سيحاكي عمليات الدفع محلياً
- لا يرسل طلبات حقيقية إلى Paymob
- مناسب للاختبار والتطوير

## معلومات مفيدة عن Paymob

### API Key vs غيره:
- **API Key** (مطلوب): للمصادقة مع الخدمات الخلفية
- **Public Key**: للعمليات من جانب العميل
- **Secret Key**: للعمليات الحساسة على السيرفر
- **HMAC Secret**: للتحقق من Callbacks

### التكامل الحالي:
- **Integration ID**: 81249 (MIGS-online لبطاقات الائتمان)
- **Iframe ID**: 81249 (صفحة دفع Paymob)
- **العملة**: AED (درهم إماراتي)

## خطوات التشخيص

1. **تحقق من الطباعة في Console:**
```
🔑 Attempting Paymob authentication...
📤 Request URL: https://accept.paymob.com/api/auth/tokens
📥 Response status: 403  ← هنا المشكلة
```

2. **تحقق من صحة المفتاح:**
```dart
final isValid = ApiConfig.isValidApiKey(ApiConfig.paymobApiKey);
print(isValid); // يجب أن يطبع true
```

3. **قارن مع المفتاح الجديد:**
```
المفتاح الحالي: ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5...
المفتاح الجديد: [من لوحة تحكم Paymob]
```

## الملفات المتعلقة

- `lib/core/config/api_config.dart` - تكوين API مفاتيح
- `lib/services/paymob_service.dart` - خدمة الدفع
- `lib/screens/subscription/subscription_screen.dart` - شاشة الاشتراكات
- `lib/core/config/paymob_config.dart` - إعدادات Paymob الإضافية

## الخطوات التالية

1. ✅ تحديد نوع الخطأ (تم - مشكلة مصادقة API)
2. ⏳ الحصول على مفتاح API صحيح من Paymob
3. ⏳ تحديث المفتاح في التطبيق
4. ⏳ اختبار عملية الاشتراك
5. ⏳ التحقق من إكمال الدفع بنجاح

## دعم إضافي

للحصول على مفاتيح Paymob:
- **الموقع**: https://accept.paymob.com
- **لوحة التحكم**: https://accept.paymob.com/portal2
- **الدعم**: support@paymob.com

