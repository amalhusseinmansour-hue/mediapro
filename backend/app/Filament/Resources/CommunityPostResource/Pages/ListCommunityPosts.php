<?php

namespace App\Filament\Resources\CommunityPostResource\Pages;

use App\Filament\Resources\CommunityPostResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListCommunityPosts extends ListRecords
{
    protected static string $resource = CommunityPostResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
