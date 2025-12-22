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
use App\Http\Controllers\Api\SocialAccountController;
use App\Http\Controllers\Api\ConnectedAccountController;
use App\Http\Controllers\Api\WalletRechargeRequestController;
use App\Http\Controllers\Api\AutoScheduledPostController;
use App\Http\Controllers\Api\AnalyticsController;
use App\Http\Controllers\Api\TikTokAnalyticsController;
use App\Http\Controllers\Api\InstagramScraperController;
use App\Http\Controllers\Api\CommunityPostController;
use App\Http\Controllers\Api\VideoGenerationController;
use App\Http\Controllers\Api\TelegramController;
use App\Http\Controllers\Api\SettingsController;
use App\Http\Controllers\Api\N8nWorkflowController;
use App\Http\Controllers\Api\GoogleDriveController;
use App\Http\Controllers\Api\PostizController;
use App\Http\Controllers\Api\LinkedInController;
use App\Http\Controllers\Auth\LinkedInAuthController;

// LinkedIn OAuth callback (Public - no auth required)
Route::get('/auth/linkedin/callback', [LinkedInAuthController::class, 'callback']);
Route::get('/auth/linkedin/redirect', [LinkedInAuthController::class, 'redirect']);

// Public routes with rate limiting
Route::middleware('throttle:5,1')->group(function () {
    Route::post('/auth/register', [AuthController::class, 'register']);
    Route::post('/auth/send-otp', [AuthController::class, 'sendOTP']);
    Route::post('/auth/verify-otp', [AuthController::class, 'verifyOTP']);
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

// Settings API (Public - read-only access to public settings)
Route::prefix('settings')->middleware('throttle:60,1')->group(function () {
    Route::get('/', [SettingsController::class, 'getPublicSettings']); // All public settings
    Route::get('/app-config', [SettingsController::class, 'getAppConfig']); // App configuration
    Route::get('/groups', [SettingsController::class, 'getGroups']); // Available groups
    Route::get('/group/{group}', [SettingsController::class, 'getSettingsByGroup']); // Settings by group
    Route::get('/{key}', [SettingsController::class, 'getSetting']); // Specific setting
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

// Social Accounts routes (Protected - requires authentication)
Route::prefix('social-accounts')->middleware(['throttle:60,1', 'auth:sanctum'])->group(function () {
    Route::get('/', [SocialAccountController::class, 'index']); // Get all connected accounts
    Route::post('/', [SocialAccountController::class, 'store']); // Add new social account
    Route::get('/{id}', [SocialAccountController::class, 'show']); // Get specific account
    Route::put('/{id}', [SocialAccountController::class, 'update']); // Update account
    Route::delete('/{id}', [SocialAccountController::class, 'destroy']); // Delete account
    // Analytics for specific account
    Route::get('/{id}/analytics', function (Request $request, $id) {
        return response()->json([
            'success' => true,
            'data' => [
                'followers' => rand(100, 10000),
                'following' => rand(50, 500),
                'posts_count' => rand(10, 100),
                'engagement_rate' => rand(1, 10) / 10,
                'recent_engagement' => [
                    'likes' => rand(100, 1000),
                    'comments' => rand(10, 100),
                    'shares' => rand(5, 50),
                ],
            ]
        ]);
    });
});

// Community Posts routes (Public GET, Protected POST/PUT/DELETE)
Route::prefix('community/posts')->middleware('throttle:60,1')->group(function () {
    Route::get('/', [CommunityPostController::class, 'index']); // Get all community posts (public)
    Route::get('/user/{userId}', [CommunityPostController::class, 'userPosts']); // Get user's posts (public, must be before /{id})
    Route::get('/{id}', [CommunityPostController::class, 'show']); // Get specific post (public)
    Route::get('/{id}/comments', [CommunityPostController::class, 'getComments']); // Get comments for a post (public)

    // Protected routes (require authentication)
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/', [CommunityPostController::class, 'store']); // Create new community post
        Route::put('/{id}', [CommunityPostController::class, 'update']); // Update post
        Route::delete('/{id}', [CommunityPostController::class, 'destroy']); // Delete post
        Route::post('/{id}/pin', [CommunityPostController::class, 'pin']); // Pin post
        Route::post('/{id}/unpin', [CommunityPostController::class, 'unpin']); // Unpin post

        // Comments routes
        Route::post('/{id}/comments', [CommunityPostController::class, 'storeComment']); // Add comment
        Route::delete('/{id}/comments/{commentId}', [CommunityPostController::class, 'deleteComment']); // Delete comment
    });
});

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

    // Note: Social Accounts routes moved outside middleware for compatibility
    // Note: Community Posts routes moved outside for public access

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

        // Advanced Analytics Endpoints
        Route::get('/engagement-breakdown', [AnalyticsController::class, 'engagementBreakdown']); // Detailed engagement metrics
        Route::get('/audience', [AnalyticsController::class, 'audienceAnalytics']); // Follower/audience analysis
        Route::get('/content-calendar', [AnalyticsController::class, 'contentCalendar']); // Monthly content calendar view
        Route::get('/best-performing', [AnalyticsController::class, 'bestPerforming']); // Top performing posts
        Route::get('/hashtag-performance', [AnalyticsController::class, 'hashtagPerformance']); // Hashtag analytics
        Route::get('/recommendations', [AnalyticsController::class, 'getRecommendations']); // AI-powered recommendations
        Route::post('/export', [AnalyticsController::class, 'exportAnalytics']); // Export analytics data
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

    // AI Video Generation Routes (Compatible with n8n Ultimate Media Agent)
    Route::prefix('video-generation')->group(function () {
        // Text to video generation (similar to n8n Create Video Tool)
        Route::post('/text-to-video', [VideoGenerationController::class, 'generateFromText']); 
        
        // Image to video generation (similar to n8n Image to Video Tool)
        Route::post('/image-to-video', [VideoGenerationController::class, 'generateFromImage']); 
        
        // Check generation status
        Route::post('/status', [VideoGenerationController::class, 'checkStatus']); 
        
        // Download completed video
        Route::post('/download', [VideoGenerationController::class, 'downloadVideo']); 
        
        // Get generation history
        Route::get('/history', [VideoGenerationController::class, 'getHistory']); 
        
        // N8N-compatible endpoint (mimics Ultimate Media Agent workflow)
        Route::post('/n8n-style', [VideoGenerationController::class, 'generateLikeN8n']); 
    });
});

