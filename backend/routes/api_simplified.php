<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\SubscriptionController;
use App\Http\Controllers\Api\SubscriptionPlanController;
use App\Http\Controllers\Api\WalletController;
use App\Http\Controllers\Api\SocialMediaPostController;
use App\Http\Controllers\Api\SocialAccountController;
use App\Http\Controllers\Api\AutoScheduledPostController;
use App\Http\Controllers\Api\AnalyticsController;
use App\Http\Controllers\Api\TelegramController;
use App\Http\Controllers\Api\SettingsController;
use App\Http\Controllers\Api\N8nWorkflowController;

/*
|--------------------------------------------------------------------------
| Simplified API Routes - SaaS Business Focused
|--------------------------------------------------------------------------
|
| Core features only:
| - Authentication
| - Social Accounts Management
| - Content Creation & Posting
| - Scheduling
| - Analytics
| - Subscriptions & Wallet
| - Telegram Bot Admin
|
*/

// ============================================
// PUBLIC ROUTES
// ============================================

// Health Check
Route::get('/health', function () {
    return response()->json(['status' => 'ok', 'timestamp' => now()]);
});

// Authentication (Rate Limited)
Route::middleware('throttle:5,1')->group(function () {
    Route::post('/auth/register', [AuthController::class, 'register']);
    Route::post('/auth/login', [AuthController::class, 'login']);
    Route::post('/auth/send-otp', [AuthController::class, 'sendOTP']);
    Route::post('/auth/verify-otp', [AuthController::class, 'verifyOTP']);
});

// Settings API (Public - read-only)
Route::prefix('settings')->middleware('throttle:60,1')->group(function () {
    Route::get('/', [SettingsController::class, 'getPublicSettings']);
    Route::get('/app-config', [SettingsController::class, 'getAppConfig']);
    Route::get('/{key}', [SettingsController::class, 'getSetting']);
});

// Subscription Plans (Public)
Route::prefix('subscription-plans')->middleware('throttle:60,1')->group(function () {
    Route::get('/', [SubscriptionPlanController::class, 'index']);
    Route::get('/popular', [SubscriptionPlanController::class, 'popularPlans']);
    Route::get('/{slug}', [SubscriptionPlanController::class, 'show']);
});

// Telegram Bot Webhook (Public - for Telegram callbacks)
Route::post('/telegram/webhook', [TelegramController::class, 'webhook'])
    ->middleware('throttle:100,1');

// ============================================
// AUTHENTICATED ROUTES
// ============================================

