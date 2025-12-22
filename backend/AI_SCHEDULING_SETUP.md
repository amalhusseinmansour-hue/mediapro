# AI Scheduling Setup Guide

## نظام الجدولة الذكية للمنشورات باستخدام الذكاء الاصطناعي

هذا النظام يوفر جدولة تلقائية وذكية للمنشورات على جميع المنصات باستخدام AI لتحديد:
- أفضل أوقات النشر لكل منصة
- أيام الأسبوع الأمثل
- التوزيع الذكي للمنشورات
- توليد المحتوى والصور تلقائياً

---

## المميزات الأساسية

### 1. الجدولة الذكية
- تحليل AI للمحتوى لتحديد أفضل وقت للنشر
- تحليل البيانات التاريخية للمستخدم
- أوقات افتراضية مثالية لكل منصة
- تعديل تلقائي للأوقات بناءً على نوع المحتوى

### 2. التوليد التلقائي
- توليد محتوى من موضوع (topic)
- توليد صور AI تلقائياً
- توليد هاشتاجات ذكية
- جدولة تلقائية بعد التوليد

### 3. الجدولة المتعددة
- جدولة عدة منشورات دفعة واحدة
- توزيع ذكي على عدة أيام
- تجنب التضارب في الأوقات
- إدارة سهلة للمنشورات المجدولة

---

## التثبيت والإعداد

### 1. نسخ الملفات

الملفات المطلوبة موجودة بالفعل على السيرفر:
- `app/Services/AISchedulingService.php` ✅
- `app/Http/Controllers/Api/AISchedulingController.php` ✅
- API Routes في `routes/api.php` ✅

### 2. إنشاء Database Migration

قم بإنشاء جدول `auto_scheduled_posts` إذا لم يكن موجوداً:

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        if (!Schema::hasTable('auto_scheduled_posts')) {
            Schema::create('auto_scheduled_posts', function (Blueprint $table) {
                $table->id();
                $table->foreignId('user_id')->constrained()->onDelete('cascade');
                $table->text('content');
                $table->json('platforms'); // ['facebook', 'instagram', etc.]
                $table->timestamp('scheduled_at');
                $table->json('ai_analysis')->nullable(); // تحليل AI
                $table->enum('status', ['pending', 'published', 'failed', 'cancelled'])->default('pending');
                $table->boolean('auto_generated')->default(false);
                $table->json('media_urls')->nullable();
                $table->json('hashtags')->nullable();
                $table->string('optimal_time_reason')->nullable();
                $table->timestamps();

                $table->index('user_id');
                $table->index('status');
                $table->index('scheduled_at');
            });
        }

        // إضافة عمود للربط مع auto_scheduled_posts في جدول scheduled_posts
        if (!Schema::hasColumn('scheduled_posts', 'auto_scheduled_post_id')) {
            Schema::table('scheduled_posts', function (Blueprint $table) {
                $table->foreignId('auto_scheduled_post_id')->nullable()->constrained('auto_scheduled_posts')->onDelete('cascade');
            });
        }
    }

    public function down()
    {
        if (Schema::hasColumn('scheduled_posts', 'auto_scheduled_post_id')) {
            Schema::table('scheduled_posts', function (Blueprint $table) {
                $table->dropForeign(['auto_scheduled_post_id']);
                $table->dropColumn('auto_scheduled_post_id');
            });
        }

        Schema::dropIfExists('auto_scheduled_posts');
    }
};
```

قم بتشغيل Migration:
```bash
php artisan migrate
```

### 3. إنشاء Model للـ AutoScheduledPost

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class AutoScheduledPost extends Model
{
    protected $fillable = [
        'user_id',
        'content',
        'platforms',
        'scheduled_at',
        'ai_analysis',
        'status',
        'auto_generated',
        'media_urls',
        'hashtags',
        'optimal_time_reason',
    ];

    protected $casts = [
        'platforms' => 'array',
        'ai_analysis' => 'array',
        'media_urls' => 'array',
        'hashtags' => 'array',
        'auto_generated' => 'boolean',
        'scheduled_at' => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function scheduledPosts(): HasMany
    {
        return $this->hasMany(ScheduledPost::class);
    }
}
```

### 4. إضافة Job لنشر المنشورات المجدولة

قم بإنشاء Job جديد أو تعديل الموجود:

