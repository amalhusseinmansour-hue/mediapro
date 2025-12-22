<?php
/**
 * Admin User Creation Script - Web Version
 * Upload this file to your server and access it via browser
 * After creating admin, DELETE this file for security!
 */

// Security: Only allow access once
$lockFile = __DIR__ . '/.admin_created.lock';
if (file_exists($lockFile)) {
    die('❌ Admin already created. This script has been locked. Delete .admin_created.lock to run again.');
}

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make('Illuminate\Contracts\Http\Kernel');
$response = $kernel->handle(
    $request = \Illuminate\Http\Request::capture()
);

use App\Models\User;

?>
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>إنشاء مستخدم Admin</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0;
            padding: 20px;
        }
        .container {
            background: white;
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            max-width: 600px;
            width: 100%;
        }
        h1 {
            color: #667eea;
            margin-bottom: 30px;
            text-align: center;
        }
        .success {
            background: #d4edda;
            border: 1px solid #c3e6cb;
            color: #155724;
            padding: 20px;
            border-radius: 8px;
            margin: 20px 0;
        }
        .error {
            background: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
            padding: 20px;
            border-radius: 8px;
            margin: 20px 0;
        }
        .info {
            background: #d1ecf1;
            border: 1px solid #bee5eb;
            color: #0c5460;
            padding: 20px;
            border-radius: 8px;
            margin: 20px 0;
        }
        .credentials {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin: 20px 0;
            font-family: 'Courier New', monospace;
        }
        .credentials div {
            margin: 10px 0;
            padding: 10px;
            background: white;
            border-radius: 5px;
        }
        .btn {
            background: #667eea;
            color: white;
            padding: 15px 30px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            width: 100%;
            margin-top: 20px;
        }
        .btn:hover {
            background: #5568d3;
        }
        .warning {
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            color: #856404;
            padding: 15px;
            border-radius: 8px;
            margin: 20px 0;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔧 إنشاء مستخدم Admin</h1>

<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        // Create or update admin user
        $user = User::updateOrCreate(
            ['email' => 'admin@mediapro.com'],
            [
                'name' => 'Admin Manager',
                'email' => 'admin@mediapro.com',
                'password' => bcrypt('Admin@12345'),
                'is_admin' => true,
                'is_active' => true,
            ]
        );

        // Create lock file
        file_put_contents($lockFile, date('Y-m-d H:i:s'));

        echo '<div class="success">';
        echo '<h2>✅ تم إنشاء Admin بنجاح!</h2>';
        echo '<p>تم إنشاء حساب المدير بنجاح. يمكنك الآن تسجيل الدخول.</p>';
        echo '</div>';

        echo '<div class="credentials">';
        echo '<h3>🔐 بيانات تسجيل الدخول:</h3>';
        echo '<div><strong>📧 البريد الإلكتروني:</strong> admin@mediapro.com</div>';
        echo '<div><strong>🔑 كلمة المرور:</strong> Admin@12345</div>';
        echo '<div><strong>🌐 رابط الدخول:</strong> <a href="https://mediaprosocial.io/admin/login">https://mediaprosocial.io/admin/login</a></div>';
        echo '<div><strong>🆔 معرف المستخدم:</strong> ' . $user->id . '</div>';
        echo '</div>';

        echo '<div class="warning">';
        echo '⚠️ <strong>مهم جداً:</strong> احذف هذا الملف الآن من السيرفر لأسباب أمنية!<br>';
        echo 'اسم الملف: <code>create_admin_web.php</code>';
        echo '</div>';

        echo '<div class="info">';
        echo '<p><strong>الخطوات التالية:</strong></p>';
        echo '<ol style="text-align: right;">';
        echo '<li>احذف هذا الملف من السيرفر</li>';
        echo '<li>اذهب إلى: <a href="https://mediaprosocial.io/admin/login">https://mediaprosocial.io/admin/login</a></li>';
        echo '<li>سجل دخول باستخدام البيانات أعلاه</li>';
        echo '<li>غيّر كلمة المرور من لوحة التحكم</li>';
        echo '</ol>';
        echo '</div>';

    } catch (\Exception $e) {
        echo '<div class="error">';
        echo '<h2>❌ حدث خطأ!</h2>';
        echo '<p>' . htmlspecialchars($e->getMessage()) . '</p>';
        echo '</div>';
    }
} else {
    ?>
        <div class="info">
            <p>هذا السكريبت سيقوم بإنشاء حساب Admin لتسجيل الدخول إلى لوحة التحكم.</p>
            <p><strong>ملاحظة:</strong> بعد إنشاء الحساب، احذف هذا الملف فوراً!</p>
        </div>

        <form method="POST">
            <button type="submit" class="btn">إنشاء Admin الآن</button>
        </form>

        <div class="credentials">
            <h3>📋 البيانات التي سيتم إنشاؤها:</h3>
            <div><strong>📧 البريد الإلكتروني:</strong> admin@mediapro.com</div>
            <div><strong>🔑 كلمة المرور:</strong> Admin@12345</div>
            <div><strong>👤 نوع الحساب:</strong> Admin (مدير)</div>
        </div>
    <?php
}
?>
    </div>
</body>
</html>
