<?php
/**
 * Diagnostic File
 * Upload to: /public_html
 * Open: https://mediaprosocial.io/diagnose.php
 */

echo "<!DOCTYPE html><html><head><meta charset='UTF-8'><title>Diagnostic</title>";
echo "<style>body{font-family:Arial;padding:20px;background:#f5f5f5}";
echo ".success{color:green}.error{color:red}.warning{color:orange}";
echo "pre{background:white;padding:15px;border-radius:5px;overflow:auto}</style></head><body>";

echo "<h1>🔍 Diagnostic Report</h1>";

echo "<h2>1. Server Information</h2>";
echo "<pre>";
echo "PHP Version: " . phpversion() . "\n";
echo "Document Root: " . $_SERVER['DOCUMENT_ROOT'] . "\n";
echo "Script Path: " . __DIR__ . "\n";
echo "Current User: " . (function_exists('posix_getpwuid') ? posix_getpwuid(posix_geteuid())['name'] : 'unknown') . "\n";
echo "</pre>";

echo "<h2>2. Critical Files Check</h2>";
echo "<pre>";

$criticalFiles = [
    'vendor/autoload.php',
    'bootstrap/app.php',
    'artisan',
    '.env',
    'app/Providers/Filament/AdminPanelProvider.php',
    'app/Filament/Resources/WebsiteRequestResource.php',
    'app/Filament/Resources/SponsoredAdRequestResource.php',
];

$allExist = true;
foreach ($criticalFiles as $file) {
    $fullPath = __DIR__ . '/' . $file;
    $exists = file_exists($fullPath);

    if ($exists) {
        echo "<span class='success'>✅</span> " . $file . "\n";
    } else {
        echo "<span class='error'>❌</span> " . $file . " <strong>MISSING</strong>\n";
        $allExist = false;
    }
}

echo "</pre>";

if (!$allExist) {
    echo "<div style='background:#ffebee;padding:15px;border-radius:5px;margin:20px 0'>";
    echo "<strong style='color:red'>⚠️ PROBLEM FOUND:</strong> Some required files are missing!<br>";
    echo "This means the files haven't been uploaded to the server yet.";
    echo "</div>";
    echo "</body></html>";
    exit;
}

echo "<h2>3. Laravel Bootstrap</h2>";
echo "<pre>";

try {
    require __DIR__ . '/vendor/autoload.php';
    echo "<span class='success'>✅</span> Composer autoload loaded\n";

    $app = require_once __DIR__ . '/bootstrap/app.php';
    echo "<span class='success'>✅</span> Laravel app loaded\n";

    $kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
    $kernel->bootstrap();
    echo "<span class='success'>✅</span> Laravel bootstrapped\n";

} catch (Exception $e) {
    echo "<span class='error'>❌</span> Error: " . $e->getMessage() . "\n";
    echo "</pre>";
    echo "</body></html>";
    exit;
}

echo "</pre>";

echo "<h2>4. Database Connection</h2>";
echo "<pre>";

try {
    $dbName = DB::connection()->getDatabaseName();
    echo "<span class='success'>✅</span> Connected to database: " . $dbName . "\n";

    $tables = DB::select('SHOW TABLES');
    $tableNames = array_map(function($t) {
        return array_values((array)$t)[0];
    }, $tables);

    echo "<span class='success'>✅</span> Found " . count($tables) . " tables\n\n";

    // Check specific tables
    $requiredTables = ['users', 'website_requests', 'sponsored_ad_requests'];
    $missingTables = [];

    echo "Required Tables:\n";
    foreach ($requiredTables as $table) {
        if (in_array($table, $tableNames)) {
            echo "  <span class='success'>✅</span> " . $table . "\n";
        } else {
            echo "  <span class='error'>❌</span> " . $table . " <strong>MISSING</strong>\n";
            $missingTables[] = $table;
        }
    }

    if (!empty($missingTables)) {
        echo "\n<span class='error'>⚠️</span> Missing tables: " . implode(', ', $missingTables) . "\n";
        echo "<span class='warning'>→</span> You need to run migrations!\n";
    }

} catch (Exception $e) {
    echo "<span class='error'>❌</span> Database error: " . $e->getMessage() . "\n";
}

