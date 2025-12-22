#!/bin/bash

echo "========================================="
echo "Setting up Laravel on Server"
echo "========================================="

# Move to public_html
cd /home/u996186400/public_html

# Backup .env if exists
if [ -f .env ]; then
    echo "✓ Backing up .env..."
    cp .env ~/env_backup
fi

# Remove all files except backups
echo "✓ Cleaning directory..."
shopt -s extglob
rm -rf !(*.old|cgi-bin)
shopt -u extglob

# Extract backend files
echo "✓ Extracting backend files..."
tar -xzf ~/backend.tar.gz

# Restore .env
if [ -f ~/env_backup ]; then
    echo "✓ Restoring .env..."
    cp ~/env_backup .env
else
    # Create new .env
    echo "✓ Creating .env..."
    cat > .env << 'EOF'
APP_NAME="Social Media Manager"
APP_ENV=production
APP_KEY=base64:9dfuKgqkzuyliwjVljMQOse1Eb/35bupcnMl7IDwDm0=
APP_DEBUG=false
APP_TIMEZONE=UTC
APP_URL=https://www.mediapro.social

APP_LOCALE=ar
APP_FALLBACK_LOCALE=en

LOG_CHANNEL=single
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=socialmedia_manager
DB_USERNAME=admin_mediapro
DB_PASSWORD=3e8tWh72~

SESSION_DRIVER=file
CACHE_STORE=file
QUEUE_CONNECTION=database

FILESYSTEM_DISK=local
BROADCAST_CONNECTION=log

MAIL_MAILER=log

STRIPE_KEY=pk_test_your_stripe_key
STRIPE_SECRET=sk_test_your_stripe_secret
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret

PAYPAL_MODE=sandbox

VITE_APP_NAME="${APP_NAME}"
EOF
fi

# Install composer dependencies
echo "✓ Installing composer dependencies..."
/usr/local/bin/ea-php82 /usr/local/bin/composer install --no-dev --optimize-autoloader --no-interaction || exit 1

# Set permissions
echo "✓ Setting permissions..."
chmod -R 755 storage bootstrap/cache
find storage -type f -exec chmod 644 {} \;
find storage -type d -exec chmod 755 {} \;

# Clear caches
echo "✓ Clearing caches..."
/usr/local/bin/ea-php82 artisan config:clear
/usr/local/bin/ea-php82 artisan cache:clear
/usr/local/bin/ea-php82 artisan route:clear
/usr/local/bin/ea-php82 artisan view:clear

# Run migrations
echo "✓ Running migrations..."
/usr/local/bin/ea-php82 artisan migrate --force

# Optimize for production
echo "✓ Optimizing for production..."
/usr/local/bin/ea-php82 artisan config:cache
/usr/local/bin/ea-php82 artisan route:cache
/usr/local/bin/ea-php82 artisan view:cache

# Create .htaccess for Laravel in public folder
echo "✓ Creating .htaccess..."
cat > public/.htaccess << 'EOF'
<IfModule mod_rewrite.c>
    <IfModule mod_negotiation.c>
        Options -MultiViews -Indexes
    </IfModule>

    RewriteEngine On

    # Handle Authorization Header
    RewriteCond %{HTTP:Authorization} .
    RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

    # Redirect Trailing Slashes If Not A Folder...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_URI} (.+)/$
    RewriteRule ^ %1 [L,R=301]

    # Send Requests To Front Controller...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ index.php [L]
</IfModule>
EOF

echo "========================================="
echo "✅ Setup completed successfully!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Make sure Document Root points to: public_html/public"
echo "2. Visit: https://www.mediapro.social"
