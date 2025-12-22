<?php

namespace App\Http\Controllers\Api;

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
use Illuminate\Support\Facades\DB;

class AdminDashboardController extends Controller
{
    /**
     * Get comprehensive dashboard statistics
     */
    public function index()
    {
        return response()->json([
            'success' => true,
            'data' => [
                'users' => $this->getUsersStatistics(),
                'subscriptions' => $this->getSubscriptionsStatistics(),
                'wallets' => $this->getWalletsStatistics(),
                'requests' => $this->getRequestsStatistics(),
                'support' => $this->getSupportStatistics(),
                'revenue' => $this->getRevenueStatistics(),
            ]
        ]);
    }

    /**
     * Get users statistics
     */
    private function getUsersStatistics()
    {
        $total = User::count();
        $activeSubscribers = User::whereHas('subscriptions', function($query) {
            $query->where('status', 'active')
                  ->where('end_date', '>', now());
        })->count();

        $newThisMonth = User::whereMonth('created_at', now()->month)
            ->whereYear('created_at', now()->year)
            ->count();

        $newToday = User::whereDate('created_at', today())->count();

        return [
            'total' => $total,
            'active_subscribers' => $activeSubscribers,
            'free_users' => $total - $activeSubscribers,
            'new_this_month' => $newThisMonth,
            'new_today' => $newToday,
        ];
    }

    /**
     * Get subscriptions statistics
     */
    private function getSubscriptionsStatistics()
    {
        $total = Subscription::where('is_plan', false)->count();
        $active = Subscription::where('is_plan', false)
            ->where('status', 'active')
            ->where('end_date', '>', now())
            ->count();

        $expired = Subscription::where('is_plan', false)
            ->where('status', 'expired')
            ->count();

        $thisMonth = Subscription::where('is_plan', false)
            ->whereMonth('created_at', now()->month)
            ->whereYear('created_at', now()->year)
            ->count();

        return [
            'total' => $total,
            'active' => $active,
            'expired' => $expired,
            'cancelled' => Subscription::where('is_plan', false)->where('status', 'cancelled')->count(),
            'new_this_month' => $thisMonth,
        ];
    }

    /**
     * Get wallets statistics
     */
    private function getWalletsStatistics()
    {
        $totalBalance = Wallet::where('status', 'active')->sum('balance');
        $totalWallets = Wallet::count();
        $activeWallets = Wallet::where('status', 'active')->count();

        $totalTransactions = WalletTransaction::count();
        $totalCredits = WalletTransaction::where('type', 'credit')->sum('amount');
        $totalDebits = WalletTransaction::where('type', 'debit')->sum('amount');

        return [
            'total_balance' => $totalBalance,
            'total_wallets' => $totalWallets,
            'active_wallets' => $activeWallets,
            'suspended_wallets' => Wallet::where('status', 'suspended')->count(),
            'total_transactions' => $totalTransactions,
            'total_credits' => $totalCredits,
            'total_debits' => $totalDebits,
        ];
    }

    /**
     * Get requests statistics (website, ads, bank transfers)
     */
    private function getRequestsStatistics()
    {
        return [
            'website_requests' => [
                'total' => WebsiteRequest::count(),
                'pending' => WebsiteRequest::pending()->count(),
                'accepted' => WebsiteRequest::byStatus('accepted')->count(),
                'completed' => WebsiteRequest::byStatus('completed')->count(),
            ],
            'ad_requests' => [
                'total' => SponsoredAdRequest::count(),
                'pending' => SponsoredAdRequest::pending()->count(),
                'running' => SponsoredAdRequest::byStatus('running')->count(),
                'completed' => SponsoredAdRequest::byStatus('completed')->count(),
            ],
            'bank_transfers' => [
                'total' => BankTransferRequest::count(),
                'pending' => BankTransferRequest::pending()->count(),
                'approved' => BankTransferRequest::approved()->count(),
                'total_amount' => BankTransferRequest::approved()->sum('amount'),
                'pending_amount' => BankTransferRequest::pending()->sum('amount'),
            ],
        ];
    }

    /**
     * Get support statistics
     */
    private function getSupportStatistics()
    {
        $total = SupportTicket::count();
        $open = SupportTicket::open()->count();
        $unresolved = SupportTicket::unresolved()->count();

        return [
            'total' => $total,
            'open' => $open,
            'in_progress' => SupportTicket::byStatus('in_progress')->count(),
            'resolved' => SupportTicket::byStatus('resolved')->count(),
            'closed' => SupportTicket::byStatus('closed')->count(),
            'unresolved' => $unresolved,
            'urgent' => SupportTicket::byPriority('urgent')->count(),
        ];
    }

