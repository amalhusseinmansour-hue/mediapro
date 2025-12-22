# دليل الإعداد الشامل - مدير وسائل التواصل الاجتماعي

## نظرة عامة

المشروع يتكون من:
1. **Backend API** - Laravel 12 مع Filament Admin Panel
2. **Mobile App** - Flutter Application

## المتطلبات

### Backend
- PHP >= 8.2
- Composer
- SQLite أو MySQL

### Mobile App
- Flutter SDK >= 3.9.2
- Dart >= 3.9.2

---

## إعداد Backend

### 1. الانتقال إلى مجلد Backend

```bash
cd backend
```

### 2. تثبيت الحزم

```bash
composer install
```

### 3. إعداد البيئة

```bash
# نسخ ملف البيئة
cp .env.example .env

# توليد مفتاح التطبيق
php artisan key:generate

# إنشاء قاعدة البيانات SQLite
touch database/database.sqlite
```

### 4. تحديث متغيرات البيئة

افتح ملف `.env` وقم بتحديث:

```env
APP_NAME="Social Media Manager"
APP_LOCALE=ar
APP_URL=http://localhost:8000

# Stripe (اختياري للتطوير)
STRIPE_KEY=pk_test_your_key
STRIPE_SECRET=sk_test_your_secret
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret

# PayPal (اختياري للتطوير)
PAYPAL_MODE=sandbox
PAYPAL_CLIENT_ID=your_client_id
PAYPAL_SECRET=your_secret
```

### 5. تشغيل Migrations والـ Seeders

```bash
php artisan migrate --seed
```

هذا سينشئ:
- جميع الجداول المطلوبة
- لغات افتراضية (العربية والإنجليزية)
- باقات اشتراك تجريبية
- إعدادات النظام
- مستخدم تجريبي (admin@example.com / password)

### 6. تشغيل السيرفر

```bash
php artisan serve
```

Backend سيعمل على: `http://localhost:8000`

### 7. الوصول للوحة التحكم

```
URL: http://localhost:8000/admin
Email: admin@example.com
Password: password
```

---

## إعداد Mobile App

### 1. الانتقال إلى مجلد المشروع الرئيسي

```bash
cd ..
```

### 2. تثبيت الحزم

```bash
flutter pub get
```

### 3. تحديث عنوان API

افتح `lib/core/constants/app_constants.dart` وتأكد من:

```dart
static const String apiBaseUrl = 'http://localhost:8000/api/v1';
```

### 4. تشغيل التطبيق

```bash
# على Android
flutter run

# على iOS
flutter run

# على الويب
flutter run -d chrome
```

---

## الميزات المتاحة

### Backend Features

#### 1. إدارة الاشتراكات
- ✅ إنشاء وتعديل باقات الاشتراك
- ✅ إدارة اشتراكات المستخدمين
- ✅ تتبع حالة الاشتراكات (نشط، ملغي، منتهي)

#### 2. بوابات الدفع
- ✅ دمج Stripe كامل
- ✅ دمج PayPal كامل
- ✅ Webhook handlers
- ✅ نظام استرداد المدفوعات

#### 3. إدارة الأرباح
- ✅ تتبع الأرباح من الاشتراكات
- ✅ إحصائيات شهرية وسنوية
- ✅ تصنيف الأرباح حسب المصدر

#### 4. الإعدادات العامة
- ✅ إعدادات النظام القابلة للتخصيص
- ✅ تصنيف الإعدادات (عام، دفع، بريد، إلخ)
- ✅ إعدادات عامة/خاصة

#### 5. اللغات والترجمات
- ✅ دعم متعدد اللغات
- ✅ واجهة عربية مع RTL
- ✅ نظام ترجمات ديناميكي
- ✅ استيراد وتصدير الترجمات

#### 6. لوحة التحكم (Filament)
- ✅ واجهة عربية كاملة مع RTL
- ✅ إدارة جميع الموارد
- ✅ Dashboard مع إحصائيات
- ✅ فلاتر وبحث متقدم

