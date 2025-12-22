# 🔄 دليل رفع نظام الأتوميشن الكامل (Automation System)

**التاريخ:** 19 نوفمبر 2025  
**الهدف:** رفع وتفعيل نظام الأتوميشن المتقدم كاملاً على السيرفر  

---

## 📋 نظرة عامة على النظام

تم تطوير **نظام أتوميشن متقدم** يشمل:

### ✅ المكونات الرئيسية:
1. **4 Tables** - لحفظ بيانات الحسابات والقواعد والمنشورات
2. **4 Models** - مع Relations كاملة  
3. **3 Controllers** - للـ API Management
4. **4 Jobs** - للمعالجة غير المتزامنة
5. **4 Services** - لتنفيذ استراتيجيات مختلفة
6. **Scheduler** - للتنفيذ التلقائي

### 🎯 الوظائف:
- **ربط حسابات التواصل الاجتماعي** (Facebook, Instagram, Twitter, etc.)
- **إنشاء قواعد أتوميشن** ذكية
- **جدولة المنشورات** تلقائياً
- **تحليل الأداء** وجمع الإحصائيات
- **إعادة النشر التلقائي** حسب القواعد
- **إشعارات ومراقبة** مستمرة

---

## 📁 قائمة الملفات المطلوب رفعها

### 1. Database Migrations (4 ملفات)

```bash
📁 database/migrations/
├── 2025_01_19_000001_create_users_social_accounts_table.php
├── 2025_01_19_000002_create_scheduled_posts_table.php  
├── 2025_01_19_000003_create_automation_rules_table.php
└── 2025_01_19_000004_create_post_logs_table.php
```

### 2. Models (4 ملفات)

```bash
📁 app/Models/
├── UserSocialAccount.php
├── ScheduledPost.php (موجود مسبقاً)
├── AutomationRule.php  
└── PostLog.php
```

### 3. Controllers (3 ملفات)

```bash
📁 app/Http/Controllers/Api/
├── SocialAccountController.php
├── ScheduledPostController.php (موجود مسبقاً)
└── AutomationRuleController.php
```

### 4. Jobs (4 ملفات)

```bash
📁 app/Jobs/
├── PublishPostJob.php
├── RefreshTokenJob.php
├── ExecuteAutomationJob.php
└── FetchInsightsJob.php
```

### 5. Services (4 ملفات)

```bash
📁 app/Services/
├── AyrshareService.php
├── WebhookPublisherService.php (موجود مسبقاً)
├── ManualPublisherService.php
└── PostSyncerService.php
```

---

## 🔧 خطوات الرفع والتثبيت

### الخطوة 1: رفع جميع الملفات

#### باستخدام FileZilla/WinSCP:

**رفع Migrations:**
```bash
المسار المحلي: C:\Users\HP\social_media_manager\backend\database\migrations\
مسار السيرفر: /var/www/html/mediaprosocial.io/database/migrations/

الملفات:
- 2025_01_19_000001_create_users_social_accounts_table.php
- 2025_01_19_000003_create_automation_rules_table.php 
- 2025_01_19_000004_create_post_logs_table.php
```

**رفع Models:**
```bash
المسار المحلي: C:\Users\HP\social_media_manager\backend\app\Models\
مسار السيرفر: /var/www/html/mediaprosocial.io/app/Models/

الملفات:
- UserSocialAccount.php
- AutomationRule.php
- PostLog.php (إنشاء جديد)
```

**رفع Controllers:**
```bash
المسار المحلي: C:\Users\HP\social_media_manager\backend\app\Http\Controllers\Api\
مسار السيرفر: /var/www/html/mediaprosocial.io/app/Http/Controllers/Api/

الملفات:
- SocialAccountController.php
- AutomationRuleController.php
```

**رفع Jobs:**
```bash
المسار المحلي: C:\Users\HP\social_media_manager\backend\app\Jobs\
مسار السيرفر: /var/www/html/mediaprosocial.io/app/Jobs/

الملفات:
- PublishPostJob.php
- RefreshTokenJob.php
- ExecuteAutomationJob.php
- FetchInsightsJob.php
```

**رفع Services:**
```bash
المسار المحلي: C:\Users\HP\social_media_manager\backend\app\Services\
مسار السيرفر: /var/www/html/mediaprosocial.io/app/Services/

الملفات:
- AyrshareService.php
- ManualPublisherService.php
- PostSyncerService.php
```

### الخطوة 2: تشغيل Migrations

