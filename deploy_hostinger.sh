#!/bin/bash

echo "========================================="
echo "Deploying to Hostinger"
echo "========================================="

# Step 1: Upload backend.tar.gz
echo "Step 1: Uploading files..."
scp -P 65002 backend/backend.tar.gz u996186400@46.202.180.189:~/

# Step 2: Execute setup on server
echo "Step 2: Setting up on server..."
ssh -p 65002 u996186400@46.202.180.189 << 'ENDSSH'

echo "Connected to server!"
echo "Current directory: $(pwd)"

# Find web root
if [ -d "public_html" ]; then
    WEB_ROOT="public_html"
elif [ -d "domains/mediapro.social/public_html" ]; then
    WEB_ROOT="domains/mediapro.social/public_html"
else
    echo "ERROR: Cannot find web root directory"
    exit 1
fi

echo "Web root: $WEB_ROOT"
cd $WEB_ROOT

# Backup existing .env
if [ -f .env ]; then
    echo "✓ Backing up .env..."
    cp .env ~/.env_backup_$(date +%Y%m%d_%H%M%S)
fi

# Clear directory (keep cgi-bin)
echo "✓ Cleaning old files..."
find . -mindepth 1 -maxdepth 1 ! -name 'cgi-bin' ! -name '.htaccess' -exec rm -rf {} + 2>/dev/null

# Extract files
echo "✓ Extracting backend files..."
tar -xzf ~/backend.tar.gz || exit 1

# Create .env file
echo "✓ Creating .env file..."
cat > .env << 'ENVFILE'
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

VITE_APP_NAME="${APP_NAME}"
ENVFILE

# Check for composer
if command -v composer &> /dev/null; then
    COMPOSER="composer"
elif [ -f /usr/local/bin/composer ]; then
    COMPOSER="/usr/local/bin/composer"
elif [ -f ~/composer.phar ]; then
    COMPOSER="php ~/composer.phar"
else
    echo "⚠ Composer not found, downloading..."
    curl -sS https://getcomposer.org/installer | php
    COMPOSER="php composer.phar"
fi

# Install dependencies
echo "✓ Installing composer dependencies..."
$COMPOSER install --no-dev --optimize-autoloader --no-interaction || exit 1

# Set permissions
echo "✓ Setting permissions..."
chmod -R 755 storage bootstrap/cache 2>/dev/null
find storage -type f -exec chmod 644 {} \; 2>/dev/null
find storage -type d -exec chmod 755 {} \; 2>/dev/null

# Clear caches
echo "✓ Clearing caches..."
php artisan config:clear 2>/dev/null
php artisan cache:clear 2>/dev/null
php artisan route:clear 2>/dev/null
php artisan view:clear 2>/dev/null

# Run migrations
echo "✓ Running migrations..."
php artisan migrate --force 2>&1

# Optimize
echo "✓ Optimizing..."
php artisan config:cache 2>/dev/null
php artisan route:cache 2>/dev/null
php artisan view:cache 2>/dev/null

# Create .htaccess in public
echo "✓ Creating .htaccess..."
cat > public/.htaccess << 'HTACCESS'
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
HTACCESS

# Create root .htaccess to redirect to public
cat > .htaccess << 'ROOTHTACCESS'
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteRule ^(.*)$ public/$1 [L]
</IfModule>
ROOTHTACCESS

echo ""
echo "========================================="
echo "✅ Deployment completed!"
echo "========================================="
echo ""
echo "IMPORTANT: In Hostinger control panel:"
echo "Change Document Root to: public_html/public"
echo ""
echo "Then visit: https://www.mediapro.social"
echo ""

ENDSSH

echo ""
echo "Done!"
