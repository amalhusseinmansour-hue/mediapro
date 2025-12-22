# 🤖 دليل دمج Ultimate Media Agent مع MediaPro Social

## نظرة عامة

هذا الدليل يشرح كيفية دمج **Ultimate Media Agent** (n8n workflow) مع منصة **mediaprosocial.io**.

---

## 📋 المتطلبات الأساسية

### APIs المطلوبة:
- ✅ **OpenAI API** - للذكاء الاصطناعي (موجود)
- ✅ **Google Drive API** - لإدارة الملفات
- ✅ **Gmail API** - للبريد الإلكتروني
- ✅ **Google Calendar API** - للمواعيد
- ✅ **Telegram Bot API** - للتواصل
- ✅ **Airtable API** - لإدارة جهات الاتصال
- ✅ **Tavily API** - للبحث على الإنترنت
- ✅ **OpenWeatherMap API** - للطقس

### APIs للنشر على السوشيال ميديا:
- Instagram API
- TikTok API
- YouTube API

---

## 🚀 الخطة الأولى: استيراد الـ Workflow

### الخطوة 1: استيراد في n8n

```bash
# 1. تأكد أن n8n يعمل
n8n start

# 2. افتح n8n
http://localhost:5678

# 3. اذهب إلى: Workflows → Import from File

# 4. اختر الملف JSON الذي شاركته
```

### الخطوة 2: إعداد Credentials

في n8n، ستحتاج لإعداد:

#### 1. Telegram Bot
```
1. تحدث مع @BotFather على Telegram
2. أنشئ bot جديد: /newbot
3. احفظ الـ API Token
4. في n8n → Credentials → Add Telegram API
```

#### 2. Google APIs
```
1. Google Cloud Console: https://console.cloud.google.com/
2. أنشئ مشروع جديد
3. فعّل APIs:
   - Google Drive API
   - Gmail API
   - Google Calendar API
4. أنشئ OAuth 2.0 credentials
5. أضف redirect URL: http://localhost:5678/rest/oauth2-credential/callback
6. في n8n → أضف Google credentials
```

#### 3. OpenAI API
```
1. https://platform.openai.com/api-keys
2. أنشئ API key جديد
3. أضفه في n8n credentials
```

#### 4. Airtable (للcontacts)
```
1. https://airtable.com/create/tokens
2. أنشئ Personal Access Token
3. أعطه صلاحيات: data.records:read, data.records:write
4. أضفه في n8n
```

#### 5. Tavily (للبحث)
```
1. https://tavily.com/
2. سجل حساب جديد
3. احصل على API key
4. أضفه في n8n
```

---

## 🔧 الخطة الثانية: التكامل مع Laravel

### 1. إنشاء TelegramService في Laravel

