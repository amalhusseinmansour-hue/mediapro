# الحل السريع - Paymob Authentication Error

## المشكلة
```
Error 403: Paymob Auth Error - incorrect credentials
يحدث عند محاولة الاشتراك في شاشة الاشتراكات
```

## الحل الفوري (نسخ-لصق)

### 1. اذهب إلى هذا الرابط
```
https://accept.paymob.com/portal2/en/profile/api-keys
```

### 2. انسخ API Key من هناك

### 3. افتح الملف
```
lib/core/config/api_config.dart
```

### 4. ابحث عن هذا السطر (حوالي سطر 180)
```dart
static const String paymobApiKey = String.fromEnvironment(
  'PAYMOB_API_KEY',
  defaultValue: 'ZXlKaGJHY2lPaUpJVXpVeE1p...',  // ← هنا
);
```

### 5. استبدل بـ
```dart
static const String paymobApiKey = String.fromEnvironment(
  'PAYMOB_API_KEY',
  defaultValue: 'PASTE_YOUR_API_KEY_HERE',
);
```

### 6. احفظ الملف ثم شغّل التطبيق

---

## اختبار سريع

```dart
// أضف هذا في main.dart
import 'lib/utils/paymob_diagnostic_test.dart';

void main() async {
  await runPaymobDiagnostics();
  runApp(const MyApp());
}
```

ستشاهد رسالة في console:
- ✅ إذا كانت "Authentication successful" = تم!
- ❌ إذا كانت "Authentication failed" = أعد المحاولة

---

## معلومات إضافية

📂 **الملفات المرتبطة:**
- `lib/core/config/api_config.dart` - يحتوي على المفتاح
- `lib/services/paymob_service.dart` - يستخدم المفتاح
- `lib/screens/subscription/subscription_screen.dart` - شاشة الاشتراكات

📚 **الوثائق:**
- `PAYMOB_AUTHENTICATION_FIX.md` - شرح مفصل
- `PAYMOB_SUBSCRIPTION_FIX_GUIDE.md` - دليل شامل
- `PAYMOB_ERROR_SUMMARY.md` - ملخص سريع

🔗 **روابط مفيدة:**
- Paymob: https://accept.paymob.com
- الدعم: support@paymob.com

---

**سؤال؟** اقرأ `PAYMOB_SUBSCRIPTION_FIX_GUIDE.md` للمزيد
