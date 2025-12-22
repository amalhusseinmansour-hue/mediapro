<?php

namespace App\Filament\Resources\WebsiteRequestResource\Pages;

use App\Filament\Resources\WebsiteRequestResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListWebsiteRequests extends ListRecords
{
    protected static string $resource = WebsiteRequestResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
