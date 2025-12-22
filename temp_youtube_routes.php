<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\YouTubeController;

// YouTube API Routes
Route::prefix('youtube')->group(function () {
    // Public routes (no auth required)
    Route::get('/auth-url', [YouTubeController::class, 'getAuthUrl']);
    Route::get('/callback', [YouTubeController::class, 'callback'])->name('youtube.callback');
    Route::get('/status', [YouTubeController::class, 'status']);

    // Protected routes (auth required)
    Route::middleware(['auth:sanctum'])->group(function () {
        Route::get('/accounts', [YouTubeController::class, 'getAccounts']);
        Route::get('/{accountId}/videos', [YouTubeController::class, 'getVideos']);
        Route::get('/{accountId}/analytics', [YouTubeController::class, 'getAnalytics']);
        Route::get('/{accountId}/videos/{videoId}/analytics', [YouTubeController::class, 'getVideoAnalytics']);
        Route::post('/{accountId}/upload/init', [YouTubeController::class, 'initUpload']);
        Route::put('/{accountId}/videos/{videoId}', [YouTubeController::class, 'updateVideo']);
        Route::delete('/{accountId}/videos/{videoId}', [YouTubeController::class, 'deleteVideo']);
        Route::delete('/{accountId}/disconnect', [YouTubeController::class, 'disconnect']);
    });
});
