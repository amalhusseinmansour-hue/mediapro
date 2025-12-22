@echo off
echo ==========================================
echo   اتصال بالسيرفر وتنفيذ الاصلاح
echo ==========================================
echo.
echo تحذير: هذا السكربت مخصص للاستخدام في بيئة التطوير فقط.
echo لا تقم بحفظ كلمات المرور او البيانات الحساسة في هذا الملف.
echo.

REM --= ادخل بيانات الخادم هنا بشكل مؤقت عند التشغيل فقط =--
set SERVER_IP=82.25.83.217
set SERVER_PORT=65002
set SERVER_USER=u126213189
REM !!! لا تقم بحفظ كلمة المرور هنا !!!

echo.
echo ==========================================
echo.

REM Connect and upload the fix script
echo جاري الاتصال بالسيرفر...
echo.

ssh -p %SERVER_PORT% %SERVER_USER%@%SERVER_IP% "cd domains/mediaprosocial.io/public_html && cat > fix_419_now.php << 'ENDOFSCRIPT'
<?php
echo '\n==========================================\n';
echo '  إصلاح خطأ 419 Page Expired\n';
echo '==========================================\n\n';

// 1. تعديل ملف .env
\$envFile = __DIR__ . '/.env';
\$envContent = file_get_contents(\$envFile);

// تعطيل SESSION_ENCRYPT
\$envContent = preg_replace('/SESSION_ENCRYPT=true/', 'SESSION_ENCRYPT=false', \$envContent);
\$envContent = preg_replace('/SESSION_ENCRYPT=false/', 'SESSION_ENCRYPT=false', \$envContent);

// إذا لم يكن موجود، أضفه
if (strpos(\$envContent, 'SESSION_ENCRYPT') === false) {
    \$envContent .= '\nSESSION_ENCRYPT=false\n';
}

file_put_contents(\$envFile, \$envContent);
echo '✅ تم تعديل SESSION_ENCRYPT إلى false\n';

// 2. حذف جميع ملفات الجلسات
\$sessionsDir = __DIR__ . '/storage/framework/sessions';
\$files = glob(\$sessionsDir . '/*');
\$deleted = 0;
foreach (\$files as \$file) {
    if (is_file(\$file) && basename(\$file) !== '.gitignore') {
        unlink(\$file);
        \$deleted++;
    }
}
echo '✅ تم حذف ' . \$deleted . ' ملف جلسة\n';

// 3. مسح الكاش
exec('php artisan config:clear 2>&1', \$output1);
echo '✅ تم مسح config cache\n';

exec('php artisan cache:clear 2>&1', \$output2);
echo '✅ تم مسح application cache\n';

exec('php artisan view:clear 2>&1', \$output3);
echo '✅ تم مسح views cache\n';

echo '\n==========================================\n';
echo '  ✅ تم الإصلاح بنجاح!\n';
echo '==========================================\n';
echo '\nالآن:\n';
echo '1. امسح كوكيز المتصفح\n';
echo '2. اذهب إلى: https://mediaprosocial.io/admin/login\n';
echo '3. سجل دخول بـ:\n';
echo '   Email: admin@mediapro.com\n';
echo '   Password: Admin@12345\n\n';
ENDOFSCRIPT
php fix_419_now.php && rm fix_419_now.php"

echo.
echo ==========================================
echo   تم التنفيذ!
echo ==========================================
echo.
echo الآن جرب تسجيل الدخول على:
echo https://mediaprosocial.io/admin/login
echo.
pause