```php
<?php
// backend/app/Services/TelegramService.php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class TelegramService
{
    protected string $botToken;
    protected string $baseUrl;

    public function __construct()
    {
        $this->botToken = config('services.telegram.bot_token');
        $this->baseUrl = "https://api.telegram.org/bot{$this->botToken}";
    }

    /**
     * Send message to Telegram chat
     */
    public function sendMessage(string $chatId, string $text, array $options = []): array
    {
        try {
            $payload = array_merge([
                'chat_id' => $chatId,
                'text' => $text,
                'parse_mode' => 'HTML',
            ], $options);

            $response = Http::post("{$this->baseUrl}/sendMessage", $payload);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json(),
                ];
            }

            return [
                'success' => false,
                'error' => $response->json('description', 'Failed to send message'),
            ];
        } catch (\Exception $e) {
            Log::error('Telegram send message error', [
                'error' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Send photo to Telegram chat
     */
    public function sendPhoto(string $chatId, string $photo, ?string $caption = null): array
    {
        try {
            $payload = [
                'chat_id' => $chatId,
                'photo' => $photo,
            ];

            if ($caption) {
                $payload['caption'] = $caption;
            }

            $response = Http::post("{$this->baseUrl}/sendPhoto", $payload);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json(),
                ];
            }

            return [
                'success' => false,
                'error' => $response->json('description', 'Failed to send photo'),
            ];
        } catch (\Exception $e) {
            Log::error('Telegram send photo error', [
                'error' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Send video to Telegram chat
     */
    public function sendVideo(string $chatId, string $video, ?string $caption = null): array
    {
        try {
            $payload = [
                'chat_id' => $chatId,
                'video' => $video,
            ];

            if ($caption) {
                $payload['caption'] = $caption;
            }

            $response = Http::post("{$this->baseUrl}/sendVideo", $payload);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json(),
                ];
            }

            return [
                'success' => false,
                'error' => $response->json('description', 'Failed to send video'),
            ];
        } catch (\Exception $e) {
            Log::error('Telegram send video error', [
                'error' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Set webhook for receiving updates
     */
    public function setWebhook(string $url): array
    {
        try {
            $response = Http::post("{$this->baseUrl}/setWebhook", [
                'url' => $url,
            ]);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json(),
                ];
            }

            return [
                'success' => false,
                'error' => $response->json('description', 'Failed to set webhook'),
            ];
        } catch (\Exception $e) {
            Log::error('Telegram set webhook error', [
                'error' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Get webhook info
     */
    public function getWebhookInfo(): ?array
    {
        try {
            $response = Http::get("{$this->baseUrl}/getWebhookInfo");

            if ($response->successful()) {
                return $response->json('result');
            }

            return null;
        } catch (\Exception $e) {
            Log::error('Telegram get webhook info error', [
                'error' => $e->getMessage(),
            ]);

            return null;
        }
    }
}
```

### 2. إنشاء MediaAgentService

```php
<?php
// backend/app/Services/MediaAgentService.php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class MediaAgentService
{
    protected N8nService $n8nService;
    protected TelegramService $telegramService;

    public function __construct()
    {
        $this->n8nService = app(N8nService::class);
        $this->telegramService = app(TelegramService::class);
    }

    /**
     * Send command to Ultimate Media Agent via n8n
     */
    public function executeCommand(string $command, array $context = []): array
    {
        // يمكن توجيه الأوامر عبر n8n webhook
        return $this->n8nService->triggerWebhook('ultimate-media-agent', [
            'command' => $command,
            'context' => $context,
            'user_id' => auth()->id(),
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    /**
     * Create image using the agent
     */
    public function createImage(string $prompt, string $imageName): array
    {
        return $this->executeCommand('create image', [
            'prompt' => $prompt,
            'image_name' => $imageName,
        ]);
    }

    /**
     * Edit image using the agent
     */
    public function editImage(string $fileId, string $imageName, string $editRequest): array
    {
        return $this->executeCommand('edit image', [
            'file_id' => $fileId,
            'image_name' => $imageName,
            'edit_request' => $editRequest,
        ]);
    }

    /**
     * Create video using the agent
     */
    public function createVideo(string $prompt, string $title, string $aspectRatio = '9:16'): array
    {
        return $this->executeCommand('create video', [
            'prompt' => $prompt,
            'title' => $title,
            'aspect_ratio' => $aspectRatio,
        ]);
    }

    /**
     * Convert image to video
     */
    public function imageToVideo(string $fileId, string $imageName, string $videoPrompt): array
    {
        return $this->executeCommand('image to video', [
            'file_id' => $fileId,
            'image_name' => $imageName,
            'video_prompt' => $videoPrompt,
        ]);
    }

    /**
     * Post to Instagram
     */
    public function postToInstagram(string $fileId, string $caption): array
    {
        return $this->executeCommand('post to instagram', [
            'file_id' => $fileId,
            'caption' => $caption,
        ]);
    }

    /**
     * Post to TikTok
     */
    public function postToTikTok(string $fileId, string $caption): array
    {
        return $this->executeCommand('post to tiktok', [
            'file_id' => $fileId,
            'caption' => $caption,
        ]);
    }

    /**
     * Post to YouTube
     */
    public function postToYouTube(string $fileId, string $title): array
    {
        return $this->executeCommand('post to youtube', [
            'file_id' => $fileId,
            'title' => $title,
        ]);
    }

    /**
     * Send email via agent
     */
    public function sendEmail(string $to, string $subject, string $message): array
    {
        return $this->executeCommand('send email', [
            'to' => $to,
            'subject' => $subject,
            'message' => $message,
        ]);
    }

    /**
     * Create calendar event via agent
     */
    public function createCalendarEvent(string $title, string $start, string $end, ?array $attendees = null): array
    {
        return $this->executeCommand('create calendar event', [
            'title' => $title,
            'start' => $start,
            'end' => $end,
            'attendees' => $attendees,
        ]);
    }

    /**
     * Search web via agent
     */
    public function searchWeb(string $query): array
    {
        return $this->executeCommand('search web', [
            'query' => $query,
        ]);
    }

    /**
     * Get weather via agent
     */
    public function getWeather(string $city): array
    {
        return $this->executeCommand('get weather', [
            'city' => $city,
        ]);
    }
}
```

