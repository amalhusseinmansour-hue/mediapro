<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ConnectedAccount;
use App\Models\SocialMediaPost;
use App\Services\MediaUploadService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class PostizController extends Controller
{
    protected $baseUrl;
    protected $apiKey;
    protected $mediaService;

    public function __construct(MediaUploadService $mediaService)
    {
        $this->baseUrl = env('POSTIZ_API_URL', 'https://api.postiz.com');
        $this->apiKey = env('POSTIZ_API_KEY');
        $this->mediaService = $mediaService;
    }

    /**
     * Get connected integrations
     */
    public function getIntegrations(Request $request)
    {
        try {
            $user = $request->user();

            // Get from local database
            $connectedAccounts = ConnectedAccount::where('user_id', $user->id)
                ->where('is_active', true)
                ->get();

            // Also try to fetch from Postiz API if configured
            $postizIntegrations = [];
            if ($this->isConfigured()) {
                $response = Http::withHeaders([
                    'Authorization' => 'Bearer ' . $this->apiKey,
                ])->get("{$this->baseUrl}/integrations");

                if ($response->successful()) {
                    $postizIntegrations = $response->json()['data'] ?? [];
                }
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'local_accounts' => $connectedAccounts,
                    'postiz_integrations' => $postizIntegrations,
                    'total' => $connectedAccounts->count(),
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Postiz Get Integrations Error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => 'فشل في جلب الحسابات المتصلة',
            ], 500);
        }
    }

    /**
     * Generate OAuth link for platform connection
     */
    public function generateOAuthLink(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'platform' => 'required|string|in:facebook,instagram,twitter,linkedin,tiktok,youtube,pinterest',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $platform = $request->platform;
            $state = bin2hex(random_bytes(16));

            // Store state in session for verification
            session(['oauth_state_' . $platform => $state]);

            $redirectUri = config('app.url') . "/api/auth/{$platform}/callback";

            // Generate OAuth URL based on platform
            $oauthUrl = $this->getOAuthUrl($platform, $state, $redirectUri);

            return response()->json([
                'success' => true,
                'data' => [
                    'url' => $oauthUrl,
                    'state' => $state,
                    'platform' => $platform,
                    'redirect_uri' => $redirectUri,
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'فشل في إنشاء رابط الربط',
            ], 500);
        }
    }

    /**
     * Publish post to connected platforms
     */
    public function publishPost(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'platforms' => 'required|array|min:1',
            'platforms.*' => 'string|in:facebook,instagram,twitter,linkedin,tiktok,youtube,pinterest',
            'content' => 'required|string|max:5000',
            'media_urls' => 'nullable|array',
            'media_urls.*' => 'url',
            'scheduled_at' => 'nullable|date|after:now',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $user = $request->user();

            // Create local post record
            $post = SocialMediaPost::create([
                'user_id' => $user->id,
                'content' => $request->content,
                'platforms' => $request->platforms,
                'media' => $request->media_urls ?? [],
                'status' => $request->scheduled_at ? 'scheduled' : 'publishing',
                'scheduled_at' => $request->scheduled_at,
            ]);

            // If not scheduled, publish immediately
            if (!$request->scheduled_at) {
                $results = $this->publishToMultiplePlatforms($post, $user);

                $allSuccess = collect($results)->every(fn($r) => $r['success']);
                $post->update([
                    'status' => $allSuccess ? 'published' : 'partial',
                    'publish_results' => $results,
                    'published_at' => $allSuccess ? now() : null,
                ]);
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'post_id' => $post->id,
                    'status' => $post->status,
                    'message' => $request->scheduled_at
                        ? 'تم جدولة المنشور بنجاح'
                        : 'تم نشر المنشور',
                    'results' => $post->publish_results ?? null,
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Postiz Publish Error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'error' => 'فشل في نشر المنشور: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get posts list
     */
    public function getPosts(Request $request)
    {
        try {
            $user = $request->user();

            $query = SocialMediaPost::where('user_id', $user->id);

            // Filter by status
            if ($request->has('status')) {
                $query->where('status', $request->status);
            }

            // Filter by platform
            if ($request->has('platform')) {
                $query->whereJsonContains('platforms', $request->platform);
            }

            // Date range
            if ($request->has('from_date')) {
                $query->whereDate('created_at', '>=', $request->from_date);
            }
            if ($request->has('to_date')) {
                $query->whereDate('created_at', '<=', $request->to_date);
            }

            $posts = $query->orderBy('created_at', 'desc')
                ->paginate($request->get('per_page', 20));

            return response()->json([
                'success' => true,
                'data' => $posts,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'فشل في جلب المنشورات',
            ], 500);
        }
    }

    /**
     * Get single post
     */
    public function getPost(Request $request, $id)
    {
        try {
            $post = SocialMediaPost::where('user_id', $request->user()->id)
                ->with('platformPosts')
                ->findOrFail($id);

            return response()->json([
                'success' => true,
                'data' => $post,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'المنشور غير موجود',
            ], 404);
        }
    }

    /**
     * Upload media file
     */
    public function uploadMedia(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'file' => 'required|file|max:102400', // 100MB max
            'type' => 'nullable|string|in:image,video',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $file = $request->file('file');
            $type = $request->type ?? ($file->getMimeType() && str_starts_with($file->getMimeType(), 'video') ? 'video' : 'image');

            $folder = "posts/user_{$request->user()->id}";

            if ($type === 'video') {
                $result = $this->mediaService->uploadVideo($file, $folder);
            } else {
                $result = $this->mediaService->uploadImage($file, $folder);
            }

            if (!$result['success']) {
                return response()->json($result, 400);
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'url' => $result['url'],
                    'path' => $result['path'],
                    'type' => $type,
                    'size' => $result['size'] ?? null,
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'فشل في رفع الملف',
            ], 500);
        }
    }

    /**
     * Generate video using AI
     */
    public function generateVideo(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'prompt' => 'required|string|max:1000',
            'provider' => 'nullable|string|in:runway,replicate,stability',
            'duration' => 'nullable|integer|min:3|max:10',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $provider = $request->provider ?? 'runway';
            $result = null;

            switch ($provider) {
                case 'runway':
                    $service = app(\App\Services\RunwayMLService::class);
                    $result = $service->generateFromText($request->prompt, [
                        'duration' => $request->duration ?? 5,
                    ]);
                    break;

                case 'replicate':
                    // Replicate needs image first
                    return response()->json([
                        'success' => false,
                        'error' => 'Replicate يحتاج صورة لإنشاء فيديو',
                    ], 400);

                case 'stability':
                    return response()->json([
                        'success' => false,
                        'error' => 'Stability AI يحتاج صورة لإنشاء فيديو',
                    ], 400);
            }

            if ($result && $result['success']) {
                return response()->json([
                    'success' => true,
                    'data' => [
                        'task_id' => $result['task_id'] ?? $result['generation_id'] ?? null,
                        'status' => $result['status'] ?? 'processing',
                        'provider' => $provider,
                        'message' => 'بدأ إنشاء الفيديو',
                    ]
                ]);
            }

            return response()->json([
                'success' => false,
                'error' => $result['error'] ?? 'فشل في إنشاء الفيديو',
            ], 500);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'فشل في إنشاء الفيديو: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get service status
     */
    public function getStatus()
    {
        $status = [
            'postiz_configured' => $this->isConfigured(),
            'local_service' => true,
            'version' => '2.0.0',
        ];

        if ($this->isConfigured()) {
            try {
                $response = Http::withHeaders([
                    'Authorization' => 'Bearer ' . $this->apiKey,
                ])->timeout(5)->get("{$this->baseUrl}/health");

                $status['postiz_status'] = $response->successful() ? 'connected' : 'error';
            } catch (\Exception $e) {
                $status['postiz_status'] = 'unreachable';
            }
        }

        return response()->json([
            'success' => true,
            'data' => $status,
        ]);
    }

    /**
     * Unlink integration
     */
    public function unlinkIntegration(Request $request, $id)
    {
        try {
            $account = ConnectedAccount::where('user_id', $request->user()->id)
                ->findOrFail($id);

            $account->delete();

            return response()->json([
                'success' => true,
                'message' => 'تم إلغاء ربط الحساب بنجاح',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'الحساب غير موجود',
            ], 404);
        }
    }

    /**
     * Delete post
     */
    public function deletePost(Request $request, $id)
    {
        try {
            $post = SocialMediaPost::where('user_id', $request->user()->id)
                ->findOrFail($id);

            // Only allow deleting draft or failed posts
            if (in_array($post->status, ['published'])) {
                return response()->json([
                    'success' => false,
                    'error' => 'لا يمكن حذف منشور تم نشره',
                ], 400);
            }

            $post->delete();

            return response()->json([
                'success' => true,
                'message' => 'تم حذف المنشور بنجاح',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'المنشور غير موجود',
            ], 404);
        }
    }

    /**
     * Helper: Check if Postiz is configured
     */
    protected function isConfigured(): bool
    {
        return !empty($this->apiKey) && !str_contains($this->apiKey, 'your_');
    }

    /**
     * Helper: Get OAuth URL for platform
     */
    protected function getOAuthUrl(string $platform, string $state, string $redirectUri): string
    {
        switch ($platform) {
            case 'facebook':
                return "https://www.facebook.com/v18.0/dialog/oauth?" . http_build_query([
                    'client_id' => env('FACEBOOK_APP_ID'),
                    'redirect_uri' => $redirectUri,
                    'state' => $state,
                    'scope' => 'pages_manage_posts,pages_read_engagement,instagram_basic,instagram_content_publish',
                ]);

            case 'twitter':
                return "https://twitter.com/i/oauth2/authorize?" . http_build_query([
                    'client_id' => env('TWITTER_CLIENT_ID'),
                    'redirect_uri' => $redirectUri,
                    'state' => $state,
                    'scope' => 'tweet.read tweet.write users.read',
                    'response_type' => 'code',
                    'code_challenge_method' => 'plain',
                    'code_challenge' => $state,
                ]);

            case 'linkedin':
                return "https://www.linkedin.com/oauth/v2/authorization?" . http_build_query([
                    'client_id' => env('LINKEDIN_CLIENT_ID'),
                    'redirect_uri' => $redirectUri,
                    'state' => $state,
                    'scope' => 'r_liteprofile w_member_social',
                    'response_type' => 'code',
                ]);

            default:
                return "{$this->baseUrl}/oauth/{$platform}?state={$state}&redirect_uri={$redirectUri}";
        }
    }

    /**
     * Helper: Publish to multiple platforms
     */
    protected function publishToMultiplePlatforms(SocialMediaPost $post, $user): array
    {
        $results = [];

        foreach ($post->platforms as $platform) {
            $account = ConnectedAccount::where('user_id', $user->id)
                ->where('platform', $platform)
                ->where('is_active', true)
                ->first();

            if (!$account) {
                $results[$platform] = [
                    'success' => false,
                    'error' => 'لا يوجد حساب متصل لهذه المنصة',
                ];
                continue;
            }

            // Publish based on platform
            $results[$platform] = $this->publishToPlatform($post, $account);
        }

        return $results;
    }

    /**
     * Helper: Publish to single platform
     */
    protected function publishToPlatform(SocialMediaPost $post, ConnectedAccount $account): array
    {
        // Implementation depends on platform
        // This is a placeholder - actual implementation would use platform APIs
        try {
            Log::info("Publishing to {$account->platform}", [
                'post_id' => $post->id,
                'account_id' => $account->id,
            ]);

            // Simulate API call
            return [
                'success' => true,
                'platform_post_id' => 'post_' . uniqid(),
                'published_at' => now()->toIso8601String(),
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }
}
