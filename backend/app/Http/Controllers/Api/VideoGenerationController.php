<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\KieAIVideoService;
use App\Services\AIVideoGeneratorService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class VideoGenerationController extends Controller
{
    protected KieAIVideoService $kieAIService;
    protected AIVideoGeneratorService $aiVideoService;

    public function __construct(KieAIVideoService $kieAIService, AIVideoGeneratorService $aiVideoService)
    {
        $this->kieAIService = $kieAIService;
        $this->aiVideoService = $aiVideoService;
    }

    /**
     * Generate video from text prompt
     */
    public function generateFromText(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'prompt' => 'required|string|max:500',
            'title' => 'nullable|string|max:100',
            'aspect_ratio' => 'nullable|in:16:9,9:16,1:1',
            'duration' => 'nullable|integer|min:1|max:10',
            'model' => 'nullable|in:veo3_fast,veo3_standard',
            'provider' => 'nullable|in:kie_ai,runway,pika,d-id,stability',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => 'Validation failed',
                'details' => $validator->errors()
            ], 422);
        }

        $provider = $request->input('provider', 'kie_ai');
        $user = Auth::user();

        // Log the request
        Log::info('Video generation request from text', [
            'user_id' => $user->id ?? 'guest',
            'provider' => $provider,
            'prompt' => $request->input('prompt'),
            'aspect_ratio' => $request->input('aspect_ratio', '9:16')
        ]);

        try {
            if ($provider === 'kie_ai') {
                // Use Kie AI (similar to n8n workflow)
                $result = $this->kieAIService->generateWithRetry([
                    'prompt' => $request->input('prompt'),
                    'aspectRatio' => $request->input('aspect_ratio', '9:16'),
                    'duration' => $request->input('duration'),
                    'model' => $request->input('model', 'veo3_fast'),
                ]);
            } else {
                // Use other providers through existing service
                $result = $this->aiVideoService->generateVideo(
                    $request->input('prompt'),
                    $provider,
                    $request->input('duration', 4),
                    $request->input('aspect_ratio', '16:9')
                );
            }

            if ($result['success']) {
                return response()->json([
                    'success' => true,
                    'message' => 'Video generation started successfully',
                    'data' => [
                        'task_id' => $result['task_id'],
                        'provider' => $provider,
                        'status' => $result['status'],
                        'estimated_time' => $result['estimated_time'] ?? 180,
                        'title' => $request->input('title', 'Generated Video'),
                    ]
                ]);
            }

            return response()->json([
                'success' => false,
                'error' => $result['error'],
                'provider' => $provider
            ], 500);

        } catch (\Exception $e) {
            Log::error('Video generation failed', [
                'error' => $e->getMessage(),
                'provider' => $provider,
                'user_id' => $user->id ?? 'guest'
            ]);

            return response()->json([
                'success' => false,
                'error' => 'Video generation failed: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Generate video from image (Image to Video)
     */
    public function generateFromImage(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'image_url' => 'required|url',
            'video_prompt' => 'required|string|max:500',
            'image_name' => 'nullable|string|max:100',
            'aspect_ratio' => 'nullable|in:16:9,9:16,1:1',
            'duration' => 'nullable|integer|min:1|max:10',
            'model' => 'nullable|in:veo3_fast,veo3_standard',
            'provider' => 'nullable|in:kie_ai,runway,pika,stability',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => 'Validation failed',
                'details' => $validator->errors()
            ], 422);
        }

        $provider = $request->input('provider', 'kie_ai');
        $user = Auth::user();

        Log::info('Image-to-video generation request', [
            'user_id' => $user->id ?? 'guest',
            'provider' => $provider,
            'image_url' => $request->input('image_url'),
            'prompt' => $request->input('video_prompt')
        ]);

        try {
            if ($provider === 'kie_ai') {
                // Use Kie AI for image-to-video (similar to n8n Image to Video Tool)
                $result = $this->kieAIService->generateWithRetry([
                    'image_url' => $request->input('image_url'),
                    'prompt' => $request->input('video_prompt'),
                    'aspectRatio' => $request->input('aspect_ratio', '9:16'),
                    'duration' => $request->input('duration'),
                    'model' => $request->input('model', 'veo3_fast'),
                ]);
            } else {
                // Other providers may not support image-to-video
                return response()->json([
                    'success' => false,
                    'error' => 'Image-to-video is currently only supported with Kie AI provider'
                ], 400);
            }

            if ($result['success']) {
                return response()->json([
                    'success' => true,
                    'message' => 'Image-to-video generation started successfully',
                    'data' => [
                        'task_id' => $result['task_id'],
                        'provider' => $provider,
                        'status' => $result['status'],
                        'estimated_time' => $result['estimated_time'] ?? 180,
                        'image_name' => $request->input('image_name', 'Image'),
                        'source_image' => $request->input('image_url'),
                    ]
                ]);
            }

            return response()->json([
                'success' => false,
                'error' => $result['error'],
                'provider' => $provider
            ], 500);

        } catch (\Exception $e) {
            Log::error('Image-to-video generation failed', [
                'error' => $e->getMessage(),
                'provider' => $provider,
                'user_id' => $user->id ?? 'guest'
            ]);

            return response()->json([
                'success' => false,
                'error' => 'Image-to-video generation failed: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Check video generation status
     */
    public function checkStatus(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'task_id' => 'required|string',
            'provider' => 'nullable|in:kie_ai,runway,pika,d-id,stability',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => 'Validation failed',
                'details' => $validator->errors()
            ], 422);
        }

        $taskId = $request->input('task_id');
        $provider = $request->input('provider', 'kie_ai');

        try {
            if ($provider === 'kie_ai') {
                $result = $this->kieAIService->checkStatus($taskId);
            } else {
                $result = $this->aiVideoService->checkStatus($taskId, $provider);
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'task_id' => $taskId,
                    'provider' => $provider,
                    'status' => $result['status'] ?? 'unknown',
                    'video_url' => $result['video_url'] ?? null,
                    'download_url' => $result['download_url'] ?? null,
                    'result_data' => $result['result_data'] ?? null,
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Status check failed', [
                'task_id' => $taskId,
                'provider' => $provider,
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'error' => 'Status check failed: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Download and save generated video
     */
    public function downloadVideo(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'video_url' => 'required|url',
            'file_name' => 'nullable|string|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => 'Validation failed',
                'details' => $validator->errors()
            ], 422);
        }

        try {
            $result = $this->kieAIService->downloadVideo(
                $request->input('video_url'),
                $request->input('file_name')
            );

            if ($result['success']) {
                return response()->json([
                    'success' => true,
                    'message' => 'Video downloaded successfully',
                    'data' => [
                        'file_path' => $result['file_path'],
                        'public_url' => $result['public_url'],
                        'file_name' => $result['file_name'],
                    ]
                ]);
            }

            return response()->json([
                'success' => false,
                'error' => $result['error']
            ], 500);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Download failed: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get available video generation providers and capabilities
     */
    public function getProviders(): JsonResponse
    {
        try {
            // Get capabilities from both services
            $kieCapabilities = $this->kieAIService->getCapabilities();
            $allProviders = $this->aiVideoService->getAvailableProviders();

            // Add Kie AI to the providers list
            $allProviders['kie_ai'] = [
                'name' => 'Kie AI (Veo)',
                'status' => 'active',
                'cost_per_video' => 0.25,
                'max_duration' => 10,
                'quality' => 'excellent',
                'features' => ['text-to-video', 'image-to-video', 'fast-generation'],
                'models' => $kieCapabilities['models'],
                'aspect_ratios' => $kieCapabilities['aspect_ratios'],
                'estimated_time' => 180,
            ];

            return response()->json([
                'success' => true,
                'data' => [
                    'providers' => $allProviders,
                    'default_provider' => 'kie_ai',
                    'recommended_settings' => [
                        'aspect_ratio' => '9:16', // TikTok/Instagram Stories format
                        'model' => 'veo3_fast',
                        'max_prompt_length' => 500,
                    ]
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Failed to get providers: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get generation history for authenticated user
     */
    public function getHistory(Request $request): JsonResponse
    {
        $user = Auth::user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'error' => 'Authentication required'
            ], 401);
        }

        try {
            // This would require a video_generations table to store history
            // For now, return empty array
            return response()->json([
                'success' => true,
                'data' => [
                    'generations' => [],
                    'total' => 0,
                    'message' => 'Generation history feature coming soon'
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Failed to get history: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Generate video with Telegram-like workflow (similar to n8n)
     */
    public function generateLikeN8n(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'prompt' => 'required|string|max:500',
            'video_title' => 'nullable|string|max:100',
            'aspect_ratio' => 'nullable|in:16:9,9:16,1:1',
            'chat_id' => 'nullable|string', // For telegram-like integration
            'image_url' => 'nullable|url', // For image-to-video
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => 'Validation failed',
                'details' => $validator->errors()
            ], 422);
        }

        try {
            $params = [
                'prompt' => $request->input('prompt'),
                'aspectRatio' => $request->input('aspect_ratio', '9:16'),
                'model' => 'veo3_fast',
            ];

            // If image URL is provided, use image-to-video
            if ($request->has('image_url')) {
                $params['image_url'] = $request->input('image_url');
            }

            $result = $this->kieAIService->generateWithRetry($params);

            if ($result['success']) {
                // Start a background job to monitor the generation
                // and optionally send notifications when done
                
                return response()->json([
                    'success' => true,
                    'message' => 'Video generation started (n8n-style)',
                    'data' => [
                        'task_id' => $result['task_id'],
                        'status' => $result['status'],
                        'estimated_time' => $result['estimated_time'],
                        'video_title' => $request->input('video_title', 'Generated Video'),
                        'chat_id' => $request->input('chat_id'),
                        'workflow' => 'n8n_compatible',
                    ]
                ]);
            }

            return response()->json([
                'success' => false,
                'error' => $result['error']
            ], 500);

        } catch (\Exception $e) {
            Log::error('N8N-style video generation failed', [
                'error' => $e->getMessage(),
                'request_data' => $request->all()
            ]);

            return response()->json([
                'success' => false,
                'error' => 'Video generation failed: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Webhook endpoint for n8n integration
     * Receives data from n8n Ultimate Media Agent workflow
     */
    public function n8nWebhook(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'action' => 'required|in:create_video,image_to_video,check_status',
            'prompt' => 'required_if:action,create_video,image_to_video|string|max:500',
            'task_id' => 'required_if:action,check_status|string',
            'image_url' => 'nullable|url',
            'video_title' => 'nullable|string|max:100',
            'aspect_ratio' => 'nullable|in:16:9,9:16,1:1',
            'chat_id' => 'nullable|string',
            'user_id' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => 'Invalid webhook data',
                'details' => $validator->errors()
            ], 422);
        }

        $action = $request->input('action');

        Log::info('N8N webhook received', [
            'action' => $action,
            'chat_id' => $request->input('chat_id'),
            'user_id' => $request->input('user_id')
        ]);

        try {
            switch ($action) {
                case 'create_video':
                    return $this->handleN8nVideoCreation($request);
                
                case 'image_to_video':
                    return $this->handleN8nImageToVideo($request);
                
                case 'check_status':
                    return $this->handleN8nStatusCheck($request);
                
                default:
                    return response()->json([
                        'success' => false,
                        'error' => 'Unknown action: ' . $action
                    ], 400);
            }

        } catch (\Exception $e) {
            Log::error('N8N webhook processing failed', [
                'action' => $action,
                'error' => $e->getMessage(),
                'request_data' => $request->all()
            ]);

            return response()->json([
                'success' => false,
                'error' => 'Webhook processing failed: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Handle video creation from n8n webhook
     */
    private function handleN8nVideoCreation(Request $request): JsonResponse
    {
        $result = $this->kieAIService->generateWithRetry([
            'prompt' => $request->input('prompt'),
            'aspectRatio' => $request->input('aspect_ratio', '9:16'),
            'model' => 'veo3_fast',
        ]);

        if ($result['success']) {
            return response()->json([
                'success' => true,
                'message' => 'Video generation started via n8n webhook',
                'data' => [
                    'task_id' => $result['task_id'],
                    'status' => $result['status'],
                    'estimated_time' => $result['estimated_time'],
                    'video_title' => $request->input('video_title', 'Generated Video'),
                    'chat_id' => $request->input('chat_id'),
                    'webhook_source' => 'n8n_ultimate_media_agent',
                ]
            ]);
        }

        return response()->json([
            'success' => false,
            'error' => $result['error'],
            'webhook_source' => 'n8n_ultimate_media_agent'
        ], 500);
    }

    /**
     * Handle image-to-video creation from n8n webhook
     */
    private function handleN8nImageToVideo(Request $request): JsonResponse
    {
        if (!$request->has('image_url')) {
            return response()->json([
                'success' => false,
                'error' => 'Image URL is required for image-to-video generation'
            ], 400);
        }

        $result = $this->kieAIService->generateWithRetry([
            'image_url' => $request->input('image_url'),
            'prompt' => $request->input('prompt'),
            'aspectRatio' => $request->input('aspect_ratio', '9:16'),
            'model' => 'veo3_fast',
        ]);

        if ($result['success']) {
            return response()->json([
                'success' => true,
                'message' => 'Image-to-video generation started via n8n webhook',
                'data' => [
                    'task_id' => $result['task_id'],
                    'status' => $result['status'],
                    'estimated_time' => $result['estimated_time'],
                    'video_title' => $request->input('video_title', 'Generated Video'),
                    'chat_id' => $request->input('chat_id'),
                    'source_image' => $request->input('image_url'),
                    'webhook_source' => 'n8n_ultimate_media_agent',
                ]
            ]);
        }

        return response()->json([
            'success' => false,
            'error' => $result['error'],
            'webhook_source' => 'n8n_ultimate_media_agent'
        ], 500);
    }

    /**
     * Handle status check from n8n webhook
     */
    private function handleN8nStatusCheck(Request $request): JsonResponse
    {
        $taskId = $request->input('task_id');
        $result = $this->kieAIService->checkStatus($taskId);

        return response()->json([
            'success' => true,
            'data' => [
                'task_id' => $taskId,
                'status' => $result['status'] ?? 'unknown',
                'video_url' => $result['video_url'] ?? null,
                'download_url' => $result['download_url'] ?? null,
                'result_data' => $result['result_data'] ?? null,
                'webhook_source' => 'n8n_ultimate_media_agent',
            ]
        ]);
    }
}