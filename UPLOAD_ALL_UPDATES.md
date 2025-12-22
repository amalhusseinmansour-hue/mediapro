# رفع جميع التحديثات للسيرفر - دليل شامل

## 📦 التحديثات المطلوب رفعها

تم إنشاء 3 تحديثات مهمة:

### 1. **نظام ربط الحسابات الاجتماعية** 🔗
- يحل مشكلة "فشل ربط الحسابات"
- يتيح ربط/فك ربط حسابات Social Media

### 2. **إصلاح تسجيل المستخدمين** 👤
- يحل مشكلة عدم حفظ بيانات المستخدمين
- يضيف 20 حقل جديد لجدول users

### 3. **صفحات Filament Admin** 📊
- طلبات المواقع
- الإعلانات الممولة
- تذاكر الدعم الفني
- التحويلات البنكية

---

## ⬆️ طريقة الرفع (10 دقائق)

### 1️⃣ تسجيل الدخول cPanel

```
https://mediaprosocial.io:2083
Username: u126213189
Password: Alenwanapp33510421@
```

---

### 2️⃣ رفع الملفات

افتح File Manager في cPanel.

#### أ) رفع ملفات ربط الحسابات:

**الملفات:**
1. `ConnectedAccount.php` → `/public_html/app/Models/`
2. `ConnectedAccountController.php` → `/public_html/app/Http/Controllers/Api/`
3. `2025_11_08_000005_create_connected_accounts_table.php` → `/public_html/database/migrations/`

**أو استخدم ZIP:**
- ارفع `connected_accounts.zip` إلى `/public_html`
- Extract

---

#### ب) رفع ملفات إصلاح التسجيل:

**الملفات:**
1. `User.php` → `/public_html/app/Models/` (استبدل الموجود)
2. `2025_11_08_000006_add_missing_fields_to_users_table.php` → `/public_html/database/migrations/`

**أو استخدم ZIP:**
- ارفع `fix_user_registration.zip` إلى `/public_html`
- Extract

---

#### ج) تحديث Routes:

**الملف:**
1. `api.php` → `/public_html/routes/` (استبدل الموجود)

**من:**
```
C:\Users\HP\social_media_manager\backend\routes\api.php
```

---

#### د) رفع Filament Resources (اختياري):

**الملفات:**
- `SponsoredAdRequestResource.php` + مجلد Pages → `/public_html/app/Filament/Resources/`
- `SupportTicketResource.php` + مجلد Pages → `/public_html/app/Filament/Resources/`
- `WebsiteRequestResource.php` + مجلد Pages → `/public_html/app/Filament/Resources/`
- `BankTransferRequestResource.php` + مجلد Pages → `/public_html/app/Filament/Resources/`

**أو استخدم ZIP:**
- ارفع `filament_resources.zip` إلى `/public_html/app/Filament/Resources/`
- Extract

---

### 3️⃣ تنفيذ Migrations (مهم جداً!)

**الطريقة أ) عبر Terminal:**

في cPanel، افتح Terminal ونفذ:

```bash
cd domains/mediaprosocial.io/public_html

# تنفيذ Migrations
php artisan migrate --force

# التحقق من النتيجة
php artisan migrate:status
```

**الطريقة ب) عبر المتصفح:**

1. ارفع `run-migration.php` إلى `/public_html`
2. افتح في المتصفح: `https://mediaprosocial.io/run-migration.php`
3. يجب أن تشاهد:
   ```
   ✓ تم تنفيذ Migration بنجاح!
   ```
4. **احذف الملف فوراً!**

---

### 4️⃣ مسح Cache

**الطريقة أ) عبر Terminal:**

```bash
cd domains/mediaprosocial.io/public_html
php artisan cache:clear
php artisan route:clear
php artisan view:clear
php artisan config:clear
```

**الطريقة ب) عبر المتصفح:**

1. ارفع `clear-cache.php` إلى `/public_html`
2. افتح: `https://mediaprosocial.io/clear-cache.php`
3. **احذف الملف فوراً!**

---

## 🧪 اختبار التحديثات

### Test 1: نظام ربط الحسابات

```http
GET https://mediaprosocial.io/api/connected-accounts/platforms
Authorization: Bearer YOUR_TOKEN
```

**يجب أن يرجع:**
```json
{
  "success": true,
  "platforms": [
    {"id": "facebook", "name": "Facebook", ...},
    {"id": "instagram", "name": "Instagram", ...}
  ]
}
```

---

### Test 2: تسجيل مستخدم جديد

```http
POST https://mediaprosocial.io/api/auth/register
Content-Type: application/json

{
  "name": "Test User",
  "email": "test123@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "phone": "+966501234567"
}
```

**يجب أن يرجع:**
```json
{
  "message": "تم التسجيل بنجاح",
  "user": {
    "id": ...,
    "name": "Test User",
    "email": "test123@example.com",
    "phone": "+966501234567",
    ...
  },
  "access_token": "..."
}
```

---

### Test 3: Filament Admin Pages

افتح:
```
https://mediaprosocial.io/admin
```

