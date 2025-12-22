<?php

namespace App\Jobs;

use App\Models\AiGeneratedVideo;
use App\Services\AIVideoGeneratorService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class CheckVideoGenerationStatusJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected AiGeneratedVideo $video;
    protected int $attempts = 0;
    protected int $maxAttempts = 30; // Max 30 checks (15 minutes if checking every 30 seconds)

    /**
     * Create a new job instance.
     */
    public function __construct(AiGeneratedVideo $video, int $attempts = 0)
    {
        $this->video = $video;
        $this->attempts = $attempts;
    }

    /**
     * Execute the job.
     */
    public function handle(AIVideoGeneratorService $aiService): void
    {
        try {
            if ($this->attempts >= $this->maxAttempts) {
                $this->video->markAsFailed('Timeout: Video generation took too long');
                Log::error('Video generation timed out', ['video_id' => $this->video->id]);
                return;
            }

            Log::info('Checking video generation status', [
                'video_id' => $this->video->id,
                'attempt' => $this->attempts + 1,
            ]);

            $result = $aiService->checkStatus($this->video->task_id, $this->video->provider);

            if ($result['success'] ?? false) {
                $status = $result['status'] ?? 'unknown';

                $statusLower = strtolower($status);
                switch ($statusLower) {
                    case 'completed':
                    case 'done':
                    case 'succeeded':
                    case 'success':
                        $this->handleCompletedVideo($result);
                        break;

                    case 'failed':
                    case 'error':
                    case 'failure':
                        $error = $result['error'] ?? 'Video generation failed';
                        $this->video->markAsFailed($error);
                        Log::error('Video generation failed on provider', [
                            'video_id' => $this->video->id,
                            'error' => $error,
                        ]);
                        break;

                    case 'processing':
                    case 'pending':
                    case 'running':
                    case 'starting':
                    case 'queued':
                    default:
                        // Still processing, check again later
                        $this->scheduleNextCheck();
                        break;
                }
            } else {
                $this->scheduleNextCheck();
            }

        } catch (\Exception $e) {
            Log::error('Error checking video status', [
                'video_id' => $this->video->id,
                'error' => $e->getMessage(),
            ]);

            $this->scheduleNextCheck();
        }
    }

    /**
     * Handle completed video.
     */
    protected function handleCompletedVideo(array $result): void
    {
        $videoUrl = $this->extractVideoUrl($result);
        $thumbnailUrl = $this->extractThumbnailUrl($result);

        if ($videoUrl) {
            $this->video->markAsCompleted($videoUrl, $thumbnailUrl);
            
            Log::info('Video generation completed successfully', [
                'video_id' => $this->video->id,
                'video_url' => $videoUrl,
            ]);

            // Notify user (you can implement notification logic here)
            $this->notifyUser();
        } else {
            $this->video->markAsFailed('No video URL found in response');
            Log::error('Video generation completed but no URL found', [
                'video_id' => $this->video->id,
                'response' => $result,
            ]);
        }
    }

    /**
     * Schedule next check.
     */
    protected function scheduleNextCheck(): void
    {
        CheckVideoGenerationStatusJob::dispatch($this->video, $this->attempts + 1)
            ->delay(now()->addSeconds(30)); // Check every 30 seconds
    }

    /**
     * Extract video URL from provider response.
     */
    protected function extractVideoUrl(array $result): ?string
    {
        // Different providers have different response formats
        // Prefer local_url (stored copy) over remote URLs
        return $result['local_url'] ??
               $result['video_url'] ??
               $result['download_url'] ??
               $result['output'] ??
               $result['result_url'] ??
               $result['video'] ??
               $result['url'] ??
               null;
    }

    /**
     * Extract thumbnail URL from provider response.
     */
    protected function extractThumbnailUrl(array $result): ?string
    {
        return $result['thumbnail_url'] ?? 
               $result['preview_url'] ?? 
               $result['thumbnail'] ?? 
               null;
    }

    /**
     * Notify user about completed video.
     */
    protected function notifyUser(): void
    {
        // You can implement push notification, email, or in-app notification here
        Log::info('Video ready for user', [
            'user_id' => $this->video->user_id,
            'video_id' => $this->video->id,
        ]);

        // Example: Send push notification
        // NotificationService::sendPushNotification(
        //     $this->video->user,
        //     'Video Ready!',
        //     'Your AI-generated video is ready to download.'
        // );
    }

    /**
     * Handle a job failure.
     */
    public function failed(\Throwable $exception): void
    {
        $this->video->markAsFailed($exception->getMessage());
        
        Log::error('Video status check job failed permanently', [
            'video_id' => $this->video->id,
            'error' => $exception->getMessage(),
        ]);
    }
}