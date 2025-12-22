<?php
require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\DB;

header('Content-Type: application/json');

$user = User::where('email', 'admin@mediapro.com')->first();

if ($user) {
    $roles = DB::table('role_user')
        ->join('roles', 'roles.id', '=', 'role_user.role_id')
        ->where('role_user.user_id', $user->id)
        ->get();

    echo json_encode([
        'status' => 'found',
        'user' => [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'is_admin' => $user->is_admin,
            'is_active' => $user->is_active,
            'user_type' => $user->user_type,
        ],
        'roles' => $roles,
        'can_access_panel' => $user->canAccessPanel(new \Filament\Panel()),
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
} else {
    echo json_encode(['status' => 'not_found']);
}
