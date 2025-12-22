<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Role;
use Illuminate\Support\Facades\Hash;

class AdminUserSeeder extends Seeder
{
    public function run(): void
    {
        // تأكد من وجود الأدوار أولاً
        $this->ensureRolesExist();

        $adminUsers = [
            [
                'name' => 'مدير النظام الرئيسي',
                'email' => 'admin@mediapro.com',
                'password' => 'Admin@2025',
                'role' => 'super_admin',
            ],
            [
                'name' => 'مدير النظام الاحتياطي',
                'email' => 'super@mediapro.com',
                'password' => 'Super@2025',
                'role' => 'super_admin',
            ],
            [
                'name' => 'الإدارة',
                'email' => 'management@mediapro.com',
                'password' => 'Management@2025',
                'role' => 'admin',
            ]
        ];

        // Delete existing admin users if exist
        $emails = array_column($adminUsers, 'email');
        User::whereIn('email', $emails)->delete();

        // Create admin users
        foreach ($adminUsers as $adminData) {
            $user = User::create([
                'name' => $adminData['name'],
                'email' => $adminData['email'],
                'password' => Hash::make($adminData['password']),
                'is_admin' => true,
                'is_active' => true,
                'user_type' => 'admin',
                'email_verified_at' => now(),
                'phone' => null,
                'bio' => 'مدير النظام - صلاحيات كاملة',
                'company_name' => 'MediaPro Social',
            ]);

            // ربط المستخدم بالدور
            $user->assignRole($adminData['role']);

            echo "✅ Admin user created: {$adminData['email']}\n";
            echo "   Password: {$adminData['password']}\n";
            echo "   Role: {$adminData['role']}\n";
        }

        echo "\n🎉 تم إنشاء " . count($adminUsers) . " مدير نظام بنجاح!\n";
        echo "🔐 يمكنك استخدام أي من البيانات أعلاه للدخول\n";
    }

    /**
     * إنشاء الأدوار الأساسية إذا لم تكن موجودة
     */
    private function ensureRolesExist(): void
    {
        $roles = [
            [
                'name' => 'super_admin',
                'display_name' => 'مدير النظام',
                'description' => 'صلاحيات كاملة لإدارة النظام بالكامل',
                'is_active' => true,
            ],
            [
                'name' => 'admin',
                'display_name' => 'مدير',
                'description' => 'صلاحيات إدارية عامة',
                'is_active' => true,
            ],
        ];

        foreach ($roles as $roleData) {
            Role::firstOrCreate(
                ['name' => $roleData['name']],
                $roleData
            );
        }

        echo "✅ Roles verified/created\n";
    }
}
