# 📝 نماذج الأكواد الجاهزة للنسخ واللصق

> نسخ المفتاح الصحيح مباشرة - دون الحاجة للتعديل اليدوي

---

## 1️⃣ النموذج الأساسي

قم بنسخ هذا الكود واستبدله في `lib/core/config/api_config.dart` (السطر ~96):

```dart
/// 🔑 Paymob API Key - للمصادقة
static const String paymobApiKey = String.fromEnvironment(
  'PAYMOB_API_KEY',
  defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  // استبدل القيمة أعلاه بالمفتاح من Paymob
);
```

---

## 2️⃣ خطوات النسخ واللصق

### أولاً: انسخ المفتاح من Paymob

```
1. اذهب إلى:
   https://accept.paymob.com/portal2/en/profile/api-keys

2. ابحث عن "API Key"

3. اضغط Copy أو اختره واضغط Ctrl+C

4. سيبدو شيء مثل:
   eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2FjY2VwdC5wYXltb2IuY29tIiwiYWNjb3VudElkIjoiMTIzNDU2Nzg5MCIsImlhdCI6MTU2MzQ1Njc4OSwibmJmIjoxNTYzNDU2Nzg5LCJleHAiOjE1NjM0NTgwMDB9.RXOoLI8KAWfyJVgPyVgd6dMTF-FD2KZ3OGU-Qneg6ik8RllmBtWeFC...
```

### ثانياً: عدّل الملف

```dart
// قبل (خاطئ):
static const String paymobApiKey = String.fromEnvironment(
  'PAYMOB_API_KEY',
  defaultValue: 'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5...',
);

// بعد (صحيح):
static const String paymobApiKey = String.fromEnvironment(
  'PAYMOB_API_KEY',
  defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2FjY2VwdC5wYXltb2IuY29tIiwiYWNjb3VudElkIjoiMTIzNDU2Nzg5MCIsImlhdCI6MTU2MzQ1Njc4OSwibmJmIjoxNTYzNDU2Nzg5LCJleHAiOjE1NjM0NTgwMDB9.RXOoLI8KAWfyJVgPyVgd6dMTF-FD2KZ3OGU-Qneg6ik8RllmBtWeFC...',
);
```

---

## 3️⃣ طرق بديلة للتعديل

### الطريقة 1: البحث والاستبدال (Find & Replace)

```
في VS Code:
1. اضغط Ctrl+H (Find & Replace)
2. في "Find": defaultValue: 'ZXlKaGJHY2
3. في "Replace": defaultValue: 'eyJhbGciOiJIUzI1Ni
4. اضغط Replace All
```

### الطريقة 2: التعديل المباشر

```
الملف: lib/core/config/api_config.dart
السطر: ~96

افتح → اختر السطر بكامله → احذف → ألصق الكود الجديد
```

### الطريقة 3: استخدام Terminal

```bash
# ملف مساعد للتعديل السريع
# (يعتمد على البيئة)

# إذا كنت على Linux/Mac:
sed -i "s/defaultValue: '.*'/defaultValue: 'YOUR_KEY_HERE'/g" lib/core/config/api_config.dart

# إذا كنت على Windows PowerShell:
(Get-Content lib/core/config/api_config.dart) -replace "defaultValue: '.*'", "defaultValue: 'YOUR_KEY_HERE'" | Set-Content lib/core/config/api_config.dart
```

---

## 4️⃣ نموذج كامل للملف

إذا أردت استبدال الملف كاملاً، إليك النموذج:

