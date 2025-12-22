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
        Schema::create('website_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('users')->onDelete('set null'); // المستخدم الذي أرسل الطلب
            $table->string('name'); // اسم العميل
            $table->string('email'); // البريد الإلكتروني
            $table->string('phone'); // رقم الهاتف
            $table->string('company_name')->nullable(); // اسم الشركة
            $table->enum('website_type', ['corporate', 'ecommerce', 'blog', 'portfolio', 'custom']); // نوع الموقع
            $table->text('description'); // وصف المشروع
            $table->decimal('budget', 10, 2)->nullable(); // الميزانية المتوقعة
            $table->string('currency', 3)->default('SAR'); // العملة
            $table->date('deadline')->nullable(); // الموعد المطلوب
            $table->json('features')->nullable(); // الميزات المطلوبة (JSON array)
            $table->enum('status', ['pending', 'reviewing', 'accepted', 'rejected', 'completed'])->default('pending'); // حالة الطلب
            $table->text('admin_notes')->nullable(); // ملاحظات الإدارة
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('website_requests');
    }
};
