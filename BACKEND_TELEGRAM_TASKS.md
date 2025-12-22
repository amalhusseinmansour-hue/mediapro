# مهام Backend للتليجرام 📋

## نظرة عامة
يحتاج Backend إلى إضافة دعم كامل لبوتات التليجرام والنشر على القنوات.

---

## المهام المطلوبة

### 1. قاعدة البيانات (Migrations)

#### جدول `telegram_bots`
```sql
CREATE TABLE telegram_bots (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    bot_token VARCHAR(255) NOT NULL,
    bot_username VARCHAR(255) NOT NULL,
    bot_first_name VARCHAR(255),
    bot_id VARCHAR(255),
    chat_id VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_bot_token (bot_token),
    INDEX idx_user_id (user_id),
    INDEX idx_is_active (is_active)
);
```

#### جدول `telegram_posts` (اختياري - لتتبع المنشورات)
```sql
CREATE TABLE telegram_posts (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    bot_id BIGINT UNSIGNED NOT NULL,
    channel_username VARCHAR(255) NOT NULL,
    message_id VARCHAR(255),
    content TEXT,
    image_url TEXT,
    hashtags JSON,
    status ENUM('pending', 'published', 'failed') DEFAULT 'pending',
    error_message TEXT,
    published_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (bot_id) REFERENCES telegram_bots(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_bot_id (bot_id),
    INDEX idx_status (status)
);
```

---

### 2. Models

#### `app/Models/TelegramBot.php`
```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TelegramBot extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'bot_token',
        'bot_username',
        'bot_first_name',
        'bot_id',
        'chat_id',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    protected $hidden = [
        'bot_token', // Hide sensitive token
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function posts()
    {
        return $this->hasMany(TelegramPost::class, 'bot_id');
    }

    // Get bot info from Telegram API
    public function verifyBot()
    {
        $url = "https://api.telegram.org/bot{$this->bot_token}/getMe";

        try {
            $response = Http::get($url);
            $data = $response->json();

            if ($data['ok'] ?? false) {
                $this->bot_id = $data['result']['id'];
                $this->bot_first_name = $data['result']['first_name'];
                $this->save();
                return true;
            }

            return false;
        } catch (\Exception $e) {
            return false;
        }
    }

    // Send message via bot
    public function sendMessage($chatId, $text, $parseMode = 'HTML')
    {
        $url = "https://api.telegram.org/bot{$this->bot_token}/sendMessage";

        return Http::post($url, [
            'chat_id' => $chatId,
            'text' => $text,
            'parse_mode' => $parseMode,
        ]);
    }

    // Send photo via bot
    public function sendPhoto($chatId, $photoUrl, $caption = null)
    {
        $url = "https://api.telegram.org/bot{$this->bot_token}/sendPhoto";

        return Http::post($url, [
            'chat_id' => $chatId,
            'photo' => $photoUrl,
            'caption' => $caption,
            'parse_mode' => 'HTML',
        ]);
    }
}
```

#### `app/Models/TelegramPost.php`
```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TelegramPost extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'bot_id',
        'channel_username',
        'message_id',
        'content',
        'image_url',
        'hashtags',
        'status',
        'error_message',
        'published_at',
    ];

    protected $casts = [
        'hashtags' => 'array',
        'published_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function bot()
    {
        return $this->belongsTo(TelegramBot::class, 'bot_id');
    }
}
```

---

### 3. Controller

