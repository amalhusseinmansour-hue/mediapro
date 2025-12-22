# PRODUCTION DEPLOYMENT FIX - Admin Login 419 & Database

## Quick Summary

**What's broken**: Admin login returns 419 Page Expired (CSRF token issue)
**Root cause**: File-based sessions + DATABASE HOST SET TO LOCALHOST  
**Fixes applied**: Session → cookie-based, DB_HOST → 82.25.83.217, SESSION_LIFETIME → 480 min

---

## Changes Made (READY TO DEPLOY)

### 1. Fixed DB_HOST (CRITICAL)
```dotenv
# BEFORE (broken - localhost doesn't work for remote DB):
DB_HOST=localhost

# AFTER (works - actual server IP):
DB_HOST=82.25.83.217
```

### 2. Fixed Session Configuration
```dotenv
SESSION_DRIVER=cookie          # Changed from 'file'
SESSION_LIFETIME=480           # Extended from 120 minutes
SESSION_ENCRYPT=true
SESSION_DOMAIN=.mediaprosocial.io
COOKIE_DOMAIN=.mediaprosocial.io
COOKIE_SECURE=true
COOKIE_HTTP_ONLY=true
COOKIE_SAME_SITE=Lax
CACHE_STORE=database           # Changed from 'file'
```

### 3. Fixed Flutter Web Registration
- Endpoint: `/register` → `/api/register`
- Added: `password_confirmation` field
- Added: `name` field (auto-generated)
- Improved: Error messages

---

## DEPLOY NOW (3 Options)

### Option 1: PowerShell (Windows - Easiest)
```powershell
cd c:\Users\HP\social_media_manager
.\Deploy-Fixes.ps1
```

### Option 2: Manual SSH Commands
```bash
ssh -p 65002 u126213189@82.25.83.217
cd ~/public_html/backend

# Backup .env
cp .env .env.backup.$(date +%Y%m%d_%H%M%S)

# Edit .env - update these values:
nano .env
# Then run:
php artisan config:clear
php artisan cache:clear
php artisan view:clear
```

### Option 3: Git Push
```bash
git add .env
git commit -m "Fix: 419 error and database connection"
git push

# Then SSH and pull:
ssh -p 65002 u126213189@82.25.83.217
cd ~/public_html/backend
git pull
php artisan config:clear
```

---

## Test Immediately After Deployment

### Test Admin Login
1. Visit: https://mediaprosocial.io/admin/login
2. Enter: `admin@mediapro.com` / `Admin@12345`
3. Expected: Login succeeds (no 419 error)

### Test Flutter Registration
1. Open Flutter Web app
2. Click: "سجل حساب جديد"
3. Expected: Registration works with proper error messages

### Test Database
```bash
ssh -p 65002 u126213189@82.25.83.217
cd ~/public_html/backend
php artisan tinker
>>> DB::connection()->getPdo();  # Should succeed silently
>>> exit
```

---

## If Still Getting 419 Error

```bash
ssh -p 65002 u126213189@82.25.83.217
cd ~/public_html/backend

# Check what error actually is:
tail -f storage/logs/laravel.log

# If database error: create cache table
php artisan cache:table
php artisan migrate
```

---

## Admin Credentials

**Option 1**: admin@mediapro.com / Admin@12345  
**Option 2**: admin@example.com / password

---

## Files Changed

- ✅ `.env` - Database host, session config, cache store
- ✅ `lib/services/auth_service.dart` - Fixed registration API calls
- ✅ `Deploy-Fixes.ps1` - Automated deployment script (NEW)
- ✅ `deploy_fixes.sh` - Shell deployment script (NEW)

---

## Why These Fixes Work

| Issue | Root Cause | Fix |
|-------|-----------|-----|
| 419 Page Expired | File sessions on HTTPS | → Cookie-based sessions with domain |
| DB Connection Fails | localhost ≠ remote server | → Use actual server IP 82.25.83.217 |
| Flutter Registration Fails | Wrong endpoint + missing fields | → /api/register + all required fields |
| Session Expires | 120 minutes too short | → Extended to 480 minutes |
| Cache Issues | File cache unreliable | → Database cache |

---

## IMPORTANT: Don't Forget

After deploying .env:
```bash
php artisan config:clear    # Clear config cache
php artisan cache:clear     # Clear app cache
php artisan view:clear      # Clear view cache
```

Without clearing cache, old settings will still be used!
