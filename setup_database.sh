#!/bin/bash

# ============================================================================
# Social Media Manager - Database Setup Script
# Run this on the server via SSH
# ============================================================================

echo "🚀 Social Media Manager - Database Setup"
echo "=========================================="
echo ""

# Database credentials
DB_HOST="localhost"
DB_USER="u126213189"
DB_PASS="Alenwanapp33510421@"
DB_NAME="u126213189_socialmedia_ma"

echo "📊 Database Information:"
echo "   Host: $DB_HOST"
echo "   User: $DB_USER"
echo "   Database: $DB_NAME"
echo ""

# Test MySQL connection
echo "🔗 Testing MySQL connection..."
mysql -h $DB_HOST -u $DB_USER -p$DB_PASS -e "SELECT 1" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✅ MySQL connection successful!"
    echo ""
    
    # Create tables
    echo "📝 Creating database tables..."
    mysql -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME << 'EOF'
-- Create users table
CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci NULL,
  `is_admin` tinyint(1) DEFAULT 0,
  `user_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'user',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert Admin User
INSERT INTO `users` (`name`, `email`, `password`, `is_admin`, `user_type`, `created_at`, `updated_at`) 
VALUES (
  'Admin',
  'admin@example.com',
  '$2y$12$SomeHashedPasswordHere',
  1,
  'admin',
  NOW(),
  NOW()
) ON DUPLICATE KEY UPDATE `id`=`id`;

-- Create migrations table
CREATE TABLE IF NOT EXISTS `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
EOF
    
    echo "✅ Tables created successfully!"
    echo ""
    
    # Clear cache
    echo "🧹 Clearing Laravel cache..."
    if [ -d "backend" ]; then
        cd backend
        php artisan config:clear
        php artisan cache:clear
        echo "✅ Cache cleared!"
    fi
    
else
    echo "❌ MySQL connection failed!"
    echo "   Please check credentials and try again."
    exit 1
fi

echo ""
echo "✅ Setup complete!"
echo "🚀 Ready to use Filament Admin Panel"
