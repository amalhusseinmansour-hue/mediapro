<?php

namespace App\Filament\Resources\AutoScheduledPostResource\Pages;

use App\Filament\Resources\AutoScheduledPostResource;
use Filament\Resources\Pages\CreateRecord;

class CreateAutoScheduledPost extends CreateRecord
{
    protected static string $resource = AutoScheduledPostResource::class;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
