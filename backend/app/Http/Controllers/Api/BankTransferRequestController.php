<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\BankTransferRequest;
use App\Models\Wallet;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class BankTransferRequestController extends Controller
{
    /**
     * Display a listing of bank transfer requests
     */
    public function index(Request $request)
    {
        $query = BankTransferRequest::with(['user', 'reviewer']);

        // Filter by status
        if ($request->has('status')) {
            $query->byStatus($request->status);
        }

        // Filter by user (for admins to view specific user's requests)
        if ($request->has('user_id')) {
            $query->byUser($request->user_id);
        }

        // Search by sender name or bank
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('sender_name', 'like', "%{$search}%")
                  ->orWhere('sender_bank', 'like', "%{$search}%")
                  ->orWhere('transfer_reference', 'like', "%{$search}%");
            });
        }

        $requests = $query->latest()->paginate($request->per_page ?? 15);

        return response()->json([
            'success' => true,
            'data' => $requests
        ]);
    }

    /**
     * Get user's own bank transfer requests
     */
    public function myRequests(Request $request)
    {
        $query = BankTransferRequest::where('user_id', Auth::id());

        // Filter by status
        if ($request->has('status')) {
            $query->byStatus($request->status);
        }

        $requests = $query->latest()->paginate($request->per_page ?? 15);

        return response()->json([
            'success' => true,
            'data' => $requests
        ]);
    }

    /**
     * Store a new bank transfer request
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'amount' => 'required|numeric|min:1',
            'currency' => 'nullable|string|max:3',
            'sender_name' => 'required|string|max:255',
            'sender_bank' => 'required|string|max:255',
            'sender_account_number' => 'nullable|string|max:255',
            'transfer_reference' => 'nullable|string|max:255',
            'transfer_date' => 'required|date|before_or_equal:today',
            'transfer_notes' => 'nullable|string',
            'receipt_image' => 'nullable|image|mimes:jpeg,png,jpg,pdf|max:5120', // 5MB max
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صحيحة',
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $request->all();
        $data['user_id'] = Auth::id();
        $data['currency'] = $data['currency'] ?? 'EGP';

        // Handle receipt image upload
        if ($request->hasFile('receipt_image')) {
            $path = $request->file('receipt_image')->store('bank-transfers', 'public');
            $data['receipt_image'] = $path;
        }

        $transferRequest = BankTransferRequest::create($data);

        return response()->json([
            'success' => true,
            'message' => 'تم إرسال طلب الشحن بنجاح! سيتم مراجعته قريباً.',
            'data' => $transferRequest->load('user')
        ], 201);
    }

    /**
     * Display the specified bank transfer request
     */
    public function show($id)
    {
        $request = BankTransferRequest::with(['user', 'reviewer'])->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $request
        ]);
    }

    /**
     * Update the status of a bank transfer request (Admin only)
     */
    public function updateStatus(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'status' => 'required|in:reviewing,approved,rejected',
            'admin_notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صحيحة',
                'errors' => $validator->errors()
            ], 422);
        }

        $transferRequest = BankTransferRequest::findOrFail($id);

        // Don't allow updating already processed requests
        if (in_array($transferRequest->status, ['approved', 'rejected'])) {
            return response()->json([
                'success' => false,
                'message' => 'لا يمكن تعديل طلب تمت معالجته بالفعل'
            ], 400);
        }

        DB::beginTransaction();
        try {
            $transferRequest->status = $request->status;
            $transferRequest->admin_notes = $request->admin_notes;
            $transferRequest->reviewed_by = Auth::id();
            $transferRequest->reviewed_at = now();
            $transferRequest->save();

            // If approved, credit the user's wallet
            if ($request->status === 'approved') {
                $wallet = Wallet::firstOrCreate(
                    ['user_id' => $transferRequest->user_id],
                    ['balance' => 0, 'currency' => $transferRequest->currency]
                );

                // Credit the wallet
                $wallet->credit(
                    $transferRequest->amount,
                    'bank_transfer',
                    "شحن محفظة عبر تحويل بنكي - رقم الطلب: {$transferRequest->id}",
                    ['bank_transfer_request_id' => $transferRequest->id]
                );
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => $request->status === 'approved'
                    ? 'تم الموافقة على الطلب وشحن المحفظة بنجاح'
                    : 'تم تحديث حالة الطلب',
                'data' => $transferRequest->load(['user', 'reviewer'])
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء معالجة الطلب: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Delete a bank transfer request
     */
    public function destroy($id)
    {
        $transferRequest = BankTransferRequest::findOrFail($id);

        // Don't allow deleting approved requests
        if ($transferRequest->status === 'approved') {
            return response()->json([
                'success' => false,
                'message' => 'لا يمكن حذف طلب تمت الموافقة عليه'
            ], 400);
        }

        // Delete receipt image if exists
        if ($transferRequest->receipt_image) {
            Storage::disk('public')->delete($transferRequest->receipt_image);
        }

        $transferRequest->delete();

        return response()->json([
            'success' => true,
            'message' => 'تم حذف الطلب بنجاح'
        ]);
    }

    /**
     * Get statistics
     */
    public function statistics()
    {
        $total = BankTransferRequest::count();
        $pending = BankTransferRequest::pending()->count();
        $approved = BankTransferRequest::approved()->count();
        $rejected = BankTransferRequest::rejected()->count();

        $totalAmount = BankTransferRequest::approved()->sum('amount');
        $pendingAmount = BankTransferRequest::pending()->sum('amount');

        return response()->json([
            'success' => true,
            'data' => [
                'total' => $total,
                'pending' => $pending,
                'approved' => $approved,
                'rejected' => $rejected,
                'reviewing' => BankTransferRequest::byStatus('reviewing')->count(),
                'total_amount' => $totalAmount,
                'pending_amount' => $pendingAmount,
            ]
        ]);
    }

    /**
     * Get bank account information for transfers
     */
    public function bankAccountInfo()
    {
        // This should be configurable in settings, but for now we return static info
        return response()->json([
            'success' => true,
            'data' => [
                'bank_name' => 'البنك الأهلي المصري',
                'account_name' => 'MediaPro Social',
                'account_number' => '0123456789012345',
                'iban' => 'EG380002000100123456789012345',
                'swift_code' => 'NBEGEGCX',
                'branch' => 'فرع القاهرة الرئيسي',
                'instructions' => [
                    'قم بتحويل المبلغ المطلوب إلى الحساب البنكي المذكور',
                    'احتفظ بإيصال التحويل',
                    'قم بتعبئة نموذج طلب الشحن وإرفاق صورة من الإيصال',
                    'سيتم مراجعة طلبك خلال 24-48 ساعة',
                    'عند الموافقة، سيتم إضافة الرصيد تلقائياً إلى محفظتك',
                ]
            ]
        ]);
    }
}
