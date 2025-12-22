<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Subscription;
use App\Models\Wallet;
use App\Models\WalletTransaction;
use App\Models\WebsiteRequest;
use App\Models\SponsoredAdRequest;
use App\Models\SupportTicket;
use App\Models\BankTransferRequest;
use App\Models\Payment;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index()
    {
        $stats = [
            'users' => [
                'total' => User::count(),
                'new_today' => User::whereDate('created_at', today())->count(),
                'active_subscribers' => User::whereHas('subscriptions', function($q) {
                    $q->where('status', 'active')->where('end_date', '>', now());
                })->count(),
            ],
            'subscriptions' => [
                'total' => Subscription::where('is_plan', false)->count(),
                'active' => Subscription::where('is_plan', false)
                    ->where('status', 'active')
                    ->where('end_date', '>', now())
                    ->count(),
            ],
            'wallets' => [
                'total_balance' => Wallet::sum('balance'),
                'total_transactions' => WalletTransaction::count(),
            ],
            'requests' => [
                'website_pending' => WebsiteRequest::pending()->count(),
                'ads_pending' => SponsoredAdRequest::pending()->count(),
                'support_open' => SupportTicket::open()->count(),
                'bank_transfers_pending' => BankTransferRequest::pending()->count(),
            ],
            'revenue' => [
                'total' => Payment::where('status', 'completed')->sum('amount'),
                'this_month' => Payment::where('status', 'completed')
                    ->whereMonth('created_at', now()->month)
                    ->sum('amount'),
            ],
        ];

        return view('admin.dashboard', compact('stats'));
    }
}
