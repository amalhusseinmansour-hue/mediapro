<?php

namespace App\Services\SocialMedia;

use App\Models\ScheduledPost;
use App\Models\UserSocialAccount;
use App\Services\SocialMedia\Contracts\SocialPublisherInterface;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class AyrshareAdapter implements SocialPublisherInterface
{
    protected string $apiKey;
    protected string $baseUrl = 'https://app.ayrshare.com/api';

    public function __construct()
    {
        $this->apiKey = config('services.ayrshare.api_key');
    }

    public function getName(): string
    {
        return 'ayrshare';
    }

    public function supportsPlatform(string $platform): bool
    {
        $supported = [
            'facebook',
            'instagram',
            'twitter',
            'linkedin',
            'tiktok',
            'youtube',
            'pinterest',
            'threads',
        ];

        return in_array($platform, $supported);
    }

    public function publish(ScheduledPost $post, array $accounts): array
    {
        try {
            // Build Ayrshare payload
            $payload = $this->buildPayload($post, $accounts);

            // Send request to Ayrshare API
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/json',
            ])->post($this->baseUrl . '/post', $payload);

            $startTime = microtime(true);
            $executionTime = (int) ((microtime(true) - $startTime) * 1000);

            if ($response->successful()) {
                $data = $response->json();

                // Parse platform responses
                $platformResponses = $this->parsePlatformResponses($data, $post->platforms);

                // Handle rate limit headers
                $this->handleRateLimitHeaders($response, $accounts);

                return [
                    'success' => !empty($data['id']),
                    'platform_responses' => $platformResponses,
                    'ayrshare_post_id' => $data['id'] ?? null,
                    'raw_response' => $data,
                    'execution_time_ms' => $executionTime,
                ];
            } else {
                $error = $response->json();

                return [
                    'success' => false,
                    'error' => $error['message'] ?? 'Ayrshare API request failed',
                    'error_details' => $error,
                    'http_status' => $response->status(),
                    'execution_time_ms' => $executionTime,
                ];
            }

        } catch (\Exception $e) {
            Log::error('Ayrshare publish error', [
                'post_id' => $post->id,
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
     * Build Ayrshare API payload
     */
    protected function buildPayload(ScheduledPost $post, array $accounts): array
    {
        $payload = [
            'post' => $post->content,
            'platforms' => $post->platforms ?? array_keys($accounts),
        ];

        // Add title if present (for LinkedIn, YouTube)
        if ($post->title) {
            $payload['title'] = $post->title;
        }

        // Add media URLs
        if (!empty($post->media_urls)) {
            if ($post->media_type === 'video') {
                $payload['videoUrl'] = $post->media_urls[0];
            } elseif ($post->media_type === 'image') {
                $payload['mediaUrls'] = $post->media_urls;
            }
        }

        // Add link
        if ($post->link_url) {
            $payload['shorten_links'] = true;
        }

        // Add platform-specific settings
        if ($post->platform_settings) {
            foreach ($post->platform_settings as $platform => $settings) {
                $payload[$platform] = $settings;
            }
        }

        // Add scheduling (if future post)
        if ($post->scheduled_at && $post->scheduled_at->isFuture()) {
            $payload['scheduleDate'] = $post->scheduled_at->toIso8601String();
        }

        // Profile keys (if using Ayrshare profiles)
        $profileKeys = [];
        foreach ($accounts as $platform => $account) {
            if (isset($account->platform_data['ayrshare_profile_key'])) {
                $profileKeys[] = $account->platform_data['ayrshare_profile_key'];
            }
        }

        if (!empty($profileKeys)) {
            $payload['profileKeys'] = $profileKeys;
        }

        return $payload;
    }

    /**
     * Parse platform-specific responses from Ayrshare
     */
    protected function parsePlatformResponses(array $data, array $platforms): array
    {
        $responses = [];

        foreach ($platforms as $platform) {
            $responses[$platform] = [
                'success' => isset($data['id']),
                'post_id' => $data["{$platform}Id"] ?? null,
                'post_url' => $data["{$platform}Url"] ?? null,
                'error' => $data['errors'][$platform] ?? null,
            ];
        }

        return $responses;
    }

    /**
     * Handle rate limit headers from Ayrshare
     */
    protected function handleRateLimitHeaders($response, array $accounts): void
    {
        $remaining = $response->header('X-RateLimit-Remaining');
        $reset = $response->header('X-RateLimit-Reset');

        if ($remaining !== null) {
            $resetAt = $reset ? now()->addSeconds((int) $reset) : null;

            foreach ($accounts as $account) {
                $account->updateRateLimit((int) $remaining, $resetAt);
            }
        }
    }

    public function validateAccount(UserSocialAccount $account): bool
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->get($this->baseUrl . '/profiles');

            if ($response->successful()) {
                $profiles = $response->json();

                // Check if account exists in Ayrshare profiles
                foreach ($profiles as $profile) {
                    if ($profile['platform'] === $account->platform &&
                        $profile['id'] === $account->platform_user_id) {
                        return true;
                    }
                }
            }

            return false;

        } catch (\Exception $e) {
            Log::error('Ayrshare account validation failed', [
                'account_id' => $account->id,
                'error' => $e->getMessage(),
            ]);

            return false;
        }
    }

    public function refreshToken(UserSocialAccount $account): bool
    {
        // Ayrshare handles token refresh internally
        // Just validate the account is still active
        return $this->validateAccount($account);
    }

    /**
     * Get analytics for a post (helper method)
     */
    public function getPostAnalytics(string $ayrsharePostId): ?array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->get($this->baseUrl . "/analytics/post/{$ayrsharePostId}");

            if ($response->successful()) {
                return $response->json();
            }

            return null;

        } catch (\Exception $e) {
            Log::error('Failed to fetch Ayrshare analytics', [
                'post_id' => $ayrsharePostId,
                'error' => $e->getMessage(),
            ]);

            return null;
        }
    }

    /**
     * Delete a published post
     */
    public function deletePost(string $ayrsharePostId): bool
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->delete($this->baseUrl . "/post/{$ayrsharePostId}");

            return $response->successful();

        } catch (\Exception $e) {
            Log::error('Failed to delete Ayrshare post', [
                'post_id' => $ayrsharePostId,
                'error' => $e->getMessage(),
            ]);

            return false;
        }
    }
}
