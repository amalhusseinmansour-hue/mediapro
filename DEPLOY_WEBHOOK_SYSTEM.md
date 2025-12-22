# 🚀 نشر نظام Webhook - أوامر سريعة

## رفع الملفات على السيرفر

### 1. رفع Migration
```bash
"C:\Program Files\PuTTY\pscp" -batch -P 65002 -pw "Alenwanapp33510421@" -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4" "C:\Users\HP\social_media_manager\backend\database\migrations\2025_01_19_100000_create_scheduled_posts_webhook_table.php" u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/database/migrations/
```

### 2. رفع Model
```bash
"C:\Program Files\PuTTY\pscp" -batch -P 65002 -pw "Alenwanapp33510421@" -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4" "C:\Users\HP\social_media_manager\backend\app\Models\ScheduledPost.php" u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/app/Models/
```

### 3. إنشاء مجلد Services ورفع الملف
```bash
"C:\Program Files\PuTTY\plink" -batch -P 65002 -pw "Alenwanapp33510421@" u126213189@82.25.83.217 -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4" "mkdir -p /home/u126213189/domains/mediaprosocial.io/public_html/app/Services && echo 'Services directory created'"

"C:\Program Files\PuTTY\pscp" -batch -P 65002 -pw "Alenwanapp33510421@" -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4" "C:\Users\HP\social_media_manager\backend\app\Services\WebhookPublisherService.php" u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/app/Services/
```

### 4. رفع Job
```bash
"C:\Program Files\PuTTY\pscp" -batch -P 65002 -pw "Alenwanapp33510421@" -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4" "C:\Users\HP\social_media_manager\backend\app\Jobs\PublishScheduledPostJob.php" u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/app/Jobs/
```

### 5. رفع Controller
```bash
"C:\Program Files\PuTTY\pscp" -batch -P 65002 -pw "Alenwanapp33510421@" -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4" "C:\Users\HP\social_media_manager\backend\app\Http\Controllers\Api\ScheduledPostController.php" u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/app/Http/Controllers/Api/
```

---

## تشغيل على السيرفر

### 6. تشغيل Migration
```bash
"C:\Program Files\PuTTY\plink" -batch -P 65002 -pw "Alenwanapp33510421@" u126213189@82.25.83.217 -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4" "cd /home/u126213189/domains/mediaprosocial.io/public_html && php artisan migrate --force"
```

### 7. إنشاء Queue Table
```bash
"C:\Program Files\PuTTY\plink" -batch -P 65002 -pw "Alenwanapp33510421@" u126213189@82.25.83.217 -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4" "cd /home/u126213189/domains/mediaprosocial.io/public_html && php artisan queue:table && php artisan migrate --force"
```

### 8. تحديث .env (إضافة Webhook URL)
```bash
"C:\Program Files\PuTTY\plink" -batch -P 65002 -pw "Alenwanapp33510421@" u126213189@82.25.83.217 -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4" "echo 'PABBLY_WEBHOOK_URL=YOUR_WEBHOOK_URL_HERE' >> /home/u126213189/domains/mediaprosocial.io/public_html/.env"
```

### 9. تحديث config/services.php
```bash
"C:\Program Files\PuTTY\plink" -batch -P 65002 -pw "Alenwanapp33510421@" u126213189@82.25.83.217 -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4" "cat >> /home/u126213189/domains/mediaprosocial.io/public_html/config/services.php << 'EOF'

    'pabbly' => [
        'webhook_url' => env('PABBLY_WEBHOOK_URL'),
    ],
EOF
"
```

### 10. مسح Cache
```bash
"C:\Program Files\PuTTY\plink" -batch -P 65002 -pw "Alenwanapp33510421@" u126213189@82.25.83.217 -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4" "cd /home/u126213189/domains/mediaprosocial.io/public_html && php artisan config:clear && php artisan cache:clear && php artisan route:clear && php artisan config:cache"
```

### 11. تشغيل Queue Worker
```bash
"C:\Program Files\PuTTY\plink" -batch -P 65002 -pw "Alenwanapp33510421@" u126213189@82.25.83.217 -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4" "cd /home/u126213189/domains/mediaprosocial.io/public_html && nohup php artisan queue:work --sleep=3 --tries=3 > /dev/null 2>&1 &"
```

---

## إضافة Routes (يدوياً)

افتح ملف `routes/api.php` وأضف:

```php
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

---

## إضافة Scheduler في Kernel.php (يدوياً)

افتح ملف `app/Console/Kernel.php` وأضف في دالة `schedule()`:

```php
protected function schedule(Schedule $schedule): void
{
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

---

## Cron Job Setup

```bash
# SSH إلى السيرفر
"C:\Program Files\PuTTY\plink" -batch -P 65002 -pw "Alenwanapp33510421@" u126213189@82.25.83.217 -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4"

# افتح crontab
crontab -e

# أضف هذا السطر
* * * * * cd /home/u126213189/domains/mediaprosocial.io/public_html && php artisan schedule:run >> /dev/null 2>&1
```

---

## اختبار النظام

### Test 1: اختبار Webhook
```bash
"C:\Program Files\PuTTY\plink" -batch -P 65002 -pw "Alenwanapp33510421@" u126213189@82.25.83.217 -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4" "cd /home/u126213189/domains/mediaprosocial.io/public_html && php artisan tinker --execute=\"app(\App\Services\WebhookPublisherService::class)->testWebhook();\""
```

### Test 2: إنشاء منشور تجريبي (من Postman/Flutter)
```bash
curl -X POST https://mediaprosocial.io/api/scheduled-posts \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content_text": "Test webhook post 🚀",
    "platforms": ["facebook"],
    "scheduled_at": "2025-01-20T15:00:00Z"
  }'
```

### Test 3: نشر فوري
```bash
curl -X POST https://mediaprosocial.io/api/scheduled-posts/1/send-now \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Test 4: التحقق من Logs
```bash
"C:\Program Files\PuTTY\plink" -batch -P 65002 -pw "Alenwanapp33510421@" u126213189@82.25.83.217 -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4" "tail -50 /home/u126213189/domains/mediaprosocial.io/public_html/storage/logs/laravel.log | grep -E 'webhook|scheduled'"
```

---

## ✅ Checklist

- [ ] ✅ Migration رُفعت وتم تشغيلها
- [ ] ✅ Model تم رفعه
- [ ] ✅ Service تم رفعه
- [ ] ✅ Job تم رفعه
- [ ] ✅ Controller تم رفعه
- [ ] ⏳ Routes تم إضافتها في `routes/api.php`
- [ ] ⏳ Scheduler تم إضافته في `Kernel.php`
- [ ] ⏳ .env تم تحديثه بـ Pabbly URL
- [ ] ⏳ config/services.php تم تحديثه
- [ ] ✅ Queue table تم إنشاؤه
- [ ] ✅ Queue worker يعمل
- [ ] ⏳ Cron job تم إضافته
- [ ] ⏳ Pabbly workflow تم إنشاؤه وجاهز

---

## 🎯 الخطوة التالية

1. احصل على Webhook URL من Pabbly Connect
2. ضعه في .env على السيرفر
3. أضف Routes في `routes/api.php`
4. أضف Scheduler في `app/Console/Kernel.php`
5. جرب إرسال منشور تجريبي

---

**🚀 جاهز للعمل!**
