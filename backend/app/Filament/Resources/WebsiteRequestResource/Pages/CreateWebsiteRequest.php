<?php

namespace App\Filament\Resources\WebsiteRequestResource\Pages;

use App\Filament\Resources\WebsiteRequestResource;
use Filament\Resources\Pages\CreateRecord;

class CreateWebsiteRequest extends CreateRecord
{
    protected static string $resource = WebsiteRequestResource::class;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
