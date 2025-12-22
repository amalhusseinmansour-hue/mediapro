# إعداد Twilio OTP في الأدمن بانل

## نظرة عامة
هذا الدليل يشرح كيفية ربط OTP بـ Twilio والتحكم من لوحة الأدمن (Filament Admin Panel).

---

## 1. إعدادات قاعدة البيانات

### إضافة حقول Twilio في جدول Settings

أضف الحقول التالية في جدول `settings`:

```sql
-- إعدادات Twilio OTP
INSERT INTO settings (group_name, key, value, type, description) VALUES
('otp', 'twilio_enabled', '1', 'boolean', 'تفعيل/إيقاف Twilio لإرسال OTP'),
('otp', 'twilio_account_sid', 'YOUR_ACCOUNT_SID', 'string', 'Twilio Account SID'),
('otp', 'twilio_auth_token', 'YOUR_AUTH_TOKEN', 'string', 'Twilio Auth Token'),
('otp', 'twilio_phone_number', '+1234567890', 'string', 'رقم هاتف Twilio المرسل'),
('otp', 'message_template', 'Your verification code is: {code}', 'text', 'قالب رسالة OTP'),
('otp', 'code_length', '6', 'integer', 'طول رمز OTP'),
('otp', 'expiry_minutes', '5', 'integer', 'مدة صلاحية OTP بالدقائق'),
('otp', 'test_otp_enabled', '1', 'boolean', 'تفعيل OTP التجريبي للاختبار'),
('otp', 'test_otp_code', '123456', 'string', 'رمز OTP التجريبي');
```

---

## 2. تثبيت Twilio SDK في Laravel

```bash
composer require twilio/sdk
```

---

## 3. إضافة Twilio Config في Laravel

في ملف `config/services.php`:

```php
'twilio' => [
    'sid' => env('TWILIO_ACCOUNT_SID'),
    'token' => env('TWILIO_AUTH_TOKEN'),
    'from' => env('TWILIO_PHONE_NUMBER'),
],
```

في ملف `.env`:

```env
TWILIO_ACCOUNT_SID=your_account_sid_here
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_PHONE_NUMBER=+1234567890
```

---

## 4. إنشاء Service لإرسال OTP عبر Twilio

### ملف: `app/Services/TwilioOtpService.php`

```php
<?php

namespace App\Services;

use Twilio\Rest\Client;
use App\Models\Setting;

class TwilioOtpService
{
    protected $twilio;
    protected $from;

    public function __construct()
    {
        // الحصول على إعدادات Twilio من قاعدة البيانات
        $accountSid = Setting::get('twilio_account_sid');
        $authToken = Setting::get('twilio_auth_token');
        $this->from = Setting::get('twilio_phone_number');

        // تهيئة Twilio Client
        if ($accountSid && $authToken) {
            $this->twilio = new Client($accountSid, $authToken);
        }
    }

    /**
     * إرسال OTP عبر SMS
     */
    public function sendOtp($phoneNumber, $code)
    {
        try {
            // التحقق من تفعيل Twilio
            if (!Setting::get('twilio_enabled', false)) {
                throw new \Exception('Twilio OTP is not enabled');
            }

            // الحصول على قالب الرسالة
            $template = Setting::get('message_template', 'Your verification code is: {code}');
            $message = str_replace('{code}', $code, $template);

            // إرسال الرسالة عبر Twilio
            $this->twilio->messages->create(
                $phoneNumber,
                [
                    'from' => $this->from,
                    'body' => $message
                ]
            );

            return [
                'success' => true,
                'message' => 'OTP sent successfully via Twilio'
            ];
        } catch (\Exception $e) {
            \Log::error('Twilio OTP Error: ' . $e->getMessage());

            return [
                'success' => false,
                'message' => 'Failed to send OTP: ' . $e->getMessage()
            ];
        }
    }

    /**
     * توليد OTP Code
     */
    public function generateOtp()
    {
        $length = Setting::get('code_length', 6);
        $min = pow(10, $length - 1);
        $max = pow(10, $length) - 1;

        return random_int($min, $max);
    }

    /**
     * التحقق من صلاحية OTP
     */
    public function isOtpValid($createdAt)
    {
        $expiryMinutes = Setting::get('expiry_minutes', 5);
        $expiryTime = now()->subMinutes($expiryMinutes);

        return $createdAt > $expiryTime;
    }
}
```

---

## 5. تحديث OTP Controller

### ملف: `app/Http/Controllers/Api/OtpController.php`

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Services\TwilioOtpService;
use App\Models\Otp;
use App\Models\Setting;

class OtpController extends Controller
{
    protected $twilioService;

    public function __construct(TwilioOtpService $twilioService)
    {
        $this->twilioService = $twilioService;
    }

