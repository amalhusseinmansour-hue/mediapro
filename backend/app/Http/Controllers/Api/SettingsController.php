<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Cache;

class SettingsController extends Controller
{
    /**
     * Get all public settings
     *
     * @return JsonResponse
     */
    public function getPublicSettings(): JsonResponse
    {
        try {
            $settings = Cache::remember('public_settings', 3600, function () {
                $publicSettings = Setting::where('is_public', true)->get();

                $result = [];
                foreach ($publicSettings as $setting) {
                    $result[$setting->key] = $this->castValue($setting->value, $setting->type);
                }

                return $result;
            });

            return response()->json([
                'success' => true,
                'data' => $settings,
                'message' => 'Public settings retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve settings',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get settings by group (public only)
     *
     * @param string $group
     * @return JsonResponse
     */
    public function getSettingsByGroup(string $group): JsonResponse
    {
        try {
            $settings = Cache::remember("public_settings_{$group}", 3600, function () use ($group) {
                $groupSettings = Setting::where('group', $group)
                    ->where('is_public', true)
                    ->get();

                $result = [];
                foreach ($groupSettings as $setting) {
                    $result[$setting->key] = $this->castValue($setting->value, $setting->type);
                }

                return $result;
            });

            return response()->json([
                'success' => true,
                'group' => $group,
                'data' => $settings,
                'message' => "Settings for group '{$group}' retrieved successfully"
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve settings',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get app configuration (optimized for mobile app)
     *
     * @return JsonResponse
     */
    public function getAppConfig(): JsonResponse
    {
        try {
            $config = Cache::remember('app_config', 3600, function () {
                return [
                    'app' => [
                        'name' => Setting::get('app_name', 'ميديا برو'),
                        'name_en' => Setting::get('app_name_en', 'Media Pro'),
                        'version' => Setting::get('app_version', '1.0.0'),
                        'logo' => Setting::get('app_logo', ''),
                        'force_update' => Setting::get('force_update', false),
                        'min_supported_version' => Setting::get('min_supported_version', '1.0.0'),
                        'maintenance_mode' => Setting::get('maintenance_mode', false),
                        'maintenance_message' => Setting::get('maintenance_message', ''),
                    ],
                    'support' => [
                        'email' => Setting::get('support_email', ''),
                        'phone' => Setting::get('support_phone', ''),
                    ],
                    'localization' => [
                        'currency' => Setting::get('currency', 'AED'),
                        'default_language' => Setting::get('default_language', 'ar'),
                        'supported_languages' => Setting::get('supported_languages', ['ar', 'en']),
                    ],
                    'links' => [
                        'terms' => Setting::get('terms_url', ''),
                        'privacy' => Setting::get('privacy_url', ''),
                        'facebook' => Setting::get('facebook_page_url', ''),
                        'instagram' => Setting::get('instagram_url', ''),
                        'twitter' => Setting::get('twitter_url', ''),
                        'linkedin' => Setting::get('linkedin_url', ''),
                    ],
                    'features' => [
                        'payment_enabled' => Setting::get('payment_enabled', true),
                        'sms_enabled' => Setting::get('sms_enabled', true),
                        'ai_enabled' => Setting::get('ai_enabled', true),
                        'firebase_enabled' => Setting::get('firebase_enabled', false),
                    ],
                    'ai' => [
                        'enabled' => Setting::get('ai_enabled', true),
                        'default_model' => Setting::get('openai_model', 'gpt-4'),
                    ],
                    'seo' => [
                        'meta_title' => Setting::get('meta_title', ''),
                        'meta_description' => Setting::get('meta_description', ''),
                        'meta_keywords' => Setting::get('meta_keywords', ''),
                    ],
                    'payment' => [
                        // Payment gateways enabled status (safe to expose)
                        'stripe_enabled' => Setting::get('stripe_enabled', false),
                        'paymob_enabled' => Setting::get('paymob_enabled', false),
                        'paypal_enabled' => Setting::get('paypal_enabled', false),
                        'google_pay_enabled' => Setting::get('google_pay_enabled', false),
                        'apple_pay_enabled' => Setting::get('apple_pay_enabled', false),
                        'default_gateway' => Setting::get('default_payment_gateway', 'stripe'),

                        // Payment settings
                        'minimum_amount' => Setting::get('minimum_payment_amount', 10),
                        'currency' => Setting::get('payment_currency', Setting::get('currency', 'AED')),
                        'processing_fee_percentage' => Setting::get('processing_fee_percentage', 0),
                        'processing_fee_fixed' => Setting::get('processing_fee_fixed', 0),

                        // Refund settings
                        'refunds_enabled' => Setting::get('enable_refunds', true),
                        'refund_period_days' => Setting::get('refund_period_days', 30),
                        'refund_fee' => Setting::get('refund_fee', 0),

                        // Security settings
                        'require_3d_secure' => Setting::get('require_3d_secure', true),
                        'fraud_detection_enabled' => Setting::get('fraud_detection_enabled', true),

                        // Stripe specific (public info only)
                        'stripe_public_key' => Setting::get('stripe_public_key', ''),
                        'stripe_currency' => Setting::get('stripe_currency', 'AED'),
                        'stripe_apple_pay_enabled' => Setting::get('stripe_enable_apple_pay', false),
                        'stripe_google_pay_enabled' => Setting::get('stripe_enable_google_pay', false),

                        // Paymob specific (public info only)
                        'paymob_currency' => Setting::get('paymob_currency', 'EGP'),
                        'paymob_cards_enabled' => Setting::get('paymob_cards_enabled', true),
                        'paymob_wallets_enabled' => Setting::get('paymob_wallets_enabled', false),
                        'paymob_installments_enabled' => Setting::get('paymob_installments_enabled', false),

                        // PayPal specific (public info only)
                        'paypal_currency' => Setting::get('paypal_currency', 'USD'),
                        'paypal_venmo_enabled' => Setting::get('paypal_venmo_enabled', false),
                        'paypal_credit_enabled' => Setting::get('paypal_credit_enabled', false),
                        'paypal_brand_name' => Setting::get('paypal_brand_name', 'Media Pro'),

                        // Google Pay specific (public info only)
                        'google_pay_merchant_id' => Setting::get('google_pay_merchant_id', ''),
                        'google_pay_merchant_name' => Setting::get('google_pay_merchant_name', 'Media Pro Social'),
                        'google_pay_environment' => Setting::get('google_pay_environment', 'TEST'),
                        'google_pay_gateway' => Setting::get('google_pay_gateway', 'stripe'),
                        'google_pay_gateway_merchant_id' => Setting::get('google_pay_gateway_merchant_id', ''),
                        'google_pay_billing_address_required' => Setting::get('google_pay_billing_address_required', false),
                        'google_pay_shipping_address_required' => Setting::get('google_pay_shipping_address_required', false),
                        'google_pay_email_required' => Setting::get('google_pay_email_required', false),
                        'google_pay_phone_required' => Setting::get('google_pay_phone_required', false),
                        'google_pay_button_color' => Setting::get('google_pay_button_color', 'default'),
                        'google_pay_button_type' => Setting::get('google_pay_button_type', 'pay'),

                        // Apple Pay specific (public info only)
                        'apple_pay_merchant_id' => Setting::get('apple_pay_merchant_id', ''),
                        'apple_pay_merchant_name' => Setting::get('apple_pay_merchant_name', 'Media Pro Social'),
                        'apple_pay_country_code' => Setting::get('apple_pay_country_code', 'AE'),
                        'apple_pay_currency_code' => Setting::get('apple_pay_currency_code', 'AED'),
                        'apple_pay_gateway' => Setting::get('apple_pay_gateway', 'stripe'),
                        'apple_pay_require_billing' => Setting::get('apple_pay_require_billing', false),
                        'apple_pay_require_shipping' => Setting::get('apple_pay_require_shipping', false),
                        'apple_pay_require_email' => Setting::get('apple_pay_require_email', false),
                        'apple_pay_require_phone' => Setting::get('apple_pay_require_phone', false),
                        'apple_pay_button_style' => Setting::get('apple_pay_button_style', 'black'),
                        'apple_pay_button_type' => Setting::get('apple_pay_button_type', 'buy'),
                    ],
                    'analytics' => [
                        // General analytics settings
                        'enabled' => Setting::get('analytics_enabled', true),
                        'tracking_enabled' => Setting::get('analytics_tracking_enabled', true),
                        'realtime_enabled' => Setting::get('analytics_realtime_enabled', true),
                        'data_retention_days' => Setting::get('analytics_data_retention_days', 90),

                        // Google Analytics (public info only)
                        'google_analytics_enabled' => Setting::get('google_analytics_enabled', false),
                        'google_analytics_tracking_id' => Setting::get('google_analytics_tracking_id', ''),
                        'google_analytics_measurement_id' => Setting::get('google_analytics_measurement_id', ''),

                        // Facebook Pixel (public info only)
                        'facebook_pixel_enabled' => Setting::get('facebook_pixel_enabled', false),
                        'facebook_pixel_id' => Setting::get('facebook_pixel_id', ''),

                        // Firebase Analytics
                        'firebase_analytics_enabled' => Setting::get('firebase_analytics_enabled', false),
                        'firebase_auto_log_events' => Setting::get('firebase_auto_log_events', true),
                        'firebase_session_timeout' => Setting::get('firebase_session_timeout', 30),

                        // Tracking options
                        'track_user_behavior' => Setting::get('track_user_behavior', true),
                        'track_user_location' => Setting::get('track_user_location', true),
                        'track_device_info' => Setting::get('track_device_info', true),
                        'track_session_duration' => Setting::get('track_session_duration', true),
                        'track_post_performance' => Setting::get('track_post_performance', true),
                        'track_social_engagement' => Setting::get('track_social_engagement', true),

                        // Reports
                        'daily_reports_enabled' => Setting::get('daily_reports_enabled', false),
                        'weekly_reports_enabled' => Setting::get('weekly_reports_enabled', true),
                        'monthly_reports_enabled' => Setting::get('monthly_reports_enabled', true),

                        // Privacy
                        'anonymize_ip' => Setting::get('anonymize_ip', true),
                        'gdpr_compliance' => Setting::get('gdpr_compliance', true),
                        'ccpa_compliance' => Setting::get('ccpa_compliance', false),
                    ],
                    'ai_content' => [
                        // General AI settings
                        'enabled' => Setting::get('ai_content_generation_enabled', true),
                        'provider' => Setting::get('ai_provider', 'openai'),
                        'default_language' => Setting::get('ai_default_language', 'ar'),
                        'request_timeout' => Setting::get('ai_request_timeout', 30),

                        // Text generation
                        'text_generation_enabled' => Setting::get('ai_text_generation_enabled', true),
                        'text_model' => Setting::get('ai_text_model', 'gpt-4'),
                        'text_max_tokens' => Setting::get('ai_text_max_tokens', 2000),
                        'text_temperature' => Setting::get('ai_text_temperature', 0.7),
                        'content_ideas_enabled' => Setting::get('ai_content_ideas_enabled', true),
                        'hashtag_generator_enabled' => Setting::get('ai_hashtag_generator_enabled', true),
                        'caption_generator_enabled' => Setting::get('ai_caption_generator_enabled', true),

                        // Image generation
                        'image_generation_enabled' => Setting::get('ai_image_generation_enabled', true),
                        'image_provider' => Setting::get('ai_image_provider', 'dalle'),
                        'image_quality' => Setting::get('ai_image_quality', 'standard'),
                        'image_size' => Setting::get('ai_image_size', '1024x1024'),
                        'image_edit_enabled' => Setting::get('ai_image_edit_enabled', true),
                        'background_removal_enabled' => Setting::get('ai_background_removal_enabled', true),

                        // Video generation
                        'video_generation_enabled' => Setting::get('ai_video_generation_enabled', false),
                        'video_provider' => Setting::get('ai_video_provider', 'runway'),
                        'video_max_duration' => Setting::get('ai_video_max_duration', 10),

                        // Usage limits
                        'daily_request_limit' => Setting::get('ai_daily_request_limit', 1000),
                        'per_user_daily_limit' => Setting::get('ai_per_user_daily_limit', 50),
                        'monthly_request_limit' => Setting::get('ai_monthly_request_limit', 30000),
                        'cost_tracking_enabled' => Setting::get('ai_cost_tracking_enabled', true),

                        // Additional features
                        'auto_translate_enabled' => Setting::get('ai_auto_translate_enabled', false),
                        'content_moderation_enabled' => Setting::get('ai_content_moderation_enabled', true),
                        'seo_optimization_enabled' => Setting::get('ai_seo_optimization_enabled', false),
                    ],
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $config,
                'message' => 'App configuration retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve app configuration',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get specific setting value (public only)
     *
     * @param string $key
     * @return JsonResponse
     */
    public function getSetting(string $key): JsonResponse
    {
        try {
            $setting = Setting::where('key', $key)
                ->where('is_public', true)
                ->first();

            if (!$setting) {
                return response()->json([
                    'success' => false,
                    'message' => 'Setting not found or not public'
                ], 404);
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'key' => $setting->key,
                    'value' => $this->castValue($setting->value, $setting->type),
                    'type' => $setting->type,
                ],
                'message' => 'Setting retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve setting',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Cast value based on type
     *
     * @param mixed $value
     * @param string $type
     * @return mixed
     */
    private function castValue($value, string $type)
    {
        return match($type) {
            'boolean' => filter_var($value, FILTER_VALIDATE_BOOLEAN),
            'integer' => (int) $value,
            'float', 'double' => (float) $value,
            'array', 'json' => json_decode($value, true),
            default => $value,
        };
    }

    /**
     * Get available setting groups
     *
     * @return JsonResponse
     */
    public function getGroups(): JsonResponse
    {
        try {
            $groups = Setting::distinct('group')
                ->where('is_public', true)
                ->pluck('group');

            return response()->json([
                'success' => true,
                'data' => $groups,
                'message' => 'Setting groups retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve groups',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Clear settings cache
     *
     * @return JsonResponse
     */
    public function clearCache(): JsonResponse
    {
        try {
            Cache::forget('public_settings');
            Cache::forget('app_config');
            Cache::forget('all_settings');

            // Clear group caches
            $groups = ['general', 'app', 'payment', 'sms', 'email', 'social', 'ai', 'external', 'seo', 'firebase', 'analytics', 'ai_content'];
            foreach ($groups as $group) {
                Cache::forget("public_settings_{$group}");
            }

            Setting::clearCache();

            return response()->json([
                'success' => true,
                'message' => 'Settings cache cleared successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to clear cache',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
