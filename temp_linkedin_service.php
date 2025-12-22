<?php

namespace App\Services;

use App\Models\SocialAccount;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;

class LinkedInService
{
    private string $clientId;
    private string $clientSecret;
    private string $redirectUri;
    private string $apiBaseUrl = 'https://api.linkedin.com/v2';

    public function __construct()
    {
        $this->clientId = config('services.linkedin.client_id') ?? '771flta29hpfws';
        $this->clientSecret = config('services.linkedin.client_secret') ?? 'WPL_AP1.oiphgRU2qvIm7NiB.++u//w==';
        $this->redirectUri = config('services.linkedin.redirect_uri') ?? 'https://mediaprosocial.io/api/auth/linkedin/callback';
    }

    /**
     * Generate OAuth authorization URL
     */
    public function getAuthorizationUrl(string $state = null): string
    {
        $scopes = ['openid', 'profile', 'email', 'w_member_social'];
        $params = [
            'response_type' => 'code',
            'client_id' => $this->clientId,
            'redirect_uri' => $this->redirectUri,
            'scope' => implode(' ', $scopes),
            'state' => $state ?? bin2hex(random_bytes(16)),
        ];
        return 'https://www.linkedin.com/oauth/v2/authorization?' . http_build_query($params);
    }

    /**
     * Exchange authorization code for access token
     */
    public function exchangeCodeForToken(string $code): array
    {
        try {
            $response = Http::asForm()->post('https://www.linkedin.com/oauth/v2/accessToken', [
                'grant_type' => 'authorization_code',
                'code' => $code,
                'redirect_uri' => $this->redirectUri,
                'client_id' => $this->clientId,
                'client_secret' => $this->clientSecret,
            ]);

            if ($response->successful()) {
                return ['success' => true, 'data' => $response->json()];
            }

            return [
                'success' => false,
                'error' => $response->json()['error_description'] ?? 'Token exchange failed',
            ];
        } catch (\Exception $e) {
            Log::error('LinkedIn token exchange failed', ['error' => $e->getMessage()]);
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Refresh access token
     */
    public function refreshToken(string $refreshToken): array
    {
        try {
            $response = Http::asForm()->post('https://www.linkedin.com/oauth/v2/accessToken', [
                'grant_type' => 'refresh_token',
                'refresh_token' => $refreshToken,
                'client_id' => $this->clientId,
                'client_secret' => $this->clientSecret,
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
     * Get user profile information
     */
    public function getUserProfile(string $accessToken): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
            ])->get('https://api.linkedin.com/v2/userinfo');

            if ($response->successful()) {
                return ['success' => true, 'data' => $response->json()];
            }

            return ['success' => false, 'error' => 'Failed to fetch profile'];
        } catch (\Exception $e) {
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Get user's LinkedIn URN (required for posting)
     */
    public function getUserUrn(string $accessToken): ?string
    {
        $profile = $this->getUserProfile($accessToken);

        if ($profile['success'] && isset($profile['data']['sub'])) {
            return 'urn:li:person:' . $profile['data']['sub'];
        }

        return null;
    }

    /**
     * Create a text post on LinkedIn
     */
    public function createTextPost(string $accessToken, string $authorUrn, string $text, string $visibility = 'PUBLIC'): array
    {
        try {
            $payload = [
                'author' => $authorUrn,
                'lifecycleState' => 'PUBLISHED',
                'specificContent' => [
                    'com.linkedin.ugc.ShareContent' => [
                        'shareCommentary' => [
                            'text' => $text,
                        ],
                        'shareMediaCategory' => 'NONE',
                    ],
                ],
                'visibility' => [
                    'com.linkedin.ugc.MemberNetworkVisibility' => $visibility,
                ],
            ];

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'Content-Type' => 'application/json',
                'X-Restli-Protocol-Version' => '2.0.0',
            ])->post($this->apiBaseUrl . '/ugcPosts', $payload);

            if ($response->successful()) {
                Log::info('LinkedIn post created successfully', ['response' => $response->json()]);
                return [
                    'success' => true,
                    'data' => $response->json(),
                    'post_id' => $response->header('x-restli-id'),
                ];
            }

            Log::error('LinkedIn post creation failed', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);

            return [
                'success' => false,
                'error' => $response->json()['message'] ?? 'Post creation failed',
                'status' => $response->status(),
            ];
        } catch (\Exception $e) {
            Log::error('LinkedIn post exception', ['error' => $e->getMessage()]);
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Create a post with image on LinkedIn
     */
    public function createImagePost(string $accessToken, string $authorUrn, string $text, string $imageUrl, string $visibility = 'PUBLIC'): array
    {
        try {
            // Step 1: Register image upload
            $registerResponse = $this->registerImageUpload($accessToken, $authorUrn);

            if (!$registerResponse['success']) {
                return $registerResponse;
            }

            $uploadUrl = $registerResponse['upload_url'];
            $asset = $registerResponse['asset'];

            // Step 2: Upload image from URL
            $imageContent = file_get_contents($imageUrl);
            if (!$imageContent) {
                return ['success' => false, 'error' => 'Failed to download image'];
            }

            $uploadResponse = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
            ])->withBody($imageContent, 'application/octet-stream')
              ->put($uploadUrl);

            if (!$uploadResponse->successful()) {
                return ['success' => false, 'error' => 'Failed to upload image'];
            }

            // Step 3: Create post with image
            $payload = [
                'author' => $authorUrn,
                'lifecycleState' => 'PUBLISHED',
                'specificContent' => [
                    'com.linkedin.ugc.ShareContent' => [
                        'shareCommentary' => [
                            'text' => $text,
                        ],
                        'shareMediaCategory' => 'IMAGE',
                        'media' => [
                            [
                                'status' => 'READY',
                                'media' => $asset,
                            ],
                        ],
                    ],
                ],
                'visibility' => [
                    'com.linkedin.ugc.MemberNetworkVisibility' => $visibility,
                ],
            ];

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'Content-Type' => 'application/json',
                'X-Restli-Protocol-Version' => '2.0.0',
            ])->post($this->apiBaseUrl . '/ugcPosts', $payload);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json(),
                    'post_id' => $response->header('x-restli-id'),
                ];
            }