    /**
     * إرسال OTP
     */
    public function send(Request $request)
    {
        $request->validate([
            'phone_number' => 'required|string'
        ]);

        $phoneNumber = $request->phone_number;

        try {
            // التحقق من تفعيل Test OTP
            $testOtpEnabled = Setting::get('test_otp_enabled', true);

            if ($testOtpEnabled) {
                // استخدام OTP تجريبي
                $code = Setting::get('test_otp_code', '123456');

                \Log::info("Test OTP for {$phoneNumber}: {$code}");

                return response()->json([
                    'success' => true,
                    'message' => 'Test OTP enabled. Check logs for code.',
                    'test_mode' => true,
                    'otp' => $code // في وضع التجربة فقط
                ]);
            }

            // توليد OTP
            $code = $this->twilioService->generateOtp();

            // حفظ OTP في قاعدة البيانات
            Otp::create([
                'phone_number' => $phoneNumber,
                'code' => $code,
                'expires_at' => now()->addMinutes(Setting::get('expiry_minutes', 5)),
            ]);

            // إرسال OTP عبر Twilio
            $result = $this->twilioService->sendOtp($phoneNumber, $code);

            if (!$result['success']) {
                return response()->json([
                    'success' => false,
                    'message' => $result['message']
                ], 500);
            }

            return response()->json([
                'success' => true,
                'message' => 'OTP sent successfully',
                'test_mode' => false
            ]);

        } catch (\Exception $e) {
            \Log::error('OTP Send Error: ' . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'Failed to send OTP: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * التحقق من OTP
     */
    public function verify(Request $request)
    {
        $request->validate([
            'phone_number' => 'required|string',
            'code' => 'required|string'
        ]);

        $phoneNumber = $request->phone_number;
        $code = $request->code;

        try {
            // التحقق من Test OTP أولاً
            $testOtpEnabled = Setting::get('test_otp_enabled', true);
            $testOtpCode = Setting::get('test_otp_code', '123456');

            if ($testOtpEnabled && $code === $testOtpCode) {
                return response()->json([
                    'success' => true,
                    'message' => 'OTP verified (Test Mode)',
                    'test_mode' => true
                ]);
            }

            // البحث عن OTP في قاعدة البيانات
            $otp = Otp::where('phone_number', $phoneNumber)
                      ->where('code', $code)
                      ->where('verified', false)
                      ->first();

            if (!$otp) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid OTP code'
                ], 400);
            }

            // التحقق من صلاحية OTP
            if (!$this->twilioService->isOtpValid($otp->created_at)) {
                return response()->json([
                    'success' => false,
                    'message' => 'OTP has expired'
                ], 400);
            }

            // تحديث حالة OTP
            $otp->update(['verified' => true]);

            return response()->json([
                'success' => true,
                'message' => 'OTP verified successfully',
                'test_mode' => false
            ]);

        } catch (\Exception $e) {
            \Log::error('OTP Verify Error: ' . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'Failed to verify OTP: ' . $e->getMessage()
            ], 500);
        }
    }
}
```

---

## 6. إضافة صفحة إعدادات OTP في Filament Admin

### ملف: `app/Filament/Pages/OtpSettings.php`

```php
<?php

namespace App\Filament\Pages;

use Filament\Pages\Page;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use Filament\Notifications\Notification;
use App\Models\Setting;

class OtpSettings extends Page implements HasForms
{
    use InteractsWithForms;

    protected static ?string $navigationIcon = 'heroicon-o-device-phone-mobile';
    protected static string $view = 'filament.pages.otp-settings';
    protected static ?string $navigationLabel = 'OTP Settings';
    protected static ?string $title = 'OTP Settings';
    protected static ?string $navigationGroup = 'Settings';
    protected static ?int $navigationSort = 5;

    public $twilio_enabled;
    public $twilio_account_sid;
    public $twilio_auth_token;
    public $twilio_phone_number;
    public $message_template;
    public $code_length;
    public $expiry_minutes;
    public $test_otp_enabled;
    public $test_otp_code;

    public function mount(): void
    {
        $this->form->fill([
            'twilio_enabled' => Setting::get('twilio_enabled', false),
            'twilio_account_sid' => Setting::get('twilio_account_sid', ''),
            'twilio_auth_token' => Setting::get('twilio_auth_token', ''),
            'twilio_phone_number' => Setting::get('twilio_phone_number', ''),
            'message_template' => Setting::get('message_template', 'Your verification code is: {code}'),
            'code_length' => Setting::get('code_length', 6),
            'expiry_minutes' => Setting::get('expiry_minutes', 5),
            'test_otp_enabled' => Setting::get('test_otp_enabled', true),
            'test_otp_code' => Setting::get('test_otp_code', '123456'),
        ]);
    }

