<?php

namespace App\Filament\Resources\SponsoredAdRequestResource\Pages;

use App\Filament\Resources\SponsoredAdRequestResource;
use Filament\Resources\Pages\CreateRecord;

class CreateSponsoredAdRequest extends CreateRecord
{
    protected static string $resource = SponsoredAdRequestResource::class;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