### 3. إضافة Configuration

```php
<?php
// backend/config/services.php

return [
    // ... existing services

    'telegram' => [
        'bot_token' => env('TELEGRAM_BOT_TOKEN'),
        'webhook_url' => env('TELEGRAM_WEBHOOK_URL'),
    ],

    'airtable' => [
        'api_token' => env('AIRTABLE_API_TOKEN'),
        'base_id' => env('AIRTABLE_BASE_ID'),
        'contacts_table' => env('AIRTABLE_CONTACTS_TABLE', 'contacts'),
    ],

    'tavily' => [
        'api_key' => env('TAVILY_API_KEY'),
    ],

    'openweathermap' => [
        'api_key' => env('OPENWEATHERMAP_API_KEY'),
    ],
];
```

### 4. إضافة المتغيرات البيئية

```env
# Telegram Bot
TELEGRAM_BOT_TOKEN=your_telegram_bot_token
TELEGRAM_WEBHOOK_URL=https://mediaprosocial.io/api/webhooks/telegram

# Airtable
AIRTABLE_API_TOKEN=your_airtable_token
AIRTABLE_BASE_ID=your_base_id
AIRTABLE_CONTACTS_TABLE=contacts

# Tavily (Web Search)
TAVILY_API_KEY=your_tavily_api_key

# OpenWeatherMap
OPENWEATHERMAP_API_KEY=your_openweathermap_key

# Google APIs (already configured in Google Cloud Console)
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
```

---

## 🎯 السيناريوهات المقترحة

### السيناريو 1: إنشاء محتوى تلقائي من Telegram

```php
// في Controller
use App\Services\MediaAgentService;

public function createContentViaTelegram(Request $request)
{
    $agentService = app(MediaAgentService::class);

    // إنشاء صورة
    $result = $agentService->createImage(
        'A professional social media post about digital marketing',
        'marketing_post_' . now()->format('YmdHis')
    );

    if ($result['success']) {
        // النشر على المنصات
        $fileId = $result['data']['file_id'];

        $agentService->postToInstagram($fileId, 'Check out our new marketing tips! 🚀');
        $agentService->postToTikTok($fileId, 'Marketing tips you need to know!');
    }

    return response()->json($result);
}
```

### السيناريو 2: إدارة حملة كاملة

```php
public function manageCampaign(Request $request)
{
    $agentService = app(MediaAgentService::class);

    // 1. إنشاء محتوى
    $image = $agentService->createImage(
        $request->input('prompt'),
        $request->input('name')
    );

    // 2. تحويل لفيديو
    $video = $agentService->imageToVideo(
        $image['data']['file_id'],
        $request->input('name'),
        'Engaging animated version'
    );

    // 3. النشر على جميع المنصات
    $platforms = ['instagram', 'tiktok', 'youtube'];
    $results = [];

    foreach ($platforms as $platform) {
        $method = 'postTo' . ucfirst($platform);
        $results[$platform] = $agentService->$method(
            $video['data']['file_id'],
            $request->input('caption')
        );
    }

    // 4. إرسال email للإشعار
    $agentService->sendEmail(
        auth()->user()->email,
        'Campaign Published Successfully',
        'Your campaign has been published on all platforms!'
    );

    return response()->json([
        'success' => true,
        'image' => $image,
        'video' => $video,
        'posts' => $results,
    ]);
}
```