// Video Generation Public Routes (for webhook/external integration compatibility)
Route::prefix('video-generation')->middleware('throttle:20,1')->group(function () {
    // Get available providers and capabilities (public)
    Route::get('/providers', [VideoGenerationController::class, 'getProviders']); 
    
    // Webhook endpoint for n8n integration (if needed)
    Route::post('/webhook/n8n', [VideoGenerationController::class, 'n8nWebhook'])->name('video.n8n.webhook'); 
});

// Telegram Bot Integration Routes (Public - for webhook compatibility)
Route::prefix('telegram')->middleware('throttle:100,1')->group(function () {
    // Webhook endpoint (receives updates from Telegram)
    Route::post('/webhook', [TelegramController::class, 'webhook'])->name('telegram.webhook');

    // Bot management endpoints (protected)
    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/bot-config', [TelegramController::class, 'getBotConfig']); // Get bot config for background service
        Route::post('/set-webhook', [TelegramController::class, 'setWebhook']);
        Route::get('/webhook-info', [TelegramController::class, 'getWebhookInfo']);
        Route::delete('/webhook', [TelegramController::class, 'deleteWebhook']);
        Route::get('/test', [TelegramController::class, 'test']);
    });
});

// N8N Workflows API (Social Media Posting via N8N)
Route::prefix('n8n-workflows')->middleware('throttle:60,1')->group(function () {
    // Public endpoints
    Route::get('/', [N8nWorkflowController::class, 'index']); // Get all active workflows
    Route::get('/platform/{platform}', [N8nWorkflowController::class, 'getByPlatform']); // Get workflow by platform
    Route::get('/{workflowId}/statistics', [N8nWorkflowController::class, 'statistics']); // Get workflow statistics

    // Protected endpoints (require authentication)
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/execute', [N8nWorkflowController::class, 'execute']); // Execute workflow
        Route::post('/post', [N8nWorkflowController::class, 'postToPlatform']); // Simplified post to platform
        Route::get('/executions', [N8nWorkflowController::class, 'executionHistory']); // Get execution history
    });
});

// Google Drive API Routes (Protected - for file management)
Route::prefix('google-drive')->middleware(['auth:sanctum', 'throttle:30,1'])->group(function () {
    Route::post('/upload', [GoogleDriveController::class, 'upload']); // Upload file to Google Drive
    Route::post('/share', [GoogleDriveController::class, 'share']); // Make file publicly accessible
    Route::delete('/delete', [GoogleDriveController::class, 'delete']); // Delete file from Google Drive
    Route::get('/file/{fileId}', [GoogleDriveController::class, 'getFile']); // Get file information
    Route::get('/status', [GoogleDriveController::class, 'status']); // Check Google Drive configuration status
});

// Postiz API Routes (Social Media Management via Postiz)
Route::prefix('postiz')->middleware('throttle:60,1')->group(function () {
    // Public endpoints
    Route::get('/status', [PostizController::class, 'getStatus']); // Get Postiz service status

    // Protected endpoints (require authentication)
    Route::middleware('auth:sanctum')->group(function () {
        // OAuth & Account Management
        Route::post('/oauth-link', [PostizController::class, 'generateOAuthLink']); // Generate OAuth link for platform
        Route::get('/integrations', [PostizController::class, 'getIntegrations']); // Get connected accounts
        Route::delete('/integrations/{id}', [PostizController::class, 'unlinkIntegration']); // Disconnect account

        // Post Management
        Route::post('/posts', [PostizController::class, 'publishPost']); // Publish or schedule post
        Route::get('/posts', [PostizController::class, 'getPosts']); // Get all posts
        Route::get('/posts/{id}', [PostizController::class, 'getPost']); // Get single post details
        Route::delete('/posts/{id}', [PostizController::class, 'deletePost']); // Delete post

        // Media Upload
        Route::post('/media', [PostizController::class, 'uploadMedia']); // Upload media file

        // Video Generation
        Route::post('/video', [PostizController::class, 'generateVideo']); // Generate video from content
    });
});

