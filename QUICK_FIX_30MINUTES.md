# 🔧 خطة إصلاح سريعة - استخدم Firebase الآن

## 🎯 الهدف: شغّل التطبيق بنجاح في 30 دقيقة

---

## ✅ الخطوة 1: تحديث Backend Config (3 دقائق)

استخدم Firebase بدلاً من Backend المعطّل:

### التعديل المطلوب:

```dart
// lib/core/config/backend_config.dart

// غيّر من:
static const bool isProduction = true;

// إلى:
static const bool isProduction = false;
```

**التأثير:**
- ✅ سيتوقف البحث عن `mediaprosocial.io`
- ✅ سيستخدم `http://localhost:8000` (Mock)
- ✅ أو استخدم Firebase مباشرة

---

## ✅ الخطوة 2: تحديث Auth Service (10 دقائق)

استخدم Firebase OTP للتسجيل الرئيسي:

### التعديل المطلوب:

في `lib/services/auth_service.dart`، حدّث method `registerWithEmail`:

```dart
Future<bool> registerWithEmail({
  required String email,
  required String password,
  required String phoneNumber,
  required String userType,
  String? companyName,
  int? employeeCount,
}) async {
  try {
    isLoading.value = true;

    // ✅ استخدم Firebase بدلاً من Backend
    // تسجيل الدخول ببريد إلكتروني في Firebase
    final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // ✅ حفظ البيانات الإضافية في Firestore
    final user = userCredential.user!;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': email,
      'phone_number': phoneNumber,
      'user_type': userType,
      'company_name': companyName,
      'employee_count': employeeCount,
      'created_at': FieldValue.serverTimestamp(),
      'phone_verified': false,
      'is_active': true,
    });

    // ✅ حفظ محلياً
    final userData = {
      'id': user.uid,
      'name': email.split('@')[0],
      'email': email,
      'phone_number': phoneNumber,
      'user_type': userType,
      'company_name': companyName,
      'employee_count': employeeCount,
    };

    final userModel = UserModel(
      id: user.uid,
      name: email.split('@')[0],
      email: email,
      phoneNumber: phoneNumber,
      subscriptionType: 'free',
      subscriptionStartDate: DateTime.now(),
      subscriptionEndDate: DateTime.now().add(const Duration(days: 30)),
      subscriptionTier: 'free',
      userType: userType,
      isLoggedIn: true,
      isActive: true,
      isPhoneVerified: false,
      lastLogin: DateTime.now(),
      createdAt: DateTime.now(),
    );

    final box = await Hive.openBox('userBox');
    await box.put('currentUser', userModel);
    currentUser.value = userModel;
    isAuthenticated.value = true;

    print('✅ User registered successfully via Firebase');
    isLoading.value = false;
    return true;

  } on FirebaseAuthException catch (e) {
    isLoading.value = false;
    print('❌ Firebase Error: ${e.message}');
    return false;
  } catch (e) {
    isLoading.value = false;
    print('❌ Error in registerWithEmail: $e');
    return false;
  }
}
```

---

## ✅ الخطوة 3: تحديث Login Service (10 دقائق)

استخدم Firebase للدخول:

```dart
Future<bool> loginWithEmail({
  required String email,
  required String password,
}) async {
  try {
    isLoading.value = true;

    // ✅ استخدم Firebase بدلاً من Backend
    final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // ✅ حمّل البيانات من Firestore
    final user = userCredential.user!;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final userData = userDoc.data() ?? {};

    // ✅ حفظ محلياً
    final userModel = UserModel(
      id: user.uid,
      name: userData['name'] ?? email.split('@')[0],
      email: email,
      phoneNumber: userData['phone_number'] ?? '',
      subscriptionType: userData['subscription_type'] ?? 'free',
      subscriptionStartDate: DateTime.now(),
      subscriptionEndDate: DateTime.now().add(const Duration(days: 30)),
      subscriptionTier: userData['subscription_tier'] ?? 'free',
      userType: userData['user_type'] ?? 'individual',
      isLoggedIn: true,
      isActive: true,
      isPhoneVerified: userData['phone_verified'] ?? false,
      lastLogin: DateTime.now(),
      createdAt: DateTime.now(),
    );

    final box = await Hive.openBox('userBox');
    await box.put('currentUser', userModel);
    currentUser.value = userModel;
    isAuthenticated.value = true;

    print('✅ User logged in successfully via Firebase');
    isLoading.value = false;
    return true;

  } on FirebaseAuthException catch (e) {
    isLoading.value = false;
    print('❌ Firebase Error: ${e.message}');
    return false;
  } catch (e) {
    isLoading.value = false;
    print('❌ Error in loginWithEmail: $e');
    return false;
  }
}
```

