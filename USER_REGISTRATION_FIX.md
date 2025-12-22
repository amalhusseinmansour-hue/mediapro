# ✅ إصلاح حفظ بيانات المستخدم في جدول users

## 📌 المشكلة السابقة

عند تسجيل مستخدم جديد من تطبيق Flutter:
- ✅ كانت البيانات تُحفظ **محلياً** في Hive (local storage)
- ⚠️ كانت البيانات تُحفظ في Firestore (اختياري)
- ❌ **لم** تكن البيانات تُرسل إلى Laravel Backend
- ❌ **لم** تُحفظ في جدول `users` في قاعدة البيانات

---

## ✅ الحل المُطبق

### 1️⃣ **تحديث Flutter - AuthService**

**الملف:** `lib/services/auth_service.dart`

**التغييرات:**
```dart
// تم إضافة:
import 'api_service.dart';

// تم إضافة instance من ApiService:
final ApiService _apiService = ApiService();

// تم تحديث دالة registerUser():
Future<UserModel> registerUser({...}) async {
  // 1. إرسال البيانات إلى Laravel Backend
  final apiResponse = await _apiService.register(
    name: name,
    phoneNumber: phoneNumber,
    userType: userType,
  );

  // 2. حفظ token
  if (apiResponse['success'] == true) {
    final apiToken = apiResponse['data']['access_token'];
    _apiService.setAuthToken(apiToken);
  }

  // 3. حفظ محلياً في Hive
  // 4. مزامنة مع Firestore (اختياري)
}
```

**النتيجة:**
- ✅ عند التسجيل، يتم إرسال البيانات إلى Laravel أولاً
- ✅ يتم حفظ Auth Token للمصادقة
- ✅ ثم يتم الحفظ محلياً

---

### 2️⃣ **تحديث Laravel - AuthController**

**الملف:** `backend/app/Http/Controllers/Api/AuthController.php`

**التغييرات:**

#### أ. حفظ نوع المستخدم (user_type):
```php
protected function registerWithPhone(Request $request): JsonResponse {
  $userType = $request->input('user_type') ?? 'individual';

  $user = User::create([
    'name' => $name,
    'phone' => $phone,
    'type_of_audience' => $userType,  // ✅ تم إضافته
    'is_phone_verified' => true,
    'is_active' => true,
    'last_login_at' => now(),
  ]);
}
```

#### ب. توحيد صيغة Response:
```php
// قبل:
return response()->json([
  'message' => '...',
  'user' => $user,
  'access_token' => $token,
]);

// بعد:
return response()->json([
  'success' => true,          // ✅ إضافة success flag
  'message' => '...',
  'data' => [                 // ✅ تغليف البيانات في data
    'user' => $user,
    'access_token' => $token,
    'token_type' => 'Bearer',
  ],
]);
```

**النتيجة:**
- ✅ يتم حفظ `user_type` في قاعدة البيانات
- ✅ Response متوافق مع Flutter
- ✅ يتم تحديث `last_login_at` عند كل تسجيل دخول

---

## 🗄️ قاعدة البيانات

### جدول `users` يحتوي على:

| الحقل | النوع | الوصف |
|------|------|-------|
| `id` | bigint | معرف المستخدم الفريد |
| `name` | string | اسم المستخدم |
| `email` | string | البريد الإلكتروني |
| `phone` | string | رقم الهاتف |
| `password` | hashed | كلمة المرور المشفرة |
| `type_of_audience` | string | نوع المستخدم (individual, business, etc.) |
| `is_phone_verified` | boolean | تأكيد رقم الهاتف |
| `is_admin` | boolean | صلاحيات الأدمن |
| `is_active` | boolean | حالة الحساب |
| `last_login_at` | timestamp | آخر تسجيل دخول |

**Migration:** تم إنشاؤها بالفعل في:
- `0001_01_01_000000_create_users_table.php`
- `2025_11_08_000006_add_missing_fields_to_users_table.php`

---

## 🔄 تدفق البيانات الجديد

### عند التسجيل من Flutter:

