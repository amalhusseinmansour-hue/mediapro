# تعليمات إعداد Database عبر SSH

## 🔌 معلومات الاتصال:

```
IP Address:    82.25.83.217
Port:          65002
Username:      u126213189
Password:      Alenwanapp33510421@
```

---

## 📖 خطوات الإعداد:

### 1. الاتصال بالـ Server

#### على Windows (PowerShell):
```powershell
ssh -p 65002 u126213189@82.25.83.217
```

#### على Mac/Linux:
```bash
ssh -p 65002 u126213189@82.25.83.217
```

---

### 2. الذهاب إلى مجلد المشروع

```bash
cd public_html
# أو
cd public_html/backend
```

---

### 3. إنشاء جداول Database

#### الطريقة الأولى - استخدام Laravel Artisan:

```bash
# بعد التأكد من أن .env محدّث بشكل صحيح
php artisan migrate --force
```

**ملاحظة:** هذا يتطلب اتصال Database صحيح في `.env`

---

#### الطريقة الثانية - استخدام MySQL CLI مباشرة:

```bash
# تسجيل الدخول إلى MySQL
mysql -u u126213189 -p

# أدخل كلمة المرور عند الطلب:
# Password: Alenwanapp33510421@
```

بعد تسجيل الدخول، ستظهر `mysql>`:

```sql
-- اختر Database
USE u126213189_socialmedia_ma;

-- إنشاء جدول Users
CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_admin` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- إضافة مستخدم Admin
INSERT INTO `users` (`name`, `email`, `password`, `is_admin`, `created_at`, `updated_at`) 
VALUES (
  'Admin',
  'admin@example.com',
  '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQdXmBAuJ0OU7YVBW7kZVLGTi',
  1,
  NOW(),
  NOW()
);

-- تحقق من البيانات
SELECT * FROM users;

-- اخرج من MySQL
EXIT;
```

---

### 4. مسح الكاش

```bash
cd backend  # تأكد أنك في مجلد backend

php artisan config:clear
php artisan cache:clear
```

---

### 5. التحقق من الاتصال

```bash
# جرب الاتصال المباشر
mysql -u u126213189 -p u126213189_socialmedia_ma -e "SELECT * FROM users;"
```

---

## ✅ التحقق من نجاح الإعداد:

```bash
# تحقق من وجود جداول
mysql -u u126213189 -p u126213189_socialmedia_ma -e "SHOW TABLES;"

# تحقق من مستخدم Admin
mysql -u u126213189 -p u126213189_socialmedia_ma -e "SELECT * FROM users WHERE email='admin@example.com';"
```

---

## 🌐 الوصول إلى لوحة التحكم:

بعد إنشاء المستخدم:

```
URL: https://mediaprosocial.io/admin/login
Email: admin@example.com
Password: password
```

---

## 🔐 كلمات المرور المشفرة:

كلمة المرور في الأمثلة أعلاه:

- Text: `password`
- Hash: `$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQdXmBAuJ0OU7YVBW7kZVLGTi`

يمكنك توليد hash جديد باستخدام:

```php
php artisan tinker
> bcrypt('your_password_here')
```

---

## ❌ حل المشاكل:

### مشكلة: "Access denied for user"

```bash
# تحقق من اسم المستخدم والكلمة المرور
mysql -u u126213189 -p

# إذا لم تعمل، اطلب تغيير كلمة المرور من cPanel
```

### مشكلة: "MySQL command not found"

```bash
# تحقق من تثبيت MySQL
which mysql

# أو جرب
/usr/bin/mysql -u u126213189 -p
```

### مشكلة: "Can't connect to local MySQL server"

```bash
# تحقق من حالة MySQL
sudo systemctl status mysql

# أو
sudo service mysql status

# إذا كان معطّل، شغّله:
sudo systemctl start mysql
```

---

## 📞 تلميحات مفيدة:

```bash
# قائمة جميع الـ Databases
mysql -u u126213189 -p -e "SHOW DATABASES;"

# قائمة جميع الـ Tables في Database
mysql -u u126213189 -p u126213189_socialmedia_ma -e "SHOW TABLES;"

# حذف Database (انتبه!)
mysql -u u126213189 -p -e "DROP DATABASE u126213189_socialmedia_ma;"

# إنشاء Database جديد
mysql -u u126213189 -p -e "CREATE DATABASE u126213189_socialmedia_ma;"
```

---

**الآن أنت جاهز! 🚀**