echo "</pre>";

echo "<h2>5. Filament Check</h2>";
echo "<pre>";

try {
    // Check if Filament panel is registered
    $panels = Filament\Facades\Filament::getPanels();
    echo "<span class='success'>✅</span> Filament is installed\n";
    echo "Panels registered: " . count($panels) . "\n\n";

    foreach ($panels as $id => $panel) {
        echo "Panel ID: " . $id . "\n";
        echo "  Path: " . $panel->getPath() . "\n";
    }

    // Check if resources exist
    echo "\nFilament Resources:\n";

    $resourceClasses = [
        'App\\Filament\\Resources\\WebsiteRequestResource',
        'App\\Filament\\Resources\\SponsoredAdRequestResource',
    ];

    foreach ($resourceClasses as $class) {
        if (class_exists($class)) {
            echo "  <span class='success'>✅</span> " . $class . "\n";
        } else {
            echo "  <span class='error'>❌</span> " . $class . " <strong>NOT FOUND</strong>\n";
        }
    }

} catch (Exception $e) {
    echo "<span class='error'>❌</span> Filament error: " . $e->getMessage() . "\n";
}

echo "</pre>";

echo "<h2>6. Routes Check</h2>";
echo "<pre>";

try {
    $routes = Route::getRoutes();
    $adminRoutes = [];

    foreach ($routes as $route) {
        $uri = $route->uri();
        if (strpos($uri, 'admin/') === 0) {
            $adminRoutes[] = $uri;
        }
    }

    echo "Found " . count($adminRoutes) . " admin routes\n\n";

    $importantRoutes = [
        'admin/website-requests',
        'admin/sponsored-ad-requests',
    ];

    echo "Looking for specific routes:\n";
    foreach ($importantRoutes as $route) {
        $found = in_array($route, $adminRoutes);
        if ($found) {
            echo "  <span class='success'>✅</span> " . $route . "\n";
        } else {
            echo "  <span class='error'>❌</span> " . $route . " <strong>NOT REGISTERED</strong>\n";
        }
    }

    if (count($adminRoutes) > 0) {
        echo "\nFirst 10 admin routes:\n";
        foreach (array_slice($adminRoutes, 0, 10) as $route) {
            echo "  → " . $route . "\n";
        }
    }

} catch (Exception $e) {
    echo "<span class='error'>❌</span> Routes error: " . $e->getMessage() . "\n";
}

echo "</pre>";

echo "<h2>7. Conclusion</h2>";
echo "<div style='background:#e3f2fd;padding:15px;border-radius:5px;margin:20px 0'>";

if (!empty($missingTables)) {
    echo "<strong style='color:#d32f2f'>🔴 PROBLEM: Missing Database Tables</strong><br><br>";
    echo "Missing tables: " . implode(', ', $missingTables) . "<br><br>";
    echo "<strong>SOLUTION:</strong> Upload run-migrations.php and run it<br>";
    echo "<a href='run-migrations.php' style='display:inline-block;margin-top:10px;padding:10px 20px;background:#4CAF50;color:white;text-decoration:none;border-radius:4px'>Run Migrations Now</a>";
} else {
    echo "<strong style='color:#388e3c'>🟢 Database OK</strong><br><br>";
    echo "All required tables exist. The 404 issue might be a cache problem.<br><br>";
    echo "<strong>SOLUTION:</strong> Clear cache<br>";
    echo "<a href='clear-cache.php' style='display:inline-block;margin-top:10px;padding:10px 20px;background:#2196F3;color:white;text-decoration:none;border-radius:4px'>Clear Cache</a>";
}

echo "</div>";

echo "<br><a href='https://mediaprosocial.io/admin' style='display:inline-block;padding:10px 20px;background:#9C27B0;color:white;text-decoration:none;border-radius:4px'>Go to Admin Panel</a>";

echo "</body></html>";