```php
<?php

namespace App\Jobs;

use App\Models\AutoScheduledPost;
use App\Models\ScheduledPost;
use App\Services\UniversalSocialMediaService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class PublishAutoScheduledPostJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected AutoScheduledPost $autoPost;

    public function __construct(AutoScheduledPost $autoPost)
    {
        $this->autoPost = $autoPost;
    }

    public function handle(UniversalSocialMediaService $socialMediaService)
    {
        try {
            Log::info("Publishing auto-scheduled post: {$this->autoPost->id}");

            // نشر على كل المنصات
            foreach ($this->autoPost->scheduledPosts as $scheduledPost) {
                if ($scheduledPost->status === 'pending') {
                    try {
                        $result = $socialMediaService->publishPost($scheduledPost);

                        if ($result['success'] ?? false) {
                            $scheduledPost->update([
                                'status' => 'published',
                                'published_at' => now(),
                            ]);
                        } else {
                            $scheduledPost->update(['status' => 'failed']);
                        }
                    } catch (\Exception $e) {
                        Log::error("Failed to publish scheduled post {$scheduledPost->id}: " . $e->getMessage());
                        $scheduledPost->update(['status' => 'failed']);
                    }
                }
            }

            // تحديث حالة AutoScheduledPost
            $allPublished = $this->autoPost->scheduledPosts()->where('status', 'published')->count() === $this->autoPost->scheduledPosts()->count();
            $anyFailed = $this->autoPost->scheduledPosts()->where('status', 'failed')->exists();

            $this->autoPost->update([
                'status' => $allPublished ? 'published' : ($anyFailed ? 'failed' : 'pending'),
            ]);

        } catch (\Exception $e) {
            Log::error("Auto-scheduled post job failed: " . $e->getMessage());
            $this->autoPost->update(['status' => 'failed']);
        }
    }
}
```

### 5. إضافة Scheduled Task

في `app/Console/Kernel.php`:

```php
protected function schedule(Schedule $schedule)
{
    // تشغيل كل دقيقة للتحقق من المنشورات المجدولة
    $schedule->call(function () {
        $dueP osts = \App\Models\AutoScheduledPost::where('status', 'pending')
            ->where('scheduled_at', '<=', now())
            ->get();

        foreach ($duePosts as $post) {
            \App\Jobs\PublishAutoScheduledPostJob::dispatch($post);
        }
    })->everyMinute()->name('publish-auto-scheduled-posts');
}
```

تأكد من تشغيل Scheduler:
```bash
php artisan schedule:work
```

أو أضف في Crontab:
```
* * * * * cd /path-to-your-project && php artisan schedule:run >> /dev/null 2>&1
```

---

## API Endpoints

جميع الـ Endpoints تحتاج إلى Authentication (`auth:sanctum`)

### 1. جدولة منشور واحد
**POST** `/api/ai-scheduling/schedule-post`

```json
{
  "content": "محتوى المنشور هنا",
  "platforms": ["facebook", "instagram", "twitter"],
  "media_urls": ["https://example.com/image.jpg"],
  "preferred_time": "2025-12-01T14:00:00Z",
  "allow_time_adjustment": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم جدولة المنشور بنجاح باستخدام AI",
  "data": {
    "post_id": 123,
    "scheduled_at": "2025-12-01T14:30:00Z",
    "platforms": ["facebook", "instagram", "twitter"],
    "ai_analysis": {
      "best_time_of_day": "afternoon",
      "expected_engagement": "high",
      "scheduling_reason": "Afternoon shows highest engagement for similar content"
    },
    "hashtags": ["#marketing", "#socialmedia", "#business"]
  }
}
```

### 2. توليد وجدولة تلقائياً
**POST** `/api/ai-scheduling/generate-and-schedule`

```json
{
  "topic": "أفضل استراتيجيات التسويق الإلكتروني",
  "platforms": ["facebook", "linkedin"],
  "tone": "professional",
  "length": "medium",
  "generate_image": true,
  "preferred_time": "2025-12-02T10:00:00Z"
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم توليد وجدولة المنشور بنجاح",
  "data": {
    "post_id": 124,
    "content": "في عالم التسويق الرقمي...",
    "scheduled_at": "2025-12-02T10:30:00Z",
    "platforms": ["facebook", "linkedin"],
    "media_urls": ["https://storage.com/generated-image.jpg"],
    "hashtags": ["#digitalmarketing", "#strategy", "#business"],
    "ai_analysis": {...}
  }
}
```

### 3. جدولة متعددة
**POST** `/api/ai-scheduling/schedule-multiple`

```json
{
  "topics": [
    "نصائح للتسويق عبر وسائل التواصل",
    "أهمية المحتوى المرئي",
    "كيفية زيادة التفاعل"
  ],
  "platforms": ["instagram", "facebook"],
  "days_spread": 7
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم جدولة 3 منشور بنجاح",
  "data": {
    "posts_count": 3,
    "posts": [
      {
        "id": 125,
        "content": "نصائح للتسويق...",
        "scheduled_at": "2025-12-03T14:00:00Z",
        "platforms": ["instagram", "facebook"]
      },
      // ...
    ]
  }
}
```

### 4. الحصول على المنشورات المجدولة
**GET** `/api/ai-scheduling/my-scheduled-posts?status=pending`