            return [
                'success' => false,
                'error' => $response->json()['message'] ?? 'Post creation failed',
            ];
        } catch (\Exception $e) {
            Log::error('LinkedIn image post exception', ['error' => $e->getMessage()]);
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Register image upload with LinkedIn
     */
    private function registerImageUpload(string $accessToken, string $authorUrn): array
    {
        try {
            $payload = [
                'registerUploadRequest' => [
                    'recipes' => ['urn:li:digitalmediaRecipe:feedshare-image'],
                    'owner' => $authorUrn,
                    'serviceRelationships' => [
                        [
                            'relationshipType' => 'OWNER',
                            'identifier' => 'urn:li:userGeneratedContent',
                        ],
                    ],
                ],
            ];

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'Content-Type' => 'application/json',
                'X-Restli-Protocol-Version' => '2.0.0',
            ])->post($this->apiBaseUrl . '/assets?action=registerUpload', $payload);

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'success' => true,
                    'upload_url' => $data['value']['uploadMechanism']['com.linkedin.digitalmedia.uploading.MediaUploadHttpRequest']['uploadUrl'],
                    'asset' => $data['value']['asset'],
                ];
            }

            return ['success' => false, 'error' => 'Failed to register image upload'];
        } catch (\Exception $e) {
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Create a post with article/link on LinkedIn
     */
    public function createArticlePost(string $accessToken, string $authorUrn, string $text, string $articleUrl, string $title = null, string $description = null, string $visibility = 'PUBLIC'): array
    {
        try {
            $media = [
                'status' => 'READY',
                'originalUrl' => $articleUrl,
            ];

            if ($title) {
                $media['title'] = ['text' => $title];
            }
            if ($description) {
                $media['description'] = ['text' => $description];
            }

            $payload = [
                'author' => $authorUrn,
                'lifecycleState' => 'PUBLISHED',
                'specificContent' => [
                    'com.linkedin.ugc.ShareContent' => [
                        'shareCommentary' => [
                            'text' => $text,
                        ],
                        'shareMediaCategory' => 'ARTICLE',
                        'media' => [$media],
                    ],
                ],
                'visibility' => [
                    'com.linkedin.ugc.MemberNetworkVisibility' => $visibility,
                ],
            ];

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'Content-Type' => 'application/json',
                'X-Restli-Protocol-Version' => '2.0.0',
            ])->post($this->apiBaseUrl . '/ugcPosts', $payload);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json(),
                    'post_id' => $response->header('x-restli-id'),
                ];
            }

            return [
                'success' => false,
                'error' => $response->json()['message'] ?? 'Article post creation failed',
            ];
        } catch (\Exception $e) {
            Log::error('LinkedIn article post exception', ['error' => $e->getMessage()]);
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Delete a post from LinkedIn
     */
    public function deletePost(string $accessToken, string $postUrn): array
    {
        try {
            $encodedUrn = urlencode($postUrn);

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'X-Restli-Protocol-Version' => '2.0.0',
            ])->delete($this->apiBaseUrl . '/ugcPosts/' . $encodedUrn);

            if ($response->successful()) {
                return ['success' => true];
            }

            return ['success' => false, 'error' => 'Failed to delete post'];
        } catch (\Exception $e) {
            Log::error('LinkedIn delete post exception', ['error' => $e->getMessage()]);
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
                        'expires_at' => now()->addSeconds($refreshResult['data']['expires_in']),
                    ]);
                } else {
                    return ['success' => false, 'error' => 'Token expired and refresh failed'];
                }
            } else {
                return ['success' => false, 'error' => 'Token expired'];
            }
        }

        $authorUrn = 'urn:li:person:' . $account->account_id;

        // Determine post type based on media
        if (empty($mediaUrls)) {
            return $this->createTextPost($account->access_token, $authorUrn, $text);
        }

        $firstMedia = $mediaUrls[0];
        $extension = strtolower(pathinfo(parse_url($firstMedia, PHP_URL_PATH), PATHINFO_EXTENSION));

        $imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

        if (in_array($extension, $imageExtensions)) {
            return $this->createImagePost($account->access_token, $authorUrn, $text, $firstMedia);
        } elseif (filter_var($firstMedia, FILTER_VALIDATE_URL)) {
            return $this->createArticlePost($account->access_token, $authorUrn, $text, $firstMedia);
        }

        return $this->createTextPost($account->access_token, $authorUrn, $text);
    }
}
