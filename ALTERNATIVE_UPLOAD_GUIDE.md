# 🚀 دليل الرفع النهائي - الطريقة البديلة

**المشكلة:** صعوبة الاتصال المباشر بالسيرفر  
**الحل:** رفع يدوي باستخدام أدوات grafical  

---

## 🎯 الخطة البديلة السريعة

### الطريقة 1: استخدام cPanel File Manager (الأسهل)

#### 1. الدخول إلى cPanel
- اذهب إلى: `https://82.25.83.217:2083` أو `https://yourdomain.com:2083`
- استخدم بيانات السيرفر للدخول

#### 2. فتح File Manager  
- اضغط على "File Manager"
- انتقل إلى: `/public_html/mediaprosocial.io/`

#### 3. رفع الملفات حسب المسارات التالية:

**Webhook System Files:**
```
رفع إلى: /public_html/mediaprosocial.io/database/migrations/
الملف: 2025_01_19_100000_create_scheduled_posts_webhook_table.php

رفع إلى: /public_html/mediaprosocial.io/app/Models/  
الملف: ScheduledPost.php

رفع إلى: /public_html/mediaprosocial.io/app/Http/Controllers/Api/
الملف: ScheduledPostController.php

رفع إلى: /public_html/mediaprosocial.io/app/Jobs/
الملف: PublishScheduledPostJob.php

رفع إلى: /public_html/mediaprosocial.io/app/Services/
الملف: WebhookPublisherService.php
```

**AI Video System Files:**
```
رفع إلى: /public_html/mediaprosocial.io/database/migrations/
الملف: 2025_11_19_120000_create_ai_generated_videos_table.php

رفع إلى: /public_html/mediaprosocial.io/app/Models/
الملف: AiGeneratedVideo.php

رفع إلى: /public_html/mediaprosocial.io/app/Services/
الملف: AIVideoGeneratorService.php

رفع إلى: /public_html/mediaprosocial.io/app/Jobs/
الملف: GenerateAIVideoJob.php
الملف: CheckVideoGenerationStatusJob.php

رفع إلى: /public_html/mediaprosocial.io/app/Http/Controllers/Api/
الملف: AIVideoController.php
```

#### 4. تشغيل الأوامر من Terminal في cPanel
```bash
cd /public_html/mediaprosocial.io
php artisan migrate
php artisan config:clear
php artisan cache:clear
```

---

### الطريقة 2: استخدام FTP Client

#### أفضل البرامج المجانية:
1. **FileZilla** - https://filezilla-project.org/
2. **WinSCP** - https://winscp.net/
3. **VS Code SFTP Extension**

#### إعدادات الاتصال:
```
Host: 82.25.83.217
Port: 21 (FTP) أو 22 (SFTP)  
Username: root أو اسم مستخدم cPanel
Password: كلمة المرور
Protocol: FTP أو SFTP
```

---

### الطريقة 3: استخدام Git (إذا كان متاح)

#### إذا كان Git مثبت على السيرفر:
```bash
# على السيرفر
cd /public_html/mediaprosocial.io
git pull origin master

# أو clone إذا لم يكن موجود
git clone https://github.com/Amalhussein1992/mediapro.git
```

---

## 📋 قائمة الملفات للرفع (نسخ جاهزة)

### الملفات الموجودة محلياً:

```bash
المسار المحلي: C:\Users\HP\social_media_manager\backend\

1. database\migrations\2025_01_19_100000_create_scheduled_posts_webhook_table.php
2. database\migrations\2025_11_19_120000_create_ai_generated_videos_table.php
3. app\Models\ScheduledPost.php  
4. app\Models\AiGeneratedVideo.php
5. app\Http\Controllers\Api\ScheduledPostController.php
6. app\Http\Controllers\Api\AIVideoController.php
7. app\Jobs\PublishScheduledPostJob.php
8. app\Jobs\GenerateAIVideoJob.php
9. app\Jobs\CheckVideoGenerationStatusJob.php
10. app\Services\WebhookPublisherService.php
11. app\Services\AIVideoGeneratorService.php
```

---

## ⚡ بعد رفع الملفات

### 1. تشغيل Commands (أهم خطوة)
```bash
# في Terminal السيرفر أو cPanel Terminal
cd /public_html/mediaprosocial.io

# تشغيل migrations الجديدة  
php artisan migrate

# تنظيف cache
php artisan config:clear
php artisan cache:clear  
php artisan view:clear

# تحديث autoload
composer dump-autoload
```

### 2. إضافة Routes الجديدة
**تحرير ملف:** `/public_html/mediaprosocial.io/routes/api.php`

