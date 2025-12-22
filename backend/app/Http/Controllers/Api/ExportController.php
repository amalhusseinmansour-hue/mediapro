<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Payment;
use App\Models\SocialMediaPost;
use App\Models\Subscription;
use App\Services\ExportService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ExportController extends Controller
{
    protected $exportService;

    public function __construct(ExportService $exportService)
    {
        $this->exportService = $exportService;
    }

    /**
     * Export users report
     */
    public function exportUsers(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'format' => 'nullable|string|in:csv,json',
            'status' => 'nullable|string|in:active,inactive,all',
            'from_date' => 'nullable|date',
            'to_date' => 'nullable|date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $query = User::query();

        if ($request->status && $request->status !== 'all') {
            $query->where('is_active', $request->status === 'active');
        }

        if ($request->from_date) {
            $query->whereDate('created_at', '>=', $request->from_date);
        }

        if ($request->to_date) {
            $query->whereDate('created_at', '<=', $request->to_date);
        }

        $users = $query->orderBy('created_at', 'desc')->get();
        $result = $this->exportService->exportUsersReport($users, $request->format ?? 'csv');

        if (!$result['success']) {
            return response()->json($result, 500);
        }

        return response()->json([
            'success' => true,
            'message' => 'تم تصدير التقرير بنجاح',
            'data' => [
                'url' => $result['url'],
                'filename' => $result['filename'],
                'count' => $users->count(),
            ],
        ]);
    }

    /**
     * Export payments report
     */
    public function exportPayments(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'format' => 'nullable|string|in:csv,json',
            'status' => 'nullable|string|in:pending,completed,failed,all',
            'from_date' => 'nullable|date',
            'to_date' => 'nullable|date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $query = Payment::with('user');

        if ($request->status && $request->status !== 'all') {
            $query->where('status', $request->status);
        }

        if ($request->from_date) {
            $query->whereDate('created_at', '>=', $request->from_date);
        }

        if ($request->to_date) {
            $query->whereDate('created_at', '<=', $request->to_date);
        }

        $payments = $query->orderBy('created_at', 'desc')->get();
        $result = $this->exportService->exportPaymentsReport($payments, $request->format ?? 'csv');

        if (!$result['success']) {
            return response()->json($result, 500);
        }

        return response()->json([
            'success' => true,
            'message' => 'تم تصدير التقرير بنجاح',
            'data' => [
                'url' => $result['url'],
                'filename' => $result['filename'],
                'count' => $payments->count(),
                'total_amount' => $payments->where('status', 'completed')->sum('amount'),
            ],
        ]);
    }

    /**
     * Export posts report
     */
    public function exportPosts(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'format' => 'nullable|string|in:csv,json',
            'status' => 'nullable|string|in:draft,scheduled,published,failed,all',
            'platform' => 'nullable|string',
            'from_date' => 'nullable|date',
            'to_date' => 'nullable|date',
            'user_id' => 'nullable|integer|exists:users,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $query = SocialMediaPost::with('user');

        if ($request->user_id) {
            $query->where('user_id', $request->user_id);
        }

        if ($request->status && $request->status !== 'all') {
            $query->where('status', $request->status);
        }

        if ($request->platform) {
            $query->whereJsonContains('platforms', $request->platform);
        }

        if ($request->from_date) {
            $query->whereDate('created_at', '>=', $request->from_date);
        }

        if ($request->to_date) {
            $query->whereDate('created_at', '<=', $request->to_date);
        }

        $posts = $query->orderBy('created_at', 'desc')->get();
        $result = $this->exportService->exportPostsReport($posts, $request->format ?? 'csv');

        if (!$result['success']) {
            return response()->json($result, 500);
        }

        return response()->json([
            'success' => true,
            'message' => 'تم تصدير التقرير بنجاح',
            'data' => [
                'url' => $result['url'],
                'filename' => $result['filename'],
                'count' => $posts->count(),
            ],
        ]);
    }

    /**
     * Export subscriptions report
     */
    public function exportSubscriptions(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'format' => 'nullable|string|in:csv,json',
            'status' => 'nullable|string|in:active,cancelled,expired,all',
            'from_date' => 'nullable|date',
            'to_date' => 'nullable|date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $query = Subscription::with(['user', 'plan']);

        if ($request->status && $request->status !== 'all') {
            $query->where('status', $request->status);
        }

        if ($request->from_date) {
            $query->whereDate('created_at', '>=', $request->from_date);
        }

        if ($request->to_date) {
            $query->whereDate('created_at', '<=', $request->to_date);
        }

        $subscriptions = $query->orderBy('created_at', 'desc')->get();
        $result = $this->exportService->exportSubscriptionsReport($subscriptions, $request->format ?? 'csv');

        if (!$result['success']) {
            return response()->json($result, 500);
        }

        return response()->json([
            'success' => true,
            'message' => 'تم تصدير التقرير بنجاح',
            'data' => [
                'url' => $result['url'],
                'filename' => $result['filename'],
                'count' => $subscriptions->count(),
            ],
        ]);
    }

    /**
     * Clean old export files
     */
    public function cleanExports(Request $request)
    {
        $days = $request->get('days', 7);
        $deleted = $this->exportService->cleanOldExports($days);

        return response()->json([
            'success' => true,
            'message' => "تم حذف {$deleted} ملف قديم",
            'deleted_count' => $deleted,
        ]);
    }
}
