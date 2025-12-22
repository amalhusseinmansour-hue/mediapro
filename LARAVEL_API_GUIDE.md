# دليل إنشاء Laravel API

## 📋 المتطلبات

- PHP >= 8.1
- Composer
- MySQL >= 5.7
- Laravel 10.x

---

## 🚀 خطوات التثبيت

### 1. إنشاء مشروع Laravel جديد

```bash
composer create-project laravel/laravel social-media-api
cd social-media-api
```

### 2. إعداد قاعدة البيانات

افتح ملف `.env` وعدّل إعدادات MySQL:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=social_media_manager
DB_USERNAME=root
DB_PASSWORD=your_password
```

### 3. إنشاء قاعدة البيانات

```sql
CREATE DATABASE social_media_manager CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

---

## 📦 تثبيت الحزم المطلوبة

```bash
# تثبيت Laravel Sanctum للمصادقة
composer require laravel/sanctum

# نشر إعدادات Sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
```

---

## 🗄️ إنشاء الجداول (Migrations)

### 1. Users Table (جدول المستخدمين)

```bash
php artisan make:migration create_users_table
```

افتح `database/migrations/xxxx_create_users_table.php`:

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('users', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('name');
            $table->string('email')->nullable();
            $table->string('phone_number')->unique();
            $table->string('photo_url')->nullable();
            $table->string('user_type')->default('individual'); // individual, business
            $table->string('subscription_tier')->default('free'); // free, individual, team, enterprise
            $table->timestamp('subscription_start_date')->nullable();
            $table->timestamp('subscription_end_date')->nullable();
            $table->boolean('is_active')->default(true);
            $table->boolean('is_phone_verified')->default(false);
            $table->timestamp('last_login')->nullable();
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('users');
    }
};
```

### 2. Subscriptions Table (جدول الاشتراكات)

```bash
php artisan make:migration create_subscriptions_table
```

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('subscriptions', function (Blueprint $table) {
            $table->id();
            $table->uuid('user_id');
            $table->string('tier'); // individual, team, enterprise
            $table->string('type'); // monthly, yearly
            $table->decimal('amount', 10, 2);
            $table->string('currency', 3)->default('USD');
            $table->integer('order_id')->nullable();
            $table->timestamp('start_date');
            $table->timestamp('end_date');
            $table->string('status')->default('active'); // active, expired, cancelled
            $table->timestamps();

            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        });
    }

    public function down()
    {
        Schema::dropIfExists('subscriptions');
    }
};
```

### 3. Login History Table (جدول سجل تسجيل الدخول)

```bash
php artisan make:migration create_login_history_table
```

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('login_history', function (Blueprint $table) {
            $table->id();
            $table->uuid('user_id');
            $table->timestamp('login_time');
            $table->timestamp('logout_time')->nullable();
            $table->string('device_info')->nullable();
            $table->string('login_method')->default('otp'); // otp, phone
            $table->boolean('is_successful')->default(true);
            $table->string('failure_reason')->nullable();
            $table->timestamps();

            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        });
    }

    public function down()
    {
        Schema::dropIfExists('login_history');
    }
};
```

### 4. OTP Table (جدول رموز التحقق)

```bash
php artisan make:migration create_otps_table
```

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('otps', function (Blueprint $table) {
            $table->id();
            $table->string('phone_number');
            $table->string('otp', 6);
            $table->timestamp('expires_at');
            $table->boolean('is_used')->default(false);
            $table->timestamps();

            $table->index('phone_number');
        });
    }

    public function down()
    {
        Schema::dropIfExists('otps');
    }
};
```

### تشغيل Migrations

```bash
php artisan migrate
```

---

## 🏗️ إنشاء Models

### 1. User Model

```bash
php artisan make:model User
```

افتح `app/Models/User.php`:

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasUuids;

    protected $keyType = 'string';
    public $incrementing = false;

    protected $fillable = [
        'name',
        'email',
        'phone_number',
        'photo_url',
        'user_type',
        'subscription_tier',
        'subscription_start_date',
        'subscription_end_date',
        'is_active',
        'is_phone_verified',
        'last_login',
    ];

    protected $hidden = [
        'remember_token',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'is_phone_verified' => 'boolean',
        'last_login' => 'datetime',
        'subscription_start_date' => 'datetime',
        'subscription_end_date' => 'datetime',
    ];

    public function subscriptions()
    {
        return $this->hasMany(Subscription::class);
    }

    public function loginHistory()
    {
        return $this->hasMany(LoginHistory::class);
    }
}
```

### 2. Subscription Model

```bash
php artisan make:model Subscription
```

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Subscription extends Model
{
    protected $fillable = [
        'user_id',
        'tier',
        'type',
        'amount',
        'currency',
        'order_id',
        'start_date',
        'end_date',
        'status',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'start_date' => 'datetime',
        'end_date' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
```

### 3. OTP Model

