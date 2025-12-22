# Laravel API - تعليمات الرفع على السيرفر

## الملفات الموجودة حالياً

✅ `routes/api.php` - ملف Routes جاهز

## الملفات المطلوبة للنسخ من BACKEND_COMPLETE_CODE.md

انسخ الأكواد التالية من ملف `BACKEND_COMPLETE_CODE.md` في المجلد الرئيسي:

### 1. Controllers (المتحكمات)
انسخ من `LARAVEL_API_GUIDE.md`:
- `app/Http/Controllers/Api/AuthController.php`
- `app/Http/Controllers/Api/UserController.php`  
- `app/Http/Controllers/Api/SubscriptionController.php`

### 2. Models (النماذج)
من `BACKEND_COMPLETE_CODE.md` - Section 5, 6, 7:
- `app/Models/User.php`
- `app/Models/Subscription.php`
- `app/Models/OTP.php`

### 3. Migrations (قاعدة البيانات)
من `BACKEND_COMPLETE_CODE.md` - Section 8, 9, 10:
- `database/migrations/2024_01_01_000001_create_users_table.php`
- `database/migrations/2024_01_01_000002_create_subscriptions_table.php`
- `database/migrations/2024_01_01_000003_create_otps_table.php`

### 4. Configuration
من `BACKEND_COMPLETE_CODE.md` - Section 11, 12:
- `.env`
- `config/cors.php`

---

## خطوات الرفع على السيرفر

### 1. إنشاء مشروع Laravel على السيرفر

```bash
composer create-project laravel/laravel social_media_api
cd social_media_api
```

### 2. نسخ الملفات

انسخ جميع الملفات من المجلدات:
- `routes/api.php` → مجلد routes
- جميع ملفات Controllers → `app/Http/Controllers/Api/`
- جميع ملفات Models → `app/Models/`
- جميع ملفات Migrations → `database/migrations/`
- `.env` → الجذر
- `cors.php` → `config/`

### 3. تثبيت Laravel Sanctum

```bash
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
```

### 4. إعداد قاعدة البيانات

```bash
# تحرير .env
nano .env

# إضافة بيانات MySQL:
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=social_media_db
DB_USERNAME=your_username
DB_PASSWORD=your_password
```

### 5. تشغيل Migrations

```bash
php artisan key:generate
php artisan migrate
```

### 6. تحسين الأداء

```bash
composer install --no-dev --optimize-autoloader
php artisan config:cache
php artisan route:cache
chmod -R 755 storage bootstrap/cache
```

---

## اختبار API

```bash
# Health Check
curl https://mediaprosocial.io/api/health

# يجب أن يرجع:
{"status":"ok","timestamp":"2025-01-07T..."}
```

---

## الوثائق الكاملة

📄 جميع الأكواد موجودة في:
- `BACKEND_COMPLETE_CODE.md` (الكود الكامل)
- `LARAVEL_API_GUIDE.md` (الدليل التفصيلي)

---

**URL الخاص بالـ API**: https://mediaprosocial.io/api