**Response:**
```json
{
  "success": true,
  "data": {
    "posts": [...],
    "pagination": {
      "total": 25,
      "per_page": 20,
      "current_page": 1,
      "last_page": 2
    }
  }
}
```

### 5. إلغاء منشور مجدول
**DELETE** `/api/ai-scheduling/{id}`

**Response:**
```json
{
  "success": true,
  "message": "تم إلغاء المنشور بنجاح"
}
```

### 6. إعادة جدولة منشور
**PUT** `/api/ai-scheduling/{id}/reschedule`

```json
{
  "new_time": "2025-12-05T16:00:00Z"
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم تحديث موعد النشر بنجاح",
  "data": {
    "new_scheduled_at": "2025-12-05T16:00:00Z"
  }
}
```

### 7. إحصائيات الجدولة
**GET** `/api/ai-scheduling/stats`

**Response:**
```json
{
  "success": true,
  "data": {
    "total_scheduled": 50,
    "pending": 15,
    "published": 30,
    "failed": 5,
    "best_performing_time": "14:00",
    "best_performing_platform": "instagram"
  }
}
```

---

## استخدام Flutter Service

### 1. التهيئة في التطبيق

تم إضافة `AISchedulingService` في `main.dart`:

```dart
Get.put(AISchedulingService());
```

### 2. أمثلة الاستخدام

```dart
final aiScheduling = Get.find<AISchedulingService>();

// 1. جدولة منشور يدوي
await aiScheduling.schedulePost(
  content: 'محتوى المنشور',
  platforms: ['facebook', 'instagram'],
  mediaUrls: ['https://example.com/image.jpg'],
  preferredTime: DateTime.now().add(Duration(days: 1)),
  allowTimeAdjustment: true,
);

// 2. توليد وجدولة تلقائياً
await aiScheduling.generateAndSchedule(
  topic: 'أفضل استراتيجيات التسويق',
  platforms: ['facebook', 'instagram', 'linkedin'],
  tone: 'professional',
  length: 'medium',
  generateImage: true,
);

// 3. جدولة متعددة
await aiScheduling.scheduleMultiplePosts(
  topics: [
    'نصيحة 1',
    'نصيحة 2',
    'نصيحة 3',
  ],
  platforms: ['instagram', 'facebook'],
  daysSpread: 7, // توزيع على أسبوع
);

// 4. الحصول على المنشورات القادمة
final upcoming = aiScheduling.upcomingPosts;

// 5. إلغاء منشور
await aiScheduling.cancelScheduledPost(postId);

// 6. إعادة جدولة
await aiScheduling.reschedulePost(
  postId,
  DateTime.now().add(Duration(days: 2)),
);

// 7. الإحصائيات
await aiScheduling.loadStats();
print('Best time: ${aiScheduling.bestPostingTime}');
print('Best platform: ${aiScheduling.bestPlatform}');
```

---

## أفضل الممارسات

### 1. الأوقات الافتراضية لكل منصة
```
Instagram: 6 PM (18:00)
Facebook:  1 PM (13:00)
Twitter:   12 PM (12:00)
LinkedIn:  10 AM (10:00)
TikTok:    7 PM (19:00)
YouTube:   3 PM (15:00)
```

### 2. توزيع المنشورات
- تجنب نشر أكثر من 3 منشورات يومياً على نفس المنصة
- استخدم الجدولة المتعددة لتوزيع المحتوى بشكل متوازن
- احترم أوقات الراحة (ليلاً من 11 PM إلى 7 AM)

### 3. تحسين الأداء
- استخدم Queue للـ Jobs
- فعّل caching للتحليلات
- راقب معدلات النجاح/الفشل

### 4. المراقبة والصيانة
- تحقق من logs بانتظام: `storage/logs/laravel.log`
- راقب حالة Scheduler: `php artisan schedule:list`
- تحقق من Queue jobs: `php artisan queue:work`

---

## استكشاف الأخطاء

### 1. المنشورات لا تُنشر في الوقت المحدد
- تأكد من تشغيل Scheduler: `php artisan schedule:work`
- تحقق من Queue: `php artisan queue:work`
- راجع التوقيت الزمني (timezone) في `.env`

### 2. فشل توليد المحتوى
- تحقق من إعدادات AI في جدول settings
- تأكد من وجود API keys صحيحة
- راجع logs للأخطاء

### 3. الجدولة لا تعمل
- تحقق من وجود جدول `auto_scheduled_posts`
- تأكد من صلاحيات الجدول
- راجع علاقات Models

---

## الخلاصة

نظام AI Scheduling يوفر:
✅ جدولة ذكية تلقائية
✅ توليد محتوى وصور AI
✅ تحليل وإحصائيات متقدمة
✅ إدارة سهلة للمنشورات
✅ توزيع متوازن على المنصات

للدعم والمساعدة: راجع logs أو تواصل مع المطور.
