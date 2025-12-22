# 🔥 الكود المتبقي - كل شيء في ملف واحد

## انسخ والصق هذا الكود في الملفات المناسبة

---

## 1. ScheduledPostController.php
**المسار:** `app/Http/Controllers/Api/ScheduledPostController.php`

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ScheduledPost;
use App\Jobs\PublishPostJob;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ScheduledPostController extends Controller
{
    public function index(Request $request)
    {
        $query = ScheduledPost::where('user_id', $request->user()->id)
            ->with(['automationRule', 'logs']);

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        if ($request->has('platform')) {
            $query->forPlatform($request->platform);
        }

        $posts = $query->orderBy('scheduled_at', 'desc')
            ->paginate($request->get('per_page', 20));

        return response()->json([
            'success' => true,
            'posts' => $posts,
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'content' => 'required|string|max:5000',
            'title' => 'nullable|string|max:255',
            'media_urls' => 'nullable|array',
            'media_urls.*' => 'url',
            'media_type' => 'nullable|in:none,image,video,carousel,link',
            'link_url' => 'nullable|url',
            'platforms' => 'required|array|min:1',
            'platforms.*' => 'in:facebook,instagram,twitter,linkedin,tiktok,youtube,pinterest,threads,snapchat',
            'account_ids' => 'nullable|array',
            'scheduled_at' => 'required|date|after:now',
            'scheduling_type' => 'nullable|in:immediate,scheduled,optimal',
            'platform_settings' => 'nullable|array',
            'track_analytics' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $post = ScheduledPost::create([
            'user_id' => $request->user()->id,
            'content' => $request->content,
            'title' => $request->title,
            'media_urls' => $request->media_urls,
            'media_type' => $request->media_type ?? 'none',
            'link_url' => $request->link_url,
            'link_title' => $request->link_title,
            'link_description' => $request->link_description,
            'link_image_url' => $request->link_image_url,
            'platforms' => $request->platforms,
            'account_ids' => $request->account_ids,
            'scheduled_at' => $request->scheduled_at,
            'scheduling_type' => $request->scheduling_type ?? 'scheduled',
            'platform_settings' => $request->platform_settings,
            'status' => 'scheduled',
            'track_analytics' => $request->track_analytics ?? false,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Post scheduled successfully',
            'post' => $post,
        ], 201);
    }

    public function show(Request $request, int $id)
    {
        $post = ScheduledPost::where('user_id', $request->user()->id)
            ->with(['logs'])
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'post' => $post,
        ]);
    }

    public function update(Request $request, int $id)
    {
        $post = ScheduledPost::where('user_id', $request->user()->id)
            ->findOrFail($id);

        if (!in_array($post->status, ['draft', 'scheduled', 'failed'])) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot update post with status: ' . $post->status,
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'content' => 'sometimes|string|max:5000',
            'title' => 'nullable|string|max:255',
            'media_urls' => 'sometimes|array',
            'platforms' => 'sometimes|array|min:1',
            'scheduled_at' => 'sometimes|date',
            'platform_settings' => 'sometimes|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $post->update($request->only([
            'content',
            'title',
            'media_urls',
            'media_type',
            'link_url',
            'platforms',
            'account_ids',
            'scheduled_at',
            'platform_settings',
        ]));

        return response()->json([
            'success' => true,
            'message' => 'Post updated successfully',
            'post' => $post->fresh(),
        ]);
    }

    public function destroy(Request $request, int $id)
    {
        $post = ScheduledPost::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $post->delete();

        return response()->json([
            'success' => true,
            'message' => 'Post deleted successfully',
        ]);
    }

    public function publishNow(Request $request, int $id)
    {
        $post = ScheduledPost::where('user_id', $request->user()->id)
            ->findOrFail($id);

        if (!in_array($post->status, ['scheduled', 'failed'])) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot publish post with status: ' . $post->status,
            ], 400);
        }

        PublishPostJob::dispatch($post);

        return response()->json([
            'success' => true,
            'message' => 'Post queued for immediate publishing',
        ]);
    }

    public function cancel(Request $request, int $id)
    {
        $post = ScheduledPost::where('user_id', $request->user()->id)
            ->findOrFail($id);

        if ($post->status === 'published') {
            return response()->json([
                'success' => false,
                'message' => 'Cannot cancel already published post',
            ], 400);
        }

        $post->update(['status' => 'cancelled']);

        return response()->json([
            'success' => true,
            'message' => 'Post cancelled successfully',
        ]);
    }
}
```

---

## 2. AutomationRuleController.php
**المسار:** `app/Http/Controllers/Api/AutomationRuleController.php`

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AutomationRule;
use App\Jobs\ExecuteAutomationRuleJob;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AutomationRuleController extends Controller
{
    public function index(Request $request)
    {
        $rules = AutomationRule::where('user_id', $request->user()->id)
            ->when($request->has('status'), function ($q) use ($request) {
                $q->where('status', $request->status);
            })
            ->when($request->has('rule_type'), function ($q) use ($request) {
                $q->where('rule_type', $request->rule_type);
            })
            ->orderBy('created_at', 'desc')
            ->paginate($request->get('per_page', 20));

        return response()->json([
            'success' => true,
            'rules' => $rules,
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'rule_type' => 'required|in:recurring_post,rss_feed,content_recycling,cross_posting,auto_reply,scheduled_campaign',
            'trigger_config' => 'nullable|array',
            'action_config' => 'nullable|array',
            'platforms' => 'required|array|min:1',
            'frequency' => 'required|in:daily,weekly,monthly,custom',
            'time_of_day' => 'required|date_format:H:i',
            'timezone' => 'required|timezone',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after:start_date',
            'content_pool' => 'nullable|array',
            'max_executions' => 'nullable|integer|min:1',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        // Calculate first execution time
        $nextExecution = $this->calculateNextExecution(
            $request->frequency,
            $request->time_of_day,
            $request->timezone
        );

        $rule = AutomationRule::create([
            'user_id' => $request->user()->id,
            'name' => $request->name,
            'description' => $request->description,
            'rule_type' => $request->rule_type,
            'trigger_config' => $request->trigger_config,
            'action_config' => $request->action_config,
            'platforms' => $request->platforms,
            'account_ids' => $request->account_ids,
            'frequency' => $request->frequency,
            'schedule_pattern' => $request->schedule_pattern,
            'time_of_day' => $request->time_of_day,
            'timezone' => $request->timezone,
            'start_date' => $request->start_date,
            'end_date' => $request->end_date,
            'next_execution_at' => $nextExecution,
            'content_pool' => $request->content_pool,
            'max_executions' => $request->max_executions,
            'status' => 'active',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Automation rule created successfully',
            'rule' => $rule,
        ], 201);
    }

    public function show(Request $request, int $id)
    {
        $rule = AutomationRule::where('user_id', $request->user()->id)
            ->with(['scheduledPosts'])
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'rule' => $rule,
        ]);
    }

    public function update(Request $request, int $id)
    {
        $rule = AutomationRule::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
            'platforms' => 'sometimes|array|min:1',
            'frequency' => 'sometimes|in:daily,weekly,monthly,custom',
            'time_of_day' => 'sometimes|date_format:H:i',
            'content_pool' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $rule->update($request->only([
            'name',
            'description',
            'trigger_config',
            'action_config',
            'platforms',
            'account_ids',
            'frequency',
            'time_of_day',
            'timezone',
            'content_pool',
            'max_executions',
        ]));

        return response()->json([
            'success' => true,
            'message' => 'Automation rule updated successfully',
            'rule' => $rule->fresh(),
        ]);
    }

    public function destroy(Request $request, int $id)
    {
        $rule = AutomationRule::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $rule->delete();

        return response()->json([
            'success' => true,
            'message' => 'Automation rule deleted successfully',
        ]);
    }

    public function pause(Request $request, int $id)
    {
        $rule = AutomationRule::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $rule->update(['status' => 'paused']);

        return response()->json([
            'success' => true,
            'message' => 'Automation rule paused',
        ]);
    }

    public function resume(Request $request, int $id)
    {
        $rule = AutomationRule::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $rule->update(['status' => 'active']);

        return response()->json([
            'success' => true,
            'message' => 'Automation rule resumed',
        ]);
    }

    public function executeNow(Request $request, int $id)
    {
        $rule = AutomationRule::where('user_id', $request->user()->id)
            ->findOrFail($id);

        ExecuteAutomationRuleJob::dispatch($rule);

        return response()->json([
            'success' => true,
            'message' => 'Automation rule queued for execution',
        ]);
    }

    private function calculateNextExecution(string $frequency, string $timeOfDay, string $timezone)
    {
        $tz = new \DateTimeZone($timezone);
        $now = now()->setTimezone($tz);
        $time = explode(':', $timeOfDay);

        switch ($frequency) {
            case 'daily':
                $next = $now->copy()->setTime((int)$time[0], (int)$time[1]);
                if ($next->isPast()) {
                    $next->addDay();
                }
                break;
            case 'weekly':
                $next = $now->copy()->addWeek()->setTime((int)$time[0], (int)$time[1]);
                break;
            case 'monthly':
                $next = $now->copy()->addMonth()->setTime((int)$time[0], (int)$time[1]);
                break;
            default:
                $next = $now->copy()->addDay();
        }

        return $next;
    }
}
```

