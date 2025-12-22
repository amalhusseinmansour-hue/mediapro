<?php

namespace App\Filament\Widgets;

use App\Models\AgentExecution;
use App\Models\TelegramConnection;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class AgentStatsWidget extends BaseWidget
{
    protected function getStats(): array
    {
        $totalExecutions = AgentExecution::count();
        $completedExecutions = AgentExecution::completed()->count();
        $failedExecutions = AgentExecution::failed()->count();
        $processingExecutions = AgentExecution::processing()->count();

        $todayExecutions = AgentExecution::whereDate('created_at', today())->count();
        $yesterdayExecutions = AgentExecution::whereDate('created_at', today()->subDay())->count();

        $executionChange = $yesterdayExecutions > 0
            ? round((($todayExecutions - $yesterdayExecutions) / $yesterdayExecutions) * 100, 1)
            : 0;

        $successRate = $totalExecutions > 0
            ? round(($completedExecutions / $totalExecutions) * 100, 1)
            : 0;

        $activeTelegramConnections = TelegramConnection::active()->count();
        $totalTelegramConnections = TelegramConnection::count();

        // Most used agent
        $mostUsedAgent = AgentExecution::selectRaw('agent_type, count(*) as count')
            ->groupBy('agent_type')
            ->orderByDesc('count')
            ->first();

        $agentNames = [
            'content' => 'Content Agent',
            'posting' => 'Posting Agent',
            'email' => 'Email Agent',
            'calendar' => 'Calendar Agent',
            'drive' => 'Drive Agent',
            'internet' => 'Internet Agent',
        ];

        $mostUsedAgentName = $mostUsedAgent
            ? ($agentNames[$mostUsedAgent->agent_type] ?? $mostUsedAgent->agent_type)
            : 'N/A';

        return [
            Stat::make('إجمالي التنفيذات', number_format($totalExecutions))
                ->description("{$todayExecutions} اليوم")
                ->descriptionIcon($executionChange >= 0 ? 'heroicon-m-arrow-trending-up' : 'heroicon-m-arrow-trending-down')
                ->color($executionChange >= 0 ? 'success' : 'danger')
                ->chart($this->getExecutionsChart()),

            Stat::make('معدل النجاح', "{$successRate}%")
                ->description("{$completedExecutions} مكتملة من {$totalExecutions}")
                ->descriptionIcon('heroicon-m-check-circle')
                ->color($successRate >= 80 ? 'success' : ($successRate >= 60 ? 'warning' : 'danger'))
                ->chart($this->getSuccessRateChart()),

            Stat::make('جاري التنفيذ', number_format($processingExecutions))
                ->description("{$failedExecutions} فاشلة")
                ->descriptionIcon('heroicon-m-clock')
                ->color('warning'),

            Stat::make('اتصالات Telegram', number_format($activeTelegramConnections))
                ->description("من {$totalTelegramConnections} إجمالي")
                ->descriptionIcon('heroicon-m-chat-bubble-left-right')
                ->color('info'),

            Stat::make('الأكثر استخداماً', $mostUsedAgentName)
                ->description($mostUsedAgent ? "{$mostUsedAgent->count} تنفيذ" : 'لا توجد بيانات')
                ->descriptionIcon('heroicon-m-cpu-chip')
                ->color('primary'),

            Stat::make('Credits المستخدمة', number_format(AgentExecution::sum('credits_used')))
                ->description('إجمالي الأرصدة')
                ->descriptionIcon('heroicon-m-currency-dollar')
                ->color('secondary'),
        ];
    }

    protected function getExecutionsChart(): array
    {
        // Get last 7 days execution count
        $data = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = today()->subDays($i);
            $data[] = AgentExecution::whereDate('created_at', $date)->count();
        }
        return $data;
    }

    protected function getSuccessRateChart(): array
    {
        // Get last 7 days success rate
        $data = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = today()->subDays($i);
            $total = AgentExecution::whereDate('created_at', $date)->count();
            $completed = AgentExecution::whereDate('created_at', $date)->completed()->count();
            $data[] = $total > 0 ? round(($completed / $total) * 100) : 0;
        }
        return $data;
    }

    protected static ?string $pollingInterval = '10s';
}
