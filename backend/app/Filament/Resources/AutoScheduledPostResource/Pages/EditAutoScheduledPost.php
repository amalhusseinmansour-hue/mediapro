<?php

namespace App\Filament\Resources\AutoScheduledPostResource\Pages;

use App\Filament\Resources\AutoScheduledPostResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditAutoScheduledPost extends EditRecord
{
    protected static string $resource = AutoScheduledPostResource::class;

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
