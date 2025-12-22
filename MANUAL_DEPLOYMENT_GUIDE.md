# 📦 دليل رفع التحديثات على السيرفر - خطوة بخطوة

## 🎯 نظرة عامة
هذا الدليل يوضح كيفية رفع جميع التحديثات على السيرفر بشكل يدوي.

---

## 📋 الملفات المطلوب رفعها

### 1. Controllers (PHP Files)
- ✅ `WEBSITE_REQUEST_CONTROLLER.php` → رفعه إلى `/app/Http/Controllers/WebsiteRequestController.php`
- ✅ `SPONSORED_ADS_REQUEST_CONTROLLER.php` → رفعه إلى `/app/Http/Controllers/SponsoredAdsRequestController.php`

### 2. SQL Migrations
- ✅ `WEBSITE_REQUESTS_MIGRATION.sql`
- ✅ `SPONSORED_ADS_REQUESTS_MIGRATION.sql`

---

## 🚀 الطريقة 1: رفع عبر File Manager (الأسهل)

### الخطوة 1: رفع Controllers

1. **اذهب إلى cPanel** → **File Manager**
2. **انتقل إلى المسار:**
   ```
   /home/u126213189/domains/mediaprosocial.io/public_html/app/Http/Controllers/
   ```
3. **اضغط Upload** ورفع:
   - `WEBSITE_REQUEST_CONTROLLER.php` (أعد تسميته إلى `WebsiteRequestController.php`)
   - `SPONSORED_ADS_REQUEST_CONTROLLER.php` (أعد تسميته إلى `SponsoredAdsRequestController.php`)

---

### الخطوة 2: تنفيذ SQL Migrations

1. **اذهب إلى cPanel** → **phpMyAdmin**
2. **اختر قاعدة البيانات** الخاصة بالتطبيق
3. **اضغط على تبويب SQL**
4. **نفذ أولاً:** محتوى ملف `WEBSITE_REQUESTS_MIGRATION.sql`
   - انسخ جميع المحتوى والصقه
   - اضغط **Go**
5. **نفذ ثانياً:** محتوى ملف `SPONSORED_ADS_REQUESTS_MIGRATION.sql`
   - انسخ جميع المحتوى والصقه
   - اضغط **Go**

---

### الخطوة 3: إضافة Routes في api.php

1. **افتح File Manager** → انتقل إلى:
   ```
   /home/u126213189/domains/mediaprosocial.io/public_html/routes/api.php
   ```

2. **أضف في أول الملف** (بعد use statements):
   ```php
   use App\Http\Controllers\WebsiteRequestController;
   use App\Http\Controllers\SponsoredAdsRequestController;
   ```

3. **أضف Routes للمستخدمين** (داخل middleware auth:sanctum):
   ```php
   // Website Requests Routes
   Route::middleware(['auth:sanctum'])->group(function () {
       Route::post('/website-requests', [WebsiteRequestController::class, 'store']);
       Route::get('/website-requests', [WebsiteRequestController::class, 'index']);
       Route::get('/website-requests/{id}', [WebsiteRequestController::class, 'show']);
       Route::delete('/website-requests/{id}', [WebsiteRequestController::class, 'destroy']);
       Route::get('/website-requests/statistics', [WebsiteRequestController::class, 'statistics']);

       // Sponsored Ads Routes
       Route::post('/sponsored-ads-requests', [SponsoredAdsRequestController::class, 'store']);
       Route::get('/sponsored-ads-requests', [SponsoredAdsRequestController::class, 'index']);
       Route::get('/sponsored-ads-requests/{id}', [SponsoredAdsRequestController::class, 'show']);
       Route::delete('/sponsored-ads-requests/{id}', [SponsoredAdsRequestController::class, 'destroy']);
       Route::get('/sponsored-ads-requests/statistics', [SponsoredAdsRequestController::class, 'statistics']);
   });
   ```

4. **أضف Routes للإدارة** (للإدارة فقط):
   ```php
   Route::middleware(['auth:sanctum'])->prefix('admin')->group(function () {
       // Website Requests Admin
       Route::get('/website-requests', [WebsiteRequestController::class, 'adminIndex']);
       Route::put('/website-requests/{id}', [WebsiteRequestController::class, 'adminUpdate']);

       // Sponsored Ads Admin
       Route::get('/sponsored-ads-requests', [SponsoredAdsRequestController::class, 'adminIndex']);
       Route::put('/sponsored-ads-requests/{id}', [SponsoredAdsRequestController::class, 'adminUpdate']);
   });
   ```

---

### الخطوة 4: مسح Cache

1. **اذهب إلى cPanel** → **Terminal**
2. **نفذ الأوامر التالية:**
   ```bash
   cd /home/u126213189/domains/mediaprosocial.io/public_html
   php artisan config:clear
   php artisan cache:clear
   php artisan route:clear
   ```

---

## 🚀 الطريقة 2: رفع عبر FTP/SFTP

### استخدام FileZilla أو أي FTP Client:

