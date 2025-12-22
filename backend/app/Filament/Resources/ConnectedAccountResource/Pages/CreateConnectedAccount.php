<?php

namespace App\Filament\Resources\ConnectedAccountResource\Pages;

use App\Filament\Resources\ConnectedAccountResource;
use Filament\Resources\Pages\CreateRecord;

class CreateConnectedAccount extends CreateRecord
{
    protected static string $resource = ConnectedAccountResource::class;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }

    protected function getCreatedNotificationTitle(): ?string
    {
        return 'تم إضافة الحساب بنجاح';
    }
}
