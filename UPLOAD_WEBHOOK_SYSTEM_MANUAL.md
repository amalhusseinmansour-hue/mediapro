# 🚀 دليل رفع Webhook System يدوياً على السيرفر

**التاريخ:** 19 نوفمبر 2025  
**الهدف:** رفع جميع ملفات نظام الـ Webhook على السيرفر وتفعيلها  

---

## 📁 قائمة الملفات المطلوب رفعها

### 1. Migration Files
```bash
المسار المحلي: C:\Users\HP\social_media_manager\backend\database\migrations\
مسار السيرفر: /var/www/html/mediaprosocial.io/database/migrations/

الملفات:
- 2025_01_19_100000_create_scheduled_posts_webhook_table.php
```

### 2. Model Files
```bash
المسار المحلي: C:\Users\HP\social_media_manager\backend\app\Models\
مسار السيرفر: /var/www/html/mediaprosocial.io/app/Models/

الملفات:
- ScheduledPost.php
```

### 3. Controller Files
```bash
المسار المحلي: C:\Users\HP\social_media_manager\backend\app\Http\Controllers\Api\
مسار السيرفر: /var/www/html/mediaprosocial.io/app/Http/Controllers/Api/

الملفات:
- ScheduledPostController.php
```

### 4. Job Files
```bash
المسار المحلي: C:\Users\HP\social_media_manager\backend\app\Jobs\
مسار السيرفر: /var/www/html/mediaprosocial.io/app/Jobs/

الملفات:
- PublishScheduledPostJob.php
```

### 5. Service Files
```bash
المسار المحلي: C:\Users\HP\social_media_manager\backend\app\Services\
مسار السيرفر: /var/www/html/mediaprosocial.io/app/Services/

الملفات:
- WebhookPublisherService.php
```

---

## 🔧 خطوات الرفع اليدوي

### الطريقة 1: باستخدام FileZilla (الأسهل)

#### 1. تحميل FileZilla
- قم بتحميل FileZilla Client من الموقع الرسمي

#### 2. إعداد الاتصال
```
Protocol: SFTP - SSH File Transfer Protocol
Host: 82.25.83.217
Port: 22
Logon Type: Normal
User: root
Password: كلمة مرور السيرفر
```

#### 3. الاتصال والرفع
1. اضغط "Quickconnect"
2. انتقل إلى مجلد `/var/www/html/mediaprosocial.io/`
3. ارفع كل ملف في مجلده المناسب حسب الجدول أعلاه

### الطريقة 2: باستخدام WinSCP

#### 1. تحميل WinSCP
- قم بتحميل WinSCP من الموقع الرسمي

#### 2. إعداد الاتصال
```
File protocol: SFTP
Host name: 82.25.83.217
Port number: 22
User name: root
Password: كلمة مرور السيرفر
```

#### 3. الاتصال والرفع
1. اضغط "Login"
2. انتقل إلى `/var/www/html/mediaprosocial.io/`
3. ارفع الملفات في أماكنها

### الطريقة 3: باستخدام VS Code Extensions

#### 1. تثبيت Extension
- ثبت SFTP أو SSH FS extension في VS Code

#### 2. إعداد الاتصال
```json
{
    "name": "Server",
    "host": "82.25.83.217",
    "port": 22,
    "username": "root",
    "password": "كلمة مرور السيرفر",
    "remotePath": "/var/www/html/mediaprosocial.io/",
    "uploadOnSave": true
}
```

#### 3. رفع الملفات
- انقر بالزر الأيمن على كل ملف واختر "Upload"

---

## ⚡ أوامر تشغيل بعد الرفع

بعد رفع جميع الملفات، قم بتشغيل الأوامر التالية على السيرفر:

### 1. تسجيل الدخول إلى السيرفر
```bash
ssh root@82.25.83.217
```

### 2. الانتقال إلى مجلد المشروع
```bash
cd /var/www/html/mediaprosocial.io
```

### 3. تشغيل Migration الجديد
```bash
php artisan migrate
```

### 4. تنظيف Cache
```bash
php artisan config:clear
php artisan cache:clear
php artisan view:clear
```

### 5. تحديث Composer (إذا لزم الأمر)
```bash
composer dump-autoload
```

---

## 🔄 إعداد Queue Worker

### 1. تشغيل Queue Worker مؤقتاً
```bash
php artisan queue:work --daemon
```

### 2. إعداد Service دائم (مهم جداً)
```bash
# إنشاء service file
sudo nano /etc/systemd/system/laravel-queue.service
```

أضف المحتوى التالي:
```ini
[Unit]
Description=Laravel Queue Worker
After=network.target

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/html/mediaprosocial.io/artisan queue:work --daemon --sleep=3 --tries=3 --timeout=90
StandardOutput=journal
StandardError=journal
SyslogIdentifier=laravel-queue

[Install]
WantedBy=multi-user.target
```

ثم:
```bash
sudo systemctl daemon-reload
sudo systemctl enable laravel-queue.service
sudo systemctl start laravel-queue.service
sudo systemctl status laravel-queue.service
```

---

## ⏰ إعداد Cron Job للـ Scheduler

### 1. فتح Crontab
```bash
crontab -e
```

