# 🚀 Laravel API - الكود الكامل الجاهز للرفع

## 📁 هيكل المشروع

```
backend/
├── routes/
│   └── api.php
├── app/
│   ├── Http/Controllers/Api/
│   │   ├── AuthController.php
│   │   ├── UserController.php
│   │   └── SubscriptionController.php
│   └── Models/
│       ├── User.php
│       ├── Subscription.php
│       └── OTP.php
├── database/migrations/
│   ├── 2024_01_01_000001_create_users_table.php
│   ├── 2024_01_01_000002_create_subscriptions_table.php
│   └── 2024_01_01_000003_create_otps_table.php
├── .env
└── composer.json
```

---

## 📄 1. routes/api.php

```php
<?php

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
    return response()->json(['status' => 'ok', 'timestamp' => now()]);
});

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/user', [AuthController::class, 'user']);

    Route::apiResource('users', UserController::class);
    Route::post('/subscriptions', [SubscriptionController::class, 'store']);
    Route::get('/subscriptions/{userId}', [SubscriptionController::class, 'show']);
});
```

---

## 📄 2. app/Http/Controllers/Api/AuthController.php

انسخ هذا الملف كاملاً (**الكود في `LARAVEL_API_GUIDE.md` - Section: AuthController**)

يحتوي على:
- `register()` - تسجيل مستخدم جديد
- `sendOTP()` - إرسال رمز التحقق
- `login()` - تسجيل الدخول
- `logout()` - تسجيل الخروج
- `user()` - الحصول على المستخدم الحالي

---

## 📄 3. app/Http/Controllers/Api/UserController.php

انسخ هذا الملف كاملاً (**الكود في `LARAVEL_API_GUIDE.md` - Section: UserController**)

يحتوي على:
- `index()` - جميع المستخدمين
- `show($id)` - مستخدم محدد
- `update($id)` - تحديث مستخدم
- `destroy($id)` - حذف مستخدم

---

## 📄 4. app/Http/Controllers/Api/SubscriptionController.php

انسخ هذا الملف كاملاً (**الكود في `LARAVEL_API_GUIDE.md` - Section: SubscriptionController**)

يحتوي على:
- `store()` - إنشاء اشتراك
- `show($userId)` - الحصول على اشتراك المستخدم
- `update($id)` - تحديث اشتراك

---

## 📄 5. app/Models/User.php

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
        'name', 'email', 'phone_number', 'photo_url', 'user_type',
        'subscription_tier', 'subscription_start_date', 'subscription_end_date',
        'is_active', 'is_phone_verified', 'last_login',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'is_phone_verified' => 'boolean',
        'last_login' => 'datetime',
        'subscription_start_date' => 'datetime',
        'subscription_end_date' => 'datetime',
    ];

    public function subscriptions() {
        return $this->hasMany(Subscription::class);
    }
}
```

---

## 📄 6. app/Models/Subscription.php

```php
<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Subscription extends Model
{
    protected $fillable = [
        'user_id', 'tier', 'type', 'amount', 'currency',
        'order_id', 'start_date', 'end_date', 'status',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'start_date' => 'datetime',
        'end_date' => 'datetime',
    ];

    public function user() {
        return $this->belongsTo(User::class);
    }
}
```

---

## 📄 7. app/Models/OTP.php

```php
<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OTP extends Model
{
    protected $table = 'otps';

    protected $fillable = [
        'phone_number', 'otp', 'expires_at', 'is_used',
    ];

    protected $casts = [
        'expires_at' => 'datetime',
        'is_used' => 'boolean',
    ];
}
```

---

## 📄 8. database/migrations/2024_01_01_000001_create_users_table.php

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
            $table->string('user_type')->default('individual');
            $table->string('subscription_tier')->default('free');
            $table->timestamp('subscription_start_date')->nullable();
            $table->timestamp('subscription_end_date')->nullable();
            $table->boolean('is_active')->default(true);
            $table->boolean('is_phone_verified')->default(false);
            $table->timestamp('last_login')->nullable();
            $table->timestamps();
        });
    }

    public function down() {
        Schema::dropIfExists('users');
    }
};
```

---

