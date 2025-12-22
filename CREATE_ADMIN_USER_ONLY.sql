-- ============================================================================
-- Social Media Manager - Admin User Setup Script
-- Execute this file from cPanel → phpMyAdmin
-- ============================================================================

-- تأكد من أنك في Database الصحيح:
-- Database Name: u126213189_socialmedia_ma

-- ============================================================================
-- 1. إنشاء جدول Users (إذا لم يكن موجود)
-- ============================================================================

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

-- ============================================================================
-- 2. حذف المستخدم القديم (إن وجد)
-- ============================================================================

DELETE FROM `users` WHERE `email` = 'admin@example.com';

-- ============================================================================
-- 3. إنشاء مستخدم Admin جديد
-- ============================================================================
-- كلمة المرور: password
-- Hash: $2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQdXmBAuJ0OU7YVBW7kZVLGTi

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

-- ============================================================================
-- 4. التحقق من البيانات
-- ============================================================================

-- اختر هذا السطر والصق في SQL منفصل للتحقق:
SELECT * FROM `users` WHERE `email` = 'admin@example.com';

-- ============================================================================
-- النتيجة المتوقعة:
-- ============================================================================
-- id | name  | email               | password (hashed) | is_admin | created_at
-- 1  | Admin | admin@example.com   | $2y$12$LQv3c... | 1        | 2025-11-19
--
-- إذا لم تظهر النتيجة، يعني قاعدة البيانات غير صحيحة
-- ============================================================================
