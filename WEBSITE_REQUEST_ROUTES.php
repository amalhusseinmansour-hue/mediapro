<?php

/**
 * Website Request Routes
 * مسارات API لطلبات المواقع الإلكترونية
 *
 * ضع هذه المسارات في ملف routes/api.php
 */

use App\Http\Controllers\WebsiteRequestController;
use Illuminate\Support\Facades\Route;

// ==================== User Routes (Protected) ====================
// المسارات الخاصة بالمستخدمين - تتطلب المصادقة

Route::middleware(['auth:sanctum'])->group(function () {

    // إرسال طلب موقع جديد
    Route::post('/website-requests', [WebsiteRequestController::class, 'store']);

    // الحصول على جميع طلبات المستخدم
    Route::get('/website-requests', [WebsiteRequestController::class, 'index']);

    // الحصول على تفاصيل طلب معين
    Route::get('/website-requests/{id}', [WebsiteRequestController::class, 'show']);

    // حذف طلب (فقط إذا كان pending)
    Route::delete('/website-requests/{id}', [WebsiteRequestController::class, 'destroy']);

    // الحصول على إحصائيات الطلبات
    Route::get('/website-requests/statistics', [WebsiteRequestController::class, 'statistics']);
});

// ==================== Admin Routes (Protected + Admin) ====================
// المسارات الخاصة بالإدارة - تتطلب المصادقة وصلاحيات الإدارة

Route::middleware(['auth:sanctum' /*, 'admin'*/])->prefix('admin')->group(function () {

    // جلب جميع الطلبات (للإدارة)
    Route::get('/website-requests', [WebsiteRequestController::class, 'adminIndex']);

    // تحديث حالة الطلب (للإدارة)
    Route::put('/website-requests/{id}', [WebsiteRequestController::class, 'adminUpdate']);
});

/**
 * ملاحظات التطبيق:
 *
 * 1. تأكد من إضافة هذه المسارات في ملف routes/api.php
 *
 * 2. إذا كان لديك middleware للإدارة، قم بإلغاء التعليق على 'admin' في المسارات الإدارية
 *
 * 3. مثال على كيفية إضافتها في routes/api.php:
 *
 *    // في أول الملف
 *    use App\Http\Controllers\WebsiteRequestController;
 *
 *    // ثم أضف المسارات
 *    Route::middleware(['auth:sanctum'])->group(function () {
 *        Route::post('/website-requests', [WebsiteRequestController::class, 'store']);
 *        Route::get('/website-requests', [WebsiteRequestController::class, 'index']);
 *        // ... باقي المسارات
 *    });
 *
 * 4. تأكد من تشغيل Migration لإنشاء جدول website_requests في قاعدة البيانات
 *
 * 5. URLs الناتجة ستكون:
 *    - POST   /api/website-requests              (إرسال طلب)
 *    - GET    /api/website-requests              (جلب طلبات المستخدم)
 *    - GET    /api/website-requests/{id}         (تفاصيل طلب)
 *    - DELETE /api/website-requests/{id}         (حذف طلب)
 *    - GET    /api/website-requests/statistics   (إحصائيات)
 *    - GET    /api/admin/website-requests        (جميع الطلبات - admin)
 *    - PUT    /api/admin/website-requests/{id}   (تحديث طلب - admin)
 */
