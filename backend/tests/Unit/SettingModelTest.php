<?php

namespace Tests\Unit;

use Tests\TestCase;
use App\Models\Setting;
use Illuminate\Foundation\Testing\RefreshDatabase;

class SettingModelTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test setting can be created
     */
    public function test_setting_can_be_created(): void
    {
        $setting = Setting::create([
            'key' => 'test_key',
            'value' => 'test_value',
            'type' => 'string',
            'group' => 'test',
            'is_public' => true,
        ]);

        $this->assertDatabaseHas('settings', [
            'key' => 'test_key',
            'value' => 'test_value',
        ]);
    }

    /**
     * Test setting value can be retrieved
     */
    public function test_setting_value_can_be_retrieved(): void
    {
        Setting::create([
            'key' => 'app_name',
            'value' => 'Test App',
            'type' => 'string',
            'group' => 'app',
            'is_public' => true,
        ]);

        $value = Setting::get('app_name');

        $this->assertEquals('Test App', $value);
    }

    /**
     * Test setting returns default value when not found
     */
    public function test_setting_returns_default_when_not_found(): void
    {
        $value = Setting::get('non_existent_key', 'default_value');

        $this->assertEquals('default_value', $value);
    }

    /**
     * Test boolean setting is cast correctly
     */
    public function test_boolean_setting_is_cast_correctly(): void
    {
        Setting::create([
            'key' => 'feature_enabled',
            'value' => 'true',
            'type' => 'boolean',
            'group' => 'features',
            'is_public' => true,
        ]);

        $value = Setting::get('feature_enabled');

        $this->assertTrue($value);
    }

    /**
     * Test integer setting is cast correctly
     */
    public function test_integer_setting_is_cast_correctly(): void
    {
        Setting::create([
            'key' => 'max_items',
            'value' => '100',
            'type' => 'integer',
            'group' => 'limits',
            'is_public' => true,
        ]);

        $value = Setting::get('max_items');

        $this->assertIsInt($value);
        $this->assertEquals(100, $value);
    }

    /**
     * Test array setting is cast correctly
     */
    public function test_array_setting_is_cast_correctly(): void
    {
        Setting::create([
            'key' => 'languages',
            'value' => json_encode(['ar', 'en']),
            'type' => 'array',
            'group' => 'localization',
            'is_public' => true,
        ]);

        $value = Setting::get('languages');

        $this->assertIsArray($value);
        $this->assertEquals(['ar', 'en'], $value);
    }

    /**
     * Test setting can be updated
     */
    public function test_setting_can_be_updated(): void
    {
        $setting = Setting::create([
            'key' => 'app_name',
            'value' => 'Old Name',
            'type' => 'string',
            'group' => 'app',
            'is_public' => true,
        ]);

        Setting::set('app_name', 'New Name');

        $this->assertDatabaseHas('settings', [
            'key' => 'app_name',
            'value' => 'New Name',
        ]);
    }

    /**
     * Test cache is cleared when setting is updated
     */
    public function test_cache_is_cleared_when_setting_updated(): void
    {
        Setting::create([
            'key' => 'app_name',
            'value' => 'Old Name',
            'type' => 'string',
            'group' => 'app',
            'is_public' => true,
        ]);

        // Get value (will be cached)
        $value1 = Setting::get('app_name');

        // Update setting
        Setting::set('app_name', 'New Name');

        // Get value again (should be new value, not cached)
        $value2 = Setting::get('app_name');

        $this->assertEquals('Old Name', $value1);
        $this->assertEquals('New Name', $value2);
    }
}
