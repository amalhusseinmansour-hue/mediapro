<?php
// Simple server info - NO Laravel required
// Upload to /public_html and open: https://mediaprosocial.io/info.php

echo "<!DOCTYPE html><html><head><meta charset='UTF-8'>";
echo "<style>body{font-family:Arial;padding:20px;background:#f5f5f5}</style></head><body>";
echo "<h1>🔍 Server Location Finder</h1>";

echo "<h2>Current Location:</h2>";
echo "<pre>";
echo "Script location: " . __FILE__ . "\n";
echo "Directory: " . __DIR__ . "\n";
echo "Document root: " . $_SERVER['DOCUMENT_ROOT'] . "\n";
echo "</pre>";

echo "<h2>Directory Contents:</h2>";
echo "<pre>";

if (is_dir(__DIR__)) {
    $files = scandir(__DIR__);

    echo "Found " . count($files) . " items:\n\n";

    foreach ($files as $item) {
        if ($item === '.' || $item === '..') continue;

        $fullPath = __DIR__ . '/' . $item;
        if (is_dir($fullPath)) {
            echo "📁 " . $item . "/\n";
        } else {
            echo "📄 " . $item . "\n";
        }
    }
}

echo "</pre>";

echo "<h2>Looking for Laravel:</h2>";
echo "<pre>";

// Check common Laravel locations
$possibleLocations = [
    __DIR__ . '/vendor',
    __DIR__ . '/artisan',
    __DIR__ . '/bootstrap/app.php',
    __DIR__ . '/../vendor',
    __DIR__ . '/../artisan',
    __DIR__ . '/../bootstrap/app.php',
];

echo "Checking for Laravel files:\n\n";

foreach ($possibleLocations as $path) {
    if (file_exists($path)) {
        echo "✅ FOUND: " . $path . "\n";
    } else {
        echo "❌ Not found: " . $path . "\n";
    }
}

echo "</pre>";

echo "<h2>What to do next:</h2>";
echo "<div style='background:white;padding:15px;border-radius:5px'>";
echo "<ol>";
echo "<li>Take a screenshot of this page</li>";
echo "<li>Send it to me</li>";
echo "<li>I will tell you the exact path to upload files</li>";
echo "</ol>";
echo "</div>";

echo "</body></html>";
?>
