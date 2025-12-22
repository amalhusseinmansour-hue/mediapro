<?php

namespace App\Services;

use App\Models\SocialAccount;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;

class TwitterService
{
    private string $apiKey;
    private string $apiSecret;
    private string $bearerToken;
    private string $redirectUri;
    private string $apiBaseUrl = 'https://api.twitter.com/2';

    public function __construct()
    {
        $this->apiKey = config('services.twitter.client_id');
        $this->apiSecret = config('services.twitter.client_secret');
        $this->bearerToken = config('services.twitter.bearer_token');
        $this->redirectUri = config('services.twitter.redirect') ?? 'https://mediaprosocial.io/api/auth/twitter/callback';
    }

    /**
     * Generate OAuth 2.0 authorization URL
     */
    public function getAuthorizationUrl(string $state = null): string
    {
        $codeVerifier = bin2hex(random_bytes(32));
        $codeChallenge = rtrim(strtr(base64_encode(hash('sha256', $codeVerifier, true)), '+/', '-_'), '=');

        // Store code verifier in cache for token exchange
        $stateKey = $state ?? bin2hex(random_bytes(16));
        Cache::put("twitter_code_verifier_{$stateKey}", $codeVerifier, 600);

        $params = [
            'response_type' => 'code',
            'client_id' => $this->apiKey,
            'redirect_uri' => $this->redirectUri,
            'scope' => 'tweet.read tweet.write users.read offline.access',
            'state' => $stateKey,
            'code_challenge' => $codeChallenge,
            'code_challenge_method' => 'S256',
        ];

        return 'https://twitter.com/i/oauth2/authorize?' . http_build_query($params);
    }

    /**
     * Exchange authorization code for access token (OAuth 2.0)
     */
    public function exchangeCodeForToken(string $code, string $state): array
    {
        try {
            $codeVerifier = Cache::get("twitter_code_verifier_{$state}");

            if (!$codeVerifier) {
                return ['success' => false, 'error' => 'Code verifier not found or expired'];
            }

            $response = Http::withBasicAuth($this->apiKey, $this->apiSecret)
                ->asForm()
                ->post('https://api.twitter.com/2/oauth2/token', [
                    'code' => $code,
                    'grant_type' => 'authorization_code',
                    'redirect_uri' => $this->redirectUri,
                    'code_verifier' => $codeVerifier,
                ]);

            Cache::forget("twitter_code_verifier_{$state}");

            if ($response->successful()) {
                return ['success' => true, 'data' => $response->json()];
            }

            Log::error('Twitter token exchange failed', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);

            return [
                'success' => false,
                'error' => $response->json()['error_description'] ?? 'Token exchange failed',
            ];
        } catch (\Exception $e) {
            Log::error('Twitter token exchange exception', ['error' => $e->getMessage()]);
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Refresh access token
     */
    public function refreshToken(string $refreshToken): array
    {
        try {
            $response = Http::withBasicAuth($this->apiKey, $this->apiSecret)
                ->asForm()
                ->post('https://api.twitter.com/2/oauth2/token', [
                    'refresh_token' => $refreshToken,
                    'grant_type' => 'refresh_token',
                ]);

            if ($response->successful()) {
                return ['success' => true, 'data' => $response->json()];
            }

            return ['success' => false, 'error' => 'Token refresh failed'];
        } catch (\Exception $e) {
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Get authenticated user profile
     */
    public function getUserProfile(string $accessToken): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
            ])->get($this->apiBaseUrl . '/users/me', [
                'user.fields' => 'id,name,username,profile_image_url,description,public_metrics,verified',
            ]);

            if ($response->successful()) {
                return ['success' => true, 'data' => $response->json()['data']];
            }

            return ['success' => false, 'error' => 'Failed to fetch profile'];
        } catch (\Exception $e) {
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Get user by username (using Bearer Token)
     */
    public function getUserByUsername(string $username): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->bearerToken,
            ])->get($this->apiBaseUrl . '/users/by/username/' . $username, [
                'user.fields' => 'id,name,username,profile_image_url,description,public_metrics,verified,created_at',
            ]);

            if ($response->successful()) {
                return ['success' => true, 'data' => $response->json()['data']];
            }