Route::middleware(['auth:sanctum', 'throttle:120,1'])->group(function () {

    // --------------------------------------
    // Authentication & User Management
    // --------------------------------------
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/user', [AuthController::class, 'user']);
    Route::put('/users/profile', [UserController::class, 'updateProfile']);
    Route::put('/users/password', [UserController::class, 'updatePassword']);

    // --------------------------------------
    // Social Accounts Management
    // --------------------------------------
    Route::prefix('social-accounts')->group(function () {
        Route::get('/', [SocialAccountController::class, 'index']);
        Route::post('/', [SocialAccountController::class, 'store']);
        Route::get('/{id}', [SocialAccountController::class, 'show']);
        Route::put('/{id}', [SocialAccountController::class, 'update']);
        Route::delete('/{id}', [SocialAccountController::class, 'destroy']);
        Route::post('/{id}/toggle', [SocialAccountController::class, 'toggleStatus']);
    });

    // OAuth for Social Media
    Route::prefix('auth')->group(function () {
        Route::get('/{platform}/redirect', [\App\Http\Controllers\Api\SocialAuthController::class, 'redirect'])
            ->where('platform', 'instagram|facebook|twitter|linkedin|tiktok|youtube');
        Route::get('/connected-accounts', [\App\Http\Controllers\Api\SocialAuthController::class, 'getUserAccounts']);
    });

    // --------------------------------------
    // Content Creation & Posting
    // --------------------------------------
    Route::prefix('social-media')->group(function () {
        Route::post('/upload-photo', [SocialMediaPostController::class, 'uploadPhoto']);
        Route::post('/upload-video', [SocialMediaPostController::class, 'uploadVideo']);
        Route::post('/upload-text', [SocialMediaPostController::class, 'uploadText']);
        Route::get('/platforms', [SocialMediaPostController::class, 'getSupportedPlatforms']);
        Route::get('/status', [SocialMediaPostController::class, 'status']);
    });

    // N8N Workflows for posting
    Route::prefix('n8n-workflows')->group(function () {
        Route::post('/post', [N8nWorkflowController::class, 'postToPlatform']);
        Route::get('/executions', [N8nWorkflowController::class, 'executionHistory']);
    });

    // --------------------------------------
    // Auto Scheduling
    // --------------------------------------
    Route::prefix('auto-scheduled-posts')->group(function () {
        Route::get('/user/{userId}', [AutoScheduledPostController::class, 'index']);
        Route::post('/', [AutoScheduledPostController::class, 'store']);
        Route::get('/{id}', [AutoScheduledPostController::class, 'show']);
        Route::put('/{id}', [AutoScheduledPostController::class, 'update']);
        Route::delete('/{id}', [AutoScheduledPostController::class, 'destroy']);
        Route::post('/{id}/activate', [AutoScheduledPostController::class, 'activate']);
        Route::post('/{id}/pause', [AutoScheduledPostController::class, 'pause']);
    });

    // --------------------------------------
    // Analytics
    // --------------------------------------
    Route::prefix('analytics')->group(function () {
        Route::get('/usage', [AnalyticsController::class, 'getUsage']);
        Route::get('/overview', [AnalyticsController::class, 'getOverview']);
        Route::get('/posts', [AnalyticsController::class, 'getPostsAnalytics']);
        Route::get('/platforms', [AnalyticsController::class, 'getPlatformsAnalytics']);
        Route::get('/check-limit/{type}', [AnalyticsController::class, 'checkLimit']);
    });

    // --------------------------------------
    // Subscriptions
    // --------------------------------------
    Route::prefix('subscriptions')->group(function () {
        Route::get('/{userId}', [SubscriptionController::class, 'show']);
        Route::post('/', [SubscriptionController::class, 'store']);
        Route::post('/upgrade', [SubscriptionController::class, 'upgrade']);
        Route::post('/cancel', [SubscriptionController::class, 'cancel']);
    });

    // --------------------------------------
    // Paymob Payment
    // --------------------------------------
    Route::prefix('paymob')->group(function () {
        Route::post('/initiate', [\App\Http\Controllers\PaymentController::class, 'initiatePayment']);
        Route::get('/status/{paymentId}', [\App\Http\Controllers\PaymentController::class, 'getPaymentStatus']);
        Route::get('/history', [\App\Http\Controllers\PaymentController::class, 'getUserPayments']);
    });

    // --------------------------------------
    // Wallet (Simplified)
    // --------------------------------------
    Route::prefix('wallets')->group(function () {
        Route::get('/{userId}', [WalletController::class, 'show']);
        Route::get('/{userId}/transactions', [WalletController::class, 'transactions']);
        Route::post('/request-recharge', [WalletController::class, 'requestRecharge']);
    });

    // --------------------------------------
    // Telegram Bot Management
    // --------------------------------------
    Route::prefix('telegram')->group(function () {
        Route::get('/bot-config', [TelegramController::class, 'getBotConfig']);
        Route::post('/set-webhook', [TelegramController::class, 'setWebhook']);
        Route::get('/webhook-info', [TelegramController::class, 'getWebhookInfo']);
        Route::delete('/webhook', [TelegramController::class, 'deleteWebhook']);
        Route::get('/test', [TelegramController::class, 'test']);
    });
});

// ============================================
// ADMIN ROUTES (Telegram Bot Only)
// ============================================

/*
 * Note: Admin features are now managed via Telegram Bot
 * These endpoints are kept for bot internal use only
 * No UI is provided in Flutter app
 */

Route::middleware(['auth:sanctum', 'throttle:60,1'])->prefix('admin')->group(function () {
    // Wallet Admin (for Telegram Bot)
    Route::post('/wallets/{userId}/credit', [WalletController::class, 'credit']);
    Route::get('/wallets/requests', [WalletController::class, 'getRechargeRequests']);
    Route::post('/wallets/requests/{id}/approve', [WalletController::class, 'approveRecharge']);
    Route::post('/wallets/requests/{id}/reject', [WalletController::class, 'rejectRecharge']);

    // Dashboard Stats (for Telegram Bot)
    Route::get('/stats/dashboard', function () {
        return response()->json([
            'total_users' => \App\Models\User::count(),
            'active_users' => \App\Models\User::where('status', 'active')->count(),
            'total_subscriptions' => \App\Models\Subscription::where('status', 'active')->count(),
            'total_revenue' => \App\Models\Subscription::where('status', 'active')->sum('amount'),
            'total_accounts' => \App\Models\SocialAccount::count(),
            'scheduled_posts' => \App\Models\AutoScheduledPost::where('status', 'active')->count(),
        ]);
    });
});

// ============================================
// REMOVED ROUTES (No longer needed)
// ============================================

/*
 * The following routes have been removed:
 *
 * ✗ /gamification/* - Gamification removed
 * ✗ /community/* - Community features removed
 * ✗ /website-requests/* - Managed via Telegram Bot
 * ✗ /sponsored-ad-requests/* - Managed via Telegram Bot
 * ✗ /support-tickets/* - Managed via Telegram Bot
 * ✗ /bank-transfer-requests/* - Simplified to wallet recharge
 * ✗ /otp/* - Integrated into auth
 * ✗ /sms/* - Admin only via backend
 * ✗ /payment-settings/* - Admin only via backend
 * ✗ /video-generation/* - Not core feature
 * ✗ /tiktok/* - Not core feature
 * ✗ /instagram/scraper/* - Not core feature
 *
 * Result: API routes reduced from 100+ to 40 essential routes
 */
