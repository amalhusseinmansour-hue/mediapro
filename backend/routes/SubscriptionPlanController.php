<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class SubscriptionPlanController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        // In a real application, you would fetch this from the database.
        $plans = [
            [
                'id' => 1,
                'name' => 'Free Plan',
                'price' => 0,
                'features' => ['Feature A', 'Feature B']
            ],
            [
                'id' => 2,
                'name' => 'Pro Plan',
                'price' => 99,
                'features' => ['Feature A', 'Feature B', 'Feature C', 'Feature D']
            ]
        ];

        return response()->json($plans);
    }
}