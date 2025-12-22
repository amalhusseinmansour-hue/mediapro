#!/bin/bash

# ========================================
# Backend Deployment Script
# ========================================
# This script deploys the Laravel backend to the production server
# Server: mediaprosocial.io
# ========================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Server Configuration
SERVER_USER="u126213189"
SERVER_HOST="82.25.83.217"
SERVER_PORT="65002"
SERVER_PASSWORD="Alenwanapp33510421@"
SERVER_PATH="/home/u126213189/domains/mediaprosocial.io/public_html"

# Local paths
LOCAL_BACKEND_PATH="backend"
ARCHIVE_NAME="backend_deployment_$(date +%Y%m%d_%H%M%S).tar.gz"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Backend Deployment Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Step 1: Check if backend directory exists
echo -e "${YELLOW}[1/8]${NC} Checking backend directory..."
if [ ! -d "$LOCAL_BACKEND_PATH" ]; then
    echo -e "${RED}Error: Backend directory not found!${NC}"
    exit 1
fi
echo -e "${GREEN} Backend directory found${NC}"
echo ""

# Step 2: Create archive excluding sensitive files
echo -e "${YELLOW}[2/8]${NC} Creating deployment archive..."
cd "$LOCAL_BACKEND_PATH" || exit 1

tar -czf "../$ARCHIVE_NAME" \
    --exclude='.env' \
    --exclude='node_modules' \
    --exclude='vendor' \
    --exclude='storage/logs/*' \
    --exclude='.git' \
    --exclude='.gitignore' \
    --exclude='*.log' \
    --exclude='.phpunit.result.cache' \
    .

cd ..

if [ ! -f "$ARCHIVE_NAME" ]; then
    echo -e "${RED}Error: Failed to create archive!${NC}"
    exit 1
fi

ARCHIVE_SIZE=$(du -h "$ARCHIVE_NAME" | cut -f1)
echo -e "${GREEN} Archive created: $ARCHIVE_NAME ($ARCHIVE_SIZE)${NC}"
echo ""

# Step 3: Upload archive to server
echo -e "${YELLOW}[3/8]${NC} Uploading to server..."
echo -e "${BLUE}This may take a few minutes depending on your internet speed...${NC}"

"/c/Program Files/PuTTY/pscp" -P "$SERVER_PORT" -pw "$SERVER_PASSWORD" \
    "$ARCHIVE_NAME" \
    "$SERVER_USER@$SERVER_HOST:$SERVER_PATH/"

if [ $? -eq 0 ]; then
    echo -e "${GREEN} Upload completed successfully${NC}"
else
    echo -e "${RED}Error: Upload failed!${NC}"
    echo -e "${YELLOW}Cleaning up local archive...${NC}"
    rm "$ARCHIVE_NAME"
    exit 1
fi
echo ""

# Step 4: Verify upload
echo -e "${YELLOW}[4/8]${NC} Verifying upload..."
"/c/Program Files/PuTTY/plink" -batch -P "$SERVER_PORT" -pw "$SERVER_PASSWORD" \
    "$SERVER_USER@$SERVER_HOST" \
    "ls -lh $SERVER_PATH/$ARCHIVE_NAME"

if [ $? -eq 0 ]; then
    echo -e "${GREEN} File verified on server${NC}"
else
    echo -e "${RED}Error: File not found on server!${NC}"
    exit 1
fi
echo ""

# Step 5: Extract on server
echo -e "${YELLOW}[5/8]${NC} Extracting files on server..."
"/c/Program Files/PuTTY/plink" -batch -P "$SERVER_PORT" -pw "$SERVER_PASSWORD" \
    "$SERVER_USER@$SERVER_HOST" \
    "cd $SERVER_PATH && tar -xzf $ARCHIVE_NAME && echo 'Extraction completed'"

if [ $? -eq 0 ]; then
    echo -e "${GREEN} Files extracted successfully${NC}"
else
    echo -e "${RED}Error: Extraction failed!${NC}"
    exit 1
fi
echo ""

# Step 6: Run Laravel commands
echo -e "${YELLOW}[6/8]${NC} Running Laravel setup commands..."
"/c/Program Files/PuTTY/plink" -batch -P "$SERVER_PORT" -pw "$SERVER_PASSWORD" \
    "$SERVER_USER@$SERVER_HOST" << 'ENDSSH'
cd /home/u126213189/domains/mediaprosocial.io/public_html

# Install composer dependencies
echo "Installing composer dependencies..."
composer install --no-dev --optimize-autoloader

# Set proper permissions
echo "Setting permissions..."
chmod -R 755 storage bootstrap/cache
chmod -R 775 storage/logs

# Run migrations
echo "Running database migrations..."
php artisan migrate --force

# Clear and cache configuration
echo "Caching configuration..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Create storage link if not exists
php artisan storage:link

echo "Laravel setup completed!"
ENDSSH

if [ $? -eq 0 ]; then
    echo -e "${GREEN} Laravel setup completed${NC}"
else
    echo -e "${RED}Error: Laravel setup failed!${NC}"
    echo -e "${YELLOW}You may need to run commands manually${NC}"
fi
echo ""

# Step 7: Cleanup
echo -e "${YELLOW}[7/8]${NC} Cleaning up..."

# Remove archive from server
"/c/Program Files/PuTTY/plink" -batch -P "$SERVER_PORT" -pw "$SERVER_PASSWORD" \
    "$SERVER_USER@$SERVER_HOST" \
    "rm $SERVER_PATH/$ARCHIVE_NAME"

# Remove local archive
rm "$ARCHIVE_NAME"

echo -e "${GREEN} Cleanup completed${NC}"
echo ""

# Step 8: Final verification
echo -e "${YELLOW}[8/8]${NC} Final verification..."
"/c/Program Files/PuTTY/plink" -batch -P "$SERVER_PORT" -pw "$SERVER_PASSWORD" \
    "$SERVER_USER@$SERVER_HOST" \
    "cd $SERVER_PATH && php artisan --version"

if [ $? -eq 0 ]; then
    echo -e "${GREEN} Deployment verification passed${NC}"
else
    echo -e "${YELLOW}Warning: Could not verify Laravel installation${NC}"
fi
echo ""

# Success message
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Deployment Completed Successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo -e "1. Update .env file on server with production credentials"
echo -e "2. Run: ${YELLOW}php artisan key:generate${NC}"
echo -e "3. Test API endpoints: ${YELLOW}https://mediaprosocial.io/api/health${NC}"
echo -e "4. Check logs: ${YELLOW}tail -f storage/logs/laravel.log${NC}"
echo ""
echo -e "${RED}   IMPORTANT:${NC}"
echo -e "Don't forget to:"
echo -e "- Update .env with production credentials"
echo -e "- Rotate all API keys (see SECURITY_NOTES.md)"
echo -e "- Test all API endpoints"
echo -e "- Monitor logs for any errors"
echo ""
