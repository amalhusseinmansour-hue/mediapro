<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Insert admin user directly into database
        DB::table('users')->updateOrInsert(
            ['email' => 'admin@mediapro.com'],
            [
                'name' => 'Admin User',
                'email' => 'admin@mediapro.com',
                'password' => Hash::make('Admin@2025'),
                'is_admin' => true,
                'is_active' => true,
                'user_type' => 'admin',
                'email_verified_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ]
        );
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::table('users')->where('email', 'admin@mediapro.com')->delete();
    }
};