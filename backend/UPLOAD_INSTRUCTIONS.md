# تعليمات رفع Backend على السيرفر

## الملف الجاهز للرفع

✅ **backend_upload.tar.gz** (87 KB) - ملف مضغوط يحتوي على:
- app/ - جميع الـ Controllers والـ Models
- routes/ - ملف api.php محدث
- database/ - جميع الـ Migrations
- config/ - إعدادات التطبيق
- .env.example - نموذج إعدادات البيئة
- composer.json - متطلبات المشروع

---

## خطوات الرفع (الطريقة 1: رفع كامل)

### 1. رفع الملف المضغوط

```bash
# من جهازك المحلي - رفع الملف
scp backend_upload.tar.gz user@mediaprosocial.io:/home/user/
```

### 2. الاتصال بالسيرفر

```bash
ssh user@mediaprosocial.io
```

### 3. إنشاء مشروع Laravel جديد

```bash
cd public_html
composer create-project laravel/laravel api
cd api
```

### 4. فك ضغط الملفات المرفوعة

```bash
# فك الضغط فوق المشروع الجديد
tar -xzf ~/backend_upload.tar.gz -C .
```

### 5. تثبيت Laravel Sanctum

```bash
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
```

### 6. إعداد ملف .env

```bash
# نسخ ملف .env.example إلى .env
cp .env.example .env

# تعديل بيانات قاعدة البيانات
nano .env
```

أضف بيانات قاعدة البيانات الخاصة بك:
```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=social_media_db
DB_USERNAME=your_username
DB_PASSWORD=your_password
```

### 7. توليد APP_KEY وتشغيل Migrations

```bash
php artisan key:generate
php artisan migrate
```

### 8. تحسين الأداء

```bash
composer install --no-dev --optimize-autoloader
php artisan config:cache
php artisan route:cache
php artisan view:cache
chmod -R 755 storage bootstrap/cache
```

---

## الطريقة 2: نسخ الملفات يدوياً (إذا كان Laravel موجود)

إذا كان لديك مشروع Laravel موجود مسبقاً، انسخ الملفات فقط:

### من BACKEND_COMPLETE_CODE.md:

1. **Controllers** (من LARAVEL_API_GUIDE.md):
   - AuthController.php → app/Http/Controllers/Api/
   - UserController.php → app/Http/Controllers/Api/
   - SubscriptionController.php → app/Http/Controllers/Api/

2. **Models** (Section 5, 6, 7):
   - User.php → app/Models/
   - Subscription.php → app/Models/
   - OTP.php → app/Models/

3. **Migrations** (Section 8, 9, 10):
   - create_users_table.php → database/migrations/
   - create_subscriptions_table.php → database/migrations/
   - create_otps_table.php → database/migrations/

4. **Routes** (موجود في backend/routes/):
   - api.php → routes/

5. **Config**:
   - cors.php → config/

ثم شغّل:
```bash
php artisan migrate
php artisan config:cache
```

---

## اختبار API بعد الرفع

```bash
# Health Check
curl https://mediaprosocial.io/api/health

# يجب أن يرجع:
{"status":"ok","timestamp":"2025-01-07T..."}
```

---

## الملفات المرجعية

📄 جميع الأكواد الكاملة موجودة في:
1. **BACKEND_COMPLETE_CODE.md** - كود كامل جاهز للنسخ
2. **LARAVEL_API_GUIDE.md** - دليل تفصيلي بالشرح
3. **README.md** - تعليمات عامة

---

## روابط مهمة

- **API URL**: https://mediaprosocial.io/api
- **Health Endpoint**: https://mediaprosocial.io/api/health

---

**بعد الرفع، اختبر الاتصال من التطبيق Flutter!** 🚀
