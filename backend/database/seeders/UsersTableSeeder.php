<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UsersTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // إضافة مستخدمين تجريبيين
        $users = [
            [
                'name' => 'أحمد محمد',
                'email' => 'ahmed@mediapro.com',
                'password' => Hash::make('password123'),
                'user_type' => 'user',
                'is_active' => true,
            ],
            [
                'name' => 'فاطمة علي',
                'email' => 'fatima@mediapro.com',
                'password' => Hash::make('password123'),
                'user_type' => 'user', 
                'is_active' => true,
            ],
            [
                'name' => 'محمد خالد',
                'email' => 'mohamed@mediapro.com',
                'password' => Hash::make('password123'),
                'user_type' => 'premium',
                'is_active' => true,
            ],
        ];

        foreach ($users as $userData) {
            User::updateOrCreate(
                ['email' => $userData['email']], // البحث بالإيميل
                $userData // البيانات للتحديث أو الإنشاء
            );
        }

        echo "تم إضافة " . count($users) . " مستخدم بنجاح!\n";
    }
}