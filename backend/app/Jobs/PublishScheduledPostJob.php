<?php

namespace App\Jobs;

use App\Models\ScheduledPost;
use App\Services\WebhookPublisherService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class PublishScheduledPostJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $tries = 3;
    public $timeout = 60;
    public $backoff = [60, 300, 900];

    protected ScheduledPost $post;

    public function __construct(ScheduledPost $post)
    {
        $this->post = $post;
    }

    public function handle(WebhookPublisherService $webhookService): void
    {
        Log::info('Publishing scheduled post', [
            'post_id' => $this->post->id,
            'attempt' => $this->attempts(),
        ]);

        $this->post->markAsProcessing();

        try {
            $result = $webhookService->publish($this->post);

            if ($result['success']) {
                $this->post->markAsSent($result['response'] ?? []);

                Log::info('Post published successfully', [
                    'post_id' => $this->post->id,
                ]);

            } else {
                $errorMessage = $result['error'] ?? 'Unknown error';

                if ($this->post->canRetry() && $this->attempts() < $this->tries) {
                    Log::warning('Post publish failed, will retry', [
                        'post_id' => $this->post->id,
                        'attempt' => $this->attempts(),
                        'error' => $errorMessage,
                    ]);

                    $this->post->update(['status' => 'pending']);
                    throw new \Exception($errorMessage);

                } else {
                    $this->post->markAsFailed($errorMessage, $result);

                    Log::error('Post publish failed permanently', [
                        'post_id' => $this->post->id,
                        'error' => $errorMessage,
                    ]);
                }
            }

        } catch (\Exception $e) {
            Log::error('Exception during post publish', [
                'post_id' => $this->post->id,
                'error' => $e->getMessage(),
            ]);

            if ($this->attempts() >= $this->tries) {
                $this->fail($e);
            } else {
                $this->post->update(['status' => 'pending']);
                throw $e;
            }
        }
    }

    public function failed(\Throwable $exception): void
    {
        Log::error('Job failed permanently', [
            'post_id' => $this->post->id,
            'error' => $exception->getMessage(),
        ]);

        $this->post->markAsFailed(
            'Job failed after ' . $this->tries . ' attempts: ' . $exception->getMessage()
        );
    }
}
