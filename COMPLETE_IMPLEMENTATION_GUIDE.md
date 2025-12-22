# 🚀 دليل التنفيذ الكامل - نظام الأوتوميشن للنشر على وسائل التواصل

## 📦 الملفات التي تم إنشاؤها

### 1. Database Migrations (✅ جاهزة)
```
database/migrations/
├── 2025_01_19_000001_create_users_social_accounts_table.php
├── 2025_01_19_000002_create_scheduled_posts_table.php
├── 2025_01_19_000003_create_automation_rules_table.php
└── 2025_01_19_000004_create_post_logs_table.php
```

### 2. Models (✅ جاهزة)
```
app/Models/
├── UserSocialAccount.php
├── ScheduledPost.php
├── AutomationRule.php
└── PostLog.php
```

### 3. Services (✅ جاهزة)
```
app/Services/SocialMedia/
├── Contracts/
│   └── SocialPublisherInterface.php
├── SocialPublishService.php
├── AyrshareAdapter.php
├── WebhookAdapter.php
├── ManualPublisher.php
└── PostSyncerAdapter.php
```

### 4. Controllers (✅ 1/3 جاهز)
```
app/Http/Controllers/Api/
├── SocialAccountController.php (✅)
├── ScheduledPostController.php (🔜 التالي)
└── AutomationRuleController.php (🔜 التالي)
```

---

## 🔧 خطوات التنفيذ على السيرفر

### الخطوة 1: رفع الملفات
```bash
# من Windows إلى السيرفر
pscp -P 65002 -r backend/* u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/
```

### الخطوة 2: تشغيل Migrations
```bash
# SSH إلى السيرفر
cd /home/u126213189/domains/mediaprosocial.io/public_html
php artisan migrate
```

### الخطوة 3: إعداد Queue
```bash
# في .env
QUEUE_CONNECTION=database

# Create jobs table
php artisan queue:table
php artisan migrate

# Start queue worker (في background)
nohup php artisan queue:work --sleep=3 --tries=3 &
```

### الخطوة 4: إعداد Scheduler
```bash
# إضافة cron job
crontab -e

# أضف هذا السطر
* * * * * cd /home/u126213189/domains/mediaprosocial.io/public_html && php artisan schedule:run >> /dev/null 2>&1
```

### الخطوة 5: تكوين Environment Variables
```bash
# في .env
AYRSHARE_ENABLED=true
AYRSHARE_API_KEY=your_key_here

WEBHOOK_ENABLED=true
WEBHOOK_URL=https://connect.pabbly.com/workflow/YOUR_ID

POSTSYNCER_ENABLED=false
POSTSYNCER_API_KEY=
```

---

## 📝 الملفات المتبقية (سأنشئها الآن)

### ScheduledPostController
**Endpoints:**
- `GET /api/scheduled-posts` - قائمة المنشورات
- `POST /api/scheduled-posts` - إنشاء منشور جديد
- `GET /api/scheduled-posts/{id}` - تفاصيل منشور
- `PUT /api/scheduled-posts/{id}` - تعديل منشور
- `DELETE /api/scheduled-posts/{id}` - حذف منشور
- `POST /api/scheduled-posts/{id}/publish-now` - نشر فوري
- `POST /api/scheduled-posts/{id}/cancel` - إلغاء جدولة

### AutomationRuleController
**Endpoints:**
- `GET /api/automation-rules` - قائمة القواعد
- `POST /api/automation-rules` - إنشاء قاعدة
- `GET /api/automation-rules/{id}` - تفاصيل قاعدة
- `PUT /api/automation-rules/{id}` - تعديل قاعدة
- `DELETE /api/automation-rules/{id}` - حذف قاعدة
- `POST /api/automation-rules/{id}/pause` - إيقاف مؤقت
- `POST /api/automation-rules/{id}/resume` - استئناف
- `POST /api/automation-rules/{id}/execute-now` - تنفيذ فوري

### Jobs
- **PublishPostJob** - ينفذ عملية النشر
- **RefreshTokenJob** - يجدد التوكنات
- **FetchInsightsJob** - يجلب الإحصائيات
- **CleanupOldLogsJob** - ينظف السجلات القديمة

### Scheduler Configuration
في `app/Console/Kernel.php`:
```php
protected function schedule(Schedule $schedule)
{
    // Check for due posts every minute
    $schedule->call(function () {
        $posts = ScheduledPost::pending()->get();
        foreach ($posts as $post) {
            PublishPostJob::dispatch($post);
        }
    })->everyMinute();

    // Check automation rules every 5 minutes
    $schedule->call(function () {
        $rules = AutomationRule::due()->get();
        foreach ($rules as $rule) {
            ExecuteAutomationRuleJob::dispatch($rule);
        }
    })->everyFiveMinutes();

    // Refresh expiring tokens daily
    $schedule->call(function () {
        $accounts = UserSocialAccount::tokenExpiringSoon(24)->get();
        foreach ($accounts as $account) {
            RefreshTokenJob::dispatch($account);
        }
    })->daily();

    // Cleanup old logs weekly
    $schedule->call(function () {
        PostLog::where('created_at', '<', now()->subDays(30))->delete();
    })->weekly();
}
```

