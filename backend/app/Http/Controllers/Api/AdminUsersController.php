<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Subscription;
use App\Models\Wallet;
use App\Models\WalletTransaction;
use App\Models\SocialMediaPost;
use App\Models\ConnectedAccount;
use App\Models\AiGeneration;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class AdminUsersController extends Controller
{
    /**
     * Get all users with filtering and pagination
     */
    public function index(Request $request)
    {
        $query = User::with(['subscriptions' => function($q) {
            $q->where('is_plan', false)->where('status', 'active')->latest();
        }, 'wallet']);

        // Search filter
        if ($request->has('search') && !empty($request->search)) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%")
                  ->orWhere('phone', 'like', "%{$search}%");
            });
        }

        // Status filter
        if ($request->has('status') && !empty($request->status)) {
            if ($request->status === 'active') {
                $query->whereHas('subscriptions', function($q) {
                    $q->where('status', 'active')->where('end_date', '>', now());
                });
            } elseif ($request->status === 'inactive') {
                $query->whereDoesntHave('subscriptions', function($q) {
                    $q->where('status', 'active')->where('end_date', '>', now());
                });
            } elseif ($request->status === 'banned') {
                $query->where('is_banned', true);
            }
        }

        // Role filter
        if ($request->has('role') && !empty($request->role)) {
            $query->where('role', $request->role);
        }

        // Date range filter
        if ($request->has('from_date') && !empty($request->from_date)) {
            $query->whereDate('created_at', '>=', $request->from_date);
        }
        if ($request->has('to_date') && !empty($request->to_date)) {
            $query->whereDate('created_at', '<=', $request->to_date);
        }

        // Sorting
        $sortBy = $request->get('sort_by', 'created_at');
        $sortOrder = $request->get('sort_order', 'desc');
        $query->orderBy($sortBy, $sortOrder);

        // Pagination
        $perPage = $request->get('per_page', 20);
        $users = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $users,
        ]);
    }

    /**
     * Get single user details
     */
    public function show($id)
    {
        $user = User::with([
            'subscriptions' => function($q) {
                $q->where('is_plan', false)->latest();
            },
            'wallet.transactions' => function($q) {
                $q->latest()->take(20);
            },
            'connectedAccounts',
            'socialMediaPosts' => function($q) {
                $q->latest()->take(10);
            },
            'aiGenerations' => function($q) {
                $q->latest()->take(10);
            },
        ])->findOrFail($id);

        // Calculate usage statistics
        $stats = [
            'total_posts' => SocialMediaPost::where('user_id', $id)->count(),
            'total_ai_generations' => AiGeneration::where('user_id', $id)->count(),
            'connected_accounts' => ConnectedAccount::where('user_id', $id)->count(),
            'total_spent' => $user->wallet ? $user->wallet->transactions()->where('type', 'debit')->sum('amount') : 0,
        ];

        return response()->json([
            'success' => true,
            'data' => [
                'user' => $user,
                'statistics' => $stats,
            ],
        ]);
    }

    /**
     * Create new user (admin)
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'phone' => 'nullable|string|max:20',
            'password' => 'required|min:8',
            'role' => 'nullable|string|in:user,admin,super_admin',
            'subscription_plan_id' => 'nullable|exists:subscription_plans,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        DB::beginTransaction();
        try {
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'phone' => $request->phone,
                'password' => Hash::make($request->password),
                'role' => $request->role ?? 'user',
                'email_verified_at' => now(),
            ]);

            // Create wallet
            Wallet::create([
                'user_id' => $user->id,
                'balance' => 0,
                'currency' => 'AED',
                'status' => 'active',
            ]);

            // Create subscription if plan specified
            if ($request->subscription_plan_id) {
                $plan = \App\Models\SubscriptionPlan::find($request->subscription_plan_id);
                if ($plan) {
                    Subscription::create([
                        'user_id' => $user->id,
                        'plan_id' => $plan->id,
                        'plan_name' => $plan->name,
                        'price' => $plan->price,
                        'currency' => $plan->currency,
                        'status' => 'active',
                        'start_date' => now(),
                        'end_date' => $plan->type === 'yearly' ? now()->addYear() : now()->addMonth(),
                        'is_plan' => false,
                    ]);
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'User created successfully',
                'data' => $user->load('wallet', 'subscriptions'),
            ], 201);

        } catch (\Exception $e) {
            DB::rollback();
            return response()->json([
                'success' => false,
                'message' => 'Failed to create user',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Update user
     */
    public function update(Request $request, $id)
    {
        $user = User::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'name' => 'nullable|string|max:255',
            'email' => 'nullable|email|unique:users,email,' . $id,
            'phone' => 'nullable|string|max:20',
            'password' => 'nullable|min:8',
            'role' => 'nullable|string|in:user,admin,super_admin',
            'is_banned' => 'nullable|boolean',
            'type_of_audience' => 'nullable|string',
            'company_name' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $updateData = $request->only([
            'name', 'email', 'phone', 'role', 'is_banned',
            'type_of_audience', 'company_name'
        ]);

        if ($request->has('password') && !empty($request->password)) {
            $updateData['password'] = Hash::make($request->password);
        }

        $user->update(array_filter($updateData, fn($v) => $v !== null));

        return response()->json([
            'success' => true,
            'message' => 'User updated successfully',
            'data' => $user->fresh(),
        ]);
    }

    /**
     * Delete user
     */
    public function destroy($id)
    {
        $user = User::findOrFail($id);

        // Prevent deleting super admins
        if ($user->role === 'super_admin') {
            return response()->json([
                'success' => false,
                'message' => 'Cannot delete super admin users',
            ], 403);
        }

        DB::beginTransaction();
        try {
            // Delete related data
            $user->aiGenerations()->delete();
            $user->socialMediaPosts()->delete();
            $user->connectedAccounts()->delete();
            if ($user->wallet) {
                $user->wallet->transactions()->delete();
                $user->wallet->delete();
            }
            $user->subscriptions()->delete();
            $user->delete();

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'User deleted successfully',
            ]);

        } catch (\Exception $e) {
            DB::rollback();
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete user',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Ban/Unban user
     */
    public function toggleBan($id)
    {
        $user = User::findOrFail($id);

        if ($user->role === 'super_admin') {
            return response()->json([
                'success' => false,
                'message' => 'Cannot ban super admin users',
            ], 403);
        }

        $user->update([
            'is_banned' => !$user->is_banned,
            'banned_at' => !$user->is_banned ? now() : null,
        ]);

        return response()->json([
            'success' => true,
            'message' => $user->is_banned ? 'User banned successfully' : 'User unbanned successfully',
            'data' => $user,
        ]);
    }

    /**
     * Add credits to user wallet
     */
    public function addCredits(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'amount' => 'required|numeric|min:1',
            'description' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::findOrFail($id);
        $wallet = $user->wallet;

        if (!$wallet) {
            $wallet = Wallet::create([
                'user_id' => $user->id,
                'balance' => 0,
                'currency' => 'AED',
                'status' => 'active',
            ]);
        }

        DB::beginTransaction();
        try {
            $wallet->increment('balance', $request->amount);

            WalletTransaction::create([
                'wallet_id' => $wallet->id,
                'type' => 'credit',
                'amount' => $request->amount,
                'balance_after' => $wallet->balance,
                'description' => $request->description ?? 'Admin credit',
                'status' => 'completed',
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Credits added successfully',
                'data' => [
                    'new_balance' => $wallet->balance,
                    'amount_added' => $request->amount,
                ],
            ]);

        } catch (\Exception $e) {
            DB::rollback();
            return response()->json([
                'success' => false,
                'message' => 'Failed to add credits',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Grant subscription to user
     */
    public function grantSubscription(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'plan_id' => 'required|exists:subscription_plans,id',
            'duration_months' => 'nullable|integer|min:1|max:24',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::findOrFail($id);
        $plan = \App\Models\SubscriptionPlan::findOrFail($request->plan_id);
        $durationMonths = $request->duration_months ?? ($plan->type === 'yearly' ? 12 : 1);

        // Cancel any existing active subscriptions
        Subscription::where('user_id', $user->id)
            ->where('is_plan', false)
            ->where('status', 'active')
            ->update(['status' => 'cancelled']);

        $subscription = Subscription::create([
            'user_id' => $user->id,
            'plan_id' => $plan->id,
            'plan_name' => $plan->name,
            'price' => 0, // Free grant
            'currency' => $plan->currency,
            'status' => 'active',
            'start_date' => now(),
            'end_date' => now()->addMonths($durationMonths),
            'is_plan' => false,
            'notes' => 'Granted by admin',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Subscription granted successfully',
            'data' => $subscription,
        ]);
    }

    /**
     * Get user's activity log
     */
    public function getActivityLog($id, Request $request)
    {
        $user = User::findOrFail($id);
        $perPage = $request->get('per_page', 20);

        $activities = [];

        // AI Generations
        $aiGenerations = AiGeneration::where('user_id', $id)
            ->latest()
            ->take(50)
            ->get()
            ->map(function($gen) {
                return [
                    'type' => 'ai_generation',
                    'title' => 'AI Generation: ' . $gen->type,
                    'description' => substr($gen->prompt, 0, 100),
                    'status' => $gen->status,
                    'timestamp' => $gen->created_at,
                ];
            });

        // Social Media Posts
        $posts = SocialMediaPost::where('user_id', $id)
            ->latest()
            ->take(50)
            ->get()
            ->map(function($post) {
                return [
                    'type' => 'social_post',
                    'title' => 'Social Post',
                    'description' => substr($post->content, 0, 100),
                    'status' => $post->status,
                    'timestamp' => $post->created_at,
                ];
            });

        // Wallet Transactions
        $transactions = [];
        if ($user->wallet) {
            $transactions = $user->wallet->transactions()
                ->latest()
                ->take(50)
                ->get()
                ->map(function($trans) {
                    return [
                        'type' => 'wallet_transaction',
                        'title' => ucfirst($trans->type) . ': ' . $trans->amount,
                        'description' => $trans->description,
                        'status' => $trans->status,
                        'timestamp' => $trans->created_at,
                    ];
                });
        }

        // Merge and sort
        $activities = collect()
            ->merge($aiGenerations)
            ->merge($posts)
            ->merge($transactions)
            ->sortByDesc('timestamp')
            ->take(100)
            ->values();

        return response()->json([
            'success' => true,
            'data' => $activities,
        ]);
    }

    /**
     * Export users to CSV
     */
    public function export(Request $request)
    {
        $query = User::with(['subscriptions' => function($q) {
            $q->where('is_plan', false)->where('status', 'active')->latest()->take(1);
        }, 'wallet']);

        // Apply same filters as index
        if ($request->has('search') && !empty($request->search)) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%");
            });
        }

        $users = $query->get();

        $csvData = [];
        $csvData[] = ['ID', 'Name', 'Email', 'Phone', 'Role', 'Subscription', 'Wallet Balance', 'Created At'];

        foreach ($users as $user) {
            $subscription = $user->subscriptions->first();
            $csvData[] = [
                $user->id,
                $user->name,
                $user->email,
                $user->phone ?? '',
                $user->role,
                $subscription ? $subscription->plan_name : 'None',
                $user->wallet ? $user->wallet->balance : 0,
                $user->created_at->format('Y-m-d H:i:s'),
            ];
        }

        $filename = 'users_export_' . date('Y-m-d_His') . '.csv';
        $filepath = storage_path('app/exports/' . $filename);

        // Ensure directory exists
        if (!file_exists(dirname($filepath))) {
            mkdir(dirname($filepath), 0755, true);
        }

        $file = fopen($filepath, 'w');
        foreach ($csvData as $row) {
            fputcsv($file, $row);
        }
        fclose($file);

        return response()->json([
            'success' => true,
            'message' => 'Export completed',
            'data' => [
                'filename' => $filename,
                'download_url' => url('storage/exports/' . $filename),
                'total_records' => count($users),
            ],
        ]);
    }

    /**
     * Get users statistics summary
     */
    public function statistics()
    {
        $total = User::count();
        $activeSubscribers = User::whereHas('subscriptions', function($q) {
            $q->where('is_plan', false)->where('status', 'active')->where('end_date', '>', now());
        })->count();

        $byRole = User::select('role', DB::raw('count(*) as count'))
            ->groupBy('role')
            ->pluck('count', 'role');

        $newThisWeek = User::where('created_at', '>=', now()->startOfWeek())->count();
        $newThisMonth = User::where('created_at', '>=', now()->startOfMonth())->count();

        // Growth trend
        $growth = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i);
            $count = User::whereDate('created_at', $date)->count();
            $growth[] = [
                'date' => $date->format('Y-m-d'),
                'count' => $count,
            ];
        }

        return response()->json([
            'success' => true,
            'data' => [
                'total_users' => $total,
                'active_subscribers' => $activeSubscribers,
                'free_users' => $total - $activeSubscribers,
                'by_role' => $byRole,
                'new_this_week' => $newThisWeek,
                'new_this_month' => $newThisMonth,
                'banned_users' => User::where('is_banned', true)->count(),
                'growth_trend' => $growth,
            ],
        ]);
    }
}