    /**
     * Get revenue statistics
     */
    private function getRevenueStatistics()
    {
        $totalRevenue = Payment::where('status', 'completed')->sum('amount');

        $thisMonthRevenue = Payment::where('status', 'completed')
            ->whereMonth('created_at', now()->month)
            ->whereYear('created_at', now()->year)
            ->sum('amount');

        $todayRevenue = Payment::where('status', 'completed')
            ->whereDate('created_at', today())
            ->sum('amount');

        $lastMonthRevenue = Payment::where('status', 'completed')
            ->whereMonth('created_at', now()->subMonth()->month)
            ->whereYear('created_at', now()->subMonth()->year)
            ->sum('amount');

        return [
            'total' => $totalRevenue,
            'this_month' => $thisMonthRevenue,
            'last_month' => $lastMonthRevenue,
            'today' => $todayRevenue,
            'growth_percentage' => $lastMonthRevenue > 0
                ? (($thisMonthRevenue - $lastMonthRevenue) / $lastMonthRevenue) * 100
                : 0,
        ];
    }

    /**
     * Get recent activities
     */
    public function recentActivities(Request $request)
    {
        $limit = $request->get('limit', 20);

        $activities = [];

        // Recent users
        $recentUsers = User::latest()->take(5)->get(['id', 'name', 'email', 'created_at']);
        foreach ($recentUsers as $user) {
            $activities[] = [
                'type' => 'user_registered',
                'title' => 'مستخدم جديد',
                'description' => "انضم {$user->name} للمنصة",
                'timestamp' => $user->created_at,
                'data' => $user,
            ];
        }

        // Recent subscriptions
        $recentSubscriptions = Subscription::where('is_plan', false)
            ->with('user')
            ->latest()
            ->take(5)
            ->get();
        foreach ($recentSubscriptions as $sub) {
            $activities[] = [
                'type' => 'subscription_created',
                'title' => 'اشتراك جديد',
                'description' => "{$sub->user->name} اشترك في خطة {$sub->plan_name}",
                'timestamp' => $sub->created_at,
                'data' => $sub,
            ];
        }

        // Recent support tickets
        $recentTickets = SupportTicket::with('user')->latest()->take(5)->get();
        foreach ($recentTickets as $ticket) {
            $activities[] = [
                'type' => 'support_ticket',
                'title' => 'تذكرة دعم جديدة',
                'description' => "تذكرة جديدة: {$ticket->subject}",
                'timestamp' => $ticket->created_at,
                'data' => $ticket,
            ];
        }

        // Recent bank transfer requests
        $recentTransfers = BankTransferRequest::with('user')->latest()->take(5)->get();
        foreach ($recentTransfers as $transfer) {
            $activities[] = [
                'type' => 'bank_transfer',
                'title' => 'طلب شحن بنكي',
                'description' => "{$transfer->user->name} طلب شحن بمبلغ {$transfer->amount} {$transfer->currency}",
                'timestamp' => $transfer->created_at,
                'data' => $transfer,
            ];
        }

        // Sort by timestamp descending
        usort($activities, function($a, $b) {
            return $b['timestamp'] <=> $a['timestamp'];
        });

        // Limit results
        $activities = array_slice($activities, 0, $limit);

        return response()->json([
            'success' => true,
            'data' => $activities
        ]);
    }

    /**
     * Get chart data for revenue over time
     */
    public function revenueChart(Request $request)
    {
        $period = $request->get('period', 'month'); // day, week, month, year

        $data = [];

        if ($period === 'month') {
            // Last 12 months
            for ($i = 11; $i >= 0; $i--) {
                $date = now()->subMonths($i);
                $revenue = Payment::where('status', 'completed')
                    ->whereMonth('created_at', $date->month)
                    ->whereYear('created_at', $date->year)
                    ->sum('amount');

                $data[] = [
                    'label' => $date->format('M Y'),
                    'value' => $revenue,
                ];
            }
        } elseif ($period === 'week') {
            // Last 7 days
            for ($i = 6; $i >= 0; $i--) {
                $date = now()->subDays($i);
                $revenue = Payment::where('status', 'completed')
                    ->whereDate('created_at', $date)
                    ->sum('amount');

                $data[] = [
                    'label' => $date->format('D, M d'),
                    'value' => $revenue,
                ];
            }
        }

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }

    /**
     * Get users growth chart
     */
    public function usersGrowthChart(Request $request)
    {
        $period = $request->get('period', 'month');

        $data = [];

        if ($period === 'month') {
            // Last 12 months
            for ($i = 11; $i >= 0; $i--) {
                $date = now()->subMonths($i);
                $count = User::whereMonth('created_at', $date->month)
                    ->whereYear('created_at', $date->year)
                    ->count();

                $data[] = [
                    'label' => $date->format('M Y'),
                    'value' => $count,
                ];
            }
        }

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }
}