### 2. إضافة السطر التالي
```bash
* * * * * cd /var/www/html/mediaprosocial.io && php artisan schedule:run >> /dev/null 2>&1
```

### 3. حفظ والخروج
اضغط `Ctrl + X` ثم `Y` ثم `Enter`

---

## 🌍 إضافة Environment Variables

### 1. تحرير ملف .env
```bash
nano /var/www/html/mediaprosocial.io/.env
```

### 2. إضافة المتغيرات الجديدة
```env
# Webhook Configuration
PABBLY_WEBHOOK_URL=https://connect.pabbly.com/webhook/YOUR_WEBHOOK_ID
WEBHOOK_SECRET=your_secret_key_here

# Queue Configuration
QUEUE_CONNECTION=database
QUEUE_FAILED_DRIVER=database

# Ayrshare Configuration (اختياري)
AYRSHARE_API_KEY=your_ayrshare_key_here
```

### 3. إعادة تحميل Config
```bash
php artisan config:clear
php artisan config:cache
```

---

## 🔍 إضافة Routes (مهم)

### 1. فتح ملف api.php
```bash
nano /var/www/html/mediaprosocial.io/routes/api.php
```

### 2. إضافة Routes الجديدة
```php
// Webhook & Scheduled Posts Routes
Route::middleware('auth:sanctum')->group(function () {
    Route::prefix('scheduled-posts')->group(function () {
        Route::get('/', [ScheduledPostController::class, 'index']);
        Route::post('/', [ScheduledPostController::class, 'store']);
        Route::get('/{id}', [ScheduledPostController::class, 'show']);
        Route::put('/{id}', [ScheduledPostController::class, 'update']);
        Route::delete('/{id}', [ScheduledPostController::class, 'destroy']);
        Route::post('/{id}/trigger', [ScheduledPostController::class, 'trigger']);
    });
});

// Public webhook endpoint
Route::post('/webhook/pabbly', [ScheduledPostController::class, 'webhook']);
```

### 3. حفظ الملف
اضغط `Ctrl + X` ثم `Y` ثم `Enter`

---

## ✅ اختبار النظام

### 1. اختبار API
```bash
curl -X POST http://82.25.83.217/api/scheduled-posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "content": "Test post from webhook",
    "scheduled_at": "2025-01-20 15:00:00",
    "platforms": ["facebook", "instagram"]
  }'
```

### 2. اختبار Queue
```bash
php artisan queue:work --once
```

### 3. اختبار Scheduler
```bash
php artisan schedule:run
```

### 4. اختبار Webhook
```bash
curl -X POST http://82.25.83.217/api/webhook/pabbly \
  -H "Content-Type: application/json" \
  -d '{
    "action": "publish_post",
    "content": "Hello from Pabbly!",
    "platforms": ["facebook"]
  }'
```

---

## 📊 مراقبة الحالة

### 1. فحص Queue Status
```bash
php artisan queue:monitor
```

### 2. فحص Failed Jobs
```bash
php artisan queue:failed
```

### 3. فحص Logs
```bash
tail -f /var/www/html/mediaprosocial.io/storage/logs/laravel.log
```

### 4. فحص Service Status
```bash
sudo systemctl status laravel-queue.service
```

---

## 🚨 حل المشاكل المحتملة

### مشكلة: Permission Denied
```bash
sudo chown -R www-data:www-data /var/www/html/mediaprosocial.io
sudo chmod -R 755 /var/www/html/mediaprosocial.io
sudo chmod -R 775 /var/www/html/mediaprosocial.io/storage
sudo chmod -R 775 /var/www/html/mediaprosocial.io/bootstrap/cache
```

### مشكلة: Migration لا يعمل
```bash
php artisan migrate:status
php artisan migrate --force
```

### مشكلة: Queue لا يعمل
```bash
sudo systemctl restart laravel-queue.service
php artisan queue:restart
```

### مشكلة: Scheduler لا يعمل
```bash
# تأكد من إضافة cron job
crontab -l
```

---

## 📝 ملخص خطوات ما بعد الرفع

1. ✅ رفع جميع الملفات
2. ✅ تشغيل Migration
3. ✅ إعداد Queue Worker Service
4. ✅ إعداد Cron Job
5. ✅ إضافة Environment Variables
6. ✅ إضافة Routes
7. ✅ اختبار النظام
8. ✅ مراقبة الحالة

---

## 🎯 النتيجة المتوقعة

بعد إتمام جميع الخطوات:

✅ **Webhook System** سيكون نشطاً ويعمل  
✅ **Scheduled Posts** ستُنشر تلقائياً  
✅ **Queue Worker** سيعالج المهام في الخلفية  
✅ **Cron Job** سيراقب المواعيد المحددة  
✅ **API Endpoints** ستكون متاحة للـ Flutter App  

---

**ملاحظة مهمة:** بعد إتمام هذه الخطوات، ستحتاج إلى إنشاء workflow في Pabbly Connect وربطه مع Facebook/Instagram APIs لاكتمال النظام.

**التوقيت المتوقع:** 30-60 دقيقة لإتمام جميع الخطوات.

**حالة الإنجاز:** ستصل إلى 85% من إكمال المشروع بعد هذه الخطوة! 🎉