---

## 3. PublishPostJob.php
**المسار:** `app/Jobs/PublishPostJob.php`

```php
<?php

namespace App\Jobs;

use App\Models\ScheduledPost;
use App\Services\SocialMedia\SocialPublishService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class PublishPostJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $tries = 3;
    public $timeout = 120;
    public $backoff = [60, 300, 900]; // 1min, 5min, 15min

    protected ScheduledPost $post;
    protected ?string $publishMethod;

    public function __construct(ScheduledPost $post, ?string $publishMethod = null)
    {
        $this->post = $post;
        $this->publishMethod = $publishMethod;
    }

    public function handle(SocialPublishService $publishService)
    {
        Log::info('Publishing scheduled post', [
            'post_id' => $this->post->id,
            'attempt' => $this->attempts(),
        ]);

        try {
            $result = $publishService->publishPost($this->post, $this->publishMethod);

            if ($result['success']) {
                Log::info('Post published successfully', [
                    'post_id' => $this->post->id,
                ]);
            } else {
                Log::warning('Post publish failed', [
                    'post_id' => $this->post->id,
                    'error' => $result['error'] ?? 'Unknown error',
                ]);

                if ($this->attempts() >= $this->tries) {
                    $this->fail(new \Exception($result['error'] ?? 'Max attempts reached'));
                }
            }

        } catch (\Exception $e) {
            Log::error('Exception during post publish', [
                'post_id' => $this->post->id,
                'error' => $e->getMessage(),
            ]);

            if ($this->attempts() >= $this->tries) {
                $this->fail($e);
            } else {
                throw $e; // Re-throw to trigger retry
            }
        }
    }

    public function failed(\Throwable $exception)
    {
        Log::error('Post publish job failed permanently', [
            'post_id' => $this->post->id,
            'error' => $exception->getMessage(),
        ]);

        $this->post->markAsFailed(
            'Job failed after ' . $this->tries . ' attempts: ' . $exception->getMessage(),
            ['exception' => get_class($exception)]
        );
    }
}
```

