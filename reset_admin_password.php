&lt;?php
require __DIR__."/vendor/autoload.php";

$app = require_once __DIR__."/bootstrap/app.php";
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\Hash;

// Update admin password
$email = "admin@mediapro.com";
$newPassword = "Admin@2025!";

$user = \App\Models\User::where("email", $email)->first();

if ($user) {
    $user->password = Hash::make($newPassword);
    $user->save();
    echo "✅ Password updated successfully for: " . $email . "\n";
    echo "New password: " . $newPassword . "\n";
} else {
    echo "❌ User not found: " . $email . "\n";
}
?>
