-- إنشاء جدول طلبات المواقع الإلكترونية
-- Website Requests Table for Media Pro Social Manager

CREATE TABLE IF NOT EXISTS `website_requests` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT 'معرف المستخدم',
  `name` VARCHAR(255) NOT NULL COMMENT 'الاسم الكامل',
  `email` VARCHAR(255) NOT NULL COMMENT 'البريد الإلكتروني',
  `phone` VARCHAR(50) NOT NULL COMMENT 'رقم الهاتف',
  `company_name` VARCHAR(255) NULL COMMENT 'اسم الشركة أو الموقع',
  `website_type` ENUM('corporate', 'ecommerce', 'portfolio', 'blog', 'custom') NOT NULL DEFAULT 'corporate' COMMENT 'نوع الموقع',
  `description` TEXT NOT NULL COMMENT 'وصف المشروع',
  `budget` DECIMAL(10, 2) NULL COMMENT 'الميزانية',
  `currency` VARCHAR(10) DEFAULT 'SAR' COMMENT 'العملة',
  `deadline` DATE NULL COMMENT 'الموعد المطلوب',
  `features` JSON NULL COMMENT 'المميزات المطلوبة',
  `status` ENUM('pending', 'reviewing', 'approved', 'in_progress', 'completed', 'cancelled') NOT NULL DEFAULT 'pending' COMMENT 'حالة الطلب',
  `admin_notes` TEXT NULL COMMENT 'ملاحظات الإدارة',
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_website_type` (`website_type`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='جدول طلبات المواقع الإلكترونية';

-- إضافة Foreign Key للربط مع جدول المستخدمين (إذا كان موجوداً)
-- ALTER TABLE `website_requests`
--   ADD CONSTRAINT `fk_website_requests_user_id`
--   FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
--   ON DELETE CASCADE ON UPDATE CASCADE;

-- إدراج بيانات تجريبية (اختياري - للاختبار فقط)
-- INSERT INTO `website_requests` (`user_id`, `name`, `email`, `phone`, `company_name`, `website_type`, `description`, `budget`, `status`)
-- VALUES
--   (1, 'أحمد محمد', 'ahmed@example.com', '0501234567', 'شركة النجاح', 'corporate', 'أريد موقع شركة احترافي بتصميم عصري', 5000.00, 'pending'),
--   (2, 'فاطمة علي', 'fatima@example.com', '0559876543', 'متجر الأزياء', 'ecommerce', 'متجر إلكتروني لبيع الملابس مع نظام دفع', 8000.00, 'reviewing');