---

## 4. RefreshTokenJob.php
**المسار:** `app/Jobs/RefreshTokenJob.php`

```php
<?php

namespace App\Jobs;

use App\Models\UserSocialAccount;
use App\Services\SocialMedia\SocialPublishService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class RefreshTokenJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $tries = 2;
    public $timeout = 60;

    protected UserSocialAccount $account;

    public function __construct(UserSocialAccount $account)
    {
        $this->account = $account;
    }

    public function handle(SocialPublishService $publishService)
    {
        Log::info('Refreshing token for account', [
            'account_id' => $this->account->id,
            'platform' => $this->account->platform,
        ]);

        try {
            $success = $publishService->refreshAccountToken($this->account);

            if ($success) {
                Log::info('Token refreshed successfully', [
                    'account_id' => $this->account->id,
                ]);
            } else {
                Log::warning('Token refresh failed', [
                    'account_id' => $this->account->id,
                ]);
            }

        } catch (\Exception $e) {
            Log::error('Exception during token refresh', [
                'account_id' => $this->account->id,
                'error' => $e->getMessage(),
            ]);

            throw $e;
        }
    }

    public function failed(\Throwable $exception)
    {
        Log::error('Token refresh job failed', [
            'account_id' => $this->account->id,
            'error' => $exception->getMessage(),
        ]);

        $this->account->markAsFailed('Token refresh failed: ' . $exception->getMessage());
    }
}
```

---

## 5. ExecuteAutomationRuleJob.php
**المسار:** `app/Jobs/ExecuteAutomationRuleJob.php`

