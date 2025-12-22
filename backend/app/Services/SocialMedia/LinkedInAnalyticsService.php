<?php

namespace App\Services\SocialMedia;

use App\Models\ConnectedAccount;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;

class LinkedInAnalyticsService
{
    protected string $apiUrl = 'https://api.linkedin.com/v2';
    protected string $restApiUrl = 'https://api.linkedin.com/rest';

    /**
     * Get user profile with statistics
     */
    public function getProfileStats(ConnectedAccount $account): array
    {
        try {
            $accessToken = decrypt($account->access_token);
            $cacheKey = "linkedin_profile_{$account->id}";

            return Cache::remember($cacheKey, 3600, function () use ($accessToken) {
                // Get basic profile
                $profileResponse = Http::withToken($accessToken)
                    ->withHeaders(['LinkedIn-Version' => '202401'])
                    ->get("{$this->apiUrl}/userinfo");

                if (!$profileResponse->successful()) {
                    // Fallback to /me endpoint
                    $profileResponse = Http::withToken($accessToken)
                        ->get("{$this->apiUrl}/me", [
                            'projection' => '(id,firstName,lastName,profilePicture(displayImage~:playableStreams),vanityName)'
                        ]);
                }

                if (!$profileResponse->successful()) {
                    throw new \Exception('Failed to fetch profile');
                }

                $profile = $profileResponse->json();

                // Get network size (connections count)
                $networkResponse = Http::withToken($accessToken)
                    ->get("{$this->apiUrl}/networkSizes/urn:li:person:{$profile['sub'] ?? $profile['id']}?edgeType=CompanyFollowedByMember");

                $networkSize = $networkResponse->successful() ? $networkResponse->json() : null;

                return [
                    'success' => true,
                    'profile' => [
                        'id' => $profile['sub'] ?? $profile['id'] ?? null,
                        'name' => $profile['name'] ?? ($profile['firstName']['localized']['en_US'] ?? '') . ' ' . ($profile['lastName']['localized']['en_US'] ?? ''),
                        'email' => $profile['email'] ?? null,
                        'picture' => $profile['picture'] ?? null,
                        'vanity_name' => $profile['vanityName'] ?? null,
                    ],
                    'network' => [
                        'connections' => $networkSize['firstDegreeSize'] ?? 0,
                        'followers' => $networkSize['followersCount'] ?? 0,
                    ],
                ];
            });

        } catch (\Exception $e) {
            Log::error('LinkedIn getProfileStats error: ' . $e->getMessage());
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Get posts analytics
     */
    public function getPostsAnalytics(ConnectedAccount $account, int $count = 10): array
    {
        try {
            $accessToken = decrypt($account->access_token);
            $userUrn = $this->getUserUrn($accessToken);

            if (!$userUrn) {
                return ['success' => false, 'error' => 'Failed to get user URN'];
            }

            $authorUrn = "urn:li:person:{$userUrn}";

            // Get user's posts (UGC posts)
            $postsResponse = Http::withToken($accessToken)
                ->withHeaders(['X-Restli-Protocol-Version' => '2.0.0'])
                ->get("{$this->apiUrl}/ugcPosts", [
                    'q' => 'authors',
                    'authors' => "List({$authorUrn})",
                    'count' => $count,
                    'sortBy' => 'LAST_MODIFIED',
                ]);

            if (!$postsResponse->successful()) {
                // Try shares endpoint as fallback
                $postsResponse = Http::withToken($accessToken)
                    ->withHeaders(['X-Restli-Protocol-Version' => '2.0.0'])
                    ->get("{$this->apiUrl}/shares", [
                        'q' => 'owners',
                        'owners' => $authorUrn,
                        'count' => $count,
                    ]);
            }

            $posts = $postsResponse->json()['elements'] ?? [];

            // Get analytics for each post
            $postsWithAnalytics = [];
            foreach ($posts as $post) {
                $postUrn = $post['id'] ?? $post['activity'] ?? null;
                if ($postUrn) {
                    $analytics = $this->getPostAnalytics($accessToken, $postUrn);
                    $postsWithAnalytics[] = [
                        'post' => $post,
                        'analytics' => $analytics,
                    ];
                }
            }

            return [
                'success' => true,
                'posts' => $postsWithAnalytics,
                'total_posts' => count($postsWithAnalytics),
            ];

        } catch (\Exception $e) {
            Log::error('LinkedIn getPostsAnalytics error: ' . $e->getMessage());
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Get analytics for a single post
     */
    public function getPostAnalytics(string $accessToken, string $postUrn): array
    {
        try {
            // Get social actions (likes, comments, shares)
            $socialActionsResponse = Http::withToken($accessToken)
                ->withHeaders(['X-Restli-Protocol-Version' => '2.0.0'])
                ->get("{$this->apiUrl}/socialActions/{$postUrn}");

            $socialActions = $socialActionsResponse->json() ?? [];

            // Get share statistics
            $shareStatsResponse = Http::withToken($accessToken)
                ->withHeaders(['X-Restli-Protocol-Version' => '2.0.0'])
                ->get("{$this->apiUrl}/organizationalEntityShareStatistics", [
                    'q' => 'organizationalEntity',
                    'organizationalEntity' => $postUrn,
                ]);

            $shareStats = $shareStatsResponse->json()['elements'][0] ?? [];

            return [
                'likes' => $socialActions['likesSummary']['totalLikes'] ?? 0,
                'comments' => $socialActions['commentsSummary']['totalFirstLevelComments'] ?? 0,
                'shares' => $shareStats['totalShareStatistics']['shareCount'] ?? 0,
                'impressions' => $shareStats['totalShareStatistics']['impressionCount'] ?? 0,
                'clicks' => $shareStats['totalShareStatistics']['clickCount'] ?? 0,
                'engagement' => $shareStats['totalShareStatistics']['engagement'] ?? 0,
                'unique_impressions' => $shareStats['totalShareStatistics']['uniqueImpressionsCount'] ?? 0,
            ];

        } catch (\Exception $e) {
            Log::error('LinkedIn getPostAnalytics error: ' . $e->getMessage());
            return [
                'likes' => 0,
                'comments' => 0,
                'shares' => 0,
                'impressions' => 0,
                'clicks' => 0,
                'engagement' => 0,
            ];
        }
    }

    /**
     * Get follower statistics over time
     */
    public function getFollowerStats(ConnectedAccount $account, string $timeRange = 'month'): array
    {
        try {
            $accessToken = decrypt($account->access_token);
            $userUrn = $this->getUserUrn($accessToken);

            if (!$userUrn) {
                return ['success' => false, 'error' => 'Failed to get user URN'];
            }

            // Calculate date range
            $endDate = now();
            $startDate = match($timeRange) {
                'week' => now()->subWeek(),
                'month' => now()->subMonth(),
                'quarter' => now()->subMonths(3),
                'year' => now()->subYear(),
                default => now()->subMonth(),
            };

            // Note: LinkedIn follower statistics API is mainly for organization pages
            // For personal profiles, we return current follower count
            $networkResponse = Http::withToken($accessToken)
                ->get("{$this->apiUrl}/networkSizes/urn:li:person:{$userUrn}?edgeType=CompanyFollowedByMember");

            $currentFollowers = 0;
            if ($networkResponse->successful()) {
                $data = $networkResponse->json();
                $currentFollowers = $data['firstDegreeSize'] ?? $data['followersCount'] ?? 0;
            }

            return [
                'success' => true,
                'current_followers' => $currentFollowers,
                'time_range' => $timeRange,
                'start_date' => $startDate->toDateString(),
                'end_date' => $endDate->toDateString(),
                'note' => 'Detailed follower history is available for LinkedIn Pages only',
            ];

        } catch (\Exception $e) {
            Log::error('LinkedIn getFollowerStats error: ' . $e->getMessage());
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Get engagement summary
     */
    public function getEngagementSummary(ConnectedAccount $account, int $postsCount = 20): array
    {
        try {
            $postsData = $this->getPostsAnalytics($account, $postsCount);

            if (!$postsData['success']) {
                return $postsData;
            }

            $totalLikes = 0;
            $totalComments = 0;
            $totalShares = 0;
            $totalImpressions = 0;
            $totalClicks = 0;

            foreach ($postsData['posts'] as $post) {
                $analytics = $post['analytics'];
                $totalLikes += $analytics['likes'] ?? 0;
                $totalComments += $analytics['comments'] ?? 0;
                $totalShares += $analytics['shares'] ?? 0;
                $totalImpressions += $analytics['impressions'] ?? 0;
                $totalClicks += $analytics['clicks'] ?? 0;
            }

            $postsCount = count($postsData['posts']);
            $totalEngagement = $totalLikes + $totalComments + $totalShares;
            $engagementRate = $totalImpressions > 0
                ? round(($totalEngagement / $totalImpressions) * 100, 2)
                : 0;

            return [
                'success' => true,
                'summary' => [
                    'total_posts' => $postsCount,
                    'total_likes' => $totalLikes,
                    'total_comments' => $totalComments,
                    'total_shares' => $totalShares,
                    'total_impressions' => $totalImpressions,
                    'total_clicks' => $totalClicks,
                    'total_engagement' => $totalEngagement,
                    'engagement_rate' => $engagementRate,
                    'avg_likes_per_post' => $postsCount > 0 ? round($totalLikes / $postsCount, 1) : 0,
                    'avg_comments_per_post' => $postsCount > 0 ? round($totalComments / $postsCount, 1) : 0,
                    'avg_shares_per_post' => $postsCount > 0 ? round($totalShares / $postsCount, 1) : 0,
                ],
            ];

        } catch (\Exception $e) {
            Log::error('LinkedIn getEngagementSummary error: ' . $e->getMessage());
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Get complete analytics dashboard data
     */
    public function getDashboardAnalytics(ConnectedAccount $account): array
    {
        try {
            $profile = $this->getProfileStats($account);
            $engagement = $this->getEngagementSummary($account);
            $followers = $this->getFollowerStats($account);
            $recentPosts = $this->getPostsAnalytics($account, 5);

            return [
                'success' => true,
                'dashboard' => [
                    'profile' => $profile['profile'] ?? null,
                    'network' => $profile['network'] ?? null,
                    'engagement_summary' => $engagement['summary'] ?? null,
                    'follower_stats' => $followers,
                    'recent_posts' => $recentPosts['posts'] ?? [],
                ],
                'updated_at' => now()->toISOString(),
            ];

        } catch (\Exception $e) {
            Log::error('LinkedIn getDashboardAnalytics error: ' . $e->getMessage());
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Get user URN from access token
     */
    protected function getUserUrn(string $accessToken): ?string
    {
        try {
            $response = Http::withToken($accessToken)
                ->withHeaders(['LinkedIn-Version' => '202401'])
                ->get("{$this->apiUrl}/userinfo");

            if ($response->successful()) {
                return $response->json()['sub'] ?? null;
            }

            // Fallback to /me
            $response = Http::withToken($accessToken)->get("{$this->apiUrl}/me");
            if ($response->successful()) {
                return $response->json()['id'] ?? null;
            }

            return null;
        } catch (\Exception $e) {
            Log::error('LinkedIn getUserUrn error: ' . $e->getMessage());
            return null;
        }
    }
}
