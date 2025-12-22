# دليل تحديث التطبيق - Android, iOS, Web

## نظرة عامة

تم إصلاح مشاكل API المتعلقة بإنشاء الحسابات وتسجيل الدخول. هذا الدليل يوضح كيفية تطبيق التحديثات على جميع المنصات.

---

## 📱 تطبيق Android (Flutter)

### الملفات المحدثة
1. `lib/services/api_service.dart`
2. `lib/services/auth_service.dart`

### الخطوات المطلوبة

#### 1. التأكد من التحديثات
```bash
# تأكد من أنك في مجلد المشروع
cd C:\Users\HP\social_media_manager

# تحديث الحزم
flutter pub get

# تنظيف المشروع
flutter clean
```

#### 2. الاختبار المحلي
```bash
# تشغيل التطبيق على المحاكي أو جهاز حقيقي
flutter run
```

#### 3. اختبار وظائف التسجيل
- [ ] تسجيل مستخدم جديد برقم هاتف
- [ ] تسجيل الدخول بحساب موجود
- [ ] التحقق من OTP
- [ ] التأكد من حفظ البيانات في Hive
- [ ] التأكد من حفظ Token في ApiService

#### 4. بناء APK للإصدار
```bash
# بناء APK
flutter build apk --release

# أو بناء App Bundle (موصى به للنشر على Google Play)
flutter build appbundle --release
```

#### 5. الملفات الناتجة
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- Bundle: `build/app/outputs/bundle/release/app-release.aab`

### تغييرات الكود الرئيسية

#### api_service.dart
```dart
// تم تحديث دالة register لدعم البريد الإلكتروني الاختياري
Future<Map<String, dynamic>> register({
  required String name,
  required String phoneNumber,
  required String userType,
  String? email,  // جديد
}) async {
  final body = {
    'name': name,
    'phoneNumber': phoneNumber,  // تغيير من phone_number
    'user_type': userType,
  };

  if (email != null && email.isNotEmpty) {
    body['email'] = email;
  }

  return await _http.post('/auth/register', body: body);
}
```

#### auth_service.dart
```dart
// تم تحديث معالجة الاستجابات لدعم البنية الجديدة
final userData = apiResponse['data']?['user'] ?? apiResponse['user'];
final tokenData = apiResponse['data']?['access_token'] ??
    apiResponse['data']?['token'] ??
    apiResponse['token'];
```

---

## 🍎 تطبيق iOS (Flutter)

### نفس الملفات والخطوات الخاصة بـ Android

### خطوات إضافية لـ iOS

#### 1. التأكد من إعدادات Xcode
```bash
cd ios
pod install
cd ..
```

#### 2. الاختبار على المحاكي
```bash
flutter run -d "iPhone 15 Pro"  # أو أي محاكي آخر
```

#### 3. بناء IPA للإصدار
```bash
# بناء iOS
flutter build ios --release

# أو بناء IPA (يتطلب Mac)
flutter build ipa --release
```

#### 4. النشر على App Store
- افتح `ios/Runner.xcworkspace` في Xcode
- Archive > Distribute App
- اتبع خطوات النشر على App Store Connect

---

## 🌐 تطبيق الويب (إن وجد)

### إذا كان لديك تطبيق ويب منفصل

#### React/Next.js
إذا كان لديك تطبيق ويب بـ React أو Next.js، قم بتحديث:

##### 1. ملف API Service
```javascript
// services/apiService.js

export const register = async ({ name, phoneNumber, userType, email }) => {
  try {
    const response = await fetch('/api/auth/register', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: JSON.stringify({
        phoneNumber,
        name,
        userType,
        ...(email && { email }),
      }),
    });

    const data = await response.json();

    if (data.success) {
      // حفظ Token
      localStorage.setItem('access_token', data.data.access_token);
      localStorage.setItem('user', JSON.stringify(data.data.user));
      return { success: true, user: data.data.user };
    }

    return { success: false, error: data.message || data.error };
  } catch (error) {
    return { success: false, error: error.message };
  }
};
```