يجب أن تظهر في القائمة الجانبية:
- ✅ طلبات المواقع
- ✅ الإعلانات الممولة
- ✅ تذاكر الدعم
- ✅ التحويلات البنكية

---

## 📋 Checklist - تأكد من كل شيء

### ✅ الرفع:
- [ ] رفع ConnectedAccount.php
- [ ] رفع ConnectedAccountController.php
- [ ] رفع Migration ربط الحسابات
- [ ] رفع User.php المحدث
- [ ] رفع Migration إصلاح التسجيل
- [ ] رفع api.php المحدث
- [ ] رفع Filament Resources (اختياري)

### ✅ التنفيذ:
- [ ] تنفيذ php artisan migrate
- [ ] مسح Cache
- [ ] حذف ملفات المساعدة (run-migration.php, clear-cache.php)

### ✅ الاختبار:
- [ ] اختبار API ربط الحسابات
- [ ] اختبار تسجيل مستخدم جديد
- [ ] اختبار Admin Pages (إذا رفعت Filament)

---

## 📁 الملفات الموجودة في المشروع

جميع الملفات جاهزة في:
```
C:\Users\HP\social_media_manager\
```

### ملفات ZIP الجاهزة:
1. `connected_accounts.zip` - نظام ربط الحسابات
2. `fix_user_registration.zip` - إصلاح التسجيل
3. `filament_resources.zip` - صفحات Filament
4. `all_updates.zip` - جميع التحديثات في ملف واحد

### ملفات المساعدة:
1. `run-migration.php` - لتنفيذ Migrations عبر المتصفح
2. `clear-cache.php` - لمسح Cache عبر المتصفح

### ملفات التوثيق:
1. `FIX_CONNECTED_ACCOUNTS.md` - دليل ربط الحسابات
2. `FIX_USER_REGISTRATION.md` - دليل إصلاح التسجيل
3. `FILAMENT_RESOURCES_GUIDE.md` - دليل Filament
4. `CONNECTED_ACCOUNTS_API_GUIDE.md` - دليل API

---

## ⚠️ ملاحظات مهمة

### 1. Migrations

**مهم جداً:** يجب تنفيذ Migrations بعد رفع الملفات:
- Migration ربط الحسابات: ينشئ جدول `connected_accounts`
- Migration إصلاح التسجيل: يضيف حقول لجدول `users`

بدون تنفيذ Migrations، لن تعمل التحديثات!

### 2. ترتيب الرفع

الترتيب الموصى به:
1. ارفع جميع الملفات أولاً
2. ثم نفذ Migrations
3. ثم امسح Cache
4. ثم اختبر

### 3. النسخ الاحتياطي

قبل الرفع، يُفضل عمل نسخة احتياطية من:
- `/public_html/app/Models/User.php`
- `/public_html/routes/api.php`
- قاعدة البيانات (من phpMyAdmin)

---

## 🔧 حل المشاكل

### المشكلة: Migration فشل

**الحل:**
1. تحقق من الـ Logs: `/public_html/storage/logs/laravel.log`
2. تأكد من رفع ملفات Migration بشكل صحيح
3. حاول مرة أخرى: `php artisan migrate --force`

### المشكلة: 404 Not Found على API endpoints

**الحل:**
1. تأكد من رفع `api.php`
2. امسح route cache: `php artisan route:clear`
3. تحقق من الـ routes: `php artisan route:list | grep connected`

### المشكلة: لا يزال التسجيل لا يعمل

**الحل:**
1. تأكد من تنفيذ Migration إصلاح التسجيل
2. تحقق من الجدول: `DESCRIBE users;` في phpMyAdmin
3. يجب أن ترى حقول: phone, is_admin, is_phone_verified, إلخ

---

## 📞 المساعدة

إذا واجهت أي مشكلة:

1. **تحقق من Logs:**
   ```
   /public_html/storage/logs/laravel.log
   ```

2. **تحقق من Migrations:**
   ```bash
   php artisan migrate:status
   ```

3. **تحقق من Routes:**
   ```bash
   php artisan route:list
   ```

4. **تحقق من الجدول:**
   في phpMyAdmin:
   ```sql
   DESCRIBE users;
   DESCRIBE connected_accounts;
   ```

---

## 🎯 بعد نجاح الرفع

بعد نجاح جميع التحديثات:

### في التطبيق:
1. ✅ ربط الحسابات الاجتماعية سيعمل
2. ✅ تسجيل المستخدمين سيحفظ جميع البيانات
3. ✅ تسجيل الدخول برقم الهاتف سيعمل

### في Admin Panel:
1. ✅ صفحات إدارة الطلبات ستظهر
2. ✅ Badges العدادات ستعمل
3. ✅ قبول/رفض التحويلات البنكية سيعمل

---

**وقت التنفيذ المتوقع:** 10 دقائق

**ملاحظة:** إذا واجهت صعوبة في أي خطوة، راجع الملفات التوثيقية المفصلة في المشروع.

---

**تم الإعداد:** 8 نوفمبر 2025

حظاً موفقاً! 🚀
