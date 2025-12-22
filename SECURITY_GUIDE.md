# 🔐 دليل الأمان والتشفير

## نظرة عامة

يوفر `SecurityManager` حلاً شاملاً وآمناً لجميع عمليات الأمان والتشفير والتحقق من صحة البيانات.

## المكونات الرئيسية

### 1. Storage الآمن (Secure Storage)

يستخدم النظام `FlutterSecureStorage` لتخزين البيانات الحساسة:

- **Android**: استخدام EncryptedSharedPreferences
- **iOS**: استخدام Keychain

#### الاستخدام

```dart
import 'package:social_media_manager/core/security/security_manager.dart';

final security = SecurityManager();

// حفظ بيانات حساسة
await security.saveSecure('api_token', 'abc123xyz');

// قراءة البيانات
final token = await security.readSecure('api_token');

// حذف البيانات
await security.deleteSecure('api_token');

// مسح جميع البيانات
await security.clearAllSecure();
```

### 2. التشفير والتجزئة (Encryption & Hashing)

#### SHA-256 Hashing

```dart
// تجزئة كلمة المرور
final passwordHash = security.hashSHA256('myPassword123');
// النتيجة: متسقة وآمنة للمقارنة
```

#### MD5 Hashing

```dart
// لتحديد الملفات
final fileHash = security.hashMD5('file_content');
```

#### Base64 Encoding/Decoding

```dart
// تشفير البيانات
final encoded = security.encodeBase64('Hello World');

// فك التشفير
final decoded = security.decodeBase64(encoded);
```

#### HMAC-SHA256 للتوقيع

```dart
// إنشاء توقيع آمن
final signature = security.generateHMAC(
  'data_to_sign',
  'secret_key',
);

// التحقق من الصحة في الخادم
```

### 3. التحقق من صحة البيانات (Validation)

#### التحقق من البريد الإلكتروني

```dart
final isValid = security.isValidEmail('user@example.com');
// true

final isInvalid = security.isValidEmail('invalid@');
// false
```

#### التحقق من كلمة المرور

```dart
final strength = security.validatePassword('Pass123!');

switch (strength) {
  case PasswordStrength.veryWeak:
    print('كلمة المرور ضعيفة جداً');
  case PasswordStrength.weak:
    print('كلمة المرور ضعيفة');
  case PasswordStrength.fair:
    print('كلمة المرور متوسطة');
  case PasswordStrength.strong:
    print('كلمة المرور قوية');
  case PasswordStrength.veryStrong:
    print('كلمة المرور قوية جداً');
}
```

