<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\InstagramService;
use App\Models\SocialAccount;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class InstagramController extends Controller
{
    protected InstagramService $instagramService;

    public function __construct(InstagramService $instagramService)
    {
        $this->instagramService = $instagramService;
    }

    /**
     * Get OAuth authorization URL
     */
    public function getAuthUrl()
    {
        try {
            if (!$this->instagramService->isConfigured()) {
                return response()->json([
                    'success' => false,
                    'error' => 'Instagram API is not configured',
                ], 500);
            }

            $state = bin2hex(random_bytes(16));
            session(['instagram_oauth_state' => $state]);

            $authUrl = $this->instagramService->getAuthorizationUrl($state);

            return response()->json([
                'success' => true,
                'auth_url' => $authUrl,
                'state' => $state,
            ]);
        } catch (\Exception $e) {
            Log::error('Instagram auth URL error', ['error' => $e->getMessage()]);
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
                Log::error('Instagram OAuth error', [
                    'error' => $error,
                    'description' => $errorDescription,
                ]);
                return response()->json([
                    'success' => false,
                    'error' => $errorDescription ?? $error,
                ], 400);
            }

            if (!$code) {
                return response()->json([
                    'success' => false,
                    'error' => 'Missing authorization code',
                ], 400);
            }

            // Exchange code for token
            $tokenData = $this->instagramService->exchangeCodeForToken($code, $state ?? '');

            $accessToken = $tokenData['access_token'];
            $expiresIn = $tokenData['expires_in'] ?? 5184000;

            // Get Instagram accounts linked to Facebook pages
            $instagramAccounts = $this->instagramService->getInstagramAccounts($accessToken);

            if (empty($instagramAccounts)) {
                return response()->json([
                    'success' => false,
                    'error' => 'No Instagram Business accounts found. Please link your Instagram account to a Facebook Page first.',
                ], 400);
            }

            // Return the first account (or all accounts)
            $account = $instagramAccounts[0];

            $responseData = [
                'success' => true,
                'data' => [
                    'id' => $account['id'],
                    'username' => $account['username'],
                    'name' => $account['name'],
                    'profile_picture_url' => $account['profile_picture_url'],
                    'followers_count' => $account['followers_count'],
                    'follows_count' => $account['follows_count'],
                    'media_count' => $account['media_count'],
                    'page_id' => $account['page_id'],
                    'page_name' => $account['page_name'],
                    'access_token' => $account['page_access_token'], // Use page token for API calls
                    'user_access_token' => $accessToken,
                    'expires_in' => $expiresIn,
                ],
                'all_accounts' => $instagramAccounts,
            ];

            // If user is authenticated, save to database
            if (Auth::check()) {
                $user = Auth::user();

                $socialAccount = SocialAccount::updateOrCreate(
                    [
                        'user_id' => $user->id,
                        'platform' => 'instagram',
                        'account_id' => $account['id'],
                    ],
                    [
                        'account_name' => '@' . $account['username'],
                        'access_token' => $account['page_access_token'],
                        'profile_image_url' => $account['profile_picture_url'],
                        'is_active' => true,
                        'platform_data' => [
                            'ig_user_id' => $account['id'],
                            'username' => $account['username'],
                            'page_id' => $account['page_id'],
                            'page_name' => $account['page_name'],
                            'followers_count' => $account['followers_count'],
                            'follows_count' => $account['follows_count'],
                            'media_count' => $account['media_count'],
                            'user_access_token' => $accessToken,
                            'token_expires_at' => now()->addSeconds($expiresIn)->toIso8601String(),
                            'connected_at' => now()->toIso8601String(),
                        ],
                    ]
                );

                $responseData['data']['account_db_id'] = $socialAccount->id;
            }

            return response()->json($responseData);

        } catch (\Exception $e) {
            Log::error('Instagram callback error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get user's Instagram accounts
     */
    public function getAccounts()
    {
        try {
            $accounts = SocialAccount::where('user_id', Auth::id())
                ->where('platform', 'instagram')
                ->where('is_active', true)
                ->get();

            return response()->json([
                'success' => true,
                'data' => $accounts->map(function ($account) {
                    return [
                        'id' => $account->id,
                        'ig_user_id' => $account->account_id,
                        'username' => $account->platform_data['username'] ?? $account->account_name,
                        'name' => $account->account_name,
                        'picture' => $account->profile_image_url,
                        'followers_count' => $account->platform_data['followers_count'] ?? 0,
                        'follows_count' => $account->platform_data['follows_count'] ?? 0,
                        'media_count' => $account->platform_data['media_count'] ?? 0,
                        'connected_at' => $account->platform_data['connected_at'] ?? $account->created_at,
                    ];
                }),
            ]);
        } catch (\Exception $e) {
            Log::error('Instagram get accounts error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get account analytics/insights
     */
    public function getAnalytics(int $accountId)
    {
        try {
            $account = SocialAccount::where('id', $accountId)
                ->where('user_id', Auth::id())
                ->where('platform', 'instagram')
                ->firstOrFail();

            $igUserId = $account->platform_data['ig_user_id'] ?? $account->account_id;
            $analytics = $this->instagramService->getAccountInsights($account->access_token, $igUserId);

            return response()->json([
                'success' => true,
                'data' => $analytics,
            ]);

        } catch (\Exception $e) {
            Log::error('Instagram analytics error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get account media/posts
     */
    public function getMedia(Request $request, int $accountId)
    {
        try {
            $account = SocialAccount::where('id', $accountId)
                ->where('user_id', Auth::id())
                ->where('platform', 'instagram')
                ->firstOrFail();

            $limit = $request->get('limit', 25);
            $after = $request->get('after');

            $igUserId = $account->platform_data['ig_user_id'] ?? $account->account_id;
            $media = $this->instagramService->getMedia($account->access_token, $igUserId, $limit, $after);

            return response()->json([
                'success' => true,
                'data' => $media,
            ]);

        } catch (\Exception $e) {
            Log::error('Instagram get media error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Create a new post
     */
    public function createPost(Request $request)
    {
        try {
            $request->validate([
                'account_id' => 'required|integer',
                'caption' => 'nullable|string|max:2200',
                'image_url' => 'required_without:video_url|url',
                'video_url' => 'required_without:image_url|url',
                'media_type' => 'nullable|in:REELS,VIDEO',
                'cover_url' => 'nullable|url',
            ]);

            $account = SocialAccount::where('id', $request->account_id)
                ->where('user_id', Auth::id())
                ->where('platform', 'instagram')
                ->firstOrFail();

            $igUserId = $account->platform_data['ig_user_id'] ?? $account->account_id;

            $postData = [
                'caption' => $request->caption,
            ];

            if ($request->image_url) {
                $postData['image_url'] = $request->image_url;
            } elseif ($request->video_url) {
                $postData['video_url'] = $request->video_url;
                $postData['media_type'] = $request->media_type ?? 'REELS';
                if ($request->cover_url) {
                    $postData['cover_url'] = $request->cover_url;
                }
            }

            $result = $this->instagramService->createPost($account->access_token, $igUserId, $postData);

            return response()->json([
                'success' => true,
                'data' => $result,
                'message' => 'Post published successfully',
            ]);

        } catch (\Exception $e) {
            Log::error('Instagram create post error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get comments on a post
     */
    public function getComments(Request $request, int $accountId, string $mediaId)
    {
        try {
            $account = SocialAccount::where('id', $accountId)
                ->where('user_id', Auth::id())
                ->where('platform', 'instagram')
                ->firstOrFail();

            $comments = $this->instagramService->getComments($account->access_token, $mediaId);

            return response()->json([
                'success' => true,
                'data' => $comments,
            ]);

        } catch (\Exception $e) {
            Log::error('Instagram get comments error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Reply to a comment
     */
    public function replyToComment(Request $request, int $accountId, string $commentId)
    {
        try {
            $request->validate([
                'message' => 'required|string|max:1000',
            ]);

            $account = SocialAccount::where('id', $accountId)
                ->where('user_id', Auth::id())
                ->where('platform', 'instagram')
                ->firstOrFail();

            $result = $this->instagramService->replyToComment($account->access_token, $commentId, $request->message);

            return response()->json([
                'success' => true,
                'data' => $result,
            ]);

        } catch (\Exception $e) {
            Log::error('Instagram reply error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get media insights
     */
    public function getMediaInsights(int $accountId, string $mediaId)
    {
        try {
            $account = SocialAccount::where('id', $accountId)
                ->where('user_id', Auth::id())
                ->where('platform', 'instagram')
                ->firstOrFail();

            $insights = $this->instagramService->getMediaInsights($account->access_token, $mediaId);

            return response()->json([
                'success' => true,
                'data' => $insights,
            ]);

        } catch (\Exception $e) {
            Log::error('Instagram media insights error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Search hashtag
     */
    public function searchHashtag(Request $request, int $accountId)
    {
        try {
            $request->validate([
                'hashtag' => 'required|string|max:100',
            ]);

            $account = SocialAccount::where('id', $accountId)
                ->where('user_id', Auth::id())
                ->where('platform', 'instagram')
                ->firstOrFail();

            $igUserId = $account->platform_data['ig_user_id'] ?? $account->account_id;
            $results = $this->instagramService->searchHashtag($account->access_token, $igUserId, $request->hashtag);

            return response()->json([
                'success' => true,
                'data' => $results,
            ]);

        } catch (\Exception $e) {
            Log::error('Instagram hashtag search error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Disconnect Instagram account
     */
    public function disconnect(int $accountId)
    {
        try {
            $account = SocialAccount::where('id', $accountId)
                ->where('user_id', Auth::id())
                ->where('platform', 'instagram')
                ->firstOrFail();

            $account->update(['is_active' => false]);
            $account->delete();

            return response()->json([
                'success' => true,
                'message' => 'Instagram account disconnected successfully',
            ]);

        } catch (\Exception $e) {
            Log::error('Instagram disconnect error', ['error' => $e->getMessage()]);
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
            'configured' => $this->instagramService->isConfigured(),
            'platform' => 'instagram',
            'api_version' => 'v18.0',
            'note' => 'Instagram Business API (requires Facebook Page)',
        ]);
    }
}
