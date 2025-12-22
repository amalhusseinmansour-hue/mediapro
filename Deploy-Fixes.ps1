# Deployment script for fixes to production server
# Run this script to deploy all critical fixes to the production backend

param(
    [string]$SSHUser = "u126213189",
    [string]$SSHHost = "82.25.83.217",
    [int]$SSHPort = 65002,
    [string]$BackendPath = "~/public_html/backend"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deploying Critical Fixes to Production" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# SSH Command to execute on production server
$sshCommand = @"
set -e  # Exit on error

echo "=== Deploying Fixes to Production ==="
cd $BackendPath || { echo "Failed to navigate to backend directory"; exit 1; }

# Backup current .env
echo "Creating backup of .env..."
cp .env ".env.backup.\$(date +%Y%m%d_%H%M%S)"

# Update .env with critical fixes
echo "Updating .env with critical fixes..."

# Function to update or add env variable
update_env() {
    local key="\$1"
    local value="\$2"
    if grep -q "^$key=" .env; then
        sed -i "s|^$key=.*|$key=$value|" .env
    else
        echo "$key=$value" >> .env
    fi
}

# Apply all critical fixes
update_env "DB_HOST" "82.25.83.217"
update_env "SESSION_LIFETIME" "480"
update_env "SESSION_ENCRYPT" "true"
update_env "SESSION_DOMAIN" ".mediaprosocial.io"
update_env "CACHE_STORE" "database"
update_env "COOKIE_DOMAIN" ".mediaprosocial.io"
update_env "COOKIE_SECURE" "true"
update_env "COOKIE_HTTP_ONLY" "true"
update_env "COOKIE_SAME_SITE" "Lax"

echo "✓ .env updated successfully"

# Clear all Laravel caches
echo ""
echo "Clearing Laravel caches..."
php artisan config:clear 2>/dev/null && echo "✓ Config cache cleared" || echo "✗ Config cache clear failed"
php artisan cache:clear 2>/dev/null && echo "✓ App cache cleared" || echo "✗ App cache clear failed"
php artisan view:clear 2>/dev/null && echo "✓ View cache cleared" || echo "✗ View cache clear failed"
php artisan optimize:clear 2>/dev/null && echo "✓ Optimization cache cleared" || echo "✗ Optimization cache clear failed"

# Test database connection
echo ""
echo "Testing database connection..."
php artisan db:show 2>/dev/null && echo "✓ Database connection successful" || echo "✗ Database connection failed (this is expected if tables missing)"

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Visit: https://mediaprosocial.io/admin/login"
echo "2. Try login with: admin@mediapro.com / Admin@12345"
echo "3. If issues persist, check: storage/logs/laravel.log"
echo "4. If database error: ssh and run 'php artisan cache:table && php artisan migrate'"
echo ""
"@

Write-Host "Connecting to production server: $SSHHost`:$SSHPort" -ForegroundColor Yellow
Write-Host ""

# Execute SSH command
try {
    # Using ssh.exe from Windows OpenSSH
    $sshCommand | ssh -p $SSHPort "$SSHUser@$SSHHost" 2>&1
    
    Write-Host ""
    Write-Host "✓ Deployment completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "IMPORTANT: Test the following immediately:" -ForegroundColor Yellow
    Write-Host "  1. Visit https://mediaprosocial.io/admin/login"
    Write-Host "  2. Login with: admin@mediapro.com / Admin@12345"
    Write-Host "  3. Check for 419 or other errors"
    Write-Host ""
} catch {
    Write-Host "✗ Deployment failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  - Make sure SSH is installed and configured"
    Write-Host "  - Verify SSH key or password authentication is working"
    Write-Host "  - Check server connectivity: ssh -p $SSHPort $SSHUser@$SSHHost"
}
