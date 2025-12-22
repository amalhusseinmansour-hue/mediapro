<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ConnectedAccount;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;

class SocialAuthController extends Controller
{
    /**
     * Redirect to platform OAuth page
     * String-style direct OAuth redirect
     */
    public function redirect(Request $request, string $platform): JsonResponse
    {
        $request->validate([
            'user_id' => 'sometimes|exists:users,id',
        ]);

        $userId = $request->user_id ?? Auth::id();

        if (!$userId) {
            return response()->json([
                'success' => false,
                'message' => 'يجب تسجيل الدخول أولاً',
            ], 401);
        }

        // Generate state token for security
        $state = base64_encode(json_encode([
            'user_id' => $userId,
            'platform' => $platform,
            'timestamp' => time(),
            'random' => Str::random(32),
        ]));

        // Store state in session or cache for verification
        cache()->put("oauth_state_{$userId}_{$platform}", $state, now()->addMinutes(10));

        $redirectUrl = $this->getOAuthUrl($platform, $state);

        if (!$redirectUrl) {
            return response()->json([
                'success' => false,
                'message' => 'المنصة غير مدعومة',
                'platform' => $platform,
            ], 400);
        }

        return response()->json([
            'success' => true,
            'platform' => $platform,
            'redirect_url' => $redirectUrl,
            'state' => $state,
        ]);
    }

    /**
     * Handle OAuth callback from platforms
     */
    public function callback(Request $request, string $platform)
    {
        try {
            $code = $request->code;
            $state = $request->state;
            $error = $request->error;

            // Check for errors
            if ($error) {
                return $this->mobileRedirect(false, $platform, 'تم إلغاء الربط');
            }

            if (!$code || !$state) {
                return $this->mobileRedirect(false, $platform, 'بيانات غير صحيحة');
            }

            // Decode and verify state
            $stateData = json_decode(base64_decode($state), true);

            if (!$stateData || !isset($stateData['user_id'])) {
                return $this->mobileRedirect(false, $platform, 'حالة غير صالحة');
            }

            $userId = $stateData['user_id'];

            // Verify state from cache
            $cachedState = cache()->get("oauth_state_{$userId}_{$platform}");
            if ($cachedState !== $state) {
                return $this->mobileRedirect(false, $platform, 'حالة غير متطابقة');
            }

            // Exchange code for access token
            $tokenData = $this->exchangeCodeForToken($platform, $code);

            if (!$tokenData) {
                return $this->mobileRedirect(false, $platform, 'فشل الحصول على الرمز');
            }

            // Get user profile from platform
            $profileData = $this->getPlatformProfile($platform, $tokenData['access_token']);

            if (!$profileData) {
                return $this->mobileRedirect(false, $platform, 'فشل الحصول على البيانات');
            }

            // Save or update connected account
            $account = $this->saveConnectedAccount($userId, $platform, $tokenData, $profileData);

            // Clear state from cache
            cache()->forget("oauth_state_{$userId}_{$platform}");

            // Redirect back to mobile app with success
            return $this->mobileRedirect(true, $platform, 'تم الربط بنجاح', $account);

        } catch (\Exception $e) {
            \Log::error("OAuth callback error for {$platform}: " . $e->getMessage());
            return $this->mobileRedirect(false, $platform, 'حدث خطأ أثناء الربط');
        }
    }

