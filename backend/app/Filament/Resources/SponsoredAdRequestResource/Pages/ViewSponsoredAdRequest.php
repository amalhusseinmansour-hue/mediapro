<?php

namespace App\Filament\Resources\SponsoredAdRequestResource\Pages;

use App\Filament\Resources\SponsoredAdRequestResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewSponsoredAdRequest extends ViewRecord
{
    protected static string $resource = SponsoredAdRequestResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
            Actions\DeleteAction::make(),
        ];
    }
}
