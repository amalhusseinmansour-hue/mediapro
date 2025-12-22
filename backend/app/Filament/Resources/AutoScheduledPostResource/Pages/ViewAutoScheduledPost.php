<?php

namespace App\Filament\Resources\AutoScheduledPostResource\Pages;

use App\Filament\Resources\AutoScheduledPostResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewAutoScheduledPost extends ViewRecord
{
    protected static string $resource = AutoScheduledPostResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
        ];
    }
}