    protected function getFormSchema(): array
    {
        return [
            Section::make('Twilio Configuration')
                ->description('Configure Twilio for SMS OTP delivery')
                ->schema([
                    Toggle::make('twilio_enabled')
                        ->label('Enable Twilio OTP')
                        ->helperText('Enable or disable Twilio for OTP delivery'),

                    TextInput::make('twilio_account_sid')
                        ->label('Twilio Account SID')
                        ->required()
                        ->maxLength(255),

                    TextInput::make('twilio_auth_token')
                        ->label('Twilio Auth Token')
                        ->password()
                        ->required()
                        ->maxLength(255),

                    TextInput::make('twilio_phone_number')
                        ->label('Twilio Phone Number')
                        ->helperText('Format: +1234567890')
                        ->required()
                        ->maxLength(20),
                ]),

            Section::make('OTP Configuration')
                ->description('Configure OTP behavior')
                ->schema([
                    Textarea::make('message_template')
                        ->label('SMS Message Template')
                        ->helperText('Use {code} as placeholder for OTP code')
                        ->required()
                        ->rows(3),

                    TextInput::make('code_length')
                        ->label('OTP Code Length')
                        ->numeric()
                        ->required()
                        ->minValue(4)
                        ->maxValue(8)
                        ->default(6),

                    TextInput::make('expiry_minutes')
                        ->label('OTP Expiry Time (minutes)')
                        ->numeric()
                        ->required()
                        ->minValue(1)
                        ->maxValue(60)
                        ->default(5),
                ]),

            Section::make('Test Mode')
                ->description('Configure test OTP for development')
                ->schema([
                    Toggle::make('test_otp_enabled')
                        ->label('Enable Test OTP')
                        ->helperText('Allow test OTP code for development'),

                    TextInput::make('test_otp_code')
                        ->label('Test OTP Code')
                        ->required()
                        ->maxLength(10),
                ]),
        ];
    }

    public function submit(): void
    {
        $data = $this->form->getState();

        foreach ($data as $key => $value) {
            Setting::set($key, $value);
        }

        Notification::make()
            ->title('Settings saved successfully')
            ->success()
            ->send();
    }
}
```

### ملف View: `resources/views/filament/pages/otp-settings.blade.php`

```blade
<x-filament::page>
    <form wire:submit.prevent="submit">
        {{ $this->form }}

        <div class="flex justify-end mt-6">
            <x-filament::button type="submit">
                Save Settings
            </x-filament::button>
        </div>
    </form>
</x-filament::page>
```

---

## 7. إضافة Route لـ OTP

في ملف `routes/api.php`:

```php
use App\Http\Controllers\Api\OtpController;

Route::prefix('otp')->group(function () {
    Route::post('/send', [OtpController::class, 'send']);
    Route::post('/verify', [OtpController::class, 'verify']);
});
```

---

## 8. إنشاء Migration لجدول OTP

```bash
php artisan make:migration create_otps_table
```

في ملف Migration:

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('otps', function (Blueprint $table) {
            $table->id();
            $table->string('phone_number');
            $table->string('code');
            $table->timestamp('expires_at');
            $table->boolean('verified')->default(false);
            $table->timestamps();

            $table->index('phone_number');
            $table->index(['phone_number', 'code']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('otps');
    }
};
```

تشغيل Migration:

```bash
php artisan migrate
```

---

## 9. إنشاء Model للـ OTP

### ملف: `app/Models/Otp.php`

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Otp extends Model
{
    protected $fillable = [
        'phone_number',
        'code',
        'expires_at',
        'verified',
    ];

    protected $casts = [
        'expires_at' => 'datetime',
        'verified' => 'boolean',
    ];
}
```

---

## 10. الحصول على Twilio Credentials

1. **إنشاء حساب في Twilio:**
   - اذهب إلى: https://www.twilio.com/
   - سجّل حساب جديد

2. **الحصول على Account SID و Auth Token:**
   - اذهب إلى Console Dashboard
   - انسخ Account SID
   - انسخ Auth Token

3. **شراء رقم هاتف:**
   - اذهب إلى Phone Numbers > Buy a Number
   - اختر رقماً يدعم SMS
   - اشتري الرقم

4. **تفعيل الرقم:**
   - الرقم الآن جاهز لإرسال رسائل SMS

---

## 11. طريقة الاستخدام من Flutter

التطبيق سيستخدم نفس الـ API:

```dart
// إرسال OTP
await otpService.sendOTP(phoneNumber);

// التحقق من OTP
await otpService.verifyOTP(phoneNumber, code);
```

**الباكيند سيتولى:**
- اختيار إرسال OTP عبر Twilio أو Test Mode
- تطبيق القالب المخصص للرسالة
- التحكم في طول الكود ومدة الصلاحية

---

## 12. اختبار النظام

### Test Mode (للتطوير):
```php
// في الأدمن بانل
test_otp_enabled = true
test_otp_code = 123456
```

أي رقم يطلب OTP سيحصل على الكود `123456`

### Production Mode:
```php
// في الأدمن بانل
test_otp_enabled = false
twilio_enabled = true
```

سيتم إرسال OTP حقيقي عبر Twilio

---

## ملخص الميزات

✅ **ربط كامل مع Twilio**
✅ **التحكم من الأدمن بانل**
✅ **إعدادات مرنة (طول الكود، مدة الصلاحية، قالب الرسالة)**
✅ **Test Mode للتطوير**
✅ **Production Mode للإنتاج**
✅ **حفظ سجل OTP في قاعدة البيانات**
✅ **API RESTful للتطبيق**

---

## الدعم

لأي استفسارات أو مشاكل، تواصل مع فريق التطوير.
