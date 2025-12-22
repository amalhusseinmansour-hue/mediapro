<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\SubscriptionController;
use App\Http\Controllers\Api\SubscriptionPlanController;
use App\Http\Controllers\Api\WalletController;
use App\Http\Controllers\Api\WebsiteRequestController;
use App\Http\Controllers\Api\SponsoredAdRequestController;
use App\Http\Controllers\Api\SupportTicketController;
use App\Http\Controllers\Api\BankTransferRequestController;
use App\Http\Controllers\Api\AdminDashboardController;
use App\Http\Controllers\Api\OTPController;
use App\Http\Controllers\Api\SocialMediaPostController;
use App\Http\Controllers\Api\ConnectedAccountController;
use App\Http\Controllers\Api\WalletRechargeRequestController;
use App\Http\Controllers\Api\AutoScheduledPostController;
use App\Http\Controllers\Api\AnalyticsController;
use App\Http\Controllers\Api\TikTokAnalyticsController;
use App\Http\Controllers\Api\InstagramScraperController;

// Public routes with rate limiting
Route::middleware('throttle:5,1')->group(function () {
    Route::post('/auth/register', [AuthController::class, 'register']);
    Route::post('/auth/send-otp', [AuthController::class, 'sendOTP']);
    Route::post('/auth/login', [AuthController::class, 'login']);
});

// OTP routes (Public - anyone can send/verify OTP) with strict rate limiting
Route::prefix('otp')->middleware('throttle:3,1')->group(function () {
    Route::post('/send', [OTPController::class, 'sendOTP']);
    Route::post('/verify', [OTPController::class, 'verifyOTP']);
    Route::get('/status', [OTPController::class, 'status']);
});

// Health check
Route::get('/health', function () {
    return response()->json(['status' => 'ok', 'timestamp' => now()]);
});

// Subscription Plans (Public - anyone can view available plans) with rate limiting
Route::prefix('subscription-plans')->middleware('throttle:60,1')->group(function () {
    Route::get('/', [SubscriptionPlanController::class, 'index']); // جميع الباقات
    Route::get('/individual', [SubscriptionPlanController::class, 'individualPlans']); // باقات الأفراد
    Route::get('/business', [SubscriptionPlanController::class, 'businessPlans']); // باقات الأعمال
    Route::get('/monthly', [SubscriptionPlanController::class, 'monthlyPlans']); // الباقات الشهرية
    Route::get('/yearly', [SubscriptionPlanController::class, 'yearlyPlans']); // الباقات السنوية
    Route::get('/popular', [SubscriptionPlanController::class, 'popularPlans']); // الباقات الشعبية
    Route::get('/{slug}', [SubscriptionPlanController::class, 'show']); // تفاصيل باقة محددة
});

