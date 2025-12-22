<?php

/**
 * Ayrshare API Routes
 *
 * أضف هذه ال routes في: routes/api.php
 */

use App\Http\Controllers\Api\AyrshareController;

// Ayrshare Routes - يتطلب authentication
Route::middleware('auth:sanctum')->group(function () {

    // ========== OAuth & Profile Management ==========

    // إنشاء رابط OAuth لربط حساب
    Route::post('/ayrshare/generate-oauth-link', [AyrshareController::class, 'generateOAuthLink']);

    // الحصول على قائمة الحسابات المربوطة
    Route::get('/ayrshare/profiles', [AyrshareController::class, 'getProfiles']);

    // فصل حساب مرتبط
    Route::delete('/ayrshare/profile/{profileKey}', [AyrshareController::class, 'unlinkProfile']);

    // ========== Publishing ==========

    // نشر محتوى
    Route::post('/ayrshare/post', [AyrshareController::class, 'publishPost']);

    // حذف منشور
    Route::delete('/ayrshare/post/{postId}', [AyrshareController::class, 'deletePost']);

    // تحديث منشور مجدول
    Route::put('/ayrshare/post/{postId}', [AyrshareController::class, 'updateScheduledPost']);

    // ========== Analytics ==========

    // الحصول على إحصائيات الحسابات
    Route::get('/ayrshare/analytics', [AyrshareController::class, 'getAnalytics']);

    // إحصائيات منشور معين
    Route::get('/ayrshare/analytics/post/{postId}', [AyrshareController::class, 'getPostAnalytics']);

    // تاريخ المنشورات
    Route::get('/ayrshare/history', [AyrshareController::class, 'getPostHistory']);

    // أفضل أوقات النشر
    Route::get('/ayrshare/best-times', [AyrshareController::class, 'getBestTimes']);

    // ========== Media Upload ==========

    // رفع صورة/فيديو
    Route::post('/ayrshare/upload', [AyrshareController::class, 'uploadMedia']);

    // ========== Status ==========

    // التحقق من حالة API
    Route::get('/ayrshare/status', [AyrshareController::class, 'checkStatus']);
});

// OAuth Callback - لا يتطلب authentication (يأتي من Ayrshare)
Route::get('/ayrshare/oauth-callback', [AyrshareController::class, 'oauthCallback']);
