# 🚀 نظام النشر عبر Webhook - Laravel + Pabbly Connect

## كل الملفات جاهزة للنسخ المباشر

---

## 1️⃣ Migration - scheduled_posts

**المسار:** `database/migrations/2025_01_19_100000_create_scheduled_posts_table.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('scheduled_posts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');

            // Content
            $table->text('content_text');
            $table->json('media_urls')->nullable(); // Array of media URLs
            $table->json('platforms'); // Array: ['facebook', 'instagram', 'twitter']

            // Scheduling
            $table->timestamp('scheduled_at')->index();

            // Status tracking
            $table->enum('status', [
                'pending',      // Waiting to be sent
                'processing',   // Currently being sent
                'sent',         // Successfully sent to Pabbly
                'failed'        // Failed to send
            ])->default('pending')->index();

            // Error tracking
            $table->text('error_message')->nullable();
            $table->json('webhook_response')->nullable(); // Store Pabbly response

            // Retry mechanism
            $table->integer('attempts')->default(0);
            $table->timestamp('last_attempt_at')->nullable();

            // Metadata
            $table->timestamp('sent_at')->nullable();

            $table->timestamps();

            // Indexes for performance
            $table->index(['status', 'scheduled_at']);
            $table->index(['user_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('scheduled_posts');
    }
};
```

---

## 2️⃣ Model - ScheduledPost

**المسار:** `app/Models/ScheduledPost.php`

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class ScheduledPost extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'content_text',
        'media_urls',
        'platforms',
        'scheduled_at',
        'status',
        'error_message',
        'webhook_response',
        'attempts',
        'last_attempt_at',
        'sent_at',
    ];

    protected $casts = [
        'media_urls' => 'array',
        'platforms' => 'array',
        'webhook_response' => 'array',
        'scheduled_at' => 'datetime',
        'last_attempt_at' => 'datetime',
        'sent_at' => 'datetime',
        'attempts' => 'integer',
    ];

    /**
     * Relationships
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Scopes
     */
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeDue($query)
    {
        return $query->where('status', 'pending')
            ->where('scheduled_at', '<=', now());
    }

    public function scopeFailed($query)
    {
        return $query->where('status', 'failed');
    }

    /**
     * Helper methods
     */
    public function isDue(): bool
    {
        return $this->status === 'pending' &&
               $this->scheduled_at <= now();
    }

    public function canRetry(): bool
    {
        return $this->attempts < 3; // Max 3 attempts
    }

    public function markAsProcessing(): void
    {
        $this->update([
            'status' => 'processing',
            'attempts' => $this->attempts + 1,
            'last_attempt_at' => now(),
        ]);
    }

    public function markAsSent(array $response = []): void
    {
        $this->update([
            'status' => 'sent',
            'sent_at' => now(),
            'webhook_response' => $response,
            'error_message' => null,
        ]);
    }

    public function markAsFailed(string $error, array $response = []): void
    {
        $this->update([
            'status' => 'failed',
            'error_message' => $error,
            'webhook_response' => $response,
        ]);
    }
}
```

---

## 3️⃣ Service - WebhookPublisherService

**المسار:** `app/Services/WebhookPublisherService.php`

```php
<?php

namespace App\Services;

