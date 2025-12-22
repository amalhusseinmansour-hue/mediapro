#!/bin/bash

# Production Deployment Script
# Deploys the corrected .env file to production server

SERVER="82.25.83.217"
PORT="65002"
USER="u126213189"
BACKEND_PATH="~/public_html/backend"

echo "Connecting to production server: $SERVER:$PORT"
echo "Deploying corrected .env file..."

ssh -p $PORT $USER@$SERVER << 'EOF'

# Navigate to backend
cd ~/public_html/backend

# Backup existing .env
cp .env .env.backup.$(date +%Y%m%d_%H%M%S)
echo "✓ Backed up .env"

# Clear caches
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan optimize:clear

echo "✓ All caches cleared"

# Test database connection
php artisan db:show > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Database connection successful"
else
    echo "⚠ Database connection warning - may need cache table"
    php artisan cache:table
    php artisan migrate
fi

echo ""
echo "=========================================="
echo "✓ Production deployment complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Test admin login: https://mediaprosocial.io/admin/login"
echo "2. Credentials: admin@mediapro.com / Admin@12345"
echo "3. Check logs if issues: storage/logs/laravel.log"

EOF

echo "Deployment script completed!"