### السيناريو 3: استخدام Telegram Bot مباشرة

```php
// يمكن للمستخدمين التواصل مع الـ bot مباشرة:

// 1. المستخدم يرسل: "Create an image of a sunset over mountains"
// 2. الـ agent يُنشئ الصورة
// 3. يرسل الصورة للمستخدم عبر Telegram
// 4. المستخدم يرد: "Post this to Instagram with caption: Beautiful sunset"
// 5. الـ agent ينشر على Instagram
// 6. يرسل تأكيد للمستخدم
```

---

## 📱 إنشاء Telegram Bot للمستخدمين

### الخطوة 1: إنشاء Bot

```bash
# تحدث مع @BotFather على Telegram:
/newbot
# اسم البوت: MediaPro Social Bot
# username: mediaprosocial_bot

# احفظ الـ token الذي يعطيك إياه
```

### الخطوة 2: إعداد Webhook في Laravel

```php
<?php
// backend/app/Http/Controllers/Api/TelegramWebhookController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\MediaAgentService;
use App\Services\TelegramService;
use Illuminate\Http\Request;

class TelegramWebhookController extends Controller
{
    protected MediaAgentService $agentService;
    protected TelegramService $telegramService;

    public function __construct()
    {
        $this->agentService = app(MediaAgentService::class);
        $this->telegramService = app(TelegramService::class);
    }

    public function handle(Request $request)
    {
        $update = $request->all();

        if (isset($update['message'])) {
            $message = $update['message'];
            $chatId = $message['chat']['id'];
            $text = $message['text'] ?? '';

            // معالجة الأوامر
            if (str_starts_with($text, '/create_image')) {
                $this->handleCreateImage($chatId, $text);
            } elseif (str_starts_with($text, '/create_video')) {
                $this->handleCreateVideo($chatId, $text);
            } elseif (str_starts_with($text, '/post')) {
                $this->handlePost($chatId, $text);
            } else {
                // إرسال للـ n8n agent لمعالجة أكثر تعقيداً
                $this->forwardToAgent($chatId, $text);
            }
        }

        return response()->json(['ok' => true]);
    }

    protected function handleCreateImage(string $chatId, string $command)
    {
        $this->telegramService->sendMessage($chatId, '🎨 Creating your image...');

        // استخراج الـ prompt من الأمر
        $prompt = trim(str_replace('/create_image', '', $command));

        $result = $this->agentService->createImage($prompt, 'image_' . time());

        if ($result['success']) {
            $this->telegramService->sendPhoto(
                $chatId,
                $result['data']['image_url'],
                'Here is your image! ✨'
            );
        } else {
            $this->telegramService->sendMessage(
                $chatId,
                '❌ Failed to create image: ' . $result['error']
            );
        }
    }

    protected function handleCreateVideo(string $chatId, string $command)
    {
        $this->telegramService->sendMessage($chatId, '🎥 Creating your video...');

        $prompt = trim(str_replace('/create_video', '', $command));

        $result = $this->agentService->createVideo($prompt, 'video_' . time());

        if ($result['success']) {
            $this->telegramService->sendVideo(
                $chatId,
                $result['data']['video_url'],
                'Here is your video! 🎬'
            );
        } else {
            $this->telegramService->sendMessage(
                $chatId,
                '❌ Failed to create video: ' . $result['error']
            );
        }
    }

    protected function forwardToAgent(string $chatId, string $text)
    {
        // إرسال للـ n8n Ultimate Media Agent
        $result = $this->agentService->executeCommand($text, [
            'chat_id' => $chatId,
            'platform' => 'telegram',
        ]);

        // الـ agent سيرد تلقائياً عبر Telegram
    }
}
```

