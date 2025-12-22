# 🔴 حل مشاكل إنشاء حساب جديد

## 📍 أين تحاول الإنشاء؟

### 1️⃣ **من لوحة التحكم Filament**

```
URL: https://mediaprosocial.io/admin/login
ثم: اضغط "Create" من قسم Users
```

**المشاكل الشائعة:**

#### ❌ "Email already exists"
```sql
-- تحقق من البريد في Database:
SELECT * FROM users WHERE email = 'البريد';

-- إذا كان موجود، احذفه:
DELETE FROM users WHERE email = 'البريد';
```

#### ❌ "Validation error"
```
✓ تأكد من ملء جميع الحقول
✓ البريد يجب أن يكون صحيح
✓ كلمة المرور يجب أن تكون 8 أحرف على الأقل
```

#### ❌ "Database connection error"
```
✓ تحقق من .env في الخادم
✓ تأكد من DB_HOST, DB_USERNAME, DB_PASSWORD
✓ جرّب php artisan config:clear
```

---

### 2️⃣ **من التطبيق Flutter**

```
Screen: LoginScreen → "سجل حساب جديد"
```

**المشاكل الشائعة:**

#### ❌ "Connection refused"
```
السبب: الخادم الخلفي (Backend) لا يرد على 
mediaprosocial.io

الحل:
1. تأكد من أن API يعمل
2. جرّب:
   curl https://mediaprosocial.io/api/register
```

#### ❌ "Invalid format"
```
✓ تأكد من صيغة البيانات المرسلة
✓ البريد يجب أن يكون صحيح
✓ الهاتف يجب أن يكون موجود
```

#### ❌ "Email already exists"
```
✓ جرّب بريد مختلف
✓ أو احذف المستخدم من Database
```

---

### 3️⃣ **من API مباشرة**

```bash
curl -X POST https://mediaprosocial.io/api/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Ahmed",
    "email": "ahmed@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "user_type": "individual"
  }'
```

---

## 🔧 حل شامل للمشاكل

### الخطوة 1: تحقق من Database

```bash
ssh -p 65002 u126213189@82.25.83.217

# تسجيل الدخول إلى MySQL
mysql -u u126213189 -p u126213189_socialmedia_ma

# في MySQL:
-- تحقق من جدول users
SELECT * FROM users;

-- تحقق من عمود البريد المحدد
SELECT COUNT(*) FROM users WHERE email = 'البريد_هنا';

-- احذف أي بيانات قديمة إذا لزم الأمر
DELETE FROM users WHERE email = 'البريد_هنا';
```

---

### الخطوة 2: تحقق من Routes

```bash
# من الخادم:
php artisan route:list | grep register

# يجب أن تظهر:
POST  /api/register
```

---

### الخطوة 3: تحقق من Validation

```php
// في AuthController.php:

protected function registerWithPhone(Request $request): JsonResponse
{
    $validated = $request->validate([
        'name' => 'required|string',
        'email' => 'nullable|email|unique:users',
        'phone' => 'required|unique:users',
        'password' => 'nullable|string|min:8',
        'user_type' => 'required|in:individual,company',
    ]);

    // إنشاء المستخدم...
}
```

---

### الخطوة 4: فعّل Debug Mode

تحديث `.env`:

```dotenv
APP_DEBUG=true
LOG_LEVEL=debug
```

ثم مسح الكاش:

```bash
php artisan config:clear
php artisan cache:clear
```

---

### الخطوة 5: تحقق من Logs

```bash
# من الخادم:
tail -f storage/logs/laravel.log

# جرّب الإنشاء والراقب الأخطاء في الـ log
```

---

## ✅ الحل السريع

إذا فشل الإنشاء مباشرة:

### 1. مسح Database وإعادة تشغيل

```bash
# من الخادم:
php artisan migrate:fresh

# ثم إنشاء Admin:
php artisan db:seed --class=AdminUserSeeder
```

### 2. إعادة تشغيل Queue

```bash
# إذا كان Queue معطّل:
php artisan queue:work --stop-when-empty
```

### 3. مسح الكاش

```bash
php artisan cache:clear
php artisan config:clear
php artisan view:clear
php artisan route:clear
```

---

## 📋 قائمة الفحص

- [ ] جدول users موجود في Database؟
- [ ] route /api/register موجود؟
- [ ] AuthController.php يعمل بدون أخطاء؟
- [ ] User Model يحتوي على fillable الصحيح؟
- [ ] .env يحتوي على بيانات Database الصحيحة؟
- [ ] APP_DEBUG=true للمشاهدة؟

---

## 🆘 إذا استمرت المشكلة

أخبرني بـ:
1. رسالة الخطأ بالضبط
2. أين تحاول الإنشاء؟
3. نوع المستخدم (Admin أم عادي)؟
4. هل تظهر أي logs في storage/logs/laravel.log؟

---

**سأساعدك بناءً على المعلومات! 💪**