##### 2. تحديث مكونات التسجيل
```javascript
// components/RegisterForm.jsx

const handleRegister = async (formData) => {
  const result = await register({
    name: formData.name,
    phoneNumber: formData.phone,
    userType: formData.userType,
    email: formData.email, // اختياري
  });

  if (result.success) {
    // إعادة توجيه للصفحة الرئيسية
    router.push('/dashboard');
  } else {
    // عرض رسالة خطأ
    setError(result.error);
  }
};
```

#### Vue.js
```javascript
// services/api.js

import axios from 'axios';

export const authService = {
  async register({ name, phoneNumber, userType, email }) {
    try {
      const response = await axios.post('/api/auth/register', {
        phoneNumber,
        name,
        userType,
        ...(email && { email }),
      });

      if (response.data.success) {
        // حفظ Token
        localStorage.setItem('token', response.data.data.access_token);
        axios.defaults.headers.common['Authorization'] =
          `Bearer ${response.data.data.access_token}`;
        return response.data;
      }
    } catch (error) {
      throw new Error(error.response?.data?.message || 'فشل التسجيل');
    }
  }
};
```

### Flutter Web

إذا كنت تستخدم Flutter Web:

```bash
# بناء التطبيق للويب
flutter build web --release

# النتيجة ستكون في
# build/web/
```

---

## ✅ قائمة التحقق النهائية

### قبل النشر
- [ ] تم اختبار التسجيل بنجاح
- [ ] تم اختبار تسجيل الدخول بنجاح
- [ ] تم التأكد من عمل OTP
- [ ] تم التأكد من حفظ Token
- [ ] تم التأكد من عمل جميع API endpoints
- [ ] تم اختبار التطبيق على أجهزة مختلفة
- [ ] تم مراجعة رسائل الخطأ بالعربية

### بعد النشر
- [ ] مراقبة سجلات الأخطاء
- [ ] متابعة تقييمات المستخدمين
- [ ] جمع ملاحظات المستخدمين
- [ ] إصلاح أي مشاكل طارئة

---

## 🐛 استكشاف الأخطاء

### مشكلة: فشل التسجيل على التطبيق

**الحل:**
1. تأكد من تحديث `api_service.dart` و `auth_service.dart`
2. تأكد من تشغيل `flutter clean` و `flutter pub get`
3. تأكد من أن API endpoint صحيح
4. راجع سجلات التطبيق (`flutter run` في console)

### مشكلة: Token لا يتم حفظه

**الحل:**
1. تأكد من أن الاستجابة تحتوي على `access_token`
2. تأكد من استدعاء `_apiService.setAuthToken(token)`
3. راجع كود `auth_service.dart` خطوة بخطوة

### مشكلة: البيانات لا تظهر بعد التسجيل

**الحل:**
1. تأكد من حفظ المستخدم في Hive بنجاح
2. تأكد من تحديث `currentUser.value`
3. راجع `AuthService.reloadUser()`

---

## 📞 الدعم

للمشاكل التقنية أو الأسئلة:
- راجع ملف `API_UPDATES_README.md` للتفاصيل التقنية
- تحقق من سجلات الخادم: `storage/logs/laravel.log`
- تحقق من console التطبيق

---

## 📊 الإحصائيات والمراقبة

### نقاط المراقبة المهمة
1. معدل نجاح التسجيل
2. معدل نجاح تسجيل الدخول
3. أخطاء API الشائعة
4. وقت الاستجابة

### أدوات المراقبة الموصى بها
- Firebase Analytics (لتطبيق Mobile)
- Google Analytics (لتطبيق Web)
- Laravel Telescope (للـ Backend)

---

**تم التحديث:** 2025-11-19
**الإصدار:** 1.1.0
**الحالة:** ✅ جاهز للنشر
