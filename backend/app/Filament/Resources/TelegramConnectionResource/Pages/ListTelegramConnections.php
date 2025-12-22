<?php

namespace App\Filament\Resources\TelegramConnectionResource\Pages;

use App\Filament\Resources\TelegramConnectionResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;
use Filament\Resources\Components\Tab;
use Illuminate\Database\Eloquent\Builder;

class ListTelegramConnections extends ListRecords
{
    protected static string $resource = TelegramConnectionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }

    public function getTabs(): array
    {
        return [
            'الكل' => Tab::make()
                ->badge(fn () => \App\Models\TelegramConnection::count()),

            'النشطة' => Tab::make()
                ->modifyQueryUsing(fn (Builder $query) => $query->active())
                ->badge(fn () => \App\Models\TelegramConnection::active()->count())
                ->badgeColor('success'),

            'غير النشطة' => Tab::make()
                ->modifyQueryUsing(fn (Builder $query) => $query->where('is_active', false))
                ->badge(fn () => \App\Models\TelegramConnection::where('is_active', false)->count())
                ->badgeColor('danger'),

            'الإشعارات مفعلة' => Tab::make()
                ->modifyQueryUsing(fn (Builder $query) => $query->withNotifications())
                ->badge(fn () => \App\Models\TelegramConnection::withNotifications()->count())
                ->badgeColor('info'),
        ];
    }
}
