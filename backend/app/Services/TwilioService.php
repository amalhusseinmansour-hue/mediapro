<?php

namespace App\Services;

use App\Models\Setting;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;

class TwilioService
{
    protected $accountSid;
    protected $authToken;
    protected $fromNumber;
    protected $isTestMode;
    protected $defaultCountryCode;
    protected $otpLength;
    protected $otpExpiryMinutes;
    protected $messageTemplate;

    public function __construct()
    {
        // Try to get settings from database first, fallback to config
        $this->accountSid = Setting::get('twilio_account_sid') ?? config('services.twilio.account_sid');
        $this->authToken = Setting::get('twilio_auth_token') ?? config('services.twilio.auth_token');
        $this->fromNumber = Setting::get('twilio_from_number') ?? config('services.twilio.from_number');
        $this->isTestMode = (bool) (Setting::get('twilio_test_mode') ?? config('services.twilio.test_mode', true));
        $this->defaultCountryCode = Setting::get('twilio_default_country_code') ?? config('services.twilio.default_country_code', '+971');
        $this->otpLength = (int) (Setting::get('twilio_otp_length') ?? 8);
        $this->otpExpiryMinutes = (int) (Setting::get('twilio_otp_expiry_minutes') ?? 5);
        $this->messageTemplate = Setting::get('twilio_otp_message_template') ?? 'رمز التحقق الخاص بك: {otp}\nصالح لمدة {minutes} دقائق';

        // Check if Twilio is enabled
        $twilioEnabled = (bool) (Setting::get('twilio_enabled') ?? config('services.twilio.enabled', true));
        if (!$twilioEnabled) {
            $this->isTestMode = true; // Force test mode if disabled
        }
    }

    /**
     * Format phone number with country code
     *
     * @param string $phoneNumber
     * @return string
     */
    protected function formatPhoneNumber(string $phoneNumber): string
    {
        // Remove all spaces, dashes, and parentheses
        $cleaned = preg_replace('/[\s\-\(\)]/', '', $phoneNumber);

        // If number already starts with +, return as is
        if (str_starts_with($cleaned, '+')) {
            return $cleaned;
        }

        // If number starts with 00, replace with +
        if (str_starts_with($cleaned, '00')) {
            return '+' . substr($cleaned, 2);
        }

        // If number starts with 0, remove it and add country code
        if (str_starts_with($cleaned, '0')) {
            return $this->defaultCountryCode . substr($cleaned, 1);
        }

        // If number doesn't have country code, add default
        if (!str_starts_with($cleaned, '+')) {
            return $this->defaultCountryCode . $cleaned;
        }

        return $cleaned;
    }

    /**
     * Send OTP via Twilio SMS
     *
     * @param string $phoneNumber
     * @return array
     */
    public function sendOTP(string $phoneNumber): array
    {
        // Format phone number with country code
        $formattedPhone = $this->formatPhoneNumber($phoneNumber);

        // Generate 8-digit OTP
        $otp = $this->generateOTP();

        // Store OTP in cache (use formatted phone as key)
        Cache::put('otp_' . $formattedPhone, $otp, now()->addMinutes($this->otpExpiryMinutes));

        // Test mode - return OTP without sending SMS
        if ($this->isTestMode) {
            Log::info('🧪 Test mode OTP', [
                'phone_original' => $phoneNumber,
                'phone_formatted' => $formattedPhone,
                'otp' => $otp
            ]);

            return [
                'success' => true,
                'message' => 'تم إرسال رمز التحقق (وضع التجربة)',
                'otp' => $otp, // في وضع التجربة، نرجع الرمز
                'phone_formatted' => $formattedPhone,
                'test_mode' => true,
            ];
        }

        // Production mode - send via Twilio
        if (empty($this->accountSid) || empty($this->authToken) || empty($this->fromNumber)) {
            return [
                'success' => false,
                'error' => 'Twilio not configured',
            ];
        }

        try {
            $message = str_replace(
                ['{otp}', '{minutes}'],
                [$otp, $this->otpExpiryMinutes],
                $this->messageTemplate
            );

            $response = Http::asForm()
                ->withBasicAuth($this->accountSid, $this->authToken)
                ->post("https://api.twilio.com/2010-04-01/Accounts/{$this->accountSid}/Messages.json", [
                    'To' => $formattedPhone, // استخدام الرقم المنسق
                    'From' => $this->fromNumber,
                    'Body' => $message,
                ]);

            if ($response->successful()) {
                Log::info('✅ OTP sent via Twilio', [
                    'phone_original' => $phoneNumber,
                    'phone_formatted' => $formattedPhone,
                    'message_sid' => $response->json('sid')
                ]);

                return [
                    'success' => true,
                    'message' => 'تم إرسال رمز التحقق',
                    'phone_formatted' => $formattedPhone,
                    'test_mode' => false,
                ];
            } else {
                Log::error('❌ Twilio API error', [
                    'phone_original' => $phoneNumber,
                    'phone_formatted' => $formattedPhone,
                    'error' => $response->json()
                ]);

                return [
                    'success' => false,
                    'error' => 'Failed to send OTP: ' . ($response->json('message') ?? 'Unknown error'),
                ];
            }
        } catch (\Exception $e) {
            Log::error('❌ Error sending OTP', [
                'phone_original' => $phoneNumber,
                'phone_formatted' => $formattedPhone,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Verify OTP
     *
     * @param string $phoneNumber
     * @param string $otp
     * @return bool
     */
    public function verifyOTP(string $phoneNumber, string $otp): bool
    {
        // Format phone number
        $formattedPhone = $this->formatPhoneNumber($phoneNumber);

        // In test mode, accept fixed OTP "1234"
        if ($this->isTestMode && $otp === '1234') {
            Log::info('🧪 Test OTP verified', [
                'phone_original' => $phoneNumber,
                'phone_formatted' => $formattedPhone
            ]);
            return true;
        }

        // Get stored OTP from cache (use formatted phone)
        $storedOtp = Cache::get('otp_' . $formattedPhone);

        if (!$storedOtp) {
            Log::warning('⚠️ OTP not found or expired', [
                'phone_original' => $phoneNumber,
                'phone_formatted' => $formattedPhone
            ]);
            return false;
        }

        if ($storedOtp === $otp) {
            // Clear OTP after successful verification
            Cache::forget('otp_' . $formattedPhone);
            Log::info('✅ OTP verified', [
                'phone_original' => $phoneNumber,
                'phone_formatted' => $formattedPhone
            ]);
            return true;
        }

        Log::warning('❌ Invalid OTP', [
            'phone_original' => $phoneNumber,
            'phone_formatted' => $formattedPhone
        ]);
        return false;
    }

    /**
     * Generate random OTP based on configured length
     *
     * @return string
     */
    protected function generateOTP(): string
    {
        // In test mode, always return fixed OTP "1234"
        if ($this->isTestMode) {
            return '1234';
        }

        $min = pow(10, $this->otpLength - 1);
        $max = pow(10, $this->otpLength) - 1;
        return str_pad(random_int($min, $max), $this->otpLength, '0', STR_PAD_LEFT);
    }

    /**
     * Check if test mode is enabled
     *
     * @return bool
     */
    public function isTestMode(): bool
    {
        return $this->isTestMode;
    }
}
