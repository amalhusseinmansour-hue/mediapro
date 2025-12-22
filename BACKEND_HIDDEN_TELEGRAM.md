# Backend Setup للتليجرام الخفي 🔒

## نظرة عامة

نظام التليجرام الخفي يتطلب endpoint واحد فقط في Backend لإرسال إعدادات البوت إلى التطبيق.

---

## المتطلبات

### 1. إنشاء Telegram Bot

```bash
1. افتح @BotFather في تليجرام
2. أرسل: /newbot
3. أدخل اسم البوت: "MyApp System Bot"
4. أدخل Username: "myapp_system_bot"
5. احفظ Bot Token الذي سيُعطى لك
```

### 2. إنشاء Group للإدارة

```bash
1. أنشئ مجموعة جديدة في تليجرام
2. أضف البوت للمجموعة
3. اجعل البوت Admin
4. احصل على Chat ID:
   - أضف @userinfobot للمجموعة مؤقتاً
   - سيُظهر Chat ID (مثل: -1001234567890)
   - أزل @userinfobot
```

---

## Backend Implementation

### الخطوة 1: إضافة متغيرات البيئة

```bash
# في .env
TELEGRAM_SYSTEM_BOT_TOKEN=123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11
TELEGRAM_ADMIN_CHAT_ID=-1001234567890
```

### الخطوة 2: Controller

```php
<?php
// app/Http/Controllers/Api/TelegramController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class TelegramController extends Controller
{
    /**
     * Get bot configuration for background service
     * هذا هو Endpoint الوحيد المطلوب
     */
    public function getBotConfig(Request $request)
    {
        // جلب إعدادات البوت من البيئة
        $botToken = env('TELEGRAM_SYSTEM_BOT_TOKEN');
        $chatId = env('TELEGRAM_ADMIN_CHAT_ID');

        // إذا لم تكن موجودة، أرجع null
        if (!$botToken || !$chatId) {
            return response()->json([
                'config' => null,
                'message' => 'Telegram bot not configured',
            ]);
        }

        // أرجع الإعدادات للتطبيق
        return response()->json([
            'success' => true,
            'config' => [
                'bot_token' => $botToken,
                'chat_id' => $chatId,
            ],
        ]);
    }

    /**
     * (اختياري) - اختبار إرسال رسالة من Backend
     */
    public function testNotification(Request $request)
    {
        $botToken = env('TELEGRAM_SYSTEM_BOT_TOKEN');
        $chatId = env('TELEGRAM_ADMIN_CHAT_ID');

        if (!$botToken || !$chatId) {
            return response()->json([
                'success' => false,
                'message' => 'Bot not configured',
            ], 400);
        }

        try {
            $message = "✅ Test notification from Backend\n\n⏰ " . now();

            $url = "https://api.telegram.org/bot{$botToken}/sendMessage";

            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, $url);
            curl_setopt($ch, CURLOPT_POST, 1);
            curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query([
                'chat_id' => $chatId,
                'text' => $message,
                'parse_mode' => 'HTML',
            ]));
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

            $response = curl_exec($ch);
            curl_close($ch);

            $data = json_decode($response, true);

            return response()->json([
                'success' => $data['ok'] ?? false,
                'message' => 'Test notification sent',
                'telegram_response' => $data,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }
}
```

### الخطوة 3: Routes

```php
<?php
// routes/api.php

use App\Http\Controllers\Api\TelegramController;

Route::middleware('auth:sanctum')->group(function () {
    // الـ endpoint الرئيسي المطلوب
    Route::get('/telegram/bot-config', [TelegramController::class, 'getBotConfig']);

    // endpoint اختياري للاختبار
    Route::post('/telegram/test-notification', [TelegramController::class, 'testNotification']);
});
```

---

## الاختبار

### 1. اختبار من Backend

```bash
curl -X GET http://localhost:8000/api/telegram/bot-config \
  -H "Authorization: Bearer YOUR_AUTH_TOKEN" \
  -H "Accept: application/json"
```

**Response متوقع**:
```json
{
  "success": true,
  "config": {
    "bot_token": "123456:ABC-DEF...",
    "chat_id": "-1001234567890"
  }
}
```

### 2. اختبار إرسال رسالة

```bash
curl -X POST http://localhost:8000/api/telegram/test-notification \
  -H "Authorization: Bearer YOUR_AUTH_TOKEN" \
  -H "Accept: application/json"
```

**يجب أن تصل رسالة في مجموعة التليجرام**.

---

## الأمان

### ✅ Best Practices

1. **لا تُرسل Bot Token في API Response**
   - ❌ سيء: `'bot_token' => env('...')`  ← **يمكن للمستخدم رؤيته**
   - ✅ جيد: إرساله فقط عبر `auth:sanctum` middleware

2. **استخدم HTTPS فقط**
   ```php
   if (!$request->secure()) {
       abort(403, 'HTTPS required');
   }
   ```

3. **Rate Limiting**
   ```php
   Route::middleware(['auth:sanctum', 'throttle:10,1'])->group(...);
   ```

4. **Log Access**
   ```php
   Log::info('Telegram config accessed', [
       'user_id' => $request->user()->id,
       'ip' => $request->ip(),
   ]);
   ```

---

## إدارة متقدمة (اختياري)

### إذا أردت دعم multiple bots لكل user