---

## 🧪 أمثلة API Requests

### 1. ربط حساب Facebook
```bash
curl -X POST https://mediaprosocial.io/api/social-accounts \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "platform": "facebook",
    "platform_user_id": "123456789",
    "username": "john_doe",
    "display_name": "John Doe",
    "access_token": "EAAxxxxxxxx",
    "refresh_token": "optional_refresh_token",
    "token_expires_at": "2025-03-01T00:00:00Z",
    "platform_data": {
      "page_id": "987654321",
      "page_name": "My Business Page"
    }
  }'
```

### 2. جدولة منشور
```bash
curl -X POST https://mediaprosocial.io/api/scheduled-posts \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "🚀 إطلاق منتج جديد! تابعونا للمزيد...",
    "title": "New Product Launch",
    "media_urls": [
      "https://example.com/product-image.jpg",
      "https://example.com/product-video.mp4"
    ],
    "media_type": "image",
    "platforms": ["facebook", "instagram", "twitter"],
    "scheduled_at": "2025-01-20T10:00:00Z",
    "scheduling_type": "scheduled",
    "platform_settings": {
      "instagram": {
        "first_comment": "للطلب: 📞 0501234567"
      },
      "facebook": {
        "target_audience": "UAE"
      }
    },
    "track_analytics": true
  }'
```

### 3. إنشاء قاعدة أوتوميشن
```bash
curl -X POST https://mediaprosocial.io/api/automation-rules \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Daily Morning Post",
    "description": "Post motivational quote every morning",
    "rule_type": "recurring_post",
    "frequency": "daily",
    "time_of_day": "08:00",
    "timezone": "Asia/Dubai",
    "platforms": ["facebook", "instagram"],
    "content_pool": [
      {"content": "صباح الخير! 🌅"},
      {"content": "يوم جديد، فرص جديدة! ✨"},
      {"content": "ابدأ يومك بطاقة إيجابية! 💪"}
    ],
    "start_date": "2025-01-20",
    "end_date": null,
    "max_executions": null,
    "status": "active"
  }'
```

### 4. نشر فوري
```bash
curl -X POST https://mediaprosocial.io/api/scheduled-posts/123/publish-now \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 🔍 Ayrshare API Examples

### مثال 1: نشر نص + صورة
```bash
curl -X POST https://app.ayrshare.com/api/post \
  -H "Authorization: Bearer YOUR_AYRSHARE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "post": "Check out our new product! 🚀",
    "platforms": ["facebook", "instagram", "twitter"],
    "mediaUrls": ["https://example.com/product.jpg"]
  }'
```

### مثال 2: نشر فيديو
```bash
curl -X POST https://app.ayrshare.com/api/post \
  -H "Authorization: Bearer YOUR_AYRSHARE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "post": "Watch our latest video!",
    "platforms": ["facebook", "instagram", "youtube"],
    "videoUrl": "https://example.com/video.mp4",
    "title": "Product Demo Video"
  }'
```

### مثال 3: منشور مجدول
```bash
curl -X POST https://app.ayrshare.com/api/post \
  -H "Authorization: Bearer YOUR_AYRSHARE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "post": "Coming soon announcement!",
    "platforms": ["facebook", "twitter"],
    "scheduleDate": "2025-01-20T15:00:00Z"
  }'
```

### مثال 4: جلب الإحصائيات
```bash
curl -X GET https://app.ayrshare.com/api/analytics/post/POST_ID \
  -H "Authorization: Bearer YOUR_AYRSHARE_KEY"
```

---

## ⚠️ إدارة المخاطر والمراقبة

### 1. Logging Strategy
```php
// في SocialPublishService
Log::channel('social_publishing')->info('Publishing post', [
    'post_id' => $post->id,
    'platforms' => $post->platforms,
    'method' => $method,
]);

// في config/logging.php
'channels' => [
    'social_publishing' => [
        'driver' => 'daily',
        'path' => storage_path('logs/social_publishing.log'),
        'level' => 'info',
        'days' => 30,
    ],
],
```

### 2. Error Monitoring
```php
// استخدم Sentry أو Bugsnag
if (app()->bound('sentry')) {
    app('sentry')->captureException($exception);
}
```

### 3. Rate Limit Monitoring
```php
// في PostLog
$rateLimitWarnings = PostLog::where('action', 'rate_limit_hit')
    ->where('created_at', '>=', now()->subHours(1))
    ->count();

if ($rateLimitWarnings > 10) {
    // Send alert to admin
    Mail::to('admin@example.com')->send(new RateLimitAlert());
}
```

### 4. Failed Jobs Monitoring
```bash
# في Laravel Horizon (recommended) أو
php artisan queue:failed

