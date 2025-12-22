<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\WalletRechargeRequest;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class WalletRechargeRequestController extends Controller
{
    /**
     * Submit a new wallet recharge request
     */
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'user_id' => 'required|string|exists:users,id',
                'amount' => 'required|numeric|min:1',
                'currency' => 'nullable|string|size:3',
                'receipt_image' => 'required|image|mimes:jpeg,jpg,png,pdf|max:5120', // 5MB max
                'payment_method' => 'nullable|string|max:255',
                'bank_name' => 'nullable|string|max:255',
                'transaction_reference' => 'nullable|string|max:255',
                'notes' => 'nullable|string|max:1000',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors(),
                ], 422);
            }

            // Upload receipt image
            $receiptPath = null;
            if ($request->hasFile('receipt_image')) {
                $receiptPath = $request->file('receipt_image')->store('wallet_receipts', 'public');
            }

            // Create recharge request
            $rechargeRequest = WalletRechargeRequest::create([
                'user_id' => $request->user_id,
                'amount' => $request->amount,
                'currency' => $request->currency ?? 'SAR',
                'receipt_image' => $receiptPath,
                'payment_method' => $request->payment_method,
                'bank_name' => $request->bank_name,
                'transaction_reference' => $request->transaction_reference,
                'notes' => $request->notes,
                'status' => WalletRechargeRequest::STATUS_PENDING,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'تم إرسال طلب الشحن بنجاح. سيتم مراجعته من قبل الإدارة.',
                'request' => [
                    'id' => $rechargeRequest->id,
                    'amount' => $rechargeRequest->amount,
                    'currency' => $rechargeRequest->currency,
                    'formatted_amount' => $rechargeRequest->formatted_amount,
                    'status' => $rechargeRequest->status,
                    'status_text' => $rechargeRequest->status_text,
                    'receipt_url' => $rechargeRequest->receipt_url,
                    'created_at' => $rechargeRequest->created_at,
                ],
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to submit recharge request',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get user's recharge requests
     */
    public function getUserRequests(Request $request, string $userId)
    {
        try {
            $perPage = $request->input('per_page', 20);
            $status = $request->input('status');

            $query = WalletRechargeRequest::where('user_id', $userId)
                ->recent();

            if ($status) {
                $query->where('status', $status);
            }

            $requests = $query->paginate($perPage);

            $data = $requests->map(function ($req) {
                return [
                    'id' => $req->id,
                    'amount' => $req->amount,
                    'currency' => $req->currency,
                    'formatted_amount' => $req->formatted_amount,
                    'payment_method' => $req->payment_method,
                    'bank_name' => $req->bank_name,
                    'transaction_reference' => $req->transaction_reference,
                    'notes' => $req->notes,
                    'status' => $req->status,
                    'status_text' => $req->status_text,
                    'receipt_url' => $req->receipt_url,
                    'admin_notes' => $req->admin_notes,
                    'processed_at' => $req->processed_at,
                    'created_at' => $req->created_at,
                    'updated_at' => $req->updated_at,
                ];
            });

            return response()->json([
                'success' => true,
                'requests' => $data,
                'pagination' => [
                    'current_page' => $requests->currentPage(),
                    'last_page' => $requests->lastPage(),
                    'per_page' => $requests->perPage(),
                    'total' => $requests->total(),
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to get recharge requests',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get a single recharge request
     */
    public function show(Request $request, int $id)
    {
        try {
            $rechargeRequest = WalletRechargeRequest::with(['user', 'processedBy'])->find($id);

            if (!$rechargeRequest) {
                return response()->json([
                    'success' => false,
                    'message' => 'Recharge request not found',
                ], 404);
            }

            return response()->json([
                'success' => true,
                'request' => [
                    'id' => $rechargeRequest->id,
                    'user' => [
                        'id' => $rechargeRequest->user->id,
                        'name' => $rechargeRequest->user->name,
                        'email' => $rechargeRequest->user->email,
                        'phone_number' => $rechargeRequest->user->phone_number,
                    ],
                    'amount' => $rechargeRequest->amount,
                    'currency' => $rechargeRequest->currency,
                    'formatted_amount' => $rechargeRequest->formatted_amount,
                    'payment_method' => $rechargeRequest->payment_method,
                    'bank_name' => $rechargeRequest->bank_name,
                    'transaction_reference' => $rechargeRequest->transaction_reference,
                    'notes' => $rechargeRequest->notes,
                    'status' => $rechargeRequest->status,
                    'status_text' => $rechargeRequest->status_text,
                    'receipt_url' => $rechargeRequest->receipt_url,
                    'admin_notes' => $rechargeRequest->admin_notes,
                    'processed_by' => $rechargeRequest->processedBy ? [
                        'id' => $rechargeRequest->processedBy->id,
                        'name' => $rechargeRequest->processedBy->name,
                    ] : null,
                    'processed_at' => $rechargeRequest->processed_at,
                    'created_at' => $rechargeRequest->created_at,
                    'updated_at' => $rechargeRequest->updated_at,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to get recharge request',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get all recharge requests (Admin)
     */
    public function index(Request $request)
    {
        try {
            $perPage = $request->input('per_page', 20);
            $status = $request->input('status');
            $search = $request->input('search');

            $query = WalletRechargeRequest::with(['user', 'processedBy'])
                ->recent();

            if ($status) {
                $query->where('status', $status);
            }

            if ($search) {
                $query->whereHas('user', function ($q) use ($search) {
                    $q->where('name', 'like', "%{$search}%")
                      ->orWhere('email', 'like', "%{$search}%")
                      ->orWhere('phone_number', 'like', "%{$search}%");
                });
            }

            $requests = $query->paginate($perPage);

            $data = $requests->map(function ($req) {
                return [
                    'id' => $req->id,
                    'user' => [
                        'id' => $req->user->id,
                        'name' => $req->user->name,
                        'email' => $req->user->email,
                        'phone_number' => $req->user->phone_number,
                    ],
                    'amount' => $req->amount,
                    'currency' => $req->currency,
                    'formatted_amount' => $req->formatted_amount,
                    'payment_method' => $req->payment_method,
                    'bank_name' => $req->bank_name,
                    'status' => $req->status,
                    'status_text' => $req->status_text,
                    'receipt_url' => $req->receipt_url,
                    'processed_at' => $req->processed_at,
                    'created_at' => $req->created_at,
                ];
            });

            return response()->json([
                'success' => true,
                'requests' => $data,
                'pagination' => [
                    'current_page' => $requests->currentPage(),
                    'last_page' => $requests->lastPage(),
                    'per_page' => $requests->perPage(),
                    'total' => $requests->total(),
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to get recharge requests',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Approve a recharge request (Admin)
     */
    public function approve(Request $request, int $id)
    {
        try {
            $validator = Validator::make($request->all(), [
                'admin_id' => 'required|string|exists:users,id',
                'admin_notes' => 'nullable|string|max:1000',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $rechargeRequest = WalletRechargeRequest::find($id);

            if (!$rechargeRequest) {
                return response()->json([
                    'success' => false,
                    'message' => 'Recharge request not found',
                ], 404);
            }

            if (!$rechargeRequest->isPending()) {
                return response()->json([
                    'success' => false,
                    'message' => 'This request has already been processed',
                ], 400);
            }

            $success = $rechargeRequest->approve(
                $request->admin_id,
                $request->admin_notes
            );

            if ($success) {
                return response()->json([
                    'success' => true,
                    'message' => 'تم قبول طلب الشحن وإضافة المبلغ للمحفظة بنجاح',
                    'request' => [
                        'id' => $rechargeRequest->id,
                        'status' => $rechargeRequest->status,
                        'status_text' => $rechargeRequest->status_text,
                        'processed_at' => $rechargeRequest->processed_at,
                    ],
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to approve recharge request',
                ], 500);
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to approve recharge request',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Reject a recharge request (Admin)
     */
    public function reject(Request $request, int $id)
    {
        try {
            $validator = Validator::make($request->all(), [
                'admin_id' => 'required|string|exists:users,id',
                'admin_notes' => 'nullable|string|max:1000',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $rechargeRequest = WalletRechargeRequest::find($id);

            if (!$rechargeRequest) {
                return response()->json([
                    'success' => false,
                    'message' => 'Recharge request not found',
                ], 404);
            }

            if (!$rechargeRequest->isPending()) {
                return response()->json([
                    'success' => false,
                    'message' => 'This request has already been processed',
                ], 400);
            }

            $success = $rechargeRequest->reject(
                $request->admin_id,
                $request->admin_notes
            );

            if ($success) {
                return response()->json([
                    'success' => true,
                    'message' => 'تم رفض طلب الشحن',
                    'request' => [
                        'id' => $rechargeRequest->id,
                        'status' => $rechargeRequest->status,
                        'status_text' => $rechargeRequest->status_text,
                        'processed_at' => $rechargeRequest->processed_at,
                    ],
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to reject recharge request',
                ], 500);
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to reject recharge request',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get statistics (Admin)
     */
    public function statistics(Request $request)
    {
        try {
            $totalRequests = WalletRechargeRequest::count();
            $pendingRequests = WalletRechargeRequest::pending()->count();
            $approvedRequests = WalletRechargeRequest::approved()->count();
            $rejectedRequests = WalletRechargeRequest::rejected()->count();
            $totalApprovedAmount = WalletRechargeRequest::approved()->sum('amount');

            return response()->json([
                'success' => true,
                'statistics' => [
                    'total_requests' => $totalRequests,
                    'pending_requests' => $pendingRequests,
                    'approved_requests' => $approvedRequests,
                    'rejected_requests' => $rejectedRequests,
                    'total_approved_amount' => number_format($totalApprovedAmount, 2),
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
}
