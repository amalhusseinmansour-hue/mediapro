# 🚀 دليل الإعداد السريع - نظام Webhook

## خطوات التنفيذ (5 دقائق)

### 1. نسخ الملفات ✅

```bash
# انسخ الملفات من:
backend/database/migrations/2025_01_19_100000_create_scheduled_posts_webhook_table.php
backend/app/Models/ScheduledPost.php
backend/app/Services/WebhookPublisherService.php
backend/app/Jobs/PublishScheduledPostJob.php
backend/app/Http/Controllers/Api/ScheduledPostController.php
```

### 2. تشغيل Migration ✅

```bash
cd /home/u126213189/domains/mediaprosocial.io/public_html
php artisan migrate
```

### 3. إعداد Queue ✅

```bash
# إنشاء جدول queue
php artisan queue:table
php artisan migrate

# تشغيل queue worker
nohup php artisan queue:work --sleep=3 --tries=3 > /dev/null 2>&1 &
```

### 4. تحديث .env ✅

```env
# أضف هذا السطر في .env
PABBLY_WEBHOOK_URL="https://connect.pabbly.com/workflow/sendwebhookdata/YOUR_WEBHOOK_ID"
```

### 5. تحديث config/services.php ✅

```php
// أضف في config/services.php
'pabbly' => [
    'webhook_url' => env('PABBLY_WEBHOOK_URL'),
],
```

### 6. إضافة Routes ✅

```php
// في routes/api.php
use App\Http\Controllers\Api\ScheduledPostController;

Route::middleware(['auth:sanctum'])->group(function () {
    Route::get('scheduled-posts', [ScheduledPostController::class, 'index']);
    Route::post('scheduled-posts', [ScheduledPostController::class, 'store']);
    Route::get('scheduled-posts/{id}', [ScheduledPostController::class, 'show']);
    Route::put('scheduled-posts/{id}', [ScheduledPostController::class, 'update']);
    Route::delete('scheduled-posts/{id}', [ScheduledPostController::class, 'destroy']);
    Route::post('scheduled-posts/{id}/send-now', [ScheduledPostController::class, 'sendNow']);
    Route::post('scheduled-posts/{id}/retry', [ScheduledPostController::class, 'retry']);
});
```

### 7. تحديث Kernel.php ✅

```php
// في app/Console/Kernel.php
protected function schedule(Schedule $schedule): void
{
    // Check for due posts every minute
    $schedule->call(function () {
        $duePosts = \App\Models\ScheduledPost::due()->get();

        foreach ($duePosts as $post) {
            \App\Jobs\PublishScheduledPostJob::dispatch($post);
        }

        if ($duePosts->count() > 0) {
            \Log::info('Dispatched scheduled posts', [
                'count' => $duePosts->count(),
            ]);
        }
    })->everyMinute()->name('dispatch-scheduled-posts');
}
```

### 8. إضافة Cron Job ✅

```bash
# SSH إلى السيرفر وأضف cron job
crontab -e

# أضف هذا السطر
* * * * * cd /home/u126213189/domains/mediaprosocial.io/public_html && php artisan schedule:run >> /dev/null 2>&1
```

### 9. مسح Cache ✅

```bash
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan config:cache
```

---

## 🧪 اختبار النظام

### Test 1: إنشاء منشور مجدول

```bash
curl -X POST https://mediaprosocial.io/api/scheduled-posts \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content_text": "Test post from webhook system! 🚀",
    "platforms": ["facebook", "twitter"],
    "scheduled_at": "2025-01-20T15:00:00Z"
  }'
```

### Test 2: نشر فوري

```bash
curl -X POST https://mediaprosocial.io/api/scheduled-posts/1/send-now \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Test 3: التحقق من Logs

```bash
tail -f storage/logs/laravel.log | grep webhook
```

---

## 📋 Pabbly Connect Setup

### خطوة 1: إنشاء Workflow
1. اذهب إلى Pabbly Connect
2. Create New Workflow
3. Trigger: **Webhook**
4. انسخ Webhook URL

### خطوة 2: ضع URL في .env
```env
PABBLY_WEBHOOK_URL="الـ URL الذي نسخته من Pabbly"
```

### خطوة 3: إضافة Actions
1. **Router** (لتوجيه حسب المنصة)
2. **Facebook:** Create Post
   - Map: `{{text}}` → Content
   - Map: `{{media}}` → Images
3. **Twitter:** Create Tweet
   - Map: `{{text}}` → Tweet Text
4. **Instagram:** Create Post
   - Map: `{{text}}` → Caption

### خطوة 4: Test
1. أرسل test webhook من Laravel
2. تحقق أن Pabbly استقبله
3. جرب النشر الفعلي

---

## 🎯 أمثلة API

### Schedule Post
```json
POST /api/scheduled-posts

{
  "content_text": "منشور تجريبي 🎉",
  "media_urls": [
    "https://example.com/image.jpg"
  ],
  "platforms": ["facebook", "instagram"],
  "scheduled_at": "2025-01-20T10:00:00Z"
}
```

### Get All Posts
```json
GET /api/scheduled-posts?status=pending
```

### Send Now
```json
POST /api/scheduled-posts/1/send-now
```

### Retry Failed
```json
POST /api/scheduled-posts/1/retry
```

---

## ✅ Checklist النهائي

- [ ] Migration تم تشغيلها
- [ ] Model تم إنشاؤه
- [ ] Service تم إنشاؤه
- [ ] Job تم إنشاؤه
- [ ] Controller تم إنشاؤه
- [ ] Routes تم إضافتها
- [ ] .env تم تحديثه بـ webhook URL
- [ ] Queue worker يعمل
- [ ] Cron job تم إضافته
- [ ] Pabbly workflow تم إنشاؤه
- [ ] Test post نجح

---

**🎉 النظام جاهز للاستخدام!**

الملفات في:
- `backend/database/migrations/`
- `backend/app/Models/`
- `backend/app/Services/`
- `backend/app/Jobs/`
- `backend/app/Http/Controllers/Api/`