```
1. المستخدم يدخل البيانات (name, phone, userType)
   ↓
2. Flutter AuthService.registerUser()
   ↓
3. 🌐 إرسال POST إلى Laravel: /api/auth/register
   ↓
4. Laravel AuthController.registerWithPhone()
   ↓
5. 💾 حفظ في جدول users (MySQL)
   ↓
6. 🔑 إنشاء Auth Token (Sanctum)
   ↓
7. ↩️ إرجاع Response: {success, data: {user, token}}
   ↓
8. Flutter يحفظ Token
   ↓
9. 💾 Flutter يحفظ في Hive (local)
   ↓
10. ☁️ Flutter يحفظ في Firestore (اختياري)
```

---

## 📝 اختبار التكامل

### 1. اختبار التسجيل من التطبيق:

```bash
# في Laravel Backend
cd backend
php artisan tinker

# التحقق من آخر مستخدم مسجل:
User::latest()->first()

# عرض جميع المستخدمين:
User::all()

# عرض المستخدمين حسب رقم الهاتف:
User::where('phone', '+971xxxxxxxxx')->get()
```

### 2. فحص Logs:

**Flutter Console:**
```
📝 Registering user: محمد, Phone: +971501234567
🌐 Sending registration data to Laravel Backend...
✅ User registered in Laravel Backend
🔑 Auth token saved: eyJ0eXAiOiJKV1QiL...
✅ User saved to Hive (Local Storage)
```

**Laravel Logs:**
```bash
# عرض logs
cd backend
php artisan pail

# أو
tail -f storage/logs/laravel.log
```

---

## 🔑 API Endpoints المُحدثة

### POST `/api/auth/register`

**Request:**
```json
{
  "name": "محمد أحمد",
  "phone_number": "+971501234567",
  "email": "optional@email.com",
  "user_type": "individual"
}
```

**Response (Success - 201):**
```json
{
  "success": true,
  "message": "تم التسجيل بنجاح",
  "data": {
    "user": {
      "id": 1,
      "name": "محمد أحمد",
      "email": "+971501234567@temp.user",
      "phone": "+971501234567",
      "type_of_audience": "individual",
      "is_phone_verified": true,
      "is_active": true,
      "last_login_at": "2025-01-09T12:00:00.000000Z"
    },
    "access_token": "1|xxxxxxxxxxxxxxxxxxxxx",
    "token_type": "Bearer"
  }
}
```

**Response (Existing User - 200):**
```json
{
  "success": true,
  "message": "تم تسجيل الدخول بنجاح",
  "data": {
    "user": {...},
    "access_token": "2|xxxxxxxxxxxxxxxxxxxxx",
    "token_type": "Bearer"
  }
}
```

---

## 🛡️ المصادقة (Laravel Sanctum)

### كيف يعمل:

1. **عند التسجيل/الدخول:**
   - Laravel ينشئ token عبر `$user->createToken('auth_token')`
   - Token يُحفظ في جدول `personal_access_tokens`
   - يتم إرجاع Token للتطبيق

2. **عند الطلبات المحمية:**
   - Flutter يضيف Header: `Authorization: Bearer {token}`
   - Laravel middleware `auth:sanctum` يتحقق من Token
   - إذا صحيح، يسمح بالوصول

3. **عند تسجيل الخروج:**
   - يتم حذف Token من قاعدة البيانات
   - المستخدم لا يستطيع الوصول للـ endpoints المحمية

---

## ✅ الخلاصة

### ما تم إصلاحه:
- ✅ **Flutter** يرسل بيانات التسجيل إلى Laravel
- ✅ **Laravel** يحفظ البيانات في جدول `users`
- ✅ يتم حفظ `user_type` بشكل صحيح
- ✅ نظام المصادقة بـ Laravel Sanctum يعمل
- ✅ Response format موحد ومتوافق
- ✅ البيانات تُحفظ محلياً وفي السيرفر

### النتيجة النهائية:
🎉 **الآن عند تسجيل المستخدم من تطبيق Flutter، بياناته تُحفظ بنجاح في جدول users في قاعدة البيانات!**

---

## 📞 الدعم

إذا واجهت أي مشاكل:
1. تحقق من Laravel logs: `php artisan pail`
2. تحقق من Flutter console logs
3. تأكد من أن Backend URL صحيح في `backend_config.dart`
4. تأكد من أن قاعدة البيانات متصلة (`.env` في Laravel)

---

**تاريخ الإصلاح:** 2025-01-09
**الإصدار:** v1.0
