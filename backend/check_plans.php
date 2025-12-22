<?php

use App\Models\SubscriptionPlan;

require __DIR__ . '/vendor/autoload.php';
$app = require __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$plans = SubscriptionPlan::all();

foreach ($plans as $plan) {
    echo "Plan ID: " . $plan->id . "\n";
    echo "Raw Features (from attribute): " . var_export($plan->getAttributes()['features'], true) . "\n";
    echo "Casted Features: " . var_export($plan->features, true) . "\n";
    echo "--------------------------------\n";
}
