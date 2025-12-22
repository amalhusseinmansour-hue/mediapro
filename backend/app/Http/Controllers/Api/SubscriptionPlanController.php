<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SubscriptionPlan;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SubscriptionPlanController extends Controller
{
    /**
     * عرض جميع الباقات النشطة
     */
    public function index(Request $request): JsonResponse
    {
        $query = SubscriptionPlan::query()
            ->where('is_active', true)
            ->ordered();

        // Filter by audience type if provided
        if ($request->has('audience_type')) {
            $audienceType = $request->input('audience_type');
            if (in_array($audienceType, ['individual', 'business'])) {
                $query->where('audience_type', $audienceType);
            }
        }

        // Filter by type (monthly, yearly) if provided
        if ($request->has('type')) {
            $query->where('type', $request->input('type'));
        }

        $plans = $query->get();

        return response()->json([
            'success' => true,
            'data' => $plans,
        ]);
    }

    /**
     * عرض باقات الأفراد فقط
     */
    public function individualPlans(): JsonResponse
    {
        $plans = SubscriptionPlan::query()
            ->where('is_active', true)
            ->individual()
            ->ordered()
            ->get();

        return response()->json([
            'success' => true,
            'data' => $plans,
        ]);
    }

    /**
     * عرض باقات الأعمال فقط
     */
    public function businessPlans(): JsonResponse
    {
        $plans = SubscriptionPlan::query()
            ->where('is_active', true)
            ->business()
            ->ordered()
            ->get();

        return response()->json([
            'success' => true,
            'data' => $plans,
        ]);
    }

    /**
     * عرض تفاصيل باقة محددة
     */
    public function show(string $slug): JsonResponse
    {
        $plan = SubscriptionPlan::where('slug', $slug)
            ->where('is_active', true)
            ->first();

        if (!$plan) {
            return response()->json([
                'success' => false,
                'message' => 'الباقة غير موجودة',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $plan,
        ]);
    }

    /**
     * عرض الباقات الشهرية
     */
    public function monthlyPlans(Request $request): JsonResponse
    {
        $query = SubscriptionPlan::query()
            ->where('is_active', true)
            ->monthly()
            ->ordered();

        // Filter by audience type if provided
        if ($request->has('audience_type')) {
            $audienceType = $request->input('audience_type');
            if (in_array($audienceType, ['individual', 'business'])) {
                $query->where('audience_type', $audienceType);
            }
        }

        $plans = $query->get();

        return response()->json([
            'success' => true,
            'data' => $plans,
        ]);
    }

    /**
     * عرض الباقات السنوية
     */
    public function yearlyPlans(Request $request): JsonResponse
    {
        $query = SubscriptionPlan::query()
            ->where('is_active', true)
            ->yearly()
            ->ordered();

        // Filter by audience type if provided
        if ($request->has('audience_type')) {
            $audienceType = $request->input('audience_type');
            if (in_array($audienceType, ['individual', 'business'])) {
                $query->where('audience_type', $audienceType);
            }
        }

        $plans = $query->get();

        return response()->json([
            'success' => true,
            'data' => $plans,
        ]);
    }

    /**
     * عرض الباقات الأكثر شعبية
     */
    public function popularPlans(): JsonResponse
    {
        $plans = SubscriptionPlan::query()
            ->where('is_active', true)
            ->popular()
            ->ordered()
            ->get();

        return response()->json([
            'success' => true,
            'data' => $plans,
        ]);
    }
}