// Legacy route (for backward compatibility)
Route::get('/subscription-plans-old', function () {
    // الحصول على الخطط من جدول subscription_plans
    $plans = \App\Models\SubscriptionPlan::active()
        ->ordered()
        ->get()
        ->map(function ($plan) {
            return [
                'id' => $plan->id,
                'name' => $plan->name,
                'name_ar' => $plan->slug == 'individual' ? 'باقة الأفراد' :
                            ($plan->slug == 'business' ? 'باقة الشركات' :
                            ($plan->slug == 'enterprise' ? 'باقة المؤسسات' : $plan->name)),
                'description' => $plan->description,
                'description_ar' => $plan->slug == 'individual' ? 'مثالية للأفراد والمستقلين' :
                                   ($plan->slug == 'business' ? 'مثالية للشركات الصغيرة والمتوسطة' :
                                   ($plan->slug == 'enterprise' ? 'حلول متقدمة للمؤسسات' : $plan->description)),
                'tier' => $plan->slug,
                'monthly_price' => $plan->type === 'monthly' ? $plan->price : ($plan->price / 12),
                'yearly_price' => $plan->type === 'yearly' ? $plan->price : ($plan->price * 12),
                'currency' => $plan->currency,
                'max_accounts' => $plan->max_accounts ?? 3,
                'max_posts_per_month' => $plan->max_posts ?? 50,
                'max_ai_requests' => $plan->ai_features ? 100 : 0,
                'has_advanced_scheduling' => $plan->scheduling,
                'has_analytics' => $plan->analytics,
                'has_team_collaboration' => $plan->slug === 'business' || $plan->slug === 'enterprise',
                'has_export_reports' => $plan->slug === 'business' || $plan->slug === 'enterprise',
                'has_priority_support' => $plan->slug === 'business' || $plan->slug === 'enterprise',
                'has_custom_branding' => $plan->slug === 'enterprise',
                'has_api' => $plan->slug === 'enterprise',
                'features' => $plan->features ?? [],
                'features_ar' => $plan->features ?? [],
                'is_popular' => $plan->is_popular,
                'badge' => $plan->is_popular ? 'Most Popular' : null,
                'badge_ar' => $plan->is_popular ? 'الأكثر شعبية' : null,
                'order' => $plan->sort_order ?? 0,
                'is_active' => $plan->is_active,
                'created_at' => $plan->created_at,
                'updated_at' => $plan->updated_at,
            ];
        });

    // إذا لم توجد خطط، نقوم بإنشاء خطط افتراضية
    if ($plans->isEmpty()) {
        $defaultPlans = [
            [
                'name' => 'Individual Plan',
                'slug' => 'individual',
                'description' => 'Perfect for individuals and freelancers',
                'type' => 'monthly',
                'price' => 99,
                'currency' => 'AED',
                'max_accounts' => 3,
                'max_posts' => 50,
                'ai_features' => true,
                'analytics' => true,
                'scheduling' => true,
                'is_popular' => true,
                'is_active' => true,
                'sort_order' => 1,
                'features' => json_encode(['3 حسابات سوشال ميديا', '50 منشور شهرياً', 'مولد محتوى AI', 'جدولة ذكية', 'تحليلات متقدمة']),
            ],
            [
                'name' => 'Business Plan',
                'slug' => 'business',
                'description' => 'Perfect for small to medium businesses',
                'type' => 'monthly',
                'price' => 199,
                'currency' => 'AED',
                'max_accounts' => 10,
                'max_posts' => 200,
                'ai_features' => true,
                'analytics' => true,
                'scheduling' => true,
                'is_popular' => false,
                'is_active' => true,
                'sort_order' => 2,
                'features' => json_encode(['10 حسابات سوشال ميديا', '200 منشور شهرياً', 'مولد محتوى AI', 'جدولة ذكية', 'تحليلات متقدمة', 'تعاون الفريق', 'دعم أولوية']),
            ],
        ];

        foreach ($defaultPlans as $planData) {
            \App\Models\SubscriptionPlan::create($planData);
        }

        // إعادة جلب الخطط
        $plans = \App\Models\SubscriptionPlan::active()
            ->ordered()
            ->get()
            ->map(function ($plan) {
                return [
                    'id' => $plan->id,
                    'name' => $plan->name,
                    'name_ar' => $plan->slug == 'individual' ? 'باقة الأفراد' :
                                ($plan->slug == 'business' ? 'باقة الشركات' : $plan->name),
                    'description' => $plan->description,
                    'description_ar' => $plan->slug == 'individual' ? 'مثالية للأفراد والمستقلين' :
                                       ($plan->slug == 'business' ? 'مثالية للشركات الصغيرة والمتوسطة' : $plan->description),
                    'tier' => $plan->slug,
                    'monthly_price' => $plan->type === 'monthly' ? $plan->price : ($plan->price / 12),
                    'yearly_price' => $plan->type === 'yearly' ? $plan->price : ($plan->price * 12),
                    'currency' => $plan->currency,
                    'max_accounts' => $plan->max_accounts ?? 3,
                    'max_posts_per_month' => $plan->max_posts ?? 50,
                    'max_ai_requests' => $plan->ai_features ? 100 : 0,
                    'has_advanced_scheduling' => $plan->scheduling,
                    'has_analytics' => $plan->analytics,
                    'has_team_collaboration' => $plan->slug === 'business' || $plan->slug === 'enterprise',
                    'has_export_reports' => $plan->slug === 'business' || $plan->slug === 'enterprise',
                    'has_priority_support' => $plan->slug === 'business' || $plan->slug === 'enterprise',
                    'has_custom_branding' => $plan->slug === 'enterprise',
                    'has_api' => $plan->slug === 'enterprise',
                    'features' => is_string($plan->features) ? json_decode($plan->features, true) : $plan->features ?? [],
                    'features_ar' => is_string($plan->features) ? json_decode($plan->features, true) : $plan->features ?? [],
                    'is_popular' => $plan->is_popular,
                    'badge' => $plan->is_popular ? 'Most Popular' : null,
                    'badge_ar' => $plan->is_popular ? 'الأكثر شعبية' : null,
                    'order' => $plan->sort_order ?? 0,
                    'is_active' => $plan->is_active,
                    'created_at' => $plan->created_at,
                    'updated_at' => $plan->updated_at,
                ];
            });
    }

    return response()->json([
        'success' => true,
        'plans' => $plans
    ]);
});