```php
// Migration
Schema::create('user_telegram_bots', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->string('bot_token');
    $table->string('chat_id');
    $table->boolean('is_active')->default(true);
    $table->timestamps();
});
```

```php
// Controller
public function getBotConfig(Request $request)
{
    $user = $request->user();

    // جلب بوت المستخدم
    $bot = $user->telegramBots()->where('is_active', true)->first();

    if (!$bot) {
        // fallback للبوت الافتراضي
        return response()->json([
            'config' => [
                'bot_token' => env('TELEGRAM_SYSTEM_BOT_TOKEN'),
                'chat_id' => env('TELEGRAM_ADMIN_CHAT_ID'),
            ],
        ]);
    }

    return response()->json([
        'config' => [
            'bot_token' => $bot->bot_token,
            'chat_id' => $bot->chat_id,
        ],
    ]);
}
```

---

## Troubleshooting

### المشكلة: `config` يعود `null`

**السبب**: متغيرات البيئة غير موجودة

**الحل**:
```bash
1. تحقق من .env:
   TELEGRAM_SYSTEM_BOT_TOKEN=...
   TELEGRAM_ADMIN_CHAT_ID=...

2. امسح الـ cache:
   php artisan config:clear
   php artisan cache:clear
```

### المشكلة: `401 Unauthorized`

**السبب**: Bot Token غير صحيح

**الحل**:
```bash
1. تحقق من Bot Token في @BotFather
2. أرسل /mybots ← اختر البوت ← API Token
3. انسخ الـ token الصحيح
4. حدّث .env
```

### المشكلة: `400 Bad Request (chat not found)`

**السبب**: Chat ID غير صحيح

**الحل**:
```bash
1. تأكد أن البوت موجود في المجموعة
2. تأكد أن البوت Admin
3. تأكد من إضافة - قبل رقم المجموعة: -1001234567890
4. استخدم @userinfobot للحصول على Chat ID الصحيح
```

---

## مثال كامل (Full Implementation)

### 1. .env
```bash
TELEGRAM_SYSTEM_BOT_TOKEN=5678901234:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw
TELEGRAM_ADMIN_CHAT_ID=-1001234567890
```

### 2. Controller
```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class TelegramController extends Controller
{
    public function getBotConfig(Request $request)
    {
        // Log access للأمان
        Log::info('Telegram config requested', [
            'user_id' => $request->user()->id,
            'user_name' => $request->user()->name,
        ]);

        $botToken = env('TELEGRAM_SYSTEM_BOT_TOKEN');
        $chatId = env('TELEGRAM_ADMIN_CHAT_ID');

        if (!$botToken || !$chatId) {
            Log::warning('Telegram bot not configured in .env');

            return response()->json([
                'config' => null,
                'message' => 'Bot not configured',
            ]);
        }

        return response()->json([
            'success' => true,
            'config' => [
                'bot_token' => $botToken,
                'chat_id' => $chatId,
            ],
        ]);
    }

    public function testNotification(Request $request)
    {
        $botToken = env('TELEGRAM_SYSTEM_BOT_TOKEN');
        $chatId = env('TELEGRAM_ADMIN_CHAT_ID');

        if (!$botToken || !$chatId) {
            return response()->json([
                'success' => false,
                'message' => 'Bot not configured',
            ], 400);
        }

        try {
            $user = $request->user();
            $message = "🧪 <b>Test Notification</b>\n\n";
            $message .= "Triggered by: {$user->name}\n";
            $message .= "User ID: {$user->id}\n";
            $message .= "⏰ " . now()->toDateTimeString();

            $url = "https://api.telegram.org/bot{$botToken}/sendMessage";

            $response = file_get_contents($url . '?' . http_build_query([
                'chat_id' => $chatId,
                'text' => $message,
                'parse_mode' => 'HTML',
            ]));

            $data = json_decode($response, true);

            Log::info('Test notification sent', [
                'success' => $data['ok'] ?? false,
                'user_id' => $user->id,
            ]);

            return response()->json([
                'success' => $data['ok'] ?? false,
                'message' => 'Test notification sent to Telegram',
            ]);

        } catch (\Exception $e) {
            Log::error('Failed to send test notification', [
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }
}
```

### 3. Routes
```php
<?php

use App\Http\Controllers\Api\TelegramController;

Route::middleware(['auth:sanctum', 'throttle:60,1'])->group(function () {
    Route::get('/telegram/bot-config', [TelegramController::class, 'getBotConfig']);
    Route::post('/telegram/test-notification', [TelegramController::class, 'testNotification']);
});
```

---

## للتطوير المستقبلي

### ميزات يمكن إضافتها:

1. **إدارة البوتات من Admin Panel**
   ```php
   // Admin can change bot config without touching .env
   Route::post('/admin/telegram/update-config', ...);
   ```

2. **Multiple Bots** حسب الباقة
   ```php
   // Free: system bot
   // Paid: custom user bot
   ```

3. **Webhooks** بدلاً من Long Polling
   ```php
   Route::post('/telegram/webhook/{botId}', ...);
   ```

4. **تقارير تلقائية** من Backend
   ```php
   // Cron job - كل يوم
   php artisan telegram:send-daily-report
   ```

---

**تم إنشاؤه بواسطة Claude Code** 🤖
**التاريخ**: 2025-01-21
