<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;

class InstagramService
{
    private ?string $appId;
    private ?string $appSecret;
    private string $redirectUri;
    private string $graphVersion = 'v18.0';
    private string $baseUrl = 'https://graph.facebook.com';

    public function __construct()
    {
        $this->appId = config('services.instagram.client_id') ?? config('services.facebook.client_id') ?? env('FACEBOOK_APP_ID') ?? env('INSTAGRAM_CLIENT_ID');
        $this->appSecret = config('services.instagram.client_secret') ?? config('services.facebook.client_secret') ?? env('FACEBOOK_APP_SECRET') ?? env('INSTAGRAM_CLIENT_SECRET');
        $this->redirectUri = config('services.instagram.redirect') ?? env('APP_URL') . '/api/instagram/callback';
    }

    /**
     * Check if Instagram API is configured
     */
    public function isConfigured(): bool
    {
        return !empty($this->appId) && !empty($this->appSecret);
    }

    /**
     * Get OAuth authorization URL for Instagram Business (via Facebook)
     */
    public function getAuthorizationUrl(string $state): string
    {
        // Instagram Business accounts require Facebook Login
        $scopes = [
            'instagram_basic',
            'instagram_content_publish',
            'instagram_manage_comments',
            'instagram_manage_insights',
            'pages_show_list',
            'pages_read_engagement',
            'business_management',
        ];

        $params = [
            'client_id' => $this->appId,
            'redirect_uri' => $this->redirectUri,
            'scope' => implode(',', $scopes),
            'response_type' => 'code',
            'state' => $state,
        ];

        return 'https://www.facebook.com/' . $this->graphVersion . '/dialog/oauth?' . http_build_query($params);
    }

    /**
     * Exchange authorization code for access token
     */
    public function exchangeCodeForToken(string $code, string $state): array
    {
        try {
            $response = Http::get($this->baseUrl . '/' . $this->graphVersion . '/oauth/access_token', [
                'client_id' => $this->appId,
                'client_secret' => $this->appSecret,
                'redirect_uri' => $this->redirectUri,
                'code' => $code,
            ]);

            if ($response->successful()) {
                $data = $response->json();

                // Get long-lived token
                $longLivedToken = $this->getLongLivedToken($data['access_token']);

                return [
                    'access_token' => $longLivedToken['access_token'] ?? $data['access_token'],
                    'token_type' => $data['token_type'] ?? 'bearer',
                    'expires_in' => $longLivedToken['expires_in'] ?? $data['expires_in'] ?? 5184000, // 60 days
                ];
            }

            Log::error('Instagram token exchange failed', ['response' => $response->json()]);
            throw new \Exception($response->json()['error']['message'] ?? 'Failed to exchange code for token');
        } catch (\Exception $e) {
            Log::error('Instagram token exchange error', ['error' => $e->getMessage()]);
            throw $e;
        }
    }

    /**
     * Get long-lived access token (valid for 60 days)
     */
    public function getLongLivedToken(string $shortLivedToken): array
    {
        try {
            $response = Http::get($this->baseUrl . '/' . $this->graphVersion . '/oauth/access_token', [
                'grant_type' => 'fb_exchange_token',
                'client_id' => $this->appId,
                'client_secret' => $this->appSecret,
                'fb_exchange_token' => $shortLivedToken,
            ]);

            if ($response->successful()) {
                return $response->json();
            }

            return ['access_token' => $shortLivedToken];
        } catch (\Exception $e) {
            Log::warning('Failed to get long-lived token', ['error' => $e->getMessage()]);
            return ['access_token' => $shortLivedToken];
        }
    }