// AI Image Generation Routes (Protected - for SaaS secure image generation)
Route::prefix('ai')->middleware(['auth:sanctum', 'throttle:30,1'])->group(function () {
    // Image Generation (using Gemini API on backend)
    Route::post('/images/generate', [\App\Http\Controllers\Api\AiController::class, 'generateImage']);

    // Image Generation via Replicate (FLUX Schnell - Fast)
    Route::post('/images/replicate', [\App\Http\Controllers\Api\AiController::class, 'generateImageReplicate']);

    // Image Generation via Nano Banana (Gemini 2.5 Flash / Gemini 3 Pro)
    Route::post('/images/nanobanana', [\App\Http\Controllers\Api\AiController::class, 'generateImageNanoBanana']);

    // Content Generation
    Route::post('/content/generate', [\App\Http\Controllers\Api\AiController::class, 'generateSocialContent']);

    // Video Script Generation
    Route::post('/video-script/generate', [\App\Http\Controllers\Api\AiController::class, 'generateVideoScript']);

    // Audio Transcription
    Route::post('/audio/transcribe', [\App\Http\Controllers\Api\AiController::class, 'transcribeAudio']);

    // Generation History
    Route::get('/generations', [\App\Http\Controllers\Api\AiController::class, 'getHistory']);
    Route::get('/generations/{id}', [\App\Http\Controllers\Api\AiController::class, 'getGeneration']);

    // Video Generation with Google Veo
    Route::post('/video/veo3', [\App\Http\Controllers\Api\AiController::class, 'generateVideoVeo3']);
    Route::post('/video/veo2', [\App\Http\Controllers\Api\AiController::class, 'generateVideoVeo2']);

    // Stability AI Image Generation
    Route::post('/images/stability', [\App\Http\Controllers\Api\AiController::class, 'generateImageStabilityAI']);

    // Runway ML Video Generation
    Route::post('/video/runway', [\App\Http\Controllers\Api\AiController::class, 'generateVideoRunway']);
    Route::post('/video/runway/status', [\App\Http\Controllers\Api\AiController::class, 'checkRunwayStatus']);

    // Replicate Video Generation (Stable Video Diffusion)
    Route::post('/video/replicate', [\App\Http\Controllers\Api\AiController::class, 'generateVideoReplicate']);

    // Get all AI providers status
    Route::get('/providers', [\App\Http\Controllers\Api\AiController::class, 'getProviders']);

    // Get subscription usage summary
    Route::get('/usage', [\App\Http\Controllers\Api\AiController::class, 'getUsageSummary']);

    // AI Content Optimization (Laravel Boost AI)
    Route::prefix('optimize')->group(function () {
        Route::post('/variations', [\App\Http\Controllers\Api\AiContentOptimizationController::class, 'generateVariations']); // Generate content variations
        Route::post('/platform', [\App\Http\Controllers\Api\AiContentOptimizationController::class, 'optimizeContent']); // Optimize for platform
        Route::post('/analyze', [\App\Http\Controllers\Api\AiContentOptimizationController::class, 'analyzeContent']); // Analyze content
        Route::post('/hashtags', [\App\Http\Controllers\Api\AiContentOptimizationController::class, 'suggestHashtags']); // Suggest hashtags
        Route::post('/posting-times', [\App\Http\Controllers\Api\AiContentOptimizationController::class, 'suggestPostingTimes']); // Suggest posting times
        Route::post('/tone', [\App\Http\Controllers\Api\AiContentOptimizationController::class, 'rewriteInTone']); // Rewrite in tone
        Route::post('/translate', [\App\Http\Controllers\Api\AiContentOptimizationController::class, 'translateContent']); // Translate content
        Route::post('/from-brief', [\App\Http\Controllers\Api\AiContentOptimizationController::class, 'generateFromBrief']); // Generate from brief
        Route::post('/check', [\App\Http\Controllers\Api\AiContentOptimizationController::class, 'checkContent']); // Check content safety
        Route::post('/batch', [\App\Http\Controllers\Api\AiContentOptimizationController::class, 'batchOptimize']); // Batch optimize
        Route::post('/batch-process', [\App\Http\Controllers\Api\AiContentOptimizationController::class, 'batchProcess']); // Batch process prompts concurrently
        Route::get('/tones', [\App\Http\Controllers\Api\AiContentOptimizationController::class, 'getAvailableTones']); // Get tones
        Route::get('/languages', [\App\Http\Controllers\Api\AiContentOptimizationController::class, 'getSupportedLanguages']); // Get languages
        Route::get('/stats', [\App\Http\Controllers\Api\AiContentOptimizationController::class, 'getStats']); // Get AI stats (rate limits, providers)
        Route::post('/clear-cache', [\App\Http\Controllers\Api\AiContentOptimizationController::class, 'clearCache']); // Clear cache (admin only)
    });
});

