<?php

namespace App\Filament\Resources\N8nWorkflowResource\Pages;

use App\Filament\Resources\N8nWorkflowResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditN8nWorkflow extends EditRecord
{
    protected static string $resource = N8nWorkflowResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\ViewAction::make(),
            Actions\DeleteAction::make(),
        ];
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