# إعادة محاولة الـ jobs الفاشلة
php artisan queue:retry all
```

### 5. Token Expiry Alerts
```php
// Daily check
$expiringAccounts = UserSocialAccount::tokenExpiringSoon(48)->get();

foreach ($expiringAccounts as $account) {
    // Notify user
    $account->user->notify(new TokenExpiringNotification($account));
}
```

---

## 📊 Monitoring Dashboard Queries

### إحصائيات النشر
```sql
-- Posts published today
SELECT
    DATE(published_at) as date,
    COUNT(*) as total_posts,
    COUNT(CASE WHEN status = 'published' THEN 1 END) as successful,
    COUNT(CASE WHEN status = 'failed' THEN 1 END) as failed
FROM scheduled_posts
WHERE DATE(published_at) = CURDATE()
GROUP BY DATE(published_at);

-- Posts by platform
SELECT
    platform,
    COUNT(*) as total,
    AVG(execution_time_ms) as avg_time
FROM post_logs
WHERE action = 'publish_success'
    AND created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY platform;

-- Error rate
SELECT
    DATE(created_at) as date,
    COUNT(*) as total_attempts,
    SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) as failures,
    ROUND(SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as error_rate
FROM post_logs
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY DATE(created_at);
```

---

## 🔐 Security Best Practices

### 1. Token Encryption
✅ Already implemented في UserSocialAccount model
```php
protected function getAccessTokenAttribute($value): ?string
{
    return $value ? Crypt::decryptString($value) : null;
}
```

### 2. API Rate Limiting
```php
// في routes/api.php
Route::middleware(['auth:sanctum', 'throttle:60,1'])->group(function () {
    Route::apiResource('scheduled-posts', ScheduledPostController::class);
});
```

### 3. Input Validation
✅ Already implemented في Controllers
```php
$validator = Validator::make($request->all(), [
    'platform' => 'required|in:facebook,instagram,twitter,...',
    'content' => 'required|string|max:5000',
]);
```

### 4. Webhook Security
```php
// Verify webhook signatures
public function handleWebhook(Request $request)
{
    $signature = $request->header('X-Webhook-Signature');
    $payload = $request->getContent();

    $expectedSignature = hash_hmac('sha256', $payload, config('webhook.secret'));

    if (!hash_equals($expectedSignature, $signature)) {
        abort(403, 'Invalid signature');
    }

    // Process webhook...
}
```

---

## 📱 Flutter Integration

### 1. API Client
```dart
class SocialMediaApi {
  final String baseUrl = 'https://mediaprosocial.io/api';

  Future<Response> schedulePost({
    required String content,
    required List<String> platforms,
    DateTime? scheduledAt,
    List<String>? mediaUrls,
  }) async {
    return await http.post(
      Uri.parse('$baseUrl/scheduled-posts'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'content': content,
        'platforms': platforms,
        'scheduled_at': scheduledAt?.toIso8601String(),
        'media_urls': mediaUrls,
      }),
    );
  }
}
```

### 2. Status Polling
```dart
Future<void> pollPostStatus(int postId) async {
  Timer.periodic(Duration(seconds: 5), (timer) async {
    final response = await http.get(
      Uri.parse('$baseUrl/scheduled-posts/$postId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);

    if (data['status'] == 'published') {
      timer.cancel();
      showSuccess('Post published successfully!');
    } else if (data['status'] == 'failed') {
      timer.cancel();
      showError(data['error_message']);
    }
  });
}
```

### 3. Real-time Updates (WebSocket)
```dart
// إذا أردت real-time updates
import 'package:pusher_client/pusher_client.dart';

final pusher = PusherClient(
  'YOUR_PUSHER_KEY',
  PusherOptions(cluster: 'ap2'),
);

final channel = pusher.subscribe('user.$userId');

channel.bind('post.published', (event) {
  final data = jsonDecode(event.data);
  showNotification('Post published: ${data['post_id']}');
});
```

---

## ✅ Checklist للنشر Production

- [ ] Run migrations على production database
- [ ] إعداد Queue worker (supervisor أو systemd)
- [ ] إعداد Cron job للـ scheduler
- [ ] تكوين Environment variables
- [ ] اختبار Ayrshare API key
- [ ] إعداد Webhook URLs (Pabbly/Zapier)
- [ ] تفعيل Logging
- [ ] إعداد Error monitoring (Sentry)
- [ ] اختبار Token refresh flow
- [ ] اختبار Rate limiting
- [ ] Backup strategy للـ database
- [ ] إعداد SSL certificates
- [ ] Test end-to-end من Flutter app

---

## 📞 الدعم والمساعدة

إذا واجهت أي مشكلة:
1. تحقق من الـ logs: `storage/logs/laravel.log`
2. تحقق من queue jobs: `php artisan queue:failed`
3. تحقق من الـ database: الجداول والعلاقات
4. راجع Ayrshare API docs: https://docs.ayrshare.com

---

*تم الإعداد: 19 يناير 2025*
*الحالة: جاهز للتنفيذ*
*الإصدار: 1.0.0*
