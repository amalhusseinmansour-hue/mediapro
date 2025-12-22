<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class CreateAdminUser extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'admin:create 
                            {--name=Admin : اسم المدير}
                            {--email= : البريد الإلكتروني}
                            {--password= : كلمة المرور}
                            {--force : إعادة إنشاء المستخدم إذا كان موجوداً}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'إنشاء مستخدم مدير جديد';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('🔧 إنشاء مستخدم مدير جديد...');

        // Get input data
        $name = $this->option('name');
        $email = $this->option('email') ?: $this->ask('📧 البريد الإلكتروني للمدير');
        $password = $this->option('password') ?: $this->secret('🔐 كلمة المرور');
        $force = $this->option('force');

        // Validate input
        $validator = Validator::make([
            'name' => $name,
            'email' => $email,
            'password' => $password,
        ], [
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8',
        ]);

        if ($validator->fails()) {
            $this->error('❌ خطأ في البيانات:');
            foreach ($validator->errors()->all() as $error) {
                $this->line('  - ' . $error);
            }
            return 1;
        }

        // Check if user exists
        $existingUser = User::where('email', $email)->first();
        if ($existingUser && !$force) {
            if ($this->confirm("⚠️ المستخدم {$email} موجود مسبقاً. هل تريد استبداله؟")) {
                $existingUser->delete();
            } else {
                $this->info('❌ تم إلغاء العملية');
                return 0;
            }
        } elseif ($existingUser && $force) {
            $existingUser->delete();
            $this->info("🗑️ تم حذف المستخدم السابق: {$email}");
        }

        // Create admin user
        try {
            $admin = User::create([
                'name' => $name,
                'email' => $email,
                'password' => Hash::make($password),
                'is_admin' => true,
                'is_active' => true,
                'user_type' => 'admin',
                'email_verified_at' => now(),
                'bio' => 'مدير النظام - صلاحيات كاملة',
                'company_name' => 'MediaPro Social',
            ]);

            $this->info('✅ تم إنشاء مستخدم المدير بنجاح!');
            $this->table(
                ['المعلومة', 'القيمة'],
                [
                    ['ID', $admin->id],
                    ['الاسم', $admin->name],
                    ['البريد الإلكتروني', $admin->email],
                    ['مدير؟', $admin->is_admin ? 'نعم' : 'لا'],
                    ['نشط؟', $admin->is_active ? 'نعم' : 'لا'],
                    ['تاريخ الإنشاء', $admin->created_at->format('Y-m-d H:i:s')],
                ]
            );

            $this->warn('🔐 احفظ هذه البيانات للدخول:');
            $this->line("📧 البريد الإلكتروني: {$email}");
            $this->line("🔑 كلمة المرور: {$password}");
            
        } catch (\Exception $e) {
            $this->error('❌ خطأ في إنشاء المستخدم: ' . $e->getMessage());
            return 1;
        }

        return 0;
    }
}