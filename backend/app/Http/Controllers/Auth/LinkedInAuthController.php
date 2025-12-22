<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class LinkedInAuthController extends Controller
{
    /**
     * LinkedIn OAuth credentials
     */
    private string $clientId = '771flta29hpfws';
    private string $clientSecret = 'WPL_AP1.oiphgRU2qvIm7NiB.++u//w==';
    private string $redirectUri = 'https://mediaprosocial.io/api/auth/linkedin/callback';

    /**
     * Handle LinkedIn OAuth callback
     * This is called by LinkedIn after the user authorizes the app
     */
    public function callback(Request $request)
    {
        Log::info('LinkedIn OAuth callback received', $request->all());

        // Check for error
        if ($request->has('error')) {
            Log::error('LinkedIn OAuth error', [
                'error' => $request->input('error'),
                'description' => $request->input('error_description'),
            ]);

            return response()->json([
                'success' => false,
                'error' => $request->input('error'),
                'error_description' => $request->input('error_description'),
            ], 400);
        }

        // Get authorization code
        $code = $request->input('code');
        if (!$code) {
            return response()->json([
                'success' => false,
                'error' => 'No authorization code received',
            ], 400);
        }

        try {
            // Exchange code for access token
            $tokenResponse = Http::asForm()->post('https://www.linkedin.com/oauth/v2/accessToken', [
                'grant_type' => 'authorization_code',
                'code' => $code,
                'redirect_uri' => $this->redirectUri,
                'client_id' => $this->clientId,
                'client_secret' => $this->clientSecret,
            ]);

            if (!$tokenResponse->successful()) {
                Log::error('LinkedIn token exchange failed', [
                    'status' => $tokenResponse->status(),
                    'body' => $tokenResponse->body(),
                ]);

                return response()->json([
                    'success' => false,
                    'error' => 'Failed to exchange code for token',
                    'details' => $tokenResponse->json(),
                ], 400);
            }

            $tokenData = $tokenResponse->json();
            $accessToken = $tokenData['access_token'] ?? null;

            if (!$accessToken) {
                return response()->json([
                    'success' => false,
                    'error' => 'No access token received',
                ], 400);
            }

            // Get user profile using OpenID Connect userinfo endpoint
            $profileResponse = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
            ])->get('https://api.linkedin.com/v2/userinfo');

            if (!$profileResponse->successful()) {
                Log::error('LinkedIn profile fetch failed', [
                    'status' => $profileResponse->status(),
                    'body' => $profileResponse->body(),
                ]);

                return response()->json([
                    'success' => false,
                    'error' => 'Failed to fetch user profile',
                    'details' => $profileResponse->json(),
                ], 400);
            }

            $profile = $profileResponse->json();

            Log::info('LinkedIn OAuth successful', [
                'user_id' => $profile['sub'] ?? 'unknown',
                'name' => $profile['name'] ?? 'unknown',
            ]);

            // Return success with user data
            // The Flutter app will handle this response
            return response()->json([
                'success' => true,
                'access_token' => $accessToken,
                'expires_in' => $tokenData['expires_in'] ?? 3600,
                'id' => $profile['sub'] ?? null,
                'name' => $profile['name'] ?? null,
                'email' => $profile['email'] ?? null,
                'picture' => $profile['picture'] ?? null,
                'vanity_name' => $profile['vanity_name'] ?? null,
            ]);

        } catch (\Exception $e) {
            Log::error('LinkedIn OAuth exception', [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'success' => false,
                'error' => 'An error occurred during authentication',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Initiate LinkedIn OAuth flow
     * Redirects the user to LinkedIn's authorization page
     */
    public function redirect()
    {
        $scopes = ['openid', 'profile', 'email', 'w_member_social'];
        $state = bin2hex(random_bytes(16));

        session(['linkedin_oauth_state' => $state]);

        $params = http_build_query([
            'response_type' => 'code',
            'client_id' => $this->clientId,
            'redirect_uri' => $this->redirectUri,
            'scope' => implode(' ', $scopes),
            'state' => $state,
        ]);

        return redirect('https://www.linkedin.com/oauth/v2/authorization?' . $params);
    }
}
