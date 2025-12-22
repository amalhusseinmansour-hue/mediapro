#!/bin/bash

echo "Connecting to server..."

ssh -p 65002 u126213189@82.25.83.217 << 'ENDSSH'
cd domains/mediaprosocial.io/public_html

echo "==========================================";
echo "  Creating fix script...";
echo "==========================================";

cat > fix_419_complete.php << 'ENDPHP'
<?php
echo "\n==========================================\n";
echo "  إصلاح خطأ 419 Page Expired\n";
echo "==========================================\n\n";

$envFile = __DIR__ . '/.env';
$envContent = file_get_contents($envFile);

// تعطيل SESSION_ENCRYPT
$original = $envContent;
$envContent = preg_replace('/SESSION_ENCRYPT=true/', 'SESSION_ENCRYPT=false', $envContent);

if ($envContent === $original && strpos($envContent, 'SESSION_ENCRYPT') === false) {
    $envContent .= "\nSESSION_ENCRYPT=false\n";
}

file_put_contents($envFile, $envContent);
echo "✅ SESSION_ENCRYPT = false\n";

// حذف ملفات الجلسات
$sessionsDir = __DIR__ . '/storage/framework/sessions';
$files = glob($sessionsDir . '/*');
$deleted = 0;
foreach ($files as $file) {
    if (is_file($file) && basename($file) !== '.gitignore') {
        unlink($file);
        $deleted++;
    }
}
echo "✅ حذف $deleted ملف جلسة\n";

// مسح الكاش
passthru('php artisan config:clear');
passthru('php artisan cache:clear');
passthru('php artisan view:clear');

echo "\n✅ تم الإصلاح بنجاح!\n\n";
echo "الآن جرب تسجيل الدخول:\n";
echo "https://mediaprosocial.io/admin/login\n";
echo "Email: admin@mediapro.com\n";
echo "Password: Admin@12345\n\n";
ENDPHP

echo "Running fix script...";
php fix_419_complete.php

echo "Cleaning up...";
rm fix_419_complete.php

echo "Done!";

ENDSSH
