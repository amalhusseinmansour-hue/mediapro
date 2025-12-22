<?php

namespace App\Filament\Resources\N8nWorkflowResource\Pages;

use App\Filament\Resources\N8nWorkflowResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListN8nWorkflows extends ListRecords
{
    protected static string $resource = N8nWorkflowResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
