<?php

namespace App\Filament\Resources\ConnectedAccountResource\Pages;

use App\Filament\Resources\ConnectedAccountResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;
use Filament\Resources\Components\Tab;
use Illuminate\Database\Eloquent\Builder;

class ListConnectedAccounts extends ListRecords
{
    protected static string $resource = ConnectedAccountResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make()
                ->label('إضافة حساب'),
        ];
    }

    public function getTabs(): array
    {
        return [
            'all' => Tab::make('الكل')
                ->badge(fn () => \App\Models\ConnectedAccount::count()),

            'active' => Tab::make('نشط')
                ->badge(fn () => \App\Models\ConnectedAccount::where('is_active', true)->count())
                ->modifyQueryUsing(fn (Builder $query) => $query->where('is_active', true))
                ->badgeColor('success'),

            'inactive' => Tab::make('غير نشط')
                ->badge(fn () => \App\Models\ConnectedAccount::where('is_active', false)->count())
                ->modifyQueryUsing(fn (Builder $query) => $query->where('is_active', false))
                ->badgeColor('danger'),

            'facebook' => Tab::make('Facebook')
                ->badge(fn () => \App\Models\ConnectedAccount::where('platform', 'facebook')->count())
                ->modifyQueryUsing(fn (Builder $query) => $query->where('platform', 'facebook'))
                ->icon('heroicon-o-globe-alt'),

            'instagram' => Tab::make('Instagram')
                ->badge(fn () => \App\Models\ConnectedAccount::where('platform', 'instagram')->count())
                ->modifyQueryUsing(fn (Builder $query) => $query->where('platform', 'instagram'))
                ->icon('heroicon-o-camera'),

            'twitter' => Tab::make('Twitter')
                ->badge(fn () => \App\Models\ConnectedAccount::where('platform', 'twitter')->count())
                ->modifyQueryUsing(fn (Builder $query) => $query->where('platform', 'twitter'))
                ->icon('heroicon-o-chat-bubble-left-right'),

            'expired_tokens' => Tab::make('Token منتهي')
                ->badge(fn () => \App\Models\ConnectedAccount::where('token_expires_at', '<', now())->count())
                ->modifyQueryUsing(fn (Builder $query) => $query->where('token_expires_at', '<', now()))
                ->badgeColor('warning')
                ->icon('heroicon-o-exclamation-triangle'),
        ];
    }
}
