<?php

/**
 * Postiz API Routes
 *
 * أضف هذه ال routes في: routes/api.php
 */

use App\Http\Controllers\Api\PostizController;

// Postiz Routes - يتطلب authentication
Route::middleware('auth:sanctum')->group(function () {

    // ========== OAuth & Integration Management ==========

    // إنشاء رابط OAuth لربط حساب
    Route::post('/postiz/oauth-link', [PostizController::class, 'generateOAuthLink']);

    // الحصول على قائمة القنوات/الحسابات المربوطة
    Route::get('/postiz/integrations', [PostizController::class, 'getIntegrations']);

    // فصل حساب مرتبط
    Route::delete('/postiz/integrations/{integrationId}', [PostizController::class, 'unlinkIntegration']);

    // الحصول على أفضل وقت للنشر
    Route::get('/postiz/find-slot/{integrationId}', [PostizController::class, 'getNextAvailableSlot']);

    // ========== Publishing ==========

    // نشر محتوى
    Route::post('/postiz/posts', [PostizController::class, 'publishPost']);

    // حذف منشور
    Route::delete('/postiz/posts/{postId}', [PostizController::class, 'deletePost']);

    // الحصول على قائمة المنشورات
    Route::get('/postiz/posts', [PostizController::class, 'getPosts']);

    // ========== Media Upload ==========

    // رفع صورة/فيديو
    Route::post('/postiz/upload', [PostizController::class, 'uploadMedia']);

    // رفع صورة/فيديو من URL خارجي
    Route::post('/postiz/upload-from-url', [PostizController::class, 'uploadMediaFromUrl']);

    // ========== AI Video Generation ==========

    // توليد فيديو بالذكاء الاصطناعي
    Route::post('/postiz/generate-video', [PostizController::class, 'generateVideo']);

    // ========== Status ==========

    // التحقق من حالة API
    Route::get('/postiz/status', [PostizController::class, 'checkStatus']);
});

// OAuth Callback - لا يتطلب authentication (يأتي من المنصات)
Route::get('/postiz/oauth-callback', [PostizController::class, 'oauthCallback']);
