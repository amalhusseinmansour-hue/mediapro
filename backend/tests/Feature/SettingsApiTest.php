<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Setting;

class SettingsApiTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test app config endpoint returns success
     */
    public function test_app_config_returns_success(): void
    {
        $response = $this->getJson('/api/settings/app-config');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ])
            ->assertJsonStructure([
                'success',
                'data' => [
                    'app',
                    'support',
                    'localization',
                    'links',
                    'features',
                    'payment',
                    'analytics',
                    'ai_content',
                ],
                'message',
            ]);
    }

    /**
     * Test app config contains required app settings
     */
    public function test_app_config_contains_app_settings(): void
    {
        $response = $this->getJson('/api/settings/app-config');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    'app' => [
                        'name',
                        'name_en',
                        'version',
                        'logo',
                        'force_update',
                        'min_supported_version',
                        'maintenance_mode',
                        'maintenance_message',
                    ],
                ],
            ]);
    }

    /**
     * Test app config contains payment settings
     */
    public function test_app_config_contains_payment_settings(): void
    {
        $response = $this->getJson('/api/settings/app-config');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    'payment' => [
                        'stripe_enabled',
                        'paymob_enabled',
                        'paypal_enabled',
                        'google_pay_enabled',
                        'apple_pay_enabled',
                        'minimum_amount',
                        'currency',
                    ],
                ],
            ]);
    }

    /**
     * Test app config does not expose secret keys
     */
    public function test_app_config_does_not_expose_secrets(): void
    {
        $response = $this->getJson('/api/settings/app-config');

        $data = $response->json('data');
        $jsonString = json_encode($data);

        // تأكد أن المفاتيح السرية غير موجودة
        $this->assertStringNotContainsString('stripe_secret', $jsonString);
        $this->assertStringNotContainsString('paymob_api_key', $jsonString);
        $this->assertStringNotContainsString('paypal_secret', $jsonString);
    }

    /**
     * Test public settings endpoint
     */
    public function test_public_settings_returns_success(): void
    {
        // Create some public settings
        Setting::create([
            'key' => 'app_name',
            'value' => 'Test App',
            'type' => 'string',
            'group' => 'app',
            'is_public' => true,
        ]);

        $response = $this->getJson('/api/settings');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ]);
    }

    /**
     * Test settings by group endpoint
     */
    public function test_settings_by_group_returns_correct_data(): void
    {
        // Create settings in different groups
        Setting::create([
            'key' => 'app_name',
            'value' => 'Test App',
            'type' => 'string',
            'group' => 'app',
            'is_public' => true,
        ]);

        Setting::create([
            'key' => 'stripe_enabled',
            'value' => 'true',
            'type' => 'boolean',
            'group' => 'payment',
            'is_public' => true,
        ]);

        $response = $this->getJson('/api/settings/group/app');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'group' => 'app',
            ]);
    }

    /**
     * Test specific setting endpoint
     */
    public function test_specific_setting_returns_correct_value(): void
    {
        Setting::create([
            'key' => 'app_name',
            'value' => 'Test App',
            'type' => 'string',
            'group' => 'app',
            'is_public' => true,
        ]);

        $response = $this->getJson('/api/settings/app_name');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'key' => 'app_name',
                    'value' => 'Test App',
                ],
            ]);
    }

    /**
     * Test non-public setting is not accessible
     */
    public function test_non_public_setting_is_not_accessible(): void
    {
        Setting::create([
            'key' => 'secret_key',
            'value' => 'secret_value',
            'type' => 'string',
            'group' => 'app',
            'is_public' => false,
        ]);

        $response = $this->getJson('/api/settings/secret_key');

        $response->assertStatus(404);
    }

    /**
     * Test rate limiting on settings endpoint
     */
    public function test_settings_endpoint_has_rate_limiting(): void
    {
        // Make 61 requests (limit is 60 per minute)
        for ($i = 0; $i < 61; $i++) {
            $response = $this->getJson('/api/settings/app-config');
            
            if ($i < 60) {
                $response->assertStatus(200);
            } else {
                // 61st request should be rate limited
                $response->assertStatus(429);
            }
        }
    }
}
