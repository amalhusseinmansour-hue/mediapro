<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ConnectedAccount;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;

class ConnectedAccountController extends Controller
{
    /**
     * Get all connected accounts for the authenticated user
     */
    public function index(Request $request): JsonResponse
    {
        try {
            // Try to get authenticated user ID
            $user = $request->user();
            $userId = $user ? $user->id : ($request->user_id ?? null);

            // If no user ID, return empty array (not an error)
            if (!$userId) {
                return response()->json([
                    'success' => true,
                    'message' => 'لا توجد حسابات متصلة',
                    'accounts' => [],
                ], 200);
            }

            // Check if ConnectedAccount model exists
            if (!class_exists(ConnectedAccount::class)) {
                return response()->json([
                    'success' => true,
                    'message' => 'لا توجد حسابات متصلة',
                    'accounts' => [],
                ], 200);
            }

            $accounts = ConnectedAccount::where('user_id', $userId)
                ->where('is_active', true)
                ->get()
                ->map(function ($account) {
                    return [
                        'id' => $account->id,
                        'platform' => $account->platform ?? 'unknown',
                        'platform_name' => $account->platform_name ?? ucfirst($account->platform ?? 'Unknown'),
                        'platform_icon' => $account->platform_icon ?? null,
                        'platform_color' => $account->platform_color ?? '#000000',
                        'username' => $account->username ?? '',
                        'display_name' => $account->display_name ?? $account->username ?? '',
                        'profile_picture' => $account->profile_picture ?? null,
                        'is_active' => $account->is_active ?? true,
                        'connected_at' => $account->connected_at?->toIso8601String(),
                        'last_used_at' => $account->last_used_at?->toIso8601String(),
                    ];
                });

            return response()->json([
                'success' => true,
                'accounts' => $accounts,
            ], 200);

        } catch (\Exception $e) {
            \Log::error('ConnectedAccount index error: ' . $e->getMessage());
            \Log::error('Stack trace: ' . $e->getTraceAsString());

            return response()->json([
                'success' => true,
                'message' => 'لا توجد حسابات متصلة',
                'accounts' => [],
                'error' => config('app.debug') ? $e->getMessage() : null,
            ], 200);
        }
    }

