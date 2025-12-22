<?php

namespace App\Filament\Resources\AgentExecutionResource\Pages;

use App\Filament\Resources\AgentExecutionResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewAgentExecution extends ViewRecord
{
    protected static string $resource = AgentExecutionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
