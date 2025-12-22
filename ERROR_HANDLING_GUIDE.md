# 📚 دليل معالجة الأخطاء الشامل

## نظرة عامة

تم تطوير نظام معالجة أخطاء احترافي وشامل للتطبيق يغطي جميع الحالات المحتملة ويوفر تجربة مستخدم ممتازة عند حدوث الأخطاء.

## البنية الهرمية للأخطاء

```
AppException (الفئة الأساسية)
├── NetworkException (أخطاء الشبكة)
├── AuthException (أخطاء المصادقة)
├── ServerException (أخطاء الخادم)
├── CacheException (أخطاء التخزين المؤقت)
├── ValidationException (أخطاء التحقق)
├── PaymentException (أخطاء الدفع)
└── UnexpectedException (أخطاء غير متوقعة)
```

## كيفية الاستخدام

### 1. التعامل مع الأخطاء في الخدمات

```dart
import 'package:social_media_manager/core/error/error_handler.dart';

class MyService {
  final errorHandler = ErrorHandler();

  Future<void> fetchData() async {
    try {
      // عملية
    } catch (error, stackTrace) {
      final appException = errorHandler.handleError(error, stackTrace);
      errorHandler.showErrorSnackBar(appException);
      rethrow;
    }
  }
}
```

### 2. الاستخدام الآمن (Safe Try)

```dart
final result = await errorHandler.safeTry(
  () => apiService.fetchUsers(),
  showError: true,
  defaultValue: [],
);
```

### 3. معالجة النتائج

```dart
final result = Result<User>.success(user);

result.when(
  onSuccess: (user) {
    print('User: ${user.name}');
  },
  onError: (error) {
    print('Error: ${error.message}');
  },
);
```

## أنواع الأخطاء

### NetworkException - أخطاء الشبكة

```dart
// مهلة انتهاء الاتصال
NetworkException.timeout()

// لا يوجد اتصال
NetworkException.noInternet()

// خطأ في الاتصال
NetworkException.connectionError()
```

### AuthException - أخطاء المصادقة

```dart
// بيانات غير صحيحة
AuthException.unauthorized()

// انتهت الصلاحية
AuthException.tokenExpired()

// لم يتم العثور على الرمز
AuthException.tokenNotFound()

// لا توجد صلاحية
AuthException.forbidden()
```

### ServerException - أخطاء الخادم

```dart
// خطأ داخلي
ServerException.internalError()

// طلب غير صحيح
ServerException.badRequest()

// المورد غير موجود
ServerException.notFound()

// تم تجاوز حد الطلبات
ServerException.rateLimited()
```

## System.Logger - نظام التسجيل

### استخدام الـ Logger

```dart
import 'package:social_media_manager/core/error/app_logger.dart';

final logger = AppLogger();

// رسائل معلومات
logger.info('User logged in successfully');

// رسائل تصحيح
logger.debug('Processing user data');

// رسائل تحذير
logger.warning('API response time exceeded 5 seconds');

// رسائل خطأ
logger.error('Failed to save user data', error, stackTrace);

// رسائل حرجة
logger.critical('Database connection lost', error, stackTrace);
```

### استخراج السجلات

```dart
// الحصول على جميع السجلات
final allLogs = logger.getLogs();

// الحصول على السجلات حسب المستوى
final errors = logger.getLogsByLevel('ERROR');

// تصدير كـ نص
final text = logger.exportLogs();

// تصدير كـ JSON
final json = logger.exportLogsAsJson();

// مسح السجلات
logger.clearLogs();
```

## معالجة الأخطاء الخاصة

### ValidationException - أخطاء التحقق

```dart
try {
  // تحقق من البيانات
  if (email.isEmpty) {
    throw ValidationException(
      message: 'خطأ في البيانات المدخلة',
      errors: {
        'email': 'البريد الإلكتروني مطلوب',
        'password': 'كلمة المرور مطلوبة',
      },
    );
  }
} catch (error) {
  final exception = error as ValidationException;
  
  // عرض الأخطاء الفردية
  exception.errors.forEach((field, message) {
    print('$field: $message');
  });
}
```

### PaymentException - أخطاء الدفع

```dart
try {
  await paymentService.processPayment(amount);
} catch (error) {
  if (error is PaymentException) {
    if (error.code == 'INSUFFICIENT_FUNDS') {
      // الرصيد غير كافي
    } else if (error.code == 'INVALID_CARD') {
      // بطاقة غير صحيحة
    }
  }
}
```

## أفضل الممارسات

### 1. استخدام try-catch الصحيح

✅ **صحيح:**
```dart
try {
  final data = await fetchData();
} catch (error, stackTrace) {
  handleError(error, stackTrace);
}
```

❌ **خاطئ:**
```dart
try {
  final data = await fetchData();
} catch (e) {
  // لا توجد معلومات عن الخطأ
}
```

### 2. تسجيل الأخطاء المهمة

```dart
// استخدم critical للأخطاء الخطيرة
logger.critical('Database connection failed', error, stackTrace);

// استخدم error للأخطاء العادية
logger.error('Failed to load user profile', error, stackTrace);

// استخدم warning للتنبيهات
logger.warning('Slow API response', null, null);
```

### 3. عرض رسائل مفيدة للمستخدم

✅ **جيد:**
```dart
showErrorSnackBar(
  exception,
  duration: const Duration(seconds: 4),
);
```

❌ **سيء:**
```dart
// لا تعرض الأخطاء الفنية للمستخدم
showErrorSnackBar(exception); // يعرض: "java.io.IOException: ..."
```

## إعدادات Global Error Handler

### في main.dart

```dart
import 'package:social_media_manager/core/error/app_logger.dart';

void main() {
  // إعداد معالج الأخطاء العام
  setupGlobalErrorHandler();
  
  runApp(const MyApp());
}
```

هذا يضمن اكتشاف جميع الأخطاء غير المعالجة.

## التكامل مع Firebase Crashlytics

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// في ErrorHandler.reportError()
await FirebaseCrashlytics.instance.recordError(
  exception.originalError,
  exception.stackTrace,
  reason: exception.message,
  fatal: isFatal,
);
```

## الملخص

✅ **الفوائد:**
- معالجة موحدة للأخطاء
- تسجيل شامل للأحداث
- رسائل خطأ واضحة للمستخدم
- سهولة التصحيح والمراقبة
- تحسين تجربة المستخدم
