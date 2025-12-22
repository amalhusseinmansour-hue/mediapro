<?php

namespace App\Http\Controllers;

use App\Models\Subscription;
use Illuminate\Http\Request;

class PricingController extends Controller
{
    /**
     * عرض صفحة الأسعار
     */
    public function index()
    {
        $subscriptions = Subscription::where('is_plan', true)
            ->where('is_active', true)
            ->orderBy('price', 'asc')
            ->get();

        return view('pricing', compact('subscriptions'));
    }
}
