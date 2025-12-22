<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;
use App\Models\SocialAccount;

class TikTokService
{
    private ?string $clientKey;
    private ?string $clientSecret;
    private string $redirectUri;
    private string $baseUrl = 'https://open.tiktokapis.com/v2';
    private string $authUrl = 'https://www.tiktok.com/v2/auth/authorize';

    public function __construct()
    {
        $this->clientKey = config('services.tiktok.client_id') ?? config('services.tiktok.client_key') ?? env('TIKTOK_CLIENT_KEY') ?? env('TIKTOK_CLIENT_ID');
        $this->clientSecret = config('services.tiktok.client_secret') ?? env('TIKTOK_CLIENT_SECRET');
        $this->redirectUri = config('services.tiktok.redirect') ?? config('services.tiktok.redirect_uri') ?? 'https://mediaprosocial.io/api/tiktok/callback';
    }

    /**
     * Generate OAuth authorization URL
     */
    public function getAuthorizationUrl(): array
    {
        $state = bin2hex(random_bytes(16));
        $codeVerifier = $this->generateCodeVerifier();
        $codeChallenge = $this->generateCodeChallenge($codeVerifier);

        // Store state and code_verifier in cache
        Cache::put("tiktok_oauth_state_{$state}", [
            'code_verifier' => $codeVerifier,
            'created_at' => now(),
        ], now()->addMinutes(10));

        // TikTok OAuth 2.0 scopes
        $scopes = [
            'user.info.basic',
            'user.info.profile',
            'user.info.stats',
            'video.list',
            'video.publish',
            'video.upload',
        ];

        $params = [
            'client_key' => $this->clientKey,
            'response_type' => 'code',
            'scope' => implode(',', $scopes),
            'redirect_uri' => $this->redirectUri,
            'state' => $state,
            'code_challenge' => $codeChallenge,
            'code_challenge_method' => 'S256',
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
        $cached = Cache::get("tiktok_oauth_state_{$state}");

        if (!$cached) {
            throw new \Exception('Invalid or expired state parameter');
        }

        $codeVerifier = $cached['code_verifier'];
        Cache::forget("tiktok_oauth_state_{$state}");

        $response = Http::asForm()->post('https://open.tiktokapis.com/v2/oauth/token/', [
            'client_key' => $this->clientKey,
            'client_secret' => $this->clientSecret,
            'code' => $code,
            'grant_type' => 'authorization_code',
            'redirect_uri' => $this->redirectUri,
            'code_verifier' => $codeVerifier,
        ]);

        if (!$response->successful()) {
            Log::error('TikTok token exchange failed', [
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
        $response = Http::asForm()->post('https://open.tiktokapis.com/v2/oauth/token/', [
            'client_key' => $this->clientKey,
            'client_secret' => $this->clientSecret,
            'grant_type' => 'refresh_token',
            'refresh_token' => $refreshToken,
        ]);

        if (!$response->successful()) {
            Log::error('TikTok token refresh failed', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);
            throw new \Exception('Failed to refresh token');
        }

        return $response->json();
    }

    /**
     * Get user info
     */
    public function getUserInfo(string $accessToken): array
    {
        $response = Http::withToken($accessToken)
            ->withHeaders(['Content-Type' => 'application/json'])
            ->get("{$this->baseUrl}/user/info/", [
                'fields' => 'open_id,union_id,avatar_url,avatar_url_100,avatar_large_url,display_name,bio_description,profile_deep_link,is_verified,follower_count,following_count,likes_count,video_count',
            ]);

        if (!$response->successful()) {
            Log::error('TikTok get user info failed', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);
            throw new \Exception('Failed to get user info');
        }

        $data = $response->json();
        return $data['data']['user'] ?? [];
    }

    /**
     * Get user videos
     */
    public function getUserVideos(string $accessToken, int $maxCount = 20, ?string $cursor = null): array
    {
        $params = [
            'fields' => 'id,title,video_description,duration,cover_image_url,embed_link,create_time,share_url,view_count,like_count,comment_count,share_count',
        ];

        $body = [
            'max_count' => $maxCount,
        ];

        if ($cursor) {
            $body['cursor'] = $cursor;
        }

        $response = Http::withToken($accessToken)
            ->withHeaders(['Content-Type' => 'application/json'])
            ->post("{$this->baseUrl}/video/list/?" . http_build_query($params), $body);

        if (!$response->successful()) {
            Log::error('TikTok get videos failed', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);
            throw new \Exception('Failed to get videos');
        }

        return $response->json();
    }

    /**
     * Initialize video upload (for direct post)
     */
    public function initializeVideoUpload(string $accessToken, array $videoInfo): array
    {
        $response = Http::withToken($accessToken)
            ->withHeaders(['Content-Type' => 'application/json'])
            ->post("{$this->baseUrl}/post/publish/video/init/", [
                'post_info' => [
                    'title' => $videoInfo['title'] ?? '',
                    'privacy_level' => $videoInfo['privacy_level'] ?? 'PUBLIC_TO_EVERYONE',
                    'disable_duet' => $videoInfo['disable_duet'] ?? false,
                    'disable_comment' => $videoInfo['disable_comment'] ?? false,
                    'disable_stitch' => $videoInfo['disable_stitch'] ?? false,
                ],
                'source_info' => [
                    'source' => 'FILE_UPLOAD',
                    'video_size' => $videoInfo['video_size'],
                    'chunk_size' => $videoInfo['chunk_size'] ?? $videoInfo['video_size'],
                    'total_chunk_count' => 1,
                ],
            ]);

        if (!$response->successful()) {
            Log::error('TikTok video upload init failed', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);
            throw new \Exception('Failed to initialize video upload');
        }

        return $response->json();
    }

    /**
     * Upload video chunk
     */
    public function uploadVideoChunk(string $uploadUrl, string $videoContent, int $chunkStart, int $chunkEnd, int $totalSize): bool
    {
        $response = Http::withHeaders([
            'Content-Type' => 'video/mp4',
            'Content-Range' => "bytes {$chunkStart}-{$chunkEnd}/{$totalSize}",
        ])->withBody($videoContent, 'video/mp4')->put($uploadUrl);

        return $response->successful();
    }

    /**
     * Post video from URL
     */
    public function postVideoFromUrl(string $accessToken, string $videoUrl, array $postInfo): array
    {
        $response = Http::withToken($accessToken)
            ->withHeaders(['Content-Type' => 'application/json'])
            ->post("{$this->baseUrl}/post/publish/video/init/", [
                'post_info' => [
                    'title' => $postInfo['title'] ?? '',
                    'privacy_level' => $postInfo['privacy_level'] ?? 'PUBLIC_TO_EVERYONE',
                    'disable_duet' => $postInfo['disable_duet'] ?? false,
                    'disable_comment' => $postInfo['disable_comment'] ?? false,
                    'disable_stitch' => $postInfo['disable_stitch'] ?? false,
                ],
                'source_info' => [
                    'source' => 'PULL_FROM_URL',
                    'video_url' => $videoUrl,
                ],
            ]);

        if (!$response->successful()) {
            Log::error('TikTok post video from URL failed', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);
            throw new \Exception('Failed to post video: ' . $response->body());
        }

        return $response->json();
    }

    /**
     * Check publish status
     */
    public function checkPublishStatus(string $accessToken, string $publishId): array
    {
        $response = Http::withToken($accessToken)
            ->withHeaders(['Content-Type' => 'application/json'])
            ->post("{$this->baseUrl}/post/publish/status/fetch/", [
                'publish_id' => $publishId,
            ]);

        if (!$response->successful()) {
            Log::error('TikTok check publish status failed', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);
            throw new \Exception('Failed to check publish status');
        }

        return $response->json();
    }

    /**
     * Get account analytics
     */
    public function getAccountAnalytics(string $accessToken): array
    {
        try {
            $userInfo = $this->getUserInfo($accessToken);

            return [
                'followers' => $userInfo['follower_count'] ?? 0,
                'following' => $userInfo['following_count'] ?? 0,
                'likes' => $userInfo['likes_count'] ?? 0,
                'videos' => $userInfo['video_count'] ?? 0,
                'is_verified' => $userInfo['is_verified'] ?? false,
                'profile_url' => $userInfo['profile_deep_link'] ?? '',
            ];
        } catch (\Exception $e) {
            Log::error('TikTok analytics error', ['error' => $e->getMessage()]);
            return [
                'followers' => 0,
                'following' => 0,
                'likes' => 0,
                'videos' => 0,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Publish video from social account
     */
    public function publishFromAccount(SocialAccount $account, string $videoUrl, string $title, array $options = []): array
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
                        'token_expires_at' => now()->addSeconds($newTokens['expires_in'] ?? 86400)->toIso8601String(),
                    ]),
                ]);
            }
        }

        $postInfo = [
            'title' => $title,
            'privacy_level' => $options['privacy_level'] ?? 'PUBLIC_TO_EVERYONE',
            'disable_duet' => $options['disable_duet'] ?? false,
            'disable_comment' => $options['disable_comment'] ?? false,
            'disable_stitch' => $options['disable_stitch'] ?? false,
        ];

        return $this->postVideoFromUrl($accessToken, $videoUrl, $postInfo);
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
     * Generate PKCE code verifier
     */
    private function generateCodeVerifier(): string
    {
        return rtrim(strtr(base64_encode(random_bytes(32)), '+/', '-_'), '=');
    }

    /**
     * Generate PKCE code challenge
     */
    private function generateCodeChallenge(string $codeVerifier): string
    {
        return rtrim(strtr(base64_encode(hash('sha256', $codeVerifier, true)), '+/', '-_'), '=');
    }

    /**
     * Check if service is configured
     */
    public function isConfigured(): bool
    {
        return !empty($this->clientKey) && !empty($this->clientSecret);
    }
}
