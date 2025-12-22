<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\TikTokService;
use App\Models\SocialAccount;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class TikTokController extends Controller
{
    protected TikTokService $tiktokService;

    public function __construct(TikTokService $tiktokService)
    {
        $this->tiktokService = $tiktokService;
    }

    /**
     * Get OAuth authorization URL
     */
    public function getAuthUrl()
    {
        try {
            if (!$this->tiktokService->isConfigured()) {
                return response()->json([
                    'success' => false,
                    'error' => 'TikTok API is not configured',
                ], 500);
            }

            $result = $this->tiktokService->getAuthorizationUrl();

            return response()->json([
                'success' => true,
                'auth_url' => $result['auth_url'],
                'state' => $result['state'],
            ]);
        } catch (\Exception $e) {
            Log::error('TikTok auth URL error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Handle OAuth callback
     */
    public function callback(Request $request)
    {
        try {
            $code = $request->get('code');
            $state = $request->get('state');
            $error = $request->get('error');
            $errorDescription = $request->get('error_description');

            if ($error) {
                Log::error('TikTok OAuth error', [
                    'error' => $error,
                    'description' => $errorDescription,
                ]);
                return response()->json([
                    'success' => false,
                    'error' => $errorDescription ?? $error,
                ], 400);
            }

            if (!$code || !$state) {
                return response()->json([
                    'success' => false,
                    'error' => 'Missing code or state parameter',
                ], 400);
            }

            // Exchange code for token
            $tokenData = $this->tiktokService->exchangeCodeForToken($code, $state);

            $accessToken = $tokenData['access_token'];
            $refreshToken = $tokenData['refresh_token'] ?? null;
            $expiresIn = $tokenData['expires_in'] ?? 86400;
            $openId = $tokenData['open_id'] ?? null;

            // Get user info
            $userInfo = $this->tiktokService->getUserInfo($accessToken);

            // Prepare response data
            $responseData = [
                'success' => true,
                'data' => [
                    'id' => $openId ?? $userInfo['open_id'] ?? null,
                    'open_id' => $openId ?? $userInfo['open_id'] ?? null,
                    'name' => $userInfo['display_name'] ?? 'TikTok User',
                    'username' => $userInfo['display_name'] ?? 'tiktok_user',
                    'avatar_url' => $userInfo['avatar_url'] ?? $userInfo['avatar_large_url'] ?? null,
                    'bio' => $userInfo['bio_description'] ?? '',
                    'follower_count' => $userInfo['follower_count'] ?? 0,
                    'following_count' => $userInfo['following_count'] ?? 0,
                    'likes_count' => $userInfo['likes_count'] ?? 0,
                    'video_count' => $userInfo['video_count'] ?? 0,
                    'is_verified' => $userInfo['is_verified'] ?? false,
                    'profile_url' => $userInfo['profile_deep_link'] ?? '',
                    'access_token' => $accessToken,
                    'refresh_token' => $refreshToken,
                    'expires_in' => $expiresIn,
                ],
            ];

            // If user is authenticated, save to database
            if (Auth::check()) {
                $user = Auth::user();

                $socialAccount = SocialAccount::updateOrCreate(
                    [
                        'user_id' => $user->id,
                        'platform' => 'tiktok',
                        'account_id' => $responseData['data']['open_id'],
                    ],
                    [
                        'account_name' => $responseData['data']['name'],
                        'access_token' => $accessToken,
                        'profile_image_url' => $responseData['data']['avatar_url'],
                        'is_active' => true,
                        'platform_data' => [
                            'open_id' => $responseData['data']['open_id'],
                            'username' => $responseData['data']['username'],
                            'bio' => $responseData['data']['bio'],
                            'follower_count' => $responseData['data']['follower_count'],
                            'following_count' => $responseData['data']['following_count'],
                            'likes_count' => $responseData['data']['likes_count'],
                            'video_count' => $responseData['data']['video_count'],
                            'is_verified' => $responseData['data']['is_verified'],
                            'profile_url' => $responseData['data']['profile_url'],
                            'refresh_token' => $refreshToken,
                            'token_expires_at' => now()->addSeconds($expiresIn)->toIso8601String(),
                            'connected_at' => now()->toIso8601String(),
                        ],
                    ]
                );

                $responseData['data']['account_db_id'] = $socialAccount->id;
            }

            return response()->json($responseData);

        } catch (\Exception $e) {
            Log::error('TikTok callback error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get user's TikTok accounts
     */
    public function getAccounts()
    {
        try {
            $accounts = SocialAccount::where('user_id', Auth::id())
                ->where('platform', 'tiktok')
                ->where('is_active', true)
                ->get();

            return response()->json([
                'success' => true,
                'data' => $accounts->map(function ($account) {
                    return [
                        'id' => $account->id,
                        'open_id' => $account->account_id,
                        'name' => $account->account_name,
                        'avatar_url' => $account->profile_image_url,
                        'username' => $account->platform_data['username'] ?? null,
                        'follower_count' => $account->platform_data['follower_count'] ?? 0,
                        'video_count' => $account->platform_data['video_count'] ?? 0,
                        'is_verified' => $account->platform_data['is_verified'] ?? false,
                        'connected_at' => $account->platform_data['connected_at'] ?? $account->created_at,
                    ];
                }),
            ]);
        } catch (\Exception $e) {
            Log::error('TikTok get accounts error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Post a video to TikTok
     */
    public function post(Request $request)
    {
        try {
            $request->validate([
                'account_id' => 'required|integer',
                'video_url' => 'required|url',
                'title' => 'required|string|max:150',
                'privacy_level' => 'nullable|in:PUBLIC_TO_EVERYONE,MUTUAL_FOLLOW_FRIENDS,SELF_ONLY',
            ]);

            $account = SocialAccount::where('id', $request->account_id)
                ->where('user_id', Auth::id())
                ->where('platform', 'tiktok')
                ->firstOrFail();

            $result = $this->tiktokService->publishFromAccount(
                $account,
                $request->video_url,
                $request->title,
                [
                    'privacy_level' => $request->privacy_level ?? 'PUBLIC_TO_EVERYONE',
                    'disable_duet' => $request->disable_duet ?? false,
                    'disable_comment' => $request->disable_comment ?? false,
                    'disable_stitch' => $request->disable_stitch ?? false,
                ]
            );

            return response()->json([
                'success' => true,
                'data' => $result,
                'message' => 'Video submitted for publishing',
            ]);

        } catch (\Exception $e) {
            Log::error('TikTok post error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get videos for an account
     */
    public function getVideos(Request $request, int $accountId)
    {
        try {
            $account = SocialAccount::where('id', $accountId)
                ->where('user_id', Auth::id())
                ->where('platform', 'tiktok')
                ->firstOrFail();

            $maxCount = $request->get('limit', 20);
            $cursor = $request->get('cursor');

            $result = $this->tiktokService->getUserVideos(
                $account->access_token,
                $maxCount,
                $cursor
            );

            return response()->json([
                'success' => true,
                'data' => $result['data'] ?? [],
            ]);

        } catch (\Exception $e) {
            Log::error('TikTok get videos error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get account analytics
     */
    public function getAnalytics(int $accountId)
    {
        try {
            $account = SocialAccount::where('id', $accountId)
                ->where('user_id', Auth::id())
                ->where('platform', 'tiktok')
                ->firstOrFail();

            $analytics = $this->tiktokService->getAccountAnalytics($account->access_token);

            return response()->json([
                'success' => true,
                'data' => $analytics,
            ]);

        } catch (\Exception $e) {
            Log::error('TikTok analytics error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Check publish status
     */
    public function checkPublishStatus(Request $request, int $accountId)
    {
        try {
            $request->validate([
                'publish_id' => 'required|string',
            ]);

            $account = SocialAccount::where('id', $accountId)
                ->where('user_id', Auth::id())
                ->where('platform', 'tiktok')
                ->firstOrFail();

            $result = $this->tiktokService->checkPublishStatus(
                $account->access_token,
                $request->publish_id
            );

            return response()->json([
                'success' => true,
                'data' => $result,
            ]);

        } catch (\Exception $e) {
            Log::error('TikTok check status error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Disconnect TikTok account
     */
    public function disconnect(int $accountId)
    {
        try {
            $account = SocialAccount::where('id', $accountId)
                ->where('user_id', Auth::id())
                ->where('platform', 'tiktok')
                ->firstOrFail();

            $account->update(['is_active' => false]);
            $account->delete();

            return response()->json([
                'success' => true,
                'message' => 'TikTok account disconnected successfully',
            ]);

        } catch (\Exception $e) {
            Log::error('TikTok disconnect error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Check service status
     */
    public function status()
    {
        return response()->json([
            'configured' => $this->tiktokService->isConfigured(),
            'platform' => 'tiktok',
            'api_version' => 'v2',
        ]);
    }
}
