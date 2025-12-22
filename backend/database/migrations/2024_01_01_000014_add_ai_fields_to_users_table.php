<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('type_of_audience')->nullable()->after('is_admin');
            $table->json('audience_demographics')->nullable()->after('type_of_audience');
            $table->json('content_preferences')->nullable()->after('audience_demographics');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['type_of_audience', 'audience_demographics', 'content_preferences']);
        });
    }
};
