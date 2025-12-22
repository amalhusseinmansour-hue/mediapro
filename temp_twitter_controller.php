<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\TwitterService;
use App\Models\SocialAccount;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;

class TwitterController extends Controller
{
    protected TwitterService $twitterService;

    public function __construct(TwitterService $twitterService)
    {
        $this->twitterService = $twitterService;
    }

    /**
     * Get OAuth authorization URL
     */
    public function getAuthUrl(Request $request): JsonResponse
    {
        try {
            $state = bin2hex(random_bytes(16));
            $authUrl = $this->twitterService->getAuthorizationUrl($state);

            return response()->json([
                'success' => true,
                'auth_url' => $authUrl,
                'state' => $state,
            ]);
        } catch (\Exception $e) {
            Log::error('Twitter auth URL generation failed', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Failed to generate auth URL: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Handle OAuth callback
     */
    public function callback(Request $request): JsonResponse
    {
        try {
            $code = $request->query('code');
            $state = $request->query('state');
            $error = $request->query('error');

            if ($error) {
                return response()->json([
                    'success' => false,
                    'error' => $request->query('error_description', 'Authorization denied'),
                ], 400);
            }

            if (!$code || !$state) {
                return response()->json([
                    'success' => false,
                    'error' => 'Missing authorization code or state',
                ], 400);
            }

            // Exchange code for token
            $tokenResult = $this->twitterService->exchangeCodeForToken($code, $state);

            if (!$tokenResult['success']) {
                return response()->json([
                    'success' => false,
                    'error' => $tokenResult['error'],
                ], 400);
            }

            $tokenData = $tokenResult['data'];
            $accessToken = $tokenData['access_token'];

            // Get user profile
            $profileResult = $this->twitterService->getUserProfile($accessToken);

            if (!$profileResult['success']) {
                return response()->json([
                    'success' => false,
                    'error' => 'Failed to get user profile',
                ], 400);
            }

            $profile = $profileResult['data'];

            // Save to database if user is authenticated
            if (auth()->check()) {
                $account = SocialAccount::updateOrCreate(
                    [
                        'user_id' => auth()->id(),
                        'platform' => 'twitter',
                        'account_id' => $profile['id'],
                    ],
                    [
                        'account_name' => $profile['name'],
                        'username' => $profile['username'],
                        'profile_image_url' => $profile['profile_image_url'] ?? null,
                        'access_token' => $accessToken,
                        'refresh_token' => $tokenData['refresh_token'] ?? null,
                        'expires_at' => isset($tokenData['expires_in'])
                            ? now()->addSeconds($tokenData['expires_in'])
                            : null,
                        'platform_data' => [
                            'verified' => $profile['verified'] ?? false,
                            'description' => $profile['description'] ?? '',
                            'public_metrics' => $profile['public_metrics'] ?? [],
                        ],
                        'is_active' => true,
                    ]
                );

                return response()->json([
                    'success' => true,
                    'message' => 'Twitter account connected successfully',
                    'data' => [
                        'id' => $account->id,
                        'platform' => 'twitter',
                        'account_name' => $profile['name'],
                        'username' => $profile['username'],
                        'profile_image_url' => $profile['profile_image_url'] ?? null,
                    ],
                ]);
            }

            // Return profile data for frontend to handle
            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $profile['id'],
                    'name' => $profile['name'],
                    'username' => $profile['username'],
                    'profile_image_url' => $profile['profile_image_url'] ?? null,
                    'access_token' => $accessToken,
                    'refresh_token' => $tokenData['refresh_token'] ?? null,
                    'expires_in' => $tokenData['expires_in'] ?? null,
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('Twitter callback failed', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get connected Twitter accounts
     */
    public function getAccounts(Request $request): JsonResponse
    {
        try {
            $accounts = SocialAccount::where('user_id', auth()->id())
                ->where('platform', 'twitter')
                ->where('is_active', true)
                ->get()
                ->map(function ($account) {
                    return [
                        'id' => $account->id,
                        'platform' => 'twitter',
                        'account_name' => $account->account_name,
                        'username' => $account->username,
                        'account_id' => $account->account_id,
                        'profile_image_url' => $account->profile_image_url,
                        'verified' => $account->platform_data['verified'] ?? false,
                        'connected_at' => $account->created_at,
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $accounts,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Post a tweet
     */
    public function post(Request $request): JsonResponse
    {
        $request->validate([
            'account_id' => 'required|integer',
            'text' => 'required|string|max:280',
            'media_urls' => 'nullable|array',
        ]);

        try {
            $account = SocialAccount::where('id', $request->account_id)
                ->where('user_id', auth()->id())
                ->where('platform', 'twitter')
                ->first();

            if (!$account) {
                return response()->json([
                    'success' => false,
                    'error' => 'Twitter account not found',
                ], 404);
            }

            $result = $this->twitterService->publishFromAccount(
                $account,
                $request->text,
                $request->media_urls ?? []
            );

            if ($result['success']) {
                return response()->json([
                    'success' => true,
                    'message' => 'Tweet posted successfully',
                    'data' => $result['data'],
                    'tweet_id' => $result['tweet_id'],
                ]);
            }

            return response()->json([
                'success' => false,
                'error' => $result['error'],
            ], 400);
        } catch (\Exception $e) {
            Log::error('Twitter post failed', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get account analytics
     */
    public function getAnalytics(Request $request, int $accountId): JsonResponse
    {
        try {
            $account = SocialAccount::where('id', $accountId)
                ->where('user_id', auth()->id())
                ->where('platform', 'twitter')
                ->first();

            if (!$account) {
                return response()->json([
                    'success' => false,
                    'error' => 'Twitter account not found',
                ], 404);
            }

            $result = $this->twitterService->getAccountAnalytics($account->account_id);

            if ($result['success']) {
                return response()->json([
                    'success' => true,
                    'data' => $result['data'],
                ]);
            }

            return response()->json([
                'success' => false,
                'error' => $result['error'],
            ], 400);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get user tweets
     */
    public function getTweets(Request $request, int $accountId): JsonResponse
    {
        try {
            $account = SocialAccount::where('id', $accountId)
                ->where('user_id', auth()->id())
                ->where('platform', 'twitter')
                ->first();

            if (!$account) {
                return response()->json([
                    'success' => false,
                    'error' => 'Twitter account not found',
                ], 404);
            }

            $maxResults = $request->query('limit', 10);
            $result = $this->twitterService->getUserTweets($account->account_id, $maxResults);

            if ($result['success']) {
                return response()->json([
                    'success' => true,
                    'data' => $result['data'],
                ]);
            }

            return response()->json([
                'success' => false,
                'error' => $result['error'],
            ], 400);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Delete a tweet
     */
    public function deleteTweet(Request $request, int $accountId, string $tweetId): JsonResponse
    {
        try {
            $account = SocialAccount::where('id', $accountId)
                ->where('user_id', auth()->id())
                ->where('platform', 'twitter')
                ->first();

            if (!$account) {
                return response()->json([
                    'success' => false,
                    'error' => 'Twitter account not found',
                ], 404);
            }

            $result = $this->twitterService->deleteTweet($account->access_token, $tweetId);

            if ($result['success']) {
                return response()->json([
                    'success' => true,
                    'message' => 'Tweet deleted successfully',
                ]);
            }

            return response()->json([
                'success' => false,
                'error' => $result['error'],
            ], 400);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Disconnect Twitter account
     */
    public function disconnect(Request $request, int $accountId): JsonResponse
    {
        try {
            $account = SocialAccount::where('id', $accountId)
                ->where('user_id', auth()->id())
                ->where('platform', 'twitter')
                ->first();

            if (!$account) {
                return response()->json([
                    'success' => false,
                    'error' => 'Twitter account not found',
                ], 404);
            }

            $account->update(['is_active' => false]);
            // Or delete: $account->delete();

            return response()->json([
                'success' => true,
                'message' => 'Twitter account disconnected successfully',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Lookup user by username (public)
     */
    public function lookupUser(Request $request): JsonResponse
    {
        $request->validate([
            'username' => 'required|string',
        ]);

        try {
            $result = $this->twitterService->getUserByUsername($request->username);

            if ($result['success']) {
                return response()->json([
                    'success' => true,
                    'data' => $result['data'],
                ]);
            }

            return response()->json([
                'success' => false,
                'error' => $result['error'],
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get service status
     */
    public function status(): JsonResponse
    {
        return response()->json([
            'configured' => $this->twitterService->isConfigured(),
            'platform' => 'twitter',
        ]);
    }
}
