<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SocialMediaPost;
use App\Services\UploadPostService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;

class SocialMediaPostController extends Controller
{
    protected $uploadPostService;

    public function __construct(UploadPostService $uploadPostService)
    {
        $this->uploadPostService = $uploadPostService;
    }

    /**
     * Unified post endpoint - handles text and media posts (from Flutter app)
     */
    public function post(Request $request): JsonResponse
    {
        Log::info('Social Post Request', ['data' => $request->all()]);

        $validator = Validator::make($request->all(), [
            'content' => 'required|string',
            'platforms' => 'required|array|min:1',
            'platforms.*' => 'required|string',
            'media_urls' => 'nullable|array',
            'media_urls.*' => 'nullable|string',
            'scheduled_at' => 'nullable|date',
        ]);

        if ($validator->fails()) {
            Log::warning('Validation failed', ['errors' => $validator->errors()]);
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $mediaUrls = $request->input('media_urls', []);
            $scheduledAt = $request->input('scheduled_at');

            $post = SocialMediaPost::create([
                'user_id' => auth()->id(),
                'content' => $request->input('content'),
                'platforms' => $request->input('platforms'),
                'media' => !empty($mediaUrls) ? $mediaUrls : null,
                'scheduled_at' => $scheduledAt,
                'status' => $scheduledAt ? 'scheduled' : 'published',
                'published_at' => $scheduledAt ? null : now(),
            ]);

            Log::info('Post created successfully', ['post_id' => $post->id]);

            return response()->json([
                'success' => true,
                'message' => $scheduledAt ? 'Post scheduled successfully' : 'Post published successfully',
                'data' => $post,
            ], 200);

        } catch (\Exception $e) {
            Log::error('Post creation failed', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Failed to create post: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get post history for authenticated user
     */
    public function history(Request $request): JsonResponse
    {
        try {
            $perPage = $request->input('per_page', 20);
            $platform = $request->input('platform');

            $query = SocialMediaPost::where('user_id', auth()->id())
                ->orderBy('created_at', 'desc');

            if ($platform) {
                $query->whereJsonContains('platforms', $platform);
            }

            $posts = $query->paginate($perPage);

            return response()->json([
                'success' => true,
                'data' => $posts->items(),
                'meta' => [
                    'current_page' => $posts->currentPage(),
                    'total' => $posts->total(),
                    'per_page' => $posts->perPage(),
                ],
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch posts: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Upload photo to social media platforms
     */
    public function uploadPhoto(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'image' => 'required|image|max:10240',
            'caption' => 'required|string',
            'platforms' => 'required|array|min:1',
            'platforms.*' => 'required|string',
            'schedule_time' => 'nullable|date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $result = $this->uploadPostService->uploadPhoto(
            $request->file('image'),
            $request->input('caption'),
            $request->input('platforms'),
            $request->input('schedule_time')
        );

        return response()->json($result, $result['success'] ? 200 : 400);
    }

    /**
     * Upload video to social media platforms
     */
    public function uploadVideo(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'video' => 'required|mimes:mp4,mov,avi,mkv|max:102400',
            'caption' => 'required|string',
            'platforms' => 'required|array|min:1',
            'platforms.*' => 'required|string',
            'title' => 'nullable|string',
            'schedule_time' => 'nullable|date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $result = $this->uploadPostService->uploadVideo(
            $request->file('video'),
            $request->input('caption'),
            $request->input('platforms'),
            $request->input('title'),
            $request->input('schedule_time')
        );

        return response()->json($result, $result['success'] ? 200 : 400);
    }

    /**
     * Upload text post to social media platforms
     */
    public function uploadText(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'text' => 'required|string',
            'platforms' => 'required|array|min:1',
            'platforms.*' => 'required|string',
            'schedule_time' => 'nullable|date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $result = $this->uploadPostService->uploadText(
            $request->input('text'),
            $request->input('platforms'),
            $request->input('schedule_time')
        );

        return response()->json($result, $result['success'] ? 200 : 400);
    }

    /**
     * Get supported platforms
     */
    public function getSupportedPlatforms(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'platforms' => $this->uploadPostService->getSupportedPlatforms(),
        ], 200);
    }

    /**
     * Get Upload-Post service status
     */
    public function status(): JsonResponse
    {
        return response()->json([
            'configured' => $this->uploadPostService->isConfigured(),
        ], 200);
    }
}
