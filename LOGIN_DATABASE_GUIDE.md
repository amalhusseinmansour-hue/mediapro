# دليل نظام تسجيل الدخول وحفظ البيانات

## نظرة عامة
تم إصلاح وتوحيد نظام تسجيل الدخول في التطبيق ليقوم بحفظ بيانات المستخدمين في:
1. **التخزين المحلي (Hive)**: للوصول السريع والعمل بدون إنترنت
2. **قاعدة البيانات السحابية (Firestore)**: للمزامنة عبر الأجهزة والنسخ الاحتياطي

---

## المكونات الرئيسية

### 1. AuthService (`lib/services/auth_service.dart`)
الخدمة الرئيسية لإدارة المصادقة والمستخدمين.

**الوظائف الرئيسية:**
- `registerUser()` - تسجيل مستخدم جديد
- `loginUser()` - تسجيل دخول مستخدم موجود
- `loginWithPhone()` - تسجيل دخول برقم الهاتف (Firebase Auth)
- `loginWithOTP()` - تسجيل دخول باستخدام OTP
- `signOut()` - تسجيل خروج

**ما يحدث عند تسجيل الدخول:**
```dart
// 1. حفظ في Hive (محلياً)
await box.put(_currentUserKey, user);

// 2. مزامنة مع Firestore (سحابياً)
await _firestoreService.createOrUpdateUser(user);

// 3. حفظ سجل تسجيل الدخول
await _saveLoginHistory(userId: user.id, loginMethod: 'phone');
```

---

### 2. PhoneAuthService (`lib/services/phone_auth_service.dart`)
خدمة تسجيل الدخول باستخدام رقم الهاتف عبر Firebase Authentication.

**التحديثات:**
- ✅ يحفظ بيانات المستخدم في Hive
- ✅ يحفظ بيانات المستخدم في Firestore
- ✅ يحدث وقت آخر تسجيل دخول
- ✅ يتحقق من رقم الهاتف عبر OTP

**مثال على الاستخدام:**
```dart
// إرسال OTP
await phoneAuthService.sendOTP('+966512345678');

// التحقق من OTP
final userCredential = await phoneAuthService.verifyOTP('123456');
// بعد التحقق، يتم حفظ البيانات تلقائياً في Hive و Firestore
```

---

### 3. FirestoreService (`lib/services/firestore_service.dart`)
خدمة التفاعل مع قاعدة بيانات Firestore.

**الجداول (Collections) في Firestore:**

#### جدول `users`
```javascript
{
  id: "user-uuid",
  name: "اسم المستخدم",
  email: "email@example.com",
  phoneNumber: "+966512345678",
  subscriptionType: "free|individual|business",
  subscriptionTier: "free|individual|business",
  subscriptionStartDate: "2025-01-01T00:00:00.000Z",
  subscriptionEndDate: "2025-02-01T00:00:00.000Z",
  isLoggedIn: true,
  isActive: true,
  isPhoneVerified: true,
  lastLogin: "2025-01-15T10:30:00.000Z",
  createdAt: "2025-01-01T00:00:00.000Z",
  updatedAt: "2025-01-15T10:30:00.000Z"
}
```

#### جدول `login_history`
```javascript
{
  id: "history-uuid",
  userId: "user-uuid",
  loginTime: "2025-01-15T10:30:00.000Z",
  logoutTime: "2025-01-15T12:00:00.000Z",
  sessionDuration: 90, // بالدقائق
  deviceInfo: "Windows - 10.0.19041",
  loginMethod: "phone|otp|email",
  isSuccessful: true,
  failureReason: null
}
```

**الوظائف المتاحة:**
- `createOrUpdateUser(user)` - إنشاء أو تحديث مستخدم
- `getUserById(userId)` - جلب بيانات مستخدم
- `updateUserLastLogin(userId)` - تحديث آخر تسجيل دخول
- `saveLoginHistory(loginHistory)` - حفظ سجل تسجيل دخول
- `getUserLoginHistory(userId)` - جلب سجل تسجيل دخول المستخدم

---

## تدفق تسجيل الدخول

### السيناريو 1: تسجيل دخول برقم الهاتف (الموصى به)

```
المستخدم → PhoneAuthScreen
    ↓
    إدخال رقم الهاتف
    ↓
PhoneAuthService.sendOTP(phoneNumber)
    ↓
Firebase يرسل OTP عبر SMS
    ↓
المستخدم يدخل OTP في OTPVerificationScreen
    ↓
PhoneAuthService.verifyOTP(code)
    ↓
Firebase يتحقق من الكود
    ↓
✅ نجح التحقق
    ↓
_saveUserToHive(firebaseUser)
    ├─→ حفظ في Hive محلياً
    ├─→ حفظ في Firestore سحابياً
    ├─→ تحديث AuthService
    └─→ حفظ سجل تسجيل الدخول
    ↓
التوجيه إلى DashboardScreen
```