// LinkedIn API Routes (Direct posting without Ayrshare)
Route::prefix('linkedin')->middleware(['auth:sanctum', 'throttle:30,1'])->group(function () {
    // Post content
    Route::post('/post', [LinkedInController::class, 'post']); // Universal post (auto-detect type)
    Route::post('/post/text', [LinkedInController::class, 'postText']); // Post text only
    Route::post('/post/image', [LinkedInController::class, 'postWithImage']); // Post with image
    Route::post('/post/link', [LinkedInController::class, 'postWithLink']); // Post with link/article

    // Account management
    Route::get('/validate', [LinkedInController::class, 'validateAccount']); // Validate account connection
    Route::delete('/post/{postUrn}', [LinkedInController::class, 'deletePost']); // Delete a post

    // Analytics
    Route::get('/analytics/dashboard', [LinkedInController::class, 'getAnalyticsDashboard']); // Complete analytics dashboard
    Route::get('/analytics/profile', [LinkedInController::class, 'getProfileStats']); // Profile statistics
    Route::get('/analytics/posts', [LinkedInController::class, 'getPostsAnalytics']); // Posts analytics
    Route::get('/analytics/engagement', [LinkedInController::class, 'getEngagementSummary']); // Engagement summary
    Route::get('/analytics/followers', [LinkedInController::class, 'getFollowerStats']); // Follower statistics
});

// Cloudinary Image Editing Routes
Route::prefix('cloudinary')->middleware(['auth:sanctum', 'throttle:60,1'])->group(function () {
    // Upload image
    Route::post('/upload', [\App\Http\Controllers\Api\CloudinaryController::class, 'upload']);

    // Transform image
    Route::post('/transform', [\App\Http\Controllers\Api\CloudinaryController::class, 'transform']);

    // Remove background
    Route::post('/remove-background', [\App\Http\Controllers\Api\CloudinaryController::class, 'removeBackground']);

    // Apply filter
    Route::post('/filter', [\App\Http\Controllers\Api\CloudinaryController::class, 'applyFilter']);

    // Enhance image
    Route::post('/enhance', [\App\Http\Controllers\Api\CloudinaryController::class, 'enhance']);

    // Resize image
    Route::post('/resize', [\App\Http\Controllers\Api\CloudinaryController::class, 'resize']);

    // Get available filters and effects
    Route::get('/filters', [\App\Http\Controllers\Api\CloudinaryController::class, 'getFilters']);

    // Get status
    Route::get('/status', [\App\Http\Controllers\Api\CloudinaryController::class, 'status']);
});

// ===================================
// Admin Management Routes (Admin Only)
// ===================================
Route::prefix('admin')->middleware(['auth:sanctum', 'admin'])->group(function () {
    // Dashboard
    Route::get('/dashboard', [\App\Http\Controllers\Api\AdminDashboardController::class, 'index']);
    Route::get('/dashboard/activities', [\App\Http\Controllers\Api\AdminDashboardController::class, 'recentActivities']);
    Route::get('/dashboard/revenue-chart', [\App\Http\Controllers\Api\AdminDashboardController::class, 'revenueChart']);
    Route::get('/dashboard/users-growth', [\App\Http\Controllers\Api\AdminDashboardController::class, 'usersGrowthChart']);

    // User Management
    Route::get('/users', [\App\Http\Controllers\Api\AdminUsersController::class, 'index']);
    Route::get('/users/statistics', [\App\Http\Controllers\Api\AdminUsersController::class, 'statistics']);
    Route::get('/users/export', [\App\Http\Controllers\Api\AdminUsersController::class, 'export']);
    Route::post('/users', [\App\Http\Controllers\Api\AdminUsersController::class, 'store']);
    Route::get('/users/{id}', [\App\Http\Controllers\Api\AdminUsersController::class, 'show']);
    Route::put('/users/{id}', [\App\Http\Controllers\Api\AdminUsersController::class, 'update']);
    Route::delete('/users/{id}', [\App\Http\Controllers\Api\AdminUsersController::class, 'destroy']);
    Route::post('/users/{id}/toggle-ban', [\App\Http\Controllers\Api\AdminUsersController::class, 'toggleBan']);
    Route::post('/users/{id}/add-credits', [\App\Http\Controllers\Api\AdminUsersController::class, 'addCredits']);
    Route::post('/users/{id}/grant-subscription', [\App\Http\Controllers\Api\AdminUsersController::class, 'grantSubscription']);
    Route::get('/users/{id}/activity-log', [\App\Http\Controllers\Api\AdminUsersController::class, 'getActivityLog']);

    // Settings Management
    Route::get('/settings', [\App\Http\Controllers\Api\AdminSettingsController::class, 'index']);
    Route::post('/settings', [\App\Http\Controllers\Api\AdminSettingsController::class, 'update']);
    Route::get('/settings/api-keys', [\App\Http\Controllers\Api\AdminSettingsController::class, 'getApiKeysStatus']);
    Route::post('/settings/test-api-key', [\App\Http\Controllers\Api\AdminSettingsController::class, 'testApiKey']);
    Route::get('/settings/system-health', [\App\Http\Controllers\Api\AdminSettingsController::class, 'systemHealth']);
    Route::post('/settings/clear-cache', [\App\Http\Controllers\Api\AdminSettingsController::class, 'clearCache']);
    Route::get('/settings/logs', [\App\Http\Controllers\Api\AdminSettingsController::class, 'getLogs']);
    Route::get('/settings/environment', [\App\Http\Controllers\Api\AdminSettingsController::class, 'getEnvironmentInfo']);
});

