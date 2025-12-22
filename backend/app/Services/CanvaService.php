<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;
use Exception;

/**
 * Canva Service - خدمة تكامل Canva للتصميم
 * OAuth 2.0 with PKCE (Proof Key for Code Exchange)
 *
 * تدعم:
 * - OAuth 2.0 مع PKCE
 * - إنشاء تصميمات من القوالب
 * - تحرير التصميمات
 * - تصدير التصميمات
 * - إدارة المجلدات والأصول
 */
class CanvaService
{
    protected string $clientId;
    protected string $clientSecret;
    protected string $redirectUri;
    protected string $baseUrl = 'https://api.canva.com/rest/v1';
    protected string $authUrl = 'https://www.canva.com/api/oauth/authorize';
    protected string $tokenUrl = 'https://api.canva.com/rest/v1/oauth/token';

    // Available scopes
    protected array $availableScopes = [
        'asset:read',
        'asset:write',
        'brandtemplate:content:read',
        'brandtemplate:meta:read',
        'design:content:read',
        'design:content:write',
        'design:meta:read',
        'folder:read',
        'folder:write',
        'profile:read',
    ];

    // Template categories for social media
    protected array $templateCategories = [
        'instagram_post' => 'Instagram Post',
        'instagram_story' => 'Instagram Story',
        'instagram_reel' => 'Instagram Reel Cover',
        'facebook_post' => 'Facebook Post',
        'facebook_cover' => 'Facebook Cover',
        'twitter_post' => 'Twitter Post',
        'twitter_header' => 'Twitter Header',
        'linkedin_post' => 'LinkedIn Post',
        'linkedin_banner' => 'LinkedIn Banner',
        'youtube_thumbnail' => 'YouTube Thumbnail',
        'tiktok_video' => 'TikTok Video',
        'pinterest_pin' => 'Pinterest Pin',
    ];

    // Design dimensions for each platform
    protected array $designDimensions = [
        'instagram_post' => ['width' => 1080, 'height' => 1080],
        'instagram_story' => ['width' => 1080, 'height' => 1920],
        'instagram_reel' => ['width' => 1080, 'height' => 1920],
        'facebook_post' => ['width' => 1200, 'height' => 630],
        'facebook_cover' => ['width' => 820, 'height' => 312],
        'facebook_story' => ['width' => 1080, 'height' => 1920],
        'twitter_post' => ['width' => 1200, 'height' => 675],
        'twitter_header' => ['width' => 1500, 'height' => 500],
        'linkedin_post' => ['width' => 1200, 'height' => 627],
        'linkedin_banner' => ['width' => 1584, 'height' => 396],
        'youtube_thumbnail' => ['width' => 1280, 'height' => 720],
        'tiktok_video' => ['width' => 1080, 'height' => 1920],
        'pinterest_pin' => ['width' => 1000, 'height' => 1500],
    ];

    public function __construct()
    {
        $this->clientId = env('CANVA_CLIENT_ID', '');
        $this->clientSecret = env('CANVA_CLIENT_SECRET', '');
        $this->redirectUri = env('CANVA_REDIRECT_URI', config('app.url') . '/api/canva/callback');
    }

    /**
     * Check if service is configured
     */
    public function isConfigured(): bool
    {
        return !empty($this->clientId) && !empty($this->clientSecret);
    }

    // ============================================
    // PKCE OAuth 2.0 Methods
    // ============================================

    /**
     * Generate a cryptographically random code verifier
     * Must be 43-128 characters, using only ASCII letters, numbers, and -._~
     */
    public function generateCodeVerifier(): string
    {
        // Generate 96 random bytes and convert to URL-safe base64
        $randomBytes = random_bytes(96);
        return rtrim(strtr(base64_encode($randomBytes), '+/', '-_'), '=');
    }

    /**
     * Generate code challenge from code verifier using SHA-256
     */
    public function generateCodeChallenge(string $codeVerifier): string
    {
        $hash = hash('sha256', $codeVerifier, true);
        return rtrim(strtr(base64_encode($hash), '+/', '-_'), '=');
    }

