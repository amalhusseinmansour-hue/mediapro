<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\WebsiteRequest;
use App\Models\SponsoredAdRequest;
use App\Models\SupportTicket;
use App\Models\BankTransferRequest;
use App\Models\Wallet;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class RequestController extends Controller
{
    // Website Requests
    public function websiteRequests(Request $request)
    {
        $query = WebsiteRequest::query();

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        $requests = $query->latest()->paginate(20);
        return view('admin.requests.website', compact('requests'));
    }

    public function updateWebsiteRequest(Request $request, $id)
    {
        $websiteRequest = WebsiteRequest::findOrFail($id);
        $websiteRequest->update($request->only(['status', 'admin_notes']));

        return redirect()->back()->with('success', 'تم تحديث الطلب بنجاح');
    }

    // Sponsored Ad Requests
    public function adRequests(Request $request)
    {
        $query = SponsoredAdRequest::query();

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        $requests = $query->latest()->paginate(20);
        return view('admin.requests.ads', compact('requests'));
    }

    public function updateAdRequest(Request $request, $id)
    {
        $adRequest = SponsoredAdRequest::findOrFail($id);
        $adRequest->update($request->only(['status', 'admin_notes']));

        return redirect()->back()->with('success', 'تم تحديث الطلب بنجاح');
    }

    // Support Tickets
    public function supportTickets(Request $request)
    {
        $query = SupportTicket::with(['user', 'assignedAdmin']);

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        if ($request->has('priority')) {
            $query->where('priority', $request->priority);
        }

        $tickets = $query->latest()->paginate(20);
        return view('admin.requests.support', compact('tickets'));
    }

    public function updateSupportTicket(Request $request, $id)
    {
        $ticket = SupportTicket::findOrFail($id);

        $data = $request->only(['status', 'priority', 'admin_notes', 'assigned_to']);

        if ($request->status === 'resolved' && $ticket->status !== 'resolved') {
            $data['resolved_at'] = now();
        }

        $ticket->update($data);

        return redirect()->back()->with('success', 'تم تحديث التذكرة بنجاح');
    }

    // Bank Transfer Requests
    public function bankTransfers(Request $request)
    {
        $query = BankTransferRequest::with(['user', 'reviewer']);

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        $transfers = $query->latest()->paginate(20);
        return view('admin.requests.bank-transfers', compact('transfers'));
    }

    public function updateBankTransfer(Request $request, $id)
    {
        $transfer = BankTransferRequest::findOrFail($id);

        if (in_array($transfer->status, ['approved', 'rejected'])) {
            return redirect()->back()->with('error', 'لا يمكن تعديل طلب تمت معالجته بالفعل');
        }

        DB::beginTransaction();
        try {
            $transfer->status = $request->status;
            $transfer->admin_notes = $request->admin_notes;
            $transfer->reviewed_by = auth()->id();
            $transfer->reviewed_at = now();
            $transfer->save();

            // If approved, credit the wallet
            if ($request->status === 'approved') {
                $wallet = Wallet::firstOrCreate(
                    ['user_id' => $transfer->user_id],
                    ['balance' => 0, 'currency' => $transfer->currency]
                );

                $wallet->credit(
                    $transfer->amount,
                    'bank_transfer',
                    "شحن محفظة عبر تحويل بنكي - رقم الطلب: {$transfer->id}",
                    ['bank_transfer_request_id' => $transfer->id]
                );
            }

            DB::commit();

            return redirect()->back()->with('success',
                $request->status === 'approved'
                    ? 'تم الموافقة على الطلب وشحن المحفظة بنجاح'
                    : 'تم تحديث حالة الطلب'
            );

        } catch (\Exception $e) {
            DB::rollBack();
            return redirect()->back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }
}
