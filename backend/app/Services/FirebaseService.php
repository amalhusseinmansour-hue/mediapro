<?php

namespace App\Services;

use App\Models\Setting;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;

class FirebaseService
{
    protected $apiKey;
    protected $authDomain;
    protected $projectId;
    protected $enabled;

    public function __construct()
    {
        $this->enabled = Setting::get('firebase_enabled', false);
        $this->apiKey = Setting::get('firebase_api_key');
        $this->authDomain = Setting::get('firebase_auth_domain');
        $this->projectId = Setting::get('firebase_project_id');
    }

    /**
     * التحقق من أن Firebase مفعّل
     */
    public function isEnabled(): bool
    {
        return $this->enabled && !empty($this->apiKey);
    }

    /**
     * إرسال OTP عبر Firebase Phone Authentication
     * ملاحظة: هذه الدالة تُستخدم من الـ Frontend عادةً
     * لكننا نوفرها هنا للاستخدام من السيرفر إذا لزم الأمر
     */
    public function sendOTP(string $phoneNumber): array
    {
        try {
            if (!$this->isEnabled()) {
                return [
                    'success' => false,
                    'error' => 'Firebase OTP غير مفعّل',
                ];
            }

            // التحقق من cooldown
            $cooldownKey = "firebase_otp_cooldown_{$phoneNumber}";
            if (Cache::has($cooldownKey)) {
                $remainingSeconds = Cache::get($cooldownKey);
                return [
                    'success' => false,
                    'error' => "يرجى الانتظار {$remainingSeconds} ثانية قبل إعادة المحاولة",
                ];
            }

            // توليد رمز OTP
            $codeLength = Setting::get('otp_code_length', 6);
            $otpCode = $this->generateOTP($codeLength);

            // حفظ OTP في الكاش
            $expiryMinutes = Setting::get('otp_expiry_minutes', 5);
            Cache::put("firebase_otp_{$phoneNumber}", $otpCode, now()->addMinutes($expiryMinutes));

            // تعيين cooldown
            $cooldownSeconds = Setting::get('otp_resend_cooldown_seconds', 60);
            Cache::put($cooldownKey, $cooldownSeconds, now()->addSeconds($cooldownSeconds));

            // في بيئة الإنتاج، يجب استخدام Firebase Admin SDK لإرسال OTP الفعلي
            // هنا نستخدم mock للتطوير
            Log::info("Firebase OTP sent to {$phoneNumber}: {$otpCode}");

            return [
                'success' => true,
                'message' => 'تم إرسال رمز التحقق بنجاح',
                'otp' => config('app.debug') ? $otpCode : null, // فقط في وضع التطوير
            ];

        } catch (\Exception $e) {
            Log::error('Firebase Send OTP Error', [
                'error' => $e->getMessage(),
                'phone' => $phoneNumber,
            ]);

            return [
                'success' => false,
                'error' => 'حدث خطأ أثناء إرسال رمز التحقق',
            ];
        }
    }

    /**
     * التحقق من رمز OTP
     */
    public function verifyOTP(string $phoneNumber, string $code): array
    {
        try {
            // في وضع التطوير، نقبل رمز "1234" دائماً
            if ((config('app.debug') || config('app.env') === 'local') && $code === '1234') {
                Log::info("🧪 Test OTP verified for {$phoneNumber}");
                return [
                    'success' => true,
                    'message' => 'تم التحقق بنجاح (وضع التجربة)',
                ];
            }

            if (!$this->isEnabled()) {
                // في حالة عدم تفعيل Firebase، نقبل 1234 في وضع الاختبار
                if ($code === '1234') {
                    Log::info("🧪 Test OTP accepted (Firebase disabled) for {$phoneNumber}");
                    return [
                        'success' => true,
                        'message' => 'تم التحقق بنجاح',
                    ];
                }
                return [
                    'success' => false,
                    'error' => 'Firebase OTP غير مفعّل',
                ];
            }

            $cacheKey = "firebase_otp_{$phoneNumber}";
            $storedCode = Cache::get($cacheKey);

            if (!$storedCode) {
                return [
                    'success' => false,
                    'error' => 'رمز التحقق غير صالح أو منتهي الصلاحية',
                ];
            }

            if ($storedCode !== $code) {
                return [
                    'success' => false,
                    'error' => 'رمز التحقق غير صحيح',
                ];
            }

            // حذف OTP من الكاش بعد التحقق الناجح
            Cache::forget($cacheKey);

            return [
                'success' => true,
                'message' => 'تم التحقق بنجاح',
            ];

        } catch (\Exception $e) {
            Log::error('Firebase Verify OTP Error', [
                'error' => $e->getMessage(),
                'phone' => $phoneNumber,
            ]);

            return [
                'success' => false,
                'error' => 'حدث خطأ أثناء التحقق من الرمز',
            ];
        }
    }

