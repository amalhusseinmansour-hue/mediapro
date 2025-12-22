<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Wallet;
use App\Models\WalletTransaction;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class WalletController extends Controller
{
    /**
     * Get user wallet
     */
    public function show(Request $request, string $userId)
    {
        try {
            $wallet = Wallet::where('user_id', $userId)->first();

            if (!$wallet) {
                // Create wallet if doesn't exist
                $wallet = Wallet::createForUser($userId);
            }

            return response()->json([
                'success' => true,
                'wallet' => [
                    'id' => $wallet->id,
                    'user_id' => $wallet->user_id,
                    'balance' => $wallet->balance,
                    'currency' => $wallet->currency,
                    'formatted_balance' => $wallet->formatted_balance,
                    'is_active' => $wallet->is_active,
                    'created_at' => $wallet->created_at,
                    'updated_at' => $wallet->updated_at,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to get wallet',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get wallet transactions
     */
    public function transactions(Request $request, string $userId)
    {
        try {
            $wallet = Wallet::where('user_id', $userId)->first();

            if (!$wallet) {
                return response()->json([
                    'success' => false,
                    'message' => 'Wallet not found',
                ], 404);
            }

            $perPage = $request->input('per_page', 20);
            $type = $request->input('type'); // 'credit' or 'debit'

            $query = $wallet->transactions();

            if ($type) {
                $query->where('type', $type);
            }

            $transactions = $query->paginate($perPage);

            return response()->json([
                'success' => true,
                'transactions' => $transactions->items(),
                'pagination' => [
                    'current_page' => $transactions->currentPage(),
                    'last_page' => $transactions->lastPage(),
                    'per_page' => $transactions->perPage(),
                    'total' => $transactions->total(),
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to get transactions',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Credit wallet (Admin only)
     */
    public function credit(Request $request, string $userId)
    {
        try {
            $validator = Validator::make($request->all(), [
                'amount' => 'required|numeric|min:0.01',
                'description' => 'required|string|max:255',
                'reference_id' => 'nullable|string|max:255',
                'metadata' => 'nullable|array',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $wallet = Wallet::where('user_id', $userId)->first();

            if (!$wallet) {
                $wallet = Wallet::createForUser($userId);
            }

            DB::beginTransaction();

            $transaction = $wallet->credit(
                $request->amount,
                $request->description,
                $request->reference_id,
                $request->metadata
            );

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Wallet credited successfully',
                'wallet' => [
                    'balance' => $wallet->balance,
                    'formatted_balance' => $wallet->formatted_balance,
                ],
                'transaction' => $transaction,
            ]);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Failed to credit wallet',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Debit wallet
     */
    public function debit(Request $request, string $userId)
    {
        try {
            $validator = Validator::make($request->all(), [
                'amount' => 'required|numeric|min:0.01',
                'description' => 'required|string|max:255',
                'reference_id' => 'nullable|string|max:255',
                'metadata' => 'nullable|array',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $wallet = Wallet::where('user_id', $userId)->first();

            if (!$wallet) {
                return response()->json([
                    'success' => false,
                    'message' => 'Wallet not found',
                ], 404);
            }

            if (!$wallet->hasEnoughBalance($request->amount)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Insufficient balance',
                ], 400);
            }

            DB::beginTransaction();

            $transaction = $wallet->debit(
                $request->amount,
                $request->description,
                $request->reference_id,
                $request->metadata
            );

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Wallet debited successfully',
                'wallet' => [
                    'balance' => $wallet->balance,
                    'formatted_balance' => $wallet->formatted_balance,
                ],
                'transaction' => $transaction,
            ]);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Failed to debit wallet',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get wallet statistics (Admin)
     */
    public function statistics(Request $request)
    {
        try {
            $totalWallets = Wallet::count();
            $activeWallets = Wallet::where('is_active', true)->count();
            $totalBalance = Wallet::sum('balance');
            $totalTransactions = WalletTransaction::count();
            $totalCredits = WalletTransaction::credit()->completed()->sum('amount');
            $totalDebits = WalletTransaction::debit()->completed()->sum('amount');

            return response()->json([
                'success' => true,
                'statistics' => [
                    'total_wallets' => $totalWallets,
                    'active_wallets' => $activeWallets,
                    'total_balance' => number_format($totalBalance, 2),
                    'total_transactions' => $totalTransactions,
                    'total_credits' => number_format($totalCredits, 2),
                    'total_debits' => number_format($totalDebits, 2),
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to get statistics',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * List all wallets (Admin)
     */
    public function index(Request $request)
    {
        try {
            $perPage = $request->input('per_page', 20);
            $search = $request->input('search');

            $query = Wallet::with('user');

            if ($search) {
                $query->whereHas('user', function ($q) use ($search) {
                    $q->where('name', 'like', "%{$search}%")
                      ->orWhere('email', 'like', "%{$search}%")
                      ->orWhere('phone_number', 'like', "%{$search}%");
                });
            }

            $wallets = $query->orderBy('balance', 'desc')->paginate($perPage);

            return response()->json([
                'success' => true,
                'wallets' => $wallets->items(),
                'pagination' => [
                    'current_page' => $wallets->currentPage(),
                    'last_page' => $wallets->lastPage(),
                    'per_page' => $wallets->perPage(),
                    'total' => $wallets->total(),
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to get wallets',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Toggle wallet status (Admin)
     */
    public function toggleStatus(Request $request, string $userId)
    {
        try {
            $wallet = Wallet::where('user_id', $userId)->first();

            if (!$wallet) {
                return response()->json([
                    'success' => false,
                    'message' => 'Wallet not found',
                ], 404);
            }

            $wallet->is_active = !$wallet->is_active;
            $wallet->save();

            return response()->json([
                'success' => true,
                'message' => 'Wallet status updated',
                'wallet' => [
                    'is_active' => $wallet->is_active,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update wallet status',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
