<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\SubscriptionPlan;

class SubscriptionPlansApiTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test subscription plans endpoint returns success
     */
    public function test_subscription_plans_returns_success(): void
    {
        // Create test plans
        SubscriptionPlan::factory()->create([
            'name' => 'باقة الأفراد',
            'slug' => 'individual',
            'is_active' => true,
        ]);

        $response = $this->getJson('/api/subscription-plans');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ])
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => [
                        'id',
                        'name',
                        'slug',
                        'description',
                        'type',
                        'price',
                        'currency',
                        'max_accounts',
                        'max_posts',
                        'ai_features',
                        'analytics',
                        'scheduling',
                        'is_popular',
                        'is_active',
                    ],
                ],
            ]);
    }

    /**
     * Test only active plans are returned
     */
    public function test_only_active_plans_are_returned(): void
    {
        // Create active and inactive plans
        SubscriptionPlan::factory()->create([
            'name' => 'Active Plan',
            'is_active' => true,
        ]);

        SubscriptionPlan::factory()->create([
            'name' => 'Inactive Plan',
            'is_active' => false,
        ]);

        $response = $this->getJson('/api/subscription-plans');

        $response->assertStatus(200);
        $data = $response->json('data');

        $this->assertCount(1, $data);
        $this->assertEquals('Active Plan', $data[0]['name']);
    }

    /**
     * Test plans are ordered by sort_order
     */
    public function test_plans_are_ordered_correctly(): void
    {
        SubscriptionPlan::factory()->create([
            'name' => 'Plan 2',
            'sort_order' => 2,
            'is_active' => true,
        ]);

        SubscriptionPlan::factory()->create([
            'name' => 'Plan 1',
            'sort_order' => 1,
            'is_active' => true,
        ]);

        $response = $this->getJson('/api/subscription-plans');

        $data = $response->json('data');
        $this->assertEquals('Plan 1', $data[0]['name']);
        $this->assertEquals('Plan 2', $data[1]['name']);
    }

    /**
     * Test individual plans endpoint
     */
    public function test_individual_plans_endpoint(): void
    {
        SubscriptionPlan::factory()->create([
            'name' => 'Individual Plan',
            'audience_type' => 'individual',
            'is_active' => true,
        ]);

        SubscriptionPlan::factory()->create([
            'name' => 'Business Plan',
            'audience_type' => 'business',
            'is_active' => true,
        ]);

        $response = $this->getJson('/api/subscription-plans/individual');

        $response->assertStatus(200);
        $data = $response->json('data');

        $this->assertCount(1, $data);
        $this->assertEquals('Individual Plan', $data[0]['name']);
    }

    /**
     * Test business plans endpoint
     */
    public function test_business_plans_endpoint(): void
    {
        SubscriptionPlan::factory()->create([
            'name' => 'Individual Plan',
            'audience_type' => 'individual',
            'is_active' => true,
        ]);

        SubscriptionPlan::factory()->create([
            'name' => 'Business Plan',
            'audience_type' => 'business',
            'is_active' => true,
        ]);

        $response = $this->getJson('/api/subscription-plans/business');

        $response->assertStatus(200);
        $data = $response->json('data');

        $this->assertCount(1, $data);
        $this->assertEquals('Business Plan', $data[0]['name']);
    }

    /**
     * Test monthly plans endpoint
     */
    public function test_monthly_plans_endpoint(): void
    {
        SubscriptionPlan::factory()->create([
            'name' => 'Monthly Plan',
            'type' => 'monthly',
            'is_active' => true,
        ]);

        SubscriptionPlan::factory()->create([
            'name' => 'Yearly Plan',
            'type' => 'yearly',
            'is_active' => true,
        ]);

        $response = $this->getJson('/api/subscription-plans/monthly');

        $response->assertStatus(200);
        $data = $response->json('data');

        $this->assertCount(1, $data);
        $this->assertEquals('Monthly Plan', $data[0]['name']);
    }

    /**
     * Test yearly plans endpoint
     */
    public function test_yearly_plans_endpoint(): void
    {
        SubscriptionPlan::factory()->create([
            'name' => 'Monthly Plan',
            'type' => 'monthly',
            'is_active' => true,
        ]);

        SubscriptionPlan::factory()->create([
            'name' => 'Yearly Plan',
            'type' => 'yearly',
            'is_active' => true,
        ]);

        $response = $this->getJson('/api/subscription-plans/yearly');

        $response->assertStatus(200);
        $data = $response->json('data');

        $this->assertCount(1, $data);
        $this->assertEquals('Yearly Plan', $data[0]['name']);
    }

    /**
     * Test popular plans endpoint
     */
    public function test_popular_plans_endpoint(): void
    {
        SubscriptionPlan::factory()->create([
            'name' => 'Popular Plan',
            'is_popular' => true,
            'is_active' => true,
        ]);

        SubscriptionPlan::factory()->create([
            'name' => 'Regular Plan',
            'is_popular' => false,
            'is_active' => true,
        ]);

        $response = $this->getJson('/api/subscription-plans/popular');

        $response->assertStatus(200);
        $data = $response->json('data');

        $this->assertCount(1, $data);
        $this->assertEquals('Popular Plan', $data[0]['name']);
    }

    /**
     * Test specific plan by slug
     */
    public function test_get_plan_by_slug(): void
    {
        SubscriptionPlan::factory()->create([
            'name' => 'Individual Plan',
            'slug' => 'individual',
            'is_active' => true,
        ]);

        $response = $this->getJson('/api/subscription-plans/individual');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'slug' => 'individual',
                ],
            ]);
    }

    /**
     * Test non-existent plan returns 404
     */
    public function test_non_existent_plan_returns_404(): void
    {
        $response = $this->getJson('/api/subscription-plans/non-existent');

        $response->assertStatus(404);
    }

    /**
     * Test rate limiting on subscription plans endpoint
     */
    public function test_subscription_plans_has_rate_limiting(): void
    {
        SubscriptionPlan::factory()->create(['is_active' => true]);

        // Make 61 requests (limit is 60 per minute)
        for ($i = 0; $i < 61; $i++) {
            $response = $this->getJson('/api/subscription-plans');
            
            if ($i < 60) {
                $response->assertStatus(200);
            } else {
                $response->assertStatus(429);
            }
        }
    }
}
