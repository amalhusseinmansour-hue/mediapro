<?php

namespace App\Filament\Resources\WebsiteRequestResource\Pages;

use App\Filament\Resources\WebsiteRequestResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditWebsiteRequest extends EditRecord
{
    protected static string $resource = WebsiteRequestResource::class;

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
