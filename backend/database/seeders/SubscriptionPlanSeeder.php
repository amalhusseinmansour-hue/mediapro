<?php

namespace Database\Seeders;

use App\Models\SubscriptionPlan;
use Illuminate\Database\Seeder;

class SubscriptionPlanSeeder extends Seeder
{
    public function run(): void
    {
        // باقات الأفراد (Individual Plans)
        $individualPlans = [
            [
                'name' => 'باقة الأفراد الاقتصادية',
                'slug' => 'individual-economy',
                'description' => 'باقة اقتصادية للأفراد الجدد في عالم إدارة وسائل التواصل',
                'type' => 'monthly',
                'audience_type' => 'individual',
                'price' => 99.00,
                'currency' => 'AED',
                'max_accounts' => 2,
                'max_posts' => 20,
                'ai_features' => false,
                'analytics' => true,
                'scheduling' => true,
                'is_popular' => false,
                'is_active' => true,
                'sort_order' => 1,
                'features' => [
                    'ربط حتى 2 حساب',
                    '20 منشور شهرياً',
                    'جدولة المنشورات',
                    'تحليلات أساسية',
                    'دعم فني أساسي',
                ],
            ],
            [
                'name' => 'باقة الأفراد الأساسية',
                'slug' => 'individual-basic',
                'description' => 'باقة مثالية للأفراد الذين يبدأون في إدارة حساباتهم',
                'type' => 'monthly',
                'audience_type' => 'individual',
                'price' => 29.00,
                'currency' => 'AED',
                'max_accounts' => 3,
                'max_posts' => 30,
                'ai_features' => false,
                'analytics' => true,
                'scheduling' => true,
                'is_popular' => false,
                'is_active' => true,
                'sort_order' => 2,
                'features' => [
                    'ربط حتى 3 حسابات',
                    '30 منشور شهرياً',
                    'جدولة المنشورات',
                    'تحليلات بسيطة',
                    'دعم فني أساسي',
                ],
            ],
            [
                'name' => 'باقة الأفراد المتقدمة',
                'slug' => 'individual-pro',
                'description' => 'باقة شاملة للأفراد المحترفين',
                'type' => 'monthly',
                'audience_type' => 'individual',
                'price' => 59.00,
                'currency' => 'AED',
                'max_accounts' => 5,
                'max_posts' => 100,
                'ai_features' => true,
                'analytics' => true,
                'scheduling' => true,
                'is_popular' => true,
                'is_active' => true,
                'sort_order' => 3,
                'features' => [
                    'ربط حتى 5 حسابات',
                    '100 منشور شهرياً',
                    'ميزات الذكاء الاصطناعي',
                    'جدولة متقدمة',
                    'تحليلات متقدمة',
                    'اقتراحات المحتوى بالذكاء الاصطناعي',
                    'دعم فني ذو أولوية',
                ],
            ],
            [
                'name' => 'باقة الأفراد السنوية',
                'slug' => 'individual-yearly',
                'description' => 'باقة سنوية للأفراد مع خصم 20%',
                'type' => 'yearly',
                'audience_type' => 'individual',
                'price' => 550.00,
                'currency' => 'AED',
                'max_accounts' => 5,
                'max_posts' => 100,
                'ai_features' => true,
                'analytics' => true,
                'scheduling' => true,
                'is_popular' => false,
                'is_active' => true,
                'sort_order' => 4,
                'features' => [
                    'جميع ميزات الباقة المتقدمة',
                    'خصم 20% عند الدفع السنوي',
                    'تقارير سنوية شاملة',
                    'دعم فني على مدار الساعة',
                ],
            ],
        ];

        // باقات الأعمال (Business Plans)
        $businessPlans = [
            [
                'name' => 'باقة الأعمال الاقتصادية',
                'slug' => 'business-economy',
                'description' => 'مثالية للشركات الصغيرة والناشئة',
                'type' => 'monthly',
                'audience_type' => 'business',
                'price' => 159.00,
                'currency' => 'AED',
                'max_accounts' => 5,
                'max_posts' => 100,
                'ai_features' => true,
                'analytics' => true,
                'scheduling' => true,
                'is_popular' => false,
                'is_active' => true,
                'sort_order' => 5,
                'features' => [
                    'ربط حتى 5 حسابات',
                    '100 منشور شهرياً',
                    'ميزات الذكاء الاصطناعي الأساسية',
                    'تحليلات احترافية',
                    'تقارير مفصلة',
                    'إدارة فريق (2 مستخدمين)',
                    'دعم فني مخصص',
                ],
            ],
            [
                'name' => 'باقة الأعمال الصغيرة',
                'slug' => 'business-starter',
                'description' => 'مثالية للشركات الصغيرة والناشئة',
                'type' => 'monthly',
                'audience_type' => 'business',
                'price' => 99.00,
                'currency' => 'AED',
                'max_accounts' => 10,
                'max_posts' => 200,
                'ai_features' => true,
                'analytics' => true,
                'scheduling' => true,
                'is_popular' => false,
                'is_active' => true,
                'sort_order' => 6,
                'features' => [
                    'ربط حتى 10 حسابات',
                    '200 منشور شهرياً',
                    'ميزات الذكاء الاصطناعي الكاملة',
                    'تحليلات احترافية',
                    'تقارير مفصلة',
                    'إدارة فريق (3 مستخدمين)',
                    'دعم فني مخصص',
                ],
            ],
            [
                'name' => 'باقة الأعمال المتقدمة',
                'slug' => 'business-growth',
                'description' => 'للشركات المتنامية',
                'type' => 'monthly',
                'audience_type' => 'business',
                'price' => 199.00,
                'currency' => 'AED',
                'max_accounts' => 25,
                'max_posts' => 500,
                'ai_features' => true,
                'analytics' => true,
                'scheduling' => true,
                'is_popular' => true,
                'is_active' => true,
                'sort_order' => 7,
                'features' => [
                    'ربط حتى 25 حساباً',
                    '500 منشور شهرياً',
                    'ذكاء اصطناعي متطور',
                    'تحليلات شاملة',
                    'إدارة فريق (10 مستخدمين)',
                    'API access',
                    'دعم فني 24/7',
                    'مدير حساب مخصص',
                ],
            ],
            [
                'name' => 'باقة المؤسسات',
                'slug' => 'business-enterprise',
                'description' => 'حلول مخصصة للمؤسسات الكبيرة',
                'type' => 'monthly',
                'audience_type' => 'business',
                'price' => 499.00,
                'currency' => 'AED',
                'max_accounts' => 100,
                'max_posts' => 2000,
                'ai_features' => true,
                'analytics' => true,
                'scheduling' => true,
                'is_popular' => false,
                'is_active' => true,
                'sort_order' => 8,
                'features' => [
                    'حسابات غير محدودة',
                    'منشورات غير محدودة',
                    'جميع ميزات الذكاء الاصطناعي',
                    'تحليلات مخصصة',
                    'إدارة فريق غير محدودة',
                    'API كامل',
                    'تدريب مخصص',
                    'دعم فني VIP',
                ],
            ],
            [
                'name' => 'باقة الأعمال السنوية',
                'slug' => 'business-yearly',
                'description' => 'باقة سنوية للأعمال مع خصم 25%',
                'type' => 'yearly',
                'audience_type' => 'business',
                'price' => 1750.00,
                'currency' => 'AED',
                'max_accounts' => 25,
                'max_posts' => 500,
                'ai_features' => true,
                'analytics' => true,
                'scheduling' => true,
                'is_popular' => false,
                'is_active' => true,
                'sort_order' => 7,
                'features' => [
                    'جميع ميزات باقة الأعمال المتقدمة',
                    'خصم 25% عند الدفع السنوي',
                    'تقارير سنوية تفصيلية',
                    'استشارات استراتيجية',
                ],
            ],
        ];

        // إدراج باقات الأفراد
        foreach ($individualPlans as $plan) {
            SubscriptionPlan::updateOrCreate(
                ['slug' => $plan['slug']],
                $plan
            );
        }

        // إدراج باقات الأعمال
        foreach ($businessPlans as $plan) {
            SubscriptionPlan::updateOrCreate(
                ['slug' => $plan['slug']],
                $plan
            );
        }

        $this->command->info('✅ تم إنشاء ' . count($individualPlans) . ' باقات للأفراد');
        $this->command->info('✅ تم إنشاء ' . count($businessPlans) . ' باقات للأعمال');
    }
}
