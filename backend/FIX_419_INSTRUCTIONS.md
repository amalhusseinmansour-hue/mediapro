# Fix 419 Page Expired Error - Instructions

## Problem
Getting "419 Page Expired" when trying to login at https://mediaprosocial.io/admin/login

## Root Cause
The issue is caused by `SESSION_ENCRYPT=true` in combination with proxy/hosting configuration, which prevents CSRF tokens from working correctly.

---

## Solution - Upload and Run Script

### Step 1: Upload the Fix Script

1. Open your cPanel File Manager or FTP client (FileZilla)
2. Navigate to: `/domains/mediaprosocial.io/public_html/`
3. Upload the file: `fix_419_final.php` to this directory

### Step 2: Run the Script via Browser

Visit this URL in your browser:
```
https://mediaprosocial.io/fix_419_final.php
```

You should see output showing:
- ✅ Changes Applied
- ✅ Session files cleared
- Fix Complete!

### Step 3: Delete the Script

**IMPORTANT:** After running, delete `fix_419_final.php` from your server for security.

### Step 4: Test Login

1. Close all browser tabs for mediaprosocial.io
2. Clear browser cookies/cache OR use Incognito mode
3. Go to: https://mediaprosocial.io/admin/login
4. Login with:
   - **Email:** admin@mediapro.com
   - **Password:** Admin@12345

---

## Alternative: Manual Fix via cPanel

If you can't run the PHP script:

### Via cPanel File Manager:

1. Login to cPanel
2. Go to **File Manager**
3. Navigate to: `/domains/mediaprosocial.io/public_html/`
4. Edit the `.env` file
5. Find this line:
   ```
   SESSION_ENCRYPT=true
   ```
6. Change it to:
   ```
   SESSION_ENCRYPT=false
   ```
7. Save the file
8. Delete these folders (to clear cache):
   - `storage/framework/cache/*` (keep .gitignore)
   - `storage/framework/sessions/*` (keep .gitignore)
   - `storage/framework/views/*` (keep .gitignore)

9. If Terminal is available in cPanel, run:
   ```bash
   cd domains/mediaprosocial.io/public_html
   php artisan config:clear
   php artisan cache:clear
   ```

10. Try logging in again

---

## Alternative: Via SSH

If SSH works:

```bash
ssh -p 65002 u126213189@82.25.83.217
cd domains/mediaprosocial.io/public_html
php fix_419_final.php
rm fix_419_final.php
```

---

## What This Fix Does

1. **Disables SESSION_ENCRYPT** - This is the main fix. Session encryption can cause CSRF token mismatches when behind proxies.
2. **Clears all sessions** - Removes old corrupted session files
3. **Clears Laravel cache** - Forces Laravel to regenerate configuration
4. **Verifies APP_URL** - Ensures it's set to https://mediaprosocial.io
5. **Verifies SESSION_DOMAIN** - Ensures it's null (works for all subdomains)

---

## If Still Not Working

After trying the above, if you still get 419:

1. Check if you're accessing via `www.mediaprosocial.io` vs `mediaprosocial.io` (use the non-www version)
2. Try a completely different browser
3. Check if your hosting has a firewall/security plugin blocking cookies
4. Contact your hosting support to ensure:
   - PHP sessions are enabled
   - No ModSecurity rules blocking Laravel
   - Cookies are allowed

---

## Files Created

- `fix_419_final.php` - Upload this to your server root
- `FIX_419_INSTRUCTIONS.md` - This instruction file
- `admin_creator.php` - Already on server (can be deleted)
- `create_admin_simple.php` - In local backend folder
- `create_admin_web.php` - In local backend folder

---

## Your Admin Credentials

```
URL: https://mediaprosocial.io/admin/login
Email: admin@mediapro.com
Password: Admin@12345
```

**Remember to change your password after first login!**
