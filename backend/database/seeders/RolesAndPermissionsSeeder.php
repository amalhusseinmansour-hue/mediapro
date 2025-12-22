<?php

namespace Database\Seeders;

use App\Models\Permission;
use App\Models\Role;
use Illuminate\Database\Seeder;

class RolesAndPermissionsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // إنشاء الصلاحيات
        $permissions = [
            // إدارة المستخدمين
            ['name' => 'users.view', 'display_name' => 'عرض المستخدمين', 'description' => 'القدرة على عرض قائمة المستخدمين', 'group' => 'users'],
            ['name' => 'users.create', 'display_name' => 'إنشاء مستخدم', 'description' => 'القدرة على إنشاء مستخدمين جدد', 'group' => 'users'],
            ['name' => 'users.edit', 'display_name' => 'تعديل مستخدم', 'description' => 'القدرة على تعديل بيانات المستخدمين', 'group' => 'users'],
            ['name' => 'users.delete', 'display_name' => 'حذف مستخدم', 'description' => 'القدرة على حذف المستخدمين', 'group' => 'users'],

            // إدارة الأدوار
            ['name' => 'roles.view', 'display_name' => 'عرض الأدوار', 'description' => 'القدرة على عرض قائمة الأدوار', 'group' => 'roles'],
            ['name' => 'roles.create', 'display_name' => 'إنشاء دور', 'description' => 'القدرة على إنشاء أدوار جديدة', 'group' => 'roles'],
            ['name' => 'roles.edit', 'display_name' => 'تعديل دور', 'description' => 'القدرة على تعديل الأدوار', 'group' => 'roles'],
            ['name' => 'roles.delete', 'display_name' => 'حذف دور', 'description' => 'القدرة على حذف الأدوار', 'group' => 'roles'],

            // إدارة الصلاحيات
            ['name' => 'permissions.view', 'display_name' => 'عرض الصلاحيات', 'description' => 'القدرة على عرض قائمة الصلاحيات', 'group' => 'permissions'],
            ['name' => 'permissions.create', 'display_name' => 'إنشاء صلاحية', 'description' => 'القدرة على إنشاء صلاحيات جديدة', 'group' => 'permissions'],
            ['name' => 'permissions.edit', 'display_name' => 'تعديل صلاحية', 'description' => 'القدرة على تعديل الصلاحيات', 'group' => 'permissions'],
            ['name' => 'permissions.delete', 'display_name' => 'حذف صلاحية', 'description' => 'القدرة على حذف الصلاحيات', 'group' => 'permissions'],

            // إدارة الاشتراكات
            ['name' => 'subscriptions.view', 'display_name' => 'عرض الاشتراكات', 'description' => 'القدرة على عرض قائمة الاشتراكات', 'group' => 'subscriptions'],
            ['name' => 'subscriptions.create', 'display_name' => 'إنشاء اشتراك', 'description' => 'القدرة على إنشاء اشتراكات جديدة', 'group' => 'subscriptions'],
            ['name' => 'subscriptions.edit', 'display_name' => 'تعديل اشتراك', 'description' => 'القدرة على تعديل الاشتراكات', 'group' => 'subscriptions'],
            ['name' => 'subscriptions.delete', 'display_name' => 'حذف اشتراك', 'description' => 'القدرة على حذف الاشتراكات', 'group' => 'subscriptions'],

            // إدارة المدفوعات
            ['name' => 'payments.view', 'display_name' => 'عرض المدفوعات', 'description' => 'القدرة على عرض قائمة المدفوعات', 'group' => 'payments'],
            ['name' => 'payments.create', 'display_name' => 'إنشاء مدفوعة', 'description' => 'القدرة على إنشاء مدفوعات جديدة', 'group' => 'payments'],
            ['name' => 'payments.edit', 'display_name' => 'تعديل مدفوعة', 'description' => 'القدرة على تعديل المدفوعات', 'group' => 'payments'],
            ['name' => 'payments.delete', 'display_name' => 'حذف مدفوعة', 'description' => 'القدرة على حذف المدفوعات', 'group' => 'payments'],
            ['name' => 'payments.refund', 'display_name' => 'استرجاع مدفوعة', 'description' => 'القدرة على استرجاع المدفوعات', 'group' => 'payments'],

            // إدارة الإعدادات
            ['name' => 'settings.view', 'display_name' => 'عرض الإعدادات', 'description' => 'القدرة على عرض الإعدادات', 'group' => 'settings'],
            ['name' => 'settings.edit', 'display_name' => 'تعديل الإعدادات', 'description' => 'القدرة على تعديل الإعدادات', 'group' => 'settings'],

            // إدارة المحتوى
            ['name' => 'content.view', 'display_name' => 'عرض المحتوى', 'description' => 'القدرة على عرض المحتوى', 'group' => 'content'],
            ['name' => 'content.create', 'display_name' => 'إنشاء محتوى', 'description' => 'القدرة على إنشاء محتوى جديد', 'group' => 'content'],
            ['name' => 'content.edit', 'display_name' => 'تعديل محتوى', 'description' => 'القدرة على تعديل المحتوى', 'group' => 'content'],
            ['name' => 'content.delete', 'display_name' => 'حذف محتوى', 'description' => 'القدرة على حذف المحتوى', 'group' => 'content'],

            // التقارير
            ['name' => 'reports.view', 'display_name' => 'عرض التقارير', 'description' => 'القدرة على عرض التقارير', 'group' => 'reports'],

            // لوحة التحكم
            ['name' => 'dashboard.view', 'display_name' => 'عرض لوحة التحكم', 'description' => 'القدرة على الوصول للوحة التحكم', 'group' => 'dashboard'],

            // إدارة مفاتيح API
            ['name' => 'apikeys.view', 'display_name' => 'عرض مفاتيح API', 'description' => 'القدرة على عرض مفاتيح API', 'group' => 'apikeys'],
            ['name' => 'apikeys.create', 'display_name' => 'إنشاء مفتاح API', 'description' => 'القدرة على إنشاء مفاتيح API جديدة', 'group' => 'apikeys'],
            ['name' => 'apikeys.edit', 'display_name' => 'تعديل مفتاح API', 'description' => 'القدرة على تعديل مفاتيح API', 'group' => 'apikeys'],
            ['name' => 'apikeys.delete', 'display_name' => 'حذف مفتاح API', 'description' => 'القدرة على حذف مفاتيح API', 'group' => 'apikeys'],

            // إدارة الصفحات
            ['name' => 'pages.view', 'display_name' => 'عرض الصفحات', 'description' => 'القدرة على عرض الصفحات', 'group' => 'pages'],
            ['name' => 'pages.create', 'display_name' => 'إنشاء صفحة', 'description' => 'القدرة على إنشاء صفحات جديدة', 'group' => 'pages'],
            ['name' => 'pages.edit', 'display_name' => 'تعديل صفحة', 'description' => 'القدرة على تعديل الصفحات', 'group' => 'pages'],
            ['name' => 'pages.delete', 'display_name' => 'حذف صفحة', 'description' => 'القدرة على حذف الصفحات', 'group' => 'pages'],

            // Brand Kits
            ['name' => 'brandkits.view', 'display_name' => 'عرض Brand Kits', 'description' => 'القدرة على عرض Brand Kits', 'group' => 'brandkits'],
            ['name' => 'brandkits.create', 'display_name' => 'إنشاء Brand Kit', 'description' => 'القدرة على إنشاء Brand Kits', 'group' => 'brandkits'],
            ['name' => 'brandkits.edit', 'display_name' => 'تعديل Brand Kit', 'description' => 'القدرة على تعديل Brand Kits', 'group' => 'brandkits'],
            ['name' => 'brandkits.delete', 'display_name' => 'حذف Brand Kit', 'description' => 'القدرة على حذف Brand Kits', 'group' => 'brandkits'],

            // AI Generations
            ['name' => 'aigenerations.view', 'display_name' => 'عرض AI Generations', 'description' => 'القدرة على عرض AI Generations', 'group' => 'aigenerations'],
            ['name' => 'aigenerations.create', 'display_name' => 'إنشاء AI Generation', 'description' => 'القدرة على إنشاء AI Generations', 'group' => 'aigenerations'],
            ['name' => 'aigenerations.delete', 'display_name' => 'حذف AI Generation', 'description' => 'القدرة على حذف AI Generations', 'group' => 'aigenerations'],

            // Earnings
            ['name' => 'earnings.view', 'display_name' => 'عرض الأرباح', 'description' => 'القدرة على عرض الأرباح', 'group' => 'earnings'],
            ['name' => 'earnings.create', 'display_name' => 'إنشاء ربح', 'description' => 'القدرة على إنشاء سجلات أرباح', 'group' => 'earnings'],
            ['name' => 'earnings.edit', 'display_name' => 'تعديل ربح', 'description' => 'القدرة على تعديل الأرباح', 'group' => 'earnings'],
            ['name' => 'earnings.delete', 'display_name' => 'حذف ربح', 'description' => 'القدرة على حذف سجلات الأرباح', 'group' => 'earnings'],

            // Notifications
            ['name' => 'notifications.view', 'display_name' => 'عرض الإشعارات', 'description' => 'القدرة على عرض الإشعارات', 'group' => 'notifications'],
            ['name' => 'notifications.create', 'display_name' => 'إنشاء إشعار', 'description' => 'القدرة على إنشاء إشعارات', 'group' => 'notifications'],
            ['name' => 'notifications.delete', 'display_name' => 'حذف إشعار', 'description' => 'القدرة على حذف الإشعارات', 'group' => 'notifications'],
        ];

        // إنشاء الصلاحيات
        foreach ($permissions as $permission) {
            Permission::firstOrCreate(
                ['name' => $permission['name']],
                $permission
            );
        }

        // إنشاء الأدوار
        $superAdmin = Role::firstOrCreate(
            ['name' => 'super_admin'],
            [
                'display_name' => 'مدير النظام',
                'description' => 'صلاحيات كاملة لإدارة النظام بالكامل',
                'is_active' => true,
            ]
        );

        $admin = Role::firstOrCreate(
            ['name' => 'admin'],
            [
                'display_name' => 'مدير',
                'description' => 'صلاحيات إدارية عامة',
                'is_active' => true,
            ]
        );

        $manager = Role::firstOrCreate(
            ['name' => 'manager'],
            [
                'display_name' => 'مدير محتوى',
                'description' => 'صلاحيات إدارة المحتوى والتقارير',
                'is_active' => true,
            ]
        );

        $user = Role::firstOrCreate(
            ['name' => 'user'],
            [
                'display_name' => 'مستخدم',
                'description' => 'صلاحيات المستخدم العادي',
                'is_active' => true,
            ]
        );

        // منح الصلاحيات للأدوار
        // Super Admin: جميع الصلاحيات
        $allPermissions = Permission::all();
        $superAdmin->permissions()->sync($allPermissions);

        // Admin: جميع الصلاحيات ما عدا إدارة الأدوار والصلاحيات
        $adminPermissions = Permission::whereNotIn('group', ['roles', 'permissions'])->get();
        $admin->permissions()->sync($adminPermissions);

        // Manager: إدارة المحتوى، التقارير، لوحة التحكم، الصفحات، Brand Kits، AI Generations
        $managerPermissions = Permission::whereIn('group', [
            'content',
            'reports',
            'dashboard',
            'pages',
            'brandkits',
            'aigenerations',
            'notifications'
        ])->get();
        $manager->permissions()->sync($managerPermissions);

        // User: عرض فقط
        $userPermissions = Permission::whereIn('name', [
            'dashboard.view',
            'content.view',
            'reports.view',
            'brandkits.view',
            'brandkits.create',
            'brandkits.edit',
            'brandkits.delete',
            'aigenerations.view',
            'aigenerations.create',
            'notifications.view',
        ])->get();
        $user->permissions()->sync($userPermissions);

        $this->command->info('تم إنشاء الأدوار والصلاحيات بنجاح!');
    }
}
