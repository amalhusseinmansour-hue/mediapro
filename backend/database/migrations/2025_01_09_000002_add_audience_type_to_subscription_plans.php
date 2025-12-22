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
        Schema::table('subscription_plans', function (Blueprint $table) {
            // نوع الجمهور: individual (أفراد) أو business (أعمال)
            $table->enum('audience_type', ['individual', 'business'])
                  ->default('individual')
                  ->after('type');

            $table->index('audience_type');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('subscription_plans', function (Blueprint $table) {
            $table->dropColumn('audience_type');
        });
    }
};
