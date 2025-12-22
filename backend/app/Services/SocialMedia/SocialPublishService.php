<?php

namespace App\Services\SocialMedia;

use App\Models\ScheduledPost;
use App\Models\UserSocialAccount;
use App\Models\PostLog;
use App\Services\SocialMedia\Contracts\SocialPublisherInterface;
use Illuminate\Support\Facades\Log;

class SocialPublishService
{
    protected array $publishers = [];
    protected string $defaultPublisher = 'ayrshare';

    public function __construct()
    {
        $this->registerPublishers();
    }

    /**
     * Register available publishers
     */
    protected function registerPublishers(): void
    {
        // Register publishers based on configuration
        if (config('services.ayrshare.enabled', true)) {
            $this->publishers['ayrshare'] = app(AyrshareAdapter::class);
        }

        if (config('services.postsyncer.enabled', false)) {
            $this->publishers['postsyncer'] = app(PostSyncerAdapter::class);
        }

        if (config('services.webhook.enabled', true)) {
            $this->publishers['webhook'] = app(WebhookAdapter::class);
        }

        // Manual fallback always available
        $this->publishers['manual'] = app(ManualPublisher::class);
    }

    /**
     * Publish a scheduled post
     */
    public function publishPost(ScheduledPost $post, ?string $preferredMethod = null): array
    {
        $startTime = microtime(true);
        $post->markAsPublishing();

        try {
            // Get publisher method
            $method = $preferredMethod ?? $this->defaultPublisher;
            $publisher = $this->getPublisher($method);

            if (!$publisher) {
                throw new \Exception("Publisher '{$method}' not available");
            }

            // Get user's social accounts for the target platforms
            $accounts = $this->getAccountsForPost($post);

            if (empty($accounts)) {
                throw new \Exception('No active social accounts found for the target platforms');
            }

            // Publish using the selected method
            $result = $publisher->publish($post, $accounts);

            // Calculate execution time
            $executionTime = (int) ((microtime(true) - $startTime) * 1000);

            // Process results
            if ($result['success']) {
                $post->markAsPublished($result['platform_responses'] ?? []);

                // Log success for each platform
                foreach ($result['platform_responses'] ?? [] as $platform => $response) {
                    $account = $accounts[$platform] ?? null;
                    $log = PostLog::logPublishAttempt($post, $platform, $account, $method);
                    $log->logSuccess(
                        $response,
                        $response['post_id'] ?? null,
                        $response['post_url'] ?? null,
                        $executionTime
                    );
                }
            } else {
                // Check if partially published
                $successCount = count(array_filter(
                    $result['platform_responses'] ?? [],
                    fn($r) => $r['success'] ?? false
                ));

                if ($successCount > 0) {
                    $post->markAsPartiallyPublished(
                        $result['platform_responses'] ?? [],
                        $result['error'] ?? 'Some platforms failed'
                    );
                } else {
                    $post->markAsFailed($result['error'] ?? 'Unknown error', $result);
                }

                // Log failures
                foreach ($result['platform_responses'] ?? [] as $platform => $response) {
                    if (!($response['success'] ?? false)) {
                        $account = $accounts[$platform] ?? null;
                        $log = PostLog::logPublishAttempt($post, $platform, $account, $method);
                        $log->logFailure(
                            $response['error'] ?? 'Unknown error',
                            $response,
                            $response['http_status'] ?? null,
                            $executionTime
                        );
                    }
                }
            }

            return $result;

        } catch (\Exception $e) {
            $executionTime = (int) ((microtime(true) - $startTime) * 1000);

            Log::error('Failed to publish post', [
                'post_id' => $post->id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            $post->markAsFailed($e->getMessage(), [
                'exception' => get_class($e),
                'trace' => $e->getTraceAsString(),
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
                'execution_time_ms' => $executionTime,
            ];
        }
    }

    /**
     * Get publisher by name
     */
    protected function getPublisher(string $name): ?SocialPublisherInterface
    {
        return $this->publishers[$name] ?? null;
    }

    /**
     * Get active social accounts for the post
     */
    protected function getAccountsForPost(ScheduledPost $post): array
    {
        $query = UserSocialAccount::where('user_id', $post->user_id)
            ->active()
            ->whereIn('platform', $post->platforms ?? []);

        // If specific account IDs are specified, filter by them
        if (!empty($post->account_ids)) {
            $query->whereIn('id', $post->account_ids);
        }

        $accounts = $query->get();

        // Return as associative array keyed by platform
        $result = [];
        foreach ($accounts as $account) {
            // Only include if not rate limited
            if (!$account->isRateLimited()) {
                $result[$account->platform] = $account;
            }
        }

        return $result;
    }

    /**
     * Refresh token for an account
     */
    public function refreshAccountToken(UserSocialAccount $account): bool
    {
        $publisher = $this->getPublisher($this->defaultPublisher);

        if (!$publisher) {
            return false;
        }

        try {
            $success = $publisher->refreshToken($account);

            if ($success) {
                $account->update([
                    'last_token_refresh_at' => now(),
                    'status' => 'active',
                    'failed_attempts' => 0,
                ]);

                PostLog::create([
                    'user_id' => $account->user_id,
                    'platform' => $account->platform,
                    'social_account_id' => $account->id,
                    'action' => 'token_refresh',
                    'status' => 'success',
                    'publish_method' => $this->defaultPublisher,
                ]);
            } else {
                $account->update([
                    'status' => 'token_expired',
                ]);

                PostLog::create([
                    'user_id' => $account->user_id,
                    'platform' => $account->platform,
                    'social_account_id' => $account->id,
                    'action' => 'token_refresh_failed',
                    'status' => 'failed',
                    'error_message' => 'Failed to refresh token',
                    'publish_method' => $this->defaultPublisher,
                ]);
            }

            return $success;

        } catch (\Exception $e) {
            Log::error('Token refresh failed', [
                'account_id' => $account->id,
                'platform' => $account->platform,
                'error' => $e->getMessage(),
            ]);

            return false;
        }
    }

    /**
     * Get available publishers
     */
    public function getAvailablePublishers(): array
    {
        return array_keys($this->publishers);
    }

    /**
     * Check if a publisher is available
     */
    public function hasPublisher(string $name): bool
    {
        return isset($this->publishers[$name]);
    }
}
