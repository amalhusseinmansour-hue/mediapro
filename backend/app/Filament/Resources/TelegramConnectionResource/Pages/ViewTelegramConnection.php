<?php

namespace App\Filament\Resources\TelegramConnectionResource\Pages;

use App\Filament\Resources\TelegramConnectionResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewTelegramConnection extends ViewRecord
{
    protected static string $resource = TelegramConnectionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
            Actions\DeleteAction::make(),
        ];
    }
}
