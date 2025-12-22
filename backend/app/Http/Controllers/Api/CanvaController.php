<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\CanvaService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Auth;
use Exception;

class CanvaController extends Controller
{
    protected CanvaService $canvaService;

    public function __construct(CanvaService $canvaService)
    {
        $this->canvaService = $canvaService;
    }

    /**
     * Check service status
     */
    public function status(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'configured' => $this->canvaService->isConfigured(),
            'provider' => 'canva',
            'dimensions' => $this->canvaService->getAvailableDimensions(),
            'categories' => $this->canvaService->getTemplateCategories(),
            'scopes' => $this->canvaService->getAvailableScopes(),
        ]);
    }

    /**
     * Get OAuth authorization URL with PKCE
     */
    public function authorize(Request $request): JsonResponse
    {
        try {
            if (!$this->canvaService->isConfigured()) {
                return response()->json([
                    'success' => false,
                    'error' => 'Canva is not configured. Please add CANVA_CLIENT_ID and CANVA_CLIENT_SECRET to your environment.',
                ], 400);
            }

            // Get requested scopes or use defaults
            $scopes = $request->scopes ?? null;

            // Generate authorization URL with PKCE
            $authData = $this->canvaService->getAuthorizationUrlWithPKCE($scopes);

            // Store code_verifier and state securely (in cache, associated with user)
            $user = Auth::user();
            $cacheKey = "canva_pkce_{$user->id}";

            Cache::put($cacheKey, [
                'code_verifier' => $authData['code_verifier'],
                'state' => $authData['state'],
                'scopes' => $authData['scopes'],
            ], now()->addMinutes(15)); // 15 minutes expiry

            return response()->json([
                'success' => true,
                'authorization_url' => $authData['authorization_url'],
                'state' => $authData['state'],
                'redirect_uri' => $this->canvaService->getRedirectUri(),
                'scopes' => $authData['scopes'],
            ]);
        } catch (Exception $e) {
            Log::error('Canva authorization error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Handle OAuth callback with PKCE
     */
    public function callback(Request $request): JsonResponse
    {
        try {
            // Check for error from Canva
            if ($request->has('error')) {
                return response()->json([
                    'success' => false,
                    'error' => $request->error,
                    'error_description' => $request->error_description ?? 'Authorization failed',
                ], 400);
            }

            $request->validate([
                'code' => 'required|string',
                'state' => 'required|string',
            ]);

            $code = $request->code;
            $state = $request->state;

            // Get user from state or session
            $user = Auth::user();

            if (!$user) {
                // Try to find user by state in cache
                $userId = Cache::get("canva_state_user_{$state}");
                if ($userId) {
                    $user = \App\Models\User::find($userId);
                }
            }

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'error' => 'User not authenticated. Please login and try again.',
                ], 401);
            }

            // Retrieve stored PKCE data
            $cacheKey = "canva_pkce_{$user->id}";
            $pkceData = Cache::get($cacheKey);

            if (!$pkceData) {
                return response()->json([
                    'success' => false,
                    'error' => 'Authorization session expired. Please try again.',
                ], 400);
            }

            // Verify state to prevent CSRF
            if ($pkceData['state'] !== $state) {
                return response()->json([
                    'success' => false,
                    'error' => 'Invalid state parameter. Authorization flow may have been compromised.',
                ], 400);
            }

            // Exchange code for token with code_verifier
            $result = $this->canvaService->exchangeCodeForToken($code, $pkceData['code_verifier']);

            if ($result['success']) {
                // Store tokens for the user
                $user->update([
                    'canva_access_token' => encrypt($result['access_token']),
                    'canva_refresh_token' => $result['refresh_token'] ? encrypt($result['refresh_token']) : null,
                    'canva_token_expires_at' => now()->addSeconds($result['expires_in']),
                    'canva_scopes' => $result['scope'] ?? implode(' ', $pkceData['scopes']),
                ]);

                // Clear PKCE cache
                Cache::forget($cacheKey);

                Log::info('Canva connected successfully', ['user_id' => $user->id]);

                return response()->json([
                    'success' => true,
                    'message' => 'Canva connected successfully',
                    'expires_in' => $result['expires_in'],
                ]);
            }

            throw new Exception('Failed to exchange authorization code');
        } catch (Exception $e) {
            Log::error('Canva callback error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Store user ID with state for callback (for mobile/SPA apps)
     */
    public function storeStateUser(Request $request): JsonResponse
    {
        $request->validate([
            'state' => 'required|string',
        ]);

        $user = Auth::user();
        Cache::put("canva_state_user_{$request->state}", $user->id, now()->addMinutes(15));

        return response()->json(['success' => true]);
    }

    /**
     * Disconnect Canva account
     */
    public function disconnect(Request $request): JsonResponse
    {
        try {
            $user = Auth::user();

            // Revoke token if possible
            if ($user->canva_access_token) {
                try {
                    $this->canvaService->revokeToken(decrypt($user->canva_access_token));
                } catch (Exception $e) {
                    // Log but continue with disconnect
                    Log::warning('Failed to revoke Canva token', ['error' => $e->getMessage()]);
                }
            }

            // Clear tokens from user
            $user->update([
                'canva_access_token' => null,
                'canva_refresh_token' => null,
                'canva_token_expires_at' => null,
                'canva_scopes' => null,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Canva disconnected successfully',
            ]);
        } catch (Exception $e) {
            Log::error('Canva disconnect error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Check connection status
     */
    public function connectionStatus(Request $request): JsonResponse
    {
        $user = Auth::user();

        $isConnected = !empty($user->canva_access_token);
        $isExpired = $user->canva_token_expires_at && $user->canva_token_expires_at < now();

        return response()->json([
            'success' => true,
            'connected' => $isConnected && !$isExpired,
            'expired' => $isExpired,
            'scopes' => $user->canva_scopes ?? null,
            'expires_at' => $user->canva_token_expires_at,
        ]);
    }

    /**
     * Get user's Canva profile
     */
    public function profile(Request $request): JsonResponse
    {
        try {
            $accessToken = $this->getUserAccessToken($request);
            $result = $this->canvaService->getUserProfile($accessToken);

            return response()->json($result);
        } catch (Exception $e) {
            Log::error('Canva profile error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], $this->getErrorStatusCode($e));
        }
    }

    /**
     * List user's designs
     */
    public function listDesigns(Request $request): JsonResponse
    {
        try {
            $accessToken = $this->getUserAccessToken($request);
            $result = $this->canvaService->listDesigns($accessToken, [
                'limit' => $request->limit ?? 50,
                'continuation' => $request->continuation,
            ]);

            return response()->json($result);
        } catch (Exception $e) {
            Log::error('Canva list designs error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], $this->getErrorStatusCode($e));
        }
    }

    /**
     * Get specific design
     */
    public function getDesign(Request $request, string $designId): JsonResponse
    {
        try {
            $accessToken = $this->getUserAccessToken($request);
            $result = $this->canvaService->getDesign($accessToken, $designId);

            if ($result['success']) {
                $result['edit_url'] = $this->canvaService->getEditUrl($designId);
                $result['view_url'] = $this->canvaService->getViewUrl($designId);
            }

            return response()->json($result);
        } catch (Exception $e) {
            Log::error('Canva get design error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], $this->getErrorStatusCode($e));
        }
    }

    /**
     * Create new design
     */
    public function createDesign(Request $request): JsonResponse
    {
        $request->validate([
            'type' => 'required|string',
            'title' => 'string|max:255',
        ]);

        try {
            $accessToken = $this->getUserAccessToken($request);
            $result = $this->canvaService->createDesign($accessToken, [
                'type' => $request->type,
                'title' => $request->title,
            ]);

            if ($result['success'] && isset($result['data']['design']['id'])) {
                $designId = $result['data']['design']['id'];
                $result['edit_url'] = $this->canvaService->getEditUrl($designId);
            }

            return response()->json($result);
        } catch (Exception $e) {
            Log::error('Canva create design error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], $this->getErrorStatusCode($e));
        }
    }

    /**
     * Quick create social media design
     */
    public function quickCreate(Request $request): JsonResponse
    {
        $request->validate([
            'platform' => 'required|string|in:instagram,facebook,twitter,linkedin,youtube,tiktok,pinterest',
            'content_type' => 'required|string|in:post,story,reel,cover,header,banner,thumbnail,video,pin',
            'title' => 'string|max:255',
        ]);

        try {
            $accessToken = $this->getUserAccessToken($request);
            $result = $this->canvaService->quickCreateSocialDesign($accessToken, [
                'platform' => $request->platform,
                'content_type' => $request->content_type,
                'title' => $request->title,
            ]);

            return response()->json($result);
        } catch (Exception $e) {
            Log::error('Canva quick create error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], $this->getErrorStatusCode($e));
        }
    }

    /**
     * Create design from template
     */
    public function createFromTemplate(Request $request): JsonResponse
    {
        $request->validate([
            'template_id' => 'required|string',
            'title' => 'string|max:255',
        ]);

        try {
            $accessToken = $this->getUserAccessToken($request);
            $result = $this->canvaService->createFromTemplate($accessToken, $request->template_id, [
                'title' => $request->title,
            ]);

            if ($result['success'] && isset($result['data']['design']['id'])) {
                $designId = $result['data']['design']['id'];
                $result['edit_url'] = $this->canvaService->getEditUrl($designId);
            }

            return response()->json($result);
        } catch (Exception $e) {
            Log::error('Canva create from template error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], $this->getErrorStatusCode($e));
        }
    }

    /**
     * Search templates
     */
    public function searchTemplates(Request $request): JsonResponse
    {
        $request->validate([
            'query' => 'string|max:200',
            'type' => 'string',
            'limit' => 'integer|min:1|max:100',
        ]);

        try {
            $accessToken = $this->getUserAccessToken($request);
            $result = $this->canvaService->searchTemplates($accessToken, [
                'query' => $request->query('query', ''),
                'type' => $request->type,
                'limit' => $request->limit ?? 20,
            ]);

            return response()->json($result);
        } catch (Exception $e) {
            Log::error('Canva search templates error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], $this->getErrorStatusCode($e));
        }
    }

    /**
     * Export design
     */
    public function exportDesign(Request $request, string $designId): JsonResponse
    {
        $request->validate([
            'format' => 'string|in:png,jpg,pdf,mp4,gif',
            'quality' => 'string|in:regular,print',
            'pages' => 'array',
        ]);

        try {
            $accessToken = $this->getUserAccessToken($request);
            $result = $this->canvaService->exportDesign($accessToken, $designId, [
                'format' => $request->format ?? 'png',
                'quality' => $request->quality ?? 'regular',
                'pages' => $request->pages,
            ]);

            return response()->json($result);
        } catch (Exception $e) {
            Log::error('Canva export design error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], $this->getErrorStatusCode($e));
        }
    }

    /**
     * Get export status
     */
    public function getExportStatus(Request $request, string $exportId): JsonResponse
    {
        try {
            $accessToken = $this->getUserAccessToken($request);
            $result = $this->canvaService->getExportStatus($accessToken, $exportId);

            return response()->json($result);
        } catch (Exception $e) {
            Log::error('Canva export status error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], $this->getErrorStatusCode($e));
        }
    }

    /**
     * Export and wait for download URL
     */
    public function exportAndDownload(Request $request, string $designId): JsonResponse
    {
        $request->validate([
            'format' => 'string|in:png,jpg,pdf,mp4,gif',
            'quality' => 'string|in:regular,print',
        ]);

        try {
            $accessToken = $this->getUserAccessToken($request);

            // Start export
            $exportResult = $this->canvaService->exportDesign($accessToken, $designId, [
                'format' => $request->format ?? 'png',
                'quality' => $request->quality ?? 'regular',
            ]);

            if (!$exportResult['success']) {
                throw new Exception('Failed to start export');
            }

            $exportId = $exportResult['data']['job']['id'];

            // Wait for completion
            $downloadResult = $this->canvaService->waitForExport($accessToken, $exportId);

            return response()->json($downloadResult);
        } catch (Exception $e) {
            Log::error('Canva export and download error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], $this->getErrorStatusCode($e));
        }
    }

    /**
     * Upload asset
     */
    public function uploadAsset(Request $request): JsonResponse
    {
        $request->validate([
            'file' => 'required|file|mimes:jpg,jpeg,png,gif,svg,mp4,webm|max:100000',
            'name' => 'string|max:255',
        ]);

        try {
            $accessToken = $this->getUserAccessToken($request);
            $file = $request->file('file');

            $result = $this->canvaService->uploadAsset($accessToken, $file->getPathname(), [
                'name' => $request->name ?? $file->getClientOriginalName(),
                'filename' => $file->getClientOriginalName(),
            ]);

            return response()->json($result);
        } catch (Exception $e) {
            Log::error('Canva upload asset error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], $this->getErrorStatusCode($e));
        }
    }

    /**
     * Upload asset from URL
     */
    public function uploadAssetFromUrl(Request $request): JsonResponse
    {
        $request->validate([
            'url' => 'required|url',
            'name' => 'string|max:255',
        ]);

        try {
            $accessToken = $this->getUserAccessToken($request);
            $result = $this->canvaService->uploadAssetFromUrl($accessToken, $request->url, [
                'name' => $request->name ?? 'Uploaded Asset',
            ]);

            return response()->json($result);
        } catch (Exception $e) {
            Log::error('Canva upload asset from URL error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], $this->getErrorStatusCode($e));
        }
    }

    /**
     * List folders
     */
    public function listFolders(Request $request): JsonResponse
    {
        try {
            $accessToken = $this->getUserAccessToken($request);
            $result = $this->canvaService->listFolders($accessToken, [
                'limit' => $request->limit ?? 50,
            ]);

            return response()->json($result);
        } catch (Exception $e) {
            Log::error('Canva list folders error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], $this->getErrorStatusCode($e));
        }
    }

    /**
     * Create folder
     */
    public function createFolder(Request $request): JsonResponse
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'parent_id' => 'string',
        ]);

        try {
            $accessToken = $this->getUserAccessToken($request);
            $result = $this->canvaService->createFolder($accessToken, $request->name, $request->parent_id);

            return response()->json($result);
        } catch (Exception $e) {
            Log::error('Canva create folder error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], $this->getErrorStatusCode($e));
        }
    }

    /**
     * Get brand templates
     */
    public function getBrandTemplates(Request $request): JsonResponse
    {
        try {
            $accessToken = $this->getUserAccessToken($request);
            $result = $this->canvaService->getBrandTemplates($accessToken, [
                'limit' => $request->limit ?? 50,
            ]);

            return response()->json($result);
        } catch (Exception $e) {
            Log::error('Canva brand templates error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], $this->getErrorStatusCode($e));
        }
    }

    /**
     * Autofill design with data
     */
    public function autofillDesign(Request $request, string $designId): JsonResponse
    {
        $request->validate([
            'data' => 'required|array',
        ]);

        try {
            $accessToken = $this->getUserAccessToken($request);
            $result = $this->canvaService->autofillDesign($accessToken, $designId, $request->data);

            return response()->json($result);
        } catch (Exception $e) {
            Log::error('Canva autofill design error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], $this->getErrorStatusCode($e));
        }
    }

    /**
     * Get available dimensions
     */
    public function getDimensions(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'dimensions' => $this->canvaService->getAvailableDimensions(),
        ]);
    }

    /**
     * Get template categories
     */
    public function getCategories(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'categories' => $this->canvaService->getTemplateCategories(),
        ]);
    }

    /**
     * Get user's access token from request or database
     */
    protected function getUserAccessToken(Request $request): string
    {
        // Check if token is provided in request header
        if ($request->hasHeader('X-Canva-Token')) {
            return $request->header('X-Canva-Token');
        }

        // Get from authenticated user
        $user = Auth::user();
        if (!$user) {
            throw new Exception('User not authenticated');
        }

        if (!$user->canva_access_token) {
            throw new Exception('Canva not connected. Please authorize your Canva account first.');
        }

        // Check if token is expired
        if ($user->canva_token_expires_at && $user->canva_token_expires_at < now()) {
            // Try to refresh
            if ($user->canva_refresh_token) {
                try {
                    $refreshResult = $this->canvaService->refreshToken(decrypt($user->canva_refresh_token));
                    if ($refreshResult['success']) {
                        $user->update([
                            'canva_access_token' => encrypt($refreshResult['access_token']),
                            'canva_refresh_token' => $refreshResult['refresh_token'] ? encrypt($refreshResult['refresh_token']) : $user->canva_refresh_token,
                            'canva_token_expires_at' => now()->addSeconds($refreshResult['expires_in']),
                        ]);
                        return $refreshResult['access_token'];
                    }
                } catch (Exception $e) {
                    Log::error('Failed to refresh Canva token', ['error' => $e->getMessage()]);
                }
            }
            throw new Exception('Canva token expired. Please reconnect your Canva account.');
        }

        return decrypt($user->canva_access_token);
    }

    /**
     * Get appropriate HTTP status code for error
     */
    protected function getErrorStatusCode(Exception $e): int
    {
        $message = strtolower($e->getMessage());

        if (str_contains($message, 'not authenticated') || str_contains($message, 'not connected')) {
            return 401;
        }

        if (str_contains($message, 'expired')) {
            return 401;
        }

        if (str_contains($message, 'not configured')) {
            return 503;
        }

        return 500;
    }
}