```php
<?php

namespace App\Jobs;

use App\Models\AutomationRule;
use App\Models\ScheduledPost;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class ExecuteAutomationRuleJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $tries = 2;
    public $timeout = 60;

    protected AutomationRule $rule;

    public function __construct(AutomationRule $rule)
    {
        $this->rule = $rule;
    }

    public function handle()
    {
        Log::info('Executing automation rule', [
            'rule_id' => $this->rule->id,
            'rule_type' => $this->rule->rule_type,
        ]);

        try {
            // Get next content from pool
            $content = $this->rule->getNextContent();

            if (!$content) {
                Log::warning('No content available for automation rule', [
                    'rule_id' => $this->rule->id,
                ]);
                return;
            }

            // Create scheduled post
            $post = ScheduledPost::create([
                'user_id' => $this->rule->user_id,
                'content' => $content['content'] ?? '',
                'title' => $content['title'] ?? null,
                'media_urls' => $content['media_urls'] ?? null,
                'media_type' => $content['media_type'] ?? 'none',
                'platforms' => $this->rule->platforms,
                'account_ids' => $this->rule->account_ids,
                'scheduled_at' => now(),
                'scheduling_type' => 'immediate',
                'platform_settings' => $this->rule->action_config,
                'automation_rule_id' => $this->rule->id,
            ]);

            // Dispatch publish job
            PublishPostJob::dispatch($post);

            // Update rule
            $this->rule->execute();

            Log::info('Automation rule executed successfully', [
                'rule_id' => $this->rule->id,
                'post_id' => $post->id,
            ]);

        } catch (\Exception $e) {
            Log::error('Exception during automation rule execution', [
                'rule_id' => $this->rule->id,
                'error' => $e->getMessage(),
            ]);

            $this->rule->markAsFailed($e->getMessage());
            throw $e;
        }
    }

    public function failed(\Throwable $exception)
    {
        Log::error('Automation rule execution failed', [
            'rule_id' => $this->rule->id,
            'error' => $exception->getMessage(),
        ]);

        $this->rule->markAsFailed($exception->getMessage());
    }
}
```

---

## 6. FetchInsightsJob.php
**المسار:** `app/Jobs/FetchInsightsJob.php`

```php
<?php

namespace App\Jobs;

use App\Models\ScheduledPost;
use App\Services\SocialMedia\AyrshareAdapter;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class FetchInsightsJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $tries = 2;
    public $timeout = 60;

    protected ScheduledPost $post;

    public function __construct(ScheduledPost $post)
    {
        $this->post = $post;
    }

    public function handle(AyrshareAdapter $ayrshare)
    {
        if (!$this->post->track_analytics) {
            return;
        }

        if ($this->post->status !== 'published') {
            return;
        }

        Log::info('Fetching analytics for post', [
            'post_id' => $this->post->id,
        ]);

        try {
            $ayrsharePostId = $this->post->publish_results['ayrshare_post_id'] ?? null;

            if (!$ayrsharePostId) {
                Log::warning('No Ayrshare post ID found', [
                    'post_id' => $this->post->id,
                ]);
                return;
            }

            $analytics = $ayrshare->getPostAnalytics($ayrsharePostId);

            if ($analytics) {
                $this->post->update([
                    'analytics_data' => $analytics,
                ]);

                Log::info('Analytics fetched successfully', [
                    'post_id' => $this->post->id,
                ]);
            }

        } catch (\Exception $e) {
            Log::error('Exception during analytics fetch', [
                'post_id' => $this->post->id,
                'error' => $e->getMessage(),
            ]);

            throw $e;
        }
    }
}
```

---

## 7. Kernel.php (Scheduler)
**المسار:** `app/Console/Kernel.php`

