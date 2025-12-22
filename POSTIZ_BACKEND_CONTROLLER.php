<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

/**
 * Postiz API Controller
 * يتعامل مع جميع طلبات Postiz API
 *
 * يجب إضافة هذا Controller في: app/Http/Controllers/Api/PostizController.php
 */
class PostizController extends Controller
{
    private $apiKey;
    private $baseUrl;

    public function __construct()
    {
        $this->apiKey = env('POSTIZ_API_KEY');
        $this->baseUrl = env('POSTIZ_BASE_URL', 'https://api.postiz.com/public/v1');
    }

    /**
     * إنشاء رابط OAuth للربط بمنصة معينة
     * Postiz يستخدم OAuth الرسمي لكل منصة
     *
     * POST /api/postiz/oauth-link
     */
    public function generateOAuthLink(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'platform' => 'required|string|in:facebook,instagram,twitter,linkedin,tiktok,youtube,reddit,pinterest,threads,discord,mastodon,bluesky',
            'user_id' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صالحة',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $platform = $request->input('platform');
            $userId = $request->input('user_id');

            // توليد state للأمان
            $state = base64_encode(json_encode([
                'user_id' => $userId,
                'platform' => $platform,
                'timestamp' => time(),
            ]));

            // بناء رابط OAuth
            // ملاحظة: في Postiz المستضاف ذاتياً، يجب أن يكون لديك OAuth Apps معدة
            $redirectUri = env('APP_URL') . '/api/postiz/oauth-callback';

            $oauthUrl = $this->getOAuthUrl($platform, $state, $redirectUri);

            return response()->json([
                'success' => true,
                'message' => 'تم إنشاء رابط OAuth بنجاح',
                'data' => [
                    'url' => $oauthUrl,
                    'state' => $state,
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('Postiz OAuth link generation error', [
                'error' => $e->getMessage(),
                'platform' => $request->input('platform'),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'فشل في إنشاء رابط OAuth: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Callback من المنصات بعد OAuth
     *
     * GET /api/postiz/oauth-callback
     */
    public function oauthCallback(Request $request)
    {
        try {
            $code = $request->query('code');
            $state = $request->query('state');

            if (!$code || !$state) {
                throw new \Exception('Missing OAuth parameters');
            }

            // فك تشفير state
            $stateData = json_decode(base64_decode($state), true);
            $userId = $stateData['user_id'];
            $platform = $stateData['platform'];

            // تبديل code بـ access token
            $tokenData = $this->exchangeOAuthCode($platform, $code);

            // حفظ معلومات الحساب في قاعدة البيانات
            $this->saveIntegration($userId, $platform, $tokenData);

            // إعادة توجيه المستخدم إلى Deep Link في التطبيق
            return redirect('mprosocial://oauth-success?platform=' . $platform);
        } catch (\Exception $e) {
            Log::error('Postiz OAuth callback error', ['error' => $e->getMessage()]);
            return redirect('mprosocial://oauth-failed?error=server_error');
        }
    }

    /**
     * الحصول على قائمة القنوات/الحسابات المربوطة
     *
     * GET /api/postiz/integrations
     */
    public function getIntegrations(Request $request)
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/json',
            ])->get($this->baseUrl . '/integrations');

            if ($response->successful()) {
                return response()->json([
                    'success' => true,
                    'data' => [
                        'integrations' => $response->json(),
                    ],
                ]);
            } else {
                throw new \Exception('فشل في جلب القنوات');
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * نشر محتوى على منصات social media
     *
     * POST /api/postiz/posts
     */
    public function publishPost(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'integration_ids' => 'required|array',
            'integration_ids.*' => 'string',
            'content' => 'required|array',
            'content.*.text' => 'required|string',
            'schedule_date' => 'nullable|date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صالحة',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $postData = [
                'integrations' => $request->input('integration_ids'),
                'content' => $request->input('content'),
            ];

            if ($request->has('schedule_date')) {
                $postData['date'] = $request->input('schedule_date');
            }

            if ($request->has('settings')) {
                $postData['settings'] = $request->input('settings');
            }

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/json',
            ])->post($this->baseUrl . '/posts', $postData);

            if ($response->successful()) {
                $data = $response->json();

                // حفظ في قاعدة البيانات
                $this->savePost($data);

                return response()->json([
                    'success' => true,
                    'message' => 'تم النشر بنجاح',
                    'data' => $data,
                ]);
            } else {
                throw new \Exception($response->json()['message'] ?? 'فشل النشر');
            }
        } catch (\Exception $e) {
            Log::error('Postiz post error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'message' => 'فشل النشر: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * حذف منشور
     *
     * DELETE /api/postiz/posts/{postId}
     */
    public function deletePost($postId)
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->delete($this->baseUrl . '/posts/' . $postId);

            if ($response->successful()) {
                return response()->json([
                    'success' => true,
                    'message' => 'تم حذف المنشور بنجاح',
                ]);
            } else {
                throw new \Exception('فشل حذف المنشور');
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * الحصول على قائمة المنشورات
     *
     * GET /api/postiz/posts
     */
    public function getPosts(Request $request)
    {
        try {
            $queryParams = [];

            if ($request->has('start_date')) {
                $queryParams['startDate'] = $request->query('start_date');
            }

            if ($request->has('end_date')) {
                $queryParams['endDate'] = $request->query('end_date');
            }

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->get($this->baseUrl . '/posts', $queryParams);

            if ($response->successful()) {
                return response()->json([
                    'success' => true,
                    'data' => [
                        'posts' => $response->json(),
                    ],
                ]);
            } else {
                throw new \Exception('فشل جلب المنشورات');
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * رفع صورة/فيديو
     *
     * POST /api/postiz/upload
     */
    public function uploadMedia(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'file' => 'required|file|max:100000', // 100MB max
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'ملف غير صالح',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $file = $request->file('file');

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->attach(
                'file',
                file_get_contents($file->getRealPath()),
                $file->getClientOriginalName()
            )->post($this->baseUrl . '/upload');

            if ($response->successful()) {
                $data = $response->json();

                return response()->json([
                    'success' => true,
                    'data' => [
                        'url' => $data['url'],
                    ],
                ]);
            } else {
                throw new \Exception('فشل رفع الملف');
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * رفع صورة/فيديو من URL خارجي
     *
     * POST /api/postiz/upload-from-url
     */
    public function uploadMediaFromUrl(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'url' => 'required|url',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'رابط غير صالح',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/json',
            ])->post($this->baseUrl . '/upload-from-url', [
                'url' => $request->input('url'),
            ]);

            if ($response->successful()) {
                $data = $response->json();

                return response()->json([
                    'success' => true,
                    'data' => [
                        'url' => $data['url'],
                    ],
                ]);
            } else {
                throw new \Exception('فشل رفع الملف من URL');
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * الحصول على أفضل وقت للنشر على قناة معينة
     *
     * GET /api/postiz/find-slot/{integrationId}
     */
    public function getNextAvailableSlot($integrationId)
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->get($this->baseUrl . '/find-slot/' . $integrationId);

            if ($response->successful()) {
                return response()->json([
                    'success' => true,
                    'data' => [
                        'slot' => $response->json()['slot'],
                    ],
                ]);
            } else {
                throw new \Exception('فشل جلب الوقت المتاح');
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * توليد فيديو بالذكاء الاصطناعي
     *
     * POST /api/postiz/generate-video
     */
    public function generateVideo(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'prompt' => 'required|string',
            'model' => 'nullable|string|in:image-text-slides,veo3',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صالحة',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $postData = [
                'prompt' => $request->input('prompt'),
                'model' => $request->input('model', 'image-text-slides'),
            ];

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/json',
            ])->post($this->baseUrl . '/generate-video', $postData);

            if ($response->successful()) {
                $data = $response->json();

                return response()->json([
                    'success' => true,
                    'data' => [
                        'video_url' => $data['url'],
                        'id' => $data['id'] ?? null,
                    ],
                ]);
            } else {
                throw new \Exception('فشل توليد الفيديو');
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * فصل حساب مرتبط (integration)
     *
     * DELETE /api/postiz/integrations/{integrationId}
     */
    public function unlinkIntegration($integrationId)
    {
        try {
            // حذف من قاعدة البيانات المحلية
            \DB::table('social_accounts')
                ->where('integration_id', $integrationId)
                ->delete();

            return response()->json([
                'success' => true,
                'message' => 'تم فصل الحساب بنجاح',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * التحقق من حالة API
     *
     * GET /api/postiz/status
     */
    public function checkStatus()
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->get($this->baseUrl . '/integrations');

            return response()->json([
                'success' => $response->successful(),
                'message' => $response->successful() ? 'API يعمل بشكل صحيح' : 'API غير متاح',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'API غير متاح',
            ], 500);
        }
    }

    // ========== Helper Methods ==========

    /**
     * الحصول على رابط OAuth حسب المنصة
     */
    private function getOAuthUrl($platform, $state, $redirectUri)
    {
        // في حالة استخدام Postiz المستضاف ذاتياً
        // يجب أن يكون لديك OAuth Apps معدة لكل منصة

        switch ($platform) {
            case 'facebook':
                $appId = env('FACEBOOK_APP_ID');
                return "https://www.facebook.com/v18.0/dialog/oauth?client_id={$appId}&redirect_uri={$redirectUri}&state={$state}&scope=pages_manage_posts,pages_read_engagement,instagram_basic,instagram_content_publish";

            case 'twitter':
                // Twitter OAuth 2.0
                $clientId = env('TWITTER_CLIENT_ID');
                return "https://twitter.com/i/oauth2/authorize?response_type=code&client_id={$clientId}&redirect_uri={$redirectUri}&state={$state}&scope=tweet.read%20tweet.write%20users.read";

            case 'linkedin':
                $clientId = env('LINKEDIN_CLIENT_ID');
                return "https://www.linkedin.com/oauth/v2/authorization?response_type=code&client_id={$clientId}&redirect_uri={$redirectUri}&state={$state}&scope=w_member_social";

            case 'tiktok':
                $clientKey = env('TIKTOK_CLIENT_KEY');
                return "https://www.tiktok.com/auth/authorize?client_key={$clientKey}&response_type=code&scope=user.info.basic,video.publish&redirect_uri={$redirectUri}&state={$state}";

            default:
                throw new \Exception('منصة غير مدعومة: ' . $platform);
        }
    }

    /**
     * تبديل OAuth code بـ access token
     */
    private function exchangeOAuthCode($platform, $code)
    {
        // هنا يتم تبديل code بـ access token حسب كل منصة
        // يمكن استخدام مكتبات OAuth المتخصصة

        // مثال بسيط:
        return [
            'access_token' => $code, // يجب استبداله بالـ access token الفعلي
            'platform' => $platform,
        ];
    }

    /**
     * حفظ معلومات الحساب المربوط
     */
    private function saveIntegration($userId, $platform, $tokenData)
    {
        \DB::table('social_accounts')->insert([
            'user_id' => $userId,
            'platform' => $platform,
            'access_token' => encrypt($tokenData['access_token']),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    /**
     * حفظ معلومات المنشور
     */
    private function savePost($postData)
    {
        // حفظ في جدول posts
        // يمكن استخدام model Post
    }
}
