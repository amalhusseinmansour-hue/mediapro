<?php

/*
|--------------------------------------------------------------------------
| NEW API Routes to Add
|--------------------------------------------------------------------------
| 
| أضف هذه الـ routes في نهاية ملف /public_html/mediaprosocial.io/routes/api.php
| هذه routes خاصة بالأنظمة الجديدة: Webhook و AI Video Generation
|
*/

use App\Http\Controllers\Api\ScheduledPostController;
use App\Http\Controllers\Api\AIVideoController;

// =============================================================================
// Webhook & Scheduled Posts Routes
// =============================================================================

Route::middleware('auth:sanctum')->prefix('scheduled-posts')->group(function () {
    // Get all scheduled posts for user
    Route::get('/', [ScheduledPostController::class, 'index']);
    
    // Create new scheduled post
    Route::post('/', [ScheduledPostController::class, 'store']);
    
    // Get specific scheduled post
    Route::get('/{id}', [ScheduledPostController::class, 'show']);
    
    // Update scheduled post
    Route::put('/{id}', [ScheduledPostController::class, 'update']);
    
    // Delete scheduled post
    Route::delete('/{id}', [ScheduledPostController::class, 'destroy']);
    
    // Manually trigger scheduled post
    Route::post('/{id}/trigger', [ScheduledPostController::class, 'trigger']);
    
    // Get logs for scheduled post
    Route::get('/{id}/logs', [ScheduledPostController::class, 'getLogs']);
});

// =============================================================================
// AI Video Generation Routes
// =============================================================================

Route::middleware('auth:sanctum')->prefix('ai-videos')->group(function () {
    // Get user's video generation history
    Route::get('/', [AIVideoController::class, 'index']);
    
    // Generate new AI video
    Route::post('/', [AIVideoController::class, 'store']);
    
    // Get available providers and their capabilities
    Route::get('/providers', [AIVideoController::class, 'providers']);
    
    // Get user's video generation statistics
    Route::get('/stats', [AIVideoController::class, 'stats']);
    
    // Get specific video details
    Route::get('/{id}', [AIVideoController::class, 'show']);
    
    // Delete a video
    Route::delete('/{id}', [AIVideoController::class, 'destroy']);
    
    // Download video file
    Route::get('/{id}/download', [AIVideoController::class, 'download']);
    
    // Retry failed video generation
    Route::post('/{id}/retry', [AIVideoController::class, 'retry']);
});

// =============================================================================
// Public Webhook Endpoints (No authentication required)
// =============================================================================

// Webhook endpoint for Pabbly Connect
Route::post('/webhook/pabbly', [ScheduledPostController::class, 'webhook']);

// Health check for webhook system
Route::get('/webhook/health', function () {
    return response()->json([
        'status' => 'OK',
        'timestamp' => now()->toISOString(),
        'version' => '1.0.0',
        'services' => [
            'webhook' => 'active',
            'queue' => 'active',
            'database' => 'active',
        ]
    ]);
});

/*
|--------------------------------------------------------------------------
| Routes Summary
|--------------------------------------------------------------------------
|
| Scheduled Posts Routes:
| - GET    /api/scheduled-posts              -> List all
| - POST   /api/scheduled-posts              -> Create new
| - GET    /api/scheduled-posts/{id}         -> Show specific
| - PUT    /api/scheduled-posts/{id}         -> Update
| - DELETE /api/scheduled-posts/{id}         -> Delete
| - POST   /api/scheduled-posts/{id}/trigger -> Manual trigger
| - GET    /api/scheduled-posts/{id}/logs    -> Get logs
|
| AI Video Routes:
| - GET    /api/ai-videos                    -> List all videos
| - POST   /api/ai-videos                    -> Generate new video
| - GET    /api/ai-videos/providers          -> Available providers
| - GET    /api/ai-videos/stats              -> User statistics
| - GET    /api/ai-videos/{id}               -> Video details
| - DELETE /api/ai-videos/{id}               -> Delete video
| - GET    /api/ai-videos/{id}/download      -> Download video
| - POST   /api/ai-videos/{id}/retry         -> Retry generation
|
| Public Routes:
| - POST   /api/webhook/pabbly               -> Pabbly webhook
| - GET    /api/webhook/health               -> System health
|
*/