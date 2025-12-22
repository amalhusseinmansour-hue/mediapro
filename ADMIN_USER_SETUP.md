# 🎯 إنشاء Admin User - اختر الطريقة المناسبة

## 🚀 عندك خيارات:

---

## ✅ الطريقة الأولى: phpMyAdmin (الأسهل - موصى بها)

### الخطوات:

1. **اذهب إلى phpMyAdmin:**
   ```
   https://cpanel.mediaprosocial.io/phpmyadmin
   ```

2. **تسجيل الدخول:**
   ```
   Username: u126213189
   Password: Alenwanapp33510421@
   ```

3. **اختر Database:**
   ```
   u126213189_socialmedia_ma
   ```

4. **انقر على SQL**

5. **انسخ والصق هذا الكود:**
   ```sql
   DELETE FROM `users` WHERE `email` = 'admin@example.com';
   
   CREATE TABLE IF NOT EXISTS `users` (
     `id` bigint unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
     `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
     `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
     `email_verified_at` timestamp NULL DEFAULT NULL,
     `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
     `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci NULL,
     `is_admin` tinyint(1) NOT NULL DEFAULT 0,
     `user_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'user',
     `created_at` timestamp NULL DEFAULT NULL,
     `updated_at` timestamp NULL DEFAULT NULL,
     UNIQUE KEY `users_email_unique` (`email`)
   ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
   
   INSERT INTO `users` (
     `name`, `email`, `password`, `is_admin`, `user_type`, `created_at`, `updated_at`
   ) VALUES (
     'Admin',
     'admin@example.com',
     '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQdXmBAuJ0OU7YVBW7kZVLGTi',
     1,
     'admin',
     NOW(),
     NOW()
   );
   ```

6. **انقر Go (الزر الأزرق)**

7. **ستظهر رسالة نجاح! ✅**

---

## 🖥️ الطريقة الثانية: SSH (للخوادم المتقدمة)

### الخطوات:

```bash
# 1. الاتصال بـ SSH
ssh -p 65002 u126213189@82.25.83.217

# 2. تسجيل الدخول إلى MySQL
mysql -u u126213189 -p u126213189_socialmedia_ma

# 3. إدخال كلمة المرور:
# Alenwanapp33510421@

# 4. الصق الكود في MySQL
```

### الكود لـ SSH:

```sql
DELETE FROM `users` WHERE `email` = 'admin@example.com';

CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci NULL,
  `is_admin` tinyint(1) NOT NULL DEFAULT 0,
  `user_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'user',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `users` (
  `name`, `email`, `password`, `is_admin`, `user_type`, `created_at`, `updated_at`
) VALUES (
  'Admin',
  'admin@example.com',
  '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQdXmBAuJ0OU7YVBW7kZVLGTi',
  1,
  'admin',
  NOW(),
  NOW()
);

SELECT * FROM users WHERE email = 'admin@example.com';
EXIT;
```

---

## 📱 بعد النجاح:

```
🌐 اذهب إلى: https://mediaprosocial.io/admin/login

📧 Email:    admin@example.com
🔐 Password: password
```

---

## ✅ التحقق من النجاح:

شغّل هذا الكود في SQL:

```sql
SELECT * FROM users WHERE email = 'admin@example.com';
```

**يجب أن تظهر صف واحد مع:**
```
id | name  | email             | is_admin
1  | Admin | admin@example.com | 1
```

---

## 🆘 إذا لم تنجح:

### خطأ: "Table 'u126213189_socialmedia_ma.users' doesn't exist"

**الحل:** اتبع الخطوات أعلاه - ستنشئ الجدول تلقائياً

### خطأ: "Access denied for user"

**الحل:** تأكد من:
- اسم المستخدم: `u126213189`
- كلمة المرور: `Alenwanapp33510421@`
- Database: `u126213189_socialmedia_ma`

### خطأ: "Connection refused"

**الحل:**
```bash
# تحقق من أن MySQL يعمل
sudo systemctl status mysql

# إذا كان معطّل، شغّله:
sudo systemctl start mysql
```

---

## 📁 الملفات المتاحة:

| الملف | الاستخدام |
|------|----------|
| `CREATE_ADMIN_USER_ONLY.sql` | ملف SQL مباشر |
| `CREATE_ADMIN_USER_INSTRUCTIONS.md` | تعليمات مفصّلة |
| `create_admin_via_ssh.sh` | Script Bash |

---

## 🎉 اختر الطريقة وابدأ الآن!

**phpMyAdmin هي الأسهل والأسرع! ⚡**
