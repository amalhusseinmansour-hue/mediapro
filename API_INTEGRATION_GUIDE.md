# دليل ربط التطبيق مع Backend API

## نظرة عامة

تم إضافة نظام API كامل للتواصل مع Laravel backend على الرابط:
**https://mediaprosocial.io/api**

## الملفات الجديدة

### 1. `lib/core/config/backend_config.dart`
يحتوي على جميع إعدادات الـ API:
- Base URL للـ Production و Development
- جميع الـ Endpoints
- HTTP Headers
- رسائل الأخطاء
- Status Codes

### 2. `lib/services/http_service.dart`
خدمة HTTP كاملة للتعامل مع الطلبات:
- GET, POST, PUT, DELETE requests
- Multipart requests (لرفع الملفات)
- إدارة Authentication Token
- معالجة الأخطاء

## كيفية الاستخدام

### 1. تهيئة HTTP Service

```dart
import 'package:social_media_manager/services/http_service.dart';
import 'package:social_media_manager/core/config/backend_config.dart';

// إنشاء instance من HttpService
final httpService = HttpService();

// تعيين Authentication Token
httpService.setAuthToken('your_jwt_token_here');
```

### 2. أمثلة على استخدام الـ API

#### تسجيل الدخول (Login)

```dart
Future<void> login(String phoneNumber, String password) async {
  try {
    final response = await httpService.post(
      BackendConfig.loginEndpoint,
      body: {
        'phone_number': phoneNumber,
        'password': password,
      },
    );

    // حفظ الـ token
    final token = response['data']['token'];
    httpService.setAuthToken(token);

    print('تم تسجيل الدخول بنجاح');
  } catch (e) {
    print('خطأ في تسجيل الدخول: $e');
  }
}
```

#### التسجيل (Register)

```dart
Future<void> register({
  required String name,
  required String phoneNumber,
  required String email,
  required String password,
}) async {
  try {
    final response = await httpService.post(
      BackendConfig.registerEndpoint,
      body: {
        'name': name,
        'phone_number': phoneNumber,
        'email': email,
        'password': password,
        'password_confirmation': password,
      },
    );

    print('تم التسجيل بنجاح');
    return response['data'];
  } catch (e) {
    print('خطأ في التسجيل: $e');
    rethrow;
  }
}
```

#### الحصول على خطط الاشتراك

```dart
Future<List<Map<String, dynamic>>> getSubscriptionPlans() async {
  try {
    final response = await httpService.get(
      BackendConfig.subscriptionPlansEndpoint,
    );

    return (response['data'] as List).cast<Map<String, dynamic>>();
  } catch (e) {
    print('خطأ في جلب خطط الاشتراك: $e');
    return [];
  }
}
```

#### الاشتراك في خطة

```dart
Future<void> subscribe(String planId) async {
  try {
    final response = await httpService.post(
      BackendConfig.subscribeEndpoint,
      body: {
        'plan_id': planId,
        'payment_method': 'paymob',
      },
    );

    print('تم الاشتراك بنجاح');
    return response['data'];
  } catch (e) {
    print('خطأ في الاشتراك: $e');
    rethrow;
  }
}
```

#### رفع ملف (Upload File)

```dart
import 'package:http/http.dart' as http;
import 'dart:io';

Future<void> uploadImage(File imageFile) async {
  try {
    final multipartFile = await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
    );

    final response = await httpService.multipart(
      '/posts/upload-image',
      fields: {
        'caption': 'صورة جديدة',
      },
      files: [multipartFile],
    );

    print('تم رفع الصورة بنجاح');
    return response['data'];
  } catch (e) {
    print('خطأ في رفع الصورة: $e');
    rethrow;
  }
}
```

### 3. معالجة الأخطاء

```dart
try {
  final response = await httpService.post(
    BackendConfig.loginEndpoint,
    body: {'phone_number': phone, 'password': password},
  );
} on HttpException catch (e) {
  // خطأ من الـ API
  if (e.isUnauthorized) {
    print('بيانات الدخول غير صحيحة');
  } else if (e.isValidationError) {
    final errors = e.validationErrors;
    print('أخطاء في البيانات: $errors');
  } else {
    print('خطأ: ${e.message}');
  }
} catch (e) {
  // خطأ عام
  print('حدث خطأ غير متوقع: $e');
}
```

