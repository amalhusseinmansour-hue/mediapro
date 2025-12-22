<?php

namespace App\Filament\Resources\ApiLogResource\Pages;

use App\Filament\Resources\ApiLogResource;
use App\Models\ApiLog;
use Filament\Resources\Pages\ListRecords;
use Filament\Resources\Components\Tab;

class ListApiLogs extends ListRecords
{
    protected static string $resource = ApiLogResource::class;

    public function getTabs(): array
    {
        return [
            'all' => Tab::make('الكل')
                ->badge(ApiLog::count()),

            'successful' => Tab::make('ناجح')
                ->modifyQueryUsing(fn ($query) => $query->successful())
                ->badge(ApiLog::successful()->count())
                ->badgeColor('success'),

            'failed' => Tab::make('فاشل')
                ->modifyQueryUsing(fn ($query) => $query->failed())
                ->badge(ApiLog::failed()->count())
                ->badgeColor('danger'),

            'today' => Tab::make('اليوم')
                ->modifyQueryUsing(fn ($query) => $query->today())
                ->badge(ApiLog::today()->count())
                ->badgeColor('info'),
        ];
    }
}
