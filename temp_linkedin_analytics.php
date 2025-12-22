<?php

namespace App\Services;

use App\Models\SocialAccount;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;

class LinkedInAnalyticsService
{
    private string $apiBaseUrl = 'https://api.linkedin.com/v2';
    private LinkedInService $linkedInService;

    public function __construct(LinkedInService $linkedInService)
    {
        $this->linkedInService = $linkedInService;
    }

    /**
     * Get profile analytics/statistics
     */
    public function getProfileStats(string $accessToken, string $personUrn): array
    {
        try {
            // Get network size (connections count)
            $networkResponse = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'X-Restli-Protocol-Version' => '2.0.0',
            ])->get($this->apiBaseUrl . '/networkSizes/' . urlencode($personUrn) . '?edgeType=CompanyFollowedByMember');

            $networkSize = 0;
            if ($networkResponse->successful()) {
                $networkSize = $networkResponse->json()['firstDegreeSize'] ?? 0;
            }

            return [
                'success' => true,
                'data' => [
                    'connections' => $networkSize,
                ],
            ];
        } catch (\Exception $e) {
            Log::error('LinkedIn profile stats error', ['error' => $e->getMessage()]);
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Get share statistics for a specific post
     */
    public function getShareStats(string $accessToken, string $shareUrn): array
    {
        try {
            $encodedUrn = urlencode($shareUrn);

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'X-Restli-Protocol-Version' => '2.0.0',
            ])->get($this->apiBaseUrl . '/socialActions/' . $encodedUrn);

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'success' => true,
                    'data' => [
                        'likes' => $data['likesSummary']['totalLikes'] ?? 0,
                        'comments' => $data['commentsSummary']['totalFirstLevelComments'] ?? 0,
                        'shares' => $data['sharesSummary']['totalShares'] ?? 0,
                    ],
                ];
            }

            return ['success' => false, 'error' => 'Failed to fetch share stats'];
        } catch (\Exception $e) {
            Log::error('LinkedIn share stats error', ['error' => $e->getMessage()]);
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Get likes for a specific post
     */
    public function getPostLikes(string $accessToken, string $shareUrn, int $count = 100): array
    {
        try {
            $encodedUrn = urlencode($shareUrn);

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'X-Restli-Protocol-Version' => '2.0.0',
            ])->get($this->apiBaseUrl . '/socialActions/' . $encodedUrn . '/likes', [
                'count' => $count,
            ]);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json(),
                ];
            }

            return ['success' => false, 'error' => 'Failed to fetch likes'];
        } catch (\Exception $e) {
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Get comments for a specific post
     */
    public function getPostComments(string $accessToken, string $shareUrn, int $count = 100): array
    {
        try {
            $encodedUrn = urlencode($shareUrn);

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'X-Restli-Protocol-Version' => '2.0.0',
            ])->get($this->apiBaseUrl . '/socialActions/' . $encodedUrn . '/comments', [
                'count' => $count,
            ]);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json(),
                ];
            }

            return ['success' => false, 'error' => 'Failed to fetch comments'];
        } catch (\Exception $e) {
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Get user's posts/shares
     */
    public function getUserPosts(string $accessToken, string $personUrn, int $count = 50): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'X-Restli-Protocol-Version' => '2.0.0',
            ])->get($this->apiBaseUrl . '/ugcPosts', [
                'q' => 'authors',
                'authors' => 'List(' . urlencode($personUrn) . ')',
                'count' => $count,
            ]);

            if ($response->successful()) {
                $posts = $response->json()['elements'] ?? [];

                // Enrich posts with engagement data
                $enrichedPosts = [];
                foreach ($posts as $post) {
                    $postUrn = $post['id'] ?? null;
                    if ($postUrn) {
                        $stats = $this->getShareStats($accessToken, $postUrn);
                        $post['engagement'] = $stats['success'] ? $stats['data'] : null;
                    }
                    $enrichedPosts[] = $post;
                }

                return [
                    'success' => true,
                    'data' => $enrichedPosts,
                    'count' => count($enrichedPosts),
                ];
            }

            return ['success' => false, 'error' => 'Failed to fetch posts'];
        } catch (\Exception $e) {
            Log::error('LinkedIn user posts error', ['error' => $e->getMessage()]);
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Get organization/company page analytics (requires organization admin)
     */
    public function getOrganizationStats(string $accessToken, string $organizationUrn, string $timeRange = 'ALL_TIME'): array
    {
        try {
            $encodedUrn = urlencode($organizationUrn);

            // Get follower statistics
            $followerResponse = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'X-Restli-Protocol-Version' => '2.0.0',
            ])->get($this->apiBaseUrl . '/organizationalEntityFollowerStatistics', [
                'q' => 'organizationalEntity',
                'organizationalEntity' => $organizationUrn,
            ]);

            $followers = 0;
            if ($followerResponse->successful()) {
                $data = $followerResponse->json()['elements'][0] ?? [];
                $followers = $data['followerCounts']['organicFollowerCount'] ?? 0;
            }

            // Get share statistics
            $shareResponse = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'X-Restli-Protocol-Version' => '2.0.0',
            ])->get($this->apiBaseUrl . '/organizationalEntityShareStatistics', [
                'q' => 'organizationalEntity',
                'organizationalEntity' => $organizationUrn,
            ]);

            $shareStats = [];
            if ($shareResponse->successful()) {
                $shareStats = $shareResponse->json()['elements'][0] ?? [];
            }

            return [
                'success' => true,
                'data' => [
                    'followers' => $followers,
                    'total_share_statistics' => $shareStats['totalShareStatistics'] ?? [],
                ],
            ];
        } catch (\Exception $e) {
            Log::error('LinkedIn organization stats error', ['error' => $e->getMessage()]);
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Get page views analytics for organization
     */
    public function getOrganizationPageViews(string $accessToken, string $organizationUrn, string $startDate, string $endDate): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'X-Restli-Protocol-Version' => '2.0.0',
            ])->get($this->apiBaseUrl . '/organizationPageStatistics', [
                'q' => 'organization',
                'organization' => $organizationUrn,
                'timeIntervals.timeGranularityType' => 'DAY',
                'timeIntervals.timeRange.start' => strtotime($startDate) * 1000,
                'timeIntervals.timeRange.end' => strtotime($endDate) * 1000,
            ]);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json(),
                ];
            }

            return ['success' => false, 'error' => 'Failed to fetch page views'];
        } catch (\Exception $e) {
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Get comprehensive analytics for a user account
     */
    public function getAccountAnalytics(SocialAccount $account): array
    {
        $accessToken = $account->access_token;
        $personUrn = 'urn:li:person:' . $account->account_id;

        // Cache key for analytics
        $cacheKey = 'linkedin_analytics_' . $account->id;

        return Cache::remember($cacheKey, now()->addMinutes(15), function () use ($accessToken, $personUrn) {
            $profile = $this->linkedInService->getUserProfile($accessToken);
            $posts = $this->getUserPosts($accessToken, $personUrn, 20);
            $profileStats = $this->getProfileStats($accessToken, $personUrn);

            // Calculate engagement metrics
            $totalLikes = 0;
            $totalComments = 0;
            $totalShares = 0;
            $postCount = 0;

            if ($posts['success'] && !empty($posts['data'])) {
                foreach ($posts['data'] as $post) {
                    if (isset($post['engagement'])) {
                        $totalLikes += $post['engagement']['likes'] ?? 0;
                        $totalComments += $post['engagement']['comments'] ?? 0;
                        $totalShares += $post['engagement']['shares'] ?? 0;
                    }
                    $postCount++;
                }
            }

            $avgEngagement = $postCount > 0 ? round(($totalLikes + $totalComments + $totalShares) / $postCount, 2) : 0;

            return [
                'success' => true,
                'data' => [
                    'profile' => $profile['success'] ? $profile['data'] : null,
                    'connections' => $profileStats['success'] ? $profileStats['data']['connections'] : 0,
                    'posts' => [
                        'count' => $postCount,
                        'recent' => $posts['success'] ? array_slice($posts['data'], 0, 5) : [],
                    ],
                    'engagement' => [
                        'total_likes' => $totalLikes,
                        'total_comments' => $totalComments,
                        'total_shares' => $totalShares,
                        'average_per_post' => $avgEngagement,
                    ],
                    'fetched_at' => now()->toIso8601String(),
                ],
            ];
        });
    }

    /**
     * Clear analytics cache for an account
     */
    public function clearCache(SocialAccount $account): void
    {
        Cache::forget('linkedin_analytics_' . $account->id);
    }

    /**
     * Get trending hashtags (based on user's network)
     */
    public function getTrendingHashtags(string $accessToken): array
    {
        // LinkedIn doesn't have a direct trending hashtags API
        // This would need to be implemented with content analysis
        return [
            'success' => true,
            'data' => [
                'note' => 'LinkedIn API does not provide direct trending hashtags endpoint',
                'suggestions' => [
                    '#Leadership',
                    '#Innovation',
                    '#DigitalTransformation',
                    '#AI',
                    '#Marketing',
                    '#Entrepreneurship',
                    '#Technology',
                    '#Business',
                ],
            ],
        ];
    }

    /**
     * Reply to a comment on a post
     */
    public function replyToComment(string $accessToken, string $shareUrn, string $commentUrn, string $replyText, string $actorUrn): array
    {
        try {
            $encodedShareUrn = urlencode($shareUrn);

            $payload = [
                'actor' => $actorUrn,
                'message' => [
                    'text' => $replyText,
                ],
                'parentComment' => $commentUrn,
            ];

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'Content-Type' => 'application/json',
                'X-Restli-Protocol-Version' => '2.0.0',
            ])->post($this->apiBaseUrl . '/socialActions/' . $encodedShareUrn . '/comments', $payload);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json(),
                ];
            }

            return ['success' => false, 'error' => 'Failed to reply to comment'];
        } catch (\Exception $e) {
            Log::error('LinkedIn reply comment error', ['error' => $e->getMessage()]);
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Like a post
     */
    public function likePost(string $accessToken, string $shareUrn, string $actorUrn): array
    {
        try {
            $encodedShareUrn = urlencode($shareUrn);

            $payload = [
                'actor' => $actorUrn,
            ];

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'Content-Type' => 'application/json',
                'X-Restli-Protocol-Version' => '2.0.0',
            ])->post($this->apiBaseUrl . '/socialActions/' . $encodedShareUrn . '/likes', $payload);

            if ($response->successful() || $response->status() === 201) {
                return ['success' => true];
            }

            return ['success' => false, 'error' => 'Failed to like post'];
        } catch (\Exception $e) {
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Unlike a post
     */
    public function unlikePost(string $accessToken, string $shareUrn, string $actorUrn): array
    {
        try {
            $encodedShareUrn = urlencode($shareUrn);
            $encodedActorUrn = urlencode($actorUrn);

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'X-Restli-Protocol-Version' => '2.0.0',
            ])->delete($this->apiBaseUrl . '/socialActions/' . $encodedShareUrn . '/likes/' . $encodedActorUrn);

            if ($response->successful()) {
                return ['success' => true];
            }

            return ['success' => false, 'error' => 'Failed to unlike post'];
        } catch (\Exception $e) {
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Add a comment to a post
     */
    public function commentOnPost(string $accessToken, string $shareUrn, string $commentText, string $actorUrn): array
    {
        try {
            $encodedShareUrn = urlencode($shareUrn);

            $payload = [
                'actor' => $actorUrn,
                'message' => [
                    'text' => $commentText,
                ],
            ];

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'Content-Type' => 'application/json',
                'X-Restli-Protocol-Version' => '2.0.0',
            ])->post($this->apiBaseUrl . '/socialActions/' . $encodedShareUrn . '/comments', $payload);

            if ($response->successful() || $response->status() === 201) {
                return [
                    'success' => true,
                    'data' => $response->json(),
                ];
            }

            return ['success' => false, 'error' => 'Failed to add comment'];
        } catch (\Exception $e) {
            Log::error('LinkedIn comment error', ['error' => $e->getMessage()]);
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }
}
