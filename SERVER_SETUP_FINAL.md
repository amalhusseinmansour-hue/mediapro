# 🚀 Final Server Setup Guide

## ✅ What's Already Done:

1. ✅ Laravel backend files uploaded to server
2. ✅ Flutter app configured to connect to: `https://mediaprosocial.io/api`
3. ✅ Flutter app installed on phone with latest updates
4. ✅ Country picker with 230+ countries
5. ✅ Test OTP: 123456

## 📋 What You Need to Do on the Server:

### Step 1: Add Routes to Laravel

Edit your main Laravel `routes/api.php` file and add this line:

```php
// Add at the bottom of routes/api.php
require __DIR__.'/api_social_media.php';
```

This will load all the Ayrshare routes from the file you uploaded.

### Step 2: Configure Environment Variables

Edit your `.env` file on the server and add these lines:

```env
# Ayrshare API Configuration
AYRSHARE_API_KEY=your_ayrshare_api_key_here

# AI Content Generation
AI_PROVIDER=claude
CLAUDE_API_KEY=your_claude_api_key_here
OPENAI_API_KEY=your_openai_api_key_here

# Queue Configuration (for scheduled posts)
QUEUE_CONNECTION=database
```

### Step 3: Run Database Migrations

SSH into your server and run:

```bash
cd /home/u126213189/domains/mediaprosocial.io/public_html
php artisan migrate
```

This will create 3 new tables:
- `social_accounts` - Stores connected social media accounts
- `scheduled_posts` - Stores posts scheduled for future publishing
- `social_posts` - Stores published post history

### Step 4: Setup Queue Worker (Critical for Scheduled Posts)

You need a queue worker running for scheduled posts to work.

**Option A: Using Supervisor (Recommended for Production)**

Create supervisor config at `/etc/supervisor/conf.d/laravel-worker.conf`:

```ini
[program:laravel-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /home/u126213189/domains/mediaprosocial.io/public_html/artisan queue:work --sleep=3 --tries=3
autostart=true
autorestart=true
user=u126213189
numprocs=1
redirect_stderr=true
stdout_logfile=/home/u126213189/domains/mediaprosocial.io/public_html/storage/logs/worker.log
stopwaitsecs=3600
```

Then:
```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start laravel-worker:*
```

**Option B: Screen Session (Quick Start)**

```bash
screen -S queue-worker
cd /home/u126213189/domains/mediaprosocial.io/public_html
php artisan queue:work --tries=3
# Press Ctrl+A then D to detach
```

### Step 5: Setup Cron Job for Scheduler

Edit crontab:
```bash
crontab -e
```

Add this line:
```cron
* * * * * cd /home/u126213189/domains/mediaprosocial.io/public_html && php artisan schedule:run >> /dev/null 2>&1
```

This runs the scheduler every minute to check for posts that need publishing.

### Step 6: Connect Social Media Accounts

**IMPORTANT:** Social accounts must be connected from the Laravel admin dashboard (NOT from the Flutter app).

#### How to Connect Accounts via Ayrshare:

1. **Get OAuth URLs from Ayrshare:**
   - Login to your Ayrshare account
   - Go to the "Profiles" or "OAuth" section
   - Get authorization URLs for each platform

2. **Create Admin Route for OAuth Callback:**

Add to `routes/web.php`:

```php
Route::get('/admin/social/callback', function (Request $request) {
    // Handle OAuth callback
    $platform = $request->get('platform');
    $code = $request->get('code');

    // Exchange code for access token via Ayrshare
    // Store in social_accounts table with Crypt::encryptString()

    return redirect()->back()->with('success', 'Account connected!');
});
```

3. **Manually Insert Test Account (For Testing):**

```php
use App\Models\SocialAccount;
use Illuminate\Support\Facades\Crypt;

SocialAccount::create([
    'user_id' => 1, // Your user ID
    'platform' => 'facebook',
    'platform_account_id' => 'your_fb_page_id',
    'account_name' => 'My Facebook Page',
    'access_token' => Crypt::encryptString('your_ayrshare_token'),
    'status' => 'active',
]);
```

## 🧪 Testing the Setup

### Test 1: Check API Connection

From your phone or browser:
```
https://mediaprosocial.io/api/social/accounts
```

Should return:
```json
{
    "success": true,
    "data": []  // Empty until you connect accounts
}
```

### Test 2: Connect an Account

After adding a test account in the database, check again:
```
https://mediaprosocial.io/api/social/accounts
```

Should show your connected account.

### Test 3: Test AI Content Generation

```bash
curl -X POST https://mediaprosocial.io/api/social/ai-content \
  -H "Authorization: Bearer YOUR_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "topic": "التسويق الرقمي",
    "platform": "linkedin",
    "tone": "professional"
  }'
```

### Test 4: Create Test Post

```bash
curl -X POST https://mediaprosocial.io/api/social/post \
  -H "Authorization: Bearer YOUR_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Test post from API",
    "platforms": ["facebook"]
  }'
```

## 📱 Using the Flutter App

After setup is complete:

1. **Login to the app** (OTP: 123456 for testing)
2. **Go to Dashboard** → Navigate to create post
3. **Select Ayrshare Post Screen**
4. **You should see:**
   - List of connected accounts
   - Platform selection options
   - AI content generator button
   - Scheduling options

## ⚠️ Important Notes

1. **Authentication:** The app uses Sanctum for API authentication
2. **Security:** All tokens are encrypted in the database
3. **Testing:** Use test OTP `123456` for phone login during development
4. **Ayrshare:** You need a valid Ayrshare API key with active subscription
5. **AI Keys:** Claude or OpenAI API keys required for AI content generation

## 🐛 Troubleshooting

### "No connected accounts" in app
**Solution:** Connect accounts from Laravel admin dashboard first

### "Failed to create post"
**Checks:**
- Ayrshare API key is correct in `.env`
- Queue worker is running
- Platform is properly connected

### "AI content generation failed"
**Checks:**
- Claude/OpenAI API keys are correct
- `AI_PROVIDER` is set in `.env`
- Check Laravel logs: `storage/logs/laravel.log`

### Scheduled posts not publishing
**Checks:**
- Cron job is configured correctly
- Queue worker is running
- Check `scheduled_posts` table for errors

## 📞 Quick Support Commands

```bash
# Check if queue worker is running
ps aux | grep "queue:work"

# Check Laravel logs
tail -f storage/logs/laravel.log

# Check scheduled posts status
php artisan tinker
>>> App\Models\ScheduledPost::where('status', 'pending')->get();

# Manually run scheduler (testing)
php artisan schedule:run

# Clear cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

## ✅ Final Checklist

- [ ] Routes added to `routes/api.php`
- [ ] Environment variables configured in `.env`
- [ ] Migrations run successfully
- [ ] Queue worker started
- [ ] Cron job configured
- [ ] At least one social account connected
- [ ] API test successful
- [ ] Flutter app can see connected accounts
- [ ] Test post created successfully

---

## 🎉 You're Ready!

Once all steps are complete:
1. Open the Flutter app on your phone
2. Login with phone number (OTP: 123456)
3. Navigate to Create Post → Ayrshare Post Screen
4. You should see your connected social media accounts
5. Create your first post! 🚀

---

**Need Help?** Check the detailed documentation:
- `AYRSHARE_BACKEND_ROUTES.md` - API routes reference
- `MASTER_README.md` - Complete system architecture
- `backend_laravel/COMPLETE_SETUP_GUIDE.md` - Detailed backend guide
