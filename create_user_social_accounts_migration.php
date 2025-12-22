<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('user_social_accounts', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->string('platform', 50); // facebook, twitter, linkedin
            $table->string('platform_user_id')->nullable();
            $table->string('username')->nullable();
            $table->string('display_name')->nullable();
            $table->text('profile_picture')->nullable();
            $table->text('access_token'); // encrypted
            $table->text('refresh_token')->nullable(); // encrypted
            $table->timestamp('token_expires_at')->nullable();
            $table->json('scopes')->nullable();
            $table->json('metadata')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->index('user_id');
            $table->index('platform');
            $table->index(['user_id', 'platform']);
            $table->unique(['user_id', 'platform', 'platform_user_id'], 'unique_user_platform_account');

            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        });
    }

    public function down()
    {
        Schema::dropIfExists('user_social_accounts');
    }
};
