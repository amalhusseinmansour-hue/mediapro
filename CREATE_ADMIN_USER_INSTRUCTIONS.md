# 🔐 إنشاء مستخدم Admin - خطوة بخطوة

## ⚠️ المشكلة:

```
❌ admin@example.com غير موجود في قاعدة البيانات
```

---

## ✅ الحل (خطوة واحدة):

### الخطوة الوحيدة: تنفيذ SQL من phpMyAdmin

```
1. اذهب إلى: https://cpanel.mediaprosocial.io/phpmyadmin
   (أو من cPanel → phpMyAdmin)

2. تسجيل الدخول بـ:
   - Username: u126213189
   - Password: Alenwanapp33510421@

3. من القائمة اليسرى، اختر Database:
   u126213189_socialmedia_ma

4. في الأعلى، انقر على تبويب: SQL

5. انسخ الكود التالي والصقه في المربع:
```

---

## 📋 الكود الذي تنسخه والصقه:

```sql
-- حذف المستخدم القديم
DELETE FROM `users` WHERE `email` = 'admin@example.com';

-- إنشاء جدول Users (إذا لم يكن موجود)
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

-- إدراج مستخدم Admin
INSERT INTO `users` (
  `name`,
  `email`,
  `password`,
  `is_admin`,
  `user_type`,
  `created_at`,
  `updated_at`
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

---

## 6️⃣ الخطوة الأخيرة:

```
6. انقر على زر: Go (أزرق كبير في الأسفل)

7. ستظهر رسالة نجاح: "Query executed successfully"
```

---

## ✅ والآن يمكنك تسجيل الدخول:

```
🌐 URL: https://mediaprosocial.io/admin/login

📧 Email:    admin@example.com
🔐 Password: password
```

---

## 🔍 للتحقق من النجاح:

بعد النقر على Go، شغّل هذا الكود:

```sql
SELECT * FROM `users` WHERE `email` = 'admin@example.com';
```

**النتيجة المتوقعة:**
```
id | name  | email             | is_admin
1  | Admin | admin@example.com | 1
```

---

## 💡 نصائح:

- 📋 الكود موجود في: `CREATE_ADMIN_USER_ONLY.sql`
- 🔐 كلمة المرور مشفرة (هاش)
- ✅ بعد النجاح، غيّر كلمة المرور من لوحة التحكم
- 🌐 استخدم الـ URL الصحيح: https://mediaprosocial.io/admin/login

---

**هل تحتاج مساعدة إضافية؟** 🆘