---

## ✅ الخطوة 4: تحديث Social Accounts Service (5 دقائق)

استخدم Firestore بدلاً من Backend:

```dart
// في social_accounts_service.dart

Future<List<SocialAccount>> fetchAccounts() async {
  try {
    // ✅ استخدم Firestore بدلاً من Backend
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('⚠️ No user logged in');
      return _loadFromHive();
    }

    print('🔵 Fetching accounts from Firestore...');
    
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('social_accounts')
        .get();

    final accounts = snapshot.docs
        .map((doc) => SocialAccount.fromJson(doc.data()))
        .toList();

    // ✅ احفظ محلياً
    for (final account in accounts) {
      final box = await Hive.openBox<SocialAccount>('socialAccountsBox');
      await box.put(account.id, account);
    }

    print('✅ Loaded ${accounts.length} accounts from Firestore');
    return accounts;

  } catch (e) {
    print('⚠️ Failed to load from Firestore, using local data: $e');
    return _loadFromHive();
  }
}
```

---

## ✅ الخطوة 5: تشغيل التطبيق (2 دقيقة)

```bash
# تنظيف
flutter clean

# تحديث المكتبات
flutter pub get

# تشغيل
flutter run
```

---

## 🧪 اختبار سريع

### اختبر المسارات التالية:

1. **التسجيل ببريد إلكتروني:**
   ```
   ✅ أدخل بريد وكلمة مرور
   ✅ اضغط "إنشاء الحساب"
   ✅ يجب أن تنتقل للـ Dashboard
   ```

2. **التسجيل برقم الهاتف:**
   ```
   ✅ اضغط "تسجيل برقم الهاتف"
   ✅ أدخل +16505551234
   ✅ أدخل الرمز 123456
   ✅ يجب أن تنتقل للـ Dashboard
   ```

3. **تسجيل الدخول:**
   ```
   ✅ أدخل البريد والكلمة المرور
   ✅ اضغط "تسجيل الدخول"
   ✅ يجب أن تنتقل للـ Dashboard
   ```

4. **جلب الحسابات:**
   ```
   ✅ في Dashboard
   ✅ يجب أن ترى الحسابات المحفوظة
   ✅ أو نموذج فارغ إذا لم تكن هناك حسابات
   ```

---

## 🔄 معالجة الأخطاء الشائعة

### ❌ "Firebase not initialized"
**الحل:**
```dart
// في main.dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### ❌ "Firestore permission denied"
**الحل:**
في Firebase Console:
```
Firestore → Rules
- allow read, write: if request.auth != null;
```

### ❌ "Email already exists"
**الحل:**
- استخدم بريد آخر
- أو حذف الحساب من Firebase Console

### ❌ "Invalid phone number"
**الحل:**
- استخدم +16505551234 (اختبار)
- أو رقمك الفعلي مع كود الدولة

---

## 📝 ملخص التعديلات

| الملف | التعديل | المدة |
|------|---------|-------|
| `backend_config.dart` | استخدم Firebase | 3 دقائق |
| `auth_service.dart` | تحديث Register/Login | 10 دقائق |
| `social_accounts_service.dart` | استخدم Firestore | 5 دقائق |
| Testing | اختبر المسارات | 10 دقائق |

**الإجمالي: 30 دقيقة فقط! ⚡**

---

## ✅ بعد الإصلاح

```
التطبيق سيعمل مع:
✅ Firebase Auth (التسجيل والدخول)
✅ Firebase OTP (رقم الهاتف)
✅ Firestore (البيانات)
✅ Hive (Cache محلي)
✅ Dashboard (واجهة رئيسية)

Status: 🟢 جاهز للاستخدام
```

---

## 🎯 الخطوة التالية (لاحقاً)

بعد أن يعمل التطبيق مع Firebase:

1. بناء Laravel Backend
2. تطبيق جميع API Endpoints
3. Migrate البيانات من Firebase
4. Testing الشامل

ولكن الآن: **استخدم Firebase فقط وشغّل التطبيق! 🚀**