```bash
php artisan make:model OTP
```

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OTP extends Model
{
    protected $table = 'otps';

    protected $fillable = [
        'phone_number',
        'otp',
        'expires_at',
        'is_used',
    ];

    protected $casts = [
        'expires_at' => 'datetime',
        'is_used' => 'boolean',
    ];
}
```

---

## 🎮 إنشاء Controllers

### 1. AuthController

```bash
php artisan make:controller Api/AuthController
```

افتح `app/Http/Controllers/Api/AuthController.php`:

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\OTP;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    // تسجيل مستخدم جديد
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'phone_number' => 'required|string|unique:users',
            'email' => 'nullable|email',
            'user_type' => 'required|string|in:individual,business',
        ]);

        $user = User::create([
            'id' => (string) Str::uuid(),
            'name' => $request->name,
            'phone_number' => $request->phone_number,
            'email' => $request->email,
            'user_type' => $request->user_type,
            'subscription_tier' => 'free',
            'subscription_start_date' => now(),
            'subscription_end_date' => now()->addDays(30),
            'is_active' => true,
            'is_phone_verified' => false,
        ]);

        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'success' => true,
            'user' => $user,
            'token' => $token,
        ], 201);
    }

    // إرسال OTP
    public function sendOTP(Request $request)
    {
        $request->validate([
            'phone_number' => 'required|string',
        ]);

        // حذف OTPs القديمة
        OTP::where('phone_number', $request->phone_number)->delete();

        // توليد OTP عشوائي
        $otpCode = rand(100000, 999999);

        // حفظ OTP
        OTP::create([
            'phone_number' => $request->phone_number,
            'otp' => $otpCode,
            'expires_at' => now()->addMinutes(5),
            'is_used' => false,
        ]);

        // هنا يجب إرسال OTP عبر SMS
        // يمكن استخدام خدمات مثل Twilio, Nexmo, إلخ

        return response()->json([
            'success' => true,
            'message' => 'تم إرسال رمز التحقق',
            // للتطوير فقط - احذف هذا في Production
            'otp' => $otpCode,
        ]);
    }

    // تسجيل الدخول بواسطة OTP
    public function login(Request $request)
    {
        $request->validate([
            'phone_number' => 'required|string',
            'otp' => 'required|string|size:6',
        ]);

        // التحقق من OTP
        $otp = OTP::where('phone_number', $request->phone_number)
            ->where('otp', $request->otp)
            ->where('is_used', false)
            ->where('expires_at', '>', now())
            ->first();

        if (!$otp) {
            return response()->json([
                'success' => false,
                'message' => 'رمز التحقق غير صحيح أو منتهي الصلاحية',
            ], 401);
        }

        // البحث عن المستخدم
        $user = User::where('phone_number', $request->phone_number)->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'المستخدم غير موجود',
            ], 404);
        }

        // تحديث OTP كمستخدم
        $otp->update(['is_used' => true]);

        // تحديث معلومات المستخدم
        $user->update([
            'is_phone_verified' => true,
            'last_login' => now(),
        ]);

        // إنشاء token
        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'success' => true,
            'user' => $user,
            'token' => $token,
        ]);
    }

    // تسجيل الخروج
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'تم تسجيل الخروج بنجاح',
        ]);
    }

    // الحصول على معلومات المستخدم الحالي
    public function user(Request $request)
    {
        return response()->json($request->user());
    }
}
```

### 2. UserController

```bash
php artisan make:controller Api/UserController
```

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    // الحصول على جميع المستخدمين
    public function index()
    {
        $users = User::with('subscriptions')->get();

        return response()->json([
            'success' => true,
            'users' => $users,
        ]);
    }

    // الحصول على مستخدم محدد
    public function show($id)
    {
        $user = User::with('subscriptions', 'loginHistory')->find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'المستخدم غير موجود',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'user' => $user,
        ]);
    }

    // تحديث مستخدم
    public function update(Request $request, $id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'المستخدم غير موجود',
            ], 404);
        }

        $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email',
            'phone_number' => 'sometimes|string|unique:users,phone_number,' . $id,
            'photo_url' => 'sometimes|string',
        ]);

        $user->update($request->only([
            'name',
            'email',
            'phone_number',
            'photo_url',
        ]));

        return response()->json([
            'success' => true,
            'user' => $user,
        ]);
    }

    // حذف مستخدم
    public function destroy($id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'المستخدم غير موجود',
            ], 404);
        }

        $user->delete();

        return response()->json([
            'success' => true,
            'message' => 'تم حذف المستخدم بنجاح',
        ]);
    }
}
```

### 3. SubscriptionController

```bash
php artisan make:controller Api/SubscriptionController
```

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Subscription;
use App\Models\User;
use Illuminate\Http\Request;

class SubscriptionController extends Controller
{
    // إنشاء اشتراك جديد
    public function store(Request $request)
    {
        $request->validate([
            'user_id' => 'required|exists:users,id',
            'tier' => 'required|string|in:individual,team,enterprise',
            'type' => 'required|string|in:monthly,yearly',
            'amount' => 'required|numeric',
            'currency' => 'required|string|size:3',
            'order_id' => 'nullable|integer',
            'start_date' => 'required|date',
            'end_date' => 'required|date',
        ]);

        $subscription = Subscription::create($request->all());

        // تحديث معلومات الاشتراك في جدول المستخدمين
        User::find($request->user_id)->update([
            'subscription_tier' => $request->tier,
            'subscription_start_date' => $request->start_date,
            'subscription_end_date' => $request->end_date,
        ]);

        return response()->json([
            'success' => true,
            'subscription' => $subscription,
        ], 201);
    }

    // الحصول على اشتراك مستخدم
    public function show($userId)
    {
        $subscription = Subscription::where('user_id', $userId)
            ->where('status', 'active')
            ->latest()
            ->first();

        if (!$subscription) {
            return response()->json([
                'success' => false,
                'message' => 'لا يوجد اشتراك نشط',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'subscription' => $subscription,
        ]);
    }

    // تحديث اشتراك
    public function update(Request $request, $id)
    {
        $subscription = Subscription::find($id);

        if (!$subscription) {
            return response()->json([
                'success' => false,
                'message' => 'الاشتراك غير موجود',
            ], 404);
        }

        $subscription->update($request->only([
            'tier',
            'type',
            'amount',
            'end_date',
            'status',
        ]));

        return response()->json([
            'success' => true,
            'subscription' => $subscription,
        ]);
    }
}
```