## Endpoints المتوفرة

### Authentication
- `POST /api/auth/login` - تسجيل الدخول
- `POST /api/auth/register` - التسجيل
- `POST /api/auth/logout` - تسجيل الخروج
- `POST /api/auth/send-otp` - إرسال OTP
- `POST /api/auth/verify-otp` - التحقق من OTP
- `POST /api/auth/refresh` - تجديد الـ Token

### User
- `GET /api/user/profile` - الحصول على بيانات المستخدم
- `PUT /api/user/update` - تحديث بيانات المستخدم
- `DELETE /api/user/delete` - حذف الحساب

### Subscriptions
- `GET /api/subscriptions` - الحصول على جميع الخطط
- `GET /api/subscription-plans` - الحصول على خطط الاشتراك
- `GET /api/user/subscription` - الحصول على اشتراك المستخدم الحالي
- `POST /api/subscriptions/subscribe` - الاشتراك في خطة
- `POST /api/subscriptions/cancel` - إلغاء الاشتراك

### Payments
- `POST /api/payments/initiate` - بدء عملية دفع
- `POST /api/payments/verify` - التحقق من الدفع
- `GET /api/payments/history` - سجل المدفوعات

### Posts
- `GET /api/posts` - الحصول على المنشورات
- `POST /api/posts/create` - إنشاء منشور جديد
- `PUT /api/posts/update` - تحديث منشور
- `DELETE /api/posts/delete` - حذف منشور
- `POST /api/posts/schedule` - جدولة منشور

### Analytics
- `GET /api/analytics` - إحصائيات عامة
- `GET /api/analytics/posts` - إحصائيات المنشورات
- `GET /api/analytics/accounts` - إحصائيات الحسابات

### Settings
- `GET /api/settings` - الحصول على الإعدادات
- `PUT /api/settings/update` - تحديث الإعدادات

## التبديل بين Production و Development

في ملف `backend_config.dart`:

```dart
// للإنتاج (Production)
static const bool isProduction = true;

// للتطوير المحلي (Development)
static const bool isProduction = false;
```

## خطوات التطبيق التالية

1. **تحديث auth_service.dart** لاستخدام Backend API بدلاً من Firebase
2. **إنشاء subscription_service.dart** للتعامل مع الاشتراكات
3. **إنشاء posts_service.dart** للتعامل مع المنشورات
4. **إنشاء analytics_service.dart** للتحليلات

## مثال كامل: إنشاء Backend Auth Service

```dart
import 'package:get/get.dart';
import '../core/config/backend_config.dart';
import 'http_service.dart';

class BackendAuthService extends GetxController {
  final _httpService = HttpService();

  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isAuthenticated = false.obs;

  Future<bool> login(String phone, String password) async {
    try {
      final response = await _httpService.post(
        BackendConfig.loginEndpoint,
        body: {
          'phone_number': phone,
          'password': password,
        },
      );

      final token = response['data']['token'];
      final user = User.fromJson(response['data']['user']);

      _httpService.setAuthToken(token);
      currentUser.value = user;
      isAuthenticated.value = true;

      // حفظ الـ token في التخزين المحلي
      await _saveToken(token);

      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _httpService.post(BackendConfig.logoutEndpoint);
    } finally {
      _httpService.clearAuthToken();
      currentUser.value = null;
      isAuthenticated.value = false;
      await _clearToken();
    }
  }

  // حفظ ومسح الـ token
  Future<void> _saveToken(String token) async {
    // استخدم shared_preferences أو Hive
  }

  Future<void> _clearToken() async {
    // مسح من التخزين المحلي
  }
}
```

## ملاحظات مهمة

1. **Authentication**: يجب تخزين الـ JWT token بشكل آمن في التطبيق
2. **Error Handling**: استخدم try-catch في جميع الطلبات
3. **Loading States**: أضف loading indicators عند إجراء الطلبات
4. **Retry Logic**: يمكن إضافة منطق لإعادة المحاولة عند فشل الطلب
5. **Caching**: يمكن استخدام Hive لتخزين البيانات محلياً

## الدعم

للمزيد من المعلومات حول Laravel API، راجع:
- https://mediaprosocial.io/api/documentation
- Backend Code في مجلد `/backend`