```php
protected function schedule(Schedule $schedule)
{
    // Check for due posts every minute
    $schedule->call(function () {
        $posts = \App\Models\ScheduledPost::pending()->get();

        foreach ($posts as $post) {
            if ($post->isDue() && $post->canRetry()) {
                \App\Jobs\PublishPostJob::dispatch($post);
            }
        }
    })->everyMinute()->name('publish-due-posts');

    // Check automation rules every 5 minutes
    $schedule->call(function () {
        $rules = \App\Models\AutomationRule::due()->get();

        foreach ($rules as $rule) {
            if ($rule->isDue()) {
                \App\Jobs\ExecuteAutomationRuleJob::dispatch($rule);
            }
        }
    })->everyFiveMinutes()->name('execute-automation-rules');

    // Refresh expiring tokens daily at 2 AM
    $schedule->call(function () {
        $accounts = \App\Models\UserSocialAccount::tokenExpiringSoon(24)->get();

        foreach ($accounts as $account) {
            \App\Jobs\RefreshTokenJob::dispatch($account);
        }
    })->dailyAt('02:00')->name('refresh-expiring-tokens');

    // Fetch analytics for published posts (6 hours after publishing)
    $schedule->call(function () {
        $posts = \App\Models\ScheduledPost::where('status', 'published')
            ->where('track_analytics', true)
            ->where('published_at', '>=', now()->subDays(7))
            ->where('published_at', '<=', now()->subHours(6))
            ->whereNull('analytics_data')
            ->get();

        foreach ($posts as $post) {
            \App\Jobs\FetchInsightsJob::dispatch($post);
        }
    })->hourly()->name('fetch-post-analytics');

    // Cleanup old logs (30 days) weekly
    $schedule->call(function () {
        \App\Models\PostLog::where('created_at', '<', now()->subDays(30))->delete();
    })->weekly()->name('cleanup-old-logs');

    // Daily summary report (optional)
    $schedule->call(function () {
        // Send daily summary to users
        // Implement as needed
    })->dailyAt('18:00')->name('daily-summary-report');
}
```

---

## 8. Routes (API)
**المسار:** `routes/api.php`

```php
use App\Http\Controllers\Api\SocialAccountController;
use App\Http\Controllers\Api\ScheduledPostController;
use App\Http\Controllers\Api\AutomationRuleController;

Route::middleware(['auth:sanctum'])->group(function () {

    // Social Accounts
    Route::apiResource('social-accounts', SocialAccountController::class);
    Route::post('social-accounts/{id}/refresh-token', [SocialAccountController::class, 'refreshToken']);
    Route::get('social-accounts-expiring-soon', [SocialAccountController::class, 'expiringSoon']);

    // Scheduled Posts
    Route::apiResource('scheduled-posts', ScheduledPostController::class);
    Route::post('scheduled-posts/{id}/publish-now', [ScheduledPostController::class, 'publishNow']);
    Route::post('scheduled-posts/{id}/cancel', [ScheduledPostController::class, 'cancel']);

    // Automation Rules
    Route::apiResource('automation-rules', AutomationRuleController::class);
    Route::post('automation-rules/{id}/pause', [AutomationRuleController::class, 'pause']);
    Route::post('automation-rules/{id}/resume', [AutomationRuleController::class, 'resume']);
    Route::post('automation-rules/{id}/execute-now', [AutomationRuleController::class, 'executeNow']);
});
```

---

## 9. Config (services.php)
**المسار:** `config/services.php`

```php
return [
    // ... existing services

    'ayrshare' => [
        'enabled' => env('AYRSHARE_ENABLED', true),
        'api_key' => env('AYRSHARE_API_KEY'),
    ],

    'postsyncer' => [
        'enabled' => env('POSTSYNCER_ENABLED', false),
        'api_key' => env('POSTSYNCER_API_KEY'),
        'base_url' => env('POSTSYNCER_BASE_URL', 'https://api.postsyncer.com/v1'),
    ],

    'webhook' => [
        'enabled' => env('WEBHOOK_ENABLED', true),
        'url' => env('WEBHOOK_URL'),
        'secret' => env('WEBHOOK_SECRET'),
    ],
];
```

---

## 10. .env.example
**المسار:** `.env.example`

```env
# Ayrshare Configuration
AYRSHARE_ENABLED=true
AYRSHARE_API_KEY=your_ayrshare_api_key_here

# PostSyncer Configuration (Optional)
POSTSYNCER_ENABLED=false
POSTSYNCER_API_KEY=
POSTSYNCER_BASE_URL=https://api.postsyncer.com/v1

# Webhook Configuration (Pabbly/Zapier)
WEBHOOK_ENABLED=true
WEBHOOK_URL=https://connect.pabbly.com/workflow/YOUR_WEBHOOK_ID
WEBHOOK_SECRET=your_webhook_secret

# Queue Configuration
QUEUE_CONNECTION=database
# For production use Redis:
# QUEUE_CONNECTION=redis
# REDIS_HOST=127.0.0.1
# REDIS_PASSWORD=null
# REDIS_PORT=6379
```

---

## 11. PHPUnit Test Example
**المسار:** `tests/Feature/ScheduledPostTest.php`

