<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;

/**
 * Sponsored Ads Request Controller
 * معالج طلبات الإعلانات الممولة
 */
class SponsoredAdsRequestController extends Controller
{
    /**
     * إرسال طلب إعلان ممول جديد
     * POST /api/sponsored-ads-requests
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
                'ad_type' => 'required|in:social_media,google_ads,display_ads,video_ads,influencer,combined',
                'platforms' => 'nullable|array',
                'campaign_goal' => 'required|in:awareness,traffic,engagement,leads,sales,app_installs',
                'target_audience' => 'nullable|string',
                'ad_content' => 'required|string|min:20',
                'budget' => 'required|numeric|min:100',
                'currency' => 'nullable|string|max:10',
                'duration_days' => 'nullable|integer|min:1',
                'start_date' => 'nullable|date',
                'end_date' => 'nullable|date|after:start_date',
                'landing_page_url' => 'nullable|url|max:500',
                'special_requirements' => 'nullable|string',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'بيانات غير صحيحة',
                    'errors' => $validator->errors()
                ], 422);
            }

            $userId = Auth::id();
            if (!$userId) {
                return response()->json([
                    'success' => false,
                    'message' => 'يجب تسجيل الدخول أولاً'
                ], 401);
            }

            // إدراج الطلب
            $requestId = DB::table('sponsored_ads_requests')->insertGetId([
                'user_id' => $userId,
                'name' => $request->input('name'),
                'email' => $request->input('email'),
                'phone' => $request->input('phone'),
                'company_name' => $request->input('company_name'),
                'ad_type' => $request->input('ad_type'),
                'platforms' => $request->input('platforms') ? json_encode($request->input('platforms')) : null,
                'campaign_goal' => $request->input('campaign_goal'),
                'target_audience' => $request->input('target_audience'),
                'ad_content' => $request->input('ad_content'),
                'budget' => $request->input('budget'),
                'currency' => $request->input('currency', 'AED'),
                'duration_days' => $request->input('duration_days'),
                'start_date' => $request->input('start_date'),
                'end_date' => $request->input('end_date'),
                'landing_page_url' => $request->input('landing_page_url'),
                'special_requirements' => $request->input('special_requirements'),
                'status' => 'pending',
                'payment_status' => 'unpaid',
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            $adsRequest = DB::table('sponsored_ads_requests')
                ->where('id', $requestId)
                ->first();

            return response()->json([
                'success' => true,
                'message' => 'تم إرسال طلب الإعلان بنجاح. سيتم التواصل معك قريباً',
                'data' => [
                    'id' => $adsRequest->id,
                    'status' => $adsRequest->status,
                    'payment_status' => $adsRequest->payment_status,
                    'created_at' => $adsRequest->created_at,
                ]
            ], 201);

        } catch (\Exception $e) {
            \Log::error('خطأ في إرسال طلب الإعلان: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء إرسال الطلب',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * الحصول على جميع طلبات المستخدم
     * GET /api/sponsored-ads-requests
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

            $query = DB::table('sponsored_ads_requests')
                ->where('user_id', $userId);

            // فلترة حسب الحالة
            if ($request->has('status')) {
                $query->where('status', $request->input('status'));
            }

            // فلترة حسب نوع الإعلان
            if ($request->has('ad_type')) {
                $query->where('ad_type', $request->input('ad_type'));
            }

            // بحث
            if ($request->has('search')) {
                $search = $request->input('search');
                $query->where(function($q) use ($search) {
                    $q->where('company_name', 'LIKE', "%{$search}%")
                      ->orWhere('ad_content', 'LIKE', "%{$search}%");
                });
            }

            $perPage = $request->input('per_page', 15);
            $requests = $query->orderBy('created_at', 'desc')
                ->paginate($perPage);

            // فك تشفير JSON في النتائج
            foreach ($requests->items() as $item) {
                if ($item->platforms) {
                    $item->platforms = json_decode($item->platforms, true);
                }
                if ($item->creative_files) {
                    $item->creative_files = json_decode($item->creative_files, true);
                }
            }

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
     * GET /api/sponsored-ads-requests/{id}
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

            $adsRequest = DB::table('sponsored_ads_requests')
                ->where('id', $id)
                ->where('user_id', $userId)
                ->first();

            if (!$adsRequest) {
                return response()->json([
                    'success' => false,
                    'message' => 'الطلب غير موجود'
                ], 404);
            }

            // فك تشفير JSON
            if ($adsRequest->platforms) {
                $adsRequest->platforms = json_decode($adsRequest->platforms, true);
            }
            if ($adsRequest->creative_files) {
                $adsRequest->creative_files = json_decode($adsRequest->creative_files, true);
            }

            return response()->json([
                'success' => true,
                'data' => $adsRequest
            ]);

        } catch (\Exception $e) {
            \Log::error('خطأ في جلب تفاصيل الطلب: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * حذف طلب (pending فقط)
     * DELETE /api/sponsored-ads-requests/{id}
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

            $adsRequest = DB::table('sponsored_ads_requests')
                ->where('id', $id)
                ->where('user_id', $userId)
                ->first();

            if (!$adsRequest) {
                return response()->json([
                    'success' => false,
                    'message' => 'الطلب غير موجود'
                ], 404);
            }

            // لا يمكن حذف الطلب إذا كان نشط أو مكتمل
            if (in_array($adsRequest->status, ['active', 'completed'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'لا يمكن حذف هذا الطلب في حالته الحالية'
                ], 403);
            }

            DB::table('sponsored_ads_requests')->where('id', $id)->delete();

            return response()->json([
                'success' => true,
                'message' => 'تم حذف الطلب بنجاح'
            ]);

        } catch (\Exception $e) {
            \Log::error('خطأ في حذف الطلب: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * الحصول على إحصائيات طلبات المستخدم
     * GET /api/sponsored-ads-requests/statistics
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

            $stats = [
                'total' => DB::table('sponsored_ads_requests')->where('user_id', $userId)->count(),
                'pending' => DB::table('sponsored_ads_requests')->where('user_id', $userId)->where('status', 'pending')->count(),
                'reviewing' => DB::table('sponsored_ads_requests')->where('user_id', $userId)->where('status', 'reviewing')->count(),
                'approved' => DB::table('sponsored_ads_requests')->where('user_id', $userId)->where('status', 'approved')->count(),
                'payment_pending' => DB::table('sponsored_ads_requests')->where('user_id', $userId)->where('status', 'payment_pending')->count(),
                'active' => DB::table('sponsored_ads_requests')->where('user_id', $userId)->where('status', 'active')->count(),
                'paused' => DB::table('sponsored_ads_requests')->where('user_id', $userId)->where('status', 'paused')->count(),
                'completed' => DB::table('sponsored_ads_requests')->where('user_id', $userId)->where('status', 'completed')->count(),
                'cancelled' => DB::table('sponsored_ads_requests')->where('user_id', $userId)->where('status', 'cancelled')->count(),
                'total_budget' => DB::table('sponsored_ads_requests')->where('user_id', $userId)->sum('budget'),
                'total_spent' => DB::table('sponsored_ads_requests')->where('user_id', $userId)->sum('spent_amount'),
                'total_impressions' => DB::table('sponsored_ads_requests')->where('user_id', $userId)->sum('impressions'),
                'total_clicks' => DB::table('sponsored_ads_requests')->where('user_id', $userId)->sum('clicks'),
                'total_conversions' => DB::table('sponsored_ads_requests')->where('user_id', $userId)->sum('conversions'),
            ];

            return response()->json([
                'success' => true,
                'data' => $stats
            ]);

        } catch (\Exception $e) {
            \Log::error('خطأ في جلب الإحصائيات: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // ==================== Admin Methods ====================

    /**
     * جلب جميع الطلبات (للإدارة)
     * GET /api/admin/sponsored-ads-requests
     */
    public function adminIndex(Request $request)
    {
        try {
            $query = DB::table('sponsored_ads_requests')
                ->join('users', 'sponsored_ads_requests.user_id', '=', 'users.id')
                ->select('sponsored_ads_requests.*', 'users.name as user_name', 'users.email as user_email');

            if ($request->has('status')) {
                $query->where('sponsored_ads_requests.status', $request->input('status'));
            }

            if ($request->has('ad_type')) {
                $query->where('ad_type', $request->input('ad_type'));
            }

            $perPage = $request->input('per_page', 20);
            $requests = $query->orderBy('sponsored_ads_requests.created_at', 'desc')
                ->paginate($perPage);

            return response()->json([
                'success' => true,
                'data' => $requests
            ]);

        } catch (\Exception $e) {
            \Log::error('خطأ في جلب جميع الطلبات: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * تحديث حالة الطلب (للإدارة)
     * PUT /api/admin/sponsored-ads-requests/{id}
     */
    public function adminUpdate(Request $request, $id)
    {
        try {
            $validator = Validator::make($request->all(), [
                'status' => 'required|in:pending,reviewing,approved,payment_pending,active,paused,completed,cancelled',
                'admin_notes' => 'nullable|string',
                'payment_status' => 'nullable|in:unpaid,partial,paid,refunded',
                'payment_amount' => 'nullable|numeric',
                'impressions' => 'nullable|integer',
                'clicks' => 'nullable|integer',
                'conversions' => 'nullable|integer',
                'spent_amount' => 'nullable|numeric',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'بيانات غير صحيحة',
                    'errors' => $validator->errors()
                ], 422);
            }

            $updateData = [
                'status' => $request->input('status'),
                'updated_at' => now(),
            ];

            if ($request->has('admin_notes')) {
                $updateData['admin_notes'] = $request->input('admin_notes');
            }
            if ($request->has('payment_status')) {
                $updateData['payment_status'] = $request->input('payment_status');
            }
            if ($request->has('payment_amount')) {
                $updateData['payment_amount'] = $request->input('payment_amount');
            }
            if ($request->has('impressions')) {
                $updateData['impressions'] = $request->input('impressions');
            }
            if ($request->has('clicks')) {
                $updateData['clicks'] = $request->input('clicks');
            }
            if ($request->has('conversions')) {
                $updateData['conversions'] = $request->input('conversions');
            }
            if ($request->has('spent_amount')) {
                $updateData['spent_amount'] = $request->input('spent_amount');
            }

            $updated = DB::table('sponsored_ads_requests')
                ->where('id', $id)
                ->update($updateData);

            if (!$updated) {
                return response()->json([
                    'success' => false,
                    'message' => 'الطلب غير موجود'
                ], 404);
            }

            return response()->json([
                'success' => true,
                'message' => 'تم تحديث الطلب بنجاح'
            ]);

        } catch (\Exception $e) {
            \Log::error('خطأ في تحديث الطلب: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
