<?php

namespace App\Filament\Resources\SponsoredAdRequestResource\Pages;

use App\Filament\Resources\SponsoredAdRequestResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditSponsoredAdRequest extends EditRecord
{
    protected static string $resource = SponsoredAdRequestResource::class;

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
