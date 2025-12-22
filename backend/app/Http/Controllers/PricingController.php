<?php

namespace App\Http\Controllers;

use App\Models\SubscriptionPlan;
use Illuminate\Http\Request;

class PricingController extends Controller
{
    /**
     * عرض صفحة الأسعار
     */
    public function index()
    {
        $plans = SubscriptionPlan::where('is_active', true)
            ->orderBy('sort_order', 'asc')
            ->get();

        // Group plans by audience type
        $individualPlans = $plans->where('audience_type', 'individual')->values();
        $businessPlans = $plans->where('audience_type', 'business')->values();

        return view('pricing', compact('plans', 'individualPlans', 'businessPlans'));
    }
}