            return ['success' => false, 'error' => $response->json()['errors'][0]['message'] ?? 'User not found'];
        } catch (\Exception $e) {
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Create a tweet (text only)
     */
    public function createTweet(string $accessToken, string $text): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'Content-Type' => 'application/json',
            ])->post($this->apiBaseUrl . '/tweets', [
                'text' => $text,
            ]);

            if ($response->successful()) {
                Log::info('Twitter tweet created successfully', ['response' => $response->json()]);
                return [
                    'success' => true,
                    'data' => $response->json()['data'],
                    'tweet_id' => $response->json()['data']['id'],
                ];
            }

            Log::error('Twitter tweet creation failed', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);

            return [
                'success' => false,
                'error' => $response->json()['detail'] ?? 'Tweet creation failed',
                'status' => $response->status(),
            ];
        } catch (\Exception $e) {
            Log::error('Twitter tweet exception', ['error' => $e->getMessage()]);
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Create a tweet with media
     */
    public function createTweetWithMedia(string $accessToken, string $text, array $mediaIds): array
    {
        try {
            $payload = [
                'text' => $text,
            ];

            if (!empty($mediaIds)) {
                $payload['media'] = ['media_ids' => $mediaIds];
            }

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'Content-Type' => 'application/json',
            ])->post($this->apiBaseUrl . '/tweets', $payload);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json()['data'],
                    'tweet_id' => $response->json()['data']['id'],
                ];
            }

            return [
                'success' => false,
                'error' => $response->json()['detail'] ?? 'Tweet with media failed',
            ];
        } catch (\Exception $e) {
            Log::error('Twitter tweet with media exception', ['error' => $e->getMessage()]);
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Upload media to Twitter (v1.1 API - still required for media upload)
     */
    public function uploadMedia(string $accessToken, string $accessTokenSecret, string $mediaUrl): array
    {
        try {
            // Download media first
            $mediaContent = file_get_contents($mediaUrl);
            if (!$mediaContent) {
                return ['success' => false, 'error' => 'Failed to download media'];
            }

            $base64Media = base64_encode($mediaContent);

            // Twitter media upload uses OAuth 1.0a
            $oauth = $this->generateOAuth1Header(
                'POST',
                'https://upload.twitter.com/1.1/media/upload.json',
                ['media_data' => $base64Media],
                $accessToken,
                $accessTokenSecret
            );

            $response = Http::withHeaders([
                'Authorization' => $oauth,
            ])->asForm()->post('https://upload.twitter.com/1.1/media/upload.json', [
                'media_data' => $base64Media,
            ]);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'media_id' => $response->json()['media_id_string'],
                ];
            }

            return ['success' => false, 'error' => 'Media upload failed'];
        } catch (\Exception $e) {
            Log::error('Twitter media upload exception', ['error' => $e->getMessage()]);
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Generate OAuth 1.0a header for media upload
     */
    private function generateOAuth1Header(string $method, string $url, array $params, string $accessToken, string $accessTokenSecret): string
    {
        $oauth = [
            'oauth_consumer_key' => $this->apiKey,
            'oauth_nonce' => bin2hex(random_bytes(16)),
            'oauth_signature_method' => 'HMAC-SHA1',
            'oauth_timestamp' => time(),
            'oauth_token' => $accessToken,
            'oauth_version' => '1.0',
        ];

        $allParams = array_merge($oauth, $params);
        ksort($allParams);

        $baseString = strtoupper($method) . '&' . rawurlencode($url) . '&' . rawurlencode(http_build_query($allParams, '', '&', PHP_QUERY_RFC3986));
        $signingKey = rawurlencode($this->apiSecret) . '&' . rawurlencode($accessTokenSecret);
        $signature = base64_encode(hash_hmac('sha1', $baseString, $signingKey, true));

        $oauth['oauth_signature'] = $signature;

        $headerParts = [];
        foreach ($oauth as $key => $value) {
            $headerParts[] = rawurlencode($key) . '="' . rawurlencode($value) . '"';
        }

        return 'OAuth ' . implode(', ', $headerParts);
    }

    /**
     * Delete a tweet
     */
    public function deleteTweet(string $accessToken, string $tweetId): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
            ])->delete($this->apiBaseUrl . '/tweets/' . $tweetId);

            if ($response->successful()) {
                return ['success' => true];
            }

            return ['success' => false, 'error' => 'Failed to delete tweet'];
        } catch (\Exception $e) {
            Log::error('Twitter delete tweet exception', ['error' => $e->getMessage()]);
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Get user tweets (timeline)
     */
    public function getUserTweets(string $userId, int $maxResults = 10): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->bearerToken,
            ])->get($this->apiBaseUrl . '/users/' . $userId . '/tweets', [
                'max_results' => $maxResults,
                'tweet.fields' => 'id,text,created_at,public_metrics,entities',
            ]);

            if ($response->successful()) {
                return ['success' => true, 'data' => $response->json()];
            }

            return ['success' => false, 'error' => 'Failed to fetch tweets'];
        } catch (\Exception $e) {
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Get account analytics/metrics
     */
    public function getAccountAnalytics(string $userId): array
    {
        try {
            // Get user public metrics
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->bearerToken,
            ])->get($this->apiBaseUrl . '/users/' . $userId, [
                'user.fields' => 'public_metrics,description,created_at,verified',
            ]);

            if ($response->successful()) {
                $data = $response->json()['data'];
                $metrics = $data['public_metrics'] ?? [];

                return [
                    'success' => true,
                    'data' => [
                        'followers' => $metrics['followers_count'] ?? 0,
                        'following' => $metrics['following_count'] ?? 0,
                        'tweets_count' => $metrics['tweet_count'] ?? 0,
                        'listed_count' => $metrics['listed_count'] ?? 0,
                        'verified' => $data['verified'] ?? false,
                        'description' => $data['description'] ?? '',
                        'created_at' => $data['created_at'] ?? null,
                    ],
                ];
            }

            return ['success' => false, 'error' => 'Failed to fetch analytics'];
        } catch (\Exception $e) {
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Get tweet analytics
     */
    public function getTweetAnalytics(string $tweetId): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->bearerToken,
            ])->get($this->apiBaseUrl . '/tweets/' . $tweetId, [
                'tweet.fields' => 'public_metrics,organic_metrics,non_public_metrics,created_at',
            ]);

            if ($response->successful()) {
                $data = $response->json()['data'];
                $metrics = $data['public_metrics'] ?? [];

                return [
                    'success' => true,
                    'data' => [
                        'retweets' => $metrics['retweet_count'] ?? 0,
                        'replies' => $metrics['reply_count'] ?? 0,
                        'likes' => $metrics['like_count'] ?? 0,
                        'quotes' => $metrics['quote_count'] ?? 0,
                        'impressions' => $metrics['impression_count'] ?? 0,
                        'bookmarks' => $metrics['bookmark_count'] ?? 0,
                    ],
                ];
            }

            return ['success' => false, 'error' => 'Failed to fetch tweet analytics'];
        } catch (\Exception $e) {
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Publish post from SocialAccount
     */
    public function publishFromAccount(SocialAccount $account, string $text, array $mediaUrls = []): array
    {
        // Check token expiration
        if ($account->expires_at && $account->expires_at->isPast()) {
            if ($account->refresh_token) {
                $refreshResult = $this->refreshToken($account->refresh_token);
                if ($refreshResult['success']) {
                    $account->update([
                        'access_token' => $refreshResult['data']['access_token'],
                        'refresh_token' => $refreshResult['data']['refresh_token'] ?? $account->refresh_token,
                        'expires_at' => now()->addSeconds($refreshResult['data']['expires_in']),
                    ]);
                } else {
                    return ['success' => false, 'error' => 'Token expired and refresh failed'];
                }
            } else {
                return ['success' => false, 'error' => 'Token expired'];
            }
        }

        // For now, create text-only tweet (media upload requires OAuth 1.0a tokens)
        if (empty($mediaUrls)) {
            return $this->createTweet($account->access_token, $text);
        }

        // If media URLs provided and we have OAuth 1.0a tokens
        $platformData = $account->platform_data ?? [];
        if (isset($platformData['auth_token_secret'])) {
            $mediaIds = [];
            foreach ($mediaUrls as $mediaUrl) {
                $uploadResult = $this->uploadMedia(
                    $account->access_token,
                    $platformData['auth_token_secret'],
                    $mediaUrl
                );
                if ($uploadResult['success']) {
                    $mediaIds[] = $uploadResult['media_id'];
                }
            }

            if (!empty($mediaIds)) {
                return $this->createTweetWithMedia($account->access_token, $text, $mediaIds);
            }
        }

        // Fallback to text-only tweet
        return $this->createTweet($account->access_token, $text);
    }

    /**
     * Check if service is configured
     */
    public function isConfigured(): bool
    {
        return !empty($this->apiKey) && !empty($this->apiSecret);
    }
}