**معايير قوة كلمة المرور:**
- ✅ أحرف صغيرة
- ✅ أحرف كبيرة
- ✅ أرقام
- ✅ أحرف خاصة (!@#$%^&*)
- ✅ على الأقل 8 أحرف

#### التحقق من رقم الهاتف

```dart
final isValid = security.isValidPhoneNumber('+1(555)123-4567');
// true

final isInvalid = security.isValidPhoneNumber('123');
// false
```

#### التحقق من الـ URL

```dart
final isValid = security.isValidURL('https://www.example.com');
// true

final isInvalid = security.isValidURL('not-a-url');
// false
```

### 4. تنظيف البيانات (Sanitization)

حماية من هجمات XSS وحقن HTML:

```dart
final userInput = '<script>alert("XSS")</script>Hello';
final sanitized = security.sanitizeInput(userInput);
// النتيجة: 'Hello' (بدون الوسوم الخطيرة)
```

### 5. مولد PIN

```dart
// إنشاء PIN عشوائي
final pin = PINGenerator.generatePIN(6);
// النتيجة: '847392'

// التحقق من صحة PIN
final isValid = PINGenerator.validatePIN('847392', 6);
// true
```

## أفضل الممارسات الأمنية

### 1. تخزين البيانات الحساسة

✅ **صحيح:**
```dart
// حفظ التوكن بشكل آمن
await security.saveSecure('auth_token', token);
```

❌ **خاطئ:**
```dart
// لا تحفظ التوكن في SharedPreferences العادي
preferences.setString('auth_token', token);
```

### 2. عدم تسجيل البيانات الحساسة

✅ **صحيح:**
```dart
logger.info('User login successful');
```

❌ **خاطئ:**
```dart
logger.info('User login with token: $token');
```

### 3. التحقق دائماً من صحة المدخلات

```dart
// تحقق من البريد قبل الإرسال
if (!security.isValidEmail(email)) {
  throw ValidationException(
    message: 'البريد غير صحيح',
    errors: {'email': 'صيغة البريد غير صحيحة'},
  );
}

// تحقق من قوة كلمة المرور
final strength = security.validatePassword(password);
if (strength.index < PasswordStrength.strong.index) {
  showError('كلمة المرور ضعيفة جداً');
  return;
}
```

### 4. تنظيف المدخلات من المستخدم

```dart
// قبل حفظ البيانات
final cleanedInput = security.sanitizeInput(userInput);
await saveToDatabase(cleanedInput);
```

### 5. استخدام HTTPS فقط

```dart
// في api_config.dart
const String backendBaseUrl = 'https://mediaprosocial.io'; // ✅ HTTPS

// ليس
const String backendBaseUrl = 'http://mediaprosocial.io'; // ❌ HTTP
```

## سيناريوهات الاستخدام

### سيناريو 1: تسجيل المستخدم

```dart
Future<void> registerUser(String email, String password) async {
  final security = SecurityManager();
  
  // التحقق من البريد
  if (!security.isValidEmail(email)) {
    throw ValidationException(
      message: 'البريد غير صحيح',
      errors: {'email': 'صيغة البريد غير صحيحة'},
    );
  }
  
  // التحقق من كلمة المرور
  final strength = security.validatePassword(password);
  if (strength.index < PasswordStrength.strong.index) {
    throw ValidationException(
      message: 'كلمة المرور ضعيفة',
      errors: {'password': 'كلمة المرور يجب أن تكون قوية'},
    );
  }
  
  // تجزئة كلمة المرور
  final hashedPassword = security.hashSHA256(password);
  
  // إرسال البيانات للخادم
  await api.register(email, hashedPassword);
}
```

### سيناريو 2: حفظ التوكن بأمان

```dart
Future<void> saveAuthToken(String token) async {
  final security = SecurityManager();
  
  // حفظ التوكن بشكل آمن
  await security.saveSecure('auth_token', token);
  
  // إنشاء توقيع للتحقق لاحقاً
  final signature = security.generateHMAC(
    token,
    'app_secret_key',
  );
  
  await security.saveSecure('token_signature', signature);
}
```

### سيناريو 3: التحقق من بيانات الدفع

```dart
Future<void> processPayment(String cardNumber, String cvv) async {
  final security = SecurityManager();
  
  // تنظيف البيانات
  final cleanCard = security.sanitizeInput(cardNumber);
  final cleanCVV = security.sanitizeInput(cvv);
  
  // التحقق من الصيغة
  if (cleanCard.length != 16 || !RegExp(r'^\d+$').hasMatch(cleanCard)) {
    throw PaymentException.invalidCard();
  }
  
  // عدم حفظ البيانات الحساسة محلياً
  // إرسالها مباشرة إلى بوابة الدفع
}
```

## الملخص

✅ **الفوائد:**
- حماية البيانات الحساسة
- توقيع رقمي آمن
- منع هجمات XSS وحقن HTML
- تحقق شامل من المدخلات
- توافق مع أفضل الممارسات الأمنية

⚠️ **ملاحظات مهمة:**
- استخدم HTTPS دائماً
- لا تحفظ كلمات المرور نصاً عادياً
- لا تسجل البيانات الحساسة
- استخدم الرموز (Tokens) بدلاً من كلمات المرور
- راجع سياسات الخصوصية و GDPR
