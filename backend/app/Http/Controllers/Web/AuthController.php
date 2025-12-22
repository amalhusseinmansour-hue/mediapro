<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class AuthController extends Controller
{
    /**
     * Show the registration form
     */
    public function showRegisterForm()
    {
        return view('auth.register');
    }

    /**
     * Show the login form
     */
    public function showLoginForm()
    {
        return view('auth.login');
    }

    /**
     * Handle user registration
     */
    public function register(Request $request)
    {
        try {
            // Validate input
            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:255',
                'email' => 'required|string|email|max:255|unique:users',
                'password' => 'required|string|min:8|confirmed',
                'phone' => 'nullable|string|max:20',
            ], [
                'name.required' => 'الاسم مطلوب',
                'email.required' => 'البريد الإلكتروني مطلوب',
                'email.email' => 'البريد الإلكتروني غير صحيح',
                'email.unique' => 'البريد الإلكتروني مستخدم بالفعل',
                'password.required' => 'كلمة المرور مطلوبة',
                'password.min' => 'كلمة المرور يجب أن تكون 8 أحرف على الأقل',
                'password.confirmed' => 'كلمة المرور غير متطابقة',
            ]);

            if ($validator->fails()) {
                return back()->withErrors($validator)->withInput();
            }

            DB::beginTransaction();

            try {
                // Create user
                $user = User::create([
                    'name' => $request->name,
                    'email' => $request->email,
                    'password' => Hash::make($request->password),
                    'phone' => $request->phone,
                    'is_email_verified' => false,
                    'is_phone_verified' => false,
                    'is_active' => true,
                    'profile_completed' => false,
                ]);

                // Create wallet for user
                Wallet::create([
                    'user_id' => $user->id,
                    'balance' => 0.00,
                    'currency' => 'USD',
                ]);

                // Log user in
                Auth::login($user);

                DB::commit();

                // Redirect to dashboard
                return redirect()->route('dashboard')->with('success', 'تم إنشاء حسابك بنجاح! مرحباً بك');

            } catch (\Exception $e) {
                DB::rollBack();
                Log::error('User registration error', [
                    'error' => $e->getMessage(),
                    'trace' => $e->getTraceAsString()
                ]);
                return back()->with('error', 'حدث خطأ أثناء إنشاء الحساب. يرجى المحاولة مرة أخرى')->withInput();
            }

        } catch (\Exception $e) {
            Log::error('Registration validation error', [
                'error' => $e->getMessage()
            ]);
            return back()->with('error', 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى')->withInput();
        }
    }

    /**
     * Handle user login
     */
    public function login(Request $request)
    {
        try {
            // Validate input
            $validator = Validator::make($request->all(), [
                'email' => 'required|email',
                'password' => 'required|string',
            ], [
                'email.required' => 'البريد الإلكتروني مطلوب',
                'email.email' => 'البريد الإلكتروني غير صحيح',
                'password.required' => 'كلمة المرور مطلوبة',
            ]);

            if ($validator->fails()) {
                return back()->withErrors($validator)->withInput();
            }

            // Attempt login
            $credentials = [
                'email' => $request->email,
                'password' => $request->password,
            ];

            $remember = $request->has('remember');

            if (Auth::attempt($credentials, $remember)) {
                $request->session()->regenerate();

                // Check if user is active
                if (!Auth::user()->is_active) {
                    Auth::logout();
                    return back()->with('error', 'حسابك غير نشط. يرجى التواصل مع الدعم');
                }

                return redirect()->intended(route('dashboard'));
            }

            return back()->with('error', 'بيانات الدخول غير صحيحة')->withInput($request->only('email'));

        } catch (\Exception $e) {
            Log::error('Login error', [
                'error' => $e->getMessage()
            ]);
            return back()->with('error', 'حدث خطأ أثناء تسجيل الدخول')->withInput();
        }
    }

    /**
     * Handle user logout
     */
    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect('/')->with('success', 'تم تسجيل الخروج بنجاح');
    }
}
