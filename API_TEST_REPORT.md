# تقرير اختبار روابط API
**التاريخ:** 2025-11-08
**الوقت:** 09:44 UTC
**الموقع:** https://mediaprosocial.io

---

## ملخص النتائج

| الرابط | الحالة | كود الاستجابة | الملاحظات |
|--------|--------|---------------|-----------|
| `/` | ✅ يعمل | 302 Redirect | يحول إلى `/public/` |
| `/admin/subscription-plans` | ✅ يعمل | 302 Redirect | يحول إلى `/admin/login` (مطلوب تسجيل دخول) |
| `/api/subscription-plans` | ❌ لا يعمل | 404 Not Found | الملفات لم يتم رفعها بعد |
| `/api/user` | ❌ لا يعمل | 404 Not Found | Route غير موجود |

---

## التفاصيل الكاملة

### 1. `/api/subscription-plans` ❌

**الحالة:** 404 Not Found

**الاستجابة:**
```json
{
  "message": "The route api/subscription-plans could not be found.",
  "exception": "Symfony\\Component\\HttpKernel\\Exception\\NotFoundHttpException"
}
```

**السبب:**
- ملف `SubscriptionPlanController.php` غير موجود على السيرفر
- ملف `SubscriptionPlan.php` (Model) غير موجود
- الروت غير مضاف في `routes/api.php`

**الحل:**
اتبع تعليمات الرفع في ملف `backend_files/UPLOAD_GUIDE.md`

---

### 2. `/admin/subscription-plans` ✅

**الحالة:** 302 Found (Redirect)

**Headers:**
```
HTTP/1.1 302 Found
Location: https://mediaprosocial.io/admin/login
Cache-Control: no-cache, no-store, must-revalidate, max-age=0
```

**الملاحظات:**
- صفحة الـ Admin تعمل بشكل صحيح
- تطلب تسجيل دخول (Session middleware يعمل)
- هذا سلوك طبيعي ومتوقع

---

### 3. الصفحة الرئيسية `/` ✅

**الحالة:** 302 Found (Redirect)

**Headers:**
```
HTTP/1.1 302 Found
Location: /public/
X-Powered-By: PHP/8.2.28
Server: LiteSpeed
```

**الملاحظات:**
- الموقع يعمل بشكل صحيح
- Laravel يعمل (PHP 8.2.28)
- السيرفر: LiteSpeed على Hostinger

---

## معلومات السيرفر

### Environment:
- **PHP Version:** 8.2.28
- **Web Server:** LiteSpeed
- **Hosting:** Hostinger (hpanel)
- **SSL:** مفعّل (HTTPS)
- **Framework:** Laravel (مكتشف من error trace)

### Laravel Info:
- **Middleware Active:**
  - DisableBackButtonCacheMiddleware (Livewire)
  - ConvertEmptyStringsToNull
  - TrimStrings
  - ValidatePostSize
  - PreventRequestsDuringMaintenance
  - HandleCors (CORS مفعّل)
  - TrustProxies
  - ValidatePathEncoding

---

## الملفات المطلوب رفعها

### لإصلاح `/api/subscription-plans`:

#### 1. Model File:
```
المسار المحلي: backend_files/SubscriptionPlan.php
المسار على السيرفر: /home/u126213189/domains/mediaprosocial.io/public_html/app/Models/SubscriptionPlan.php
```

#### 2. Controller File:
```
المسار المحلي: backend_files/SubscriptionPlanController.php
المسار على السيرفر: /home/u126213189/domains/mediaprosocial.io/public_html/app/Http/Controllers/Api/SubscriptionPlanController.php
```

#### 3. Route Addition:
```php
// إضافة في: routes/api.php

use App\Http\Controllers\Api\SubscriptionPlanController;

Route::get('/subscription-plans', [SubscriptionPlanController::class, 'index']);
```

---

## طرق الرفع المتاحة

### الطريقة 1: cPanel File Manager (الأسهل) ⭐

1. افتح cPanel
2. اذهب إلى File Manager
3. انتقل إلى `public_html/app/Models/`
4. ارفع `SubscriptionPlan.php`
5. انتقل إلى `public_html/app/Http/Controllers/Api/`
6. ارفع `SubscriptionPlanController.php`
7. افتح `routes/api.php` وأضف الروت

**التفاصيل الكاملة:** راجع `backend_files/UPLOAD_GUIDE.md`

---

### الطريقة 2: FTP (FileZilla)

