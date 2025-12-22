<?php
/**
 * Auto Deploy Script for Admin Pages
 *
 * Instructions:
 * 1. Upload this file to public_html/
 * 2. Visit: https://mediaprosocial.io/deploy-admin.php
 * 3. Delete this file after deployment for security!
 */

echo "<!DOCTYPE html>";
echo "<html dir='rtl' lang='ar'>";
echo "<head><meta charset='UTF-8'><title>نشر الصفحات الإدارية</title>";
echo "<style>body{font-family:Arial;padding:20px;direction:rtl;} .success{color:green;} .error{color:red;} .info{color:blue;}</style></head>";
echo "<body>";
echo "<h1>نشر الصفحات الإدارية - MediaPro Social</h1>";
echo "<hr>";

$baseDir = '/home/u126213189/domains/mediaprosocial.io/public_html';

// Check if running from correct location
if (!file_exists($baseDir . '/artisan')) {
    echo "<p class='error'>❌ خطأ: هذا السكريبت يجب أن يكون في المجلد الرئيسي للمشروع</p>";
    echo "</body></html>";
    exit;
}

echo "<h2>الخطوة 1: إنشاء المجلدات المطلوبة</h2>";

$directories = [
    $baseDir . '/app/Http/Controllers/Admin',
    $baseDir . '/resources/views/admin',
    $baseDir . '/resources/views/admin/layouts',
    $baseDir . '/resources/views/admin/users',
    $baseDir . '/resources/views/admin/requests',
];

foreach ($directories as $dir) {
    if (!file_exists($dir)) {
        if (mkdir($dir, 0755, true)) {
            echo "<p class='success'>✓ تم إنشاء: " . basename($dir) . "</p>";
        } else {
            echo "<p class='error'>✗ فشل إنشاء: " . basename($dir) . "</p>";
        }
    } else {
        echo "<p class='info'>→ موجود بالفعل: " . basename($dir) . "</p>";
    }
}

echo "<hr>";
echo "<h2>الخطوة 2: تحديث ملف Routes</h2>";

$webRoutesPath = $baseDir . '/routes/web.php';
$webRoutesBackup = $baseDir . '/routes/web.php.backup';

// Backup existing routes
if (file_exists($webRoutesPath)) {
    copy($webRoutesPath, $webRoutesBackup);
    echo "<p class='success'>✓ تم عمل نسخة احتياطية من web.php</p>";
}

echo "<p class='info'>→ يرجى تحديث ملف routes/web.php يدوياً بإضافة Admin Routes</p>";

echo "<hr>";
echo "<h2>الخطوة 3: مسح Cache</h2>";

$commands = [
    'route:clear' => 'مسح Routes Cache',
    'view:clear' => 'مسح Views Cache',
    'config:clear' => 'مسح Config Cache',
    'cache:clear' => 'مسح Application Cache',
];

foreach ($commands as $cmd => $label) {
    exec("cd $baseDir && php artisan $cmd 2>&1", $output, $returnVar);

    if ($returnVar === 0) {
        echo "<p class='success'>✓ $label</p>";
    } else {
        echo "<p class='error'>✗ فشل $label: " . implode(' ', $output) . "</p>";
    }

    $output = [];
}

echo "<hr>";
echo "<h2>الخطوة 4: التحقق من الملفات</h2>";

$requiredFiles = [
    'app/Http/Controllers/Admin/DashboardController.php',
    'app/Http/Controllers/Admin/UserController.php',
    'app/Http/Controllers/Admin/RequestController.php',
    'resources/views/admin/layouts/app.blade.php',
    'resources/views/admin/dashboard.blade.php',
];

echo "<p>الملفات المطلوبة:</p>";
echo "<ul>";
foreach ($requiredFiles as $file) {
    $fullPath = $baseDir . '/' . $file;
    if (file_exists($fullPath)) {
        echo "<li class='success'>✓ $file</li>";
    } else {
        echo "<li class='error'>✗ $file - <strong>غير موجود! يجب رفعه يدوياً</strong></li>";
    }
}
echo "</ul>";

echo "<hr>";
echo "<h2>✅ انتهى التنصيب!</h2>";
echo "<p class='info'><strong>الخطوات التالية:</strong></p>";
echo "<ol>";
echo "<li>ارفع ملفات Controllers إلى <code>app/Http/Controllers/Admin/</code></li>";
echo "<li>ارفع ملفات Views إلى <code>resources/views/admin/</code></li>";
echo "<li>حدّث ملف <code>routes/web.php</code></li>";
echo "<li>احذف هذا الملف (<code>deploy-admin.php</code>) لأسباب أمنية!</li>";
echo "<li>افتح: <a href='/admin'>https://mediaprosocial.io/admin</a></li>";
echo "</ol>";

echo "<hr>";
echo "<p style='background:#ffe6e6;padding:10px;border-radius:5px;'>";
echo "<strong>⚠️ تحذير أمني:</strong> احذف هذا الملف فوراً بعد الانتهاء!";
echo "</p>";

echo "</body></html>";
?>