    /**
     * Get Instagram Business Accounts linked to Facebook Pages
     */
    public function getInstagramAccounts(string $accessToken): array
    {
        try {
            // First get Facebook Pages
            $response = Http::get($this->baseUrl . '/' . $this->graphVersion . '/me/accounts', [
                'access_token' => $accessToken,
                'fields' => 'id,name,access_token,instagram_business_account{id,username,name,profile_picture_url,followers_count,follows_count,media_count}',
            ]);

            if (!$response->successful()) {
                throw new \Exception($response->json()['error']['message'] ?? 'Failed to get accounts');
            }

            $pages = $response->json()['data'] ?? [];
            $instagramAccounts = [];

            foreach ($pages as $page) {
                if (isset($page['instagram_business_account'])) {
                    $igAccount = $page['instagram_business_account'];
                    $instagramAccounts[] = [
                        'id' => $igAccount['id'],
                        'username' => $igAccount['username'] ?? '',
                        'name' => $igAccount['name'] ?? $igAccount['username'] ?? '',
                        'profile_picture_url' => $igAccount['profile_picture_url'] ?? '',
                        'followers_count' => $igAccount['followers_count'] ?? 0,
                        'follows_count' => $igAccount['follows_count'] ?? 0,
                        'media_count' => $igAccount['media_count'] ?? 0,
                        'page_id' => $page['id'],
                        'page_name' => $page['name'],
                        'page_access_token' => $page['access_token'],
                    ];
                }
            }

            return $instagramAccounts;
        } catch (\Exception $e) {
            Log::error('Failed to get Instagram accounts', ['error' => $e->getMessage()]);
            throw $e;
        }
    }

    /**
     * Get Instagram account info
     */
    public function getAccountInfo(string $accessToken, string $igUserId): array
    {
        try {
            $response = Http::get($this->baseUrl . '/' . $this->graphVersion . '/' . $igUserId, [
                'access_token' => $accessToken,
                'fields' => 'id,username,name,profile_picture_url,biography,followers_count,follows_count,media_count,website',
            ]);

            if ($response->successful()) {
                return $response->json();
            }

            throw new \Exception($response->json()['error']['message'] ?? 'Failed to get account info');
        } catch (\Exception $e) {
            Log::error('Instagram get account info error', ['error' => $e->getMessage()]);
            throw $e;
        }
    }

    /**
     * Get account insights/analytics
     */
    public function getAccountInsights(string $accessToken, string $igUserId, string $period = 'day', int $days = 30): array
    {
        try {
            $metrics = [
                'impressions',
                'reach',
                'profile_views',
                'follower_count',
            ];

            $response = Http::get($this->baseUrl . '/' . $this->graphVersion . '/' . $igUserId . '/insights', [
                'access_token' => $accessToken,
                'metric' => implode(',', $metrics),
                'period' => $period,
            ]);

            if (!$response->successful()) {
                // Try with lifetime metrics
                $response = Http::get($this->baseUrl . '/' . $this->graphVersion . '/' . $igUserId . '/insights', [
                    'access_token' => $accessToken,
                    'metric' => 'follower_count',
                    'period' => 'lifetime',
                ]);
            }

            $insights = $response->json()['data'] ?? [];

            // Get account info for additional stats
            $accountInfo = $this->getAccountInfo($accessToken, $igUserId);

            return [
                'account' => $accountInfo,
                'insights' => $insights,
                'summary' => [
                    'followers' => $accountInfo['followers_count'] ?? 0,
                    'following' => $accountInfo['follows_count'] ?? 0,
                    'posts' => $accountInfo['media_count'] ?? 0,
                ],
            ];
        } catch (\Exception $e) {
            Log::error('Instagram insights error', ['error' => $e->getMessage()]);
            throw $e;
        }
    }

    /**
     * Get user's media/posts
     */
    public function getMedia(string $accessToken, string $igUserId, int $limit = 25, ?string $after = null): array
    {
        try {
            $params = [
                'access_token' => $accessToken,
                'fields' => 'id,caption,media_type,media_url,thumbnail_url,permalink,timestamp,like_count,comments_count,insights.metric(impressions,reach,engagement)',
                'limit' => $limit,
            ];

            if ($after) {
                $params['after'] = $after;
            }

            $response = Http::get($this->baseUrl . '/' . $this->graphVersion . '/' . $igUserId . '/media', $params);

            if ($response->successful()) {
                return $response->json();
            }

            throw new \Exception($response->json()['error']['message'] ?? 'Failed to get media');
        } catch (\Exception $e) {
            Log::error('Instagram get media error', ['error' => $e->getMessage()]);
            throw $e;
        }
    }

