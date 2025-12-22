-- ==================== Database Schema للتكامل مع Postiz ====================

-- جدول الحسابات الاجتماعية المربوطة
CREATE TABLE IF NOT EXISTS `social_accounts` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `integration_id` VARCHAR(255) NOT NULL,
  `platform` VARCHAR(50) NOT NULL COMMENT 'facebook, instagram, twitter, linkedin, etc',
  `account_name` VARCHAR(255) DEFAULT NULL,
  `username` VARCHAR(255) DEFAULT NULL,
  `profile_picture` TEXT DEFAULT NULL,
  `access_token` TEXT DEFAULT NULL COMMENT 'encrypted',
  `refresh_token` TEXT DEFAULT NULL COMMENT 'encrypted',
  `token_expires_at` TIMESTAMP NULL DEFAULT NULL,
  `followers` INT DEFAULT 0,
  `is_active` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_platform` (`platform`),
  INDEX `idx_integration_id` (`integration_id`),
  INDEX `idx_user_platform` (`user_id`, `platform`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- جدول المنشورات
CREATE TABLE IF NOT EXISTS `posts` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `content` JSON NOT NULL COMMENT 'محتوى المنشور بصيغة JSON',
  `integration_ids` JSON NOT NULL COMMENT 'IDs الحسابات التي سينشر عليها',
  `status` ENUM('draft', 'scheduled', 'publishing', 'published', 'failed') DEFAULT 'draft',
  `scheduled_at` TIMESTAMP NULL DEFAULT NULL COMMENT 'وقت الجدولة',
  `published_at` TIMESTAMP NULL DEFAULT NULL COMMENT 'وقت النشر الفعلي',
  `platform_post_ids` JSON DEFAULT NULL COMMENT 'IDs المنشورات على كل منصة',
  `error_message` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_scheduled_at` (`scheduled_at`),
  INDEX `idx_published_at` (`published_at`),
  INDEX `idx_user_status` (`user_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- جدول تحليلات المنشورات
CREATE TABLE IF NOT EXISTS `post_analytics` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `post_id` BIGINT UNSIGNED NOT NULL,
  `platform` VARCHAR(50) NOT NULL,
  `platform_post_id` VARCHAR(255) DEFAULT NULL,
  `likes` INT DEFAULT 0,
  `comments` INT DEFAULT 0,
  `shares` INT DEFAULT 0,
  `views` INT DEFAULT 0,
  `reach` INT DEFAULT 0,
  `impressions` INT DEFAULT 0,
  `clicks` INT DEFAULT 0,
  `saves` INT DEFAULT 0,
  `engagement_rate` DECIMAL(5,2) DEFAULT 0.00,
  `last_synced_at` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_post_id` (`post_id`),
  INDEX `idx_platform` (`platform`),
  INDEX `idx_platform_post_id` (`platform_post_id`),
  UNIQUE KEY `unique_post_platform` (`post_id`, `platform`),
  FOREIGN KEY (`post_id`) REFERENCES `posts`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- جدول تحليلات الحسابات (يومية)
CREATE TABLE IF NOT EXISTS `account_analytics` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `social_account_id` BIGINT UNSIGNED NOT NULL,
  `date` DATE NOT NULL,
  `followers` INT DEFAULT 0,
  `following` INT DEFAULT 0,
  `posts_count` INT DEFAULT 0,
  `total_likes` INT DEFAULT 0,
  `total_comments` INT DEFAULT 0,
  `total_shares` INT DEFAULT 0,
  `total_reach` INT DEFAULT 0,
  `total_impressions` INT DEFAULT 0,
  `engagement_rate` DECIMAL(5,2) DEFAULT 0.00,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_social_account_id` (`social_account_id`),
  INDEX `idx_date` (`date`),
  UNIQUE KEY `unique_account_date` (`social_account_id`, `date`),
  FOREIGN KEY (`social_account_id`) REFERENCES `social_accounts`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- جدول الجدولة (Queue للمنشورات المجدولة)
CREATE TABLE IF NOT EXISTS `post_schedules` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `post_id` BIGINT UNSIGNED NOT NULL,
  `scheduled_for` TIMESTAMP NOT NULL,
  `status` ENUM('pending', 'processing', 'completed', 'failed') DEFAULT 'pending',
  `attempts` INT DEFAULT 0,
  `last_attempt_at` TIMESTAMP NULL DEFAULT NULL,
  `error_message` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_post_id` (`post_id`),
  INDEX `idx_scheduled_for` (`scheduled_for`),
  INDEX `idx_status` (`status`),
  INDEX `idx_scheduled_status` (`scheduled_for`, `status`),
  FOREIGN KEY (`post_id`) REFERENCES `posts`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- جدول Media (الوسائط المرفوعة)
CREATE TABLE IF NOT EXISTS `media` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `type` ENUM('image', 'video', 'gif') NOT NULL,
  `url` TEXT NOT NULL,
  `path` VARCHAR(500) DEFAULT NULL,
  `filename` VARCHAR(255) DEFAULT NULL,
  `size` INT DEFAULT NULL COMMENT 'بالـ bytes',
  `mime_type` VARCHAR(100) DEFAULT NULL,
  `width` INT DEFAULT NULL,
  `height` INT DEFAULT NULL,
  `duration` INT DEFAULT NULL COMMENT 'للفيديو بالثواني',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- جدول قوالب المنشورات
CREATE TABLE IF NOT EXISTS `post_templates` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `content` JSON NOT NULL,
  `category` VARCHAR(100) DEFAULT NULL,
  `is_favorite` BOOLEAN DEFAULT FALSE,
  `usage_count` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- جدول الإشعارات
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `type` VARCHAR(50) NOT NULL COMMENT 'post_published, post_failed, new_follower, etc',
  `title` VARCHAR(255) NOT NULL,
  `message` TEXT DEFAULT NULL,
  `data` JSON DEFAULT NULL,
  `is_read` BOOLEAN DEFAULT FALSE,
  `read_at` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_is_read` (`is_read`),
  INDEX `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==================== تحديث جدول Users ====================

-- إضافة حقول للاشتراكات
ALTER TABLE `users`
ADD COLUMN IF NOT EXISTS `subscription_plan` ENUM('free', 'basic', 'pro', 'enterprise') DEFAULT 'free',
ADD COLUMN IF NOT EXISTS `subscription_status` ENUM('active', 'inactive', 'cancelled', 'expired') DEFAULT 'inactive',
ADD COLUMN IF NOT EXISTS `subscription_expires_at` TIMESTAMP NULL DEFAULT NULL,
ADD COLUMN IF NOT EXISTS `posts_limit` INT DEFAULT 10 COMMENT 'عدد المنشورات المسموح شهرياً',
ADD COLUMN IF NOT EXISTS `accounts_limit` INT DEFAULT 3 COMMENT 'عدد الحسابات المسموح ربطها',
ADD COLUMN IF NOT EXISTS `posts_count_this_month` INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS `last_reset_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- ==================== Views للتقارير ====================

-- View: ملخص المستخدم
CREATE OR REPLACE VIEW `user_summary` AS
SELECT
    u.id AS user_id,
    u.name,
    u.email,
    u.subscription_plan,
    COUNT(DISTINCT sa.id) AS total_accounts,
    COUNT(DISTINCT CASE WHEN sa.is_active = 1 THEN sa.id END) AS active_accounts,
    COUNT(DISTINCT p.id) AS total_posts,
    COUNT(DISTINCT CASE WHEN p.status = 'published' THEN p.id END) AS published_posts,
    COUNT(DISTINCT CASE WHEN p.status = 'scheduled' THEN p.id END) AS scheduled_posts,
    COALESCE(SUM(pa.likes), 0) AS total_likes,
    COALESCE(SUM(pa.comments), 0) AS total_comments,
    COALESCE(SUM(pa.shares), 0) AS total_shares,
    COALESCE(SUM(pa.reach), 0) AS total_reach
FROM users u
LEFT JOIN social_accounts sa ON u.id = sa.user_id
LEFT JOIN posts p ON u.id = p.user_id
LEFT JOIN post_analytics pa ON p.id = pa.post_id
GROUP BY u.id;

-- View: إحصائيات المنصات
CREATE OR REPLACE VIEW `platform_stats` AS
SELECT
    sa.platform,
    COUNT(DISTINCT sa.id) AS total_accounts,
    COUNT(DISTINCT sa.user_id) AS total_users,
    COUNT(DISTINCT p.id) AS total_posts,
    COALESCE(AVG(pa.engagement_rate), 0) AS avg_engagement_rate,
    COALESCE(SUM(pa.reach), 0) AS total_reach
FROM social_accounts sa
LEFT JOIN posts p ON JSON_CONTAINS(p.integration_ids, JSON_ARRAY(sa.id))
LEFT JOIN post_analytics pa ON p.id = pa.post_id AND pa.platform = sa.platform
GROUP BY sa.platform;

-- ==================== Stored Procedures ====================

-- Procedure: تحديث عداد المنشورات الشهري
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS reset_monthly_post_counts()
BEGIN
    UPDATE users
    SET posts_count_this_month = 0,
        last_reset_at = CURRENT_TIMESTAMP
    WHERE MONTH(last_reset_at) != MONTH(CURRENT_TIMESTAMP)
       OR YEAR(last_reset_at) != YEAR(CURRENT_TIMESTAMP);
END$$
DELIMITER ;

-- Procedure: مزامنة التحليلات من Postiz API
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sync_analytics(IN p_post_id BIGINT)
BEGIN
    -- هنا يمكن إضافة منطق المزامنة مع Postiz API
    -- يتم استدعاؤها من Laravel Queue

    UPDATE posts
    SET updated_at = CURRENT_TIMESTAMP
    WHERE id = p_post_id;
END$$
DELIMITER ;

-- ==================== Triggers ====================

-- Trigger: تحديث عداد المنشورات عند النشر
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS after_post_published
AFTER UPDATE ON posts
FOR EACH ROW
BEGIN
    IF NEW.status = 'published' AND OLD.status != 'published' THEN
        UPDATE users
        SET posts_count_this_month = posts_count_this_month + 1
        WHERE id = NEW.user_id;
    END IF;
END$$
DELIMITER ;

-- Trigger: إنشاء إشعار عند نشر منشور
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS after_post_published_notification
AFTER UPDATE ON posts
FOR EACH ROW
BEGIN
    IF NEW.status = 'published' AND OLD.status != 'published' THEN
        INSERT INTO notifications (user_id, type, title, message, data)
        VALUES (
            NEW.user_id,
            'post_published',
            'تم نشر منشورك بنجاح',
            'تم نشر منشورك على جميع المنصات المحددة',
            JSON_OBJECT('post_id', NEW.id)
        );
    END IF;
END$$
DELIMITER ;

-- ==================== Indexes للأداء ====================

-- فهارس إضافية لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_posts_user_published ON posts(user_id, published_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_status_scheduled ON posts(status, scheduled_at);
CREATE INDEX IF NOT EXISTS idx_analytics_post_platform ON post_analytics(post_id, platform);

-- ==================== البيانات الأولية ====================

-- إدراج خطط الاشتراك (إذا كان لديك جدول منفصل)
-- INSERT INTO subscription_plans (name, price, posts_limit, accounts_limit) VALUES
-- ('Free', 0, 10, 3),
-- ('Basic', 99.99, 100, 10),
-- ('Pro', 159.99, 500, 25);

-- ==================== Notes ====================
-- 1. تأكد من تشغيل هذه الـ migrations على قاعدة البيانات
-- 2. يمكنك استخدام Laravel migrations بدلاً من SQL مباشرة
-- 3. قم بإنشاء backup قبل تطبيق التغييرات
-- 4. راجع الـ indexes للتأكد من الأداء الأمثل