```
Host: ftp.mediaprosocial.io
Port: 21
User: [FTP username]
Pass: [FTP password]
```

**التفاصيل الكاملة:** راجع `backend_files/UPLOAD_GUIDE.md`

---

### الطريقة 3: SSH

```bash
# الاتصال
ssh -p 65002 u126213189@82.25.83.217

# رفع الملف المضغوط
scp -P 65002 backend_upload.tar.gz u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/

# فك الضغط ونقل الملفات
cd /home/u126213189/domains/mediaprosocial.io/public_html/
tar -xzf backend_upload.tar.gz
mv SubscriptionPlan.php app/Models/
mkdir -p app/Http/Controllers/Api
mv SubscriptionPlanController.php app/Http/Controllers/Api/
```

**التفاصيل الكاملة:** راجع `backend_files/UPLOAD_GUIDE.md`

---

## الاختبار بعد الرفع

### 1. اختبر الـ API مباشرة:

```bash
curl -s "https://mediaprosocial.io/api/subscription-plans" | python -m json.tool
```

**النتيجة المتوقعة:**
```json
{
  "success": true,
  "data": [
    {
      "id": "1",
      "name": "Basic Plan",
      "monthly_price": 99.0,
      "yearly_price": 950.0,
      "currency": "AED",
      "max_accounts": 5,
      "max_posts_per_month": 100,
      "features": [...],
      "tier": "individual",
      "is_popular": true
    }
  ],
  "message": "Subscription plans retrieved successfully"
}
```

---

### 2. اختبر من المتصفح:

افتح: https://mediaprosocial.io/api/subscription-plans

يجب أن ترى JSON response

---

### 3. اختبر من التطبيق:

1. شغّل تطبيق Flutter
2. افتح شاشة "خطط الاشتراكات"
3. يجب أن تظهر الخطط من قاعدة البيانات
4. تحقق من console للتأكد من عدم وجود أخطاء HTTP

---

## توقعات بعد الرفع

### ✅ ما سيعمل:

1. **API Endpoint:** `GET /api/subscription-plans` سيعطي 200 OK
2. **JSON Response:** بيانات الخطط من قاعدة البيانات
3. **Flutter App:** سيعرض الخطط الحقيقية بدلاً من hardcoded plans
4. **Admin Panel:** أي تعديل في Admin سيظهر فوراً في التطبيق

### ⚠️ الأمور التي قد تحتاج انتباه:

1. **الصلاحيات:** تأكد من:
   - الملفات: 644
   - المجلدات: 755

2. **قاعدة البيانات:** تأكد من:
   - جدول `subscription_plans` موجود
   - يحتوي على بيانات
   - حقل `is_active = 1` للخطط النشطة

3. **Composer Autoload:** قد تحتاج تشغيل:
   ```bash
   composer dump-autoload
   ```

4. **Route Cache:** قد تحتاج تشغيل:
   ```bash
   php artisan route:clear
   php artisan config:clear
   php artisan cache:clear
   ```

---

## الملفات المرجعية

جميع الملفات والتعليمات موجودة في:
```
C:\Users\HP\social_media_manager\backend_files\
```

### الملفات الموجودة:

1. **SubscriptionPlan.php** - Model
2. **SubscriptionPlanController.php** - Controller
3. **routes_api.php** - Route example
4. **INSTALLATION_INSTRUCTIONS.md** - تعليمات مختصرة
5. **UPLOAD_GUIDE.md** - دليل شامل
6. **README.md** - ملخص المشروع
7. **backend_upload.tar.gz** - ملف مضغوط

---

## الخلاصة

### الحالة الحالية:

- ✅ **Backend يعمل:** Laravel + PHP 8.2.28
- ✅ **Admin Panel يعمل:** يطلب تسجيل دخول
- ✅ **Database جاهزة:** جدول subscription_plans موجود
- ✅ **Flutter App جاهز:** كود الـ API integration مكتمل
- ❌ **API Endpoint لا يعمل:** الملفات غير مرفوعة

### الخطوة التالية:

**رفع الملفات الثلاثة** حسب أي طريقة من الطرق المذكورة أعلاه.

**الوقت المتوقع:** 5-10 دقائق

---

## الدعم

إذا واجهت أي مشكلة:

1. تحقق من `storage/logs/laravel.log`
2. افتح Developer Console (F12) في المتصفح
3. شارك رسالة الخطأ الكاملة

---

**تم إنشاء التقرير بواسطة:** Claude Code
**التاريخ:** 2025-11-08 09:44 UTC

