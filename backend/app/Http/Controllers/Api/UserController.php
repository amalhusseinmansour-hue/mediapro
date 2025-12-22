<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    /**
     * Display a listing of users.
     */
    public function index(Request $request): JsonResponse
    {
        $users = User::query()
            ->when($request->search, function ($query, $search) {
                $query->where('name', 'like', "%{$search}%")
                      ->orWhere('email', 'like', "%{$search}%")
                      ->orWhere('phone', 'like', "%{$search}%");
            })
            ->latest()
            ->paginate($request->per_page ?? 15);

        return response()->json($users);
    }

    /**
     * Store a newly created user.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'phone' => 'nullable|string|max:20',
            'password' => 'nullable|string|min:8',
            'subscription_type' => 'nullable|string',
            'subscription_tier' => 'nullable|string',
            'user_type' => 'nullable|string',
        ]);

        // If password is provided, hash it; otherwise, generate a random one
        $validated['password'] = $validated['password']
            ? Hash::make($validated['password'])
            : Hash::make(bin2hex(random_bytes(16)));

        $user = User::create($validated);

        return response()->json([
            'message' => 'تم إنشاء المستخدم بنجاح',
            'user' => $user,
        ], 201);
    }

    /**
     * Display the specified user.
     */
    public function show(string $id): JsonResponse
    {
        $user = User::findOrFail($id);

        return response()->json($user);
    }

    /**
     * Update the specified user.
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $user = User::findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'email' => 'sometimes|required|string|email|max:255|unique:users,email,' . $id,
            'phone' => 'nullable|string|max:20',
            'password' => 'nullable|string|min:8',
            'subscription_type' => 'nullable|string',
            'subscription_tier' => 'nullable|string',
            'user_type' => 'nullable|string',
        ]);

        // Only hash password if it's being updated
        if (isset($validated['password'])) {
            $validated['password'] = Hash::make($validated['password']);
        }

        $user->update($validated);

        return response()->json([
            'message' => 'تم تحديث المستخدم بنجاح',
            'user' => $user,
        ]);
    }

    /**
     * Remove the specified user.
     */
    public function destroy(string $id): JsonResponse
    {
        $user = User::findOrFail($id);
        $user->delete();

        return response()->json([
            'message' => 'تم حذف المستخدم بنجاح',
        ]);
    }

    /**
     * Get current authenticated user.
     */
    public function me(Request $request): JsonResponse
    {
        return response()->json($request->user());
    }

    /**
     * Update current user's profile.
     */
    public function updateProfile(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'email' => 'sometimes|required|string|email|max:255|unique:users,email,' . $user->id,
            'phone' => 'nullable|string|max:20',
        ]);

        $user->update($validated);

        return response()->json([
            'message' => 'تم تحديث الملف الشخصي بنجاح',
            'user' => $user,
        ]);
    }

    /**
     * Update current user's password.
     */
    public function updatePassword(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'current_password' => 'required|string',
            'new_password' => 'required|string|min:8|confirmed',
        ]);

        $user = $request->user();

        if (!Hash::check($validated['current_password'], $user->password)) {
            return response()->json([
                'message' => 'كلمة المرور الحالية غير صحيحة',
            ], 422);
        }

        $user->update([
            'password' => Hash::make($validated['new_password']),
        ]);

        return response()->json([
            'message' => 'تم تحديث كلمة المرور بنجاح',
        ]);
    }

    /**
     * Get full user profile with related data
     */
    public function getFullProfile(Request $request): JsonResponse
    {
        $user = $request->user()->load([
            'subscriptions' => function($q) {
                $q->where('is_plan', false)->where('status', 'active')->latest();
            },
            'wallet.transactions' => function($q) {
                $q->latest()->take(10);
            },
            'connectedAccounts',
            'brandKits',
        ]);

        // Calculate usage stats
        $stats = [
            'total_posts' => $user->socialMediaPosts()->count(),
            'total_ai_generations' => $user->aiGenerations()->count(),
            'posts_this_month' => $user->socialMediaPosts()
                ->where('created_at', '>=', now()->startOfMonth())
                ->count(),
            'ai_this_month' => $user->aiGenerations()
                ->where('created_at', '>=', now()->startOfMonth())
                ->count(),
            'connected_accounts' => $user->connectedAccounts()->count(),
        ];

        // Get subscription limits
        $subscription = $user->subscriptions->first();
        $limits = [
            'max_posts' => $subscription ? ($subscription->max_posts ?? 50) : 10,
            'max_ai_requests' => $subscription ? ($subscription->ai_features ? 100 : 0) : 5,
            'max_accounts' => $subscription ? ($subscription->max_accounts ?? 3) : 1,
        ];

        return response()->json([
            'success' => true,
            'data' => [
                'user' => $user,
                'statistics' => $stats,
                'limits' => $limits,
                'subscription' => $subscription,
            ],
        ]);
    }

    /**
     * Update user preferences
     */
    public function updatePreferences(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'language' => 'nullable|string|in:ar,en',
            'timezone' => 'nullable|string',
            'notification_email' => 'nullable|boolean',
            'notification_push' => 'nullable|boolean',
            'notification_sms' => 'nullable|boolean',
            'theme' => 'nullable|string|in:light,dark,system',
            'default_platform' => 'nullable|string',
            'auto_schedule' => 'nullable|boolean',
            'ai_suggestions' => 'nullable|boolean',
        ]);

        $user = $request->user();

        $preferences = $user->preferences ?? [];
        $preferences = array_merge($preferences, $validated);

        $user->update(['preferences' => $preferences]);

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث التفضيلات بنجاح',
            'preferences' => $user->preferences,
        ]);
    }

    /**
     * Get user preferences
     */
    public function getPreferences(Request $request): JsonResponse
    {
        $user = $request->user();

        $defaultPreferences = [
            'language' => 'ar',
            'timezone' => 'Asia/Dubai',
            'notification_email' => true,
            'notification_push' => true,
            'notification_sms' => false,
            'theme' => 'system',
            'default_platform' => null,
            'auto_schedule' => false,
            'ai_suggestions' => true,
        ];

        $preferences = array_merge($defaultPreferences, $user->preferences ?? []);

        return response()->json([
            'success' => true,
            'preferences' => $preferences,
        ]);
    }

    /**
     * Update user's business profile
     */
    public function updateBusinessProfile(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'company_name' => 'nullable|string|max:255',
            'company_size' => 'nullable|string|in:1-10,11-50,51-200,201-500,500+',
            'industry' => 'nullable|string',
            'website' => 'nullable|url',
            'type_of_audience' => 'nullable|string',
            'target_platforms' => 'nullable|array',
            'content_goals' => 'nullable|array',
            'brand_voice' => 'nullable|string',
        ]);

        $user = $request->user();
        $user->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث ملف الأعمال بنجاح',
            'user' => $user->fresh(),
        ]);
    }

    /**
     * Get user's connected social accounts
     */
    public function getConnectedAccounts(Request $request): JsonResponse
    {
        $accounts = $request->user()->connectedAccounts()
            ->orderBy('platform')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $accounts,
        ]);
    }

    /**
     * Delete user account (soft delete)
     */
    public function deleteAccount(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'password' => 'required|string',
            'reason' => 'nullable|string',
        ]);

        $user = $request->user();

        if (!Hash::check($validated['password'], $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'كلمة المرور غير صحيحة',
            ], 422);
        }

        // Revoke all tokens
        $user->tokens()->delete();

        // Store deletion reason if provided
        if ($validated['reason']) {
            \Log::info('User account deletion', [
                'user_id' => $user->id,
                'email' => $user->email,
                'reason' => $validated['reason'],
            ]);
        }

        // Soft delete the user
        $user->delete();

        return response()->json([
            'success' => true,
            'message' => 'تم حذف الحساب بنجاح',
        ]);
    }

    /**
     * Get user's usage statistics
     */
    public function getUsageStats(Request $request): JsonResponse
    {
        $user = $request->user();
        $period = $request->get('period', 'month');

        $startDate = match($period) {
            'week' => now()->startOfWeek(),
            'month' => now()->startOfMonth(),
            'year' => now()->startOfYear(),
            default => now()->startOfMonth(),
        };

        $stats = [
            'posts' => [
                'total' => $user->socialMediaPosts()->count(),
                'period' => $user->socialMediaPosts()
                    ->where('created_at', '>=', $startDate)
                    ->count(),
                'by_platform' => $user->socialMediaPosts()
                    ->where('created_at', '>=', $startDate)
                    ->selectRaw('platform, count(*) as count')
                    ->groupBy('platform')
                    ->pluck('count', 'platform'),
                'by_status' => $user->socialMediaPosts()
                    ->where('created_at', '>=', $startDate)
                    ->selectRaw('status, count(*) as count')
                    ->groupBy('status')
                    ->pluck('count', 'status'),
            ],
            'ai_generations' => [
                'total' => $user->aiGenerations()->count(),
                'period' => $user->aiGenerations()
                    ->where('created_at', '>=', $startDate)
                    ->count(),
                'by_type' => $user->aiGenerations()
                    ->where('created_at', '>=', $startDate)
                    ->selectRaw('type, count(*) as count')
                    ->groupBy('type')
                    ->pluck('count', 'type'),
                'tokens_used' => $user->aiGenerations()
                    ->where('created_at', '>=', $startDate)
                    ->sum('tokens_used'),
            ],
            'wallet' => [
                'balance' => $user->wallet ? $user->wallet->balance : 0,
                'total_spent' => $user->wallet
                    ? $user->wallet->transactions()
                        ->where('type', 'debit')
                        ->where('created_at', '>=', $startDate)
                        ->sum('amount')
                    : 0,
            ],
        ];

        return response()->json([
            'success' => true,
            'period' => $period,
            'start_date' => $startDate->toDateString(),
            'data' => $stats,
        ]);
    }
}