#### `app/Http/Controllers/Api/TelegramBotController.php`
```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TelegramBot;
use App\Models\TelegramPost;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Validator;

class TelegramBotController extends Controller
{
    /**
     * Get all connected bots for current user
     */
    public function index(Request $request)
    {
        $bots = TelegramBot::where('user_id', $request->user()->id)
            ->get()
            ->map(function ($bot) {
                return [
                    'id' => $bot->id,
                    'username' => $bot->bot_username,
                    'first_name' => $bot->bot_first_name,
                    'bot_id' => $bot->bot_id,
                    'chat_id' => $bot->chat_id,
                    'is_active' => $bot->is_active,
                    'connected_at' => $bot->created_at->toIso8601String(),
                ];
            });

        return response()->json([
            'success' => true,
            'bots' => $bots,
        ]);
    }

    /**
     * Connect a new Telegram bot
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'bot_token' => 'required|string',
            'bot_username' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();

        // Check subscription limits
        $currentBotCount = TelegramBot::where('user_id', $user->id)->count();
        $maxBots = $user->max_telegram_bots ?? 0;

        if ($currentBotCount >= $maxBots) {
            return response()->json([
                'success' => false,
                'message' => 'You have reached the maximum number of bots for your subscription tier',
            ], 403);
        }

        // Verify bot token
        $url = "https://api.telegram.org/bot{$request->bot_token}/getMe";

        try {
            $response = Http::timeout(10)->get($url);
            $data = $response->json();

            if (!($data['ok'] ?? false)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid bot token',
                ], 400);
            }

            $botInfo = $data['result'];

            // Create bot record
            $bot = TelegramBot::create([
                'user_id' => $user->id,
                'bot_token' => $request->bot_token,
                'bot_username' => $request->bot_username,
                'bot_first_name' => $botInfo['first_name'] ?? null,
                'bot_id' => $botInfo['id'],
                'is_active' => true,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Bot connected successfully',
                'bot' => [
                    'id' => $bot->id,
                    'username' => $bot->bot_username,
                    'first_name' => $bot->bot_first_name,
                ],
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to verify bot: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Disconnect a bot
     */
    public function destroy(Request $request, $id)
    {
        $bot = TelegramBot::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$bot) {
            return response()->json([
                'success' => false,
                'message' => 'Bot not found',
            ], 404);
        }

        $bot->delete();

        return response()->json([
            'success' => true,
            'message' => 'Bot disconnected successfully',
        ]);
    }

    /**
     * Publish content to Telegram channel
     */
    public function publish(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'channel_username' => 'required|string',
            'content' => 'required|string',
            'image_url' => 'nullable|url',
            'hashtags' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $bot = TelegramBot::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->where('is_active', true)
            ->first();

        if (!$bot) {
            return response()->json([
                'success' => false,
                'message' => 'Bot not found or inactive',
            ], 404);
        }

        // Prepare content
        $content = $request->content;
        if ($request->hashtags && is_array($request->hashtags)) {
            $hashtags = implode(' ', array_map(fn($tag) => '#' . $tag, $request->hashtags));
            $content .= "\n\n" . $hashtags;
        }

        // Create post record
        $post = TelegramPost::create([
            'user_id' => $request->user()->id,
            'bot_id' => $bot->id,
            'channel_username' => $request->channel_username,
            'content' => $content,
            'image_url' => $request->image_url,
            'hashtags' => $request->hashtags,
            'status' => 'pending',
        ]);

        try {
            $chatId = '@' . ltrim($request->channel_username, '@');

            // Send to Telegram
            if ($request->image_url) {
                $response = $bot->sendPhoto($chatId, $request->image_url, $content);
            } else {
                $response = $bot->sendMessage($chatId, $content);
            }

            $data = $response->json();

            if ($data['ok'] ?? false) {
                $post->update([
                    'status' => 'published',
                    'message_id' => $data['result']['message_id'] ?? null,
                    'published_at' => now(),
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Published successfully',
                    'data' => [
                        'post_id' => $post->id,
                        'message_id' => $data['result']['message_id'] ?? null,
                        'channel' => $request->channel_username,
                    ],
                ]);
            } else {
                $errorMsg = $data['description'] ?? 'Unknown error';
                $post->update([
                    'status' => 'failed',
                    'error_message' => $errorMsg,
                ]);

                return response()->json([
                    'success' => false,
                    'message' => 'Failed to publish: ' . $errorMsg,
                ], 400);
            }

        } catch (\Exception $e) {
            $post->update([
                'status' => 'failed',
                'error_message' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to publish: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get channel info
     */
    public function getChannelInfo(Request $request, $id, $username)
    {
        $bot = TelegramBot::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->where('is_active', true)
            ->first();

        if (!$bot) {
            return response()->json([
                'success' => false,
                'message' => 'Bot not found or inactive',
            ], 404);
        }

        $chatId = '@' . ltrim($username, '@');
        $url = "https://api.telegram.org/bot{$bot->bot_token}/getChat";

        try {
            $response = Http::post($url, ['chat_id' => $chatId]);
            $data = $response->json();

            if ($data['ok'] ?? false) {
                return response()->json([
                    'success' => true,
                    'channel' => $data['result'],
                ]);
            }

            return response()->json([
                'success' => false,
                'message' => $data['description'] ?? 'Failed to get channel info',
            ], 400);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to get channel info: ' . $e->getMessage(),
            ], 500);
        }
    }
}
```

