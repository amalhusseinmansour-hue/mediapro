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
        Schema::create('support_tickets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained()->onDelete('cascade');
            $table->string('name'); // اسم صاحب التذكرة
            $table->string('email'); // البريد الإلكتروني
            $table->string('phone')->nullable(); // رقم الهاتف
            $table->string('whatsapp_number')->nullable(); // رقم WhatsApp
            $table->string('subject'); // موضوع التذكرة
            $table->text('message'); // الرسالة
            $table->enum('category', ['technical', 'billing', 'feature', 'bug', 'account', 'other'])->default('other'); // التصنيف
            $table->enum('priority', ['low', 'medium', 'high', 'urgent'])->default('medium'); // الأولوية
            $table->enum('status', ['open', 'in_progress', 'resolved', 'closed'])->default('open'); // الحالة
            $table->text('admin_notes')->nullable(); // ملاحظات الإدارة
            $table->foreignId('assigned_to')->nullable()->constrained('users')->onDelete('set null'); // المعين له
            $table->timestamp('resolved_at')->nullable(); // تاريخ الحل
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('support_tickets');
    }
};