    /**
     * Get OAuth URL for platform
     */
    private function getOAuthUrl(string $platform, string $state): ?string
    {
        $callbackUrl = url("/api/auth/{$platform}/callback");

        return match($platform) {
            'instagram' => sprintf(
                'https://api.instagram.com/oauth/authorize?client_id=%s&redirect_uri=%s&scope=user_profile,user_media&response_type=code&state=%s',
                config('services.instagram.client_id'),
                urlencode($callbackUrl),
                $state
            ),

            'facebook' => sprintf(
                'https://www.facebook.com/v18.0/dialog/oauth?client_id=%s&redirect_uri=%s&scope=pages_manage_posts,pages_read_engagement&response_type=code&state=%s',
                config('services.facebook.client_id'),
                urlencode($callbackUrl),
                $state
            ),

            'twitter' => sprintf(
                'https://twitter.com/i/oauth2/authorize?client_id=%s&redirect_uri=%s&scope=tweet.read%20tweet.write%20users.read&response_type=code&code_challenge=challenge&code_challenge_method=plain&state=%s',
                config('services.twitter.client_id'),
                urlencode($callbackUrl),
                $state
            ),

            'linkedin' => sprintf(
                'https://www.linkedin.com/oauth/v2/authorization?client_id=%s&redirect_uri=%s&scope=w_member_social&response_type=code&state=%s',
                config('services.linkedin.client_id'),
                urlencode($callbackUrl),
                $state
            ),

            'tiktok' => sprintf(
                'https://www.tiktok.com/auth/authorize/?client_key=%s&redirect_uri=%s&scope=user.info.basic,video.list&response_type=code&state=%s',
                config('services.tiktok.client_id'),
                urlencode($callbackUrl),
                $state
            ),

            'youtube' => sprintf(
                'https://accounts.google.com/o/oauth2/v2/auth?client_id=%s&redirect_uri=%s&scope=https://www.googleapis.com/auth/youtube.upload&response_type=code&access_type=offline&state=%s',
                config('services.google.client_id'),
                urlencode($callbackUrl),
                $state
            ),

            'snapchat' => sprintf(
                'https://accounts.snapchat.com/login/oauth2/authorize?client_id=%s&redirect_uri=%s&response_type=code&scope=snapchat-marketing-api&state=%s',
                config('services.snapchat.client_id'),
                urlencode($callbackUrl),
                $state
            ),

            default => null,
        };
    }

    /**
     * Exchange authorization code for access token
     */
    private function exchangeCodeForToken(string $platform, string $code): ?array
    {
        $callbackUrl = url("/api/auth/{$platform}/callback");

        try {
            $response = match($platform) {
                'instagram' => Http::asForm()->post('https://api.instagram.com/oauth/access_token', [
                    'client_id' => config('services.instagram.client_id'),
                    'client_secret' => config('services.instagram.client_secret'),
                    'grant_type' => 'authorization_code',
                    'redirect_uri' => $callbackUrl,
                    'code' => $code,
                ]),

                'facebook' => Http::get('https://graph.facebook.com/v18.0/oauth/access_token', [
                    'client_id' => config('services.facebook.client_id'),
                    'client_secret' => config('services.facebook.client_secret'),
                    'redirect_uri' => $callbackUrl,
                    'code' => $code,
                ]),

                'twitter' => Http::asForm()->withBasicAuth(
                    config('services.twitter.client_id'),
                    config('services.twitter.client_secret')
                )->post('https://api.twitter.com/2/oauth2/token', [
                    'grant_type' => 'authorization_code',
                    'code' => $code,
                    'redirect_uri' => $callbackUrl,
                    'code_verifier' => 'challenge',
                ]),

                'linkedin' => Http::asForm()->post('https://www.linkedin.com/oauth/v2/accessToken', [
                    'grant_type' => 'authorization_code',
                    'code' => $code,
                    'redirect_uri' => $callbackUrl,
                    'client_id' => config('services.linkedin.client_id'),
                    'client_secret' => config('services.linkedin.client_secret'),
                ]),

                'tiktok' => Http::asForm()->post('https://open-api.tiktok.com/oauth/access_token/', [
                    'client_key' => config('services.tiktok.client_id'),
                    'client_secret' => config('services.tiktok.client_secret'),
                    'code' => $code,
                    'grant_type' => 'authorization_code',
                ]),

                'youtube' => Http::asForm()->post('https://oauth2.googleapis.com/token', [
                    'client_id' => config('services.google.client_id'),
                    'client_secret' => config('services.google.client_secret'),
                    'code' => $code,
                    'redirect_uri' => $callbackUrl,
                    'grant_type' => 'authorization_code',
                ]),

                'snapchat' => Http::asForm()->post('https://accounts.snapchat.com/login/oauth2/access_token', [
                    'client_id' => config('services.snapchat.client_id'),
                    'client_secret' => config('services.snapchat.client_secret'),
                    'grant_type' => 'authorization_code',
                    'redirect_uri' => $callbackUrl,
                    'code' => $code,
                ]),

                default => null,
            };

            if ($response && $response->successful()) {
                $data = $response->json();

                return [
                    'access_token' => $data['access_token'] ?? null,
                    'refresh_token' => $data['refresh_token'] ?? null,
                    'expires_in' => $data['expires_in'] ?? null,
                    'token_type' => $data['token_type'] ?? 'Bearer',
                ];
            }

            return null;
        } catch (\Exception $e) {
            \Log::error("Token exchange error for {$platform}: " . $e->getMessage());
            return null;
        }
    }

