<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\FirebaseService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * تسجيل مستخدم جديد
     * يدعم التسجيل بالبريد الإلكتروني أو رقم الهاتف
     */
    public function register(Request $request): JsonResponse
    {
        // إذا كان الطلب يحتوي على phone فقط بدون email/password
        if (($request->has('phone_number') || $request->has('phoneNumber')) && !$request->has('password')) {
            return $this->registerWithPhone($request);
        }

        // التسجيل العادي بالبريد الإلكتروني وكلمة المرور
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users,email',
            'password' => 'required|string|min:8|confirmed',
            'user_type' => 'required|in:individual,company,business',
            'company_name' => 'required_if:user_type,company|required_if:user_type,business|nullable|string|max:255',
            'phone_number' => 'nullable|string|max:20|unique:users,phone_number',
        ]);

        // تحويل 'company' إلى 'business' لمطابقة قاعدة البيانات
        $userType = $validated['user_type'];
        if ($userType === 'company') {
            $userType = 'business';
        }

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'user_type' => $userType,
            'company_name' => $validated['company_name'] ?? null,
            'phone_number' => $validated['phone_number'] ?? null,
            'is_admin' => false,
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'تم التسجيل بنجاح',
            'data' => [
                'user' => $user,
                'access_token' => $token,
                'token_type' => 'Bearer',
            ],
        ], 201);
    }

    /**
     * تسجيل مستخدم جديد برقم الهاتف (من التطبيق)
     */
    protected function registerWithPhone(Request $request): JsonResponse
    {
        try {
            $phone = $request->input('phone_number') ?? $request->input('phoneNumber');
            $email = $request->input('email') ?? '';
            $name = $request->input('name') ?? 'User ' . substr($phone, -4);
            $userType = $request->input('user_type') ?? $request->input('userType') ?? 'individual';

            // التحقق من صحة رقم الهاتف
            if (empty($phone)) {
                return response()->json([
                    'success' => false,
                    'message' => 'رقم الهاتف مطلوب',
                    'error' => 'Phone number is required',
                ], 422);
            }

            // تحويل 'company' إلى 'business' لمطابقة قاعدة البيانات
            if ($userType === 'company') {
                $userType = 'business';
            }

            // البحث عن مستخدم موجود بنفس رقم الهاتف
            $user = User::where('phone_number', $phone)->first();

            if ($user) {
                // تحديث بيانات المستخدم الموجود
                $user->update([
                    'name' => $name,
                    'phone_number' => $phone,
                    'email' => $email ?: $user->email,
                    'user_type' => $userType,
                    'is_phone_verified' => true,
                    'is_active' => true,
                    'last_login_at' => now(),
                ]);

                $token = $user->createToken('auth_token')->plainTextToken;

                return response()->json([
                    'success' => true,
                    'message' => 'تم تسجيل الدخول بنجاح',
                    'data' => [
                        'user' => $user,
                        'access_token' => $token,
                        'token_type' => 'Bearer',
                    ],
                ], 200);
            }

            // إنشاء بريد إلكتروني من رقم الهاتف إذا لم يتم توفيره
            if (empty($email)) {
                $cleanPhone = preg_replace('/[^0-9]/', '', $phone);
                $email = $cleanPhone . '@socialmedia.app';
            }

            // إنشاء مستخدم جديد
            $user = User::create([
                'name' => $name,
                'email' => $email,
                'phone_number' => $phone,
                'password' => Hash::make(bin2hex(random_bytes(16))), // كلمة مرور عشوائية
                'user_type' => $userType,
                'is_admin' => false,
                'is_phone_verified' => true,
                'is_active' => true,
                'last_login_at' => now(),
            ]);

            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'تم التسجيل بنجاح',
                'data' => [
                    'user' => $user,
                    'access_token' => $token,
                    'token_type' => 'Bearer',
                ],
            ], 201);
        } catch (\Exception $e) {
            \Log::error('Registration error: ' . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء التسجيل',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * تسجيل الدخول
     */
    public function login(Request $request): JsonResponse
    {
        // دعم تسجيل الدخول برقم الهاتف OTP
        if ($request->has('phone') && $request->has('login_method') && $request->input('login_method') === 'otp') {
            return $this->loginWithPhone($request);
        }

        $validated = $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $validated['email'])->first();

        if (!$user || !Hash::check($validated['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['البريد الإلكتروني أو كلمة المرور غير صحيحة'],
            ]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'تم تسجيل الدخول بنجاح',
            'user' => $user,
            'token' => $token,
            'token_type' => 'Bearer',
        ]);
    }

    /**
     * تسجيل الدخول برقم الهاتف
     */
    protected function loginWithPhone(Request $request): JsonResponse
    {
        $phone = $request->input('phone');

        $user = User::where('phone_number', $phone)->first();

        if (!$user) {
            throw ValidationException::withMessages([
                'phone' => ['رقم الهاتف غير مسجل'],
            ]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'تم تسجيل الدخول بنجاح',
            'user' => $user,
            'token' => $token,
            'token_type' => 'Bearer',
        ]);
    }

    /**
     * الحصول على بيانات المستخدم الحالي
     */
    public function user(Request $request): JsonResponse
    {
        return response()->json([
            'user' => $request->user(),
        ]);
    }

    /**
     * تسجيل الخروج
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'تم تسجيل الخروج بنجاح',
        ]);
    }

    /**
     * حذف جميع الـ tokens للمستخدم
     */
    public function logoutAll(Request $request): JsonResponse
    {
        $request->user()->tokens()->delete();

        return response()->json([
            'message' => 'تم تسجيل الخروج من جميع الأجهزة',
        ]);
    }

    /**
     * تحديث الملف الشخصي
     */
    public function updateProfile(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|unique:users,email,' . $request->user()->id,
        ]);

        $request->user()->update($validated);

        return response()->json([
            'message' => 'تم تحديث الملف الشخصي',
            'user' => $request->user(),
        ]);
    }

    /**
     * تغيير كلمة المرور
     */
    public function changePassword(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'current_password' => 'required',
            'password' => 'required|string|min:8|confirmed',
        ]);

        if (!Hash::check($validated['current_password'], $request->user()->password)) {
            throw ValidationException::withMessages([
                'current_password' => ['كلمة المرور الحالية غير صحيحة'],
            ]);
        }

        $request->user()->update([
            'password' => Hash::make($validated['password']),
        ]);

        return response()->json([
            'message' => 'تم تغيير كلمة المرور بنجاح',
        ]);
    }

    /**
     * إرسال OTP إلى رقم الهاتف
     */
    public function sendOTP(Request $request, FirebaseService $firebase): JsonResponse
    {
        $validated = $request->validate([
            'phone_number' => 'required|string',
        ]);

        $result = $firebase->sendOTP($validated['phone_number']);

        if (!$result['success']) {
            return response()->json([
                'success' => false,
                'message' => $result['error'],
            ], 400);
        }

        return response()->json([
            'success' => true,
            'message' => $result['message'],
            'otp' => $result['otp'] ?? null, // فقط في التطوير
        ]);
    }

    /**
     * التحقق من OTP
     * يدعم كلا الشكلين: phone/code و phone_number/otp
     */
    public function verifyOTP(Request $request, FirebaseService $firebase): JsonResponse
    {
        // دعم كلا الشكلين من المعاملات
        $phoneNumber = $request->input('phone') ?? $request->input('phone_number');
        $otpCode = $request->input('code') ?? $request->input('otp');

        if (empty($phoneNumber) || empty($otpCode)) {
            return response()->json([
                'success' => false,
                'message' => 'رقم الهاتف ورمز التحقق مطلوبان',
            ], 422);
        }

        $result = $firebase->verifyOTP($phoneNumber, $otpCode);

        if (!$result['success']) {
            return response()->json([
                'success' => false,
                'message' => $result['error'] ?? 'رمز التحقق غير صحيح',
            ], 400);
        }

        // البحث عن المستخدم أو إنشاؤه
        $user = User::firstOrCreate(
            ['phone_number' => $phoneNumber],
            [
                'name' => 'User ' . substr($phoneNumber, -4),
                'email' => preg_replace('/[^0-9]/', '', $phoneNumber) . '@socialmedia.app',
                'password' => Hash::make(str()->random(32)),
                'user_type' => 'individual',
                'is_phone_verified' => true,
                'is_active' => true,
            ]
        );

        // تحديث حالة التحقق
        $user->update([
            'is_phone_verified' => true,
            'is_active' => true,
            'last_login_at' => now(),
        ]);

        // إنشاء token
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'تم التحقق بنجاح',
            'user' => $user,
            'access_token' => $token,
            'token_type' => 'Bearer',
        ]);
    }

    /**
     * التحقق من إمكانية إعادة إرسال OTP
     */
    public function canResendOTP(Request $request, FirebaseService $firebase): JsonResponse
    {
        $validated = $request->validate([
            'phone' => 'required|string',
        ]);

        $result = $firebase->canResend($validated['phone']);

        return response()->json($result);
    }

    /**
     * الحصول على إعدادات Firebase للـ Frontend
     */
    public function getFirebaseConfig(FirebaseService $firebase): JsonResponse
    {
        $config = $firebase->getFirebaseConfig();

        if (empty($config)) {
            return response()->json([
                'message' => 'Firebase غير مفعّل',
                'enabled' => false,
            ]);
        }

        return response()->json([
            'enabled' => true,
            'config' => $config,
        ]);
    }
}
