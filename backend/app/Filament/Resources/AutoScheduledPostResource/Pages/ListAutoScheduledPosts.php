<?php

namespace App\Filament\Resources\AutoScheduledPostResource\Pages;

use App\Filament\Resources\AutoScheduledPostResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListAutoScheduledPosts extends ListRecords
{
    protected static string $resource = AutoScheduledPostResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