// ===================================
// Export Routes (Admin Only)
// ===================================
Route::prefix('exports')->middleware(['auth:sanctum', 'admin'])->group(function () {
    Route::get('/users', [\App\Http\Controllers\Api\ExportController::class, 'exportUsers']);
    Route::get('/payments', [\App\Http\Controllers\Api\ExportController::class, 'exportPayments']);
    Route::get('/posts', [\App\Http\Controllers\Api\ExportController::class, 'exportPosts']);
    Route::get('/subscriptions', [\App\Http\Controllers\Api\ExportController::class, 'exportSubscriptions']);
    Route::delete('/clean', [\App\Http\Controllers\Api\ExportController::class, 'cleanExports']);
});

// ===================================
// Push Notifications Routes
// ===================================
Route::prefix('push-notifications')->middleware(['auth:sanctum'])->group(function () {
    Route::post('/register-token', function (\Illuminate\Http\Request $request) {
        $service = app(\App\Services\PushNotificationService::class);
        $success = $service->registerToken($request->user(), $request->token, $request->platform ?? 'android');
        return response()->json(['success' => $success]);
    });
    Route::delete('/remove-token', function (\Illuminate\Http\Request $request) {
        $service = app(\App\Services\PushNotificationService::class);
        $success = $service->removeToken($request->user(), $request->token);
        return response()->json(['success' => $success]);
    });
});

Route::prefix('push-notifications')->middleware(['auth:sanctum', 'admin'])->group(function () {
    Route::post('/send-to-user', function (\Illuminate\Http\Request $request) {
        $service = app(\App\Services\PushNotificationService::class);
        $user = \App\Models\User::findOrFail($request->user_id);
        $result = $service->sendToUser($user, $request->title, $request->body, $request->data ?? []);
        return response()->json($result);
    });
    Route::post('/broadcast', function (\Illuminate\Http\Request $request) {
        $service = app(\App\Services\PushNotificationService::class);
        $result = $service->broadcast($request->title, $request->body, $request->data ?? []);
        return response()->json($result);
    });
    Route::post('/send-to-topic', function (\Illuminate\Http\Request $request) {
        $service = app(\App\Services\PushNotificationService::class);
        $result = $service->sendToTopic($request->topic, $request->title, $request->body, $request->data ?? []);
        return response()->json($result);
    });
});

// ===================================
// Media Upload Routes
// ===================================
Route::prefix('media')->middleware(['auth:sanctum', 'throttle:30,1'])->group(function () {
    Route::post('/upload/image', [\App\Http\Controllers\Api\MediaController::class, 'uploadImage']); // Upload single image
    Route::post('/upload/video', [\App\Http\Controllers\Api\MediaController::class, 'uploadVideo']); // Upload video
    Route::post('/upload/file', [\App\Http\Controllers\Api\MediaController::class, 'uploadFile']); // Upload any file
    Route::post('/upload/url', [\App\Http\Controllers\Api\MediaController::class, 'uploadFromUrl']); // Upload from URL
    Route::post('/upload/images', [\App\Http\Controllers\Api\MediaController::class, 'uploadMultipleImages']); // Upload multiple images
    Route::delete('/delete', [\App\Http\Controllers\Api\MediaController::class, 'deleteFile']); // Delete file
});

// ===================================
// Scheduled Posts Routes
// ===================================
Route::prefix('scheduled-posts')->middleware(['auth:sanctum', 'throttle:60,1'])->group(function () {
    Route::get('/', [\App\Http\Controllers\Api\ScheduledPostController::class, 'index']); // Get all scheduled posts
    Route::post('/', [\App\Http\Controllers\Api\ScheduledPostController::class, 'store']); // Create scheduled post
    Route::get('/{id}', [\App\Http\Controllers\Api\ScheduledPostController::class, 'show']); // Get single post
    Route::put('/{id}', [\App\Http\Controllers\Api\ScheduledPostController::class, 'update']); // Update post
    Route::delete('/{id}', [\App\Http\Controllers\Api\ScheduledPostController::class, 'destroy']); // Delete post
    Route::post('/{id}/send-now', [\App\Http\Controllers\Api\ScheduledPostController::class, 'sendNow']); // Send immediately
    Route::post('/{id}/retry', [\App\Http\Controllers\Api\ScheduledPostController::class, 'retry']); // Retry failed post
});

// Social Posts Routes (Alias for mobile app compatibility)
Route::prefix('social/posts')->middleware(['auth:sanctum', 'throttle:60,1'])->group(function () {
    Route::get('/', [\App\Http\Controllers\Api\ScheduledPostController::class, 'index']); // Get all posts
    Route::post('/', [\App\Http\Controllers\Api\ScheduledPostController::class, 'store']); // Create post
    Route::get('/{id}', [\App\Http\Controllers\Api\ScheduledPostController::class, 'show']); // Get single post
    Route::put('/{id}', [\App\Http\Controllers\Api\ScheduledPostController::class, 'update']); // Update post
    Route::delete('/{id}', [\App\Http\Controllers\Api\ScheduledPostController::class, 'destroy']); // Delete post
});

