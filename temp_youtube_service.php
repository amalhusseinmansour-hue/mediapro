<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;
use App\Models\SocialAccount;

class YouTubeService
{
    private ?string $clientId;
    private ?string $clientSecret;
    private string $redirectUri;
    private string $baseUrl = 'https://www.googleapis.com/youtube/v3';
    private string $authUrl = 'https://accounts.google.com/o/oauth2/v2/auth';
    private string $tokenUrl = 'https://oauth2.googleapis.com/token';

    public function __construct()
    {
        $this->clientId = config('services.google.client_id') ?? env('GOOGLE_CLIENT_ID');
        $this->clientSecret = config('services.google.client_secret') ?? env('GOOGLE_CLIENT_SECRET');
        $this->redirectUri = config('services.google.redirect') ?? 'https://mediaprosocial.io/api/youtube/callback';
    }

    /**
     * Generate OAuth authorization URL
     */
    public function getAuthorizationUrl(): array
    {
        $state = bin2hex(random_bytes(16));

        // Store state in cache
        Cache::put("youtube_oauth_state_{$state}", [
            'created_at' => now(),
        ], now()->addMinutes(10));

        // YouTube/Google OAuth 2.0 scopes
        $scopes = [
            'https://www.googleapis.com/auth/youtube.readonly',
            'https://www.googleapis.com/auth/youtube.upload',
            'https://www.googleapis.com/auth/youtube.force-ssl',
            'https://www.googleapis.com/auth/userinfo.profile',
            'https://www.googleapis.com/auth/userinfo.email',
        ];

        $params = [
            'client_id' => $this->clientId,
            'redirect_uri' => $this->redirectUri,
            'response_type' => 'code',
            'scope' => implode(' ', $scopes),
            'state' => $state,
            'access_type' => 'offline',
            'prompt' => 'consent',
        ];

        $authUrl = $this->authUrl . '?' . http_build_query($params);

        return [
            'auth_url' => $authUrl,
            'state' => $state,
        ];
    }

    /**
     * Exchange authorization code for access token
     */
    public function exchangeCodeForToken(string $code, string $state): array
    {
        $cached = Cache::get("youtube_oauth_state_{$state}");

        if (!$cached) {
            throw new \Exception('Invalid or expired state parameter');
        }

        Cache::forget("youtube_oauth_state_{$state}");

        $response = Http::asForm()->post($this->tokenUrl, [
            'client_id' => $this->clientId,
            'client_secret' => $this->clientSecret,
            'code' => $code,
            'grant_type' => 'authorization_code',
            'redirect_uri' => $this->redirectUri,
        ]);

        if (!$response->successful()) {
            Log::error('YouTube token exchange failed', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);
            throw new \Exception('Failed to exchange code for token: ' . $response->body());
        }

        return $response->json();
    }

    /**
     * Refresh access token
     */
    public function refreshToken(string $refreshToken): array
    {
        $response = Http::asForm()->post($this->tokenUrl, [
            'client_id' => $this->clientId,
            'client_secret' => $this->clientSecret,
            'grant_type' => 'refresh_token',
            'refresh_token' => $refreshToken,
        ]);

        if (!$response->successful()) {
            Log::error('YouTube token refresh failed', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);
            throw new \Exception('Failed to refresh token');
        }

        return $response->json();
    }

    /**
     * Get user info from Google
     */
    public function getUserInfo(string $accessToken): array
    {
        $response = Http::withToken($accessToken)
            ->get('https://www.googleapis.com/oauth2/v2/userinfo');

        if (!$response->successful()) {
            throw new \Exception('Failed to get user info');
        }

        return $response->json();
    }

    /**
     * Get YouTube channel info
     */
    public function getChannelInfo(string $accessToken): array
    {
        $response = Http::withToken($accessToken)
            ->get("{$this->baseUrl}/channels", [
                'part' => 'snippet,statistics,contentDetails,brandingSettings',
                'mine' => 'true',
            ]);

        if (!$response->successful()) {
            Log::error('YouTube get channel info failed', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);
            throw new \Exception('Failed to get channel info');
        }

        $data = $response->json();
        return $data['items'][0] ?? [];
    }

    /**
     * Get channel videos
     */
    public function getChannelVideos(string $accessToken, int $maxResults = 20, ?string $pageToken = null): array
    {
        $params = [
            'part' => 'snippet,statistics,contentDetails',
            'mine' => 'true',
            'maxResults' => $maxResults,
            'order' => 'date',
        ];

        if ($pageToken) {
            $params['pageToken'] = $pageToken;
        }

        $response = Http::withToken($accessToken)
            ->get("{$this->baseUrl}/search", $params);

        if (!$response->successful()) {
            throw new \Exception('Failed to get videos');
        }

        return $response->json();
    }

    /**
     * Get video details
     */
    public function getVideoDetails(string $accessToken, string $videoId): array
    {
        $response = Http::withToken($accessToken)
            ->get("{$this->baseUrl}/videos", [
                'part' => 'snippet,statistics,contentDetails,status',
                'id' => $videoId,
            ]);

        if (!$response->successful()) {
            throw new \Exception('Failed to get video details');
        }

        $data = $response->json();
        return $data['items'][0] ?? [];
    }

