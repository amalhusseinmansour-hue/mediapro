<?php

/**
 * Social Auth Routes
 * أضف هذه الـ routes في routes/api.php
 */

use App\Http\Controllers\Api\SocialAuthController;

// OAuth Routes
Route::middleware('auth:sanctum')->group(function () {
    // Generate OAuth URL
    Route::get('/auth/{platform}/redirect', [SocialAuthController::class, 'redirect']);

    // Get connected accounts
    Route::get('/auth/connected-accounts', [SocialAuthController::class, 'getUserAccounts']);

    // Disconnect account
    Route::delete('/auth/disconnect/{accountId}', [SocialAuthController::class, 'disconnect']);

    // Publish to social media
    Route::post('/social/publish', [SocialAuthController::class, 'publish']);
});

// OAuth Callbacks (no auth required - من المنصات)
Route::get('/auth/{platform}/callback', [SocialAuthController::class, 'callback']);
