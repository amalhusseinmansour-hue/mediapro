<?php

namespace App\Filament\Resources\TelegramConnectionResource\Pages;

use App\Filament\Resources\TelegramConnectionResource;
use Filament\Resources\Pages\CreateRecord;

class CreateTelegramConnection extends CreateRecord
{
    protected static string $resource = TelegramConnectionResource::class;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
