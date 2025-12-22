<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "🚀 Installing AI Media & Twilio Settings...\n\n";

try {
    // AI Media Settings
    $aiSettings = [
        ['key' => 'image_generation_enabled', 'value' => '1', 'type' => 'boolean', 'group' => 'ai', 'description' => 'تفعيل توليد الصور بالذكاء الاصطناعي', 'is_public' => 1],
        ['key' => 'video_generation_enabled', 'value' => '1', 'type' => 'boolean', 'group' => 'ai', 'description' => 'تفعيل توليد الفيديو بالذكاء الاصطناعي', 'is_public' => 1],
        ['key' => 'image_provider', 'value' => 'replicate', 'type' => 'string', 'group' => 'ai', 'description' => 'مزود خدمة الصور', 'is_public' => 1],
        ['key' => 'video_provider', 'value' => 'runway', 'type' => 'string', 'group' => 'ai', 'description' => 'مزود خدمة الفيديو', 'is_public' => 1],
        ['key' => 'replicate_api_key', 'value' => '', 'type' => 'string', 'group' => 'ai', 'description' => 'Replicate API Key', 'is_public' => 0],
        ['key' => 'replicate_image_model', 'value' => 'stability-ai/sdxl:39ed52f2a78e934b3ba6e2a89f5b1c712de7dfea535525255b1aa35c5565e08b', 'type' => 'string', 'group' => 'ai', 'description' => 'Replicate Image Model', 'is_public' => 0],
        ['key' => 'replicate_video_model', 'value' => 'anotherjesse/zeroscope-v2-xl:9f747673945c62801b13b84701c783929c0ee784e4748ec062204894dda1a351', 'type' => 'string', 'group' => 'ai', 'description' => 'Replicate Video Model', 'is_public' => 0],
        ['key' => 'runway_api_key', 'value' => '', 'type' => 'string', 'group' => 'ai', 'description' => 'Runway ML API Key', 'is_public' => 0],
        ['key' => 'runway_base_url', 'value' => 'https://api.runwayml.com/v1', 'type' => 'string', 'group' => 'ai', 'description' => 'Runway API Base URL', 'is_public' => 0],
        ['key' => 'stability_api_key', 'value' => '', 'type' => 'string', 'group' => 'ai', 'description' => 'Stability AI API Key', 'is_public' => 0],
        ['key' => 'stability_engine', 'value' => 'stable-diffusion-xl-1024-v1-0', 'type' => 'string', 'group' => 'ai', 'description' => 'Stability Engine', 'is_public' => 0],
        ['key' => 'leonardo_api_key', 'value' => '', 'type' => 'string', 'group' => 'ai', 'description' => 'Leonardo AI API Key', 'is_public' => 0],
        ['key' => 'ai_image_width', 'value' => '1024', 'type' => 'integer', 'group' => 'ai', 'description' => 'عرض الصورة الافتراضي', 'is_public' => 1],
        ['key' => 'ai_image_height', 'value' => '1024', 'type' => 'integer', 'group' => 'ai', 'description' => 'ارتفاع الصورة الافتراضي', 'is_public' => 1],
        ['key' => 'ai_video_length', 'value' => '5', 'type' => 'integer', 'group' => 'ai', 'description' => 'طول الفيديو بالثواني', 'is_public' => 1],
        ['key' => 'ai_guidance_scale', 'value' => '7.5', 'type' => 'float', 'group' => 'ai', 'description' => 'مقياس التوجيه', 'is_public' => 1],
        ['key' => 'ai_steps', 'value' => '30', 'type' => 'integer', 'group' => 'ai', 'description' => 'عدد خطوات التوليد', 'is_public' => 1],
        ['key' => 'ai_image_cost_per_generation', 'value' => '0.05', 'type' => 'float', 'group' => 'ai', 'description' => 'تكلفة توليد الصورة', 'is_public' => 1],
        ['key' => 'ai_video_cost_per_second', 'value' => '0.10', 'type' => 'float', 'group' => 'ai', 'description' => 'تكلفة توليد الفيديو لكل ثانية', 'is_public' => 1],
    ];

    // Twilio OTP Settings
    $twilioSettings = [
        ['key' => 'twilio_enabled', 'value' => '1', 'type' => 'boolean', 'group' => 'otp', 'description' => 'تفعيل Twilio', 'is_public' => 1],
        ['key' => 'twilio_account_sid', 'value' => '', 'type' => 'string', 'group' => 'otp', 'description' => 'Twilio Account SID', 'is_public' => 0],
        ['key' => 'twilio_auth_token', 'value' => '', 'type' => 'string', 'group' => 'otp', 'description' => 'Twilio Auth Token', 'is_public' => 0],
        ['key' => 'twilio_phone_number', 'value' => '', 'type' => 'string', 'group' => 'otp', 'description' => 'Twilio Phone Number', 'is_public' => 0],
        ['key' => 'otp_message_template', 'value' => 'رمز التحقق الخاص بك هو: {code}', 'type' => 'string', 'group' => 'otp', 'description' => 'قالب رسالة OTP', 'is_public' => 1],
        ['key' => 'otp_code_length', 'value' => '6', 'type' => 'integer', 'group' => 'otp', 'description' => 'طول رمز OTP', 'is_public' => 1],
        ['key' => 'otp_expiry_minutes', 'value' => '10', 'type' => 'integer', 'group' => 'otp', 'description' => 'مدة صلاحية OTP', 'is_public' => 1],
        ['key' => 'test_otp_enabled', 'value' => '1', 'type' => 'boolean', 'group' => 'otp', 'description' => 'وضع الاختبار للOTP', 'is_public' => 1],
        ['key' => 'test_otp_code', 'value' => '123456', 'type' => 'string', 'group' => 'otp', 'description' => 'رمز OTP للاختبار', 'is_public' => 1],
    ];

    $allSettings = array_merge($aiSettings, $twilioSettings);
    $inserted = 0;
    $skipped = 0;

    foreach ($allSettings as $setting) {
        $exists = DB::table('settings')->where('key', $setting['key'])->exists();

        if (!$exists) {
            $setting['created_at'] = now();
            $setting['updated_at'] = now();
            DB::table('settings')->insert($setting);
            echo "✅ Inserted: {$setting['key']}\n";
            $inserted++;
        } else {
            echo "⏭️  Skipped (exists): {$setting['key']}\n";
            $skipped++;
        }
    }

    echo "\n📊 Summary:\n";
    echo "   ✅ Inserted: $inserted settings\n";
    echo "   ⏭️  Skipped: $skipped settings\n";
    echo "\n🎉 Installation completed successfully!\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
