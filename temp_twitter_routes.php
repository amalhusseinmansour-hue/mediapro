<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\TwitterController;

// Twitter API Routes
Route::prefix('twitter')->group(function () {
    // Public routes (no auth required)
    Route::get('/auth-url', [TwitterController::class, 'getAuthUrl']);
    Route::get('/callback', [TwitterController::class, 'callback'])->name('twitter.callback');
    Route::get('/status', [TwitterController::class, 'status']);
    Route::post('/lookup', [TwitterController::class, 'lookupUser']);

    // Protected routes (auth required)
    Route::middleware(['auth:sanctum'])->group(function () {
        Route::get('/accounts', [TwitterController::class, 'getAccounts']);
        Route::post('/post', [TwitterController::class, 'post']);
        Route::get('/{accountId}/analytics', [TwitterController::class, 'getAnalytics']);
        Route::get('/{accountId}/tweets', [TwitterController::class, 'getTweets']);
        Route::delete('/{accountId}/tweets/{tweetId}', [TwitterController::class, 'deleteTweet']);
        Route::delete('/{accountId}/disconnect', [TwitterController::class, 'disconnect']);
    });
});
