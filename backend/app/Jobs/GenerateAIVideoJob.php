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

class GenerateAIVideoJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected AiGeneratedVideo $video;

    /**
     * Create a new job instance.
     */
    public function __construct(AiGeneratedVideo $video)
    {
        $this->video = $video;
    }

    /**
     * Execute the job.
     */
    public function handle(AIVideoGeneratorService $aiService): void
    {
        try {
            Log::info('Starting AI video generation', ['video_id' => $this->video->id]);

            // Mark as started
            $this->video->markAsStarted();

            // Generate video
            $result = $aiService->generateVideo(
                $this->video->prompt,
                $this->video->provider,
                $this->video->duration,
                $this->video->aspect_ratio,
                $this->video->metadata ?? []
            );

            if ($result['success']) {
                // Save task ID and update status
                $this->video->update([
                    'task_id' => $result['task_id'],
                    'api_response' => $result,
                ]);

                Log::info('Video generation initiated', [
                    'video_id' => $this->video->id,
                    'task_id' => $result['task_id'],
                ]);

                // Dispatch job to check status periodically
                CheckVideoGenerationStatusJob::dispatch($this->video)
                    ->delay(now()->addSeconds($result['estimated_time'] ?? 60));

            } else {
                $this->video->markAsFailed($result['error']);
                Log::error('Video generation failed to start', [
                    'video_id' => $this->video->id,
                    'error' => $result['error'],
                ]);
            }

        } catch (\Exception $e) {
            $this->video->markAsFailed($e->getMessage());
            Log::error('Video generation job failed', [
                'video_id' => $this->video->id,
                'error' => $e->getMessage(),
            ]);

            throw $e;
        }
    }

    /**
     * Handle a job failure.
     */
    public function failed(\Throwable $exception): void
    {
        $this->video->markAsFailed($exception->getMessage());
        
        Log::error('AI Video generation job failed permanently', [
            'video_id' => $this->video->id,
            'error' => $exception->getMessage(),
        ]);
    }
}