<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\YouTubeService;
use App\Models\SocialAccount;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class YouTubeController extends Controller
{
    protected YouTubeService $youtubeService;

    public function __construct(YouTubeService $youtubeService)
    {
        $this->youtubeService = $youtubeService;
    }

    /**
     * Get OAuth authorization URL
     */
    public function getAuthUrl()
    {
        try {
            if (!$this->youtubeService->isConfigured()) {
                return response()->json([
                    'success' => false,
                    'error' => 'YouTube API is not configured',
                ], 500);
            }

            $result = $this->youtubeService->getAuthorizationUrl();

            return response()->json([
                'success' => true,
                'auth_url' => $result['auth_url'],
                'state' => $result['state'],
            ]);
        } catch (\Exception $e) {
            Log::error('YouTube auth URL error', ['error' => $e->getMessage()]);
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
                Log::error('YouTube OAuth error', [
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
            $tokenData = $this->youtubeService->exchangeCodeForToken($code, $state);

            $accessToken = $tokenData['access_token'];
            $refreshToken = $tokenData['refresh_token'] ?? null;
            $expiresIn = $tokenData['expires_in'] ?? 3600;

            // Get user info and channel info
            $userInfo = $this->youtubeService->getUserInfo($accessToken);
            $channelInfo = $this->youtubeService->getChannelInfo($accessToken);

            $snippet = $channelInfo['snippet'] ?? [];
            $statistics = $channelInfo['statistics'] ?? [];

            // Prepare response data
            $responseData = [
                'success' => true,
                'data' => [
                    'id' => $channelInfo['id'] ?? $userInfo['id'] ?? null,
                    'channel_id' => $channelInfo['id'] ?? null,
                    'name' => $snippet['title'] ?? $userInfo['name'] ?? 'YouTube User',
                    'email' => $userInfo['email'] ?? null,
                    'picture' => $userInfo['picture'] ?? $snippet['thumbnails']['high']['url'] ?? null,
                    'channel_title' => $snippet['title'] ?? '',
                    'channel_description' => $snippet['description'] ?? '',
                    'custom_url' => $snippet['customUrl'] ?? '',
                    'subscriber_count' => (int)($statistics['subscriberCount'] ?? 0),
                    'video_count' => (int)($statistics['videoCount'] ?? 0),
                    'view_count' => (int)($statistics['viewCount'] ?? 0),
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
                        'platform' => 'youtube',
                        'account_id' => $responseData['data']['channel_id'] ?? $responseData['data']['id'],
                    ],
                    [
                        'account_name' => $responseData['data']['name'],
                        'access_token' => $accessToken,
                        'profile_image_url' => $responseData['data']['picture'],
                        'is_active' => true,
                        'platform_data' => [
                            'channel_id' => $responseData['data']['channel_id'],
                            'email' => $responseData['data']['email'],
                            'channel_title' => $responseData['data']['channel_title'],
                            'channel_description' => $responseData['data']['channel_description'],
                            'custom_url' => $responseData['data']['custom_url'],
                            'subscriber_count' => $responseData['data']['subscriber_count'],
                            'video_count' => $responseData['data']['video_count'],
                            'view_count' => $responseData['data']['view_count'],
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
            Log::error('YouTube callback error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get user's YouTube accounts
     */
    public function getAccounts()
    {
        try {
            $accounts = SocialAccount::where('user_id', Auth::id())
                ->where('platform', 'youtube')
                ->where('is_active', true)
                ->get();

            return response()->json([
                'success' => true,
                'data' => $accounts->map(function ($account) {
                    return [
                        'id' => $account->id,
                        'channel_id' => $account->account_id,
                        'name' => $account->account_name,
                        'picture' => $account->profile_image_url,
                        'channel_title' => $account->platform_data['channel_title'] ?? null,
                        'custom_url' => $account->platform_data['custom_url'] ?? null,
                        'subscriber_count' => $account->platform_data['subscriber_count'] ?? 0,
                        'video_count' => $account->platform_data['video_count'] ?? 0,
                        'view_count' => $account->platform_data['view_count'] ?? 0,
                        'connected_at' => $account->platform_data['connected_at'] ?? $account->created_at,
                    ];
                }),
            ]);
        } catch (\Exception $e) {
            Log::error('YouTube get accounts error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get channel videos
     */
    public function getVideos(Request $request, int $accountId)
    {
        try {
            $account = SocialAccount::where('id', $accountId)
                ->where('user_id', Auth::id())
                ->where('platform', 'youtube')
                ->firstOrFail();

            $maxResults = $request->get('limit', 20);
            $pageToken = $request->get('page_token');

            $result = $this->youtubeService->getChannelVideos(
                $account->access_token,
                $maxResults,
                $pageToken
            );

            return response()->json([
                'success' => true,
                'data' => $result,
            ]);

        } catch (\Exception $e) {
            Log::error('YouTube get videos error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get account/channel analytics
     */
    public function getAnalytics(int $accountId)
    {
        try {
            $account = SocialAccount::where('id', $accountId)
                ->where('user_id', Auth::id())
                ->where('platform', 'youtube')
                ->firstOrFail();

            $analytics = $this->youtubeService->getChannelAnalytics($account->access_token);

            return response()->json([
                'success' => true,
                'data' => $analytics,
            ]);

        } catch (\Exception $e) {
            Log::error('YouTube analytics error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get video analytics
     */
    public function getVideoAnalytics(int $accountId, string $videoId)
    {
        try {
            $account = SocialAccount::where('id', $accountId)
                ->where('user_id', Auth::id())
                ->where('platform', 'youtube')
                ->firstOrFail();

            $analytics = $this->youtubeService->getVideoAnalytics($account->access_token, $videoId);

            return response()->json([
                'success' => true,
                'data' => $analytics,
            ]);

        } catch (\Exception $e) {
            Log::error('YouTube video analytics error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Initialize video upload
     */
    public function initUpload(Request $request, int $accountId)
    {
        try {
            $request->validate([
                'title' => 'required|string|max:100',
                'description' => 'nullable|string|max:5000',
                'tags' => 'nullable|array',
                'privacy_status' => 'nullable|in:public,private,unlisted',
                'category_id' => 'nullable|string',
            ]);

            $account = SocialAccount::where('id', $accountId)
                ->where('user_id', Auth::id())
                ->where('platform', 'youtube')
                ->firstOrFail();

            $result = $this->youtubeService->publishFromAccount($account, [
                'title' => $request->title,
                'description' => $request->description ?? '',
                'tags' => $request->tags ?? [],
                'privacy_status' => $request->privacy_status ?? 'private',
                'category_id' => $request->category_id ?? '22',
            ]);

            return response()->json([
                'success' => true,
                'data' => $result,
                'message' => 'Upload initialized. Use the upload_url to upload your video.',
            ]);

        } catch (\Exception $e) {
            Log::error('YouTube init upload error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Update video metadata
     */
    public function updateVideo(Request $request, int $accountId, string $videoId)
    {
        try {
            $request->validate([
                'title' => 'required|string|max:100',
                'description' => 'nullable|string|max:5000',
                'tags' => 'nullable|array',
                'privacy_status' => 'nullable|in:public,private,unlisted',
            ]);

            $account = SocialAccount::where('id', $accountId)
                ->where('user_id', Auth::id())
                ->where('platform', 'youtube')
                ->firstOrFail();

            $result = $this->youtubeService->updateVideo($account->access_token, $videoId, [
                'title' => $request->title,
                'description' => $request->description ?? '',
                'tags' => $request->tags ?? [],
                'privacy_status' => $request->privacy_status ?? 'private',
            ]);

            return response()->json([
                'success' => true,
                'data' => $result,
            ]);

        } catch (\Exception $e) {
            Log::error('YouTube update video error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Delete video
     */
    public function deleteVideo(int $accountId, string $videoId)
    {
        try {
            $account = SocialAccount::where('id', $accountId)
                ->where('user_id', Auth::id())
                ->where('platform', 'youtube')
                ->firstOrFail();

            $result = $this->youtubeService->deleteVideo($account->access_token, $videoId);

            return response()->json([
                'success' => $result,
                'message' => $result ? 'Video deleted successfully' : 'Failed to delete video',
            ]);

        } catch (\Exception $e) {
            Log::error('YouTube delete video error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Disconnect YouTube account
     */
    public function disconnect(int $accountId)
    {
        try {
            $account = SocialAccount::where('id', $accountId)
                ->where('user_id', Auth::id())
                ->where('platform', 'youtube')
                ->firstOrFail();

            $account->update(['is_active' => false]);
            $account->delete();

            return response()->json([
                'success' => true,
                'message' => 'YouTube account disconnected successfully',
            ]);

        } catch (\Exception $e) {
            Log::error('YouTube disconnect error', ['error' => $e->getMessage()]);
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
            'configured' => $this->youtubeService->isConfigured(),
            'platform' => 'youtube',
            'api_version' => 'v3',
        ]);
    }
}