    /**
     * Get user profile from platform
     */
    private function getPlatformProfile(string $platform, string $accessToken): ?array
    {
        try {
            $response = match($platform) {
                'instagram' => Http::get('https://graph.instagram.com/me', [
                    'fields' => 'id,username,account_type,media_count',
                    'access_token' => $accessToken,
                ]),

                'facebook' => Http::get('https://graph.facebook.com/me', [
                    'fields' => 'id,name,picture',
                    'access_token' => $accessToken,
                ]),

                'twitter' => Http::withToken($accessToken)->get('https://api.twitter.com/2/users/me', [
                    'user.fields' => 'id,name,username,profile_image_url',
                ]),

                'linkedin' => Http::withToken($accessToken)->get('https://api.linkedin.com/v2/me'),

                'tiktok' => Http::get('https://open-api.tiktok.com/user/info/', [
                    'access_token' => $accessToken,
                    'fields' => 'open_id,union_id,avatar_url,display_name',
                ]),

                'youtube' => Http::withToken($accessToken)->get('https://www.googleapis.com/youtube/v3/channels', [
                    'part' => 'snippet,statistics',
                    'mine' => 'true',
                ]),

                'snapchat' => Http::withToken($accessToken)->get('https://adsapi.snapchat.com/v1/me'),

                default => null,
            };

            if ($response && $response->successful()) {
                return $this->normalizeProfileData($platform, $response->json());
            }

            return null;
        } catch (\Exception $e) {
            \Log::error("Profile fetch error for {$platform}: " . $e->getMessage());
            return null;
        }
    }

