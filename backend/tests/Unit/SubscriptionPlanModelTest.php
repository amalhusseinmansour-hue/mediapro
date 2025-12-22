<?php

namespace Tests\Unit;

use Tests\TestCase;
use App\Models\SubscriptionPlan;
use Illuminate\Foundation\Testing\RefreshDatabase;

class SubscriptionPlanModelTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test subscription plan can be created
     */
    public function test_subscription_plan_can_be_created(): void
    {
        $plan = SubscriptionPlan::create([
            'name' => 'Test Plan',
            'slug' => 'test-plan',
            'description' => 'Test Description',
            'type' => 'monthly',
            'price' => 99.99,
            'currency' => 'AED',
            'max_accounts' => 5,
            'max_posts' => 100,
            'ai_features' => true,
            'analytics' => true,
            'scheduling' => true,
            'is_popular' => false,
            'is_active' => true,
            'sort_order' => 1,
        ]);

        $this->assertDatabaseHas('subscription_plans', [
            'name' => 'Test Plan',
            'slug' => 'test-plan',
        ]);
    }

    /**
     * Test active scope returns only active plans
     */
    public function test_active_scope_returns_only_active_plans(): void
    {
        SubscriptionPlan::factory()->create(['is_active' => true]);
        SubscriptionPlan::factory()->create(['is_active' => false]);

        $activePlans = SubscriptionPlan::active()->get();

        $this->assertCount(1, $activePlans);
        $this->assertTrue($activePlans->first()->is_active);
    }

    /**
     * Test monthly scope returns only monthly plans
     */
    public function test_monthly_scope_returns_only_monthly_plans(): void
    {
        SubscriptionPlan::factory()->create(['type' => 'monthly']);
        SubscriptionPlan::factory()->create(['type' => 'yearly']);

        $monthlyPlans = SubscriptionPlan::monthly()->get();

        $this->assertCount(1, $monthlyPlans);
        $this->assertEquals('monthly', $monthlyPlans->first()->type);
    }

    /**
     * Test yearly scope returns only yearly plans
     */
    public function test_yearly_scope_returns_only_yearly_plans(): void
    {
        SubscriptionPlan::factory()->create(['type' => 'monthly']);
        SubscriptionPlan::factory()->create(['type' => 'yearly']);

        $yearlyPlans = SubscriptionPlan::yearly()->get();

        $this->assertCount(1, $yearlyPlans);
        $this->assertEquals('yearly', $yearlyPlans->first()->type);
    }

    /**
     * Test popular scope returns only popular plans
     */
    public function test_popular_scope_returns_only_popular_plans(): void
    {
        SubscriptionPlan::factory()->create(['is_popular' => true]);
        SubscriptionPlan::factory()->create(['is_popular' => false]);

        $popularPlans = SubscriptionPlan::popular()->get();

        $this->assertCount(1, $popularPlans);
        $this->assertTrue($popularPlans->first()->is_popular);
    }

    /**
     * Test ordered scope returns plans in correct order
     */
    public function test_ordered_scope_returns_plans_in_correct_order(): void
    {
        SubscriptionPlan::factory()->create(['sort_order' => 3]);
        SubscriptionPlan::factory()->create(['sort_order' => 1]);
        SubscriptionPlan::factory()->create(['sort_order' => 2]);

        $orderedPlans = SubscriptionPlan::ordered()->get();

        $this->assertEquals(1, $orderedPlans[0]->sort_order);
        $this->assertEquals(2, $orderedPlans[1]->sort_order);
        $this->assertEquals(3, $orderedPlans[2]->sort_order);
    }

    /**
     * Test individual scope returns only individual plans
     */
    public function test_individual_scope_returns_only_individual_plans(): void
    {
        SubscriptionPlan::factory()->create(['audience_type' => 'individual']);
        SubscriptionPlan::factory()->create(['audience_type' => 'business']);

        $individualPlans = SubscriptionPlan::individual()->get();

        $this->assertCount(1, $individualPlans);
        $this->assertEquals('individual', $individualPlans->first()->audience_type);
    }

    /**
     * Test business scope returns only business plans
     */
    public function test_business_scope_returns_only_business_plans(): void
    {
        SubscriptionPlan::factory()->create(['audience_type' => 'individual']);
        SubscriptionPlan::factory()->create(['audience_type' => 'business']);

        $businessPlans = SubscriptionPlan::business()->get();

        $this->assertCount(1, $businessPlans);
        $this->assertEquals('business', $businessPlans->first()->audience_type);
    }

    /**
     * Test features are cast to array
     */
    public function test_features_are_cast_to_array(): void
    {
        $plan = SubscriptionPlan::factory()->create([
            'features' => ['Feature 1', 'Feature 2', 'Feature 3'],
        ]);

        $this->assertIsArray($plan->features);
        $this->assertCount(3, $plan->features);
    }

    /**
     * Test boolean fields are cast correctly
     */
    public function test_boolean_fields_are_cast_correctly(): void
    {
        $plan = SubscriptionPlan::factory()->create([
            'ai_features' => true,
            'analytics' => false,
            'scheduling' => true,
            'is_popular' => false,
            'is_active' => true,
        ]);

        $this->assertTrue($plan->ai_features);
        $this->assertFalse($plan->analytics);
        $this->assertTrue($plan->scheduling);
        $this->assertFalse($plan->is_popular);
        $this->assertTrue($plan->is_active);
    }

    /**
     * Test price is cast to decimal
     */
    public function test_price_is_cast_to_decimal(): void
    {
        $plan = SubscriptionPlan::factory()->create([
            'price' => 99.99,
        ]);

        $this->assertEquals('99.99', $plan->price);
    }

    /**
     * Test combining multiple scopes
     */
    public function test_combining_multiple_scopes(): void
    {
        SubscriptionPlan::factory()->create([
            'type' => 'monthly',
            'is_active' => true,
            'is_popular' => true,
            'sort_order' => 1,
        ]);

        SubscriptionPlan::factory()->create([
            'type' => 'yearly',
            'is_active' => true,
            'is_popular' => false,
            'sort_order' => 2,
        ]);

        SubscriptionPlan::factory()->create([
            'type' => 'monthly',
            'is_active' => false,
            'is_popular' => true,
            'sort_order' => 3,
        ]);

        $plans = SubscriptionPlan::active()
            ->monthly()
            ->popular()
            ->ordered()
            ->get();

        $this->assertCount(1, $plans);
        $this->assertEquals('monthly', $plans->first()->type);
        $this->assertTrue($plans->first()->is_active);
        $this->assertTrue($plans->first()->is_popular);
    }
}
