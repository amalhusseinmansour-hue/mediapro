<?php

namespace Database\Seeders;

use App\Models\Language;
use Illuminate\Database\Seeder;

class LanguageSeeder extends Seeder
{
    public function run(): void
    {
        $languages = [
            [
                'name' => 'العربية',
                'code' => 'ar',
                'direction' => 'rtl',
                'flag' => '🇸🇦',
                'is_active' => true,
                'is_default' => true,
                'sort_order' => 1,
            ],
            [
                'name' => 'English',
                'code' => 'en',
                'direction' => 'ltr',
                'flag' => '🇺🇸',
                'is_active' => true,
                'is_default' => false,
                'sort_order' => 2,
            ],
        ];

        foreach ($languages as $language) {
            Language::updateOrCreate(
                ['code' => $language['code']],
                $language
            );
        }
    }
}
