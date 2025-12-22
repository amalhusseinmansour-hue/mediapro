<?php

namespace App\Filament\Pages;

use Filament\Pages\Page;

class ApiDocumentation extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-book-open';

    protected static string $view = 'filament.pages.api-documentation';

    protected static ?string $navigationGroup = 'النظام';

    protected static ?string $navigationLabel = 'توثيق API';

    protected static ?string $title = 'توثيق API';

    protected static ?int $navigationSort = 10;

    public function getHeading(): string
    {
        return 'توثيق واجهة برمجة التطبيقات (API)';
    }
}