```dart
part of 'api_config.dart';

// الجزء المتعلق بـ Paymob فقط:

class ApiConfig {
  // ... الأكواد الأخرى ...

  /// 🔐 Paymob Credentials
  
  /// Paymob API Key - للمصادقة مع النظام
  /// احصل عليه من: https://accept.paymob.com/portal2/en/profile/api-keys
  /// خطوات الحصول:
  /// 1. تسجيل الدخول إلى https://accept.paymob.com/portal2
  /// 2. الذهاب إلى Settings → API Keys
  /// 3. نسخ API Key (وليس Public أو Secret Key)
  /// 4. إذا كان قديماً، اضغط "Regenerate"
  static const String paymobApiKey = String.fromEnvironment(
    'PAYMOB_API_KEY',
    defaultValue: 'YOUR_PAYMOB_API_KEY_HERE',  // ← استبدل بالمفتاح الصحيح
  );

  /// Paymob Public Key - للعميل
  static const String paymobPublicKey = String.fromEnvironment(
    'PAYMOB_PUBLIC_KEY',
    defaultValue: 'are_pk_live_SgS4VDIjkSDiJoPPrDx4Q3uQJjKgr37n',
  );

  /// Paymob Secret Key - للخدمات الخلفية
  static const String paymobSecretKey = String.fromEnvironment(
    'PAYMOB_SECRET_KEY',
    defaultValue: 'are_sk_live_9de41b699c84f1cdda78478ac87ce590916495a6f563df9a17692e33fd9023c5',
  );

  /// معرّف التكامل الأساسي
  static const int paymobIntegrationId = 81249;

  /// معرّف iframe الدفع
  static const String paymobIframeId = '96854';

  /// معرّف iframe الفوري
  static const String paymobIframeIdFawry = '96853';

  // ... الأكواد الأخرى ...

  /// تفعيل الوضع التجريبي للمصادقة
  static const bool enableTestMode = false;  // set to true for test mode

  /// التحقق من صحة مفتاح Paymob
  static bool isValidApiKey(String key) {
    return key.isNotEmpty && 
           key.length > 50 &&
           !key.contains('PASTE_YOUR') &&
           !key.contains('YOUR_API_KEY') &&
           !key.contains('YOUR_PAYMOB');
  }

  /// التحقق من توفر خدمة معينة
  static bool isServiceAvailable(String service) {
    if (service == 'paymob') {
      return isValidApiKey(paymobApiKey);
    }
    return false;
  }

  // ... باقي الأكواد ...
}
```

---

## 5️⃣ اختبار التغييرات

بعد الحفظ، تحقق من أن كل شيء يعمل:

```dart
// أضف هذا في main.dart للاختبار السريع:
import 'package:social_media_manager/core/config/api_config.dart';

void main() {
  // اختبر المفتاح قبل التشغيل
  final isValid = ApiConfig.isValidApiKey(ApiConfig.paymobApiKey);
  print('API Key is valid: $isValid');
  print('API Key length: ${ApiConfig.paymobApiKey.length}');
  
  if (!isValid) {
    print('⚠️ WARNING: Paymob API Key is not valid!');
    print('Please update it in lib/core/config/api_config.dart');
  } else {
    print('✅ API Key looks good!');
  }
  
  runApp(const MyApp());
}
```

---

## 6️⃣ قائمة التحقق

- [ ] نسخت المفتاح من Paymob بشكل صحيح
- [ ] أنت في الموقع الصحيح (live.paymob.com وليس test)
- [ ] المفتاح يبدأ بـ `eyJ` (علامة JWT)
- [ ] طول المفتاح أكثر من 50 حرف
- [ ] لا توجد مسافات إضافية قبل أو بعد المفتاح
- [ ] الملف تم حفظه (Ctrl+S)
- [ ] أعدت تشغيل التطبيق (flutter clean && flutter run)

---

## 7️⃣ أمثلة على أخطاء شائعة

### ❌ خطأ: مسافات إضافية
```dart
// خطأ:
defaultValue: ' eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... ',
                 ↑                                    ↑
            مسافة في البداية                  مسافة في النهاية

// صحيح:
defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
```

### ❌ خطأ: المفتاح مقطوع
```dart
// خطأ:
defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
                // المفتاح ناقص بقية الأحرف

// صحيح:
defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2FjY2VwdC5wYXltb2IuY29tIi...',
```

### ❌ خطأ: علامات الاقتباس
```dart
// خطأ:
defaultValue: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
              ↑                                       ↑
            علامات مزدوجة

// صحيح:
defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
              ↑                                       ↑
            علامات مفردة (أحادية)
```

---

## 8️⃣ الدعم والمساعدة

إذا واجهت مشكلة:

1. تحقق من أن المفتاح صحيح من Paymob
2. جرب `flutter clean && flutter run`
3. اقرأ الملف الكامل: `PAYMOB_COMPLETE_SOLUTION_2025.md`
4. شغّل التشخيص: `runPaymobDiagnostics()`

---

**ملاحظة مهمة:** ✨

الأكواد أعلاه هي أمثلة عامة. المفتاح الفعلي يجب أن يكون فريد وشخصي لحسابك.