// AI Scheduling Routes (Mobile app compatibility)
Route::prefix('ai-scheduling')->middleware(['auth:sanctum', 'throttle:60,1'])->group(function () {
    // Get user's scheduled posts
    Route::get('/my-scheduled-posts', function (Request $request) {
        $posts = \App\Models\ScheduledPost::where('user_id', $request->user()->id)
            ->when($request->has('status'), fn($q) => $q->where('status', $request->status))
            ->orderBy('scheduled_at', 'desc')
            ->paginate($request->get('per_page', 20));
        return response()->json(['success' => true, 'data' => $posts]);
    });

    // Get scheduling stats
    Route::get('/stats', function (Request $request) {
        $userId = $request->user()->id;
        return response()->json([
            'success' => true,
            'data' => [
                'total_scheduled' => \App\Models\ScheduledPost::where('user_id', $userId)->count(),
                'pending' => \App\Models\ScheduledPost::where('user_id', $userId)->where('status', 'pending')->count(),
                'published' => \App\Models\ScheduledPost::where('user_id', $userId)->where('status', 'published')->count(),
                'failed' => \App\Models\ScheduledPost::where('user_id', $userId)->where('status', 'failed')->count(),
            ]
        ]);
    });

    // Schedule a post
    Route::post('/schedule-post', [\App\Http\Controllers\Api\ScheduledPostController::class, 'store']);

    // Delete scheduled post
    Route::delete('/{id}', [\App\Http\Controllers\Api\ScheduledPostController::class, 'destroy']);

    // Reschedule post
    Route::put('/{id}/reschedule', function (Request $request, int $id) {
        $post = \App\Models\ScheduledPost::where('user_id', $request->user()->id)->findOrFail($id);
        $post->update(['scheduled_at' => $request->new_time]);
        return response()->json(['success' => true, 'message' => 'Post rescheduled', 'data' => $post]);
    });
});

// System endpoint for dispatching scheduled posts (cron)
Route::post('/system/dispatch-scheduled', [\App\Http\Controllers\Api\ScheduledPostController::class, 'dispatchScheduled'])
    ->middleware('throttle:10,1');

// ===================================
// Notifications Routes
// ===================================
Route::prefix('notifications')->middleware(['auth:sanctum', 'throttle:60,1'])->group(function () {
    Route::get('/', [\App\Http\Controllers\Api\NotificationController::class, 'index']); // Get all notifications
    Route::get('/unread-count', [\App\Http\Controllers\Api\NotificationController::class, 'unreadCount']); // Get unread count
    Route::get('/{id}', [\App\Http\Controllers\Api\NotificationController::class, 'show']); // Get single notification
    Route::post('/{id}/read', [\App\Http\Controllers\Api\NotificationController::class, 'markAsRead']); // Mark as read
    Route::post('/read-all', [\App\Http\Controllers\Api\NotificationController::class, 'markAllAsRead']); // Mark all as read
    Route::delete('/{id}', [\App\Http\Controllers\Api\NotificationController::class, 'destroy']); // Delete notification
    Route::delete('/read/clear', [\App\Http\Controllers\Api\NotificationController::class, 'deleteRead']); // Delete all read
});

// ===================================
// Payment Routes (Paymob/Stripe)
// ===================================
Route::prefix('payments')->group(function () {
    // Public webhook endpoints
    Route::post('/paymob/webhook', [\App\Http\Controllers\PaymentController::class, 'handleWebhook'])->name('paymob.webhook');
    Route::get('/paymob/callback', [\App\Http\Controllers\PaymentController::class, 'handleCallback'])->name('paymob.callback');

    // Protected payment endpoints
    Route::middleware(['auth:sanctum', 'throttle:30,1'])->group(function () {
        Route::post('/initiate', [\App\Http\Controllers\PaymentController::class, 'initiatePayment']); // Create payment
        Route::get('/status/{paymentId}', [\App\Http\Controllers\PaymentController::class, 'getPaymentStatus']); // Get payment status
        Route::get('/history', [\App\Http\Controllers\PaymentController::class, 'getUserPayments']); // Get user's payment history
    });
});

