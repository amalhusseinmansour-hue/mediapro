<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class ApifyTikTokService
{
    private string $apiToken;
    private string $actorId = 'naqsZgh7DhGajnD5z';
    private string $baseUrl = 'https://api.apify.com/v2';

    public function __construct()
    {
        $this->apiToken = config('services.apify.api_token');
    }

    /**
     * Get TikTok user profile information
     *
     * @param string $username TikTok username
     * @return array|null
     */
    public function getUserProfile(string $username): ?array
    {
        try {
            $input = [
                'profile_username' => $username,
            ];

            return $this->runActor($input);
        } catch (\Exception $e) {
            Log::error('Failed to get TikTok user profile', [
                'username' => $username,
                'error' => $e->getMessage()
            ]);
            return null;
        }
    }

    /**
     * Get TikTok user's posts
     *
     * @param string $userId TikTok user ID
     * @param string $secUserId TikTok secure user ID
     * @param int $count Number of posts to fetch (default: 10)
     * @return array|null
     */
    public function getUserPosts(string $userId = '', string $secUserId = '', int $count = 10): ?array
    {
        try {
            $input = [
                'userPosts_userId' => $userId,
                'userPosts_secUserId' => $secUserId,
                'userPosts_count' => $count,
                'userPosts_maxCursor' => '0',
            ];

            return $this->runActor($input);
        } catch (\Exception $e) {
            Log::error('Failed to get TikTok user posts', [
                'userId' => $userId,
                'error' => $e->getMessage()
            ]);
            return null;
        }
    }

    /**
     * Get TikTok post details
     *
     * @param string $awemeId TikTok post ID (awemeId)
     * @return array|null
     */
    public function getPostDetails(string $awemeId): ?array
    {
        try {
            $input = [
                'post_awemeId' => $awemeId,
            ];

            return $this->runActor($input);
        } catch (\Exception $e) {
            Log::error('Failed to get TikTok post details', [
                'awemeId' => $awemeId,
                'error' => $e->getMessage()
            ]);
            return null;
        }
    }

    /**
     * Get user's followers
     *
     * @param string $userId TikTok user ID
     * @param string $secUserId TikTok secure user ID
     * @param int $count Number of followers to fetch (default: 10)
     * @return array|null
     */
    public function getUserFollowers(string $userId = '', string $secUserId = '', int $count = 10): ?array
    {
        try {
            $input = [
                'followers_userId' => $userId,
                'followers_secUserId' => $secUserId,
                'followers_count' => $count,
                'followers_maxTime' => 0,
            ];

            return $this->runActor($input);
        } catch (\Exception $e) {
            Log::error('Failed to get TikTok followers', [
                'userId' => $userId,
                'error' => $e->getMessage()
            ]);
            return null;
        }
    }

    /**
     * Get user's following
     *
     * @param string $userId TikTok user ID
     * @param string $secUserId TikTok secure user ID
     * @param int $count Number of following to fetch (default: 10)
     * @return array|null
     */
    public function getUserFollowing(string $userId = '', string $secUserId = '', int $count = 10): ?array
    {
        try {
            $input = [
                'following_userId' => $userId,
                'following_secUserId' => $secUserId,
                'following_count' => $count,
                'following_maxTime' => 0,
            ];

            return $this->runActor($input);
        } catch (\Exception $e) {
            Log::error('Failed to get TikTok following', [
                'userId' => $userId,
                'error' => $e->getMessage()
            ]);
            return null;
        }
    }

    /**
     * Search TikTok users
     *
     * @param string $keyword Search keyword
     * @param int $count Number of results (default: 20)
     * @return array|null
     */
    public function searchUsers(string $keyword, int $count = 20): ?array
    {
        try {
            $input = [
                'searchUsers_keyword' => $keyword,
                'searchUsers_count' => $count,
                'searchUsers_cursor' => 0,
            ];

            return $this->runActor($input);
        } catch (\Exception $e) {
            Log::error('Failed to search TikTok users', [
                'keyword' => $keyword,
                'error' => $e->getMessage()
            ]);
            return null;
        }
    }

    /**
     * Search TikTok posts
     *
     * @param string $keyword Search keyword
     * @param int $count Number of results (default: 10)
     * @return array|null
     */
    public function searchPosts(string $keyword, int $count = 10): ?array
    {
        try {
            $input = [
                'searchPosts_keyword' => $keyword,
                'searchPosts_count' => $count,
                'searchPosts_offset' => 0,
                'searchPosts_useFilters' => false,
                'searchPosts_publishTime' => 0,
                'searchPosts_sortType' => 0,
            ];

            return $this->runActor($input);
        } catch (\Exception $e) {
            Log::error('Failed to search TikTok posts', [
                'keyword' => $keyword,
                'error' => $e->getMessage()
            ]);
            return null;
        }
    }

    /**
     * Search TikTok hashtags
     *
     * @param string $keyword Search keyword
     * @param int $count Number of results (default: 20)
     * @return array|null
     */
    public function searchHashtags(string $keyword, int $count = 20): ?array
    {
        try {
            $input = [
                'searchHashtags_keyword' => $keyword,
                'searchHashtags_count' => $count,
                'searchHashtags_cursor' => 0,
            ];

            return $this->runActor($input);
        } catch (\Exception $e) {
            Log::error('Failed to search TikTok hashtags', [
                'keyword' => $keyword,
                'error' => $e->getMessage()
            ]);
            return null;
        }
    }

    /**
     * Get post comments
     *
     * @param string $awemeId TikTok post ID
     * @param int $count Number of comments (default: 10)
     * @return array|null
     */
    public function getPostComments(string $awemeId, int $count = 10): ?array
    {
        try {
            $input = [
                'listComments_awemeId' => $awemeId,
                'listComments_count' => $count,
                'listComments_cursor' => 0,
            ];

            return $this->runActor($input);
        } catch (\Exception $e) {
            Log::error('Failed to get TikTok post comments', [
                'awemeId' => $awemeId,
                'error' => $e->getMessage()
            ]);
            return null;
        }
    }

    /**
     * Get video without watermark
     *
     * @param string $awemeId TikTok post ID
     * @return array|null
     */
    public function getVideoWithoutWatermark(string $awemeId): ?array
    {
        try {
            $input = [
                'videoWithoutWatermark_awemeId' => $awemeId,
            ];

            return $this->runActor($input);
        } catch (\Exception $e) {
            Log::error('Failed to get video without watermark', [
                'awemeId' => $awemeId,
                'error' => $e->getMessage()
            ]);
            return null;
        }
    }

    /**
     * Run the Apify Actor with the given input
     *
     * @param array $input Actor input parameters
     * @return array|null
     */
    private function runActor(array $input): ?array
    {
        try {
            // Start the actor run
            $runResponse = Http::withToken($this->apiToken)
                ->post("{$this->baseUrl}/acts/{$this->actorId}/runs", $input)
                ->json();

            if (!isset($runResponse['data']['id'])) {
                Log::error('Failed to start Apify actor', ['response' => $runResponse]);
                return null;
            }

            $runId = $runResponse['data']['id'];

            // Wait for the run to finish
            $maxAttempts = 30; // Wait up to 5 minutes
            $attempt = 0;

            while ($attempt < $maxAttempts) {
                sleep(10); // Wait 10 seconds between checks

                $statusResponse = Http::withToken($this->apiToken)
                    ->get("{$this->baseUrl}/actor-runs/{$runId}")
                    ->json();

                $status = $statusResponse['data']['status'] ?? null;

                if ($status === 'SUCCEEDED') {
                    // Get the results from the dataset
                    $datasetId = $statusResponse['data']['defaultDatasetId'];

                    $resultsResponse = Http::withToken($this->apiToken)
                        ->get("{$this->baseUrl}/datasets/{$datasetId}/items")
                        ->json();

                    return $resultsResponse;
                }

                if (in_array($status, ['FAILED', 'ABORTED', 'TIMED-OUT'])) {
                    Log::error('Apify actor run failed', [
                        'status' => $status,
                        'runId' => $runId
                    ]);
                    return null;
                }

                $attempt++;
            }

            Log::warning('Apify actor run timeout', ['runId' => $runId]);
            return null;

        } catch (\Exception $e) {
            Log::error('Error running Apify actor', [
                'error' => $e->getMessage(),
                'input' => $input
            ]);
            return null;
        }
    }
}
