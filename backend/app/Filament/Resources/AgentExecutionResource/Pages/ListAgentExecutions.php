<?php

namespace App\Filament\Resources\AgentExecutionResource\Pages;

use App\Filament\Resources\AgentExecutionResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;
use Filament\Resources\Components\Tab;
use Illuminate\Database\Eloquent\Builder;

class ListAgentExecutions extends ListRecords
{
    protected static string $resource = AgentExecutionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            //
        ];
    }

    public function getTabs(): array
    {
        return [
            'الكل' => Tab::make()
                ->badge(fn () => \App\Models\AgentExecution::count()),

            'مكتملة' => Tab::make()
                ->modifyQueryUsing(fn (Builder $query) => $query->completed())
                ->badge(fn () => \App\Models\AgentExecution::completed()->count())
                ->badgeColor('success'),

            'جاري التنفيذ' => Tab::make()
                ->modifyQueryUsing(fn (Builder $query) => $query->processing())
                ->badge(fn () => \App\Models\AgentExecution::processing()->count())
                ->badgeColor('warning'),

            'فاشلة' => Tab::make()
                ->modifyQueryUsing(fn (Builder $query) => $query->failed())
                ->badge(fn () => \App\Models\AgentExecution::failed()->count())
                ->badgeColor('danger'),

            'Content Agent' => Tab::make()
                ->modifyQueryUsing(fn (Builder $query) => $query->byAgent('content'))
                ->badge(fn () => \App\Models\AgentExecution::byAgent('content')->count())
                ->badgeColor('info'),

            'Posting Agent' => Tab::make()
                ->modifyQueryUsing(fn (Builder $query) => $query->byAgent('posting'))
                ->badge(fn () => \App\Models\AgentExecution::byAgent('posting')->count())
                ->badgeColor('success'),
        ];
    }
}
