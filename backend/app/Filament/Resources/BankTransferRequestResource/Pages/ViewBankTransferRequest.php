<?php

namespace App\Filament\Resources\BankTransferRequestResource\Pages;

use App\Filament\Resources\BankTransferRequestResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewBankTransferRequest extends ViewRecord
{
    protected static string $resource = BankTransferRequestResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
            Actions\DeleteAction::make(),
        ];
    }
}
