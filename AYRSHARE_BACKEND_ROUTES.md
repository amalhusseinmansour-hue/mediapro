# Ayrshare Backend Routes - Quick Reference

## Required Laravel Routes for Flutter App

Add these routes to your Laravel `routes/api.php`:

```php
use App\Http\Controllers\Api\SocialMediaController;

// Social Media Management Routes (Protected by Sanctum auth)
Route::middleware('auth:sanctum')->group(function () {

    // Get all connected social accounts for current user
    Route::get('/social/accounts', [SocialMediaController::class, 'getAccounts']);

    // Delete a social account
    Route::delete('/social/accounts/{accountId}', [SocialMediaController::class, 'deleteAccount']);

    // Create post (immediate or scheduled)
    // POST body: { content, platforms[], media_urls[], scheduled_at? }
    Route::post('/social/post', [SocialMediaController::class, 'createPost']);

    // Get all scheduled posts
    Route::get('/social/scheduled-posts', [SocialMediaController::class, 'getScheduledPosts']);

    // Cancel a scheduled post
    Route::delete('/social/scheduled-posts/{postId}', [SocialMediaController::class, 'cancelScheduledPost']);

    // Generate AI content
    // POST body: { topic, platform, tone, max_length? }
    Route::post('/social/ai-content', [SocialMediaController::class, 'generateAIContent']);

    // Get post history with pagination
    // Query params: platform?, page?, per_page?
    Route::get('/social/posts', [SocialMediaController::class, 'getPostHistory']);
});
```

## Backend Setup Checklist

### 1. Environment Variables (.env)

```env
AYRSHARE_API_KEY=your_ayrshare_api_key_here
AI_PROVIDER=claude
CLAUDE_API_KEY=your_claude_api_key_here
OPENAI_API_KEY=your_openai_api_key_here
QUEUE_CONNECTION=database
```

### 2. Run Migrations

```bash
php artisan migrate
```

This will create:
- `social_accounts` table
- `scheduled_posts` table
- `social_posts` table

### 3. Configure Queue Worker

```bash
# Start queue worker
php artisan queue:work

# Start scheduler (for scheduled posts)
php artisan schedule:work
```

### 4. Configure Cron Job (Production)

Add to your server's crontab:

```cron
* * * * * cd /path-to-your-project && php artisan schedule:run >> /dev/null 2>&1
```

### 5. Connect Social Accounts (Admin Dashboard)

Social accounts MUST be connected from the Laravel admin dashboard using Ayrshare OAuth.

**Steps:**
1. Get OAuth URLs from Ayrshare
2. User authorizes each platform
3. Store tokens in `social_accounts` table (encrypted)

**Example Controller Method:**

```php
public function connectAccount(Request $request)
{
    $validated = $request->validate([
        'platform' => 'required|string',
        'access_token' => 'required|string',
        'refresh_token' => 'nullable|string',
        'platform_account_id' => 'required|string',
        'account_name' => 'required|string',
    ]);

    SocialAccount::create([
        'user_id' => $request->user()->id,
        'platform' => $validated['platform'],
        'platform_account_id' => $validated['platform_account_id'],
        'account_name' => $validated['account_name'],
        'access_token' => Crypt::encryptString($validated['access_token']),
        'refresh_token' => $validated['refresh_token']
            ? Crypt::encryptString($validated['refresh_token'])
            : null,
        'status' => 'active',
    ]);

    return response()->json(['success' => true]);
}
```

## API Response Format

All endpoints should return JSON in this format:

### Success Response:
```json
{
    "success": true,
    "message": "Operation successful",
    "data": { ... }
}
```

### Error Response:
```json
{
    "success": false,
    "message": "Error message here",
    "errors": { ... }
}
```

## Supported Platforms

The Flutter app supports these platforms via Ayrshare:
- Facebook
- Instagram
- Twitter (X)
- LinkedIn
- YouTube
- TikTok

## Testing the Integration

### 1. Test Account Connection

```bash
curl -X GET https://mediaprosocial.io/api/social/accounts \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

Expected response:
```json
{
    "success": true,
    "data": [
        {
            "id": "1",
            "platform": "facebook",
            "accountName": "My Page",
            "isActive": true
        }
    ]
}
```

### 2. Test Immediate Post

```bash
curl -X POST https://mediaprosocial.io/api/social/post \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Hello World!",
    "platforms": ["facebook", "instagram"]
  }'
```

### 3. Test Scheduled Post

```bash
curl -X POST https://mediaprosocial.io/api/social/post \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Scheduled post",
    "platforms": ["facebook"],
    "scheduled_at": "2025-01-15 14:00:00"
  }'
```

### 4. Test AI Content Generation

```bash
curl -X POST https://mediaprosocial.io/api/social/ai-content \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "topic": "الذكاء الاصطناعي في التسويق",
    "platform": "linkedin",
    "tone": "professional"
  }'
```

## Flutter App Access

The new Ayrshare Post Screen can be accessed from:
- Dashboard → Create Post → Ayrshare Post Screen

Or navigate directly:
```dart
Get.to(() => const AyrsharePostScreen());
```

## Troubleshooting

### Issue: "No connected accounts"
**Solution:** Connect social accounts from Laravel admin dashboard first

### Issue: "Failed to create post"
**Checks:**
- Ayrshare API key is correct
- Platforms are properly connected
- Queue worker is running

### Issue: "Scheduled posts not publishing"
**Checks:**
- Cron job is configured
- Queue worker is running
- Check `scheduled_posts` table status

### Issue: "AI content generation failed"
**Checks:**
- Claude/OpenAI API keys are correct
- AI_PROVIDER env variable is set
- Check Laravel logs for errors

## Important Notes

1. **Security:** All tokens are encrypted using `Crypt::encryptString()`
2. **Authentication:** All routes require Sanctum authentication
3. **Rate Limiting:** Consider adding rate limiting to prevent abuse
4. **Logging:** All API calls to Ayrshare are logged in `social_posts` table
5. **Error Handling:** Failed posts are marked with error messages for debugging

## Next Steps

1. ✅ Flutter app is ready and installed
2. ⏳ Add routes to Laravel `routes/api.php`
3. ⏳ Configure environment variables
4. ⏳ Run migrations
5. ⏳ Start queue worker
6. ⏳ Connect social accounts via admin dashboard
7. ⏳ Test the integration

All backend files are in the `backend_laravel/` folder!