// Social OAuth Routes (String-style direct OAuth)
Route::prefix('auth')->group(function () {
    // OAuth redirect (protected with auth)
    Route::middleware(['auth:sanctum'])->get('/{platform}/redirect', [\App\Http\Controllers\Api\SocialAuthController::class, 'redirect'])
        ->where('platform', 'instagram|facebook|twitter|linkedin|tiktok|youtube|snapchat');

    // OAuth callback (public - receives callback from OAuth providers)
    Route::get('/{platform}/callback', [\App\Http\Controllers\Api\SocialAuthController::class, 'callback'])
        ->where('platform', 'instagram|facebook|twitter|linkedin|tiktok|youtube|snapchat');

    // Get user's connected accounts
    Route::middleware(['auth:sanctum'])->get('/connected-accounts', [\App\Http\Controllers\Api\SocialAuthController::class, 'getUserAccounts']);
});

// Public submission routes with strict rate limiting
Route::middleware('throttle:5,1')->group(function () {
    // Website Requests (Public - anyone can submit)
    Route::post('/website-requests', [WebsiteRequestController::class, 'store']);

    // Sponsored Ad Requests (Public - anyone can submit)
    Route::post('/sponsored-ad-requests', [SponsoredAdRequestController::class, 'store']);

    // Support Tickets (Public - anyone can submit)
    Route::post('/support-tickets', [SupportTicketController::class, 'store']);
});

// Bank Account Info (Public - anyone can view) with moderate rate limiting
Route::get('/bank-account-info', [BankTransferRequestController::class, 'bankAccountInfo'])->middleware('throttle:30,1');

