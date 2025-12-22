# حل مشكلة CORS في Laravel Backend

## المشكلة
نسخة Flutter Web لا تستطيع الاتصال بـ Laravel Backend بسبب CORS (Cross-Origin Resource Sharing)

## الحل السريع

### الخطوة 1: إنشاء Middleware

في Backend Laravel، أنشئ ملف:
`app/Http/Middleware/Cors.php`

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class Cors
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next)
    {
        // السماح بجميع Origins في التطوير
        // في الإنتاج، حدد النطاقات المسموحة فقط
        $allowedOrigins = [
            'http://localhost:8080',
            'http://localhost',
            'http://127.0.0.1:8080',
            'https://mediaprosocial.io',
            // أضف نطاقات Flutter Web الأخرى هنا
        ];

        $origin = $request->headers->get('Origin');

        if (in_array($origin, $allowedOrigins) || app()->environment('local')) {
            return $next($request)
                ->header('Access-Control-Allow-Origin', $origin ?: '*')
                ->header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS, PATCH')
                ->header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept, Origin, X-CSRF-TOKEN')
                ->header('Access-Control-Allow-Credentials', 'true')
                ->header('Access-Control-Max-Age', '86400');
        }

        return $next($request);
    }
}
```

### الخطوة 2: تسجيل Middleware

في ملف `app/Http/Kernel.php`:

**أضف في `$middleware` (Global Middleware):**
```php
protected $middleware = [
    // ...
    \App\Http\Middleware\Cors::class, // أضف هذا
];
```

**أو أضف في `$middlewareGroups` للـ API فقط:**
```php
protected $middlewareGroups = [
    'api' => [
        \App\Http\Middleware\Cors::class, // أضف في بداية المجموعة
        \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
        'throttle:api',
        \Illuminate\Routing\Middleware\SubstituteBindings::class,
    ],
];
```

### الخطوة 3: إضافة Route للـ OPTIONS

في `routes/api.php`، أضف في البداية:

```php
<?php

// معالجة طلبات OPTIONS (Preflight)
Route::options('{any}', function() {
    return response()->json([], 200);
})->where('any', '.*');

// باقي الـ routes هنا...
```

## الحل البديل - استخدام Package

إذا كنت تفضل استخدام package جاهز:

### 1. تثبيت Package:
```bash
composer require fruitcake/laravel-cors
```

### 2. نشر الإعدادات:
```bash
php artisan vendor:publish --tag="cors"
```

### 3. تعديل `config/cors.php`:
```php
<?php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie', 'telegram/*'],

    'allowed_methods' => ['*'],

    'allowed_origins' => [
        'http://localhost:8080',
        'http://localhost',
        'http://127.0.0.1:8080',
        'https://mediaprosocial.io',
    ],

    'allowed_origins_patterns' => [
        '/^http:\/\/localhost:\d+$/',
        '/^http:\/\/127\.0\.0\.1:\d+$/',
    ],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => true,
];
```

### 4. في `app/Http/Kernel.php`:
```php
protected $middleware = [
    // ...
    \Fruitcake\Cors\HandleCors::class,
];
```

## التحقق من الإعدادات

بعد التطبيق:

### 1. امسح الـ cache:
```bash
php artisan config:clear
php artisan cache:clear
php artisan route:clear
```

### 2. اختبر من المتصفح:
افتح Console في المتصفح وشغل:
```javascript
fetch('https://mediaprosocial.io/api/health', {
    method: 'GET',
    headers: {
        'Content-Type': 'application/json',
    }
})
.then(response => response.json())
.then(data => console.log('✅ CORS works:', data))
.catch(error => console.error('❌ CORS error:', error));
```

## لـ Sanctum (إذا كنت تستخدمه)

في `.env`:
```bash
SANCTUM_STATEFUL_DOMAINS=localhost:8080,127.0.0.1:8080,mediaprosocial.io
SESSION_DOMAIN=.mediaprosocial.io
```

في `config/sanctum.php`:
```php
'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', sprintf(
    '%s%s',
    'localhost,localhost:3000,127.0.0.1,127.0.0.1:8000,::1',
    Sanctum::currentApplicationUrlWithPort()
))),
```

## حل مؤقت للاختبار فقط

إذا كنت تريد اختبار سريع بدون تعديل Backend:

**افتح Chrome مع CORS معطل:**
```bash
# Windows
"C:\Program Files\Google\Chrome\Application\chrome.exe" --disable-web-security --user-data-dir="C:\temp\chrome_cors"

# أو في PowerShell
Start-Process chrome.exe -ArgumentList "--disable-web-security","--user-data-dir=C:\temp\chrome_cors","http://localhost:8080"
```

⚠️ **تحذير**: استخدم هذا للتطوير فقط، لا تستخدمه للتصفح العادي!

## الاختبار

بعد تطبيق الحل:

1. أعد تشغيل Laravel Server
2. أعد تحميل Flutter Web (F5)
3. حاول تسجيل الدخول

يجب أن يعمل الآن! ✅

---

**تم إنشاؤه**: 2025-01-21
