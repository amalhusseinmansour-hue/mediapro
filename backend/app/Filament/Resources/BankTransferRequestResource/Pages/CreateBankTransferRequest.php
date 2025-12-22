<?php

namespace App\Filament\Resources\BankTransferRequestResource\Pages;

use App\Filament\Resources\BankTransferRequestResource;
use Filament\Resources\Pages\CreateRecord;

class CreateBankTransferRequest extends CreateRecord
{
    protected static string $resource = BankTransferRequestResource::class;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
