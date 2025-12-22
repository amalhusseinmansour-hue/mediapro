<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;

/**
 * Website Request Controller
 * معالج طلبات المواقع الإلكترونية
 */
class WebsiteRequestController extends Controller
{
    /**
     * إرسال طلب موقع إلكتروني جديد
     * POST /api/website-requests
     */
    public function store(Request $request)
    {
        try {
            // التحقق من البيانات
            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:255',
                'email' => 'required|email|max:255',
                'phone' => 'required|string|max:50',
                'company_name' => 'nullable|string|max:255',
                'website_type' => 'required|in:corporate,ecommerce,portfolio,blog,custom',
                'description' => 'required|string|min:20',
                'budget' => 'nullable|numeric|min:0',
                'currency' => 'nullable|string|max:10',
                'deadline' => 'nullable|date',
                'features' => 'nullable|array',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'بيانات غير صحيحة',
                    'errors' => $validator->errors()
                ], 422);
            }

            // الحصول على معرف المستخدم الحالي
            $userId = Auth::id();

            if (!$userId) {
                return response()->json([
                    'success' => false,
                    'message' => 'يجب تسجيل الدخول أولاً'
                ], 401);
            }

            // إدراج الطلب في قاعدة البيانات
            $requestId = DB::table('website_requests')->insertGetId([
                'user_id' => $userId,
                'name' => $request->input('name'),
                'email' => $request->input('email'),
                'phone' => $request->input('phone'),
                'company_name' => $request->input('company_name'),
                'website_type' => $request->input('website_type'),
                'description' => $request->input('description'),
                'budget' => $request->input('budget'),
                'currency' => $request->input('currency', 'SAR'),
                'deadline' => $request->input('deadline'),
                'features' => $request->input('features') ? json_encode($request->input('features')) : null,
                'status' => 'pending',
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // الحصول على الطلب المُنشأ
            $websiteRequest = DB::table('website_requests')
                ->where('id', $requestId)
                ->first();

            // إرسال إشعار للإدارة (اختياري)
            // TODO: إرسال بريد إلكتروني أو إشعار للإدارة

            return response()->json([
                'success' => true,
                'message' => 'تم إرسال طلبك بنجاح. سيتم التواصل معك قريباً',
                'data' => [
                    'id' => $websiteRequest->id,
                    'status' => $websiteRequest->status,
                    'created_at' => $websiteRequest->created_at,
                ]
            ], 201);

        } catch (\Exception $e) {
            \Log::error('خطأ في إرسال طلب الموقع: ' . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء إرسال الطلب. حاول مرة أخرى',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * الحصول على جميع طلبات المستخدم الحالي
     * GET /api/website-requests
     */
    public function index(Request $request)
    {
        try {
            $userId = Auth::id();

            if (!$userId) {
                return response()->json([
                    'success' => false,
                    'message' => 'يجب تسجيل الدخول أولاً'
                ], 401);
            }

            // جلب الطلبات
            $query = DB::table('website_requests')
                ->where('user_id', $userId);

            // فلترة حسب الحالة
            if ($request->has('status')) {
                $query->where('status', $request->input('status'));
            }

            // فلترة حسب نوع الموقع
            if ($request->has('website_type')) {
                $query->where('website_type', $request->input('website_type'));
            }

            // بحث
            if ($request->has('search')) {
                $search = $request->input('search');
                $query->where(function($q) use ($search) {
                    $q->where('company_name', 'LIKE', "%{$search}%")
                      ->orWhere('description', 'LIKE', "%{$search}%");
                });
            }

            // ترتيب وصفحات
            $perPage = $request->input('per_page', 15);
            $requests = $query->orderBy('created_at', 'desc')
                ->paginate($perPage);

            return response()->json([
                'success' => true,
                'data' => $requests
            ]);

        } catch (\Exception $e) {
            \Log::error('خطأ في جلب الطلبات: ' . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء جلب الطلبات',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * الحصول على تفاصيل طلب معين
     * GET /api/website-requests/{id}
     */
    public function show($id)
    {
        try {
            $userId = Auth::id();

            if (!$userId) {
                return response()->json([
                    'success' => false,
                    'message' => 'يجب تسجيل الدخول أولاً'
                ], 401);
            }

            // جلب الطلب
            $websiteRequest = DB::table('website_requests')
                ->where('id', $id)
                ->where('user_id', $userId)
                ->first();

            if (!$websiteRequest) {
                return response()->json([
                    'success' => false,
                    'message' => 'الطلب غير موجود'
                ], 404);
            }

            // فك تشفير JSON
            if ($websiteRequest->features) {
                $websiteRequest->features = json_decode($websiteRequest->features, true);
            }

            return response()->json([
                'success' => true,
                'data' => $websiteRequest
            ]);

        } catch (\Exception $e) {
            \Log::error('خطأ في جلب تفاصيل الطلب: ' . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء جلب تفاصيل الطلب',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * حذف طلب (فقط إذا كانت حالته pending)
     * DELETE /api/website-requests/{id}
     */
    public function destroy($id)
    {
        try {
            $userId = Auth::id();

            if (!$userId) {
                return response()->json([
                    'success' => false,
                    'message' => 'يجب تسجيل الدخول أولاً'
                ], 401);
            }

            // التحقق من الطلب
            $websiteRequest = DB::table('website_requests')
                ->where('id', $id)
                ->where('user_id', $userId)
                ->first();

            if (!$websiteRequest) {
                return response()->json([
                    'success' => false,
                    'message' => 'الطلب غير موجود'
                ], 404);
            }

            // لا يمكن حذف الطلب إذا كان قيد المراجعة أو التنفيذ
            if (in_array($websiteRequest->status, ['reviewing', 'approved', 'in_progress', 'completed'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'لا يمكن حذف هذا الطلب في حالته الحالية'
                ], 403);
            }

            // حذف الطلب
            DB::table('website_requests')
                ->where('id', $id)
                ->delete();

            return response()->json([
                'success' => true,
                'message' => 'تم حذف الطلب بنجاح'
            ]);

        } catch (\Exception $e) {
            \Log::error('خطأ في حذف الطلب: ' . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء حذف الطلب',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * الحصول على إحصائيات طلبات المستخدم
     * GET /api/website-requests/statistics
     */
    public function statistics()
    {
        try {
            $userId = Auth::id();

            if (!$userId) {
                return response()->json([
                    'success' => false,
                    'message' => 'يجب تسجيل الدخول أولاً'
                ], 401);
            }

            // إحصائيات الطلبات
            $stats = [
                'total' => DB::table('website_requests')
                    ->where('user_id', $userId)
                    ->count(),
                'pending' => DB::table('website_requests')
                    ->where('user_id', $userId)
                    ->where('status', 'pending')
                    ->count(),
                'reviewing' => DB::table('website_requests')
                    ->where('user_id', $userId)
                    ->where('status', 'reviewing')
                    ->count(),
                'approved' => DB::table('website_requests')
                    ->where('user_id', $userId)
                    ->where('status', 'approved')
                    ->count(),
                'in_progress' => DB::table('website_requests')
                    ->where('user_id', $userId)
                    ->where('status', 'in_progress')
                    ->count(),
                'completed' => DB::table('website_requests')
                    ->where('user_id', $userId)
                    ->where('status', 'completed')
                    ->count(),
                'cancelled' => DB::table('website_requests')
                    ->where('user_id', $userId)
                    ->where('status', 'cancelled')
                    ->count(),
            ];

            return response()->json([
                'success' => true,
                'data' => $stats
            ]);

        } catch (\Exception $e) {
            \Log::error('خطأ في جلب الإحصائيات: ' . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء جلب الإحصائيات',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // ==================== Admin Methods ====================

    /**
     * جلب جميع الطلبات (للإدارة فقط)
     * GET /api/admin/website-requests
     */
    public function adminIndex(Request $request)
    {
        try {
            // TODO: التحقق من صلاحيات الإدارة
            // if (!Auth::user()->isAdmin()) { return 403; }

            $query = DB::table('website_requests')
                ->join('users', 'website_requests.user_id', '=', 'users.id')
                ->select('website_requests.*', 'users.name as user_name', 'users.email as user_email');

            // فلترة
            if ($request->has('status')) {
                $query->where('website_requests.status', $request->input('status'));
            }

            if ($request->has('website_type')) {
                $query->where('website_type', $request->input('website_type'));
            }

            // ترتيب
            $perPage = $request->input('per_page', 20);
            $requests = $query->orderBy('website_requests.created_at', 'desc')
                ->paginate($perPage);

            return response()->json([
                'success' => true,
                'data' => $requests
            ]);

        } catch (\Exception $e) {
            \Log::error('خطأ في جلب جميع الطلبات: ' . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء جلب الطلبات',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * تحديث حالة الطلب (للإدارة فقط)
     * PUT /api/admin/website-requests/{id}
     */
    public function adminUpdate(Request $request, $id)
    {
        try {
            // TODO: التحقق من صلاحيات الإدارة

            $validator = Validator::make($request->all(), [
                'status' => 'required|in:pending,reviewing,approved,in_progress,completed,cancelled',
                'admin_notes' => 'nullable|string',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'بيانات غير صحيحة',
                    'errors' => $validator->errors()
                ], 422);
            }

            // تحديث الطلب
            $updated = DB::table('website_requests')
                ->where('id', $id)
                ->update([
                    'status' => $request->input('status'),
                    'admin_notes' => $request->input('admin_notes'),
                    'updated_at' => now(),
                ]);

            if (!$updated) {
                return response()->json([
                    'success' => false,
                    'message' => 'الطلب غير موجود'
                ], 404);
            }

            // TODO: إرسال إشعار للمستخدم بتغيير الحالة

            return response()->json([
                'success' => true,
                'message' => 'تم تحديث حالة الطلب بنجاح'
            ]);

        } catch (\Exception $e) {
            \Log::error('خطأ في تحديث الطلب: ' . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء تحديث الطلب',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