### API Endpoints

#### Authentication
```
POST /api/v1/register
POST /api/v1/login
POST /api/v1/logout
GET  /api/v1/user
```

#### Subscriptions
```
GET    /api/v1/subscription-plans
GET    /api/v1/subscriptions
POST   /api/v1/subscriptions
GET    /api/v1/subscriptions/{id}
POST   /api/v1/subscriptions/{id}/cancel
POST   /api/v1/subscriptions/{id}/renew
GET    /api/v1/subscriptions/user/current
```

#### Payments
```
POST /api/v1/payments/stripe/create-payment-intent
POST /api/v1/payments/stripe/confirm
POST /api/v1/payments/paypal/create-order
POST /api/v1/payments/paypal/capture
```

#### Earnings
```
GET /api/v1/earnings
GET /api/v1/earnings/stats/total
GET /api/v1/earnings/stats/monthly
```

#### Settings (Public)
```
GET /api/v1/settings/public
```

#### Languages
```
GET /api/v1/languages
GET /api/v1/translations/{languageCode}
```

---

## هيكل قاعدة البيانات

### الجداول الرئيسية

1. **users** - المستخدمين
2. **subscription_plans** - باقات الاشتراك
3. **subscriptions** - اشتراكات المستخدمين
4. **payments** - سجل المدفوعات
5. **earnings** - سجل الأرباح
6. **settings** - إعدادات النظام
7. **languages** - اللغات المتاحة
8. **translations** - الترجمات

---

## الأوامر المفيدة

### Backend

```bash
# تشغيل السيرفر
php artisan serve

# إعادة تشغيل الـ migrations
php artisan migrate:fresh --seed

# مسح الكاش
php artisan cache:clear
php artisan config:clear
php artisan route:clear

# إنشاء مستخدم إداري
php artisan tinker
>>> User::create(['name' => 'Admin', 'email' => 'admin@test.com', 'password' => bcrypt('password'), 'is_admin' => true])
```

### Flutter

```bash
# تنظيف المشروع
flutter clean

# الحصول على الحزم
flutter pub get

# بناء التطبيق
flutter build apk        # Android
flutter build ios        # iOS
flutter build web        # Web

# تشغيل الاختبارات
flutter test
```

---

## الأمان

### تأمين الـ API

1. جميع endpoints المحمية تتطلب `Bearer Token`
2. Admin endpoints محمية بـ `AdminMiddleware`
3. CSRF protection مفعل
4. Rate limiting مطبق

### حماية البيانات

1. كلمات المرور مشفرة (bcrypt)
2. API Keys محمية في `.env`
3. Webhook signatures يتم التحقق منها
4. SQL injection محمي (Eloquent ORM)

---

## حل المشاكل الشائعة

### Backend

#### مشكلة: Access denied for user

**الحل:** تأكد من صحة معلومات قاعدة البيانات في `.env`

#### مشكلة: Class not found

**الحل:**
```bash
composer dump-autoload
php artisan config:clear
```

#### مشكلة: Permission denied

**الحل:**
```bash
chmod -R 775 storage bootstrap/cache
```

### Flutter

#### مشكلة: Package version conflict

**الحل:**
```bash
flutter clean
flutter pub get
```

#### مشكلة: Network error

**الحل:** تحقق من عنوان API في `app_constants.dart`

---

## النشر (Production)

### Backend

1. تحديث `.env`:
```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://yourdomain.com
```

2. تحسين الأداء:
```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
composer install --optimize-autoloader --no-dev
```

### Flutter

1. بناء للإنتاج:
```bash
flutter build apk --release        # Android
flutter build ios --release        # iOS
flutter build web --release        # Web
```

---

## الدعم

للمساعدة أو الإبلاغ عن مشاكل:
- فتح Issue في GitHub
- مراجعة الـ logs في `storage/logs/laravel.log`

---

## الترخيص

MIT License

---

تم تطوير النظام بالكامل باللغة العربية مع دعم RTL ✨
