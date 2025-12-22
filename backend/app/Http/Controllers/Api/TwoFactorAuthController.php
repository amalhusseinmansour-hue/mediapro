<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\TwoFactorAuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class TwoFactorAuthController extends Controller
{
    protected TwoFactorAuthService $twoFactorService;

    public function __construct(TwoFactorAuthService $twoFactorService)
    {
        $this->twoFactorService = $twoFactorService;
    }

    /**
     * Get 2FA status for current user
     */
    public function status(Request $request): JsonResponse
    {
        $user = $request->user();
        $status = $this->twoFactorService->getStatus($user);

        return response()->json([
            'success' => true,
            'data' => $status,
        ]);
    }

    /**
     * Initialize 2FA setup - generate secret and QR code
     */
    public function setup(Request $request): JsonResponse
    {
        $user = $request->user();

        // Check if already enabled
        if ($user->two_factor_enabled) {
            return response()->json([
                'success' => false,
                'message' => 'المصادقة الثنائية مفعلة بالفعل',
            ], 422);
        }

        // Generate new secret
        $secret = $this->twoFactorService->generateSecretKey();

        // Store temporarily in session/cache
        session(['2fa_secret' => $secret]);

        // Get QR code URL
        $qrCodeUrl = $this->twoFactorService->getQrCodeUrl($user, $secret);

        // Try to generate SVG, fallback to URL if dependencies missing
        $qrCodeSvg = null;
        try {
            $qrCodeSvg = $this->twoFactorService->getQrCodeSvg($user, $secret);
        } catch (\Exception $e) {
            // QR SVG generation not available
        }

        return response()->json([
            'success' => true,
            'data' => [
                'secret' => $secret,
                'qr_code_url' => $qrCodeUrl,
                'qr_code_svg' => $qrCodeSvg,
                'manual_entry_key' => chunk_split($secret, 4, ' '),
            ],
        ]);
    }

    /**
     * Confirm and enable 2FA
     */
    public function enable(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'secret' => 'required|string',
            'code' => 'required|string|size:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();

        // Check if already enabled
        if ($user->two_factor_enabled) {
            return response()->json([
                'success' => false,
                'message' => 'المصادقة الثنائية مفعلة بالفعل',
            ], 422);
        }

        $result = $this->twoFactorService->enable($user, $request->secret, $request->code);

        return response()->json($result, $result['success'] ? 200 : 422);
    }

    /**
     * Disable 2FA
     */
    public function disable(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();

        // Check if enabled
        if (!$user->two_factor_enabled) {
            return response()->json([
                'success' => false,
                'message' => 'المصادقة الثنائية غير مفعلة',
            ], 422);
        }

        $result = $this->twoFactorService->disable($user, $request->password);

        return response()->json($result, $result['success'] ? 200 : 422);
    }

    /**
     * Verify 2FA code (for login flow)
     */
    public function verify(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'code' => 'required|string|min:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();

        if (!$user->two_factor_enabled) {
            return response()->json([
                'success' => true,
                'message' => 'المصادقة الثنائية غير مفعلة',
            ]);
        }

        $isValid = $this->twoFactorService->verifyLogin($user, $request->code);

        if ($isValid) {
            return response()->json([
                'success' => true,
                'message' => 'تم التحقق بنجاح',
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'رمز التحقق غير صحيح',
        ], 422);
    }

    /**
     * Get recovery codes
     */
    public function getRecoveryCodes(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();

        // Verify password
        if (!password_verify($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'كلمة المرور غير صحيحة',
            ], 422);
        }

        if (!$user->two_factor_enabled) {
            return response()->json([
                'success' => false,
                'message' => 'المصادقة الثنائية غير مفعلة',
            ], 422);
        }

        $codes = $this->twoFactorService->decryptRecoveryCodes($user->two_factor_recovery_codes);

        return response()->json([
            'success' => true,
            'data' => [
                'recovery_codes' => $codes,
                'remaining_count' => count($codes),
            ],
        ]);
    }

    /**
     * Regenerate recovery codes
     */
    public function regenerateRecoveryCodes(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();

        if (!$user->two_factor_enabled) {
            return response()->json([
                'success' => false,
                'message' => 'المصادقة الثنائية غير مفعلة',
            ], 422);
        }

        $result = $this->twoFactorService->regenerateRecoveryCodes($user, $request->password);

        return response()->json($result, $result['success'] ? 200 : 422);
    }
}
