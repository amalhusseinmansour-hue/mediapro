<?php

/**
 * أضف هذه الـ routes في routes/api.php
 */

use App\Http\Controllers\Api\SocialAuthController;
use App\Http\Controllers\Api\PublishController;

// ========== OAuth Routes ==========
Route::prefix('auth')->group(function () {
    // Generate OAuth URL
    Route::middleware('auth:sanctum')->get('/{platform}/redirect', [SocialAuthController::class, 'redirect']);

    // OAuth Callback (no auth - من المنصات)
    Route::get('/{platform}/callback', [SocialAuthController::class, 'callback']);

    // Get connected accounts
    Route::middleware('auth:sanctum')->get('/connected-accounts', [SocialAuthController::class, 'getUserAccounts']);
});

// ========== Social Media Publishing Routes ==========
Route::middleware('auth:sanctum')->prefix('social')->group(function () {
    // Accounts Management
    Route::get('/accounts', [PublishController::class, 'getAccounts']);
    Route::delete('/accounts/{id}', [PublishController::class, 'disconnect']);

    // Publishing
    Route::post('/publish', [PublishController::class, 'publish']);

    // Postiz Features
    Route::post('/generate-video', [PublishController::class, 'generateVideo']);
    Route::post('/upload-media', [PublishController::class, 'uploadMedia']);
    Route::get('/analytics', [PublishController::class, 'getAnalytics']);
});