## 📄 9. database/migrations/2024_01_01_000002_create_subscriptions_table.php

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
            $table->string('tier');
            $table->string('type');
            $table->decimal('amount', 10, 2);
            $table->string('currency', 3)->default('USD');
            $table->integer('order_id')->nullable();
            $table->timestamp('start_date');
            $table->timestamp('end_date');
            $table->string('status')->default('active');
            $table->timestamps();

            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        });
    }

    public function down() {
        Schema::dropIfExists('subscriptions');
    }
};
```

---

## 📄 10. database/migrations/2024_01_01_000003_create_otps_table.php

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

    public function down() {
        Schema::dropIfExists('otps');
    }
};
```

---

## 📄 11. .env (إعدادات قاعدة البيانات)

```env
APP_NAME="Social Media Manager API"
APP_ENV=production
APP_KEY=base64:YOUR_APP_KEY_HERE
APP_DEBUG=false
APP_URL=https://mediaprosocial.io

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=social_media_db
DB_USERNAME=your_db_username
DB_PASSWORD=your_db_password

SANCTUM_STATEFUL_DOMAINS=mediaprosocial.io
SESSION_DRIVER=file
```

---

## 📄 12. config/cors.php

```php
<?php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['*'], // في Production: ['https://yourdomain.com']
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => false,
];
```

---

## 🚀 خطوات الرفع على السيرفر

### 1. إنشاء مشروع Laravel جديد على السيرفر

```bash
# SSH إلى السيرفر
ssh your-user@mediaprosocial.io

# الانتقال إلى المجلد العام
cd public_html

# إنشاء مشروع Laravel (إذا لم يكن موجوداً)
composer create-project laravel/laravel api
cd api
```

### 2. نسخ الملفات

انسخ جميع الملفات أعلاه إلى المجلدات المناسبة:

```
routes/api.php → routes/api.php
app/Http/Controllers/Api/* → app/Http/Controllers/Api/
app/Models/* → app/Models/
database/migrations/* → database/migrations/
.env → .env
config/cors.php → config/cors.php
```

### 3. تثبيت Laravel Sanctum

```bash
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
```

### 4. إعداد قاعدة البيانات

```bash
# تحرير ملف .env وإضافة بيانات قاعدة البيانات
nano .env

# إنشاء قاعدة البيانات (من phpMyAdmin أو MySQL CLI)
# CREATE DATABASE social_media_db;

# تشغيل Migrations
php artisan migrate

# توليد APP_KEY
php artisan key:generate
```

### 5. تحسين الأداء

```bash
# تحسين التطبيق
composer install --no-dev --optimize-autoloader
php artisan config:cache
php artisan route:cache
php artisan view:cache

# تعيين الصلاحيات
chmod -R 755 storage bootstrap/cache
```

### 6. إعداد .htaccess (للخادم Apache)

أنشئ ملف `.htaccess` في مجلد `public`:

```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteRule ^(.*)$ public/$1 [L]
</IfModule>
```

---

## ✅ اختبار API

بعد الرفع، اختبر API:

```bash
# اختبار Health Check
curl https://mediaprosocial.io/api/health

# يجب أن ترجع:
# {"status":"ok","timestamp":"2025-01-07T..."}
```

---

## 🔧 حل المشاكل الشائعة

### 1. خطأ 500 Internal Server Error
- تحقق من ملف `.env`
- تأكد من تشغيل `php artisan key:generate`
- تحقق من صلاحيات المجلدات

### 2. خطأ CORS
- حدّث `config/cors.php`
- أضف النطاق الخاص بك في `allowed_origins`

### 3. خطأ قاعدة البيانات
- تأكد من بيانات `.env` صحيحة
- تحقق من إنشاء قاعدة البيانات
- شغّل `php artisan migrate`

---

## 📝 ملاحظات مهمة

1. **الأمان**: في Production، غيّر `APP_DEBUG=false` و `APP_ENV=production`
2. **HTTPS**: تأكد من استخدام HTTPS فقط
3. **API Keys**: احفظ Sanctum tokens بشكل آمن
4. **Backup**: احفظ نسخة احتياطية من قاعدة البيانات بانتظام

---

## 🎯 الخلاصة

الآن لديك:
- ✅ كود Laravel API كامل
- ✅ جميع الملفات المطلوبة
- ✅ تعليمات الرفع والتشغيل
- ✅ اختبارات جاهزة

**بعد رفع API، حدّثني لنختبر الاتصال من Flutter!** 🚀