---

## 🛣️ إنشاء Routes

افتح `routes/api.php`:

```php
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\SubscriptionController;

// Public routes
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/send-otp', [AuthController::class, 'sendOTP']);
Route::post('/auth/login', [AuthController::class, 'login']);

// Health check
Route::get('/health', function () {
    return response()->json(['status' => 'ok']);
});

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // Auth routes
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/user', [AuthController::class, 'user']);

    // User routes
    Route::get('/users', [UserController::class, 'index']);
    Route::get('/users/{id}', [UserController::class, 'show']);
    Route::put('/users/{id}', [UserController::class, 'update']);
    Route::delete('/users/{id}', [UserController::class, 'destroy']);

    // Subscription routes
    Route::post('/subscriptions', [SubscriptionController::class, 'store']);
    Route::get('/subscriptions/{userId}', [SubscriptionController::class, 'show']);
    Route::put('/subscriptions/{id}', [SubscriptionController::class, 'update']);
});
```

---

## ⚙️ إعداد CORS

افتح `config/cors.php`:

```php
'paths' => ['api/*', 'sanctum/csrf-cookie'],

'allowed_methods' => ['*'],

'allowed_origins' => ['*'], // في Production، حدد النطاقات المسموحة

'allowed_origins_patterns' => [],

'allowed_headers' => ['*'],

'exposed_headers' => [],

'max_age' => 0,

'supports_credentials' => false,
```

---

## 🚀 تشغيل السيرفر

```bash
php artisan serve
```

السيرفر سيعمل على: `http://127.0.0.1:8000`

---

## 🧪 اختبار API

استخدم Postman أو curl:

```bash
# تسجيل مستخدم جديد
curl -X POST http://127.0.0.1:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "phone_number": "+1234567890",
    "user_type": "individual"
  }'

# إرسال OTP
curl -X POST http://127.0.0.1:8000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone_number": "+1234567890"
  }'

# تسجيل الدخول
curl -X POST http://127.0.0.1:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone_number": "+1234567890",
    "otp": "123456"
  }'
```

---

## 📤 نشر API على السيرفر

### 1. رفع الملفات

```bash
# ضغط المشروع
zip -r social-media-api.zip . -x "*.git*" "node_modules/*" "vendor/*"

# رفع إلى السيرفر عبر FTP أو SCP
scp social-media-api.zip user@your-server.com:/path/to/api/
```

### 2. تثبيت على السيرفر

```bash
# فك الضغط
unzip social-media-api.zip

# تثبيت dependencies
composer install --no-dev --optimize-autoloader

# إعداد البيئة
cp .env.example .env
php artisan key:generate

# تشغيل migrations
php artisan migrate --force

# تحسين الأداء
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

---

## 🔒 الأمان

### 1. تفعيل Rate Limiting

افتح `app/Http/Kernel.php`:

```php
'api' => [
    'throttle:60,1', // 60 طلب في الدقيقة
    \Illuminate\Routing\Middleware\SubstituteBindings::class,
],
```

### 2. إضافة API Key middleware (اختياري)

```bash
php artisan make:middleware ApiKeyMiddleware
```

### 3. تفعيل HTTPS في Production

تأكد من استخدام HTTPS فقط في البيئة الإنتاجية.

---

## ✅ الخلاصة

الآن لديك:
- ✅ Laravel API كامل مع MySQL
- ✅ نظام مصادقة بـ OTP
- ✅ إدارة المستخدمين
- ✅ نظام اشتراكات
- ✅ API جاهز للاستخدام مع Flutter

**الخطوة التالية**: حدّث رابط API في `lib/services/api_service.dart`!
