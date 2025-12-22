<?php
// Script to add LinkedIn routes to api.php

$apiFile = '/home/u126213189/domains/mediaprosocial.io/public_html/routes/api.php';
$content = file_get_contents($apiFile);

// Add use statement if not exists
if (strpos($content, 'LinkedInController') === false) {
    $content = str_replace(
        'use App\Http\Controllers\Api\PostizController;',
        "use App\Http\Controllers\Api\PostizController;\nuse App\Http\Controllers\Api\LinkedInController;",
        $content
    );
}

// Add LinkedIn routes before the last closing - find the Cloudinary routes and add before them
$linkedInRoutes = <<<'ROUTES'

// LinkedIn API Routes (Social Media Management via LinkedIn)
Route::prefix('linkedin')->middleware('throttle:60,1')->group(function () {
    // Public OAuth endpoints
    Route::get('/auth-url', [LinkedInController::class, 'getAuthUrl']); // Get OAuth URL
    Route::get('/callback', [LinkedInController::class, 'callback']); // OAuth callback

    // Protected endpoints (require authentication)
    Route::middleware('auth:sanctum')->group(function () {
        // Account Management
        Route::get('/accounts', [LinkedInController::class, 'getAccounts']); // Get connected accounts
        Route::post('/connect', [LinkedInController::class, 'connect']); // Connect account
        Route::delete('/accounts/{id}', [LinkedInController::class, 'disconnect']); // Disconnect account
        Route::post('/accounts/{id}/refresh', [LinkedInController::class, 'refreshToken']); // Refresh token
        Route::get('/accounts/{id}/profile', [LinkedInController::class, 'getProfile']); // Get profile

        // Post Management
        Route::post('/posts', [LinkedInController::class, 'createPost']); // Create post
        Route::delete('/posts', [LinkedInController::class, 'deletePost']); // Delete post
        Route::get('/accounts/{id}/posts', [LinkedInController::class, 'getPosts']); // Get user posts
        Route::post('/posts/stats', [LinkedInController::class, 'getPostStats']); // Get post stats

        // Analytics
        Route::get('/accounts/{id}/analytics', [LinkedInController::class, 'getAnalytics']); // Get analytics

        // Engagement
        Route::post('/posts/comments', [LinkedInController::class, 'getComments']); // Get comments
        Route::post('/posts/like', [LinkedInController::class, 'likePost']); // Like post
        Route::post('/posts/comment', [LinkedInController::class, 'commentPost']); // Comment on post
    });
});

ROUTES;

// Check if LinkedIn routes already exist
if (strpos($content, "Route::prefix('linkedin')") === false) {
    // Find the position to insert (before Cloudinary routes)
    $cloudinaryPos = strpos($content, "// Cloudinary Image Editing Routes");
    if ($cloudinaryPos !== false) {
        $content = substr($content, 0, $cloudinaryPos) . $linkedInRoutes . substr($content, $cloudinaryPos);
    } else {
        // If Cloudinary not found, append before the last closing
        $content = rtrim($content) . "\n" . $linkedInRoutes;
    }
}

file_put_contents($apiFile, $content);
echo "LinkedIn routes added successfully!\n";