### السيناريو 2: مستخدم موجود (تسجيل دخول سريع)

```
المستخدم → LoginScreen
    ↓
التحقق من hasExistingUser()
    ↓
✅ مستخدم موجود في Hive
    ↓
AuthService.loginUser()
    ├─→ تحديث isLoggedIn = true
    ├─→ تحديث lastLogin
    └─→ مزامنة مع Firestore
    ↓
التوجيه إلى DashboardScreen
```

---

## التحقق من حفظ البيانات

### في Firebase Console:
1. افتح [Firebase Console](https://console.firebase.google.com)
2. اختر مشروعك
3. انتقل إلى **Firestore Database**
4. ابحث عن Collections:
   - `users` - جدول المستخدمين
   - `login_history` - سجل تسجيل الدخول

### في التطبيق (Logs):
عند تسجيل الدخول، ستظهر رسائل في Console:
```
📱 _saveUserToHive called for user: +966512345678
✅ Hive box opened successfully
📝 Creating new user...
✅ User saved to Hive: +966512345678 (ID: abc123)
💾 Saving user to Firestore...
✅ User saved to Firestore successfully
📊 User ID: abc123
📱 Phone: +966512345678
💼 Subscription: free
✅ Last login updated in Firestore
✅ Login history saved with ID: xyz789
```

---

## استكشاف الأخطاء

### المشكلة: "FirestoreService not available"
**الحل:**
- تأكد من تهيئة Firebase في `main.dart`
- تحقق من تسجيل `FirestoreService` في GetX:
  ```dart
  Get.put(FirestoreService());
  ```

### المشكلة: "User not saved to Firestore"
**الحل:**
1. تحقق من اتصال الإنترنت
2. راجع قواعد Firestore Security Rules:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null;
       }
       match /login_history/{historyId} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

### المشكلة: "No user found in Hive"
**الحل:**
- امسح البيانات المحلية:
  ```dart
  await authService.clearUserData();
  ```
- أعد تسجيل الدخول

---

## نصائح للتطوير

### اختبار حفظ البيانات:
```dart
// 1. تسجيل مستخدم جديد
final user = await authService.registerUser(
  name: 'Test User',
  phoneNumber: '+966512345678',
  userType: 'individual',
);

// 2. التحقق من الحفظ في Hive
final currentUser = await authService.getCurrentUser();
print('User in Hive: ${currentUser?.name}');

// 3. التحقق من الحفظ في Firestore
final firestoreUser = await firestoreService.getUserById(user.id);
print('User in Firestore: ${firestoreUser?.name}');

// 4. جلب سجل تسجيل الدخول
final loginHistory = await firestoreService.getUserLoginHistory(user.id);
print('Login history entries: ${loginHistory.length}');
```

---

## الملفات المحدثة

### ملفات تم تعديلها:
1. ✅ `lib/services/phone_auth_service.dart`
   - إضافة حفظ في Firestore
   - إضافة FirestoreService dependency

2. ✅ `lib/screens/auth/login_screen.dart`
   - تحديث لاستخدام AuthService الصحيح
   - إزالة auth_service_temp

3. ✅ `lib/services/auth_service.dart`
   - بالفعل يحفظ في Firestore
   - يحفظ سجل تسجيل الدخول

### الخدمات المتاحة:
- ✅ `AuthService` - الخدمة الرئيسية
- ✅ `PhoneAuthService` - تسجيل دخول بالهاتف
- ✅ `FirestoreService` - التفاعل مع قاعدة البيانات
- ⚠️ `auth_service_temp.dart` - (قديم - لا يُنصح باستخدامه)

---

## الخلاصة

✅ **تم الإصلاح:**
- تسجيل الدخول يحفظ البيانات في Hive (محلياً)
- تسجيل الدخول يحفظ البيانات في Firestore (سحابياً)
- يتم حفظ سجل تسجيل الدخول مع كل عملية تسجيل دخول
- تم توحيد جميع خدمات تسجيل الدخول

✅ **الجداول في Firestore:**
- `users` - معلومات المستخدمين الكاملة
- `login_history` - سجل تسجيل الدخول والخروج

✅ **الميزات:**
- عمل بدون إنترنت (Hive)
- مزامنة سحابية (Firestore)
- تتبع نشاط المستخدم
- أمان البيانات

---

## للمزيد من المساعدة

إذا واجهت أي مشاكل:
1. تحقق من Logs في Console
2. راجع Firebase Console لرؤية البيانات
3. تأكد من إعدادات Firebase Security Rules
4. تحقق من اتصال الإنترنت

📝 **ملاحظة:** جميع عمليات تسجيل الدخول تتم بشكل آمن عبر Firebase Authentication، والبيانات محمية بقواعد الأمان في Firestore.
