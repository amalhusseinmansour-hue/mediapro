<?php

namespace App\Filament\Widgets;

use App\Models\User;
use App\Models\Subscription;
use App\Models\Payment;
use App\Models\Earning;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends BaseWidget
{
    protected function getStats(): array
    {
        $totalUsers = User::count();
        $newUsersThisMonth = User::whereMonth('created_at', now()->month)->count();

        $activeSubscriptions = Subscription::where('status', 'active')->count();
        $totalSubscriptions = Subscription::count();

        $totalPayments = Payment::where('status', 'completed')->sum('amount');
        $paymentsThisMonth = Payment::where('status', 'completed')
            ->whereMonth('created_at', now()->month)
            ->sum('amount');

        $totalEarnings = Earning::sum('amount');
        $earningsThisMonth = Earning::whereMonth('created_at', now()->month)->sum('amount');

        return [
            Stat::make('إجمالي المستخدمين', $totalUsers)
                ->description($newUsersThisMonth . ' مستخدم جديد هذا الشهر')
                ->descriptionIcon('heroicon-m-arrow-trending-up')
                ->color('success')
                ->chart([7, 12, 18, 22, 25, 28, $newUsersThisMonth]),

            Stat::make('الاشتراكات النشطة', $activeSubscriptions)
                ->description('من أصل ' . $totalSubscriptions . ' اشتراك')
                ->descriptionIcon('heroicon-m-check-circle')
                ->color('info'),

            Stat::make('إجمالي المدفوعات', '$' . number_format($totalPayments, 2))
                ->description('$' . number_format($paymentsThisMonth, 2) . ' هذا الشهر')
                ->descriptionIcon('heroicon-m-currency-dollar')
                ->color('warning'),

            Stat::make('إجمالي الأرباح', '$' . number_format($totalEarnings, 2))
                ->description('$' . number_format($earningsThisMonth, 2) . ' هذا الشهر')
                ->descriptionIcon('heroicon-m-banknotes')
                ->color('success'),
        ];
    }
}
