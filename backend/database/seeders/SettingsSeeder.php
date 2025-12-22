<?php

namespace Database\Seeders;

use App\Models\Setting;
use Illuminate\Database\Seeder;

class SettingsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $settings = [
            // General Settings (عام)
            [
                'key' => 'app_name',
                'value' => 'ميديا برو',
                'type' => 'string',
                'group' => 'general',
                'description' => 'اسم التطبيق',
                'is_public' => true,
            ],
            [
                'key' => 'app_name_en',
                'value' => 'Media Pro',
                'type' => 'string',
                'group' => 'general',
                'description' => 'App name in English',
                'is_public' => true,
            ],
            [
                'key' => 'app_logo',
                'value' => 'https://mediaprosocial.io/images/logo.png',
                'type' => 'string',
                'group' => 'general',
                'description' => 'رابط شعار التطبيق',
                'is_public' => true,
            ],
            [
                'key' => 'support_email',
                'value' => 'support@mediaprosocial.io',
                'type' => 'string',
                'group' => 'general',
                'description' => 'البريد الإلكتروني للدعم',
                'is_public' => true,
            ],
            [
                'key' => 'support_phone',
                'value' => '+971XXXXXXXXX',
                'type' => 'string',
                'group' => 'general',
                'description' => 'رقم هاتف الدعم',
                'is_public' => true,
            ],
            [
                'key' => 'currency',
                'value' => 'AED',
                'type' => 'string',
                'group' => 'general',
                'description' => 'العملة الافتراضية',
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
                'key' => 'supported_languages',
                'value' => json_encode(['ar', 'en']),
                'type' => 'json',
                'group' => 'general',
                'description' => 'اللغات المدعومة',
                'is_public' => true,
            ],
            [
                'key' => 'terms_url',
                'value' => 'https://mediaprosocial.io/terms',
                'type' => 'string',
                'group' => 'general',
                'description' => 'رابط الشروط والأحكام',
                'is_public' => true,
            ],
            [
                'key' => 'privacy_url',
                'value' => 'https://mediaprosocial.io/privacy',
                'type' => 'string',
                'group' => 'general',
                'description' => 'رابط سياسة الخصوصية',
                'is_public' => true,
            ],

            // App Settings (التطبيق)
            [
                'key' => 'app_version',
                'value' => '1.0.0',
                'type' => 'string',
                'group' => 'app',
                'description' => 'إصدار التطبيق الحالي',
                'is_public' => true,
            ],
            [
                'key' => 'force_update',
                'value' => 'false',
                'type' => 'boolean',
                'group' => 'app',
                'description' => 'فرض التحديث على المستخدمين',
                'is_public' => true,
            ],
            [
                'key' => 'min_supported_version',
                'value' => '1.0.0',
                'type' => 'string',
                'group' => 'app',
                'description' => 'أقل إصدار مدعوم',
                'is_public' => true,
            ],
            [
                'key' => 'maintenance_mode',
                'value' => 'false',
                'type' => 'boolean',
                'group' => 'app',
                'description' => 'وضع الصيانة',
                'is_public' => true,
            ],
            [
                'key' => 'maintenance_message',
                'value' => 'التطبيق تحت الصيانة حالياً',
                'type' => 'string',
                'group' => 'app',
                'description' => 'رسالة وضع الصيانة',
                'is_public' => true,
            ],

            // AI Services (خدمات الذكاء الاصطناعي)
            [
                'key' => 'openai_api_key',
                'value' => '',
                'type' => 'string',
                'group' => 'ai',
                'description' => 'OpenAI API Key',
                'is_public' => false,
            ],
            [
                'key' => 'openai_model',
                'value' => 'gpt-4',
                'type' => 'string',
                'group' => 'ai',
                'description' => 'OpenAI Model to use',
                'is_public' => true,
            ],
            [
                'key' => 'gemini_api_key',
                'value' => '',
                'type' => 'string',
                'group' => 'ai',
                'description' => 'Google Gemini API Key',
                'is_public' => false,
            ],
            [
                'key' => 'anthropic_api_key',
                'value' => '',
                'type' => 'string',
                'group' => 'ai',
                'description' => 'Anthropic Claude API Key',
                'is_public' => false,
            ],
            [
                'key' => 'ai_enabled',
                'value' => 'true',
                'type' => 'boolean',
                'group' => 'ai',
                'description' => 'تفعيل خدمات الذكاء الاصطناعي',
                'is_public' => true,
            ],

            // Payment Gateways (بوابات الدفع)
            [
                'key' => 'paytabs_merchant_id',
                'value' => '',
                'type' => 'string',
                'group' => 'payment',
                'description' => 'PayTabs Merchant ID',
                'is_public' => false,
            ],
            [
                'key' => 'paytabs_secret_key',
                'value' => '',
                'type' => 'string',
                'group' => 'payment',
                'description' => 'PayTabs Secret Key',
                'is_public' => false,
            ],
            [
                'key' => 'paytabs_profile_id',
                'value' => '',
                'type' => 'string',
                'group' => 'payment',
                'description' => 'PayTabs Profile ID',
                'is_public' => false,
            ],
            [
                'key' => 'moyasar_api_key',
                'value' => '',
                'type' => 'string',
                'group' => 'payment',
                'description' => 'Moyasar API Key',
                'is_public' => false,
            ],
            [
                'key' => 'moyasar_secret_key',
                'value' => '',
                'type' => 'string',
                'group' => 'payment',
                'description' => 'Moyasar Secret Key',
                'is_public' => false,
            ],
            [
                'key' => 'stripe_public_key',
                'value' => '',
                'type' => 'string',
                'group' => 'payment',
                'description' => 'Stripe Public Key',
                'is_public' => false,
            ],
            [
                'key' => 'stripe_secret_key',
                'value' => '',
                'type' => 'string',
                'group' => 'payment',
                'description' => 'Stripe Secret Key',
                'is_public' => false,
            ],
            [
                'key' => 'payment_enabled',
                'value' => 'true',
                'type' => 'boolean',
                'group' => 'payment',
                'description' => 'تفعيل المدفوعات',
                'is_public' => true,
            ],
            [
                'key' => 'default_payment_gateway',
                'value' => 'paytabs',
                'type' => 'string',
                'group' => 'payment',
                'description' => 'بوابة الدفع الافتراضية',
                'is_public' => true,
            ],

            // SMS Services (خدمات الرسائل)
            [
                'key' => 'twilio_account_sid',
                'value' => '',
                'type' => 'string',
                'group' => 'sms',
                'description' => 'Twilio Account SID',
                'is_public' => false,
            ],
            [
                'key' => 'twilio_auth_token',
                'value' => '',
                'type' => 'string',
                'group' => 'sms',
                'description' => 'Twilio Auth Token',
                'is_public' => false,
            ],
            [
                'key' => 'twilio_phone_number',
                'value' => '',
                'type' => 'string',
                'group' => 'sms',
                'description' => 'Twilio Phone Number',
                'is_public' => false,
            ],
            [
                'key' => 'unifonic_app_sid',
                'value' => '',
                'type' => 'string',
                'group' => 'sms',
                'description' => 'Unifonic App SID',
                'is_public' => false,
            ],
            [
                'key' => 'unifonic_sender_id',
                'value' => '',
                'type' => 'string',
                'group' => 'sms',
                'description' => 'Unifonic Sender ID',
                'is_public' => false,
            ],
            [
                'key' => 'sms_provider',
                'value' => 'twilio',
                'type' => 'string',
                'group' => 'sms',
                'description' => 'مزود خدمة الرسائل',
                'is_public' => false,
            ],
            [
                'key' => 'sms_enabled',
                'value' => 'true',
                'type' => 'boolean',
                'group' => 'sms',
                'description' => 'تفعيل خدمة الرسائل',
                'is_public' => true,
            ],

            // Email Settings (البريد الإلكتروني)
            [
                'key' => 'mail_mailer',
                'value' => 'smtp',
                'type' => 'string',
                'group' => 'email',
                'description' => 'Mail Driver',
                'is_public' => false,
            ],
            [
                'key' => 'mail_host',
                'value' => 'smtp.gmail.com',
                'type' => 'string',
                'group' => 'email',
                'description' => 'SMTP Host',
                'is_public' => false,
            ],
            [
                'key' => 'mail_port',
                'value' => '587',
                'type' => 'integer',
                'group' => 'email',
                'description' => 'SMTP Port',
                'is_public' => false,
            ],
            [
                'key' => 'mail_username',
                'value' => '',
                'type' => 'string',
                'group' => 'email',
                'description' => 'SMTP Username',
                'is_public' => false,
            ],
            [
                'key' => 'mail_password',
                'value' => '',
                'type' => 'string',
                'group' => 'email',
                'description' => 'SMTP Password',
                'is_public' => false,
            ],
            [
                'key' => 'mail_encryption',
                'value' => 'tls',
                'type' => 'string',
                'group' => 'email',
                'description' => 'SMTP Encryption',
                'is_public' => false,
            ],
            [
                'key' => 'mail_from_address',
                'value' => 'noreply@mediaprosocial.io',
                'type' => 'string',
                'group' => 'email',
                'description' => 'From Email Address',
                'is_public' => false,
            ],
            [
                'key' => 'mail_from_name',
                'value' => 'Media Pro',
                'type' => 'string',
                'group' => 'email',
                'description' => 'From Name',
                'is_public' => false,
            ],

            // External Services (الخدمات الخارجية)
            [
                'key' => 'apify_api_key',
                'value' => '',
                'type' => 'string',
                'group' => 'external',
                'description' => 'Apify API Key (for TikTok/Instagram scraping)',
                'is_public' => false,
            ],
            [
                'key' => 'n8n_webhook_url',
                'value' => '',
                'type' => 'string',
                'group' => 'external',
                'description' => 'n8n Webhook URL',
                'is_public' => false,
            ],
            [
                'key' => 'postiz_api_key',
                'value' => '',
                'type' => 'string',
                'group' => 'external',
                'description' => 'Postiz API Key',
                'is_public' => false,
            ],
            [
                'key' => 'postiz_api_url',
                'value' => 'https://api.postiz.com/public/v1',
                'type' => 'string',
                'group' => 'external',
                'description' => 'Postiz API Base URL',
                'is_public' => false,
            ],

            // Firebase Configuration
            [
                'key' => 'firebase_enabled',
                'value' => 'false',
                'type' => 'boolean',
                'group' => 'firebase',
                'description' => 'تفعيل Firebase (للإشعارات والتحليلات)',
                'is_public' => true,
            ],
            [
                'key' => 'firebase_project_id',
                'value' => '',
                'type' => 'string',
                'group' => 'firebase',
                'description' => 'Firebase Project ID',
                'is_public' => false,
            ],
            [
                'key' => 'firebase_api_key',
                'value' => '',
                'type' => 'string',
                'group' => 'firebase',
                'description' => 'Firebase Web API Key',
                'is_public' => false,
            ],
            [
                'key' => 'firebase_messaging_sender_id',
                'value' => '',
                'type' => 'string',
                'group' => 'firebase',
                'description' => 'Firebase Cloud Messaging Sender ID',
                'is_public' => false,
            ],

            // Social Media (وسائل التواصل)
            [
                'key' => 'facebook_page_url',
                'value' => 'https://facebook.com/mediaprosocial',
                'type' => 'string',
                'group' => 'social',
                'description' => 'رابط صفحة Facebook',
                'is_public' => true,
            ],
            [
                'key' => 'instagram_url',
                'value' => 'https://instagram.com/mediaprosocial',
                'type' => 'string',
                'group' => 'social',
                'description' => 'رابط Instagram',
                'is_public' => true,
            ],
            [
                'key' => 'twitter_url',
                'value' => 'https://twitter.com/mediaprosocial',
                'type' => 'string',
                'group' => 'social',
                'description' => 'رابط Twitter/X',
                'is_public' => true,
            ],
            [
                'key' => 'linkedin_url',
                'value' => 'https://linkedin.com/company/mediaprosocial',
                'type' => 'string',
                'group' => 'social',
                'description' => 'رابط LinkedIn',
                'is_public' => true,
            ],

            // SEO Settings (تحسين محركات البحث)
            [
                'key' => 'meta_title',
                'value' => 'ميديا برو - إدارة وسائل التواصل الاجتماعي بالذكاء الاصطناعي',
                'type' => 'string',
                'group' => 'seo',
                'description' => 'عنوان الميتا',
                'is_public' => true,
            ],
            [
                'key' => 'meta_description',
                'value' => 'منصة شاملة لإدارة وسائل التواصل الاجتماعي باستخدام الذكاء الاصطناعي',
                'type' => 'string',
                'group' => 'seo',
                'description' => 'وصف الميتا',
                'is_public' => true,
            ],
            [
                'key' => 'meta_keywords',
                'value' => 'وسائل التواصل الاجتماعي, ذكاء اصطناعي, إدارة المحتوى, social media, AI',
                'type' => 'string',
                'group' => 'seo',
                'description' => 'كلمات مفتاحية',
                'is_public' => true,
            ],
        ];

        foreach ($settings as $setting) {
            Setting::updateOrCreate(
                ['key' => $setting['key']],
                $setting
            );
        }

        $this->command->info('✅ Settings seeded successfully!');
        $this->command->info('Total settings created: ' . count($settings));
    }
}
