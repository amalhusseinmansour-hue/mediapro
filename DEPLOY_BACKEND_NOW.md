# 🚀 Deploy Backend - Fix HTTP 500 Error

## ⚠️ Current Issue
The Flutter app calls `https://mediaprosocial.io/api/social/accounts` but gets **HTTP 500 error**.

This means the Laravel backend files are uploaded but **NOT CONFIGURED YET**.

---

## ✅ Quick Fix (5 Minutes)

### Step 1: SSH into Your Server

```bash
ssh u126213189@82.25.83.217 -p 65002
```

### Step 2: Navigate to Laravel Root

```bash
cd /home/u126213189/domains/mediaprosocial.io/public_html
```

### Step 3: Add Social Media Routes

Edit `routes/api.php` and add this line **at the bottom**:

```bash
nano routes/api.php
```

Add this line:
```php
// Social Media Management Routes (Ayrshare)
require __DIR__.'/api_social_media.php';
```

Press `Ctrl + O` to save, `Enter`, then `Ctrl + X` to exit.

### Step 4: Verify Route File Exists

```bash
ls -lh routes/api_social_media.php
```

If the file **doesn't exist**, create it:

```bash
nano routes/api_social_media.php
```

Paste this content:

```php
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\SocialMediaController;

/*
|--------------------------------------------------------------------------
| Social Media API Routes
|--------------------------------------------------------------------------
|
| Routes for social media management via Ayrshare
| All routes require authentication via Sanctum
|
*/

Route::middleware('auth:sanctum')->prefix('social')->group(function () {

    // Social Accounts Management
    Route::get('/accounts', [SocialMediaController::class, 'getAccounts']);
    Route::delete('/accounts/{accountId}', [SocialMediaController::class, 'deleteAccount']);

    // Post Creation (Immediate or Scheduled)
    Route::post('/post', [SocialMediaController::class, 'createPost']);

    // Scheduled Posts Management
    Route::get('/scheduled-posts', [SocialMediaController::class, 'getScheduledPosts']);
    Route::delete('/scheduled-posts/{postId}', [SocialMediaController::class, 'cancelScheduledPost']);

    // AI Content Generation
    Route::post('/ai-content', [SocialMediaController::class, 'generateAIContent']);

    // Post History
    Route::get('/posts', [SocialMediaController::class, 'getPostHistory']);
});
```

Save with `Ctrl + O`, `Enter`, `Ctrl + X`.

### Step 5: Run Database Migrations

```bash
php artisan migrate
```

This creates 3 tables:
- `social_accounts` - Connected social media accounts
- `scheduled_posts` - Scheduled posts
- `social_posts` - Post history

### Step 6: Configure Environment Variables

```bash
nano .env
```

Add these lines at the end:

```env
# Ayrshare API Configuration
AYRSHARE_API_KEY=your_ayrshare_api_key_here

# AI Content Generation (Optional)
AI_PROVIDER=claude
CLAUDE_API_KEY=your_claude_api_key_here
OPENAI_API_KEY=your_openai_api_key_here

# Queue Configuration (for scheduled posts)
QUEUE_CONNECTION=database
```

Save with `Ctrl + O`, `Enter`, `Ctrl + X`.

### Step 7: Clear Laravel Cache

```bash
php artisan config:clear
php artisan route:clear
php artisan cache:clear
```

### Step 8: Test the API

```bash
curl -X GET https://mediaprosocial.io/api/social/accounts \
  -H "Content-Type: application/json" \
  -H "Accept: application/json"
```

**Expected response:**
```json
{
    "success": true,
    "data": []
}
```

If you see this, **the error is FIXED!** ✅

---

## 🎉 Test from Flutter App

1. Open the app on your phone
2. **No more HTTP 500 errors!**
3. The app will show "لا توجد حسابات متصلة" (No connected accounts)
4. This is **NORMAL** - you haven't connected any social accounts yet

---

## 📋 Next Steps (Optional - for Full Functionality)

### Setup Queue Worker (For Scheduled Posts)

Start a queue worker in the background:

```bash
screen -S queue-worker
php artisan queue:work
# Press Ctrl+A then D to detach
```

### Setup Cron Job (For Scheduler)

```bash
crontab -e
```

Add this line:
```cron
* * * * * cd /home/u126213189/domains/mediaprosocial.io/public_html && php artisan schedule:run >> /dev/null 2>&1
```

### Connect Social Media Accounts

Social accounts must be connected from the Laravel admin dashboard using Ayrshare OAuth.

**For testing**, you can manually insert a test account:

```bash
php artisan tinker
```

Then run:
```php
use App\Models\SocialAccount;
use Illuminate\Support\Facades\Crypt;

SocialAccount::create([
    'user_id' => 1,
    'platform' => 'facebook',
    'platform_account_id' => 'test_account_123',
    'account_name' => 'Test Facebook Page',
    'access_token' => Crypt::encryptString('test_token_here'),
    'status' => 'active',
]);
```

Type `exit` to leave tinker.

---

## ✅ Verification Checklist

- [ ] Routes added to `routes/api.php`
- [ ] File `routes/api_social_media.php` exists
- [ ] Migrations run successfully (`php artisan migrate`)
- [ ] Environment variables configured in `.env`
- [ ] Laravel cache cleared
- [ ] API returns `{"success": true, "data": []}`
- [ ] Flutter app NO LONGER shows HTTP 500 error

---

## 🐛 Troubleshooting

### Still getting HTTP 500?

Check Laravel logs:
```bash
tail -100 storage/logs/laravel.log
```

### "Class SocialMediaController not found"

Make sure the controller file exists:
```bash
ls -lh app/Http/Controllers/Api/SocialMediaController.php
```

If not, you need to upload the backend files from `backend_laravel/` folder.

### "Table not found" error

Run migrations:
```bash
php artisan migrate:fresh
```

---

## 📞 Need Help?

Check these files for reference:
- `SERVER_SETUP_FINAL.md` - Complete setup guide
- `AYRSHARE_BACKEND_ROUTES.md` - API routes documentation
- `backend_laravel/` - All Laravel backend files

---

## 🎯 Summary

**The HTTP 500 error happens because:**
1. ❌ Routes not registered in `routes/api.php`
2. ❌ Database tables not created
3. ❌ Laravel cache not cleared

**After following this guide:**
1. ✅ API responds with `{"success": true, "data": []}`
2. ✅ No more HTTP 500 errors
3. ✅ App can login and work normally
4. ✅ Ready to connect social media accounts