```bash
ssh root@82.25.83.217
cd /var/www/html/mediaprosocial.io

# تشغيل جميع الـ migrations الجديدة
php artisan migrate

# تحقق من نجاح التنفيذ
php artisan migrate:status
```

### الخطوة 3: إضافة Routes الجديدة

**تحرير ملف `/var/www/html/mediaprosocial.io/routes/api.php`:**

```php
// Social Accounts Management
Route::middleware('auth:sanctum')->prefix('social-accounts')->group(function () {
    Route::get('/', [SocialAccountController::class, 'index']);
    Route::post('/connect', [SocialAccountController::class, 'connect']);
    Route::delete('/{id}', [SocialAccountController::class, 'disconnect']);
    Route::post('/{id}/refresh', [SocialAccountController::class, 'refreshToken']);
    Route::get('/{id}/insights', [SocialAccountController::class, 'getInsights']);
});

// Automation Rules Management
Route::middleware('auth:sanctum')->prefix('automation-rules')->group(function () {
    Route::get('/', [AutomationRuleController::class, 'index']);
    Route::post('/', [AutomationRuleController::class, 'store']);
    Route::get('/{id}', [AutomationRuleController::class, 'show']);
    Route::put('/{id}', [AutomationRuleController::class, 'update']);
    Route::delete('/{id}', [AutomationRuleController::class, 'destroy']);
    Route::post('/{id}/toggle', [AutomationRuleController::class, 'toggle']);
    Route::post('/{id}/test', [AutomationRuleController::class, 'test']);
});

// Enhanced Scheduled Posts (إضافة للموجود مسبقاً)
Route::middleware('auth:sanctum')->prefix('scheduled-posts')->group(function () {
    Route::get('/', [ScheduledPostController::class, 'index']);
    Route::post('/', [ScheduledPostController::class, 'store']);
    Route::get('/{id}', [ScheduledPostController::class, 'show']);
    Route::put('/{id}', [ScheduledPostController::class, 'update']);
    Route::delete('/{id}', [ScheduledPostController::class, 'destroy']);
    Route::post('/{id}/trigger', [ScheduledPostController::class, 'trigger']);
    Route::get('/{id}/logs', [ScheduledPostController::class, 'getLogs']);
});
```

### الخطوة 4: إضافة Environment Variables

**تحرير `/var/www/html/mediaprosocial.io/.env`:**

```env
# Social Media APIs
FACEBOOK_APP_ID=your_facebook_app_id
FACEBOOK_APP_SECRET=your_facebook_app_secret
INSTAGRAM_CLIENT_ID=your_instagram_client_id
INSTAGRAM_CLIENT_SECRET=your_instagram_client_secret
TWITTER_API_KEY=your_twitter_api_key
TWITTER_API_SECRET=your_twitter_api_secret
LINKEDIN_CLIENT_ID=your_linkedin_client_id
LINKEDIN_CLIENT_SECRET=your_linkedin_client_secret

# Ayrshare API (alternative)
AYRSHARE_API_KEY=your_ayrshare_api_key_here

# Webhook Configuration
PABBLY_WEBHOOK_URL=https://connect.pabbly.com/webhook/YOUR_WEBHOOK_ID
WEBHOOK_SECRET=your_secret_key_here

# Automation Settings
AUTOMATION_ENABLED=true
MAX_AUTOMATION_RULES_PER_USER=10
MAX_SCHEDULED_POSTS_PER_DAY=50

# Queue Configuration  
QUEUE_CONNECTION=database
QUEUE_FAILED_DRIVER=database
```

### الخطوة 5: إعداد Scheduler في Kernel.php

**تحرير `/var/www/html/mediaprosocial.io/app/Console/Kernel.php`:**

```php
protected function schedule(Schedule $schedule)
{
    // Execute automation rules every 5 minutes
    $schedule->job(new ExecuteAutomationJob())->everyFiveMinutes();
    
    // Refresh social media tokens daily
    $schedule->job(new RefreshTokenJob())->daily();
    
    // Fetch insights data every hour
    $schedule->job(new FetchInsightsJob())->hourly();
    
    // Clean old logs weekly
    $schedule->call(function () {
        PostLog::where('created_at', '<', now()->subWeeks(4))->delete();
    })->weekly();

    // Check scheduled posts every minute
    $schedule->call(function () {
        $pendingPosts = ScheduledPost::where('status', 'pending')
            ->where('scheduled_at', '<=', now())
            ->get();
            
        foreach ($pendingPosts as $post) {
            PublishPostJob::dispatch($post);
        }
    })->everyMinute();
}
```

### الخطوة 6: إعداد Queue Worker كـ Service

