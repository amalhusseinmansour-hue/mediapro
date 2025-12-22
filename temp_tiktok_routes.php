<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\TikTokController;

// TikTok API Routes
Route::prefix('tiktok')->group(function () {
    // Public routes (no auth required)
    Route::get('/auth-url', [TikTokController::class, 'getAuthUrl']);
    Route::get('/callback', [TikTokController::class, 'callback'])->name('tiktok.callback');
    Route::get('/status', [TikTokController::class, 'status']);

    // Protected routes (auth required)
    Route::middleware(['auth:sanctum'])->group(function () {
        Route::get('/accounts', [TikTokController::class, 'getAccounts']);
        Route::post('/post', [TikTokController::class, 'post']);
        Route::get('/{accountId}/videos', [TikTokController::class, 'getVideos']);
        Route::get('/{accountId}/analytics', [TikTokController::class, 'getAnalytics']);
        Route::post('/{accountId}/publish-status', [TikTokController::class, 'checkPublishStatus']);
        Route::delete('/{accountId}/disconnect', [TikTokController::class, 'disconnect']);
    });
});
