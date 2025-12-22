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
        Schema::create('bank_transfer_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->decimal('amount', 10, 2);
            $table->string('currency', 3)->default('EGP');

            // معلومات التحويل البنكي
            $table->string('sender_name');
            $table->string('sender_bank');
            $table->string('sender_account_number')->nullable();
            $table->string('transfer_reference')->nullable();
            $table->dateTime('transfer_date');
            $table->text('transfer_notes')->nullable();

            // صورة إيصال التحويل
            $table->string('receipt_image')->nullable();

            // حالة الطلب
            $table->enum('status', ['pending', 'reviewing', 'approved', 'rejected'])->default('pending');

            // ملاحظات الإدارة
            $table->text('admin_notes')->nullable();
            $table->foreignId('reviewed_by')->nullable()->constrained('users')->nullOnDelete();
            $table->dateTime('reviewed_at')->nullable();

            $table->timestamps();
            $table->softDeletes();

            $table->index(['user_id', 'status']);
            $table->index('transfer_date');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bank_transfer_requests');
    }
};