    /**
     * Create a media container (first step for publishing)
     */
    public function createMediaContainer(string $accessToken, string $igUserId, array $data): array
    {
        try {
            $params = [
                'access_token' => $accessToken,
            ];

            if (isset($data['image_url'])) {
                // Image post
                $params['image_url'] = $data['image_url'];
                if (isset($data['caption'])) {
                    $params['caption'] = $data['caption'];
                }
            } elseif (isset($data['video_url'])) {
                // Video/Reel post
                $params['video_url'] = $data['video_url'];
                $params['media_type'] = $data['media_type'] ?? 'REELS';
                if (isset($data['caption'])) {
                    $params['caption'] = $data['caption'];
                }
                if (isset($data['cover_url'])) {
                    $params['cover_url'] = $data['cover_url'];
                }
                if (isset($data['share_to_feed'])) {
                    $params['share_to_feed'] = $data['share_to_feed'];
                }
            } elseif (isset($data['children'])) {
                // Carousel post
                $params['media_type'] = 'CAROUSEL';
                $params['children'] = $data['children'];
                if (isset($data['caption'])) {
                    $params['caption'] = $data['caption'];
                }
            }

            $response = Http::post($this->baseUrl . '/' . $this->graphVersion . '/' . $igUserId . '/media', $params);

            if ($response->successful()) {
                return $response->json();
            }

            throw new \Exception($response->json()['error']['message'] ?? 'Failed to create media container');
        } catch (\Exception $e) {
            Log::error('Instagram create container error', ['error' => $e->getMessage()]);
            throw $e;
        }
    }

    /**
     * Check media container status
     */
    public function checkContainerStatus(string $accessToken, string $containerId): array
    {
        try {
            $response = Http::get($this->baseUrl . '/' . $this->graphVersion . '/' . $containerId, [
                'access_token' => $accessToken,
                'fields' => 'status_code,status',
            ]);

            if ($response->successful()) {
                return $response->json();
            }

            throw new \Exception($response->json()['error']['message'] ?? 'Failed to check status');
        } catch (\Exception $e) {
            Log::error('Instagram check status error', ['error' => $e->getMessage()]);
            throw $e;
        }
    }

    /**
     * Publish the media container
     */
    public function publishMedia(string $accessToken, string $igUserId, string $containerId): array
    {
        try {
            $response = Http::post($this->baseUrl . '/' . $this->graphVersion . '/' . $igUserId . '/media_publish', [
                'access_token' => $accessToken,
                'creation_id' => $containerId,
            ]);

            if ($response->successful()) {
                return $response->json();
            }

            throw new \Exception($response->json()['error']['message'] ?? 'Failed to publish media');
        } catch (\Exception $e) {
            Log::error('Instagram publish error', ['error' => $e->getMessage()]);
            throw $e;
        }
    }

    /**
     * Create and publish a post (combines container creation and publishing)
     */
    public function createPost(string $accessToken, string $igUserId, array $data): array
    {
        try {
            // Step 1: Create media container
            $container = $this->createMediaContainer($accessToken, $igUserId, $data);
            $containerId = $container['id'];

            // Step 2: For videos, wait for processing
            if (isset($data['video_url'])) {
                $maxAttempts = 30;
                $attempt = 0;

                while ($attempt < $maxAttempts) {
                    $status = $this->checkContainerStatus($accessToken, $containerId);

                    if ($status['status_code'] === 'FINISHED') {
                        break;
                    } elseif ($status['status_code'] === 'ERROR') {
                        throw new \Exception('Video processing failed: ' . ($status['status'] ?? 'Unknown error'));
                    }

                    $attempt++;
                    sleep(2);
                }
            }

            // Step 3: Publish
            $result = $this->publishMedia($accessToken, $igUserId, $containerId);

            return [
                'success' => true,
                'media_id' => $result['id'],
                'container_id' => $containerId,
            ];
        } catch (\Exception $e) {
            Log::error('Instagram create post error', ['error' => $e->getMessage()]);
            throw $e;
        }
    }