    /**
     * Upload video (initialize resumable upload)
     */
    public function initializeVideoUpload(string $accessToken, array $videoMetadata): array
    {
        $response = Http::withToken($accessToken)
            ->withHeaders([
                'Content-Type' => 'application/json',
                'X-Upload-Content-Type' => 'video/*',
            ])
            ->post('https://www.googleapis.com/upload/youtube/v3/videos?uploadType=resumable&part=snippet,status', [
                'snippet' => [
                    'title' => $videoMetadata['title'] ?? 'Untitled',
                    'description' => $videoMetadata['description'] ?? '',
                    'tags' => $videoMetadata['tags'] ?? [],
                    'categoryId' => $videoMetadata['category_id'] ?? '22', // People & Blogs
                ],
                'status' => [
                    'privacyStatus' => $videoMetadata['privacy_status'] ?? 'private',
                    'selfDeclaredMadeForKids' => $videoMetadata['made_for_kids'] ?? false,
                ],
            ]);

        if (!$response->successful()) {
            Log::error('YouTube video upload init failed', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);
            throw new \Exception('Failed to initialize video upload');
        }

        return [
            'upload_url' => $response->header('Location'),
            'response' => $response->json(),
        ];
    }

    /**
     * Update video metadata
     */
    public function updateVideo(string $accessToken, string $videoId, array $metadata): array
    {
        $response = Http::withToken($accessToken)
            ->put("{$this->baseUrl}/videos?part=snippet,status", [
                'id' => $videoId,
                'snippet' => [
                    'title' => $metadata['title'],
                    'description' => $metadata['description'] ?? '',
                    'tags' => $metadata['tags'] ?? [],
                    'categoryId' => $metadata['category_id'] ?? '22',
                ],
                'status' => [
                    'privacyStatus' => $metadata['privacy_status'] ?? 'private',
                ],
            ]);

        if (!$response->successful()) {
            throw new \Exception('Failed to update video');
        }

        return $response->json();
    }

    /**
     * Delete video
     */
    public function deleteVideo(string $accessToken, string $videoId): bool
    {
        $response = Http::withToken($accessToken)
            ->delete("{$this->baseUrl}/videos", [
                'id' => $videoId,
            ]);

        return $response->successful();
    }

    /**
     * Get channel analytics/statistics
     */
    public function getChannelAnalytics(string $accessToken): array
    {
        try {
            $channelInfo = $this->getChannelInfo($accessToken);

            $statistics = $channelInfo['statistics'] ?? [];
            $snippet = $channelInfo['snippet'] ?? [];

            return [
                'channel_id' => $channelInfo['id'] ?? '',
                'title' => $snippet['title'] ?? '',
                'description' => $snippet['description'] ?? '',
                'thumbnail' => $snippet['thumbnails']['high']['url'] ?? $snippet['thumbnails']['default']['url'] ?? '',
                'subscribers' => (int)($statistics['subscriberCount'] ?? 0),
                'total_views' => (int)($statistics['viewCount'] ?? 0),
                'video_count' => (int)($statistics['videoCount'] ?? 0),
                'hidden_subscriber_count' => $statistics['hiddenSubscriberCount'] ?? false,
                'custom_url' => $snippet['customUrl'] ?? '',
                'published_at' => $snippet['publishedAt'] ?? '',
                'country' => $snippet['country'] ?? '',
            ];
        } catch (\Exception $e) {
            Log::error('YouTube analytics error', ['error' => $e->getMessage()]);
            return [
                'subscribers' => 0,
                'total_views' => 0,
                'video_count' => 0,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Get video analytics
     */
    public function getVideoAnalytics(string $accessToken, string $videoId): array
    {
        try {
            $video = $this->getVideoDetails($accessToken, $videoId);

            $statistics = $video['statistics'] ?? [];
            $snippet = $video['snippet'] ?? [];

            return [
                'video_id' => $videoId,
                'title' => $snippet['title'] ?? '',
                'views' => (int)($statistics['viewCount'] ?? 0),
                'likes' => (int)($statistics['likeCount'] ?? 0),
                'comments' => (int)($statistics['commentCount'] ?? 0),
                'favorites' => (int)($statistics['favoriteCount'] ?? 0),
            ];
        } catch (\Exception $e) {
            Log::error('YouTube video analytics error', ['error' => $e->getMessage()]);
            return ['error' => $e->getMessage()];
        }
    }

    /**
     * Publish from social account
     */
    public function publishFromAccount(SocialAccount $account, array $videoData): array
    {
        $accessToken = $account->access_token;

        // Check if token needs refresh
        if ($this->tokenNeedsRefresh($account)) {
            $refreshToken = $account->platform_data['refresh_token'] ?? null;
            if ($refreshToken) {
                $newTokens = $this->refreshToken($refreshToken);
                $accessToken = $newTokens['access_token'];

                // Update account tokens
                $account->update([
                    'access_token' => $accessToken,
                    'platform_data' => array_merge($account->platform_data ?? [], [
                        'refresh_token' => $newTokens['refresh_token'] ?? $refreshToken,
                        'token_expires_at' => now()->addSeconds($newTokens['expires_in'] ?? 3600)->toIso8601String(),
                    ]),
                ]);
            }
        }

        return $this->initializeVideoUpload($accessToken, $videoData);
    }

    /**
     * Check if token needs refresh
     */
    private function tokenNeedsRefresh(SocialAccount $account): bool
    {
        $expiresAt = $account->platform_data['token_expires_at'] ?? null;
        if (!$expiresAt) {
            return false;
        }

        return now()->addMinutes(5)->isAfter($expiresAt);
    }

    /**
     * Check if service is configured
     */
    public function isConfigured(): bool
    {
        return !empty($this->clientId) && !empty($this->clientSecret);
    }
}
