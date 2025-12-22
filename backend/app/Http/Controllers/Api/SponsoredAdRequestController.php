<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SponsoredAdRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class SponsoredAdRequestController extends Controller
{
    /**
     * Display a listing of sponsored ad requests
     */
    public function index(Request $request)
    {
        $query = SponsoredAdRequest::query();

        // Filter by status
        if ($request->has('status')) {
            $query->byStatus($request->status);
        }

        // Filter by platform
        if ($request->has('ad_platform')) {
            $query->byPlatform($request->ad_platform);
        }

        // Filter by ad type
        if ($request->has('ad_type')) {
            $query->where('ad_type', $request->ad_type);
        }

        // Search
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%")
                  ->orWhere('company_name', 'like', "%{$search}%");
            });
        }

        $requests = $query->latest()->paginate($request->per_page ?? 15);

        return response()->json([
            'success' => true,
            'data' => $requests
        ]);
    }

    /**
     * Store a newly created sponsored ad request
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|email|max:255',
            'phone' => 'required|string|max:20',
            'company_name' => 'nullable|string|max:255',
            'ad_platform' => 'required|in:facebook,instagram,google,tiktok,twitter,linkedin,snapchat,multiple',
            'ad_type' => 'required|in:awareness,traffic,engagement,leads,sales,app_installs',
            'target_audience' => 'required|string',
            'budget' => 'required|numeric|min:1',
            'currency' => 'nullable|string|max:3',
            'duration_days' => 'nullable|integer|min:1',
            'start_date' => 'nullable|date|after:today',
            'ad_content' => 'nullable|string',
            'targeting_options' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صحيحة',
                'errors' => $validator->errors()
            ], 422);
        }

        // إنشاء الطلب مع ربطه بالمستخدم (إذا كان مسجل دخول)
        $data = $request->all();

        // إضافة user_id إذا كان المستخدم مسجل دخول
        if ($request->user()) {
            $data['user_id'] = $request->user()->id;
        }

        $adRequest = SponsoredAdRequest::create($data);

        // تحميل بيانات المستخدم المرتبط
        $adRequest->load('user');

        return response()->json([
            'success' => true,
            'message' => 'تم إرسال طلب الإعلان الممول بنجاح! سنتواصل معك قريباً.',
            'data' => $adRequest
        ], 201);
    }

    /**
     * Display the specified sponsored ad request
     */
    public function show($id)
    {
        $adRequest = SponsoredAdRequest::findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $adRequest
        ]);
    }

    /**
     * Update the specified sponsored ad request
     */
    public function update(Request $request, $id)
    {
        $adRequest = SponsoredAdRequest::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'status' => 'sometimes|in:pending,reviewing,accepted,rejected,running,completed',
            'admin_notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صحيحة',
                'errors' => $validator->errors()
            ], 422);
        }

        $adRequest->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث الطلب بنجاح',
            'data' => $adRequest
        ]);
    }

    /**
     * Remove the specified sponsored ad request
     */
    public function destroy($id)
    {
        $adRequest = SponsoredAdRequest::findOrFail($id);
        $adRequest->delete();

        return response()->json([
            'success' => true,
            'message' => 'تم حذف الطلب بنجاح'
        ]);
    }

    /**
     * Get statistics
     */
    public function statistics()
    {
        return response()->json([
            'success' => true,
            'data' => [
                'total' => SponsoredAdRequest::count(),
                'pending' => SponsoredAdRequest::pending()->count(),
                'reviewing' => SponsoredAdRequest::byStatus('reviewing')->count(),
                'accepted' => SponsoredAdRequest::byStatus('accepted')->count(),
                'rejected' => SponsoredAdRequest::byStatus('rejected')->count(),
                'running' => SponsoredAdRequest::byStatus('running')->count(),
                'completed' => SponsoredAdRequest::byStatus('completed')->count(),
                'by_platform' => [
                    'facebook' => SponsoredAdRequest::byPlatform('facebook')->count(),
                    'instagram' => SponsoredAdRequest::byPlatform('instagram')->count(),
                    'google' => SponsoredAdRequest::byPlatform('google')->count(),
                    'tiktok' => SponsoredAdRequest::byPlatform('tiktok')->count(),
                ]
            ]
        ]);
    }
}
