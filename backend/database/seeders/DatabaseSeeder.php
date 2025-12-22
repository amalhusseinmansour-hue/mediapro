<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // استدعاء Seeders بالترتيب
        $this->call([
            LanguageSeeder::class,
            SubscriptionPlanSeeder::class,
            SettingSeeder::class,
            PageSeeder::class,
        ]);

        // إنشاء مستخدم تجريبي
        User::factory()->create([
            'name' => 'Admin User',
            'email' => 'admin@example.com',
            'password' => bcrypt('password'),
        ]);
    }
}
