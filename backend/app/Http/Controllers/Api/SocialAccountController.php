<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\UserSocialAccount;
use App\Services\SocialMedia\SocialPublishService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class SocialAccountController extends Controller
{
    protected SocialPublishService $publishService;

    public function __construct(SocialPublishService $publishService)
    {
        $this->publishService = $publishService;
    }

    /**
     * Get all connected social accounts for the authenticated user
     */
    public function index(Request $request)
    {
        $accounts = UserSocialAccount::where('user_id', $request->user()->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'accounts' => $accounts,
        ]);
    }

    /**
     * Get a specific social account
     */
    public function show(Request $request, int $id)
    {
        $account = UserSocialAccount::where('user_id', $request->user()->id)
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'account' => $account,
        ]);
    }

    /**
     * Connect a new social account
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'platform' => 'required|string|in:facebook,instagram,twitter,linkedin,tiktok,youtube,pinterest,threads,snapchat',
            'platform_user_id' => 'required|string',
            'username' => 'nullable|string',
            'display_name' => 'nullable|string',
            'profile_image_url' => 'nullable|url',
            'access_token' => 'required|string',
            'refresh_token' => 'nullable|string',
            'token_expires_at' => 'nullable|date',
            'platform_data' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            // Check if account already exists
            $existing = UserSocialAccount::where('user_id', $request->user()->id)
                ->where('platform', $request->platform)
                ->where('platform_user_id', $request->platform_user_id)
                ->first();

            if ($existing) {
                // Update existing account
                $existing->update($request->only([
                    'username',
                    'display_name',
                    'profile_image_url',
                    'access_token',
                    'refresh_token',
                    'token_expires_at',
                    'platform_data',
                ]));

                $existing->update([
                    'status' => 'active',
                    'failed_attempts' => 0,
                    'last_error' => null,
                ]);

                $account = $existing;
                $message = 'Social account updated successfully';
            } else {
                // Create new account
                $account = UserSocialAccount::create([
                    'user_id' => $request->user()->id,
                    'platform' => $request->platform,
                    'platform_user_id' => $request->platform_user_id,
                    'username' => $request->username,
                    'display_name' => $request->display_name,
                    'profile_image_url' => $request->profile_image_url,
                    'access_token' => $request->access_token,
                    'refresh_token' => $request->refresh_token,
                    'token_expires_at' => $request->token_expires_at,
                    'platform_data' => $request->platform_data,
                    'status' => 'active',
                ]);

                $message = 'Social account connected successfully';
            }

            return response()->json([
                'success' => true,
                'message' => $message,
                'account' => $account,
            ], $existing ? 200 : 201);

        } catch (\Exception $e) {
            Log::error('Failed to connect social account', [
                'user_id' => $request->user()->id,
                'platform' => $request->platform,
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to connect social account',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Update a social account
     */
    public function update(Request $request, int $id)
    {
        $account = UserSocialAccount::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'username' => 'sometimes|string',
            'display_name' => 'sometimes|string',
            'profile_image_url' => 'sometimes|url',
            'access_token' => 'sometimes|string',
            'refresh_token' => 'sometimes|string',
            'token_expires_at' => 'sometimes|date',
            'platform_data' => 'sometimes|array',
            'status' => 'sometimes|in:active,inactive,token_expired,authentication_failed,rate_limited,suspended',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $account->update($request->only([
            'username',
            'display_name',
            'profile_image_url',
            'access_token',
            'refresh_token',
            'token_expires_at',
            'platform_data',
            'status',
        ]));

        return response()->json([
            'success' => true,
            'message' => 'Social account updated successfully',
            'account' => $account->fresh(),
        ]);
    }

    /**
     * Delete a social account
     */
    public function destroy(Request $request, int $id)
    {
        $account = UserSocialAccount::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $account->delete();

        return response()->json([
            'success' => true,
            'message' => 'Social account deleted successfully',
        ]);
    }

    /**
     * Refresh access token for a social account
     */
    public function refreshToken(Request $request, int $id)
    {
        $account = UserSocialAccount::where('user_id', $request->user()->id)
            ->findOrFail($id);

        try {
            $success = $this->publishService->refreshAccountToken($account);

            if ($success) {
                return response()->json([
                    'success' => true,
                    'message' => 'Token refreshed successfully',
                    'account' => $account->fresh(),
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to refresh token',
                ], 400);
            }

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Token refresh failed',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get accounts that need token refresh
     */
    public function expiringSoon(Request $request)
    {
        $hours = $request->get('hours', 24);

        $accounts = UserSocialAccount::where('user_id', $request->user()->id)
            ->tokenExpiringSoon($hours)
            ->get();

        return response()->json([
            'success' => true,
            'accounts' => $accounts,
            'count' => $accounts->count(),
        ]);
    }
}
