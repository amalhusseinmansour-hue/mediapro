#!/bin/bash

# ============================================================================
# Fix Page Expired 419 Error - Automatic Setup
# Run this from SSH on your server
# ============================================================================

echo "🔧 Fixing Page Expired 419 Error..."
echo "===================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running from correct directory
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ Error: .env file not found${NC}"
    echo "Please run this script from the project root directory"
    exit 1
fi

echo -e "${YELLOW}📝 Step 1: Updating .env file...${NC}"

# Update SESSION_DRIVER
sed -i 's/SESSION_DRIVER=file/SESSION_DRIVER=cookie/g' .env
echo "   ✓ SESSION_DRIVER: file → cookie"

# Update SESSION_ENCRYPT
sed -i 's/SESSION_ENCRYPT=false/SESSION_ENCRYPT=true/g' .env
echo "   ✓ SESSION_ENCRYPT: false → true"

# Update CACHE_STORE
sed -i 's/CACHE_STORE=file/CACHE_STORE=database/g' .env
echo "   ✓ CACHE_STORE: file → database"

# Update APP_DEBUG (optional, for development)
sed -i 's/APP_DEBUG=false/APP_DEBUG=true/g' .env
echo "   ✓ APP_DEBUG: false → true"

echo ""
echo -e "${YELLOW}🧹 Step 2: Clearing caches...${NC}"

php artisan config:clear && echo "   ✓ Config cleared"
php artisan cache:clear && echo "   ✓ Cache cleared"
php artisan view:clear && echo "   ✓ Views cleared"
php artisan route:clear && echo "   ✓ Routes cleared"

echo ""
echo -e "${YELLOW}📊 Step 3: Creating cache table...${NC}"

php artisan cache:table
echo "   ✓ Cache table migration created"

echo ""
echo -e "${YELLOW}🗂️ Step 4: Running migrations...${NC}"

php artisan migrate --force
echo "   ✓ Migrations completed"

echo ""
echo -e "${YELLOW}🔐 Step 5: Fixing permissions...${NC}"

chmod -R 775 storage/
chmod -R 775 bootstrap/cache/
chmod -R 775 public/storage/
echo "   ✓ Permissions fixed"

echo ""
echo -e "${GREEN}✅ Done! Page Expired 419 should be fixed!${NC}"
echo ""
echo "🌐 Test at: https://mediaprosocial.io/admin/login"
echo "📧 Email:    admin@example.com"
echo "🔐 Password: password"
echo ""