### الخطوة 3: إضافة Route

```php
<?php
// backend/routes/api.php

Route::post('/webhooks/telegram', [TelegramWebhookController::class, 'handle']);
```

### الخطوة 4: تفعيل Webhook

```php
// artisan command
php artisan tinker

>>> app(\App\Services\TelegramService::class)->setWebhook('https://mediaprosocial.io/api/webhooks/telegram');
```

---

## 🎨 إنشاء Filament Resource للإدارة

```php
<?php
// backend/app/Filament/Resources/MediaAgentResource.php

namespace App\Filament\Resources;

use App\Filament\Resources\MediaAgentResource\Pages;
use App\Services\MediaAgentService;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class MediaAgentResource extends Resource
{
    protected static ?string $navigationIcon = 'heroicon-o-cpu-chip';
    protected static ?string $navigationLabel = 'AI Media Agent';
    protected static ?string $navigationGroup = 'AI Tools';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('action')
                    ->label('Action Type')
                    ->options([
                        'create_image' => 'Create Image',
                        'edit_image' => 'Edit Image',
                        'create_video' => 'Create Video',
                        'image_to_video' => 'Image to Video',
                        'post_instagram' => 'Post to Instagram',
                        'post_tiktok' => 'Post to TikTok',
                        'post_youtube' => 'Post to YouTube',
                    ])
                    ->required(),

                Forms\Components\Textarea::make('prompt')
                    ->label('Prompt / Description')
                    ->required()
                    ->rows(3),

                Forms\Components\TextInput::make('name')
                    ->label('Name / Title')
                    ->required(),

                Forms\Components\Select::make('aspect_ratio')
                    ->label('Aspect Ratio')
                    ->options([
                        '16:9' => '16:9 (Landscape)',
                        '9:16' => '9:16 (Portrait)',
                        '1:1' => '1:1 (Square)',
                    ])
                    ->default('9:16')
                    ->visible(fn ($get) => in_array($get('action'), ['create_video', 'image_to_video'])),

                Forms\Components\TextInput::make('file_id')
                    ->label('Google Drive File ID')
                    ->visible(fn ($get) => in_array($get('action'), ['edit_image', 'image_to_video', 'post_instagram', 'post_tiktok', 'post_youtube'])),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('action')
                    ->label('Action')
                    ->badge(),

                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'completed' => 'success',
                        'processing' => 'warning',
                        'failed' => 'danger',
                        default => 'gray',
                    }),

                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListMediaAgents::route('/'),
            'create' => Pages\CreateMediaAgent::route('/create'),
        ];
    }
}
```

---

## 🔥 الفوائد من هذا التكامل

### 1. **أتمتة كاملة**
- إنشاء محتوى AI تلقائياً
- نشر على منصات متعددة
- إدارة جدولة تلقائية

### 2. **تجربة Telegram**
- المستخدمون يمكنهم التحكم من Telegram
- إرسال أوامر بسيطة
- استقبال النتائج فوراً

### 3. **تكامل متعدد**
- Google Drive للتخزين
- Gmail للإشعارات
- Calendar للجدولة
- Airtable للcontacts

### 4. **ذكاء اصطناعي متقدم**
- إنشاء صور احترافية
- تعديل صور موجودة
- إنشاء فيديوهات
- تحويل صور لفيديوهات

---

## 📊 الخطوات التالية

1. ✅ استيراد الـ workflow في n8n
2. ✅ إعداد جميع الـ credentials
3. ✅ إنشاء Telegram bot
4. ✅ دمج Services في Laravel
5. ✅ اختبار كل ميزة
6. ✅ إنشاء واجهات Filament
7. ✅ توثيق الاستخدام للمستخدمين

---

**جاهز للبدء؟** 🚀