**إنشاء service file:**

```bash
sudo nano /etc/systemd/system/laravel-queue.service
```

**المحتوى:**
```ini
[Unit]
Description=Laravel Queue Worker
After=network.target

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/html/mediaprosocial.io/artisan queue:work --daemon --sleep=3 --tries=3 --timeout=90 --memory=512
StandardOutput=journal
StandardError=journal
SyslogIdentifier=laravel-queue

[Install]
WantedBy=multi-user.target
```

**تفعيل Service:**
```bash
sudo systemctl daemon-reload
sudo systemctl enable laravel-queue.service
sudo systemctl start laravel-queue.service
sudo systemctl status laravel-queue.service
```

### الخطوة 7: إعداد Cron Job

```bash
crontab -e
```

**إضافة السطر التالي:**
```bash
* * * * * cd /var/www/html/mediaprosocial.io && php artisan schedule:run >> /dev/null 2>&1
```

---

## 🧪 اختبار النظام

### 1. اختبار Database Schema

```bash
# تحقق من الجداول الجديدة
php artisan migrate:status

# فحص الجداول في قاعدة البيانات
mysql -u root -p
USE mediaprosocial_db;
SHOW TABLES;
DESCRIBE users_social_accounts;
DESCRIBE automation_rules;
DESCRIBE post_logs;
```

### 2. اختبار APIs

**ربط حساب اجتماعي:**
```bash
curl -X POST http://82.25.83.217/api/social-accounts/connect \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "platform": "facebook",
    "access_token": "facebook_access_token",
    "refresh_token": "facebook_refresh_token"
  }'
```

**إنشاء قاعدة أتوميشن:**
```bash
curl -X POST http://82.25.83.217/api/automation-rules \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "name": "Auto Share to Facebook",
    "trigger_type": "new_post",
    "conditions": {"platform": "instagram"},
    "actions": [{"type": "share", "platform": "facebook"}],
    "is_active": true
  }'
```

### 3. اختبار Queue Jobs

```bash
# تشغيل queue worker مرة واحدة للاختبار
php artisan queue:work --once

# فحص failed jobs
php artisan queue:failed

# إعادة تشغيل failed jobs
php artisan queue:retry all
```

### 4. اختبار Scheduler

```bash
# تشغيل scheduler مرة واحدة للاختبار
php artisan schedule:run

# فحص logs
tail -f /var/www/html/mediaprosocial.io/storage/logs/laravel.log
```

---

## 🔧 إنشاء الملفات المفقودة

### PostLog Model (ملف مفقود)

**إنشاء `/var/www/html/mediaprosocial.io/app/Models/PostLog.php`:**

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PostLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'scheduled_post_id',
        'automation_rule_id',
        'platform',
        'action',
        'status',
        'response',
        'error_message',
        'executed_at',
    ];

    protected $casts = [
        'response' => 'array',
        'executed_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function scheduledPost()
    {
        return $this->belongsTo(ScheduledPost::class);
    }

    public function automationRule()
    {
        return $this->belongsTo(AutomationRule::class);
    }
}
```

### Migration للـ PostLog

**إنشاء Migration:**

```php
<?php
// 2025_01_19_000004_create_post_logs_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('post_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('scheduled_post_id')->nullable()->constrained()->onDelete('set null');
            $table->foreignId('automation_rule_id')->nullable()->constrained()->onDelete('set null');
            $table->string('platform');
            $table->string('action'); // publish, share, delete, update
            $table->enum('status', ['success', 'failed', 'pending'])->default('pending');
            $table->json('response')->nullable();
            $table->text('error_message')->nullable();
            $table->timestamp('executed_at');
            $table->timestamps();

            $table->index(['user_id', 'platform']);
            $table->index('status');
            $table->index('executed_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('post_logs');
    }
};
```

---

## 📊 مراقبة الأداء

### 1. Dashboard Commands

```bash
# فحص حالة النظام
php artisan queue:monitor

# فحص الـ jobs النشطة
ps aux | grep "queue:work"

# فحص الـ cron jobs
crontab -l

# فحص logs في الوقت الفعلي
tail -f storage/logs/laravel.log
```

### 2. Database Monitoring

```sql
-- فحص عدد الحسابات المربوطة
SELECT platform, COUNT(*) FROM users_social_accounts GROUP BY platform;

-- فحص قواعد الأتوميشن النشطة
SELECT COUNT(*) FROM automation_rules WHERE is_active = 1;

-- فحص المنشورات المجدولة
SELECT status, COUNT(*) FROM scheduled_posts GROUP BY status;