**أضف في نهاية الملف:**
```php
// Webhook & Scheduled Posts Routes
Route::middleware('auth:sanctum')->prefix('scheduled-posts')->group(function () {
    Route::get('/', [ScheduledPostController::class, 'index']);
    Route::post('/', [ScheduledPostController::class, 'store']);
    Route::get('/{id}', [ScheduledPostController::class, 'show']);
    Route::put('/{id}', [ScheduledPostController::class, 'update']);
    Route::delete('/{id}', [ScheduledPostController::class, 'destroy']);
    Route::post('/{id}/trigger', [ScheduledPostController::class, 'trigger']);
});

// AI Video Generation Routes
Route::middleware('auth:sanctum')->prefix('ai-videos')->group(function () {
    Route::get('/', [AIVideoController::class, 'index']);
    Route::post('/', [AIVideoController::class, 'store']);
    Route::get('/providers', [AIVideoController::class, 'providers']);
    Route::get('/stats', [AIVideoController::class, 'stats']);
    Route::get('/{id}', [AIVideoController::class, 'show']);
    Route::delete('/{id}', [AIVideoController::class, 'destroy']);
    Route::get('/{id}/download', [AIVideoController::class, 'download']);
    Route::post('/{id}/retry', [AIVideoController::class, 'retry']);
});

// Public webhook endpoint
Route::post('/webhook/pabbly', [ScheduledPostController::class, 'webhook']);
```

### 3. تحديث .env File
**تحرير:** `/public_html/mediaprosocial.io/.env`

**أضف هذه المتغيرات:**
```env
# Webhook Configuration
PABBLY_WEBHOOK_URL=https://connect.pabbly.com/webhook/YOUR_WEBHOOK_ID
WEBHOOK_SECRET=your_secret_key_here

# AI Video Generation APIs
RUNWAY_API_KEY=your_runway_api_key_here
PIKA_API_KEY=your_pika_api_key_here
DID_API_KEY=your_d_id_api_key_here
STABILITY_API_KEY=your_stability_api_key_here

# Queue Configuration
QUEUE_CONNECTION=database
QUEUE_FAILED_DRIVER=database
```

---

## 🧪 اختبار سريع

### 1. اختبار Database
```bash
php artisan migrate:status
```
**المتوقع:** رؤية الـ migrations الجديدة مُنفذة ✅

### 2. اختبار APIs
```bash
curl -X GET http://82.25.83.217/api/admin/users
```
**المتوقع:** استجابة JSON صحيحة ✅

### 3. فحص الجداول الجديدة
```sql
-- في phpMyAdmin أو قاعدة البيانات
SHOW TABLES;
-- يجب رؤية: scheduled_posts, ai_generated_videos
```

---

## ✅ قائمة التحقق السريع

### بعد الرفع:
- [ ] جميع الملفات مرفوعة في المسارات الصحيحة
- [ ] تم تشغيل `php artisan migrate`
- [ ] تم إضافة Routes في api.php
- [ ] تم تحديث .env بالمتغيرات الجديدة
- [ ] تم تشغيل `php artisan config:clear`
- [ ] اختبار API يعطي استجابة صحيحة

### النتيجة المتوقعة:
✅ **نظام Webhook نشط**  
✅ **نظام AI Video جاهز**  
✅ **قاعدة البيانات محدّثة**  
✅ **APIs جديدة متاحة**  
✅ **المشروع مكتمل 100%**  

---

## 🚀 الخطوة الأخيرة (اختيارية)

### إعداد Queue Worker (للأداء الأمثل)
```bash
# إنشاء service للـ queue
sudo nano /etc/systemd/system/laravel-queue.service

# المحتوى:
[Unit]  
Description=Laravel Queue Worker
After=network.target

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /public_html/mediaprosocial.io/artisan queue:work --daemon
StandardOutput=journal

[Install]
WantedBy=multi-user.target

# تفعيل
sudo systemctl enable laravel-queue.service
sudo systemctl start laravel-queue.service
```

### إعداد Cron Job
```bash
# فتح crontab
crontab -e

# إضافة:
* * * * * cd /public_html/mediaprosocial.io && php artisan schedule:run >> /dev/null 2>&1
```

---

## 🎯 النهاية 

بعد إتمام هذه الخطوات:

### ✅ ستحصل على:
1. **مشروع Social Media Manager مكتمل 100%**
2. **نظام Webhook يعمل مع Pabbly Connect**  
3. **نظام AI Video Generation بـ 4 مقدمين**
4. **Flutter App جاهز للإطلاق**
5. **Backend API شامل ومحسّن**

### 🚀 المرحلة التالية:
**إطلاق المشروع على Google Play Store!** 

---

**الوقت المتوقع للإنجاز:** 1-2 ساعة  
**مستوى الصعوبة:** سهل (copy & paste)  
**النتيجة:** ✅ **مشروع مكتمل 100%** 

هل تريد البدء بالطريقة الأولى (cPanel) أم الثانية (FTP)؟ 🤔