    /**
     * Connect a new social media account
     */
    public function connect(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'platform' => 'required|string|in:facebook,instagram,twitter,linkedin,tiktok,youtube,snapchat,pinterest',
            'access_token' => 'required|string',
            'platform_user_id' => 'nullable|string',
            'username' => 'nullable|string',
            'display_name' => 'nullable|string',
            'profile_picture' => 'nullable|url',
            'email' => 'nullable|email',
            'refresh_token' => 'nullable|string',
            'expires_in' => 'nullable|integer', // seconds until expiration
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صحيحة',
                'errors' => $validator->errors(),
            ], 422);
        }

        $userId = Auth::id();
        
        if (!$userId) {
            return response()->json([
                'success' => false,
                'message' => 'يجب عليك تسجيل الدخول أولاً',
            ], 401);
        }

        try {
            // Check if account already connected
            $existingAccount = ConnectedAccount::byUser($userId)
                ->byPlatform($request->platform)
                ->first();

            if ($existingAccount) {
                // Update existing account
                $existingAccount->update([
                    'platform_user_id' => $request->platform_user_id ?? $existingAccount->platform_user_id,
                    'username' => $request->username ?? $existingAccount->username,
                    'display_name' => $request->display_name ?? $existingAccount->display_name,
                    'profile_picture' => $request->profile_picture ?? $existingAccount->profile_picture,
                    'email' => $request->email ?? $existingAccount->email,
                    'access_token' => encrypt($request->access_token),
                    'refresh_token' => $request->refresh_token ? encrypt($request->refresh_token) : $existingAccount->refresh_token,
                    'token_expires_at' => $request->expires_in ? now()->addSeconds($request->expires_in) : null,
                    'is_active' => true,
                    'connected_at' => now(),
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'تم تحديث ربط الحساب بنجاح',
                    'account' => [
                        'id' => $existingAccount->id,
                        'platform' => $existingAccount->platform,
                        'platform_name' => $existingAccount->platform_name,
                        'username' => $existingAccount->username,
                        'display_name' => $existingAccount->display_name,
                        'profile_picture' => $existingAccount->profile_picture,
                    ],
                ]);
            }

            // Create new connected account
            $account = ConnectedAccount::create([
                'user_id' => $userId,
                'platform' => $request->platform,
                'platform_user_id' => $request->platform_user_id,
                'username' => $request->username,
                'display_name' => $request->display_name,
                'profile_picture' => $request->profile_picture,
                'email' => $request->email,
                'access_token' => encrypt($request->access_token),
                'refresh_token' => $request->refresh_token ? encrypt($request->refresh_token) : null,
                'token_expires_at' => $request->expires_in ? now()->addSeconds($request->expires_in) : null,
                'is_active' => true,
                'connected_at' => now(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'تم ربط الحساب بنجاح',
                'account' => [
                    'id' => $account->id,
                    'platform' => $account->platform,
                    'platform_name' => $account->platform_name,
                    'username' => $account->username,
                    'display_name' => $account->display_name,
                    'profile_picture' => $account->profile_picture,
                ],
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل ربط الحساب. حاول مرة أخرى.',
                'error' => config('app.debug') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Get a specific connected account
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $userId = Auth::id();

        if (!$userId) {
            return response()->json([
                'success' => false,
                'message' => 'يجب عليك تسجيل الدخول أولاً',
            ], 401);
        }

        $account = ConnectedAccount::byUser($userId)->find($id);

        if (!$account) {
            return response()->json([
                'success' => false,
                'message' => 'الحساب غير موجود',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $account->id,
                'platform' => $account->platform,
                'platform_name' => $account->platform_name,
                'username' => $account->username,
                'display_name' => $account->display_name,
                'profile_picture' => $account->profile_picture,
                'is_active' => $account->is_active,
                'connected_at' => $account->connected_at?->toIso8601String(),
                'last_used_at' => $account->last_used_at?->toIso8601String(),
            ],
        ]);
    }

    /**
     * Update a connected account
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $userId = Auth::id();

        if (!$userId) {
            return response()->json([
                'success' => false,
                'message' => 'يجب عليك تسجيل الدخول أولاً',
            ], 401);
        }

        $account = ConnectedAccount::byUser($userId)->find($id);

        if (!$account) {
            return response()->json([
                'success' => false,
                'message' => 'الحساب غير موجود',
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'display_name' => 'nullable|string',
            'is_active' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صحيحة',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $updates = [];
            if ($request->has('display_name')) {
                $updates['display_name'] = $request->display_name;
            }
            if ($request->has('is_active')) {
                $updates['is_active'] = $request->is_active;
            }

            if (!empty($updates)) {
                $account->update($updates);
            }

            return response()->json([
                'success' => true,
                'message' => 'تم تحديث الحساب بنجاح',
                'data' => [
                    'id' => $account->id,
                    'platform' => $account->platform,
                    'username' => $account->username,
                    'display_name' => $account->display_name,
                    'is_active' => $account->is_active,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل تحديث الحساب',
                'error' => config('app.debug') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Disconnect a connected account
     */
    public function disconnect(Request $request, int $id): JsonResponse
    {
        $userId = Auth::id();

        if (!$userId) {
            return response()->json([
                'success' => false,
                'message' => 'يجب عليك تسجيل الدخول أولاً',
            ], 401);
        }

        $account = ConnectedAccount::byUser($userId)->find($id);

        if (!$account) {
            return response()->json([
                'success' => false,
                'message' => 'الحساب غير موجود',
            ], 404);
        }

        try {
            $account->delete();

            return response()->json([
                'success' => true,
                'message' => 'تم فك ربط الحساب بنجاح',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل فك ربط الحساب',
                'error' => config('app.debug') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Toggle account active status
     */
    public function toggleStatus(Request $request, int $id): JsonResponse
    {
        $userId = Auth::id();

        if (!$userId) {
            return response()->json([
                'success' => false,
                'message' => 'يجب عليك تسجيل الدخول أولاً',
            ], 401);
        }

        $account = ConnectedAccount::byUser($userId)->find($id);

        if (!$account) {
            return response()->json([
                'success' => false,
                'message' => 'الحساب غير موجود',
            ], 404);
        }

        try {
            $account->update([
                'is_active' => !$account->is_active,
            ]);

            return response()->json([
                'success' => true,
                'message' => $account->is_active ? 'تم تفعيل الحساب' : 'تم تعطيل الحساب',
                'is_active' => $account->is_active,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل تحديث حالة الحساب',
                'error' => config('app.debug') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Get supported platforms
     */
    public function platforms(): JsonResponse
    {
        $platforms = [
            [
                'id' => 'facebook',
                'name' => 'Facebook',
                'name_ar' => 'فيسبوك',
                'icon' => 'facebook',
                'color' => '#1877F2',
                'supported' => true,
            ],
            [
                'id' => 'instagram',
                'name' => 'Instagram',
                'name_ar' => 'إنستغرام',
                'icon' => 'instagram',
                'color' => '#E4405F',
                'supported' => true,
            ],
            [
                'id' => 'twitter',
                'name' => 'Twitter (X)',
                'name_ar' => 'تويتر',
                'icon' => 'twitter',
                'color' => '#1DA1F2',
                'supported' => true,
            ],
            [
                'id' => 'linkedin',
                'name' => 'LinkedIn',
                'name_ar' => 'لينكد إن',
                'icon' => 'linkedin',
                'color' => '#0A66C2',
                'supported' => true,
            ],
            [
                'id' => 'tiktok',
                'name' => 'TikTok',
                'name_ar' => 'تيك توك',
                'icon' => 'tiktok',
                'color' => '#000000',
                'supported' => true,
            ],
            [
                'id' => 'youtube',
                'name' => 'YouTube',
                'name_ar' => 'يوتيوب',
                'icon' => 'youtube',
                'color' => '#FF0000',
                'supported' => true,
            ],
            [
                'id' => 'snapchat',
                'name' => 'Snapchat',
                'name_ar' => 'سناب شات',
                'icon' => 'snapchat',
                'color' => '#FFFC00',
                'supported' => true,
            ],
            [
                'id' => 'pinterest',
                'name' => 'Pinterest',
                'name_ar' => 'بينتريست',
                'icon' => 'pinterest',
                'color' => '#E60023',
                'supported' => true,
            ],
        ];

        return response()->json([
            'success' => true,
            'platforms' => $platforms,
        ]);
    }

    /**
     * Get statistics for connected accounts
     */
    public function statistics(Request $request): JsonResponse
    {
        $userId = $request->user_id ?? Auth::id();

        $totalAccounts = ConnectedAccount::byUser($userId)->count();
        $activeAccounts = ConnectedAccount::byUser($userId)->active()->count();
        $inactiveAccounts = $totalAccounts - $activeAccounts;

        $accountsByPlatform = ConnectedAccount::byUser($userId)
            ->selectRaw('platform, count(*) as count')
            ->groupBy('platform')
            ->get()
            ->pluck('count', 'platform');

        return response()->json([
            'success' => true,
            'statistics' => [
                'total_accounts' => $totalAccounts,
                'active_accounts' => $activeAccounts,
                'inactive_accounts' => $inactiveAccounts,
                'by_platform' => $accountsByPlatform,
            ],
        ]);
    }
}