    /**
     * Generate a cryptographically random state string
     */
    public function generateState(): string
    {
        $randomBytes = random_bytes(32);
        return rtrim(strtr(base64_encode($randomBytes), '+/', '-_'), '=');
    }

    /**
     * Get OAuth authorization URL with PKCE
     * Returns URL and the code_verifier that must be stored securely
     */
    public function getAuthorizationUrlWithPKCE(array $scopes = null, string $state = null): array
    {
        // Generate PKCE values
        $codeVerifier = $this->generateCodeVerifier();
        $codeChallenge = $this->generateCodeChallenge($codeVerifier);
        $state = $state ?? $this->generateState();

        // Default scopes if not provided
        if ($scopes === null) {
            $scopes = [
                'asset:read',
                'asset:write',
                'design:content:read',
                'design:content:write',
                'design:meta:read',
                'folder:read',
                'folder:write',
                'profile:read',
            ];
        }

        $params = http_build_query([
            'client_id' => $this->clientId,
            'redirect_uri' => $this->redirectUri,
            'response_type' => 'code',
            'code_challenge' => $codeChallenge,
            'code_challenge_method' => 'S256',
            'scope' => implode(' ', $scopes),
            'state' => $state,
        ]);

        return [
            'authorization_url' => "{$this->authUrl}?{$params}",
            'code_verifier' => $codeVerifier,
            'state' => $state,
            'scopes' => $scopes,
        ];
    }

    /**
     * Exchange authorization code for access token (with PKCE)
     */
    public function exchangeCodeForToken(string $code, string $codeVerifier): array
    {
        try {
            // Create Basic Auth header
            $credentials = base64_encode("{$this->clientId}:{$this->clientSecret}");

            $response = Http::withHeaders([
                'Authorization' => 'Basic ' . $credentials,
                'Content-Type' => 'application/x-www-form-urlencoded',
            ])->asForm()->post($this->tokenUrl, [
                'grant_type' => 'authorization_code',
                'code' => $code,
                'code_verifier' => $codeVerifier,
                'redirect_uri' => $this->redirectUri,
            ]);

            if ($response->successful()) {
                $data = $response->json();

                Log::info('Canva: Token exchanged successfully via PKCE');

                return [
                    'success' => true,
                    'access_token' => $data['access_token'],
                    'refresh_token' => $data['refresh_token'] ?? null,
                    'expires_in' => $data['expires_in'],
                    'token_type' => $data['token_type'],
                    'scope' => $data['scope'] ?? null,
                ];
            }

            $error = $response->json();
            Log::error('Canva token exchange failed', ['response' => $error]);
            throw new Exception('Failed to exchange token: ' . ($error['error_description'] ?? $response->body()));
        } catch (Exception $e) {
            Log::error('Canva token exchange error', ['error' => $e->getMessage()]);
            throw $e;
        }
    }

    /**
     * Refresh access token
     */
    public function refreshToken(string $refreshToken): array
    {
        try {
            // Create Basic Auth header
            $credentials = base64_encode("{$this->clientId}:{$this->clientSecret}");

            $response = Http::withHeaders([
                'Authorization' => 'Basic ' . $credentials,
                'Content-Type' => 'application/x-www-form-urlencoded',
            ])->asForm()->post($this->tokenUrl, [
                'grant_type' => 'refresh_token',
                'refresh_token' => $refreshToken,
            ]);

            if ($response->successful()) {
                $data = $response->json();

                Log::info('Canva: Token refreshed successfully');

                return [
                    'success' => true,
                    'access_token' => $data['access_token'],
                    'refresh_token' => $data['refresh_token'] ?? null,
                    'expires_in' => $data['expires_in'],
                    'token_type' => $data['token_type'],
                ];
            }

            throw new Exception('Failed to refresh token: ' . $response->body());
        } catch (Exception $e) {
            Log::error('Canva token refresh error', ['error' => $e->getMessage()]);
            throw $e;
        }
    }

