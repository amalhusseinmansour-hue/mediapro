<?php
/**
 * Run Migration Script
 *
 * Instructions:
 * 1. Upload this file to /public_html
 * 2. Visit: https://mediaprosocial.io/run-migration.php
 * 3. DELETE this file immediately after use!
 */

echo "<!DOCTYPE html>";
echo "<html dir='rtl' lang='ar'>";
echo "<head>";
echo "<meta charset='UTF-8'>";
echo "<meta name='viewport' content='width=device-width, initial-scale=1.0'>";
echo "<title>تنفيذ Migration - MediaPro Social</title>";
echo "<style>";
echo "body { font-family: Arial; padding: 40px; direction: rtl; background: #f5f5f5; }";
echo ".container { max-width: 900px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }";
echo "h1 { color: #2a5298; border-bottom: 3px solid #2a5298; padding-bottom: 10px; }";
echo ".success { color: green; background: #d4edda; padding: 15px; border-radius: 5px; margin: 20px 0; }";
echo ".error { color: red; background: #f8d7da; padding: 15px; border-radius: 5px; margin: 20px 0; }";
echo ".command { background: #f8f9fa; padding: 15px; border-right: 4px solid #2a5298; margin: 15px 0; font-family: monospace; }";
echo ".warning { background: #fff3cd; padding: 15px; border-radius: 5px; margin: 20px 0; color: #856404; }";
echo ".btn { display: inline-block; padding: 12px 30px; background: #2a5298; color: white; text-decoration: none; border-radius: 5px; margin: 10px 5px; }";
echo ".btn:hover { background: #1e3c72; }";
echo "pre { background: #f8f9fa; padding: 10px; border-radius: 5px; overflow-x: auto; }";
echo "</style>";
echo "</head>";
echo "<body>";

echo "<div class='container'>";
echo "<h1>🗃️ تنفيذ Migration - Connected Accounts</h1>";

$baseDir = '/home/u126213189/domains/mediaprosocial.io/public_html';

// Check if we're in the right place
if (!file_exists($baseDir . '/artisan')) {
    echo "<div class='error'>";
    echo "⚠️ خطأ: لم يتم العثور على مجلد Laravel الصحيح!<br>";
    echo "المسار المتوقع: $baseDir<br>";
    echo "تأكد من رفع هذا الملف في المجلد الصحيح.";
    echo "</div>";
    echo "</div></body></html>";
    exit;
}

echo "<p>جاري تنفيذ Migration لجدول الحسابات المتصلة...</p>";

echo "<div class='command'>";
echo "<strong>تنفيذ Migration</strong><br>";
echo "<code>php artisan migrate</code><br><br>";

exec("cd $baseDir && php artisan migrate --force 2>&1", $output, $returnVar);

if ($returnVar === 0) {
    echo "<span style='color:green'>✓ نجح</span>";
    echo "<div class='success'>";
    echo "<h2>✅ تم تنفيذ Migration بنجاح!</h2>";
    echo "<p>الآن يمكنك استخدام نظام ربط الحسابات في التطبيق.</p>";
    echo "</div>";
} else {
    echo "<span style='color:red'>✗ فشل</span>";
    echo "<div class='error'>";
    echo "<h2>❌ فشل تنفيذ Migration</h2>";
    echo "<p>تحقق من الرسائل أدناه للمزيد من التفاصيل.</p>";
    echo "</div>";
}

if (!empty($output)) {
    echo "<pre>" . htmlspecialchars(implode("\n", $output)) . "</pre>";
}

echo "</div>";

// Check migration status
echo "<div class='command'>";
echo "<strong>التحقق من حالة Migrations</strong><br>";
echo "<code>php artisan migrate:status</code><br><br>";

exec("cd $baseDir && php artisan migrate:status 2>&1", $statusOutput, $statusReturn);

if (!empty($statusOutput)) {
    echo "<pre>" . htmlspecialchars(implode("\n", $statusOutput)) . "</pre>";
}

echo "</div>";

echo "<div style='text-align:center; margin-top: 30px;'>";
echo "<a href='/api/connected-accounts/platforms' class='btn'>🧪 اختبار API</a>";
echo "<a href='/admin' class='btn'>📊 اذهب للوحة التحكم</a>";
echo "</div>";

echo "<div class='warning' style='margin-top: 30px;'>";
echo "<h3>⚠️ تحذير أمني مهم جداً!</h3>";
echo "<p><strong>يجب عليك حذف هذا الملف فوراً بعد الاستخدام!</strong></p>";
echo "<p>الملف الذي يجب حذفه: <code>public_html/run-migration.php</code></p>";
echo "<ol>";
echo "<li>افتح cPanel File Manager</li>";
echo "<li>انتقل إلى /public_html</li>";
echo "<li>ابحث عن run-migration.php</li>";
echo "<li>انقر بزر الفأرة الأيمن واختر Delete</li>";
echo "</ol>";
echo "</div>";

echo "</div>";

echo "</body></html>";
?>
