#!/bin/bash

# Server credentials
SERVER="u996186400@46.202.180.189"
PORT="65002"
REMOTE_PATH="/home/u996186400/domains/mediapro.social/public_html"

echo "========================================="
echo "Deploying Social Media Manager to Server"
echo "========================================="

# Upload the archive
echo "1. Uploading files..."
scp -P $PORT backend/backend.tar.gz $SERVER:~/ || exit 1

# Connect and setup
echo "2. Extracting and setting up on server..."
ssh -p $PORT $SERVER << 'ENDSSH'

# Navigate to web root
cd /home/u996186400/domains/mediapro.social/public_html

# Backup existing .env if exists
if [ -f .env ]; then
    echo "Backing up existing .env..."
    cp .env .env.backup
fi

# Clear old files (keep .env.backup)
echo "Cleaning old files..."
find . -mindepth 1 ! -name '.env.backup' -delete

# Extract new files
echo "Extracting files..."
tar -xzf ~/backend.tar.gz -C .

# Restore .env if backup exists
if [ -f .env.backup ]; then
    echo "Restoring .env..."
    mv .env.backup .env
fi

# Install composer dependencies
echo "Installing composer dependencies..."
composer install --no-dev --optimize-autoloader || exit 1

# Set permissions
echo "Setting permissions..."
chmod -R 755 storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Generate app key if not exists
if ! grep -q "APP_KEY=base64:" .env; then
    echo "Generating application key..."
    php artisan key:generate --force
fi

# Clear all caches
echo "Clearing caches..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Run migrations
echo "Running migrations..."
php artisan migrate --force

# Optimize for production
echo "Optimizing..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Clean up
rm ~/backend.tar.gz

echo "========================================="
echo "Deployment completed successfully!"
echo "========================================="

ENDSSH

echo ""
echo "Done! Check https://www.mediapro.social"
