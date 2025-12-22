<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\LinkedInController;

// LinkedIn API Routes
Route::prefix('linkedin')->group(function () {
    // Public routes (no auth required)
    Route::get('/auth-url', [LinkedInController::class, 'getAuthUrl']);
    Route::get('/callback', [LinkedInController::class, 'callback'])->name('linkedin.callback');
    Route::get('/status', function () {
        $service = app(\App\Services\LinkedInService::class);
        return response()->json([
            'configured' => $service->isConfigured(),
            'platform' => 'linkedin',
            'api_version' => 'v2',
        ]);
    });

    // Protected routes (auth required)
    Route::middleware(['auth:sanctum'])->group(function () {
        Route::post('/connect', [LinkedInController::class, 'connect']);
        Route::get('/accounts', [LinkedInController::class, 'getAccounts']);
        Route::get('/{accountId}/profile', [LinkedInController::class, 'getProfile']);
        Route::get('/{accountId}/analytics', [LinkedInController::class, 'getAnalytics']);
        Route::get('/{accountId}/posts', [LinkedInController::class, 'getPosts']);
        Route::post('/post', [LinkedInController::class, 'createPost']);
        Route::delete('/post/{postId}', [LinkedInController::class, 'deletePost']);
        Route::get('/post/{postId}/stats', [LinkedInController::class, 'getPostStats']);
        Route::get('/post/{postId}/comments', [LinkedInController::class, 'getComments']);
        Route::post('/post/{postId}/like', [LinkedInController::class, 'likePost']);
        Route::post('/post/{postId}/comment', [LinkedInController::class, 'commentPost']);
        Route::post('/{accountId}/refresh-token', [LinkedInController::class, 'refreshToken']);
        Route::delete('/{accountId}/disconnect', [LinkedInController::class, 'disconnect']);
    });
});
