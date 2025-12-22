-- إنشاء جدول طلبات الإعلانات الممولة
-- Sponsored Ads Requests Table for Media Pro Social Manager

CREATE TABLE IF NOT EXISTS `sponsored_ads_requests` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT 'معرف المستخدم',

  -- معلومات الاتصال
  `name` VARCHAR(255) NOT NULL COMMENT 'الاسم الكامل',
  `email` VARCHAR(255) NOT NULL COMMENT 'البريد الإلكتروني',
  `phone` VARCHAR(50) NOT NULL COMMENT 'رقم الهاتف',
  `company_name` VARCHAR(255) NULL COMMENT 'اسم الشركة أو البراند',

  -- تفاصيل الإعلان
  `ad_type` ENUM('social_media', 'google_ads', 'display_ads', 'video_ads', 'influencer', 'combined') NOT NULL DEFAULT 'social_media' COMMENT 'نوع الإعلان',
  `platforms` JSON NULL COMMENT 'المنصات المستهدفة (Facebook, Instagram, Twitter, etc.)',
  `campaign_goal` ENUM('awareness', 'traffic', 'engagement', 'leads', 'sales', 'app_installs') NOT NULL DEFAULT 'awareness' COMMENT 'هدف الحملة',
  `target_audience` TEXT NULL COMMENT 'وصف الجمهور المستهدف',
  `ad_content` TEXT NOT NULL COMMENT 'محتوى الإعلان أو وصفه',

  -- معلومات الميزانية والمدة
  `budget` DECIMAL(10, 2) NOT NULL COMMENT 'الميزانية',
  `currency` VARCHAR(10) DEFAULT 'AED' COMMENT 'العملة',
  `duration_days` INT NULL COMMENT 'مدة الحملة بالأيام',
  `start_date` DATE NULL COMMENT 'تاريخ البدء المطلوب',
  `end_date` DATE NULL COMMENT 'تاريخ الانتهاء المطلوب',

  -- تفاصيل إضافية
  `creative_files` JSON NULL COMMENT 'روابط الملفات الإبداعية (صور، فيديو)',
  `landing_page_url` VARCHAR(500) NULL COMMENT 'رابط الصفحة المقصودة',
  `special_requirements` TEXT NULL COMMENT 'متطلبات خاصة',

  -- حالة الطلب
  `status` ENUM('pending', 'reviewing', 'approved', 'payment_pending', 'active', 'paused', 'completed', 'cancelled') NOT NULL DEFAULT 'pending' COMMENT 'حالة الطلب',
  `admin_notes` TEXT NULL COMMENT 'ملاحظات الإدارة',
  `payment_status` ENUM('unpaid', 'partial', 'paid', 'refunded') DEFAULT 'unpaid' COMMENT 'حالة الدفع',
  `payment_amount` DECIMAL(10, 2) NULL COMMENT 'المبلغ المدفوع',

  -- إحصائيات الحملة (بعد التفعيل)
  `impressions` INT DEFAULT 0 COMMENT 'عدد المشاهدات',
  `clicks` INT DEFAULT 0 COMMENT 'عدد النقرات',
  `conversions` INT DEFAULT 0 COMMENT 'عدد التحويلات',
  `spent_amount` DECIMAL(10, 2) DEFAULT 0 COMMENT 'المبلغ المصروف',

  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_ad_type` (`ad_type`),
  INDEX `idx_campaign_goal` (`campaign_goal`),
  INDEX `idx_start_date` (`start_date`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='جدول طلبات الإعلانات الممولة';

-- إضافة Foreign Key للربط مع جدول المستخدمين (إذا كان موجوداً)
-- ALTER TABLE `sponsored_ads_requests`
--   ADD CONSTRAINT `fk_sponsored_ads_requests_user_id`
--   FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
--   ON DELETE CASCADE ON UPDATE CASCADE;

-- إدراج بيانات تجريبية (اختياري - للاختبار فقط)
-- INSERT INTO `sponsored_ads_requests` (
--   `user_id`, `name`, `email`, `phone`, `company_name`,
--   `ad_type`, `campaign_goal`, `ad_content`, `budget`, `duration_days`, `status`
-- ) VALUES
--   (1, 'أحمد محمد', 'ahmed@example.com', '0501234567', 'شركة النجاح',
--    'social_media', 'awareness', 'حملة إعلانية للتعريف بالبراند الجديد', 3000.00, 30, 'pending'),
--   (2, 'فاطمة علي', 'fatima@example.com', '0559876543', 'متجر الأزياء',
--    'combined', 'sales', 'حملة لزيادة المبيعات في موسم الصيف', 5000.00, 45, 'active');
