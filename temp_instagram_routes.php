<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\InstagramController;

// Instagram API Routes
Route::prefix('instagram')->group(function () {
    // Public routes (no auth required)
    Route::get('/auth-url', [InstagramController::class, 'getAuthUrl']);
    Route::get('/callback', [InstagramController::class, 'callback'])->name('instagram.callback');
    Route::get('/status', [InstagramController::class, 'status']);

    // Protected routes (auth required)
    Route::middleware(['auth:sanctum'])->group(function () {
        Route::get('/accounts', [InstagramController::class, 'getAccounts']);
        Route::get('/{accountId}/analytics', [InstagramController::class, 'getAnalytics']);
        Route::get('/{accountId}/media', [InstagramController::class, 'getMedia']);
        Route::post('/post', [InstagramController::class, 'createPost']);
        Route::get('/{accountId}/media/{mediaId}/comments', [InstagramController::class, 'getComments']);
        Route::post('/{accountId}/comments/{commentId}/reply', [InstagramController::class, 'replyToComment']);
        Route::get('/{accountId}/media/{mediaId}/insights', [InstagramController::class, 'getMediaInsights']);
        Route::post('/{accountId}/hashtag/search', [InstagramController::class, 'searchHashtag']);
        Route::delete('/{accountId}/disconnect', [InstagramController::class, 'disconnect']);
    });
});