    /**
     * Get comments on a media
     */
    public function getComments(string $accessToken, string $mediaId): array
    {
        try {
            $response = Http::get($this->baseUrl . '/' . $this->graphVersion . '/' . $mediaId . '/comments', [
                'access_token' => $accessToken,
                'fields' => 'id,text,timestamp,username,like_count,replies{id,text,timestamp,username}',
            ]);

            if ($response->successful()) {
                return $response->json();
            }

            throw new \Exception($response->json()['error']['message'] ?? 'Failed to get comments');
        } catch (\Exception $e) {
            Log::error('Instagram get comments error', ['error' => $e->getMessage()]);
            throw $e;
        }
    }

    /**
     * Reply to a comment
     */
    public function replyToComment(string $accessToken, string $commentId, string $message): array
    {
        try {
            $response = Http::post($this->baseUrl . '/' . $this->graphVersion . '/' . $commentId . '/replies', [
                'access_token' => $accessToken,
                'message' => $message,
            ]);

            if ($response->successful()) {
                return $response->json();
            }

            throw new \Exception($response->json()['error']['message'] ?? 'Failed to reply');
        } catch (\Exception $e) {
            Log::error('Instagram reply error', ['error' => $e->getMessage()]);
            throw $e;
        }
    }

    /**
     * Get media insights
     */
    public function getMediaInsights(string $accessToken, string $mediaId): array
    {
        try {
            $metrics = 'impressions,reach,engagement,saved';

            $response = Http::get($this->baseUrl . '/' . $this->graphVersion . '/' . $mediaId . '/insights', [
                'access_token' => $accessToken,
                'metric' => $metrics,
            ]);

            if ($response->successful()) {
                return $response->json();
            }

            // Return empty if insights not available
            return ['data' => []];
        } catch (\Exception $e) {
            Log::warning('Instagram media insights error', ['error' => $e->getMessage()]);
            return ['data' => []];
        }
    }

    /**
     * Delete a media post
     */
    public function deleteMedia(string $accessToken, string $mediaId): bool
    {
        try {
            // Note: Instagram Graph API doesn't support deleting media
            // This would need to be done through the Instagram app
            Log::warning('Instagram media deletion not supported via API');
            return false;
        } catch (\Exception $e) {
            Log::error('Instagram delete error', ['error' => $e->getMessage()]);
            return false;
        }
    }

    /**
     * Get hashtag search results
     */
    public function searchHashtag(string $accessToken, string $igUserId, string $hashtag): array
    {
        try {
            // First, get hashtag ID
            $response = Http::get($this->baseUrl . '/' . $this->graphVersion . '/ig_hashtag_search', [
                'access_token' => $accessToken,
                'user_id' => $igUserId,
                'q' => $hashtag,
            ]);

            if (!$response->successful()) {
                throw new \Exception($response->json()['error']['message'] ?? 'Failed to search hashtag');
            }

            $hashtagId = $response->json()['data'][0]['id'] ?? null;

            if (!$hashtagId) {
                return ['data' => []];
            }

            // Get recent media with this hashtag
            $mediaResponse = Http::get($this->baseUrl . '/' . $this->graphVersion . '/' . $hashtagId . '/recent_media', [
                'access_token' => $accessToken,
                'user_id' => $igUserId,
                'fields' => 'id,caption,media_type,permalink,like_count,comments_count',
            ]);

            return $mediaResponse->json();
        } catch (\Exception $e) {
            Log::error('Instagram hashtag search error', ['error' => $e->getMessage()]);
            throw $e;
        }
    }
}
