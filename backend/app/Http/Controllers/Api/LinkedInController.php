<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ConnectedAccount;
use App\Services\SocialMedia\LinkedInService;
use App\Services\SocialMedia\LinkedInAnalyticsService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class LinkedInController extends Controller
{
    protected LinkedInService $linkedInService;
    protected LinkedInAnalyticsService $analyticsService;

    public function __construct(LinkedInService $linkedInService, LinkedInAnalyticsService $analyticsService)
    {
        $this->linkedInService = $linkedInService;
        $this->analyticsService = $analyticsService;
    }

    /**
     * Post text content to LinkedIn
     */
    public function postText(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'content' => 'required|string|max:3000',
            'account_id' => 'sometimes|exists:connected_accounts,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صحيحة',
                'errors' => $validator->errors(),
            ], 422);
        }

        $account = $this->getLinkedInAccount($request);

        if (!$account) {
            return response()->json([
                'success' => false,
                'message' => 'لا يوجد حساب LinkedIn متصل',
            ], 404);
        }

        $result = $this->linkedInService->postText($account, $request->content);

        if ($result['success']) {
            // Update last used
            $account->update(['last_used_at' => now()]);
        }

        return response()->json($result, $result['success'] ? 200 : 400);
    }

    /**
     * Post with image to LinkedIn
     */
    public function postWithImage(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'content' => 'required|string|max:3000',
            'image_url' => 'required|url',
            'account_id' => 'sometimes|exists:connected_accounts,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صحيحة',
                'errors' => $validator->errors(),
            ], 422);
        }

        $account = $this->getLinkedInAccount($request);

        if (!$account) {
            return response()->json([
                'success' => false,
                'message' => 'لا يوجد حساب LinkedIn متصل',
            ], 404);
        }

        $result = $this->linkedInService->postWithImage(
            $account,
            $request->content,
            $request->image_url
        );

        if ($result['success']) {
            $account->update(['last_used_at' => now()]);
        }

        return response()->json($result, $result['success'] ? 200 : 400);
    }

    /**
     * Post with link/article to LinkedIn
     */
    public function postWithLink(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'content' => 'required|string|max:3000',
            'link_url' => 'required|url',
            'title' => 'nullable|string|max:200',
            'description' => 'nullable|string|max:500',
            'account_id' => 'sometimes|exists:connected_accounts,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صحيحة',
                'errors' => $validator->errors(),
            ], 422);
        }

        $account = $this->getLinkedInAccount($request);

        if (!$account) {
            return response()->json([
                'success' => false,
                'message' => 'لا يوجد حساب LinkedIn متصل',
            ], 404);
        }

        $result = $this->linkedInService->postWithLink(
            $account,
            $request->content,
            $request->link_url,
            $request->title,
            $request->description
        );

        if ($result['success']) {
            $account->update(['last_used_at' => now()]);
        }

        return response()->json($result, $result['success'] ? 200 : 400);
    }

    /**
     * Universal post method - handles all types
     */
    public function post(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'content' => 'required|string|max:3000',
            'type' => 'sometimes|in:text,image,link',
            'image_url' => 'required_if:type,image|nullable|url',
            'link_url' => 'required_if:type,link|nullable|url',
            'title' => 'nullable|string|max:200',
            'description' => 'nullable|string|max:500',
            'account_id' => 'sometimes|exists:connected_accounts,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صحيحة',
                'errors' => $validator->errors(),
            ], 422);
        }

        $account = $this->getLinkedInAccount($request);

        if (!$account) {
            return response()->json([
                'success' => false,
                'message' => 'لا يوجد حساب LinkedIn متصل',
            ], 404);
        }

        $type = $request->type ?? 'text';

        // Auto-detect type if not specified
        if ($request->image_url && $type === 'text') {
            $type = 'image';
        } elseif ($request->link_url && $type === 'text') {
            $type = 'link';
        }

        $result = match($type) {
            'image' => $this->linkedInService->postWithImage(
                $account,
                $request->content,
                $request->image_url
            ),
            'link' => $this->linkedInService->postWithLink(
                $account,
                $request->content,
                $request->link_url,
                $request->title,
                $request->description
            ),
            default => $this->linkedInService->postText($account, $request->content),
        };

        if ($result['success']) {
            $account->update(['last_used_at' => now()]);
        }

        return response()->json($result, $result['success'] ? 200 : 400);
    }

    /**
     * Delete a LinkedIn post
     */
    public function deletePost(Request $request, string $postUrn): JsonResponse
    {
        $account = $this->getLinkedInAccount($request);

        if (!$account) {
            return response()->json([
                'success' => false,
                'message' => 'لا يوجد حساب LinkedIn متصل',
            ], 404);
        }

        $result = $this->linkedInService->deletePost($account, $postUrn);

        return response()->json($result, $result['success'] ? 200 : 400);
    }

    /**
     * Validate LinkedIn account connection
     */
    public function validateAccount(Request $request): JsonResponse
    {
        $account = $this->getLinkedInAccount($request);

        if (!$account) {
            return response()->json([
                'success' => false,
                'message' => 'لا يوجد حساب LinkedIn متصل',
                'is_valid' => false,
            ], 404);
        }

        $isValid = $this->linkedInService->validateToken($account);

        if (!$isValid) {
            $account->update(['is_active' => false]);
        }

        return response()->json([
            'success' => true,
            'is_valid' => $isValid,
            'account' => [
                'id' => $account->id,
                'username' => $account->username,
                'display_name' => $account->display_name,
                'is_active' => $isValid,
            ],
        ]);
    }

    /**
     * Get LinkedIn account for user
     */
    protected function getLinkedInAccount(Request $request): ?ConnectedAccount
    {
        $userId = Auth::id() ?? $request->user_id;

        if (!$userId) {
            return null;
        }

        // If specific account_id provided
        if ($request->account_id) {
            return ConnectedAccount::where('id', $request->account_id)
                ->where('user_id', $userId)
                ->where('platform', 'linkedin')
                ->where('is_active', true)
                ->first();
        }

        // Get default LinkedIn account
        return ConnectedAccount::where('user_id', $userId)
            ->where('platform', 'linkedin')
            ->where('is_active', true)
            ->first();
    }

    // ============== Analytics Methods ==============

    /**
     * Get complete analytics dashboard
     */
    public function getAnalyticsDashboard(Request $request): JsonResponse
    {
        $account = $this->getLinkedInAccount($request);

        if (!$account) {
            return response()->json([
                'success' => false,
                'message' => 'لا يوجد حساب LinkedIn متصل',
            ], 404);
        }

        $result = $this->analyticsService->getDashboardAnalytics($account);

        return response()->json($result, $result['success'] ? 200 : 400);
    }

    /**
     * Get profile statistics
     */
    public function getProfileStats(Request $request): JsonResponse
    {
        $account = $this->getLinkedInAccount($request);

        if (!$account) {
            return response()->json([
                'success' => false,
                'message' => 'لا يوجد حساب LinkedIn متصل',
            ], 404);
        }

        $result = $this->analyticsService->getProfileStats($account);

        return response()->json($result, $result['success'] ? 200 : 400);
    }

    /**
     * Get posts analytics
     */
    public function getPostsAnalytics(Request $request): JsonResponse
    {
        $account = $this->getLinkedInAccount($request);

        if (!$account) {
            return response()->json([
                'success' => false,
                'message' => 'لا يوجد حساب LinkedIn متصل',
            ], 404);
        }

        $count = $request->get('count', 10);
        $result = $this->analyticsService->getPostsAnalytics($account, $count);

        return response()->json($result, $result['success'] ? 200 : 400);
    }

    /**
     * Get engagement summary
     */
    public function getEngagementSummary(Request $request): JsonResponse
    {
        $account = $this->getLinkedInAccount($request);

        if (!$account) {
            return response()->json([
                'success' => false,
                'message' => 'لا يوجد حساب LinkedIn متصل',
            ], 404);
        }

        $postsCount = $request->get('posts_count', 20);
        $result = $this->analyticsService->getEngagementSummary($account, $postsCount);

        return response()->json($result, $result['success'] ? 200 : 400);
    }

    /**
     * Get follower statistics
     */
    public function getFollowerStats(Request $request): JsonResponse
    {
        $account = $this->getLinkedInAccount($request);

        if (!$account) {
            return response()->json([
                'success' => false,
                'message' => 'لا يوجد حساب LinkedIn متصل',
            ], 404);
        }

        $timeRange = $request->get('time_range', 'month');
        $result = $this->analyticsService->getFollowerStats($account, $timeRange);

        return response()->json($result, $result['success'] ? 200 : 400);
    }
}