    /**
     * Introspect an access token
     */
    public function introspectToken(string $token): array
    {
        try {
            $credentials = base64_encode("{$this->clientId}:{$this->clientSecret}");

            $response = Http::withHeaders([
                'Authorization' => 'Basic ' . $credentials,
                'Content-Type' => 'application/x-www-form-urlencoded',
            ])->asForm()->post("{$this->baseUrl}/oauth/introspect", [
                'token' => $token,
            ]);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json(),
                ];
            }

            throw new Exception('Failed to introspect token: ' . $response->body());
        } catch (Exception $e) {
            Log::error('Canva token introspect error', ['error' => $e->getMessage()]);
            throw $e;
        }
    }

    /**
     * Revoke a token
     */
    public function revokeToken(string $token): array
    {
        try {
            $credentials = base64_encode("{$this->clientId}:{$this->clientSecret}");

            $response = Http::withHeaders([
                'Authorization' => 'Basic ' . $credentials,
                'Content-Type' => 'application/x-www-form-urlencoded',
            ])->asForm()->post("{$this->baseUrl}/oauth/revoke", [
                'token' => $token,
            ]);

            if ($response->successful()) {
                Log::info('Canva: Token revoked successfully');
                return ['success' => true];
            }

            throw new Exception('Failed to revoke token: ' . $response->body());
        } catch (Exception $e) {
            Log::error('Canva token revoke error', ['error' => $e->getMessage()]);
            throw $e;
        }
    }

    // ============================================
    // API Request Methods
    // ============================================

    /**
     * Make authenticated API request
     */
    protected function apiRequest(string $method, string $endpoint, string $accessToken, array $data = []): array
    {
        try {
            $request = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'Content-Type' => 'application/json',
            ])->timeout(60);

            $url = "{$this->baseUrl}/{$endpoint}";

            $response = match (strtoupper($method)) {
                'GET' => $request->get($url, $data),
                'POST' => $request->post($url, $data),
                'PUT' => $request->put($url, $data),
                'PATCH' => $request->patch($url, $data),
                'DELETE' => $request->delete($url),
                default => throw new Exception("Unsupported HTTP method: {$method}"),
            };

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json(),
                ];
            }

            $error = $response->json();
            throw new Exception("Canva API error: " . ($error['message'] ?? $response->body()));
        } catch (Exception $e) {
            Log::error('Canva API request error', [
                'endpoint' => $endpoint,
                'error' => $e->getMessage(),
            ]);
            throw $e;
        }
    }

    // ============================================
    // User & Profile Methods
    // ============================================

    /**
     * Get user profile
     */
    public function getUserProfile(string $accessToken): array
    {
        return $this->apiRequest('GET', 'users/me', $accessToken);
    }

    // ============================================
    // Design Methods
    // ============================================

    /**
     * List user's designs
     */
    public function listDesigns(string $accessToken, array $options = []): array
    {
        $params = [
            'limit' => $options['limit'] ?? 50,
        ];

        if (isset($options['continuation'])) {
            $params['continuation'] = $options['continuation'];
        }

        return $this->apiRequest('GET', 'designs', $accessToken, $params);
    }

    /**
     * Get design by ID
     */
    public function getDesign(string $accessToken, string $designId): array
    {
        return $this->apiRequest('GET', "designs/{$designId}", $accessToken);
    }

    /**
     * Create a new design
     */
    public function createDesign(string $accessToken, array $options): array
    {
        $designType = $options['type'] ?? 'instagram_post';
        $dimensions = $this->designDimensions[$designType] ?? $this->designDimensions['instagram_post'];

        $data = [
            'design_type' => [
                'width' => $dimensions['width'],
                'height' => $dimensions['height'],
            ],
            'title' => $options['title'] ?? 'Untitled Design',
        ];

        if (isset($options['asset_id'])) {
            $data['asset_id'] = $options['asset_id'];
        }

        return $this->apiRequest('POST', 'designs', $accessToken, $data);
    }

    /**
     * Create design from template
     */
    public function createFromTemplate(string $accessToken, string $templateId, array $options = []): array
    {
        $data = [
            'template_id' => $templateId,
            'title' => $options['title'] ?? 'Design from Template',
        ];

        if (isset($options['brand_template_id'])) {
            $data['brand_template_id'] = $options['brand_template_id'];
        }

        return $this->apiRequest('POST', 'designs', $accessToken, $data);
    }

    /**
     * Search templates
     */
    public function searchTemplates(string $accessToken, array $options = []): array
    {
        $params = [
            'query' => $options['query'] ?? '',
            'limit' => $options['limit'] ?? 20,
        ];

        if (isset($options['type'])) {
            $category = $this->templateCategories[$options['type']] ?? null;
            if ($category) {
                $params['category'] = $category;
            }
        }

        return $this->apiRequest('GET', 'templates', $accessToken, $params);
    }

    // ============================================
    // Export Methods
    // ============================================

    /**
     * Export design
     */
    public function exportDesign(string $accessToken, string $designId, array $options = []): array
    {
        $format = $options['format'] ?? 'png';
        $quality = $options['quality'] ?? 'regular';

        $data = [
            'design_id' => $designId,
            'format' => [
                'type' => $format,
            ],
        ];

        if ($format === 'png' || $format === 'jpg') {
            $data['format']['quality'] = $quality;
            if (isset($options['pages'])) {
                $data['format']['pages'] = $options['pages'];
            }
        }

        if ($format === 'pdf') {
            $data['format']['size'] = $options['size'] ?? 'a4';
        }

        if ($format === 'mp4') {
            $data['format']['quality'] = $options['video_quality'] ?? '1080p';
        }

        return $this->apiRequest('POST', 'exports', $accessToken, $data);
    }

    /**
     * Get export status and download URL
     */
    public function getExportStatus(string $accessToken, string $exportId): array
    {
        return $this->apiRequest('GET', "exports/{$exportId}", $accessToken);
    }

    /**
     * Wait for export to complete and return download URL
     */
    public function waitForExport(string $accessToken, string $exportId, int $maxWaitSeconds = 120): array
    {
        $startTime = time();

        while (true) {
            $status = $this->getExportStatus($accessToken, $exportId);

            if (!$status['success']) {
                throw new Exception('Failed to get export status');
            }

            $exportStatus = $status['data']['status'] ?? 'unknown';

            if ($exportStatus === 'completed') {
                return [
                    'success' => true,
                    'download_url' => $status['data']['urls'][0]['url'] ?? null,
                    'urls' => $status['data']['urls'] ?? [],
                ];
            }

            if ($exportStatus === 'failed') {
                throw new Exception('Export failed: ' . ($status['data']['error']['message'] ?? 'Unknown error'));
            }

            if (time() - $startTime > $maxWaitSeconds) {
                throw new Exception('Export timeout after ' . $maxWaitSeconds . ' seconds');
            }

            sleep(2);
        }
    }

    // ============================================
    // Asset Methods
    // ============================================

    /**
     * Upload asset to Canva
     */
    public function uploadAsset(string $accessToken, string $filePath, array $options = []): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
            ])->attach(
                'file',
                file_get_contents($filePath),
                $options['filename'] ?? basename($filePath)
            )->post("{$this->baseUrl}/assets", [
                'name' => $options['name'] ?? basename($filePath),
            ]);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json(),
                ];
            }

            throw new Exception('Failed to upload asset: ' . $response->body());
        } catch (Exception $e) {
            Log::error('Canva asset upload error', ['error' => $e->getMessage()]);
            throw $e;
        }
    }

    /**
     * Upload asset from URL
     */
    public function uploadAssetFromUrl(string $accessToken, string $url, array $options = []): array
    {
        $data = [
            'url' => $url,
            'name' => $options['name'] ?? 'Uploaded Asset',
        ];

        return $this->apiRequest('POST', 'assets', $accessToken, $data);
    }

    // ============================================
    // Folder Methods
    // ============================================

    /**
     * List folders
     */
    public function listFolders(string $accessToken, array $options = []): array
    {
        $params = [
            'limit' => $options['limit'] ?? 50,
        ];

        return $this->apiRequest('GET', 'folders', $accessToken, $params);
    }

    /**
     * Create folder
     */
    public function createFolder(string $accessToken, string $name, string $parentId = null): array
    {
        $data = ['name' => $name];

        if ($parentId) {
            $data['parent_folder_id'] = $parentId;
        }

        return $this->apiRequest('POST', 'folders', $accessToken, $data);
    }

    /**
     * Move design to folder
     */
    public function moveDesignToFolder(string $accessToken, string $designId, string $folderId): array
    {
        return $this->apiRequest('POST', "folders/{$folderId}/items", $accessToken, [
            'item_id' => $designId,
            'item_type' => 'design',
        ]);
    }

    // ============================================
    // Brand Templates Methods
    // ============================================

    /**
     * Get brand templates
     */
    public function getBrandTemplates(string $accessToken, array $options = []): array
    {
        $params = [
            'limit' => $options['limit'] ?? 50,
        ];

        return $this->apiRequest('GET', 'brand-templates', $accessToken, $params);
    }

    // ============================================
    // Autofill Methods
    // ============================================

    /**
     * Autofill design with data
     */
    public function autofillDesign(string $accessToken, string $designId, array $data): array
    {
        $autofillData = [];

        foreach ($data as $key => $value) {
            $autofillData[] = [
                'name' => $key,
                'value' => $value,
            ];
        }

        return $this->apiRequest('POST', "designs/{$designId}/autofill", $accessToken, [
            'data' => $autofillData,
        ]);
    }

    // ============================================
    // Helper Methods
    // ============================================

    /**
     * Get available design dimensions
     */
    public function getAvailableDimensions(): array
    {
        return $this->designDimensions;
    }

    /**
     * Get template categories
     */
    public function getTemplateCategories(): array
    {
        return $this->templateCategories;
    }

    /**
     * Get available scopes
     */
    public function getAvailableScopes(): array
    {
        return $this->availableScopes;
    }

    /**
     * Get design edit URL (opens Canva editor)
     */
    public function getEditUrl(string $designId): string
    {
        return "https://www.canva.com/design/{$designId}/edit";
    }

    /**
     * Get design view URL
     */
    public function getViewUrl(string $designId): string
    {
        return "https://www.canva.com/design/{$designId}/view";
    }

    /**
     * Quick create social media design
     */
    public function quickCreateSocialDesign(string $accessToken, array $options): array
    {
        $platform = $options['platform'] ?? 'instagram';
        $contentType = $options['content_type'] ?? 'post';
        $designType = "{$platform}_{$contentType}";

        $design = $this->createDesign($accessToken, [
            'type' => $designType,
            'title' => $options['title'] ?? "New {$platform} {$contentType}",
        ]);

        if (!$design['success']) {
            return $design;
        }

        $designId = $design['data']['design']['id'];

        return [
            'success' => true,
            'design_id' => $designId,
            'edit_url' => $this->getEditUrl($designId),
            'dimensions' => $this->designDimensions[$designType] ?? null,
        ];
    }

    /**
     * Bulk export designs
     */
    public function bulkExport(string $accessToken, array $designIds, array $options = []): array
    {
        $exports = [];

        foreach ($designIds as $designId) {
            try {
                $export = $this->exportDesign($accessToken, $designId, $options);
                $exports[$designId] = $export;
            } catch (Exception $e) {
                $exports[$designId] = [
                    'success' => false,
                    'error' => $e->getMessage(),
                ];
            }
        }

        return [
            'success' => true,
            'exports' => $exports,
        ];
    }

    /**
     * Get redirect URI
     */
    public function getRedirectUri(): string
    {
        return $this->redirectUri;
    }

    /**
     * Get client ID
     */
    public function getClientId(): string
    {
        return $this->clientId;
    }
}
