-- Migration SQL for auto_scheduled_posts table
-- Execute this on the production database

CREATE TABLE IF NOT EXISTS `auto_scheduled_posts` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id` VARCHAR(255) NOT NULL,
    `content` TEXT NOT NULL,
    `media_urls` JSON NULL,
    `platforms` JSON NOT NULL,
    `schedule_time` TIMESTAMP NOT NULL,
    `recurrence_pattern` ENUM('once', 'daily', 'weekly', 'monthly', 'custom') NOT NULL DEFAULT 'once',
    `recurrence_interval` INT NULL,
    `recurrence_end_date` TIMESTAMP NULL,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `status` ENUM('pending', 'active', 'paused', 'completed', 'failed') NOT NULL DEFAULT 'pending',
    `last_posted_at` TIMESTAMP NULL,
    `next_post_at` TIMESTAMP NULL,
    `post_count` INT NOT NULL DEFAULT 0,
    `metadata` JSON NULL,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    PRIMARY KEY (`id`),
    INDEX `auto_scheduled_posts_user_id_index` (`user_id`),
    INDEX `auto_scheduled_posts_is_active_index` (`is_active`),
    INDEX `auto_scheduled_posts_status_index` (`status`),
    INDEX `auto_scheduled_posts_next_post_at_index` (`next_post_at`),
    CONSTRAINT `auto_scheduled_posts_user_id_foreign`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add this migration to migrations table
INSERT INTO `migrations` (`migration`, `batch`)
VALUES ('2025_11_10_000002_create_auto_scheduled_posts_table',
        (SELECT IFNULL(MAX(batch), 0) + 1 FROM (SELECT batch FROM migrations) as temp));