**معلومات الاتصال:**
- Host: `sftp://82.25.83.217`
- Port: `65002`
- Username: `u126213189`
- Password: `Alenwanapp33510421@`
- Protocol: SFTP

**رفع الملفات:**
1. اتصل بالسيرفر
2. انتقل إلى `/home/u126213189/domains/mediaprosocial.io/public_html/app/Http/Controllers/`
3. ارفع:
   - `WEBSITE_REQUEST_CONTROLLER.php` → أعد تسميته `WebsiteRequestController.php`
   - `SPONSORED_ADS_REQUEST_CONTROLLER.php` → أعد تسميته `SponsoredAdsRequestController.php`

ثم اتبع الخطوات 2-4 من الطريقة 1.

---

## 🚀 الطريقة 3: رفع عبر Command Line (PowerShell/CMD)

### الأوامر الجاهزة:

```powershell
# 1. رفع WebsiteRequestController
& "C:\Program Files\PuTTY\pscp" -P 65002 -pw "Alenwanapp33510421@" `
  "C:\Users\HP\social_media_manager\WEBSITE_REQUEST_CONTROLLER.php" `
  u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/app/Http/Controllers/WebsiteRequestController.php

# 2. رفع SponsoredAdsRequestController
& "C:\Program Files\PuTTY\pscp" -P 65002 -pw "Alenwanapp33510421@" `
  "C:\Users\HP\social_media_manager\SPONSORED_ADS_REQUEST_CONTROLLER.php" `
  u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/app/Http/Controllers/SponsoredAdsRequestController.php

# 3. مسح Cache
& "C:\Program Files\PuTTY\plink" -batch -P 65002 -pw "Alenwanapp33510421@" `
  u126213189@82.25.83.217 `
  -hostkey "ssh-ed25519 255 SHA256:FU/mr+GKSXqaOTBEpxpTOABktDVs2uSwxBkng087mw4" `
  "cd /home/u126213189/domains/mediaprosocial.io/public_html && php artisan config:clear && php artisan cache:clear && php artisan route:clear"
```

**تشغيل الأوامر:**
1. افتح PowerShell كمسؤول
2. انسخ الأوامر والصقها
3. اضغط Enter

ثم اتبع الخطوات 2-3 من الطريقة 1 (SQL + Routes).

---

## ✅ التحقق من نجاح التحديث

### 1. التحقق من رفع الملفات:
```bash
# عبر Terminal في cPanel
cd /home/u126213189/domains/mediaprosocial.io/public_html/app/Http/Controllers/
ls -la WebsiteRequestController.php
ls -la SponsoredAdsRequestController.php
```

يجب أن تظهر الملفات.

### 2. التحقق من الجداول:
```sql
-- في phpMyAdmin
SHOW TABLES LIKE '%requests%';
```

يجب أن تظهر:
- `website_requests`
- `sponsored_ads_requests`

### 3. التحقق من Routes:
```bash
# في Terminal
cd /home/u126213189/domains/mediaprosocial.io/public_html
php artisan route:list | grep requests
```

يجب أن تظهر جميع Routes الجديدة.

---

## 🧪 اختبار APIs

### 1. اختبار Website Request:
```bash
curl -X POST https://mediaprosocial.io/api/website-requests \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "phone": "0501234567",
    "company_name": "Test Company",
    "website_type": "corporate",
    "description": "Test website request description with more than 20 characters",
    "budget": 5000
  }'
```

### 2. اختبار Sponsored Ads Request:
```bash
curl -X POST https://mediaprosocial.io/api/sponsored-ads-requests \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "phone": "0501234567",
    "company_name": "Test Company",
    "ad_type": "social_media",
    "campaign_goal": "awareness",
    "ad_content": "Test ad content with more than 20 characters for testing",
    "budget": 3000,
    "duration_days": 30
  }'
```

---

## 🎉 تم!

بعد اتباع هذه الخطوات، سيكون لديك:

✅ نظام طلبات المواقع الإلكترونية جاهز
✅ نظام طلبات الإعلانات الممولة جاهز
✅ APIs كاملة للتطبيق
✅ قاعدة بيانات محدثة

---

## 🔥 الخطوة التالية: تحديث التطبيق

تطبيق Flutter جاهز بالفعل مع:
- ✅ شاشة طلب موقع جديد
- ✅ شاشة عرض طلبات المواقع
- ✅ شاشة عرض حالة الطلبات

**لاختبار التطبيق:**
```bash
cd C:\Users\HP\social_media_manager
flutter run -d R9KY902X3HW
```

---

## 📞 في حالة وجود مشاكل

### المشكلة: Controller not found
```bash
# تأكد من اسم الملف الصحيح (حساس لحالة الأحرف)
composer dump-autoload
```

### المشكلة: Route not found
```bash
# مسح Cache مرة أخرى
php artisan route:clear
php artisan cache:clear
```

### المشكلة: Table doesn't exist
```
# نفذ SQL Migrations مرة أخرى في phpMyAdmin
```

---

✅ **كل شيء جاهز! استمتع بالمميزات الجديدة!** 🚀
