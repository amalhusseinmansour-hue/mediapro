#!/bin/bash
# Run this on the live server to complete the CSRF token fix
# This script should be run AFTER the .env configuration has been deployed

echo "=========================="
echo "Completing CSRF Token Fix"
echo "=========================="
echo ""

# Step 1: Navigate to backend directory
cd /home/u126213189/public_html/backend  # Adjust path if needed

echo "✓ In backend directory"
echo ""

# Step 2: Run the migration
echo "Running sessions table migration..."
php artisan migrate --no-interaction

echo ""
echo "✓ Migration completed"
echo ""

# Step 3: Clear all caches
echo "Clearing all caches..."
php artisan cache:clear
php artisan view:clear
php artisan config:cache
php artisan route:cache

echo "✓ Caches cleared and recreated"
echo ""

# Step 4: Verify the table exists
echo "Verifying sessions table was created..."
php artisan tinker --execute="echo 'Sessions table check: ' . (DB::table('information_schema.tables')->where('table_schema', DB::getDatabaseName())->where('table_name', 'sessions')->exists() ? 'OK' : 'MISSING')"

echo ""
echo "=========================="
echo "CSRF Token Fix Complete!"
echo "=========================="
echo ""
echo "You can now test admin login at:"
echo "https://mediaprosocial.io/admin/login"
echo ""
