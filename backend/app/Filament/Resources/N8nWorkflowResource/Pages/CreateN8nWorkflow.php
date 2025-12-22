<?php

namespace App\Filament\Resources\N8nWorkflowResource\Pages;

use App\Filament\Resources\N8nWorkflowResource;
use Filament\Resources\Pages\CreateRecord;

class CreateN8nWorkflow extends CreateRecord
{
    protected static string $resource = N8nWorkflowResource::class;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
