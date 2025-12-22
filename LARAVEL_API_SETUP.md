# إعداد Laravel API للتطبيق

## 📋 نظرة عامة

تم تعديل التطبيق ليستخدم:
- ✅ **Firebase Authentication** - للتحقق من رقم الهاتف عبر OTP فقط
- ✅ **Laravel API** - كقاعدة بيانات رئيسية لحفظ جميع البيانات
- ✅ **Hive (Local Storage)** - للحفظ المحلي والعمل Offline

## 🔧 التغييرات التي تمت

### 1. إزالة Firestore
- تم إزالة جميع عمليات حفظ البيانات في Firestore
- Firebase يُستخدم الآن فقط للـ OTP (Phone Authentication)

### 2. إضافة Laravel API Service
تم إنشاء ملف جديد: `lib/services/laravel_api_service.dart`

### 3. تعديل PhoneAuthService
- تم تعديل حفظ بيانات المستخدم من Firestore إلى Laravel API
- يتم الحفظ في Hive محلياً ثم المزامنة مع Laravel

## 🚀 خطوات الإعداد

### 1. إعداد Laravel Backend

قم بإنشاء Laravel API مع الـ Endpoints التالية:

#### **A. User Management**

```php
// routes/api.php

// تسجيل مستخدم جديد أو تحديثه
POST /api/users/register
{
    "id": "uuid",
    "name": "string",
    "email": "string",
    "phoneNumber": "string",
    "subscriptionType": "string",
    "subscriptionTier": "string",
    "userType": "string",
    "isPhoneVerified": boolean,
    "isLoggedIn": boolean,
    "createdAt": "datetime",
    "lastLogin": "datetime"
}

// Response:
{
    "success": true,
    "user": {...},
    "token": "auth_token"  // JWT Token
}

// تحديث بيانات المستخدم
PUT /api/users/{userId}
Headers: Authorization: Bearer {token}
Body: {same as register}

// جلب بيانات مستخدم
GET /api/users/{userId}
Headers: Authorization: Bearer {token}

// Response:
{
    "success": true,
    "user": {...}
}

// تحديث آخر تسجيل دخول
POST /api/users/{userId}/login
Headers: Authorization: Bearer {token}
```

#### **B. Subscription Management**

```php
// تحديث الاشتراك
PUT /api/users/{userId}/subscription
Headers: Authorization: Bearer {token}
Body:
{
    "tier": "string",
    "subscription_type": "string",
    "end_date": "datetime"
}
```

#### **C. Wallet Operations**

```php
// إنشاء معاملة محفظة
POST /api/wallet/transactions
Headers: Authorization: Bearer {token}
Body:
{
    "user_id": "string",
    "type": "credit|debit",
    "amount": number,
    "description": "string",
    "reference_id": "string"
}

// جلب رصيد المحفظة
GET /api/wallet/{userId}/balance
Headers: Authorization: Bearer {token}

// Response:
{
    "success": true,
    "balance": number
}
```

#### **D. Health Check**

```php
// للتحقق من أن API يعمل
GET /api/health

// Response:
{
    "status": "ok",
    "timestamp": "datetime"
}
```

### 2. تحديث رابط API في التطبيق

افتح ملف: `lib/services/laravel_api_service.dart`

```dart
// استبدل هذا السطر:
static const String baseUrl = 'https://your-laravel-api.com/api';

// بـ:
static const String baseUrl = 'https://mediaprosocial.io/api';
// أو
static const String baseUrl = 'https://your-actual-domain.com/api';
```

### 3. إعداد Laravel Database

قم بإنشاء جداول قاعدة البيانات:

```php
// database/migrations/xxxx_create_users_table.php
Schema::create('users', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->string('name');
    $table->string('email')->nullable();
    $table->string('phone_number')->unique();
    $table->string('subscription_type')->default('free');
    $table->string('subscription_tier')->default('free');
    $table->string('user_type')->default('individual');
    $table->boolean('is_phone_verified')->default(false);
    $table->boolean('is_logged_in')->default(false);
    $table->timestamp('last_login')->nullable();
    $table->timestamps();
});

// database/migrations/xxxx_create_wallet_transactions_table.php
Schema::create('wallet_transactions', function (Blueprint $table) {
    $table->id();
    $table->uuid('user_id');
    $table->enum('type', ['credit', 'debit']);
    $table->decimal('amount', 10, 2);
    $table->string('description');
    $table->string('reference_id')->nullable();
    $table->enum('status', ['pending', 'completed', 'failed'])->default('completed');
    $table->timestamps();

    $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
});
```

