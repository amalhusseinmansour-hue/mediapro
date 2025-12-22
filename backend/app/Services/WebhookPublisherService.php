<?php

namespace App\Services;

use App\Models\ScheduledPost;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class WebhookPublisherService
{
    protected string $webhookUrl;
    protected int $timeout = 30;
    protected int $maxRetries = 3;

    public function __construct()
    {
        $this->webhookUrl = config('services.pabbly.webhook_url');
    }

    public function publish(ScheduledPost $post): array
    {
        if (!$this->webhookUrl) {
            throw new \Exception('Webhook URL not configured');
        }

        $payload = $this->buildPayload($post);

        Log::info('Sending webhook to Pabbly', [
            'post_id' => $post->id,
            'webhook_url' => $this->webhookUrl,
        ]);

        try {
            $response = Http::timeout($this->timeout)
                ->retry($this->maxRetries, 100)
                ->post($this->webhookUrl, $payload);

            if ($response->successful()) {
                Log::info('Webhook sent successfully', [
                    'post_id' => $post->id,
                    'status' => $response->status(),
                ]);

                return [
                    'success' => true,
                    'status_code' => $response->status(),
                    'response' => $response->json(),
                ];
            } else {
                $errorMessage = "Webhook failed with status {$response->status()}";

                Log::error('Webhook failed', [
                    'post_id' => $post->id,
                    'status' => $response->status(),
                    'response' => $response->body(),
                ]);

                return [
                    'success' => false,
                    'error' => $errorMessage,
                    'status_code' => $response->status(),
                    'response' => $response->body(),
                ];
            }

        } catch (\Illuminate\Http\Client\ConnectionException $e) {
            Log::error('Webhook connection error', [
                'post_id' => $post->id,
                'error' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'error' => 'Connection error: ' . $e->getMessage(),
            ];

        } catch (\Exception $e) {
            Log::error('Webhook exception', [
                'post_id' => $post->id,
                'error' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    protected function buildPayload(ScheduledPost $post): array
    {
        return [
            'text' => $post->content_text,
            'media' => $post->media_urls ?? [],
            'platforms' => $post->platforms,
            'scheduled_at' => $post->scheduled_at->toIso8601String(),
            'user_name' => $post->user->name ?? '',
            'user_id' => $post->user_id,
            'post_id' => $post->id,
            'timestamp' => now()->toIso8601String(),
        ];
    }

    public function testWebhook(): array
    {
        if (!$this->webhookUrl) {
            return [
                'success' => false,
                'error' => 'Webhook URL not configured',
            ];
        }

        try {
            $response = Http::timeout($this->timeout)
                ->post($this->webhookUrl, [
                    'test' => true,
                    'message' => 'Test webhook from Laravel',
                    'timestamp' => now()->toIso8601String(),
                ]);

            return [
                'success' => $response->successful(),
                'status_code' => $response->status(),
                'response' => $response->json(),
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    public function setWebhookUrl(string $url): self
    {
        $this->webhookUrl = $url;
        return $this;
    }
}
