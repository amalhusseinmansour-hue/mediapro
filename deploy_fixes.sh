#!/bin/bash

# Deployment script for fixes to production server
# This script connects to the production server and applies all fixes

echo "=========================================="
echo "Deploying Critical Fixes to Production"
echo "=========================================="

# SSH connection details
SERVER="82.25.83.217"
PORT="65002"
USER="u126213189"
PASSWORD="Alenwanapp33510421@"
BACKEND_PATH="~/public_html/backend"

# Connect via SSH and execute deployment commands
ssh -p $PORT $USER@$SERVER << 'ENDSSH'

# Navigate to backend directory
cd ~/public_html/backend || exit 1

echo "Current working directory: $(pwd)"

# Backup current .env
cp .env .env.backup.$(date +%Y%m%d_%H%M%S)
echo "✓ Backed up .env"

# Update .env with critical fixes
cat > .env.updates << 'EOF'
# Database configuration - Use server IP instead of localhost
DB_HOST=82.25.83.217

# Session configuration - Extended lifetime and proper cookie settings
SESSION_LIFETIME=480
SESSION_ENCRYPT=true
SESSION_DOMAIN=.mediaprosocial.io

# Cookie security settings
COOKIE_DOMAIN=.mediaprosocial.io
COOKIE_SECURE=true
COOKIE_HTTP_ONLY=true
COOKIE_SAME_SITE=Lax

# Cache configuration - Use database instead of file
CACHE_STORE=database
EOF

# Read current .env and update values
while IFS='=' read -r key value; do
  if [ -z "$key" ] || [[ "$key" =~ ^# ]]; then
    continue
  fi
  
  case "$key" in
    DB_HOST) sed -i "s/^DB_HOST=.*/DB_HOST=82.25.83.217/" .env ;;
    SESSION_LIFETIME) sed -i "s/^SESSION_LIFETIME=.*/SESSION_LIFETIME=480/" .env ;;
    SESSION_ENCRYPT) sed -i "s/^SESSION_ENCRYPT=.*/SESSION_ENCRYPT=true/" .env ;;
    SESSION_DOMAIN) sed -i "s/^SESSION_DOMAIN=.*/SESSION_DOMAIN=.mediaprosocial.io/" .env ;;
    CACHE_STORE) sed -i "s/^CACHE_STORE=.*/CACHE_STORE=database/" .env ;;
  esac
done < .env.updates

# Ensure COOKIE settings exist in .env
grep -q "^COOKIE_DOMAIN=" .env || echo "COOKIE_DOMAIN=.mediaprosocial.io" >> .env
grep -q "^COOKIE_SECURE=" .env || echo "COOKIE_SECURE=true" >> .env
grep -q "^COOKIE_HTTP_ONLY=" .env || echo "COOKIE_HTTP_ONLY=true" >> .env
grep -q "^COOKIE_SAME_SITE=" .env || echo "COOKIE_SAME_SITE=Lax" >> .env

echo "✓ Updated .env with critical fixes"

# Clear all caches
php artisan config:clear
echo "✓ Cleared config cache"

php artisan cache:clear
echo "✓ Cleared application cache"

php artisan view:clear
echo "✓ Cleared view cache"

php artisan optimize:clear
echo "✓ Cleared optimization cache"

# Test database connection
echo ""
echo "Testing database connection..."
php artisan tinker << 'TINKER'
try {
  DB::connection()->getPdo();
  echo "✓ Database connection successful\n";
} catch (\Exception $e) {
  echo "✗ Database connection failed: " . $e->getMessage() . "\n";
}
exit;
TINKER

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Test admin login at: https://mediaprosocial.io/admin/login"
echo "2. Use credentials: admin@mediapro.com / Admin@12345"
echo "3. If 419 error persists, check: storage/logs/laravel.log"
echo "4. If database fails, run: php artisan cache:table && php artisan migrate"
echo ""

ENDSSH

echo "Deployment script completed!"
