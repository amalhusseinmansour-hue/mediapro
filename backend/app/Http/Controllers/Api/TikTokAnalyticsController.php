<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ApifyTikTokService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class TikTokAnalyticsController extends Controller
{
    protected ApifyTikTokService $tiktokService;

    public function __construct(ApifyTikTokService $tiktokService)
    {
        $this->tiktokService = $tiktokService;
    }

    /**
     * Get TikTok user profile
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getUserProfile(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'username' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $result = $this->tiktokService->getUserProfile($request->username);

        if ($result === null) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch user profile'
            ], 500);
        }

        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }

    /**
     * Get TikTok user's posts
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getUserPosts(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'nullable|string',
            'sec_user_id' => 'nullable|string',
            'count' => 'nullable|integer|min:1|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $result = $this->tiktokService->getUserPosts(
            $request->input('user_id', ''),
            $request->input('sec_user_id', ''),
            $request->input('count', 10)
        );

        if ($result === null) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch user posts'
            ], 500);
        }

        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }

    /**
     * Get TikTok post details
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getPostDetails(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'post_id' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $result = $this->tiktokService->getPostDetails($request->post_id);

        if ($result === null) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch post details'
            ], 500);
        }

        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }

    /**
     * Get user's followers
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getUserFollowers(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'nullable|string',
            'sec_user_id' => 'nullable|string',
            'count' => 'nullable|integer|min:1|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $result = $this->tiktokService->getUserFollowers(
            $request->input('user_id', ''),
            $request->input('sec_user_id', ''),
            $request->input('count', 10)
        );

        if ($result === null) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch followers'
            ], 500);
        }

        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }

    /**
     * Get user's following
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getUserFollowing(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'nullable|string',
            'sec_user_id' => 'nullable|string',
            'count' => 'nullable|integer|min:1|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $result = $this->tiktokService->getUserFollowing(
            $request->input('user_id', ''),
            $request->input('sec_user_id', ''),
            $request->input('count', 10)
        );

        if ($result === null) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch following'
            ], 500);
        }

        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }

    /**
     * Search TikTok users
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function searchUsers(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'keyword' => 'required|string',
            'count' => 'nullable|integer|min:1|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $result = $this->tiktokService->searchUsers(
            $request->keyword,
            $request->input('count', 20)
        );

        if ($result === null) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to search users'
            ], 500);
        }

        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }

    /**
     * Search TikTok posts
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function searchPosts(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'keyword' => 'required|string',
            'count' => 'nullable|integer|min:1|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $result = $this->tiktokService->searchPosts(
            $request->keyword,
            $request->input('count', 10)
        );

        if ($result === null) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to search posts'
            ], 500);
        }

        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }

    /**
     * Search TikTok hashtags
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function searchHashtags(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'keyword' => 'required|string',
            'count' => 'nullable|integer|min:1|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $result = $this->tiktokService->searchHashtags(
            $request->keyword,
            $request->input('count', 20)
        );

        if ($result === null) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to search hashtags'
            ], 500);
        }

        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }

    /**
     * Get post comments
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getPostComments(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'post_id' => 'required|string',
            'count' => 'nullable|integer|min:1|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $result = $this->tiktokService->getPostComments(
            $request->post_id,
            $request->input('count', 10)
        );

        if ($result === null) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch comments'
            ], 500);
        }

        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }

    /**
     * Get video without watermark
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function getVideoWithoutWatermark(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'post_id' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $result = $this->tiktokService->getVideoWithoutWatermark($request->post_id);

        if ($result === null) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch video'
            ], 500);
        }

        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }
}