### 4. إعداد Authentication في Laravel

```php
// في Controller
use Firebase\JWT\JWT;

public function register(Request $request)
{
    $validated = $request->validate([
        'id' => 'required|uuid',
        'name' => 'required|string',
        'phoneNumber' => 'required|string',
        // ... بقية الحقول
    ]);

    $user = User::updateOrCreate(
        ['id' => $validated['id']],
        [
            'name' => $validated['name'],
            'phone_number' => $validated['phoneNumber'],
            'is_phone_verified' => $validated['isPhoneVerified'] ?? false,
            // ... بقية الحقول
        ]
    );

    // إنشاء JWT Token
    $token = JWT::encode(
        ['user_id' => $user->id, 'exp' => time() + (60 * 60 * 24 * 30)],
        env('JWT_SECRET'),
        'HS256'
    );

    return response()->json([
        'success' => true,
        'user' => $user,
        'token' => $token
    ], 201);
}
```

## 🔒 الأمان

### في Laravel:

```php
// app/Http/Middleware/VerifyJWTToken.php
public function handle($request, Closure $next)
{
    $token = $request->bearerToken();

    if (!$token) {
        return response()->json(['error' => 'Unauthorized'], 401);
    }

    try {
        $decoded = JWT::decode($token, new Key(env('JWT_SECRET'), 'HS256'));
        $request->user_id = $decoded->user_id;
        return $next($request);
    } catch (\Exception $e) {
        return response()->json(['error' => 'Invalid token'], 401);
    }
}
```

### في Flutter:
الـ Token يتم حفظه تلقائياً في `LaravelApiService` ويُرسل مع كل request:

```dart
'Authorization': 'Bearer ${authToken.value}'
```

## 📊 Flow التسجيل الكامل

1. **المستخدم يدخل رقم الهاتف**
   - يتم إرسال OTP عبر Firebase Auth

2. **المستخدم يدخل رمز التحقق**
   - Firebase يتحقق من الرمز
   - إذا نجح، يتم إنشاء User في Firebase Auth

3. **حفظ بيانات المستخدم**
   - يتم الحفظ أولاً في Hive (محلياً)
   - ثم يتم إرسال البيانات إلى Laravel API
   - Laravel يحفظ البيانات ويرجع Token

4. **استخدام التطبيق**
   - جميع العمليات تتم عبر Laravel API
   - البيانات تُحفظ محلياً في Hive للعمل Offline

## 🧪 الاختبار

### 1. اختبار الاتصال بـ API:

```dart
final laravelService = Get.find<LaravelApiService>();
final isConnected = await laravelService.checkConnection();
print('API Connected: $isConnected');
```

### 2. اختبار تسجيل مستخدم:

```dart
// سيتم تلقائياً عند التسجيل عبر OTP
```

### 3. اختبار جلب بيانات:

```dart
final user = await laravelService.getUserById('user_id');
print('User: ${user?.name}');
```

## ⚠️ ملاحظات مهمة

1. **لا تنسى تفعيل CORS في Laravel**:
   ```php
   // في config/cors.php
   'paths' => ['api/*'],
   'allowed_origins' => ['*'],
   'allowed_methods' => ['*'],
   ```

2. **استخدم HTTPS دائماً** في Production

3. **لا تحفظ JWT Secret في الكود** - استخدم `.env` file

4. **قم بتفعيل Rate Limiting** في Laravel للحماية من الهجمات

## 🎉 الخلاصة

الآن التطبيق يستخدم:
- 🔥 Firebase للـ OTP فقط
- 🚀 Laravel كقاعدة بيانات رئيسية
- 💾 Hive للحفظ المحلي

لا حاجة لتفعيل Firestore أو إضافة بطاقة ائتمان لـ Google Cloud!
