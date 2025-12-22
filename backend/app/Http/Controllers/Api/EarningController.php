<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Earning;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class EarningController extends Controller
{
    /**
     * عرض جميع الأرباح
     */
    public function index(Request $request): JsonResponse
    {
        $query = Earning::query();

        // Filter by user if not admin
        if (!$request->user()->is_admin) {
            $query->where('user_id', $request->user()->id);
        }

        // Apply filters
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        if ($request->has('type')) {
            $query->where('type', $request->type);
        }

        if ($request->has('source')) {
            $query->where('source', $request->source);
        }

        $earnings = $query->with(['user', 'subscription'])
            ->orderBy('created_at', 'desc')
            ->paginate(15);

        return response()->json($earnings);
    }

    /**
     * عرض ربح واحد
     */
    public function show(string $id): JsonResponse
    {
        $earning = Earning::with(['user', 'subscription'])
            ->findOrFail($id);

        return response()->json($earning);
    }

    /**
     * إجمالي الأرباح
     */
    public function total(Request $request): JsonResponse
    {
        $userId = $request->user()->is_admin ? null : $request->user()->id;

        $total = Earning::totalEarnings($userId);

        $pending = Earning::pending()
            ->when($userId, fn($q) => $q->where('user_id', $userId))
            ->sum('amount');

        $completed = Earning::completed()
            ->when($userId, fn($q) => $q->where('user_id', $userId))
            ->sum('amount');

        return response()->json([
            'total' => $total,
            'pending' => $pending,
            'completed' => $completed,
        ]);
    }

    /**
     * الأرباح الشهرية
     */
    public function monthly(Request $request): JsonResponse
    {
        $userId = $request->user()->is_admin ? null : $request->user()->id;

        $months = $request->input('months', 12);

        $earnings = Earning::select(
                DB::raw('YEAR(created_at) as year'),
                DB::raw('MONTH(created_at) as month'),
                DB::raw('SUM(amount) as total'),
                DB::raw('COUNT(*) as count')
            )
            ->when($userId, fn($q) => $q->where('user_id', $userId))
            ->where('status', 'completed')
            ->where('created_at', '>=', now()->subMonths($months))
            ->groupBy('year', 'month')
            ->orderBy('year', 'desc')
            ->orderBy('month', 'desc')
            ->get();

        return response()->json($earnings);
    }
}
