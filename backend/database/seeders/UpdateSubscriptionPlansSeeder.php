<?php

namespace Database\Seeders;

use App\Models\SubscriptionPlan;
use App\Models\Subscription;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class UpdateSubscriptionPlansSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // تحديث باقة الأفراد (99 درهم)
        $individualPlan = SubscriptionPlan::where('slug', 'individual')
            ->orWhere('name', 'like', '%فرد%')
            ->orWhere('name', 'like', '%individual%')
            ->first();

        if ($individualPlan) {
            $individualPlan->update([
                'max_ai_videos' => 15,
                'max_video_duration' => 4,
                'video_quality' => '480p',
                'max_ai_images' => 50,
                'max_ai_texts' => 100,
                'max_social_accounts' => 3,
                'max_posts' => 30,
                'max_team_members' => 1,
                'priority_processing' => false,
                'advanced_analytics' => false,
                'ai_features' => true,
                'analytics' => true,
                'scheduling' => true,
            ]);
            $this->command->info('✅ تم تحديث باقة الأفراد');
        } else {
            // إنشاء باقة جديدة إذا لم تكن موجودة
            SubscriptionPlan::create([
                'name' => 'الفردي',
                'slug' => 'individual',
                'description' => 'مثالي للمستخدمين الأفراد والمؤثرين',
                'type' => 'monthly',
                'price' => 99.00,
                'currency' => 'AED',
                'max_ai_videos' => 15,
                'max_video_duration' => 4,
                'video_quality' => '480p',
                'max_ai_images' => 50,
                'max_ai_texts' => 100,
                'max_accounts' => 3,
                'max_posts' => 30,
                'max_social_accounts' => 3,
                'max_team_members' => 1,
                'priority_processing' => false,
                'advanced_analytics' => false,
                'ai_features' => true,
                'analytics' => true,
                'scheduling' => true,
                'is_active' => true,
                'sort_order' => 1,
                'features' => [
                    '15 فيديو AI شهرياً',
                    '50 صورة AI شهرياً',
                    '100 نص AI شهرياً',
                    '3 حسابات سوشيال',
                    '30 منشور مجدول',
                    'جودة فيديو 480p',
                    'مدة فيديو حتى 4 ثواني',
                ],
            ]);
            $this->command->info('✅ تم إنشاء باقة الأفراد');
        }

        // تحديث باقة الشركات (179 درهم)
        $businessPlan = SubscriptionPlan::where('slug', 'business')
            ->orWhere('name', 'like', '%شرك%')
            ->orWhere('name', 'like', '%business%')
            ->first();

        if ($businessPlan) {
            $businessPlan->update([
                'max_ai_videos' => 60,
                'max_video_duration' => 8,
                'video_quality' => '1080p',
                'max_ai_images' => 200,
                'max_ai_texts' => 999999, // غير محدود
                'max_social_accounts' => 10,
                'max_posts' => 999999, // غير محدود
                'max_team_members' => 5,
                'priority_processing' => true,
                'advanced_analytics' => true,
                'ai_features' => true,
                'analytics' => true,
                'scheduling' => true,
            ]);
            $this->command->info('✅ تم تحديث باقة الشركات');
        } else {
            // إنشاء باقة جديدة إذا لم تكن موجودة
            SubscriptionPlan::create([
                'name' => 'الشركات',
                'slug' => 'business',
                'description' => 'مثالي للشركات والفرق',
                'type' => 'monthly',
                'price' => 179.00,
                'currency' => 'AED',
                'max_ai_videos' => 60,
                'max_video_duration' => 8,
                'video_quality' => '1080p',
                'max_ai_images' => 200,
                'max_ai_texts' => 999999,
                'max_accounts' => 10,
                'max_posts' => 999999,
                'max_social_accounts' => 10,
                'max_team_members' => 5,
                'priority_processing' => true,
                'advanced_analytics' => true,
                'ai_features' => true,
                'analytics' => true,
                'scheduling' => true,
                'is_active' => true,
                'is_popular' => true,
                'sort_order' => 2,
                'features' => [
                    '60 فيديو AI شهرياً',
                    '200 صورة AI شهرياً',
                    'نصوص AI غير محدودة',
                    '10 حسابات سوشيال',
                    'جدولة غير محدودة',
                    'جودة فيديو 1080p HD',
                    'مدة فيديو حتى 8 ثواني',
                    'أولوية المعالجة',
                    'تحليلات متقدمة',
                    '5 أعضاء فريق',
                ],
            ]);
            $this->command->info('✅ تم إنشاء باقة الشركات');
        }

        // تحديث الاشتراكات الحالية للمستخدمين
        $this->updateExistingSubscriptions();
    }

    /**
     * تحديث الاشتراكات الحالية
     */
    private function updateExistingSubscriptions(): void
    {
        // تحديث اشتراكات الأفراد
        Subscription::where('type', 'individual')
            ->orWhere('name', 'like', '%فرد%')
            ->orWhere('name', 'like', '%individual%')
            ->update([
                'max_ai_videos' => 15,
                'max_video_duration' => 4,
                'video_quality' => '480p',
                'max_ai_images' => 50,
                'max_ai_texts' => 100,
                'max_social_accounts' => 3,
                'max_team_members' => 1,
                'priority_processing' => false,
                'advanced_analytics' => false,
            ]);

        // تحديث اشتراكات الشركات
        Subscription::where('type', 'business')
            ->orWhere('name', 'like', '%شرك%')
            ->orWhere('name', 'like', '%business%')
            ->update([
                'max_ai_videos' => 60,
                'max_video_duration' => 8,
                'video_quality' => '1080p',
                'max_ai_images' => 200,
                'max_ai_texts' => 999999,
                'max_social_accounts' => 10,
                'max_team_members' => 5,
                'priority_processing' => true,
                'advanced_analytics' => true,
            ]);

        $this->command->info('✅ تم تحديث اشتراكات المستخدمين الحالية');
    }
}
