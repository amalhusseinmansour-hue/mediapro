<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\SocialMediaPostController;

// Social Media Posts (Flutter App)
Route::prefix('social')->middleware(['auth:sanctum'])->group(function () {
    Route::post('/post', [SocialMediaPostController::class, 'post']);
    Route::get('/posts', [SocialMediaPostController::class, 'history']);
});
