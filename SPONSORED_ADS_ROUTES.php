<?php

/**
 * Sponsored Ads Request Routes
 * مسارات API لطلبات الإعلانات الممولة
 * ضع هذه المسارات في ملف routes/api.php
 */

use App\Http\Controllers\SponsoredAdsRequestController;
use Illuminate\Support\Facades\Route;

// ==================== User Routes (Protected) ====================
Route::middleware(['auth:sanctum'])->group(function () {

    // إرسال طلب إعلان جديد
    Route::post('/sponsored-ads-requests', [SponsoredAdsRequestController::class, 'store']);

    // الحصول على جميع طلبات المستخدم
    Route::get('/sponsored-ads-requests', [SponsoredAdsRequestController::class, 'index']);

    // الحصول على تفاصيل طلب معين
    Route::get('/sponsored-ads-requests/{id}', [SponsoredAdsRequestController::class, 'show']);

    // حذف طلب
    Route::delete('/sponsored-ads-requests/{id}', [SponsoredAdsRequestController::class, 'destroy']);

    // الحصول على إحصائيات الطلبات
    Route::get('/sponsored-ads-requests/statistics', [SponsoredAdsRequestController::class, 'statistics']);
});

// ==================== Admin Routes (Protected + Admin) ====================
Route::middleware(['auth:sanctum' /*, 'admin'*/])->prefix('admin')->group(function () {

    // جلب جميع الطلبات (للإدارة)
    Route::get('/sponsored-ads-requests', [SponsoredAdsRequestController::class, 'adminIndex']);

    // تحديث حالة الطلب وإضافة إحصائيات (للإدارة)
    Route::put('/sponsored-ads-requests/{id}', [SponsoredAdsRequestController::class, 'adminUpdate']);
});

/**
 * URLs الناتجة:
 *
 * User Routes:
 * - POST   /api/sponsored-ads-requests              (إرسال طلب)
 * - GET    /api/sponsored-ads-requests              (جلب طلبات المستخدم)
 * - GET    /api/sponsored-ads-requests/{id}         (تفاصيل طلب)
 * - DELETE /api/sponsored-ads-requests/{id}         (حذف طلب)
 * - GET    /api/sponsored-ads-requests/statistics   (إحصائيات)
 *
 * Admin Routes:
 * - GET    /api/admin/sponsored-ads-requests        (جميع الطلبات)
 * - PUT    /api/admin/sponsored-ads-requests/{id}   (تحديث طلب + إحصائيات)
 */
