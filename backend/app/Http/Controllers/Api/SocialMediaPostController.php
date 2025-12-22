<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\UploadPostService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;

class SocialMediaPostController extends Controller
{
    protected $uploadPostService;

    public function __construct(UploadPostService $uploadPostService)
    {
        $this->uploadPostService = $uploadPostService;
    }

    /**
     * Upload photo to social media platforms
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function uploadPhoto(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'image' => 'required|image|max:10240', // Max 10MB
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

        if ($result['success']) {
            return response()->json($result, 200);
        }

        return response()->json($result, 400);
    }

    /**
     * Upload video to social media platforms
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function uploadVideo(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'video' => 'required|mimes:mp4,mov,avi,mkv|max:102400', // Max 100MB
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

        if ($result['success']) {
            return response()->json($result, 200);
        }

        return response()->json($result, 400);
    }

    /**
     * Upload text post to social media platforms
     *
     * @param Request $request
     * @return JsonResponse
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

        if ($result['success']) {
            return response()->json($result, 200);
        }

        return response()->json($result, 400);
    }

    /**
     * Get supported platforms
     *
     * @return JsonResponse
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
     *
     * @return JsonResponse
     */
    public function status(): JsonResponse
    {
        return response()->json([
            'configured' => $this->uploadPostService->isConfigured(),
        ], 200);
    }
}
