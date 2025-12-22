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
        Schema::create('notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained()->onDelete('cascade');
            $table->string('type'); // info, success, warning, error, subscription, payment
            $table->string('title');
            $table->text('message');
            $table->json('data')->nullable(); // معلومات إضافية
            $table->string('icon')->nullable();
            $table->string('action_url')->nullable(); // رابط للإجراء
            $table->string('action_text')->nullable(); // نص زر الإجراء
            $table->boolean('is_read')->default(false);
            $table->timestamp('read_at')->nullable();
            $table->boolean('is_global')->default(false); // إشعار عام لجميع المستخدمين
            $table->timestamp('expires_at')->nullable(); // تاريخ انتهاء الإشعار
            $table->timestamps();
            $table->softDeletes();

            $table->index('user_id');
            $table->index('type');
            $table->index('is_read');
            $table->index('is_global');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('notifications');
    }
};
