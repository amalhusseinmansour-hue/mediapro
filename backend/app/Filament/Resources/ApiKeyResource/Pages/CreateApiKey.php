<?php

namespace App\Filament\Resources\ApiKeyResource\Pages;

use App\Filament\Resources\ApiKeyResource;
use Filament\Resources\Pages\CreateRecord;
use Filament\Notifications\Notification;

class CreateApiKey extends CreateRecord
{
    protected static string $resource = ApiKeyResource::class;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }

    protected function afterCreate(): void
    {
        Notification::make()
            ->title('تم إنشاء مفتاح API بنجاح')
            ->body('المفتاح: ' . $this->record->key)
            ->success()
            ->persistent()
            ->send();
    }
}
