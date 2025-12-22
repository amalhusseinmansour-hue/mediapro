# 🚀 خطة الـ 60 دقيقة - ابدأ الآن!

**⏰ البداية:** الآن  
**⏰ النهاية:** بعد 60 دقيقة  
**🎯 الهدف:** مشروع مكتمل 100%  

---

## 📋 المهام السريعة (4 مراحل)

### 🔥 المرحلة 1 (0-15 دقيقة): رفع الملفات السريع

#### استخدم هذه الطريقة الأسهل:
1. **افتح متصفح الويب**
2. **اذهب إلى:** `https://82.25.83.217:2083` أو `https://cpanel.yourdomain.com`
3. **ادخل بيانات cPanel**
4. **اضغط "File Manager"**
5. **انتقل إلى:** `public_html/mediaprosocial.io/`

#### ارفع هذه الملفات (11 ملف):

**في مجلد `database/migrations/`:**
- `2025_01_19_100000_create_scheduled_posts_webhook_table.php`
- `2025_11_19_120000_create_ai_generated_videos_table.php`

**في مجلد `app/Models/`:**
- `ScheduledPost.php`
- `AiGeneratedVideo.php`

**في مجلد `app/Http/Controllers/Api/`:**
- `ScheduledPostController.php`
- `AIVideoController.php`

**في مجلد `app/Jobs/`:**
- `PublishScheduledPostJob.php`
- `GenerateAIVideoJob.php`
- `CheckVideoGenerationStatusJob.php`

**في مجلد `app/Services/`:**
- `WebhookPublisherService.php`
- `AIVideoGeneratorService.php`

---

### ⚡ المرحلة 2 (15-25 دقيقة): تشغيل الأوامر

#### افتح Terminal في cPanel أو اتصل بـ SSH:
```bash
# انتقل للمجلد
cd /public_html/mediaprosocial.io

# شغّل migrations
php artisan migrate

# نظّف cache
php artisan config:clear
php artisan cache:clear
php artisan view:clear

# حدّث composer
composer dump-autoload
```

---

### 🔧 المرحلة 3 (25-40 دقيقة): إضافة الإعدادات

#### أ) أضف Routes في `routes/api.php`:
**انسخ والصق هذا في نهاية الملف:**
```php
// Webhook & Scheduled Posts Routes
Route::middleware('auth:sanctum')->prefix('scheduled-posts')->group(function () {
    Route::get('/', [App\Http\Controllers\Api\ScheduledPostController::class, 'index']);
    Route::post('/', [App\Http\Controllers\Api\ScheduledPostController::class, 'store']);
    Route::get('/{id}', [App\Http\Controllers\Api\ScheduledPostController::class, 'show']);
    Route::put('/{id}', [App\Http\Controllers\Api\ScheduledPostController::class, 'update']);
    Route::delete('/{id}', [App\Http\Controllers\Api\ScheduledPostController::class, 'destroy']);
    Route::post('/{id}/trigger', [App\Http\Controllers\Api\ScheduledPostController::class, 'trigger']);
});

// AI Video Generation Routes
Route::middleware('auth:sanctum')->prefix('ai-videos')->group(function () {
    Route::get('/', [App\Http\Controllers\Api\AIVideoController::class, 'index']);
    Route::post('/', [App\Http\Controllers\Api\AIVideoController::class, 'store']);
    Route::get('/providers', [App\Http\Controllers\Api\AIVideoController::class, 'providers']);
    Route::get('/stats', [App\Http\Controllers\Api\AIVideoController::class, 'stats']);
    Route::get('/{id}', [App\Http\Controllers\Api\AIVideoController::class, 'show']);
    Route::delete('/{id}', [App\Http\Controllers\Api\AIVideoController::class, 'destroy']);
    Route::get('/{id}/download', [App\Http\Controllers\Api\AIVideoController::class, 'download']);
    Route::post('/{id}/retry', [App\Http\Controllers\Api\AIVideoController::class, 'retry']);
});

// Public webhook
Route::post('/webhook/pabbly', [App\Http\Controllers\Api\ScheduledPostController::class, 'webhook']);
```

#### ب) أضف Variables في `.env`:
**انسخ والصق هذا في نهاية ملف .env:**
```env
# Webhook System
PABBLY_WEBHOOK_URL=https://connect.pabbly.com/webhook/YOUR_WEBHOOK_ID
WEBHOOK_SECRET=your_secure_secret_key

# AI Video APIs
RUNWAY_API_KEY=your_runway_key_here
PIKA_API_KEY=your_pika_key_here
DID_API_KEY=your_did_key_here
STABILITY_API_KEY=your_stability_key_here

# Queue Settings
QUEUE_CONNECTION=database
QUEUE_FAILED_DRIVER=database
```

#### ج) شغّل أمر التحديث:
```bash
php artisan config:clear
```

---

### 🧪 المرحلة 4 (40-60 دقيقة): اختبار سريع

#### اختبار 1: فحص Database
```bash
php artisan migrate:status
# يجب رؤية: create_scheduled_posts_webhook_table ✅
# يجب رؤية: create_ai_generated_videos_table ✅
```

#### اختبار 2: فحص API
```bash
curl -X GET http://82.25.83.217/api/admin/users
# يجب الحصول على استجابة JSON ✅
```

#### اختبار 3: فحص Routes الجديدة
```bash
curl -X GET http://82.25.83.217/api/webhook/health
# أو زيارة الرابط في المتصفح
```

---

## ✅ قائمة التحقق السريع

### الدقيقة 15: ✅ رفع الملفات مكتمل
- [ ] 11 ملف مرفوع في المسارات الصحيحة

### الدقيقة 25: ✅ تشغيل الأوامر مكتمل  
- [ ] تم تشغيل `php artisan migrate`
- [ ] تم تشغيل أوامر تنظيف cache

### الدقيقة 40: ✅ إضافة الإعدادات مكتمل
- [ ] تم إضافة Routes في api.php
- [ ] تم إضافة Variables في .env
- [ ] تم تشغيل `php artisan config:clear`

### الدقيقة 60: ✅ اختبار واستكشاف مكتمل
- [ ] migrations تعمل بنجاح
- [ ] APIs تستجيب بشكل صحيح
- [ ] لا توجد أخطاء في logs

---

## 🎊 النتيجة بعد 60 دقيقة:

### ✅ مشروع Social Media Manager مكتمل 100%!

**المميزات النهائية:**
- 🔥 **Flutter App** كامل ومكتمل
- 🔥 **نظام Webhook** للنشر التلقائي
- 🔥 **نظام AI Video Generation** مع 4 مقدمين
- 🔥 **نظام Automation** متقدم  
- 🔥 **Backend API** شامل ومحسّن
- 🔥 **Database** محدّث ومُحسن
- 🔥 **جاهز للإنتاج** فوراً

---

## 🚦 إشارة البدء

### ⏰ ابدأ العد التنازلي الآن!

**الدقيقة 0:** افتح cPanel → File Manager  
**الدقيقة 15:** انتهاء الرفع  
**الدقيقة 25:** انتهاء الأوامر  
**الدقيقة 40:** انتهاء الإعدادات  
**الدقيقة 60:** ✅ **مشروع مكتمل!**  

### 🎯 ابدأ الآن!

**الخطوة الأولى:** افتح `https://82.25.83.217:2083` في المتصفح

**🔥 العد التنازلي بدأ! 60... 59... 58... 🔥**

---

**سأتابع معك كل خطوة! أخبرني عند الانتهاء من كل مرحلة!** 🚀