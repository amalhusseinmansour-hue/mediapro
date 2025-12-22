<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SocialAccount;
use App\Services\LinkedInService;
use App\Services\LinkedInAnalyticsService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;

class LinkedInController extends Controller
{
    private LinkedInService $linkedInService;
    private LinkedInAnalyticsService $analyticsService;

    public function __construct(LinkedInService $linkedInService, LinkedInAnalyticsService $analyticsService)
    {
        $this->linkedInService = $linkedInService;
        $this->analyticsService = $analyticsService;
    }

    /**
     * Get OAuth authorization URL
     */
    public function getAuthUrl(Request $request): JsonResponse
    {
        $state = bin2hex(random_bytes(16));

        // Store state in session or cache for verification
        session(['linkedin_oauth_state' => $state]);

        $authUrl = $this->linkedInService->getAuthorizationUrl($state);

        return response()->json([
            'success' => true,
            'auth_url' => $authUrl,
            'state' => $state,
        ]);
    }

    /**
     * Handle OAuth callback and connect account
     */
    public function callback(Request $request): JsonResponse
    {
        Log::info('LinkedIn OAuth callback', $request->all());

        if ($request->has('error')) {
            return response()->json([
                'success' => false,
                'error' => $request->input('error'),
                'error_description' => $request->input('error_description'),
            ], 400);
        }

        $code = $request->input('code');
        if (!$code) {
            return response()->json([
                'success' => false,
                'error' => 'No authorization code received',
            ], 400);
        }

        // Exchange code for token
        $tokenResult = $this->linkedInService->exchangeCodeForToken($code);

        if (!$tokenResult['success']) {
            return response()->json([
                'success' => false,
                'error' => $tokenResult['error'],
            ], 400);
        }

        $accessToken = $tokenResult['data']['access_token'];
        $expiresIn = $tokenResult['data']['expires_in'] ?? 3600;
        $refreshToken = $tokenResult['data']['refresh_token'] ?? null;

        // Get user profile
        $profileResult = $this->linkedInService->getUserProfile($accessToken);

        if (!$profileResult['success']) {
            return response()->json([
                'success' => false,
                'error' => 'Failed to fetch profile',
            ], 400);
        }

        $profile = $profileResult['data'];

        return response()->json([
            'success' => true,
            'data' => [
                'access_token' => $accessToken,
                'refresh_token' => $refreshToken,
                'expires_in' => $expiresIn,
                'profile' => [
                    'id' => $profile['sub'] ?? null,
                    'name' => $profile['name'] ?? null,
                    'email' => $profile['email'] ?? null,
                    'picture' => $profile['picture'] ?? null,
                ],
            ],
        ]);
    }

