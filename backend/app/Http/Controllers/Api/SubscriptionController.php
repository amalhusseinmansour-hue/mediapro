<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class SubscriptionController extends Controller
{
    /**
     * عرض جميع الاشتراكات
     */
    public function index(Request $request): JsonResponse
    {
        $subscriptions = Subscription::where('user_id', $request->user()->id)
            ->with('payments')
            ->orderBy('created_at', 'desc')
            ->paginate(15);

        return response()->json($subscriptions);
    }

    /**
     * عرض اشتراك واحد
     */
    public function show(string $id): JsonResponse
    {
        $subscription = Subscription::with(['payments', 'earnings'])
            ->findOrFail($id);

        return response()->json($subscription);
    }

    /**
     * إنشاء اشتراك جديد
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'plan_id' => 'required|exists:subscription_plans,id',
            'payment_method' => 'required|in:stripe,paypal',
        ]);

        $plan = SubscriptionPlan::findOrFail($validated['plan_id']);

        $subscription = Subscription::create([
            'user_id' => $request->user()->id,
            'name' => $plan->name,
            'type' => $plan->type,
            'price' => $plan->price,
            'currency' => $plan->currency,
            'features' => $plan->features,
            'max_accounts' => $plan->max_accounts,
            'max_posts' => $plan->max_posts,
            'ai_features' => $plan->ai_features,
            'analytics' => $plan->analytics,
            'scheduling' => $plan->scheduling,
            'status' => 'pending',
            'starts_at' => now(),
            'ends_at' => $plan->type === 'monthly' ? now()->addMonth() :
                        ($plan->type === 'yearly' ? now()->addYear() : null),
        ]);

        return response()->json($subscription, 201);
    }

    /**
     * تحديث اشتراك
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $subscription = Subscription::findOrFail($id);

        $validated = $request->validate([
            'status' => 'sometimes|in:active,cancelled,expired',
        ]);

        $subscription->update($validated);

        return response()->json($subscription);
    }

    /**
     * حذف اشتراك
     */
    public function destroy(string $id): JsonResponse
    {
        $subscription = Subscription::findOrFail($id);
        $subscription->delete();

        return response()->json(['message' => 'تم حذف الاشتراك بنجاح']);
    }

    /**
     * إلغاء اشتراك
     */
    public function cancel(string $id): JsonResponse
    {
        $subscription = Subscription::findOrFail($id);
        $subscription->cancel();

        return response()->json([
            'message' => 'تم إلغاء الاشتراك بنجاح',
            'subscription' => $subscription
        ]);
    }

    /**
     * تجديد اشتراك
     */
    public function renew(Request $request, string $id): JsonResponse
    {
        $subscription = Subscription::findOrFail($id);

        $months = $request->input('months', 1);
        $subscription->renew($months);

        return response()->json([
            'message' => 'تم تجديد الاشتراك بنجاح',
            'subscription' => $subscription
        ]);
    }

    /**
     * الحصول على الاشتراك الحالي
     */
    public function current(Request $request): JsonResponse
    {
        $subscription = Subscription::where('user_id', $request->user()->id)
            ->where('status', 'active')
            ->where('starts_at', '<=', now())
            ->where(function ($query) {
                $query->whereNull('ends_at')
                    ->orWhere('ends_at', '>=', now());
            })
            ->first();

        return response()->json($subscription);
    }

    /**
     * عرض جميع الباقات المتاحة
     */
    public function plans(): JsonResponse
    {
        $plans = SubscriptionPlan::active()
            ->ordered()
            ->get();

        return response()->json($plans);
    }
}