    /**
     * Normalize profile data from different platforms
     */
    private function normalizeProfileData(string $platform, array $data): array
    {
        return match($platform) {
            'instagram' => [
                'platform_user_id' => $data['id'] ?? null,
                'username' => $data['username'] ?? null,
                'display_name' => $data['username'] ?? null,
                'profile_picture' => null,
                'metadata' => $data,
            ],

            'facebook' => [
                'platform_user_id' => $data['id'] ?? null,
                'username' => $data['name'] ?? null,
                'display_name' => $data['name'] ?? null,
                'profile_picture' => $data['picture']['data']['url'] ?? null,
                'metadata' => $data,
            ],

            'twitter' => [
                'platform_user_id' => $data['data']['id'] ?? null,
                'username' => '@' . ($data['data']['username'] ?? ''),
                'display_name' => $data['data']['name'] ?? null,
                'profile_picture' => $data['data']['profile_image_url'] ?? null,
                'metadata' => $data,
            ],

            'linkedin' => [
                'platform_user_id' => $data['id'] ?? null,
                'username' => $data['localizedFirstName'] . ' ' . ($data['localizedLastName'] ?? ''),
                'display_name' => $data['localizedFirstName'] . ' ' . ($data['localizedLastName'] ?? ''),
                'profile_picture' => null,
                'metadata' => $data,
            ],

            'tiktok' => [
                'platform_user_id' => $data['data']['user']['open_id'] ?? null,
                'username' => $data['data']['user']['display_name'] ?? null,
                'display_name' => $data['data']['user']['display_name'] ?? null,
                'profile_picture' => $data['data']['user']['avatar_url'] ?? null,
                'metadata' => $data,
            ],

            'youtube' => [
                'platform_user_id' => $data['items'][0]['id'] ?? null,
                'username' => $data['items'][0]['snippet']['title'] ?? null,
                'display_name' => $data['items'][0]['snippet']['title'] ?? null,
                'profile_picture' => $data['items'][0]['snippet']['thumbnails']['default']['url'] ?? null,
                'metadata' => $data,
            ],

            'snapchat' => [
                'platform_user_id' => $data['me']['id'] ?? null,
                'username' => $data['me']['display_name'] ?? ($data['me']['email'] ?? null),
                'display_name' => $data['me']['display_name'] ?? null,
                'profile_picture' => $data['me']['bitmoji_url'] ?? null,
                'metadata' => $data,
            ],

            default => [],
        };
    }

    /**
     * Save or update connected account
     */
    private function saveConnectedAccount(int $userId, string $platform, array $tokenData, array $profileData): ConnectedAccount
    {
        $existingAccount = ConnectedAccount::where('user_id', $userId)
            ->where('platform', $platform)
            ->first();

        $accountData = [
            'user_id' => $userId,
            'platform' => $platform,
            'platform_user_id' => $profileData['platform_user_id'],
            'username' => $profileData['username'],
            'display_name' => $profileData['display_name'],
            'profile_picture' => $profileData['profile_picture'],
            'access_token' => encrypt($tokenData['access_token']),
            'refresh_token' => $tokenData['refresh_token'] ? encrypt($tokenData['refresh_token']) : null,
            'token_expires_at' => $tokenData['expires_in'] ? now()->addSeconds($tokenData['expires_in']) : null,
            'is_active' => true,
            'connected_at' => now(),
            'metadata' => $profileData['metadata'],
        ];

        if ($existingAccount) {
            $existingAccount->update($accountData);
            return $existingAccount;
        }

        return ConnectedAccount::create($accountData);
    }

    /**
     * Redirect back to mobile app
     */
    private function mobileRedirect(bool $success, string $platform, string $message, ?ConnectedAccount $account = null)
    {
        // Deep link scheme for mobile app
        $scheme = config('app.mobile_scheme', 'socialmediamanager');

        $params = http_build_query([
            'success' => $success ? 'true' : 'false',
            'platform' => $platform,
            'message' => $message,
            'account_id' => $account?->id,
            'username' => $account?->username,
        ]);

        $deepLink = "{$scheme}://oauth/callback?{$params}";

        // Return HTML page that redirects to deep link
        return response()->view('oauth.redirect', [
            'deepLink' => $deepLink,
            'success' => $success,
            'platform' => $platform,
            'message' => $message,
        ]);
    }

    /**
     * Get user's connected accounts (for Flutter app)
     */
    public function getUserAccounts(Request $request): JsonResponse
    {
        $userId = $request->user_id ?? Auth::id();

        if (!$userId) {
            return response()->json([
                'success' => false,
                'message' => 'غير مصرح',
            ], 401);
        }

        $accounts = ConnectedAccount::where('user_id', $userId)
            ->where('is_active', true)
            ->get()
            ->map(function ($account) {
                return [
                    'id' => $account->id,
                    'platform' => $account->platform,
                    'username' => $account->username,
                    'display_name' => $account->display_name,
                    'profile_picture' => $account->profile_picture,
                    'connected_at' => $account->connected_at->toIso8601String(),
                    'is_connected' => true,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $accounts,
        ]);
    }
}
