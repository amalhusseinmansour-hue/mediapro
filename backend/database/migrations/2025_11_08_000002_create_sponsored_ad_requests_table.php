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
        Schema::create('sponsored_ad_requests', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // اسم العميل
            $table->string('email'); // البريد الإلكتروني
            $table->string('phone'); // رقم الهاتف
            $table->string('company_name')->nullable(); // اسم الشركة
            $table->enum('ad_platform', ['facebook', 'instagram', 'google', 'tiktok', 'twitter', 'linkedin', 'snapchat', 'multiple']); // منصة الإعلان
            $table->enum('ad_type', ['awareness', 'traffic', 'engagement', 'leads', 'sales', 'app_installs']); // نوع الحملة الإعلانية
            $table->text('target_audience'); // الجمهور المستهدف
            $table->decimal('budget', 10, 2); // الميزانية
            $table->string('currency', 3)->default('AED'); // العملة
            $table->integer('duration_days')->nullable(); // مدة الحملة بالأيام
            $table->date('start_date')->nullable(); // تاريخ البدء المطلوب
            $table->text('ad_content')->nullable(); // محتوى الإعلان
            $table->json('targeting_options')->nullable(); // خيارات الاستهداف (JSON)
            $table->enum('status', ['pending', 'reviewing', 'accepted', 'rejected', 'running', 'completed'])->default('pending'); // حالة الطلب
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
        Schema::dropIfExists('sponsored_ad_requests');
    }
};
