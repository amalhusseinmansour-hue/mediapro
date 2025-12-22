<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Jobs\GenerateAIVideoJob;
use App\Models\AiGeneratedVideo;
use App\Services\AIVideoGeneratorService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AIVideoController extends Controller
{
    protected AIVideoGeneratorService $aiService;

    public function __construct(AIVideoGeneratorService $aiService)
    {
        $this->aiService = $aiService;
    }

    /**
     * Get user's video generation history.
     */
    public function index(Request $request)
    {
        $videos = AiGeneratedVideo::where('user_id', $request->user()->id)
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $videos,
        ]);
    }

    /**
     * Generate a new AI video.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'prompt' => 'required|string|max:1000|min:5',
            'provider' => 'nullable|string|in:gemini,runway,pika,d-id,stability,replicate',
            'duration' => 'nullable|integer|min:1|max:16',
            'aspect_ratio' => 'nullable|string|in:16:9,9:16,1:1,4:3',
            'options' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        // Check user's video generation limits
        $userVideosToday = AiGeneratedVideo::where('user_id', $request->user()->id)
            ->whereDate('created_at', today())
            ->count();

        $maxVideosPerDay = $request->user()->subscription_type === 'premium' ? 50 : 5;

        if ($userVideosToday >= $maxVideosPerDay) {
            return response()->json([
                'success' => false,
                'message' => 'Daily video generation limit exceeded',
                'limit' => $maxVideosPerDay,
                'used' => $userVideosToday,
            ], 429);
        }

        // Create video record
        $video = AiGeneratedVideo::create([
            'user_id' => $request->user()->id,
            'prompt' => $request->prompt,
            'provider' => $request->provider ?? 'gemini',
            'duration' => $request->duration ?? 4,
            'aspect_ratio' => $request->aspect_ratio ?? '16:9',
            'metadata' => $request->options ?? [],
            'status' => 'pending',
        ]);

        // Dispatch generation job
        GenerateAIVideoJob::dispatch($video);

        return response()->json([
            'success' => true,
            'message' => 'Video generation started. You will be notified when ready.',
            'data' => [
                'id' => $video->id,
                'status' => $video->status,
                'estimated_time' => '1-5 minutes',
            ],
        ], 201);
    }

    /**
     * Get specific video details.
     */
    public function show(Request $request, $id)
    {
        $video = AiGeneratedVideo::where('user_id', $request->user()->id)
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $video,
        ]);
    }

    /**
     * Delete a video.
     */
    public function destroy(Request $request, $id)
    {
        $video = AiGeneratedVideo::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $video->delete();

        return response()->json([
            'success' => true,
            'message' => 'Video deleted successfully',
        ]);
    }

    /**
     * Get available providers and their capabilities.
     */
    public function providers()
    {
        $providers = $this->aiService->getAvailableProviders();

        return response()->json([
            'success' => true,
            'data' => $providers,
        ]);
    }

    /**
     * Get user's video generation statistics.
     */
    public function stats(Request $request)
    {
        $userId = $request->user()->id;

        $stats = [
            'total_videos' => AiGeneratedVideo::where('user_id', $userId)->count(),
            'completed_videos' => AiGeneratedVideo::where('user_id', $userId)->byStatus('completed')->count(),
            'processing_videos' => AiGeneratedVideo::where('user_id', $userId)
                ->whereIn('status', ['pending', 'processing'])->count(),
            'failed_videos' => AiGeneratedVideo::where('user_id', $userId)->byStatus('failed')->count(),
            'total_cost' => AiGeneratedVideo::where('user_id', $userId)->sum('cost'),
            'videos_today' => AiGeneratedVideo::where('user_id', $userId)
                ->whereDate('created_at', today())->count(),
            'videos_this_month' => AiGeneratedVideo::where('user_id', $userId)
                ->whereMonth('created_at', now()->month)->count(),
        ];

        // Usage limits
        $maxVideosPerDay = $request->user()->subscription_type === 'premium' ? 50 : 5;
        $maxVideosPerMonth = $request->user()->subscription_type === 'premium' ? 500 : 50;

        $stats['limits'] = [
            'daily_limit' => $maxVideosPerDay,
            'daily_remaining' => max(0, $maxVideosPerDay - $stats['videos_today']),
            'monthly_limit' => $maxVideosPerMonth,
            'monthly_remaining' => max(0, $maxVideosPerMonth - $stats['videos_this_month']),
        ];

        return response()->json([
            'success' => true,
            'data' => $stats,
        ]);
    }

    /**
     * Download video file.
     */
    public function download(Request $request, $id)
    {
        $video = AiGeneratedVideo::where('user_id', $request->user()->id)
            ->findOrFail($id);

        if (!$video->isReady()) {
            return response()->json([
                'success' => false,
                'message' => 'Video is not ready for download',
                'status' => $video->status,
            ], 400);
        }

        return response()->json([
            'success' => true,
            'download_url' => $video->video_url,
            'filename' => 'ai_video_' . $video->id . '.mp4',
        ]);
    }

    /**
     * Retry failed video generation.
     */
    public function retry(Request $request, $id)
    {
        $video = AiGeneratedVideo::where('user_id', $request->user()->id)
            ->findOrFail($id);

        if (!$video->hasFailed()) {
            return response()->json([
                'success' => false,
                'message' => 'Only failed videos can be retried',
                'current_status' => $video->status,
            ], 400);
        }

        // Reset video status
        $video->update([
            'status' => 'pending',
            'video_url' => null,
            'thumbnail_url' => null,
            'task_id' => null,
            'started_at' => null,
            'completed_at' => null,
        ]);

        // Dispatch generation job again
        GenerateAIVideoJob::dispatch($video);

        return response()->json([
            'success' => true,
            'message' => 'Video generation restarted',
            'data' => [
                'id' => $video->id,
                'status' => $video->status,
            ],
        ]);
    }
}