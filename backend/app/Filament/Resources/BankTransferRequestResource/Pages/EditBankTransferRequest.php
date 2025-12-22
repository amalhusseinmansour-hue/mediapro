<?php

namespace App\Filament\Resources\BankTransferRequestResource\Pages;

use App\Filament\Resources\BankTransferRequestResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditBankTransferRequest extends EditRecord
{
    protected static string $resource = BankTransferRequestResource::class;

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
