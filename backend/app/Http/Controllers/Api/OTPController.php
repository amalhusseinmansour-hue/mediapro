<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\TwilioService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;

class OTPController extends Controller
{
    protected $twilioService;

    public function __construct(TwilioService $twilioService)
    {
        $this->twilioService = $twilioService;
    }

    /**
     * Send OTP to phone number
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function sendOTP(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'phone_number' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $phoneNumber = $request->input('phone_number');
        $result = $this->twilioService->sendOTP($phoneNumber);

        if ($result['success']) {
            return response()->json($result, 200);
        }

        return response()->json($result, 400);
    }

    /**
     * Verify OTP
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function verifyOTP(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'phone_number' => 'required|string',
            'otp' => 'required|string|min:4|max:8', // Support 4-8 digit OTP (including test OTP "1234")
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $phoneNumber = $request->input('phone_number');
        $otp = $request->input('otp');

        $isValid = $this->twilioService->verifyOTP($phoneNumber, $otp);

        if ($isValid) {
            return response()->json([
                'success' => true,
                'message' => 'تم التحقق بنجاح',
            ], 200);
        }

        return response()->json([
            'success' => false,
            'message' => 'رمز التحقق غير صحيح أو منتهي الصلاحية',
        ], 400);
    }

    /**
     * Get OTP configuration status
     *
     * @return JsonResponse
     */
    public function status(): JsonResponse
    {
        return response()->json([
            'test_mode' => $this->twilioService->isTestMode(),
            'configured' => !empty(config('services.twilio.account_sid')),
        ], 200);
    }
}
