# 📦 حزمة الملفات الجاهزة للرفع

## 🎯 المحتويات

هذا الملف يحتوي على قائمة شاملة بجميع الملفات التي تحتاج رفعها:

### 1. Webhook System Files ✅

#### Migration File:
**المسار المحلي:** `C:\Users\HP\social_media_manager\backend\database\migrations\2025_01_19_100000_create_scheduled_posts_webhook_table.php`  
**مسار السيرفر:** `/public_html/mediaprosocial.io/database/migrations/`

#### Model File:  
**المسار المحلي:** `C:\Users\HP\social_media_manager\backend\app\Models\ScheduledPost.php`  
**مسار السيرفر:** `/public_html/mediaprosocial.io/app/Models/`

#### Controller File:
**المسار المحلي:** `C:\Users\HP\social_media_manager\backend\app\Http\Controllers\Api\ScheduledPostController.php`  
**مسار السيرفر:** `/public_html/mediaprosocial.io/app/Http/Controllers/Api/`

#### Job File:
**المسار المحلي:** `C:\Users\HP\social_media_manager\backend\app\Jobs\PublishScheduledPostJob.php`  
**مسار السيرفر:** `/public_html/mediaprosocial.io/app/Jobs/`

#### Service File:
**المسار المحلي:** `C:\Users\HP\social_media_manager\backend\app\Services\WebhookPublisherService.php`  
**مسار السيرفر:** `/public_html/mediaprosocial.io/app/Services/`

---

### 2. AI Video System Files ✅

#### Migration File:
**المسار المحلي:** `C:\Users\HP\social_media_manager\backend\database\migrations\2025_11_19_120000_create_ai_generated_videos_table.php`  
**مسار السيرفر:** `/public_html/mediaprosocial.io/database/migrations/`

#### Model File:
**المسار المحلي:** `C:\Users\HP\social_media_manager\backend\app\Models\AiGeneratedVideo.php`  
**مسار السيرفر:** `/public_html/mediaprosocial.io/app/Models/`

#### Service File:
**المسار المحلي:** `C:\Users\HP\social_media_manager\backend\app\Services\AIVideoGeneratorService.php`  
**مسار السيرفر:** `/public_html/mediaprosocial.io/app/Services/`

#### Job Files:
**المسار المحلي:** `C:\Users\HP\social_media_manager\backend\app\Jobs\GenerateAIVideoJob.php`  
**مسار السيرفر:** `/public_html/mediaprosocial.io/app/Jobs/`

**المسار المحلي:** `C:\Users\HP\social_media_manager\backend\app\Jobs\CheckVideoGenerationStatusJob.php`  
**مسار السيرفر:** `/public_html/mediaprosocial.io/app/Jobs/`

#### Controller File:
**المسار المحلي:** `C:\Users\HP\social_media_manager\backend\app\Http\Controllers\Api\AIVideoController.php`  
**مسار السيرفر:** `/public_html/mediaprosocial.io/app/Http/Controllers/Api/`

---

## 🔧 أوامر تشغيل بعد الرفع

### في Terminal السيرفر:
```bash
cd /public_html/mediaprosocial.io

# تشغيل migrations
php artisan migrate

# تنظيف cache  
php artisan config:clear
php artisan cache:clear
php artisan view:clear

# تحديث composer
composer dump-autoload

# تحديث permissions
chown -R www-data:www-data .
chmod -R 755 .
chmod -R 775 storage bootstrap/cache
```

---

## ✅ ملخص الرفع

### إجمالي الملفات: **11 ملف**

**Migrations:** 2 ملف  
**Models:** 2 ملف  
**Controllers:** 2 ملف  
**Jobs:** 3 ملف  
**Services:** 2 ملف  

**الوقت المتوقع:** 30-60 دقيقة  
**الصعوبة:** سهل جداً  

---

## 🎯 بعد الرفع

### النتيجة المتوقعة:
✅ **مشروع مكتمل 100%**  
✅ **نظام Webhook نشط**  
✅ **نظام AI Video جاهز**  
✅ **قاعدة البيانات محدّثة**  
✅ **جاهز للإنتاج**  

**🎉 مبروك مقدماً! 🎉**