// ===================================
// Content Templates Routes
// ===================================
Route::prefix('templates')->middleware(['auth:sanctum', 'throttle:60,1'])->group(function () {
    Route::get('/', [\App\Http\Controllers\Api\ContentTemplatesController::class, 'index']);
    Route::get('/categories', [\App\Http\Controllers\Api\ContentTemplatesController::class, 'getCategories']);
    Route::get('/popular', [\App\Http\Controllers\Api\ContentTemplatesController::class, 'getPopular']);
    Route::post('/', [\App\Http\Controllers\Api\ContentTemplatesController::class, 'store']);
    Route::get('/{id}', [\App\Http\Controllers\Api\ContentTemplatesController::class, 'show']);
    Route::put('/{id}', [\App\Http\Controllers\Api\ContentTemplatesController::class, 'update']);
    Route::delete('/{id}', [\App\Http\Controllers\Api\ContentTemplatesController::class, 'destroy']);
    Route::post('/{id}/duplicate', [\App\Http\Controllers\Api\ContentTemplatesController::class, 'duplicate']);
    Route::post('/{id}/use', [\App\Http\Controllers\Api\ContentTemplatesController::class, 'useTemplate']);

    // Admin only - bulk create system templates
    Route::post('/bulk-create', [\App\Http\Controllers\Api\ContentTemplatesController::class, 'bulkCreateSystemTemplates']);
});

// ===================================
// Workspace/Team Management Routes
// ===================================
Route::prefix('workspaces')->middleware(['auth:sanctum', 'throttle:60,1'])->group(function () {
    Route::get('/', [\App\Http\Controllers\Api\WorkspaceController::class, 'index']); // Get all workspaces
    Route::post('/', [\App\Http\Controllers\Api\WorkspaceController::class, 'store']); // Create workspace
    Route::get('/invitations', [\App\Http\Controllers\Api\WorkspaceController::class, 'getMyInvitations']); // Get pending invitations
    Route::post('/accept-invitation', [\App\Http\Controllers\Api\WorkspaceController::class, 'acceptInvitation']); // Accept invitation

    Route::get('/{id}', [\App\Http\Controllers\Api\WorkspaceController::class, 'show']); // Get workspace details
    Route::put('/{id}', [\App\Http\Controllers\Api\WorkspaceController::class, 'update']); // Update workspace
    Route::delete('/{id}', [\App\Http\Controllers\Api\WorkspaceController::class, 'destroy']); // Delete workspace
    Route::post('/{id}/leave', [\App\Http\Controllers\Api\WorkspaceController::class, 'leave']); // Leave workspace

    // Member management
    Route::post('/{id}/invite', [\App\Http\Controllers\Api\WorkspaceController::class, 'inviteMember']); // Invite member
    Route::delete('/{id}/invitations/{invitationId}', [\App\Http\Controllers\Api\WorkspaceController::class, 'cancelInvitation']); // Cancel invitation
    Route::delete('/{id}/members/{memberId}', [\App\Http\Controllers\Api\WorkspaceController::class, 'removeMember']); // Remove member
    Route::put('/{id}/members/{memberId}/role', [\App\Http\Controllers\Api\WorkspaceController::class, 'updateMemberRole']); // Update role
    Route::post('/{id}/transfer-ownership', [\App\Http\Controllers\Api\WorkspaceController::class, 'transferOwnership']); // Transfer ownership

    // Activity log
    Route::get('/{id}/activities', [\App\Http\Controllers\Api\WorkspaceController::class, 'getActivities']); // Get activities
});

// ===================================
// User Profile & Settings Routes
// ===================================
Route::prefix('user')->middleware(['auth:sanctum', 'throttle:60,1'])->group(function () {
    // Basic profile
    Route::get('/me', [\App\Http\Controllers\Api\UserController::class, 'me']);
    Route::get('/profile', [\App\Http\Controllers\Api\UserController::class, 'getFullProfile']);
    Route::put('/profile', [\App\Http\Controllers\Api\UserController::class, 'updateProfile']);
    Route::put('/password', [\App\Http\Controllers\Api\UserController::class, 'updatePassword']);

    // Business profile
    Route::put('/business-profile', [\App\Http\Controllers\Api\UserController::class, 'updateBusinessProfile']);

    // Preferences
    Route::get('/preferences', [\App\Http\Controllers\Api\UserController::class, 'getPreferences']);
    Route::put('/preferences', [\App\Http\Controllers\Api\UserController::class, 'updatePreferences']);

    // Connected accounts
    Route::get('/connected-accounts', [\App\Http\Controllers\Api\UserController::class, 'getConnectedAccounts']);

    // Usage statistics
    Route::get('/usage-stats', [\App\Http\Controllers\Api\UserController::class, 'getUsageStats']);

    // Delete account
    Route::post('/delete-account', [\App\Http\Controllers\Api\UserController::class, 'deleteAccount']);

    // Two-Factor Authentication
    Route::prefix('2fa')->group(function () {
        Route::get('/status', [\App\Http\Controllers\Api\TwoFactorAuthController::class, 'status']); // Get 2FA status
        Route::post('/setup', [\App\Http\Controllers\Api\TwoFactorAuthController::class, 'setup']); // Initialize setup
        Route::post('/enable', [\App\Http\Controllers\Api\TwoFactorAuthController::class, 'enable']); // Enable 2FA
        Route::post('/disable', [\App\Http\Controllers\Api\TwoFactorAuthController::class, 'disable']); // Disable 2FA
        Route::post('/verify', [\App\Http\Controllers\Api\TwoFactorAuthController::class, 'verify']); // Verify code
        Route::post('/recovery-codes', [\App\Http\Controllers\Api\TwoFactorAuthController::class, 'getRecoveryCodes']); // Get recovery codes
        Route::post('/regenerate-codes', [\App\Http\Controllers\Api\TwoFactorAuthController::class, 'regenerateRecoveryCodes']); // Regenerate codes
    });
});