    /**
     * Connect LinkedIn account to user
     */
    public function connect(Request $request): JsonResponse
    {
        $request->validate([
            'access_token' => 'required|string',
            'refresh_token' => 'nullable|string',
            'expires_in' => 'required|integer',
            'account_id' => 'required|string',
            'account_name' => 'required|string',
        ]);

        try {
            $account = SocialAccount::updateOrCreate(
                [
                    'user_id' => $request->user()->id,
                    'platform' => 'linkedin',
                    'account_id' => $request->input('account_id'),
                ],
                [
                    'account_name' => $request->input('account_name'),
                    'access_token' => $request->input('access_token'),
                    'refresh_token' => $request->input('refresh_token'),
                    'expires_at' => now()->addSeconds($request->input('expires_in')),
                    'is_active' => true,
                ]
            );

            return response()->json([
                'success' => true,
                'message' => 'LinkedIn account connected successfully',
                'data' => $account,
            ]);
        } catch (\Exception $e) {
            Log::error('LinkedIn connect error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Disconnect LinkedIn account
     */
    public function disconnect(Request $request, int $accountId): JsonResponse
    {
        try {
            $account = SocialAccount::where('user_id', $request->user()->id)
                ->where('platform', 'linkedin')
                ->findOrFail($accountId);

            $account->delete();

            return response()->json([
                'success' => true,
                'message' => 'LinkedIn account disconnected',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Account not found',
            ], 404);
        }
    }

    /**
     * Create a post on LinkedIn
     */
    public function createPost(Request $request): JsonResponse
    {
        $request->validate([
            'account_id' => 'required|integer',
            'text' => 'required|string|max:3000',
            'media_urls' => 'nullable|array',
            'media_urls.*' => 'url',
            'visibility' => 'nullable|string|in:PUBLIC,CONNECTIONS',
        ]);

        try {
            $account = SocialAccount::where('user_id', $request->user()->id)
                ->where('platform', 'linkedin')
                ->findOrFail($request->input('account_id'));

            $result = $this->linkedInService->publishFromAccount(
                $account,
                $request->input('text'),
                $request->input('media_urls', [])
            );

            if ($result['success']) {
                return response()->json([
                    'success' => true,
                    'message' => 'Post created successfully',
                    'data' => $result,
                ]);
            }

            return response()->json([
                'success' => false,
                'error' => $result['error'] ?? 'Failed to create post',
            ], 400);
        } catch (\Exception $e) {
            Log::error('LinkedIn create post error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Delete a post from LinkedIn
     */
    public function deletePost(Request $request): JsonResponse
    {
        $request->validate([
            'account_id' => 'required|integer',
            'post_urn' => 'required|string',
        ]);

        try {
            $account = SocialAccount::where('user_id', $request->user()->id)
                ->where('platform', 'linkedin')
                ->findOrFail($request->input('account_id'));

            $result = $this->linkedInService->deletePost(
                $account->access_token,
                $request->input('post_urn')
            );

            if ($result['success']) {
                return response()->json([
                    'success' => true,
                    'message' => 'Post deleted successfully',
                ]);
            }

            return response()->json([
                'success' => false,
                'error' => $result['error'] ?? 'Failed to delete post',
            ], 400);
        } catch (\Exception $e) {
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
            $account = SocialAccount::where('user_id', $request->user()->id)
                ->where('platform', 'linkedin')
                ->findOrFail($accountId);

            $analytics = $this->analyticsService->getAccountAnalytics($account);

            return response()->json($analytics);
        } catch (\Exception $e) {
            Log::error('LinkedIn analytics error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get user's posts
     */
    public function getPosts(Request $request, int $accountId): JsonResponse
    {
        try {
            $account = SocialAccount::where('user_id', $request->user()->id)
                ->where('platform', 'linkedin')
                ->findOrFail($accountId);

            $personUrn = 'urn:li:person:' . $account->account_id;
            $count = $request->input('count', 20);

            $posts = $this->analyticsService->getUserPosts($account->access_token, $personUrn, $count);

            return response()->json($posts);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get post statistics
     */
    public function getPostStats(Request $request): JsonResponse
    {
        $request->validate([
            'account_id' => 'required|integer',
            'post_urn' => 'required|string',
        ]);

        try {
            $account = SocialAccount::where('user_id', $request->user()->id)
                ->where('platform', 'linkedin')
                ->findOrFail($request->input('account_id'));

            $stats = $this->analyticsService->getShareStats(
                $account->access_token,
                $request->input('post_urn')
            );

            return response()->json($stats);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get post comments
     */
    public function getComments(Request $request): JsonResponse
    {
        $request->validate([
            'account_id' => 'required|integer',
            'post_urn' => 'required|string',
        ]);

        try {
            $account = SocialAccount::where('user_id', $request->user()->id)
                ->where('platform', 'linkedin')
                ->findOrFail($request->input('account_id'));

            $comments = $this->analyticsService->getPostComments(
                $account->access_token,
                $request->input('post_urn'),
                $request->input('count', 50)
            );

            return response()->json($comments);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Like a post
     */
    public function likePost(Request $request): JsonResponse
    {
        $request->validate([
            'account_id' => 'required|integer',
            'post_urn' => 'required|string',
        ]);

        try {
            $account = SocialAccount::where('user_id', $request->user()->id)
                ->where('platform', 'linkedin')
                ->findOrFail($request->input('account_id'));

            $actorUrn = 'urn:li:person:' . $account->account_id;

            $result = $this->analyticsService->likePost(
                $account->access_token,
                $request->input('post_urn'),
                $actorUrn
            );

            return response()->json($result);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Comment on a post
     */
    public function commentPost(Request $request): JsonResponse
    {
        $request->validate([
            'account_id' => 'required|integer',
            'post_urn' => 'required|string',
            'comment' => 'required|string|max:1250',
        ]);

        try {
            $account = SocialAccount::where('user_id', $request->user()->id)
                ->where('platform', 'linkedin')
                ->findOrFail($request->input('account_id'));

            $actorUrn = 'urn:li:person:' . $account->account_id;

            $result = $this->analyticsService->commentOnPost(
                $account->access_token,
                $request->input('post_urn'),
                $request->input('comment'),
                $actorUrn
            );

            return response()->json($result);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Refresh account token
     */
    public function refreshToken(Request $request, int $accountId): JsonResponse
    {
        try {
            $account = SocialAccount::where('user_id', $request->user()->id)
                ->where('platform', 'linkedin')
                ->findOrFail($accountId);

            if (!$account->refresh_token) {
                return response()->json([
                    'success' => false,
                    'error' => 'No refresh token available',
                ], 400);
            }

            $result = $this->linkedInService->refreshToken($account->refresh_token);

            if ($result['success']) {
                $account->update([
                    'access_token' => $result['data']['access_token'],
                    'refresh_token' => $result['data']['refresh_token'] ?? $account->refresh_token,
                    'expires_at' => now()->addSeconds($result['data']['expires_in']),
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Token refreshed successfully',
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
     * Get connected LinkedIn accounts
     */
    public function getAccounts(Request $request): JsonResponse
    {
        try {
            $accounts = SocialAccount::where('user_id', $request->user()->id)
                ->where('platform', 'linkedin')
                ->get();

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
     * Get profile information for a connected account
     */
    public function getProfile(Request $request, int $accountId): JsonResponse
    {
        try {
            $account = SocialAccount::where('user_id', $request->user()->id)
                ->where('platform', 'linkedin')
                ->findOrFail($accountId);

            $profile = $this->linkedInService->getUserProfile($account->access_token);

            return response()->json($profile);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
