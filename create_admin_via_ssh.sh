#!/bin/bash

# ============================================================================
# Social Media Manager - Create Admin User via SSH
# ============================================================================

echo "🔐 Creating Admin User..."
echo "========================"
echo ""

# Database credentials
DB_HOST="localhost"
DB_USER="u126213189"
DB_PASS="Alenwanapp33510421@"
DB_NAME="u126213189_socialmedia_ma"

# Create admin user using direct MySQL command
mysql -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME << EOF

-- Delete old admin if exists
DELETE FROM users WHERE email = 'admin@example.com';

-- Create users table if not exists
CREATE TABLE IF NOT EXISTS \`users\` (
  \`id\` bigint unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  \`name\` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  \`email\` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  \`email_verified_at\` timestamp NULL DEFAULT NULL,
  \`password\` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  \`remember_token\` varchar(100) COLLATE utf8mb4_unicode_ci NULL,
  \`is_admin\` tinyint(1) NOT NULL DEFAULT 0,
  \`user_type\` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'user',
  \`created_at\` timestamp NULL DEFAULT NULL,
  \`updated_at\` timestamp NULL DEFAULT NULL,
  UNIQUE KEY \`users_email_unique\` (\`email\`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert admin user
INSERT INTO \`users\` (
  \`name\`,
  \`email\`,
  \`password\`,
  \`is_admin\`,
  \`user_type\`,
  \`created_at\`,
  \`updated_at\`
) VALUES (
  'Admin',
  'admin@example.com',
  '\$2y\$12\$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQdXmBAuJ0OU7YVBW7kZVLGTi',
  1,
  'admin',
  NOW(),
  NOW()
);

-- Verify
SELECT * FROM users WHERE email = 'admin@example.com';

EOF

if [ $? -eq 0 ]; then
    echo "✅ Admin user created successfully!"
    echo ""
    echo "📧 Email:    admin@example.com"
    echo "🔐 Password: password"
    echo ""
    echo "🌐 Login at: https://mediaprosocial.io/admin/login"
else
    echo "❌ Failed to create admin user"
    exit 1
fi
