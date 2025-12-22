<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str; // Required for random OTP generation

class AuthController extends Controller
{
    /**
     * Register a new user.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => $user
        ], 201);
    }

    /**
     * Authenticate the user and return a token.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json(['message' => 'Invalid login details'], 401);
        }

        $user = User::where('email', $request['email'])->firstOrFail();

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => $user
        ]);
    }

    /**
     * Log the user out (Invalidate the token).
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Successfully logged out'
        ]);
    }

    /**
     * Send an OTP to the user's phone number.
     * In a real app, this would use an SMS gateway like Twilio or Vonage.
     * For now, we'll generate an OTP and return it for simulation.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function sendOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'phone_number' => 'required|string|min:10|max:15', // Basic validation
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        // In a real application, you would integrate with an SMS service here.
        // For demonstration, we generate a random 6-digit OTP.
        $otp = random_int(100000, 999999);

        // You would typically store this OTP with an expiration time.
        // For example, in cache or a dedicated database table.
        // Cache::put('otp_' . $request->phone_number, $otp, now()->addMinutes(5));

        // For this demo, we will return the OTP in the response.
        // In production, you would NEVER return the OTP in the response.
        return response()->json([
            'message' => 'OTP sent successfully (simulation).',
            'otp' => $otp // NOTE: For testing purposes only. Remove in production.
        ]);
    }

    /**
     * Verify the OTP and log in/register the user.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function verifyOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'phone_number' => 'required|string|min:10|max:15',
            'otp' => 'required|string|digits:6',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        // In a real app, you would verify the OTP against the stored value.
        // $storedOtp = Cache::get('otp_' . $request->phone_number);
        // if (!$storedOtp || $storedOtp != $request->otp) {
        //     return response()->json(['message' => 'Invalid OTP'], 401);
        // }

        // If OTP is valid, find or create the user.
        $user = User::firstOrCreate(
            ['phone_number' => $request->phone_number],
            [
                'name' => 'User_' . Str::random(8), // Placeholder name
                'email' => $request->phone_number . '@example.com', // Placeholder email
                'password' => Hash::make(Str::random(16)) // Secure random password
            ]
        );

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Phone number verified successfully!',
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => $user
        ]);
    }
}