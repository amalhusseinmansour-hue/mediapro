<?php

namespace Database\Seeders;

use App\Models\Setting;
use Illuminate\Database\Seeder;

class SettingSeeder extends Seeder
{
    public function run(): void
    {
        $settings = [
            // General Settings
            [
                'key' => 'app_name',
                'value' => 'مدير وسائل التواصل الاجتماعي',
                'type' => 'string',
                'group' => 'general',
                'description' => 'اسم التطبيق',
                'is_public' => true,
            ],
            [
                'key' => 'app_description',
                'value' => 'منصة شاملة لإدارة حسابات وسائل التواصل الاجتماعي',
                'type' => 'string',
                'group' => 'general',
                'description' => 'وصف التطبيق',
                'is_public' => true,
            ],
            [
                'key' => 'default_language',
                'value' => 'ar',
                'type' => 'string',
                'group' => 'general',
                'description' => 'اللغة الافتراضية',
                'is_public' => true,
            ],
            [
                'key' => 'maintenance_mode',
                'value' => 'false',
                'type' => 'boolean',
                'group' => 'general',
                'description' => 'وضع الصيانة',
                'is_public' => true,
            ],

            // Payment Settings
            [
                'key' => 'payment_enabled',
                'value' => 'true',
                'type' => 'boolean',
                'group' => 'payment',
                'description' => 'تفعيل الدفع',
                'is_public' => false,
            ],
            [
                'key' => 'stripe_enabled',
                'value' => 'true',
                'type' => 'boolean',
                'group' => 'payment',
                'description' => 'تفعيل Stripe',
                'is_public' => true,
            ],
            [
                'key' => 'paypal_enabled',
                'value' => 'true',
                'type' => 'boolean',
                'group' => 'payment',
                'description' => 'تفعيل PayPal',
                'is_public' => true,
            ],
            [
                'key' => 'default_currency',
                'value' => 'USD',
                'type' => 'string',
                'group' => 'payment',
                'description' => 'العملة الافتراضية',
                'is_public' => true,
            ],

            // Email Settings
            [
                'key' => 'smtp_host',
                'value' => 'smtp.gmail.com',
                'type' => 'string',
                'group' => 'email',
                'description' => 'مضيف SMTP',
                'is_public' => false,
            ],
            [
                'key' => 'smtp_port',
                'value' => '587',
                'type' => 'integer',
                'group' => 'email',
                'description' => 'منفذ SMTP',
                'is_public' => false,
            ],

            // Social Settings
            [
                'key' => 'facebook_enabled',
                'value' => 'true',
                'type' => 'boolean',
                'group' => 'social',
                'description' => 'تفعيل Facebook',
                'is_public' => true,
            ],
            [
                'key' => 'twitter_enabled',
                'value' => 'true',
                'type' => 'boolean',
                'group' => 'social',
                'description' => 'تفعيل Twitter',
                'is_public' => true,
            ],
            [
                'key' => 'instagram_enabled',
                'value' => 'true',
                'type' => 'boolean',
                'group' => 'social',
                'description' => 'تفعيل Instagram',
                'is_public' => true,
            ],

            // SEO Settings
            [
                'key' => 'meta_title',
                'value' => 'مدير وسائل التواصل الاجتماعي',
                'type' => 'string',
                'group' => 'seo',
                'description' => 'عنوان الميتا',
                'is_public' => true,
            ],
            [
                'key' => 'meta_description',
                'value' => 'منصة شاملة لإدارة وجدولة منشورات وسائل التواصل الاجتماعي',
                'type' => 'string',
                'group' => 'seo',
                'description' => 'وصف الميتا',
                'is_public' => true,
            ],
            [
                'key' => 'meta_keywords',
                'value' => 'وسائل التواصل,إدارة,جدولة,منشورات',
                'type' => 'string',
                'group' => 'seo',
                'description' => 'كلمات الميتا المفتاحية',
                'is_public' => true,
            ],
        ];

        foreach ($settings as $setting) {
            Setting::updateOrCreate(
                ['key' => $setting['key']],
                $setting
            );
        }

        Setting::clearCache();
    }
}
