<?php

namespace App\Filament\Resources\WalletRechargeRequestResource\Pages;

use App\Filament\Resources\WalletRechargeRequestResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;
use Filament\Resources\Components\Tab;
use Illuminate\Database\Eloquent\Builder;

class ListWalletRechargeRequests extends ListRecords
{
    protected static string $resource = WalletRechargeRequestResource::class;

    protected function getHeaderActions(): array
    {
        return [
            // Statistics action commented out until the page is created
            // Actions\Action::make('statistics')
            //     ->label('الإحصائيات')
            //     ->icon('heroicon-o-chart-bar')
            //     ->color('info')
            //     ->url(route('filament.admin.pages.wallet-recharge-statistics')),
        ];
    }

    public function getTabs(): array
    {
        return [
            'all' => Tab::make('الكل'),

            'pending' => Tab::make('قيد الانتظار')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', 'pending'))
                ->badge(fn () => \App\Models\WalletRechargeRequest::pending()->count())
                ->badgeColor('warning'),

            'approved' => Tab::make('المقبولة')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', 'approved'))
                ->badge(fn () => \App\Models\WalletRechargeRequest::approved()->count())
                ->badgeColor('success'),

            'rejected' => Tab::make('المرفوضة')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', 'rejected'))
                ->badge(fn () => \App\Models\WalletRechargeRequest::rejected()->count())
                ->badgeColor('danger'),
        ];
    }
}
