<?php

namespace App\Services\SocialMedia;

use App\Models\ScheduledPost;
use App\Models\UserSocialAccount;
use App\Services\SocialMedia\Contracts\SocialPublisherInterface;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class WebhookAdapter implements SocialPublisherInterface
{
    protected ?string $webhookUrl;
    protected int $timeout = 30;

    public function __construct()
    {
        $this->webhookUrl = config('services.webhook.url');
    }

    public function getName(): string
    {
        return 'webhook';
    }

    public function supportsPlatform(string $platform): bool
    {
        // Webhook can support any platform
        // The external service (Pabbly/Zapier) handles the actual publishing
        return true;
    }

    public function publish(ScheduledPost $post, array $accounts): array
    {
        if (!$this->webhookUrl) {
            return [
                'success' => false,
                'error' => 'Webhook URL not configured',
            ];
        }

        try {
            $startTime = microtime(true);

            // Build webhook payload
            $payload = $this->buildPayload($post, $accounts);

            // Send webhook request
            $response = Http::timeout($this->timeout)
                ->post($this->webhookUrl, $payload);

            $executionTime = (int) ((microtime(true) - $startTime) * 1000);

            if ($response->successful()) {
                $data = $response->json();

                // Build platform responses
                $platformResponses = [];
                foreach ($post->platforms as $platform) {
                    $platformResponses[$platform] = [
                        'success' => true,
                        'webhook_response' => $data,
                        'post_id' => $data['post_id'] ?? null,
                        'post_url' => $data['post_url'] ?? null,
                    ];
                }

                return [
                    'success' => true,
                    'platform_responses' => $platformResponses,
                    'webhook_response' => $data,
                    'execution_time_ms' => $executionTime,
                ];
            } else {
                return [
                    'success' => false,
                    'error' => 'Webhook request failed: ' . $response->status(),
                    'http_status' => $response->status(),
                    'response_body' => $response->body(),
                    'execution_time_ms' => $executionTime,
                ];
            }

        } catch (\Exception $e) {
            Log::error('Webhook publish error', [
                'post_id' => $post->id,
                'webhook_url' => $this->webhookUrl,
                'error' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
                'exception' => get_class($e),
            ];
        }
    }

    /**
     * Build webhook payload
     */
    protected function buildPayload(ScheduledPost $post, array $accounts): array
    {
        $accountsData = [];
        foreach ($accounts as $platform => $account) {
            $accountsData[$platform] = [
                'id' => $account->id,
                'platform_user_id' => $account->platform_user_id,
                'username' => $account->username,
                'access_token' => $account->access_token, // Be careful with token exposure!
            ];
        }

        return [
            'event' => 'social_post_publish',
            'post_id' => $post->id,
            'user_id' => $post->user_id,
            'content' => $post->content,
            'title' => $post->title,
            'media_urls' => $post->media_urls,
            'media_type' => $post->media_type,
            'link' => [
                'url' => $post->link_url,
                'title' => $post->link_title,
                'description' => $post->link_description,
                'image' => $post->link_image_url,
            ],
            'platforms' => $post->platforms,
            'platform_settings' => $post->platform_settings,
            'scheduled_at' => $post->scheduled_at?->toIso8601String(),
            'accounts' => $accountsData,
            'metadata' => [
                'attempt' => $post->attempts,
                'created_at' => $post->created_at->toIso8601String(),
            ],
        ];
    }

    public function validateAccount(UserSocialAccount $account): bool
    {
        // Webhook doesn't validate accounts directly
        // This would be handled by the external service
        return true;
    }

    public function refreshToken(UserSocialAccount $account): bool
    {
        // Webhook doesn't handle token refresh
        // This would be handled by the external service
        Log::warning('Token refresh not supported by webhook adapter', [
            'account_id' => $account->id,
        ]);

        return false;
    }

    /**
     * Set custom webhook URL (useful for testing or per-user webhooks)
     */
    public function setWebhookUrl(string $url): self
    {
        $this->webhookUrl = $url;
        return $this;
    }

    /**
     * Send a test webhook
     */
    public function sendTestWebhook(int $userId): array
    {
        if (!$this->webhookUrl) {
            return [
                'success' => false,
                'error' => 'Webhook URL not configured',
            ];
        }

        try {
            $response = Http::timeout($this->timeout)->post($this->webhookUrl, [
                'event' => 'test',
                'user_id' => $userId,
                'timestamp' => now()->toIso8601String(),
                'message' => 'This is a test webhook from Social Media Manager',
            ]);

            return [
                'success' => $response->successful(),
                'status' => $response->status(),
                'response' => $response->json(),
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }
}
