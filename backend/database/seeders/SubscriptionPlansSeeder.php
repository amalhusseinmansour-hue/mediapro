<?php

namespace Database\Seeders;

use App\Models\Subscription;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class SubscriptionPlansSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $plans = [
            [
                'is_plan' => true,
                'name' => 'الباقة المجانية',
                'description' => 'مثالية للمبتدئين والاستخدام الشخصي',
                'type' => 'free',
                'price' => 0,
                'currency' => 'EGP',
                'max_accounts' => 2,
                'max_posts' => 10,
                'ai_features' => false,
                'analytics' => false,
                'scheduling' => true,
                'status' => 'active',
                'is_active' => true,
            ],
            [
                'is_plan' => true,
                'name' => 'الباقة الأساسية',
                'description' => 'للأفراد والشركات الصغيرة',
                'type' => 'monthly',
                'price' => 299,
                'currency' => 'EGP',
                'max_accounts' => 5,
                'max_posts' => 50,
                'ai_features' => true,
                'analytics' => true,
                'scheduling' => true,
                'status' => 'active',
                'is_active' => true,
            ],
            [
                'is_plan' => true,
                'name' => 'الباقة الاحترافية',
                'description' => 'للشركات المتوسطة والمحترفين',
                'type' => 'monthly',
                'price' => 599,
                'currency' => 'EGP',
                'max_accounts' => 15,
                'max_posts' => 150,
                'ai_features' => true,
                'analytics' => true,
                'scheduling' => true,
                'status' => 'active',
                'is_active' => true,
            ],
            [
                'is_plan' => true,
                'name' => 'باقة الأعمال',
                'description' => 'للشركات الكبيرة والوكالات',
                'type' => 'monthly',
                'price' => 999,
                'currency' => 'EGP',
                'max_accounts' => 999,
                'max_posts' => 9999,
                'ai_features' => true,
                'analytics' => true,
                'scheduling' => true,
                'status' => 'active',
                'is_active' => true,
            ],
        ];

        foreach ($plans as $plan) {
            Subscription::updateOrCreate(
                [
                    'name' => $plan['name'],
                    'is_plan' => true
                ],
                $plan
            );
        }

        $this->command->info('تم إنشاء خطط الاشتراك بنجاح!');
    }
}
