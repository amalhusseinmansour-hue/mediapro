# 🚀 Firebase OTP - Quick Setup Guide

## ⚡ الخطوات السريعة

### 1️⃣ إضافة Dependencies (2 دقيقة)

```yaml
# pubspec.yaml
dependencies:
  firebase_auth: ^4.10.0
  firebase_core: ^2.24.0
  cloud_firestore: ^4.13.0
  get: ^4.6.5
```

ثم:
```bash
flutter pub get
```

### 2️⃣ تهيئة Firebase (3 دقائق)

```dart
// main.dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  Get.put(FirebasePhoneAuthService());
  runApp(const MyApp());
}
```

### 3️⃣ تفعيل Phone Auth (1 دقيقة)

**في Firebase Console:**

```
1. اذهب إلى: Authentication
2. انقر: Sign-in method
3. اختر: Phone
4. فعّل: الخيار
5. (اختياري) أضف أرقام اختبار
```

### 4️⃣ إضافة Navigation (2 دقيقة)

```dart
// في GetMaterialApp
getPages: [
  GetPage(
    name: '/login',
    page: () => LoginScreen(),
  ),
  GetPage(
    name: '/otp-verify',
    page: () => FirebaseOTPVerificationScreen(
      phoneNumber: Get.arguments['phone'],
    ),
  ),
],
```

---

## 📱 الاستخدام الأساسي

### إرسال OTP

```dart
final phoneAuth = Get.find<FirebasePhoneAuthService>();

await phoneAuth.sendOTP('+971501234567');
Get.to(() => FirebaseOTPVerificationScreen(
  phoneNumber: '+971501234567',
));
```

### في الـ Screen

```dart
// الرمز يُدخل تلقائياً
// عند النقر "تحقق"
// ينتقل للـ Dashboard
```

---

## 🧪 الاختبار

### استخدام أرقام الاختبار

في Firebase Console، أضف:
- **الرقم**: +16505551234
- **الرمز**: 123456

### الاختبار المحلي

```dart
// استخدم الرقم المضاف في Firebase
// الرمز سيكون 123456 دائماً
```

---

## ✅ Checklist سريع

- [ ] Firebase project أنشئ
- [ ] google-services.json أضيف (Android)
- [ ] GoogleService-Info.plist أضيف (iOS)
- [ ] Phone Auth مفعل
- [ ] Dependencies مثبتة
- [ ] main.dart محدث
- [ ] Navigation متصل
- [ ] test phone أضيف (اختياري)

---

## 🎯 الملفات الجديدة

| الملف | الوصف |
|------|-------|
| `firebase_phone_auth_service.dart` | خدمة Firebase (250 سطر) |
| `firebase_otp_verification_screen.dart` | واجهة المستخدم (350 سطر) |
| `FIREBASE_OTP_INTEGRATION_GUIDE.md` | دليل كامل |

---

## 🆘 مساعدة سريعة

**Q: لا يتم استقبال OTP**
A: تأكد من `+` في البداية، مثل: `+971501234567`

**Q: "invalid-phone-number"**
A: استخدم رمز الدولة الصحيح

**Q: كيف أختبر؟**
A: أضف رقم اختبار في Firebase Console

**Q: كم حد أقصى للمحاولات؟**
A: 5 محاولات، إعادة إرسال كل 60 ثانية

---

## 🚀 جاهز!

**النظام الآن جاهز للاستخدام!**

```dart
// Just use it:
final phoneAuth = Get.find<FirebasePhoneAuthService>();
await phoneAuth.sendOTP(phoneNumber);
```

**Happy Coding! 💚**