// Protected routes with authentication and rate limiting
Route::middleware(['auth:sanctum', 'throttle:120,1'])->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/user', [AuthController::class, 'user']);

    Route::apiResource('users', UserController::class);
    Route::post('/subscriptions', [SubscriptionController::class, 'store']);
    Route::get('/subscriptions/{userId}', [SubscriptionController::class, 'show']);

    // Wallet routes
    Route::prefix('wallets')->group(function () {
        // User wallet endpoints
        Route::get('/{userId}', [WalletController::class, 'show']);
        Route::get('/{userId}/transactions', [WalletController::class, 'transactions']);
        Route::post('/{userId}/debit', [WalletController::class, 'debit']);

        // Admin endpoints
        Route::get('/', [WalletController::class, 'index']); // List all wallets
        Route::get('/statistics/all', [WalletController::class, 'statistics']); // Get statistics
        Route::post('/{userId}/credit', [WalletController::class, 'credit']); // Credit wallet
        Route::post('/{userId}/toggle-status', [WalletController::class, 'toggleStatus']); // Toggle status
    });

    // Wallet Recharge Request routes
    Route::prefix('wallet-recharge-requests')->group(function () {
        // User endpoints
        Route::post('/', [WalletRechargeRequestController::class, 'store']); // Submit new request
        Route::get('/user/{userId}', [WalletRechargeRequestController::class, 'getUserRequests']); // Get user's requests
        Route::get('/{id}', [WalletRechargeRequestController::class, 'show']); // Get single request

        // Admin endpoints
        Route::get('/', [WalletRechargeRequestController::class, 'index']); // List all requests
        Route::get('/statistics/all', [WalletRechargeRequestController::class, 'statistics']); // Get statistics
        Route::post('/{id}/approve', [WalletRechargeRequestController::class, 'approve']); // Approve request
        Route::post('/{id}/reject', [WalletRechargeRequestController::class, 'reject']); // Reject request
    });

    // Auto Scheduled Posts routes
    Route::prefix('auto-scheduled-posts')->group(function () {
        // User endpoints
        Route::get('/user/{userId}', [AutoScheduledPostController::class, 'index']); // Get user's posts
        Route::post('/', [AutoScheduledPostController::class, 'store']); // Create new auto post
        Route::get('/{id}', [AutoScheduledPostController::class, 'show']); // Get single post
        Route::put('/{id}', [AutoScheduledPostController::class, 'update']); // Update post
        Route::delete('/{id}', [AutoScheduledPostController::class, 'destroy']); // Delete post
        Route::post('/{id}/activate', [AutoScheduledPostController::class, 'activate']); // Activate post
        Route::post('/{id}/pause', [AutoScheduledPostController::class, 'pause']); // Pause post

        // System/Admin endpoints
        Route::get('/due/posting', [AutoScheduledPostController::class, 'getDueForPosting']); // Get posts due for posting
        Route::get('/statistics/all', [AutoScheduledPostController::class, 'statistics']); // Get statistics
    });

    // Social Media Posting routes
    Route::prefix('social-media')->group(function () {
        Route::post('/upload-photo', [SocialMediaPostController::class, 'uploadPhoto']);
        Route::post('/upload-video', [SocialMediaPostController::class, 'uploadVideo']);
        Route::post('/upload-text', [SocialMediaPostController::class, 'uploadText']);
        Route::get('/platforms', [SocialMediaPostController::class, 'getSupportedPlatforms']);
        Route::get('/status', [SocialMediaPostController::class, 'status']);
    });

    // Connected Accounts routes
    Route::prefix('connected-accounts')->group(function () {
        Route::get('/', [ConnectedAccountController::class, 'index']); // Get all connected accounts
        Route::get('/platforms', [ConnectedAccountController::class, 'platforms']); // Get supported platforms
        Route::get('/statistics', [ConnectedAccountController::class, 'statistics']); // Get statistics
        Route::post('/connect', [ConnectedAccountController::class, 'connect']); // Connect new account
        Route::delete('/{id}', [ConnectedAccountController::class, 'disconnect']); // Disconnect account
        Route::post('/{id}/toggle-status', [ConnectedAccountController::class, 'toggleStatus']); // Toggle active status
    });

    // Social Accounts routes (Alias for connected-accounts - for mobile app compatibility)
    Route::prefix('social-accounts')->group(function () {
        Route::get('/', [ConnectedAccountController::class, 'index']); // Get all connected accounts
        Route::post('/', [ConnectedAccountController::class, 'connect']); // Add new social account
        Route::get('/{id}', [ConnectedAccountController::class, 'show']); // Get specific account  
        Route::put('/{id}', [ConnectedAccountController::class, 'update']); // Update account
        Route::delete('/{id}', [ConnectedAccountController::class, 'disconnect']); // Delete account
    });

    // Website Requests Management (Admin only)
    Route::prefix('website-requests')->group(function () {
        Route::get('/', [WebsiteRequestController::class, 'index']); // List all requests
        Route::get('/statistics', [WebsiteRequestController::class, 'statistics']); // Get statistics
        Route::get('/{id}', [WebsiteRequestController::class, 'show']); // View specific request
        Route::put('/{id}', [WebsiteRequestController::class, 'update']); // Update request (status, notes)
        Route::delete('/{id}', [WebsiteRequestController::class, 'destroy']); // Delete request
    });

    // Sponsored Ad Requests Management (Admin only)
    Route::prefix('sponsored-ad-requests')->group(function () {
        Route::get('/', [SponsoredAdRequestController::class, 'index']); // List all requests
        Route::get('/statistics', [SponsoredAdRequestController::class, 'statistics']); // Get statistics
        Route::get('/{id}', [SponsoredAdRequestController::class, 'show']); // View specific request
        Route::put('/{id}', [SponsoredAdRequestController::class, 'update']); // Update request (status, notes)
        Route::delete('/{id}', [SponsoredAdRequestController::class, 'destroy']); // Delete request
    });

    // Support Tickets Management (Admin only)
    Route::prefix('support-tickets')->group(function () {
        Route::get('/', [SupportTicketController::class, 'index']); // List all tickets
        Route::get('/statistics', [SupportTicketController::class, 'statistics']); // Get statistics
        Route::get('/{id}', [SupportTicketController::class, 'show']); // View specific ticket
        Route::put('/{id}', [SupportTicketController::class, 'update']); // Update ticket (status, priority, notes, assign)
        Route::delete('/{id}', [SupportTicketController::class, 'destroy']); // Delete ticket
    });

    // Bank Transfer Requests Management
    Route::prefix('bank-transfer-requests')->group(function () {
        // User endpoints
        Route::post('/', [BankTransferRequestController::class, 'store']); // Submit new request
        Route::get('/my-requests', [BankTransferRequestController::class, 'myRequests']); // Get user's own requests

        // Admin endpoints
        Route::get('/', [BankTransferRequestController::class, 'index']); // List all requests
        Route::get('/statistics', [BankTransferRequestController::class, 'statistics']); // Get statistics
        Route::get('/{id}', [BankTransferRequestController::class, 'show']); // View specific request
        Route::put('/{id}/status', [BankTransferRequestController::class, 'updateStatus']); // Update status (approve/reject)
        Route::delete('/{id}', [BankTransferRequestController::class, 'destroy']); // Delete request
    });

    // Admin Dashboard (Admin only)
    Route::prefix('admin/dashboard')->group(function () {
        Route::get('/', [AdminDashboardController::class, 'index']); // Get all dashboard statistics
        Route::get('/recent-activities', [AdminDashboardController::class, 'recentActivities']); // Get recent activities
        Route::get('/revenue-chart', [AdminDashboardController::class, 'revenueChart']); // Get revenue chart data
        Route::get('/users-growth-chart', [AdminDashboardController::class, 'usersGrowthChart']); // Get users growth chart
    });

    // Analytics Routes (User-specific analytics and usage tracking)
    Route::prefix('analytics')->group(function () {
        Route::get('/usage', [AnalyticsController::class, 'getUsage']); // Get current usage stats
        Route::get('/overview', [AnalyticsController::class, 'getOverview']); // Get performance overview
        Route::get('/posts', [AnalyticsController::class, 'getPostsAnalytics']); // Get posts analytics
        Route::get('/platforms', [AnalyticsController::class, 'getPlatformsAnalytics']); // Get platforms analytics
        Route::get('/check-limit/{type}', [AnalyticsController::class, 'checkLimit']); // Check if user can proceed (post/ai/account)
    });

    // TikTok Analytics Routes (Using Apify API)
    Route::prefix('tiktok')->group(function () {
        Route::post('/user/profile', [TikTokAnalyticsController::class, 'getUserProfile']); // Get TikTok user profile
        Route::post('/user/posts', [TikTokAnalyticsController::class, 'getUserPosts']); // Get TikTok user posts
        Route::post('/user/followers', [TikTokAnalyticsController::class, 'getUserFollowers']); // Get TikTok user followers
        Route::post('/user/following', [TikTokAnalyticsController::class, 'getUserFollowing']); // Get TikTok user following
        Route::post('/post/details', [TikTokAnalyticsController::class, 'getPostDetails']); // Get TikTok post details
        Route::post('/post/comments', [TikTokAnalyticsController::class, 'getPostComments']); // Get TikTok post comments
        Route::post('/search/users', [TikTokAnalyticsController::class, 'searchUsers']); // Search TikTok users
        Route::post('/search/posts', [TikTokAnalyticsController::class, 'searchPosts']); // Search TikTok posts
        Route::post('/search/hashtags', [TikTokAnalyticsController::class, 'searchHashtags']); // Search TikTok hashtags
        Route::post('/video/download', [TikTokAnalyticsController::class, 'getVideoWithoutWatermark']); // Get video without watermark
    });

    // Instagram Hashtag Scraper Routes (Using Apify API)
    Route::prefix('instagram')->group(function () {
        Route::post('/scrape/hashtag', [InstagramScraperController::class, 'scrapeByHashtag']); // Scrape posts by hashtag
        Route::post('/scrape/keyword', [InstagramScraperController::class, 'scrapeByKeyword']); // Scrape posts by keyword
        Route::post('/analyze/hashtags', [InstagramScraperController::class, 'analyzeTrendingHashtags']); // Analyze trending hashtags
        Route::get('/last-results', [InstagramScraperController::class, 'getLastResults']); // Get last scraping results
        Route::post('/suggest/hashtags', [InstagramScraperController::class, 'suggestHashtags']); // Get hashtag suggestions
    });
});
