<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Setting;

class AppSettingsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $settings = [
            // App Settings
            [
                'key' => 'app_name',
                'value' => 'ميديا برو',
                'type' => 'string',
                'group' => 'app',
                'description' => 'اسم التطبيق بالعربي',
                'is_public' => true,
            ],
            [
                'key' => 'app_name_en',
                'value' => 'Media Pro Social',
                'type' => 'string',
                'group' => 'app',
                'description' => 'اسم التطبيق بالإنجليزي',
                'is_public' => true,
            ],
            [
                'key' => 'app_version',
                'value' => '1.0.0',
                'type' => 'string',
                'group' => 'app',
                'description' => 'إصدار التطبيق الحالي',
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
                'key' => 'force_update',
                'value' => false,
                'type' => 'boolean',
                'group' => 'app',
                'description' => 'إجبار المستخدم على التحديث',
                'is_public' => true,
            ],
            [
                'key' => 'maintenance_mode',
                'value' => false,
                'type' => 'boolean',
                'group' => 'app',
                'description' => 'وضع الصيانة',
                'is_public' => true,
            ],
            [
                'key' => 'maintenance_message',
                'value' => 'التطبيق تحت الصيانة حالياً. سنعود قريباً!',
                'type' => 'string',
                'group' => 'app',
                'description' => 'رسالة الصيانة',
                'is_public' => true,
            ],
            [
                'key' => 'app_logo',
                'value' => '',
                'type' => 'string',
                'group' => 'app',
                'description' => 'شعار التطبيق (URL)',
                'is_public' => true,
            ],
            [
                'key' => 'splash_screen_duration',
                'value' => '3',
                'type' => 'integer',
                'group' => 'app',
                'description' => 'مدة شاشة البداية بالثواني',
                'is_public' => true,
            ],
            [
                'key' => 'default_theme',
                'value' => 'dark',
                'type' => 'string',
                'group' => 'app',
                'description' => 'المظهر الافتراضي (dark/light)',
                'is_public' => true,
            ],
            [
                'key' => 'enable_onboarding',
                'value' => true,
                'type' => 'boolean',
                'group' => 'app',
                'description' => 'تفعيل شاشات التعريف للمستخدمين الجدد',
                'is_public' => true,
            ],

            // Localization
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
                'key' => 'rtl_enabled',
                'value' => true,
                'type' => 'boolean',
                'group' => 'general',
                'description' => 'تفعيل الكتابة من اليمين لليسار',
                'is_public' => true,
            ],

            // Support & Contact
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
                'value' => '+971 50 123 4567',
                'type' => 'string',
                'group' => 'general',
                'description' => 'رقم الهاتف للدعم',
                'is_public' => true,
            ],
            [
                'key' => 'support_whatsapp',
                'value' => '+971501234567',
                'type' => 'string',
                'group' => 'general',
                'description' => 'رقم واتساب للدعم',
                'is_public' => true,
            ],

            // Links
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
            [
                'key' => 'help_center_url',
                'value' => 'https://mediaprosocial.io/help',
                'type' => 'string',
                'group' => 'general',
                'description' => 'رابط مركز المساعدة',
                'is_public' => true,
            ],

            // Social Media Links
            [
                'key' => 'facebook_page_url',
                'value' => 'https://facebook.com/mediapro',
                'type' => 'string',
                'group' => 'social',
                'description' => 'رابط صفحة الفيسبوك',
                'is_public' => true,
            ],
            [
                'key' => 'instagram_url',
                'value' => 'https://instagram.com/mediapro',
                'type' => 'string',
                'group' => 'social',
                'description' => 'رابط الإنستجرام',
                'is_public' => true,
            ],
            [
                'key' => 'twitter_url',
                'value' => 'https://twitter.com/mediapro',
                'type' => 'string',
                'group' => 'social',
                'description' => 'رابط تويتر',
                'is_public' => true,
            ],
            [
                'key' => 'linkedin_url',
                'value' => 'https://linkedin.com/company/mediapro',
                'type' => 'string',
                'group' => 'social',
                'description' => 'رابط لينكد إن',
                'is_public' => true,
            ],
            [
                'key' => 'youtube_url',
                'value' => 'https://youtube.com/@mediapro',
                'type' => 'string',
                'group' => 'social',
                'description' => 'رابط يوتيوب',
                'is_public' => true,
            ],

            // Features
            [
                'key' => 'payment_enabled',
                'value' => true,
                'type' => 'boolean',
                'group' => 'app',
                'description' => 'تفعيل نظام الدفع',
                'is_public' => true,
            ],
            [
                'key' => 'ai_enabled',
                'value' => true,
                'type' => 'boolean',
                'group' => 'app',
                'description' => 'تفعيل ميزات الذكاء الاصطناعي',
                'is_public' => true,
            ],
            [
                'key' => 'sms_enabled',
                'value' => true,
                'type' => 'boolean',
                'group' => 'app',
                'description' => 'تفعيل خدمة الرسائل النصية',
                'is_public' => true,
            ],
            [
                'key' => 'firebase_enabled',
                'value' => false,
                'type' => 'boolean',
                'group' => 'app',
                'description' => 'تفعيل Firebase',
                'is_public' => true,
            ],
            [
                'key' => 'analytics_enabled',
                'value' => true,
                'type' => 'boolean',
                'group' => 'app',
                'description' => 'تفعيل التحليلات',
                'is_public' => true,
            ],
            [
                'key' => 'notifications_enabled',
                'value' => true,
                'type' => 'boolean',
                'group' => 'app',
                'description' => 'تفعيل الإشعارات',
                'is_public' => true,
            ],

            // App Limits & Restrictions
            [
                'key' => 'max_upload_size_mb',
                'value' => '50',
                'type' => 'integer',
                'group' => 'app',
                'description' => 'الحد الأقصى لحجم الملف المرفوع (MB)',
                'is_public' => true,
            ],
            [
                'key' => 'max_post_images',
                'value' => '10',
                'type' => 'integer',
                'group' => 'app',
                'description' => 'الحد الأقصى لعدد الصور في المنشور',
                'is_public' => true,
            ],
            [
                'key' => 'max_video_duration_seconds',
                'value' => '300',
                'type' => 'integer',
                'group' => 'app',
                'description' => 'الحد الأقصى لمدة الفيديو (ثواني)',
                'is_public' => true,
            ],
            [
                'key' => 'rate_limit_per_minute',
                'value' => '60',
                'type' => 'integer',
                'group' => 'app',
                'description' => 'عدد الطلبات المسموح بها في الدقيقة',
                'is_public' => true,
            ],

            // Colors & Branding
            [
                'key' => 'primary_color',
                'value' => '#6366F1',
                'type' => 'string',
                'group' => 'app',
                'description' => 'اللون الأساسي للتطبيق',
                'is_public' => true,
            ],
            [
                'key' => 'secondary_color',
                'value' => '#8B5CF6',
                'type' => 'string',
                'group' => 'app',
                'description' => 'اللون الثانوي للتطبيق',
                'is_public' => true,
            ],
            [
                'key' => 'accent_color',
                'value' => '#10B981',
                'type' => 'string',
                'group' => 'app',
                'description' => 'لون التمييز',
                'is_public' => true,
            ],

            // AI Settings (visible in app config)
            [
                'key' => 'ai_default_model',
                'value' => 'gpt-4',
                'type' => 'string',
                'group' => 'ai',
                'description' => 'النموذج الافتراضي للذكاء الاصطناعي',
                'is_public' => true,
            ],
            [
                'key' => 'ai_max_tokens',
                'value' => '2000',
                'type' => 'integer',
                'group' => 'ai',
                'description' => 'الحد الأقصى للتوكنز',
                'is_public' => true,
            ],
        ];

        foreach ($settings as $setting) {
            Setting::updateOrCreate(
                ['key' => $setting['key']],
                $setting
            );
        }

        $this->command->info('✅ App settings seeded successfully!');
    }
}