// ===================================
// Claude AI Content Generation Routes
// ===================================
Route::prefix('claude')->middleware(['auth:sanctum', 'throttle:60,1'])->group(function () {
    // Status
    Route::get('/status', [\App\Http\Controllers\Api\ClaudeAIController::class, 'status']);

    // Content Generation
    Route::post('/generate', [\App\Http\Controllers\Api\ClaudeAIController::class, 'generateContent']); // Generate social media content
    Route::post('/hashtags', [\App\Http\Controllers\Api\ClaudeAIController::class, 'generateHashtags']); // Generate hashtags
    Route::post('/ideas', [\App\Http\Controllers\Api\ClaudeAIController::class, 'generateIdeas']); // Generate content ideas
    Route::post('/improve', [\App\Http\Controllers\Api\ClaudeAIController::class, 'improveContent']); // Improve existing content
    Route::post('/video-script', [\App\Http\Controllers\Api\ClaudeAIController::class, 'generateVideoScript']); // Generate video script
    Route::post('/analyze', [\App\Http\Controllers\Api\ClaudeAIController::class, 'analyzeContent']); // Analyze content
    Route::post('/calendar', [\App\Http\Controllers\Api\ClaudeAIController::class, 'generateCalendar']); // Generate content calendar
    Route::post('/comprehensive', [\App\Http\Controllers\Api\ClaudeAIController::class, 'generateComprehensive']); // Generate for all platforms
});

// ===================================
// Canva Design Integration Routes
// ===================================
Route::prefix('canva')->group(function () {
    // Public endpoints
    Route::get('/status', [\App\Http\Controllers\Api\CanvaController::class, 'status']); // Service status
    Route::get('/dimensions', [\App\Http\Controllers\Api\CanvaController::class, 'getDimensions']); // Available dimensions
    Route::get('/categories', [\App\Http\Controllers\Api\CanvaController::class, 'getCategories']); // Template categories

    // OAuth endpoints
    Route::middleware(['auth:sanctum'])->group(function () {
        Route::get('/authorize', [\App\Http\Controllers\Api\CanvaController::class, 'authorize']); // Get OAuth URL with PKCE
        Route::post('/store-state-user', [\App\Http\Controllers\Api\CanvaController::class, 'storeStateUser']); // Store state for mobile/SPA
        Route::get('/connection-status', [\App\Http\Controllers\Api\CanvaController::class, 'connectionStatus']); // Check connection status
        Route::post('/disconnect', [\App\Http\Controllers\Api\CanvaController::class, 'disconnect']); // Disconnect Canva account
    });
    Route::get('/callback', [\App\Http\Controllers\Api\CanvaController::class, 'callback']); // OAuth callback with PKCE

    // Protected endpoints
    Route::middleware(['auth:sanctum', 'throttle:60,1'])->group(function () {
        // Profile
        Route::get('/profile', [\App\Http\Controllers\Api\CanvaController::class, 'profile']); // Get user profile

        // Designs
        Route::get('/designs', [\App\Http\Controllers\Api\CanvaController::class, 'listDesigns']); // List designs
        Route::get('/designs/{id}', [\App\Http\Controllers\Api\CanvaController::class, 'getDesign']); // Get design
        Route::post('/designs', [\App\Http\Controllers\Api\CanvaController::class, 'createDesign']); // Create design
        Route::post('/designs/quick-create', [\App\Http\Controllers\Api\CanvaController::class, 'quickCreate']); // Quick create social design
        Route::post('/designs/from-template', [\App\Http\Controllers\Api\CanvaController::class, 'createFromTemplate']); // Create from template
        Route::post('/designs/{id}/autofill', [\App\Http\Controllers\Api\CanvaController::class, 'autofillDesign']); // Autofill design

        // Templates
        Route::get('/templates', [\App\Http\Controllers\Api\CanvaController::class, 'searchTemplates']); // Search templates
        Route::get('/brand-templates', [\App\Http\Controllers\Api\CanvaController::class, 'getBrandTemplates']); // Brand templates

        // Export
        Route::post('/designs/{id}/export', [\App\Http\Controllers\Api\CanvaController::class, 'exportDesign']); // Export design
        Route::get('/exports/{id}', [\App\Http\Controllers\Api\CanvaController::class, 'getExportStatus']); // Export status
        Route::post('/designs/{id}/export-download', [\App\Http\Controllers\Api\CanvaController::class, 'exportAndDownload']); // Export and get URL

        // Assets
        Route::post('/assets', [\App\Http\Controllers\Api\CanvaController::class, 'uploadAsset']); // Upload asset
        Route::post('/assets/from-url', [\App\Http\Controllers\Api\CanvaController::class, 'uploadAssetFromUrl']); // Upload from URL

        // Folders
        Route::get('/folders', [\App\Http\Controllers\Api\CanvaController::class, 'listFolders']); // List folders
        Route::post('/folders', [\App\Http\Controllers\Api\CanvaController::class, 'createFolder']); // Create folder
    });
});