use App\Models\ScheduledPost;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class WebhookPublisherService
{
    protected string $webhookUrl;
    protected int $timeout = 30; // seconds
    protected int $maxRetries = 3;

    public function __construct()
    {
        $this->webhookUrl = config('services.pabbly.webhook_url');
    }

    /**
     * Send post to Pabbly Connect via webhook
     */
    public function publish(ScheduledPost $post): array
    {
        if (!$this->webhookUrl) {
            throw new \Exception('Webhook URL not configured');
        }

        $payload = $this->buildPayload($post);

        Log::info('Sending webhook to Pabbly', [
            'post_id' => $post->id,
            'webhook_url' => $this->webhookUrl,
        ]);

        try {
            $response = Http::timeout($this->timeout)
                ->retry($this->maxRetries, 100) // Retry 3 times with 100ms delay
                ->post($this->webhookUrl, $payload);

            if ($response->successful()) {
                Log::info('Webhook sent successfully', [
                    'post_id' => $post->id,
                    'status' => $response->status(),
                ]);

                return [
                    'success' => true,
                    'status_code' => $response->status(),
                    'response' => $response->json(),
                ];
            } else {
                $errorMessage = "Webhook failed with status {$response->status()}";

                Log::error('Webhook failed', [
                    'post_id' => $post->id,
                    'status' => $response->status(),
                    'response' => $response->body(),
                ]);

                return [
                    'success' => false,
                    'error' => $errorMessage,
                    'status_code' => $response->status(),
                    'response' => $response->body(),
                ];
            }

        } catch (\Illuminate\Http\Client\ConnectionException $e) {
            Log::error('Webhook connection error', [
                'post_id' => $post->id,
                'error' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'error' => 'Connection error: ' . $e->getMessage(),
            ];

        } catch (\Exception $e) {
            Log::error('Webhook exception', [
                'post_id' => $post->id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Build payload for Pabbly webhook
     */
    protected function buildPayload(ScheduledPost $post): array
    {
        return [
            'text' => $post->content_text,
            'media' => $post->media_urls ?? [],
            'platforms' => $post->platforms,
            'scheduled_at' => $post->scheduled_at->toIso8601String(),
            'user_name' => $post->user->name ?? '',
            'user_id' => $post->user_id,
            'post_id' => $post->id,
            'timestamp' => now()->toIso8601String(),
        ];
    }

    /**
     * Test webhook connection
     */
    public function testWebhook(): array
    {
        if (!$this->webhookUrl) {
            return [
                'success' => false,
                'error' => 'Webhook URL not configured',
            ];
        }

        try {
            $response = Http::timeout($this->timeout)
                ->post($this->webhookUrl, [
                    'test' => true,
                    'message' => 'Test webhook from Laravel',
                    'timestamp' => now()->toIso8601String(),
                ]);

            return [
                'success' => $response->successful(),
                'status_code' => $response->status(),
                'response' => $response->json(),
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Set custom webhook URL (useful for testing or per-user webhooks)
     */
    public function setWebhookUrl(string $url): self
    {
        $this->webhookUrl = $url;
        return $this;
    }
}
```

---

## 4️⃣ Job - PublishScheduledPostJob

**المسار:** `app/Jobs/PublishScheduledPostJob.php`

```php
<?php

namespace App\Jobs;

use App\Models\ScheduledPost;
use App\Services\WebhookPublisherService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class PublishScheduledPostJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $tries = 3; // Maximum 3 attempts
    public $timeout = 60; // 60 seconds timeout
    public $backoff = [60, 300, 900]; // 1min, 5min, 15min

    protected ScheduledPost $post;

    public function __construct(ScheduledPost $post)
    {
        $this->post = $post;
    }

    public function handle(WebhookPublisherService $webhookService): void
    {
        Log::info('Publishing scheduled post', [
            'post_id' => $this->post->id,
            'attempt' => $this->attempts(),
        ]);

        // Mark as processing
        $this->post->markAsProcessing();

        try {
            // Send webhook
            $result = $webhookService->publish($this->post);

            if ($result['success']) {
                // Mark as sent
                $this->post->markAsSent($result['response'] ?? []);

                Log::info('Post published successfully', [
                    'post_id' => $this->post->id,
                ]);

            } else {
                // Failed
                $errorMessage = $result['error'] ?? 'Unknown error';

                if ($this->post->canRetry() && $this->attempts() < $this->tries) {
                    // Will retry
                    Log::warning('Post publish failed, will retry', [
                        'post_id' => $this->post->id,
                        'attempt' => $this->attempts(),
                        'error' => $errorMessage,
                    ]);

                    // Keep status as pending for retry
                    $this->post->update(['status' => 'pending']);

                    // Re-throw to trigger retry
                    throw new \Exception($errorMessage);

                } else {
                    // Max retries reached or can't retry
                    $this->post->markAsFailed($errorMessage, $result);

                    Log::error('Post publish failed permanently', [
                        'post_id' => $this->post->id,
                        'error' => $errorMessage,
                    ]);
                }
            }

        } catch (\Exception $e) {
            Log::error('Exception during post publish', [
                'post_id' => $this->post->id,
                'error' => $e->getMessage(),
            ]);

            if ($this->attempts() >= $this->tries) {
                // Max attempts reached
                $this->fail($e);
            } else {
                // Will retry
                $this->post->update(['status' => 'pending']);
                throw $e;
            }
        }
    }

    public function failed(\Throwable $exception): void
    {
        Log::error('Job failed permanently', [
            'post_id' => $this->post->id,
            'error' => $exception->getMessage(),
        ]);

        $this->post->markAsFailed(
            'Job failed after ' . $this->tries . ' attempts: ' . $exception->getMessage()
        );
    }
}
```

---

## 5️⃣ Controller - ScheduledPostController

**المسار:** `app/Http/Controllers/Api/ScheduledPostController.php`

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ScheduledPost;
use App\Jobs\PublishScheduledPostJob;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ScheduledPostController extends Controller
{
    /**
     * Get all scheduled posts for authenticated user
     */
    public function index(Request $request)
    {
        $posts = ScheduledPost::where('user_id', $request->user()->id)
            ->when($request->has('status'), function ($q) use ($request) {
                $q->where('status', $request->status);
            })
            ->orderBy('scheduled_at', 'desc')
            ->paginate($request->get('per_page', 20));

        return response()->json([
            'success' => true,
            'posts' => $posts,
        ]);
    }

    /**
     * Store a new scheduled post
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'content_text' => 'required|string|max:5000',
            'media_urls' => 'nullable|array',
            'media_urls.*' => 'url',
            'platforms' => 'required|array|min:1',
            'platforms.*' => 'string|in:facebook,instagram,twitter,linkedin,tiktok,youtube,pinterest',
            'scheduled_at' => 'required|date|after:now',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $post = ScheduledPost::create([
            'user_id' => $request->user()->id,
            'content_text' => $request->content_text,
            'media_urls' => $request->media_urls,
            'platforms' => $request->platforms,
            'scheduled_at' => $request->scheduled_at,
            'status' => 'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Post scheduled successfully',
            'post' => $post,
        ], 201);
    }

    /**
     * Get a specific scheduled post
     */
    public function show(Request $request, int $id)
    {
        $post = ScheduledPost::where('user_id', $request->user()->id)
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'post' => $post,
        ]);
    }

    /**
     * Update a scheduled post
     */
    public function update(Request $request, int $id)
    {
        $post = ScheduledPost::where('user_id', $request->user()->id)
            ->findOrFail($id);

        // Can only update pending posts
        if ($post->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Cannot update post with status: ' . $post->status,
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'content_text' => 'sometimes|string|max:5000',
            'media_urls' => 'sometimes|array',
            'platforms' => 'sometimes|array|min:1',
            'scheduled_at' => 'sometimes|date|after:now',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $post->update($request->only([
            'content_text',
            'media_urls',
            'platforms',
            'scheduled_at',
        ]));

        return response()->json([
            'success' => true,
            'message' => 'Post updated successfully',
            'post' => $post->fresh(),
        ]);
    }

    /**
     * Delete a scheduled post
     */
    public function destroy(Request $request, int $id)
    {
        $post = ScheduledPost::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $post->delete();

        return response()->json([
            'success' => true,
            'message' => 'Post deleted successfully',
        ]);
    }

    /**
     * Send post immediately (bypass scheduling)
     */
    public function sendNow(Request $request, int $id)
    {
        $post = ScheduledPost::where('user_id', $request->user()->id)
            ->findOrFail($id);

        if (!in_array($post->status, ['pending', 'failed'])) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot send post with status: ' . $post->status,
            ], 400);
        }

        // Dispatch job immediately
        PublishScheduledPostJob::dispatch($post);

        return response()->json([
            'success' => true,
            'message' => 'Post queued for immediate sending',
            'post' => $post->fresh(),
        ]);
    }

    /**
     * Retry a failed post
     */
    public function retry(Request $request, int $id)
    {
        $post = ScheduledPost::where('user_id', $request->user()->id)
            ->findOrFail($id);

        if ($post->status !== 'failed') {
            return response()->json([
                'success' => false,
                'message' => 'Only failed posts can be retried',
            ], 400);
        }

        if (!$post->canRetry()) {
            return response()->json([
                'success' => false,
                'message' => 'Maximum retry attempts reached',
            ], 400);
        }

        // Reset to pending and dispatch
        $post->update(['status' => 'pending']);
        PublishScheduledPostJob::dispatch($post);

        return response()->json([
            'success' => true,
            'message' => 'Post queued for retry',
            'post' => $post->fresh(),
        ]);
    }

    /**
     * Dispatch all due scheduled posts (called by scheduler)
     */
    public function dispatchScheduled()
    {
        $duePosts = ScheduledPost::due()->get();

        $dispatched = 0;
        foreach ($duePosts as $post) {
            PublishScheduledPostJob::dispatch($post);
            $dispatched++;
        }

        return response()->json([
            'success' => true,
            'message' => "Dispatched {$dispatched} scheduled posts",
            'count' => $dispatched,
        ]);
    }
}
```

---

## 6️⃣ Kernel.php - Task Scheduling

**المسار:** `app/Console/Kernel.php`

```php
<?php

namespace App\Console;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;
use App\Models\ScheduledPost;
use App\Jobs\PublishScheduledPostJob;

class Kernel extends ConsoleKernel
{
    protected function schedule(Schedule $schedule): void
    {
        // Check for due posts every minute
        $schedule->call(function () {
            $duePosts = ScheduledPost::due()->get();

            foreach ($duePosts as $post) {
                PublishScheduledPostJob::dispatch($post);
            }

            if ($duePosts->count() > 0) {
                \Log::info('Dispatched scheduled posts', [
                    'count' => $duePosts->count(),
                    'post_ids' => $duePosts->pluck('id')->toArray(),
                ]);
            }

        })->everyMinute()->name('dispatch-scheduled-posts');

        // Cleanup old sent posts (optional - keep for 30 days)
        $schedule->call(function () {
            $deleted = ScheduledPost::where('status', 'sent')
                ->where('sent_at', '<', now()->subDays(30))
                ->delete();

            if ($deleted > 0) {
                \Log::info('Cleaned up old posts', ['count' => $deleted]);
            }

        })->daily()->name('cleanup-old-posts');
    }

    protected function commands(): void
    {
        $this->load(__DIR__.'/Commands');

        require base_path('routes/console.php');
    }
}
```

---

## 7️⃣ Routes - API

**المسار:** `routes/api.php`

```php
use App\Http\Controllers\Api\ScheduledPostController;

Route::middleware(['auth:sanctum'])->group(function () {

    // Scheduled Posts
    Route::get('scheduled-posts', [ScheduledPostController::class, 'index']);
    Route::post('scheduled-posts', [ScheduledPostController::class, 'store']);
    Route::get('scheduled-posts/{id}', [ScheduledPostController::class, 'show']);
    Route::put('scheduled-posts/{id}', [ScheduledPostController::class, 'update']);
    Route::delete('scheduled-posts/{id}', [ScheduledPostController::class, 'destroy']);

    // Actions
    Route::post('scheduled-posts/{id}/send-now', [ScheduledPostController::class, 'sendNow']);
    Route::post('scheduled-posts/{id}/retry', [ScheduledPostController::class, 'retry']);

    // Admin/Internal
    Route::post('scheduled-posts/dispatch', [ScheduledPostController::class, 'dispatchScheduled']);
});
```

---

## 8️⃣ Configuration

### config/services.php
```php
return [
    // ... existing services

    'pabbly' => [
        'webhook_url' => env('PABBLY_WEBHOOK_URL'),
    ],
];
```

### .env
```env
# Pabbly Connect Webhook
PABBLY_WEBHOOK_URL="https://connect.pabbly.com/workflow/sendwebhookdata/YOUR_WEBHOOK_ID"

# Queue Configuration
QUEUE_CONNECTION=database
# For production, use Redis:
# QUEUE_CONNECTION=redis
```

---

## 9️⃣ أمثلة API Requests

### 1. Schedule a Post
```bash
POST /api/scheduled-posts
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "content_text": "🚀 إطلاق منتجنا الجديد! تابعونا للمزيد...",
  "media_urls": [
    "https://example.com/product-image.jpg",
    "https://example.com/product-video.mp4"
  ],
  "platforms": ["facebook", "instagram", "twitter"],
  "scheduled_at": "2025-01-20T10:00:00Z"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Post scheduled successfully",
  "post": {
    "id": 1,
    "user_id": 1,
    "content_text": "🚀 إطلاق منتجنا الجديد! تابعونا للمزيد...",
    "media_urls": [
      "https://example.com/product-image.jpg",
      "https://example.com/product-video.mp4"
    ],
    "platforms": ["facebook", "instagram", "twitter"],
    "scheduled_at": "2025-01-20T10:00:00.000000Z",
    "status": "pending",
    "attempts": 0,
    "created_at": "2025-01-19T12:00:00.000000Z"
  }
}
```

### 2. Send Post Now (Immediate)
```bash
POST /api/scheduled-posts/1/send-now
Authorization: Bearer YOUR_TOKEN
```

**Response:**
```json
{
  "success": true,
  "message": "Post queued for immediate sending",
  "post": {
    "id": 1,
    "status": "processing",
    "attempts": 1,
    "last_attempt_at": "2025-01-19T12:05:00.000000Z"
  }
}
```

### 3. Get All Scheduled Posts
```bash
GET /api/scheduled-posts?status=pending
Authorization: Bearer YOUR_TOKEN
```

**Response:**
```json
{
  "success": true,
  "posts": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "content_text": "...",
        "platforms": ["facebook", "instagram"],
        "scheduled_at": "2025-01-20T10:00:00Z",
        "status": "pending"
      }
    ],
    "per_page": 20,
    "total": 1
  }
}
```

### 4. Retry Failed Post
```bash
POST /api/scheduled-posts/1/retry
Authorization: Bearer YOUR_TOKEN
```

**Response:**
```json
{
  "success": true,
  "message": "Post queued for retry",
  "post": {
    "id": 1,
    "status": "pending",
    "attempts": 2
  }
}
```

---

## 🔟 Pabbly Connect Webhook Payload

عندما يُرسل Laravel الـ webhook، Pabbly سيستقبل:

```json
{
  "text": "🚀 إطلاق منتجنا الجديد! تابعونا للمزيد...",
  "media": [
    "https://example.com/product-image.jpg",
    "https://example.com/product-video.mp4"
  ],
  "platforms": ["facebook", "instagram", "twitter"],
  "scheduled_at": "2025-01-20T10:00:00+00:00",
  "user_name": "John Doe",
  "user_id": 1,
  "post_id": 1,
  "timestamp": "2025-01-20T10:00:05+00:00"
}
```

---

## 1️⃣1️⃣ خطوات التنفيذ

### 1. نسخ الملفات
```bash
# في مشروع Laravel الخاص بك
cp migration -> database/migrations/
cp Model -> app/Models/
cp Service -> app/Services/
cp Job -> app/Jobs/
cp Controller -> app/Http/Controllers/Api/
```

### 2. تشغيل Migration
```bash
php artisan migrate
```

### 3. إنشاء Queue Table
```bash
php artisan queue:table
php artisan migrate
```

### 4. إعداد .env
```env
PABBLY_WEBHOOK_URL="YOUR_PABBLY_WEBHOOK_URL_HERE"
QUEUE_CONNECTION=database
```

### 5. تشغيل Queue Worker
```bash
# Development
php artisan queue:work

# Production (في background)
nohup php artisan queue:work --sleep=3 --tries=3 &
```

### 6. تفعيل Scheduler
```bash
# أضف إلى crontab
* * * * * cd /path-to-project && php artisan schedule:run >> /dev/null 2>&1
```

### 7. اختبار النظام
```bash
# Test webhook connection
php artisan tinker

>>> $service = app(\App\Services\WebhookPublisherService::class);
>>> $service->testWebhook();
```

---

## 1️⃣2️⃣ Pabbly Connect Setup

### في Pabbly Connect:

1. **Create New Workflow**
2. **Trigger:** Webhook (Catch Hook)
3. **Copy Webhook URL** → ضعه في `.env` كـ `PABBLY_WEBHOOK_URL`
4. **Add Actions:**
   - Facebook: Create Post
   - Instagram: Create Post
   - Twitter: Create Post
5. **Map Fields:**
   - Content: `{{text}}`
   - Media: `{{media}}`
   - Use **Router** لتوجيه لكل منصة حسب `{{platforms}}`

---

## 1️⃣3️⃣ Testing

### Create Test Post
```bash
curl -X POST http://localhost:8000/api/scheduled-posts \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content_text": "Test post 🎉",
    "platforms": ["facebook", "twitter"],
    "scheduled_at": "2025-01-20T15:00:00Z"
  }'
```

### Send Immediately
```bash
curl -X POST http://localhost:8000/api/scheduled-posts/1/send-now \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Check Logs
```bash
tail -f storage/logs/laravel.log | grep -E "webhook|scheduled"
```

---

## 1️⃣4️⃣ Monitoring & Debugging

### Check Queue Status
```bash
# See pending jobs
php artisan queue:work --once

# See failed jobs
php artisan queue:failed
```

### Retry Failed Jobs
```bash
# Retry all
php artisan queue:retry all

# Retry specific
php artisan queue:retry JOB_ID
```

### Monitor Scheduled Posts
```sql
-- Posts pending
SELECT COUNT(*) FROM scheduled_posts WHERE status = 'pending';

-- Posts sent today
SELECT COUNT(*) FROM scheduled_posts
WHERE status = 'sent' AND DATE(sent_at) = CURDATE();

-- Failed posts
SELECT * FROM scheduled_posts WHERE status = 'failed';
```

---

## ✅ Checklist

- [ ] Migration created and run
- [ ] Model created
- [ ] Service created
- [ ] Job created
- [ ] Controller created
- [ ] Routes added
- [ ] Config updated
- [ ] .env configured with Pabbly webhook URL
- [ ] Queue worker running
- [ ] Scheduler cron job added
- [ ] Pabbly workflow created
- [ ] Test post sent successfully

---

**🎉 النظام جاهز! كل ملف يمكن نسخه مباشرة إلى مشروع Laravel.**
