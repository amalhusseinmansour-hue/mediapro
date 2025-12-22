# Run this on the live server to complete the CSRF token fix
# This script should be run AFTER the .env configuration has been deployed

Write-Host "==========================" -ForegroundColor Green
Write-Host "Completing CSRF Token Fix" -ForegroundColor Green
Write-Host "==========================" -ForegroundColor Green
Write-Host ""

# Step 1: Navigate to backend directory
cd "C:\path\to\backend"  # Adjust path to your actual backend folder

Write-Host "✓ In backend directory" -ForegroundColor Green
Write-Host ""

# Step 2: Run the migration
Write-Host "Running sessions table migration..." -ForegroundColor Cyan
php artisan migrate --no-interaction

Write-Host ""
Write-Host "✓ Migration completed" -ForegroundColor Green
Write-Host ""

# Step 3: Clear all caches
Write-Host "Clearing all caches..." -ForegroundColor Cyan
php artisan cache:clear
php artisan view:clear
php artisan config:cache
php artisan route:cache

Write-Host "✓ Caches cleared and recreated" -ForegroundColor Green
Write-Host ""

# Step 4: Verify the table exists
Write-Host "Verifying sessions table was created..." -ForegroundColor Cyan
php artisan tinker --execute="echo 'Sessions table created: ' . (DB::table('information_schema.tables')->where('table_schema', DB::getDatabaseName())->where('table_name', 'sessions')->exists() ? 'YES' : 'NO')"

Write-Host ""
Write-Host "==========================" -ForegroundColor Green
Write-Host "CSRF Token Fix Complete!" -ForegroundColor Green
Write-Host "==========================" -ForegroundColor Green
Write-Host ""
Write-Host "You can now test admin login at:" -ForegroundColor Yellow
Write-Host "https://mediaprosocial.io/admin/login" -ForegroundColor Cyan
Write-Host ""
