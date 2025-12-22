<?php

namespace Database\Factories;

use App\Models\SubscriptionPlan;
use Illuminate\Database\Eloquent\Factories\Factory;

class SubscriptionPlanFactory extends Factory
{
    protected $model = SubscriptionPlan::class;

    public function definition(): array
    {
        return [
            'name' => $this->faker->words(2, true),
            'slug' => $this->faker->slug,
            'description' => $this->faker->sentence,
            'type' => $this->faker->randomElement(['monthly', 'yearly']),
            'audience_type' => $this->faker->randomElement(['individual', 'business']),
            'price' => $this->faker->randomFloat(2, 50, 500),
            'currency' => 'AED',
            'max_accounts' => $this->faker->numberBetween(3, 20),
            'max_posts' => $this->faker->numberBetween(50, 500),
            'ai_features' => $this->faker->boolean(80),
            'analytics' => $this->faker->boolean(80),
            'scheduling' => $this->faker->boolean(90),
            'is_popular' => $this->faker->boolean(20),
            'is_active' => $this->faker->boolean(90),
            'sort_order' => $this->faker->numberBetween(1, 10),
            'features' => [
                $this->faker->sentence,
                $this->faker->sentence,
                $this->faker->sentence,
            ],
        ];
    }

    /**
     * Indicate that the plan is active.
     */
    public function active(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_active' => true,
        ]);
    }

    /**
     * Indicate that the plan is inactive.
     */
    public function inactive(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_active' => false,
        ]);
    }

    /**
     * Indicate that the plan is popular.
     */
    public function popular(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_popular' => true,
        ]);
    }

    /**
     * Indicate that the plan is monthly.
     */
    public function monthly(): static
    {
        return $this->state(fn (array $attributes) => [
            'type' => 'monthly',
        ]);
    }

    /**
     * Indicate that the plan is yearly.
     */
    public function yearly(): static
    {
        return $this->state(fn (array $attributes) => [
            'type' => 'yearly',
        ]);
    }

    /**
     * Indicate that the plan is for individuals.
     */
    public function individual(): static
    {
        return $this->state(fn (array $attributes) => [
            'audience_type' => 'individual',
            'max_accounts' => $this->faker->numberBetween(3, 10),
            'max_posts' => $this->faker->numberBetween(50, 200),
        ]);
    }

    /**
     * Indicate that the plan is for businesses.
     */
    public function business(): static
    {
        return $this->state(fn (array $attributes) => [
            'audience_type' => 'business',
            'max_accounts' => $this->faker->numberBetween(10, 50),
            'max_posts' => $this->faker->numberBetween(200, 1000),
        ]);
    }
}