---

### 4. Routes

#### `routes/api.php`
```php
use App\Http\Controllers\Api\TelegramBotController;

Route::middleware('auth:sanctum')->group(function () {
    // Telegram Bots Management
    Route::get('/telegram-bots', [TelegramBotController::class, 'index']);
    Route::post('/telegram-bots', [TelegramBotController::class, 'store']);
    Route::delete('/telegram-bots/{id}', [TelegramBotController::class, 'destroy']);

    // Telegram Publishing
    Route::post('/telegram-bots/{id}/publish', [TelegramBotController::class, 'publish']);
    Route::get('/telegram-bots/{id}/channel/{username}', [TelegramBotController::class, 'getChannelInfo']);
});
```

---

### 5. Update User Model

#### `app/Models/User.php`
أضف هذا للحسابات المربوطة:

```php
// في User Model
public function telegramBots()
{
    return $this->hasMany(TelegramBot::class);
}

public function getMaxTelegramBotsAttribute()
{
    switch ($this->tier) {
        case 'free':
            return 0;
        case 'individual':
            return 1;
        case 'business':
            return 3;
        default:
            return 0;
    }
}
```

---

### 6. Seeder (اختياري للتجربة)

#### `database/seeders/TelegramBotSeeder.php`
```php
<?php

namespace Database\Seeders;

use App\Models\TelegramBot;
use App\Models\User;
use Illuminate\Database\Seeder;

class TelegramBotSeeder extends Seeder
{
    public function run()
    {
        $user = User::first();

        if ($user) {
            TelegramBot::create([
                'user_id' => $user->id,
                'bot_token' => env('TELEGRAM_TEST_BOT_TOKEN', 'test_token'),
                'bot_username' => 'test_bot',
                'bot_first_name' => 'Test Bot',
                'is_active' => true,
            ]);
        }
    }
}
```

---

## الاختبار

### 1. اختبار ربط البوت
```bash
curl -X POST http://localhost:8000/api/telegram-bots \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "bot_token": "123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11",
    "bot_username": "my_bot"
  }'
```

### 2. اختبار النشر
```bash
curl -X POST http://localhost:8000/api/telegram-bots/1/publish \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "channel_username": "my_channel",
    "content": "هذا منشور تجريبي",
    "image_url": "https://example.com/image.jpg",
    "hashtags": ["test", "telegram"]
  }'
```

---

## الأمان

- ✅ Bot tokens محمية عبر `$hidden` في Model
- ✅ جميع Endpoints محمية بـ `auth:sanctum`
- ✅ التحقق من ملكية المستخدم للبوت
- ✅ Validation لجميع المدخلات
- ✅ Error handling شامل
- ✅ Rate limiting موصى به

---

## الخطوات التالية

1. [ ] إنشاء Migrations
2. [ ] إنشاء Models
3. [ ] إنشاء Controller
4. [ ] إضافة Routes
5. [ ] تحديث User Model
6. [ ] الاختبار
7. [ ] Deploy

---

تم إنشاؤه بواسطة Claude Code 🤖
