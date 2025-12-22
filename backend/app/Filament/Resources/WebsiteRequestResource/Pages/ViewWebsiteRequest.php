<?php

namespace App\Filament\Resources\WebsiteRequestResource\Pages;

use App\Filament\Resources\WebsiteRequestResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewWebsiteRequest extends ViewRecord
{
    protected static string $resource = WebsiteRequestResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
            Actions\DeleteAction::make(),
        ];
    }
}
