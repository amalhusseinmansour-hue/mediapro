<?php

namespace App\Filament\Widgets;

use App\Models\WebsiteRequest;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class WebsiteRequestsStatsWidget extends BaseWidget
{
    protected static ?int $sort = 2;

    protected function getStats(): array
    {
        $total = WebsiteRequest::count();
        $pending = WebsiteRequest::where('status', 'pending')->count();
        $reviewing = WebsiteRequest::where('status', 'reviewing')->count();
        $accepted = WebsiteRequest::where('status', 'accepted')->count();
        $completed = WebsiteRequest::where('status', 'completed')->count();
        $rejected = WebsiteRequest::where('status', 'rejected')->count();

        return [
            Stat::make('إجمالي الطلبات', $total)
                ->description('جميع طلبات المواقع')
                ->descriptionIcon('heroicon-m-globe-alt')
                ->color('primary')
                ->chart([7, 3, 4, 5, 6, 3, 5, 3]),

            Stat::make('قيد الانتظار', $pending)
                ->description('طلبات جديدة')
                ->descriptionIcon('heroicon-m-clock')
                ->color('warning')
                ->chart([3, 2, 4, 3, 5, 4, 6, 5]),

            Stat::make('قيد المراجعة', $reviewing)
                ->description('يتم مراجعتها')
                ->descriptionIcon('heroicon-m-magnifying-glass')
                ->color('info')
                ->chart([2, 3, 2, 4, 3, 5, 4, 3]),

            Stat::make('مقبولة', $accepted)
                ->description('تم قبول الطلب')
                ->descriptionIcon('heroicon-m-check-circle')
                ->color('success')
                ->chart([1, 2, 3, 2, 4, 3, 5, 4]),

            Stat::make('مكتملة', $completed)
                ->description('تم إنجازها')
                ->descriptionIcon('heroicon-m-check-badge')
                ->color('primary')
                ->chart([2, 1, 3, 2, 3, 4, 3, 5]),

            Stat::make('مرفوضة', $rejected)
                ->description('لم تستوفي المعايير')
                ->descriptionIcon('heroicon-m-x-circle')
                ->color('danger')
                ->chart([1, 1, 2, 1, 2, 1, 3, 2]),
        ];
    }
}