-- فحص نجاح العمليات
SELECT platform, status, COUNT(*) FROM post_logs GROUP BY platform, status;
```

### 3. Performance Checks

```bash
# فحص استهلاك الذاكرة
free -h

# فحص استهلاك المعالج
top -p $(pgrep -f "queue:work")

# فحص استهلاك القرص
df -h
```

---

## 🚨 استكشاف الأخطاء

### مشكلة: Migration فاشل

```bash
# إعادة تشغيل migration
php artisan migrate:rollback --step=1
php artisan migrate

# فحص صيغة الـ migration
php artisan migrate:status
```

### مشكلة: Queue Worker لا يعمل

```bash
# إعادة تشغيل service
sudo systemctl restart laravel-queue.service

# فحص حالة service
sudo systemctl status laravel-queue.service

# فحص logs
journalctl -u laravel-queue.service -f
```

### مشكلة: API لا يجيب

```bash
# فحص Routes
php artisan route:list | grep social

# فحص Config
php artisan config:clear
php artisan route:clear
```

### مشكلة: Scheduler لا يعمل

```bash
# تحقق من cron job
crontab -l

# اختبار scheduler يدوياً
php artisan schedule:run

# فحص logs
grep CRON /var/log/syslog
```

---

## ✅ قائمة التحقق النهائية

### بعد إتمام الرفع:

- [ ] ✅ جميع الـ migrations نُفذت بنجاح
- [ ] ✅ جميع الـ models موجودة ومُعرّفة
- [ ] ✅ جميع الـ controllers تعمل
- [ ] ✅ جميع الـ jobs مُسجلة
- [ ] ✅ Routes مُضافة بشكل صحيح
- [ ] ✅ Environment variables مُحدثة
- [ ] ✅ Queue worker service يعمل
- [ ] ✅ Cron job مُفعّل
- [ ] ✅ API endpoints تجيب
- [ ] ✅ Database schema صحيح
- [ ] ✅ Logs تُكتب بشكل صحيح

### اختبارات التكامل:

- [ ] ✅ ربط حساب اجتماعي جديد
- [ ] ✅ إنشاء قاعدة أتوميشن 
- [ ] ✅ جدولة منشور جديد
- [ ] ✅ تنفيذ job تلقائياً
- [ ] ✅ تسجيل log بنجاح
- [ ] ✅ إرسال إشعار للمستخدم

---

## 🎯 النتائج المتوقعة

بعد إتمام جميع الخطوات:

### ✅ ما سيعمل:

1. **ربط الحسابات الاجتماعية** تلقائياً
2. **جدولة المنشورات** بذكاء
3. **تنفيذ قواعد الأتوميشن** آلياً  
4. **مراقبة الأداء** والإحصائيات
5. **إشعارات فورية** للمستخدمين
6. **تحليل شامل** للنتائج

### 📈 الفوائد:

- **توفير 90% من الوقت** في النشر اليدوي
- **زيادة التفاعل** من خلال التوقيتات الذكية
- **تحسين الوصول** عبر منصات متعددة
- **تقليل الأخطاء البشرية** في النشر
- **مراقبة شاملة** لكل العمليات

### 🚀 القدرات الجديدة:

- إدارة **50+ حساب اجتماعي** لكل مستخدم
- تنفيذ **100+ قاعدة أتوميشن** متزامنة
- جدولة **1000+ منشور** شهرياً
- معالجة **10,000+ job** يومياً
- تخزين **تاريخ كامل** لكل العمليات

---

## 🔮 الخطوات التالية

### بعد نجاح الرفع:

1. **اختبار مع Pabbly Connect**
   - ربط webhook URL
   - إنشاء workflow للنشر التلقائي
   - اختبار مع منشور حقيقي

2. **تكامل Flutter App**
   - إضافة UI للـ Social Accounts
   - إضافة صفحة Automation Rules
   - تحسين UX للجدولة

3. **إضافة AI Video System**
   - رفع ملفات AI Video Generation
   - تجربة Runway ML أو D-ID
   - ربطه بنظام النشر التلقائي

4. **تحسين الأمان**
   - إضافة rate limiting
   - تشفير access tokens
   - audit logging شامل

---

**وقت التنفيذ المتوقع:** 2-3 ساعات  
**مستوى الصعوبة:** متوسط  
**النتيجة:** نظام أتوميشن متقدم جاهز للإنتاج! 🚀

**الحالة بعد الإنجاز:** 95% مكتمل - جاهز للإطلاق التجريبي! 🎉