<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Str;
use PragmaRX\Google2FA\Google2FA;
use BaconQrCode\Renderer\ImageRenderer;
use BaconQrCode\Renderer\Image\SvgImageBackEnd;
use BaconQrCode\Renderer\RendererStyle\RendererStyle;
use BaconQrCode\Writer;

class TwoFactorAuthService
{
    protected Google2FA $google2fa;
    protected string $appName;

    public function __construct()
    {
        $this->google2fa = new Google2FA();
        $this->appName = config('app.name', 'Social Media Manager');
    }

    /**
     * Generate a new secret key for the user
     */
    public function generateSecretKey(): string
    {
        return $this->google2fa->generateSecretKey();
    }

    /**
     * Get the QR code URL for authenticator apps
     */
    public function getQrCodeUrl(User $user, string $secret): string
    {
        return $this->google2fa->getQRCodeUrl(
            $this->appName,
            $user->email,
            $secret
        );
    }

    /**
     * Generate QR code as SVG
     */
    public function getQrCodeSvg(User $user, string $secret): string
    {
        $qrCodeUrl = $this->getQrCodeUrl($user, $secret);

        $renderer = new ImageRenderer(
            new RendererStyle(200),
            new SvgImageBackEnd()
        );

        $writer = new Writer($renderer);
        return $writer->writeString($qrCodeUrl);
    }

    /**
     * Verify the OTP code
     */
    public function verifyCode(string $secret, string $code): bool
    {
        return $this->google2fa->verifyKey($secret, $code);
    }

    /**
     * Generate recovery codes
     */
    public function generateRecoveryCodes(int $count = 8): array
    {
        $codes = [];
        for ($i = 0; $i < $count; $i++) {
            $codes[] = Str::upper(Str::random(4) . '-' . Str::random(4) . '-' . Str::random(4));
        }
        return $codes;
    }

    /**
     * Encrypt recovery codes for storage
     */
    public function encryptRecoveryCodes(array $codes): string
    {
        return encrypt(json_encode($codes));
    }

    /**
     * Decrypt recovery codes
     */
    public function decryptRecoveryCodes(?string $encryptedCodes): array
    {
        if (!$encryptedCodes) {
            return [];
        }

        try {
            return json_decode(decrypt($encryptedCodes), true) ?? [];
        } catch (\Exception $e) {
            return [];
        }
    }

    /**
     * Enable 2FA for user
     */
    public function enable(User $user, string $secret, string $code): array
    {
        // Verify the code first
        if (!$this->verifyCode($secret, $code)) {
            return [
                'success' => false,
                'message' => 'رمز التحقق غير صحيح',
            ];
        }

        // Generate recovery codes
        $recoveryCodes = $this->generateRecoveryCodes();

        // Update user
        $user->update([
            'two_factor_enabled' => true,
            'two_factor_secret' => encrypt($secret),
            'two_factor_recovery_codes' => $this->encryptRecoveryCodes($recoveryCodes),
            'two_factor_confirmed_at' => now(),
        ]);

        return [
            'success' => true,
            'message' => 'تم تفعيل المصادقة الثنائية بنجاح',
            'recovery_codes' => $recoveryCodes,
        ];
    }

    /**
     * Disable 2FA for user
     */
    public function disable(User $user, string $password): array
    {
        // Verify password
        if (!password_verify($password, $user->password)) {
            return [
                'success' => false,
                'message' => 'كلمة المرور غير صحيحة',
            ];
        }

        $user->update([
            'two_factor_enabled' => false,
            'two_factor_secret' => null,
            'two_factor_recovery_codes' => null,
            'two_factor_confirmed_at' => null,
        ]);

        return [
            'success' => true,
            'message' => 'تم تعطيل المصادقة الثنائية',
        ];
    }

    /**
     * Verify 2FA code during login
     */
    public function verifyLogin(User $user, string $code): bool
    {
        if (!$user->two_factor_enabled || !$user->two_factor_secret) {
            return true; // 2FA not enabled
        }

        $secret = decrypt($user->two_factor_secret);

        // Try regular TOTP code
        if ($this->verifyCode($secret, $code)) {
            return true;
        }

        // Try recovery code
        return $this->useRecoveryCode($user, $code);
    }

    /**
     * Use a recovery code
     */
    public function useRecoveryCode(User $user, string $code): bool
    {
        $recoveryCodes = $this->decryptRecoveryCodes($user->two_factor_recovery_codes);

        if (in_array($code, $recoveryCodes)) {
            // Remove used code
            $recoveryCodes = array_values(array_diff($recoveryCodes, [$code]));
            $user->update([
                'two_factor_recovery_codes' => $this->encryptRecoveryCodes($recoveryCodes),
            ]);
            return true;
        }

        return false;
    }

    /**
     * Regenerate recovery codes
     */
    public function regenerateRecoveryCodes(User $user, string $password): array
    {
        // Verify password
        if (!password_verify($password, $user->password)) {
            return [
                'success' => false,
                'message' => 'كلمة المرور غير صحيحة',
            ];
        }

        $recoveryCodes = $this->generateRecoveryCodes();
        $user->update([
            'two_factor_recovery_codes' => $this->encryptRecoveryCodes($recoveryCodes),
        ]);

        return [
            'success' => true,
            'message' => 'تم إنشاء رموز استرداد جديدة',
            'recovery_codes' => $recoveryCodes,
        ];
    }

    /**
     * Get 2FA status for user
     */
    public function getStatus(User $user): array
    {
        $recoveryCodes = $this->decryptRecoveryCodes($user->two_factor_recovery_codes);

        return [
            'enabled' => $user->two_factor_enabled,
            'confirmed_at' => $user->two_factor_confirmed_at,
            'recovery_codes_remaining' => count($recoveryCodes),
        ];
    }
}