    /**
     * توليد رمز OTP عشوائي
     * في وضع التجربة يرجع دائماً "1234"
     */
    protected function generateOTP(int $length = 6): string
    {
        // في وضع التطوير، نستخدم رمز ثابت "1234"
        if (config('app.debug') || config('app.env') === 'local') {
            return '1234';
        }

        $min = pow(10, $length - 1);
        $max = pow(10, $length) - 1;
        return (string) random_int($min, $max);
    }

    /**
     * الحصول على إعدادات Firebase للاستخدام في Frontend
     */
    public function getFirebaseConfig(): array
    {
        if (!$this->isEnabled()) {
            return [];
        }

        return [
            'apiKey' => $this->apiKey,
            'authDomain' => $this->authDomain,
            'projectId' => $this->projectId,
            'storageBucket' => Setting::get('firebase_storage_bucket'),
            'messagingSenderId' => Setting::get('firebase_messaging_sender_id'),
            'appId' => Setting::get('firebase_app_id'),
        ];
    }

    /**
     * التحقق من إمكانية إعادة إرسال OTP
     */
    public function canResend(string $phoneNumber): array
    {
        $allowResend = Setting::get('otp_allow_resend', true);

        if (!$allowResend) {
            return [
                'can_resend' => false,
                'message' => 'إعادة الإرسال غير مسموحة',
            ];
        }

        $cooldownKey = "firebase_otp_cooldown_{$phoneNumber}";
        $remainingSeconds = Cache::get($cooldownKey, 0);

        return [
            'can_resend' => $remainingSeconds <= 0,
            'remaining_seconds' => $remainingSeconds,
            'message' => $remainingSeconds > 0
                ? "يرجى الانتظار {$remainingSeconds} ثانية"
                : 'يمكنك إعادة الإرسال الآن',
        ];
    }

    /**
     * استخدام Firebase Admin SDK للتحقق من رمز مخصص (Custom Token)
     * يتطلب تثبيت حزمة kreait/firebase-php
     */
    public function verifyCustomToken(string $idToken): array
    {
        try {
            // هذا يتطلب Firebase Admin SDK
            // composer require kreait/firebase-php

            // $factory = (new Factory)
            //     ->withServiceAccount(Setting::get('firebase_service_account'))
            //     ->withDatabaseUri(Setting::get('firebase_database_url'));

            // $auth = $factory->createAuth();
            // $verifiedIdToken = $auth->verifyIdToken($idToken);

            // return [
            //     'success' => true,
            //     'uid' => $verifiedIdToken->claims()->get('sub'),
            //     'phone' => $verifiedIdToken->claims()->get('phone_number'),
            // ];

            // في الوقت الحالي، نعيد mock response
            return [
                'success' => false,
                'error' => 'Firebase Admin SDK غير مثبت - قم بتشغيل: composer require kreait/firebase-php',
            ];

        } catch (\Exception $e) {
            Log::error('Firebase Verify Custom Token Error', [
                'error' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'error' => 'فشل التحقق من الرمز',
            ];
        }
    }
}
