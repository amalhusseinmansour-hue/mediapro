-- Migration SQL for wallet_recharge_requests table
-- Execute this on the production database

CREATE TABLE IF NOT EXISTS `wallet_recharge_requests` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id` VARCHAR(255) NOT NULL,
    `amount` DECIMAL(10, 2) NOT NULL,
    `currency` VARCHAR(3) NOT NULL DEFAULT 'SAR',
    `receipt_image` VARCHAR(255) NOT NULL,
    `payment_method` VARCHAR(255) NULL,
    `bank_name` VARCHAR(255) NULL,
    `transaction_reference` VARCHAR(255) NULL,
    `notes` TEXT NULL,
    `status` ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending',
    `admin_notes` TEXT NULL,
    `processed_by` VARCHAR(255) NULL,
    `processed_at` TIMESTAMP NULL,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    PRIMARY KEY (`id`),
    INDEX `wallet_recharge_requests_user_id_index` (`user_id`),
    INDEX `wallet_recharge_requests_status_index` (`status`),
    INDEX `wallet_recharge_requests_processed_by_index` (`processed_by`),
    CONSTRAINT `wallet_recharge_requests_user_id_foreign`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `wallet_recharge_requests_processed_by_foreign`
        FOREIGN KEY (`processed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add this migration to migrations table
INSERT INTO `migrations` (`migration`, `batch`)
VALUES ('2025_11_10_000001_create_wallet_recharge_requests_table',
        (SELECT IFNULL(MAX(batch), 0) + 1 FROM (SELECT batch FROM migrations) as temp));
