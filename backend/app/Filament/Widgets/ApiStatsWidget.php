<?php

namespace App\Filament\Widgets;

use App\Models\ApiKey;
use App\Models\ApiLog;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class ApiStatsWidget extends BaseWidget
{
    protected static ?int $sort = 3;

    protected function getStats(): array
    {
        $totalKeys = ApiKey::count();
        $activeKeys = ApiKey::active()->count();

        $totalRequests = ApiLog::count();
        $todayRequests = ApiLog::today()->count();

        $successRate = $totalRequests > 0
            ? round((ApiLog::successful()->count() / $totalRequests) * 100, 1)
            : 0;

        $avgResponseTime = ApiLog::whereNotNull('response_time')
            ->avg('response_time');

        return [
            Stat::make('مفاتيح API النشطة', $activeKeys)
                ->description('من أصل ' . $totalKeys . ' مفتاح')
                ->descriptionIcon('heroicon-m-key')
                ->color('success'),

            Stat::make('طلبات API اليوم', number_format($todayRequests))
                ->description('إجمالي: ' . number_format($totalRequests))
                ->descriptionIcon('heroicon-m-arrow-trending-up')
                ->color('info'),

            Stat::make('نسبة النجاح', $successRate . '%')
                ->description('للطلبات الناجحة')
                ->descriptionIcon('heroicon-m-check-circle')
                ->color($successRate >= 90 ? 'success' : ($successRate >= 70 ? 'warning' : 'danger')),

            Stat::make('متوسط وقت الاستجابة', round($avgResponseTime ?? 0) . 'ms')
                ->description('لجميع الطلبات')
                ->descriptionIcon('heroicon-m-clock')
                ->color($avgResponseTime < 200 ? 'success' : ($avgResponseTime < 500 ? 'warning' : 'danger')),
        ];
    }
}
