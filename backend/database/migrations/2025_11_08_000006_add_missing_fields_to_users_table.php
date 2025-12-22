<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Phone verification fields
            $table->string('phone')->nullable()->after('email');
            $table->boolean('is_phone_verified')->default(false)->after('phone');

            // Admin and role fields
            $table->boolean('is_admin')->default(false)->after('password');
            $table->foreignId('role_id')->nullable()->after('is_admin');

            // User preferences
            $table->string('type_of_audience')->nullable()->after('role_id');
            $table->json('audience_demographics')->nullable()->after('type_of_audience');
            $table->json('content_preferences')->nullable()->after('audience_demographics');

            // Profile fields
            $table->string('profile_picture')->nullable()->after('content_preferences');
            $table->text('bio')->nullable()->after('profile_picture');

            // Business fields
            $table->string('company_name')->nullable()->after('bio');
            $table->string('business_type')->nullable()->after('company_name');

            // Social media profile links
            $table->string('facebook_url')->nullable()->after('business_type');
            $table->string('instagram_url')->nullable()->after('facebook_url');
            $table->string('twitter_url')->nullable()->after('instagram_url');
            $table->string('linkedin_url')->nullable()->after('twitter_url');

            // Status
            $table->boolean('is_active')->default(true)->after('linkedin_url');
            $table->timestamp('last_login_at')->nullable()->after('is_active');

            // Add index for phone
            $table->index('phone');
            $table->index('is_admin');
            $table->index('role_id');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex(['phone']);
            $table->dropIndex(['is_admin']);
            $table->dropIndex(['role_id']);

            $table->dropColumn([
                'phone',
                'is_phone_verified',
                'is_admin',
                'role_id',
                'type_of_audience',
                'audience_demographics',
                'content_preferences',
                'profile_picture',
                'bio',
                'company_name',
                'business_type',
                'facebook_url',
                'instagram_url',
                'twitter_url',
                'linkedin_url',
                'is_active',
                'last_login_at',
            ]);
        });
    }
};
