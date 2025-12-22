<?php

namespace App\Filament\Resources\SponsoredAdRequestResource\Pages;

use App\Filament\Resources\SponsoredAdRequestResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListSponsoredAdRequests extends ListRecords
{
    protected static string $resource = SponsoredAdRequestResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
