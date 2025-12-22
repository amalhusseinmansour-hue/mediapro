<?php

namespace App\Filament\Resources\BankTransferRequestResource\Pages;

use App\Filament\Resources\BankTransferRequestResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListBankTransferRequests extends ListRecords
{
    protected static string $resource = BankTransferRequestResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
