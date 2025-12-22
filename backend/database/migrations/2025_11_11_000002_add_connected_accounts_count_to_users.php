<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // تتبع عدد الحسابات المربوطة
            $table->integer('connected_accounts_count')->default(0)->after('email_verified_at');

            // فهرسة
            $table->index('connected_accounts_count');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex(['connected_accounts_count']);
            $table->dropColumn('connected_accounts_count');
        });
    }
};