```php
<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\ScheduledPost;
use App\Models\UserSocialAccount;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ScheduledPostTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_create_scheduled_post()
    {
        $user = User::factory()->create();
        $account = UserSocialAccount::factory()->create([
            'user_id' => $user->id,
            'platform' => 'facebook',
            'status' => 'active',
        ]);

        $response = $this->actingAs($user)->postJson('/api/scheduled-posts', [
            'content' => 'Test post content',
            'platforms' => ['facebook'],
            'scheduled_at' => now()->addHour()->toIso8601String(),
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'success',
                'message',
                'post' => [
                    'id',
                    'content',
                    'platforms',
                    'status',
                ],
            ]);

        $this->assertDatabaseHas('scheduled_posts', [
            'user_id' => $user->id,
            'content' => 'Test post content',
            'status' => 'scheduled',
        ]);
    }

    public function test_user_can_publish_post_now()
    {
        $user = User::factory()->create();
        $post = ScheduledPost::factory()->create([
            'user_id' => $user->id,
            'status' => 'scheduled',
        ]);

        $response = $this->actingAs($user)
            ->postJson("/api/scheduled-posts/{$post->id}/publish-now");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Post queued for immediate publishing',
            ]);
    }
}
```

---

## 12. Postman Collection (JSON)
**اسم الملف:** `Social_Media_Automation_API.postman_collection.json`

```json
{
  "info": {
    "name": "Social Media Automation API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Social Accounts",
      "item": [
        {
          "name": "List Accounts",
          "request": {
            "method": "GET",
            "header": [
              {
                "key": "Authorization",
                "value": "Bearer {{token}}"
              }
            ],
            "url": {
              "raw": "{{base_url}}/api/social-accounts",
              "host": ["{{base_url}}"],
              "path": ["api", "social-accounts"]
            }
          }
        },
        {
          "name": "Connect Account",
          "request": {
            "method": "POST",
            "header": [
              {
                "key": "Authorization",
                "value": "Bearer {{token}}"
              },
              {
                "key": "Content-Type",
                "value": "application/json"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"platform\": \"facebook\",\n  \"platform_user_id\": \"123456789\",\n  \"username\": \"john_doe\",\n  \"display_name\": \"John Doe\",\n  \"access_token\": \"EAAxxxxxxxxxxxxx\",\n  \"token_expires_at\": \"2025-03-01T00:00:00Z\"\n}"
            },
            "url": {
              "raw": "{{base_url}}/api/social-accounts",
              "host": ["{{base_url}}"],
              "path": ["api", "social-accounts"]
            }
          }
        }
      ]
    },
    {
      "name": "Scheduled Posts",
      "item": [
        {
          "name": "Create Scheduled Post",
          "request": {
            "method": "POST",
            "header": [
              {
                "key": "Authorization",
                "value": "Bearer {{token}}"
              },
              {
                "key": "Content-Type",
                "value": "application/json"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"content\": \"🚀 Exciting announcement coming soon!\",\n  \"platforms\": [\"facebook\", \"instagram\", \"twitter\"],\n  \"media_urls\": [\"https://example.com/image.jpg\"],\n  \"media_type\": \"image\",\n  \"scheduled_at\": \"2025-01-20T10:00:00Z\",\n  \"track_analytics\": true\n}"
            },
            "url": {
              "raw": "{{base_url}}/api/scheduled-posts",
              "host": ["{{base_url}}"],
              "path": ["api", "scheduled-posts"]
            }
          }
        }
      ]
    }
  ],
  "variable": [
    {
      "key": "base_url",
      "value": "https://mediaprosocial.io"
    },
    {
      "key": "token",
      "value": "your_auth_token_here"
    }
  ]
}
```

---

## ✅ خطوات النشر السريعة

```bash
# 1. رفع الملفات
cd C:\Users\HP\social_media_manager\backend
pscp -P 65002 -r * u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/

# 2. SSH إلى السيرفر
ssh -p 65002 u126213189@82.25.83.217

# 3. تشغيل Migrations
cd /home/u126213189/domains/mediaprosocial.io/public_html
php artisan migrate

# 4. إنشاء جدول الـ queue
php artisan queue:table
php artisan migrate

# 5. تشغيل Queue Worker
nohup php artisan queue:work --sleep=3 --tries=3 > /dev/null 2>&1 &

# 6. إضافة Cron Job
crontab -e
# أضف: * * * * * cd /path && php artisan schedule:run >> /dev/null 2>&1

# 7. Clear cache
php artisan config:cache
php artisan route:cache
```

---

**تم! 🎉 كل شيء جاهز للتنفيذ!**
