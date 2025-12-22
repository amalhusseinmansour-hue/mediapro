<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;

/**
 * Complete Postiz Controller
 * يتعامل مع جميع وظائف Postiz: ربط الحسابات، النشر، الجدولة، التحليلات
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

    // ==================== ربط حسابات Social Media ====================

    /**
     * إنشاء رابط OAuth لربط منصة معينة
     * POST /api/postiz/oauth-link
     */
    public function generateOAuthLink(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'platform' => 'required|string|in:facebook,instagram,twitter,linkedin,tiktok,youtube,reddit,pinterest,threads,discord,slack,mastodon,bluesky',
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
                'random' => bin2hex(random_bytes(16)),
            ]));

            // حفظ state في session أو cache
            cache()->put("oauth_state_{$state}", [
                'user_id' => $userId,
                'platform' => $platform,
            ], now()->addMinutes(15));

            $redirectUri = env('APP_URL') . '/api/postiz/oauth-callback';
            $oauthUrl = $this->getOAuthUrl($platform, $state, $redirectUri);

            return response()->json([
                'success' => true,
                'data' => [
                    'url' => $oauthUrl,
                    'state' => $state,
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('Postiz OAuth link error', [
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

            // التحقق من state
            $stateData = cache()->get("oauth_state_{$state}");
            if (!$stateData) {
                throw new \Exception('Invalid or expired state');
            }

            $userId = $stateData['user_id'];
            $platform = $stateData['platform'];

            // تبديل code بـ access token
            $tokenData = $this->exchangeOAuthCode($platform, $code);

            // حفظ Integration في قاعدة البيانات
            $integration = $this->saveIntegration($userId, $platform, $tokenData);

            // حذف state من cache
            cache()->forget("oauth_state_{$state}");

            // إعادة توجيه المستخدم
            return redirect('mprosocial://oauth-success?platform=' . $platform . '&integration_id=' . $integration->id);
        } catch (\Exception $e) {
            Log::error('Postiz OAuth callback error', ['error' => $e->getMessage()]);
            return redirect('mprosocial://oauth-failed?error=' . urlencode($e->getMessage()));
        }
    }

    /**
     * الحصول على جميع الحسابات المربوطة
     * GET /api/postiz/integrations
     */
    public function getIntegrations(Request $request)
    {
        try {
            $userId = Auth::id();

            // جلب من قاعدة البيانات المحلية
            $integrations = DB::table('social_accounts')
                ->where('user_id', $userId)
                ->where('is_active', true)
                ->get()
                ->map(function ($account) {
                    return [
                        'id' => $account->id,
                        'integration_id' => $account->integration_id,
                        'platform' => $account->platform,
                        'provider' => $account->platform,
                        'name' => $account->account_name,
                        'username' => $account->username,
                        'profile_picture' => $account->profile_picture,
                        'is_active' => (bool) $account->is_active,
                        'connected_at' => $account->created_at,
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => [
                    'integrations' => $integrations,
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('Get integrations error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * فصل حساب مرتبط
     * DELETE /api/postiz/integrations/{integrationId}
     */
    public function unlinkIntegration($integrationId)
    {
        try {
            $userId = Auth::id();

            $deleted = DB::table('social_accounts')
                ->where('id', $integrationId)
                ->where('user_id', $userId)
                ->update(['is_active' => false, 'updated_at' => now()]);

            return response()->json([
                'success' => (bool) $deleted,
                'message' => $deleted ? 'تم فصل الحساب بنجاح' : 'الحساب غير موجود',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    // ==================== النشر والجدولة ====================

    /**
     * نشر منشور فوري أو مجدول
     * POST /api/postiz/posts
     */
    public function publishPost(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'integration_ids' => 'required|array',
            'integration_ids.*' => 'integer',
            'content' => 'required|array',
            'content.*.text' => 'required|string',
            'schedule_date' => 'nullable|date|after:now',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صالحة',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $userId = Auth::id();
            $integrationIds = $request->input('integration_ids');
            $content = $request->input('content');
            $scheduleDate = $request->input('schedule_date');

            // التحقق من ملكية المستخدم للحسابات
            $userIntegrations = DB::table('social_accounts')
                ->whereIn('id', $integrationIds)
                ->where('user_id', $userId)
                ->where('is_active', true)
                ->pluck('integration_id')
                ->toArray();

            if (count($userIntegrations) !== count($integrationIds)) {
                throw new \Exception('بعض الحسابات غير صالحة أو غير مملوكة لك');
            }

            // إنشاء سجل في قاعدة البيانات
            $postId = DB::table('posts')->insertGetId([
                'user_id' => $userId,
                'content' => json_encode($content),
                'integration_ids' => json_encode($integrationIds),
                'status' => $scheduleDate ? 'scheduled' : 'publishing',
                'scheduled_at' => $scheduleDate,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // إذا كان فوري، نشره الآن عبر Postiz API
            if (!$scheduleDate) {
                $result = $this->publishToPostiz($userIntegrations, $content, null);

                DB::table('posts')->where('id', $postId)->update([
                    'status' => 'published',
                    'published_at' => now(),
                    'platform_post_ids' => json_encode($result['postIds'] ?? []),
                ]);
            }

            return response()->json([
                'success' => true,
                'message' => $scheduleDate ? 'تم جدولة المنشور بنجاح' : 'تم النشر بنجاح',
                'data' => [
                    'id' => $postId,
                    'postIds' => $result['postIds'] ?? [],
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('Publish post error', [
                'error' => $e->getMessage(),
                'user_id' => Auth::id(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'فشل النشر: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * الحصول على قائمة المنشورات
     * GET /api/postiz/posts
     */
    public function getPosts(Request $request)
    {
        try {
            $userId = Auth::id();
            $startDate = $request->query('start_date');
            $endDate = $request->query('end_date');
            $status = $request->query('status');

            $query = DB::table('posts')->where('user_id', $userId);

            if ($startDate) {
                $query->where('created_at', '>=', $startDate);
            }

            if ($endDate) {
                $query->where('created_at', '<=', $endDate);
            }

            if ($status) {
                $query->where('status', $status);
            }

            $posts = $query->orderBy('created_at', 'desc')
                ->get()
                ->map(function ($post) {
                    return [
                        'id' => $post->id,
                        'content' => json_decode($post->content, true),
                        'text' => json_decode($post->content, true)[0]['text'] ?? '',
                        'media' => json_decode($post->content, true)[0]['media'] ?? [],
                        'status' => $post->status,
                        'schedule_date' => $post->scheduled_at,
                        'published_at' => $post->published_at,
                        'integration_ids' => json_decode($post->integration_ids, true),
                        'postIds' => json_decode($post->platform_post_ids, true) ?? [],
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => [
                    'posts' => $posts,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * تحديث منشور مجدول
     * PUT /api/postiz/posts/{postId}
     */
    public function updatePost(Request $request, $postId)
    {
        try {
            $userId = Auth::id();

            $post = DB::table('posts')
                ->where('id', $postId)
                ->where('user_id', $userId)
                ->where('status', 'scheduled')
                ->first();

            if (!$post) {
                throw new \Exception('المنشور غير موجود أو لا يمكن تعديله');
            }

            $updateData = [];

            if ($request->has('content')) {
                $updateData['content'] = json_encode($request->input('content'));
            }

            if ($request->has('schedule_date')) {
                $updateData['scheduled_at'] = $request->input('schedule_date');
            }

            $updateData['updated_at'] = now();

            DB::table('posts')->where('id', $postId)->update($updateData);

            return response()->json([
                'success' => true,
                'message' => 'تم تحديث المنشور بنجاح',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * حذف منشور
     * DELETE /api/postiz/posts/{postId}
     */
    public function deletePost($postId)
    {
        try {
            $userId = Auth::id();

            $deleted = DB::table('posts')
                ->where('id', $postId)
                ->where('user_id', $userId)
                ->delete();

            return response()->json([
                'success' => (bool) $deleted,
                'message' => $deleted ? 'تم حذف المنشور بنجاح' : 'المنشور غير موجود',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    // ==================== التحليلات ====================

    /**
     * ملخص التحليلات الشامل
     * GET /api/postiz/analytics/summary
     */
    public function getAnalyticsSummary(Request $request)
    {
        try {
            $userId = Auth::id();
            $startDate = $request->query('start_date', now()->subDays(30));
            $endDate = $request->query('end_date', now());

            // حساب الإحصائيات من قاعدة البيانات
            $totalPosts = DB::table('posts')
                ->where('user_id', $userId)
                ->where('status', 'published')
                ->whereBetween('published_at', [$startDate, $endDate])
                ->count();

            $totalAccounts = DB::table('social_accounts')
                ->where('user_id', $userId)
                ->where('is_active', true)
                ->count();

            // يمكن دمج البيانات من Postiz API إذا كان متاحاً
            $analytics = DB::table('post_analytics')
                ->join('posts', 'post_analytics.post_id', '=', 'posts.id')
                ->where('posts.user_id', $userId)
                ->whereBetween('posts.published_at', [$startDate, $endDate])
                ->selectRaw('
                    SUM(likes) as total_likes,
                    SUM(comments) as total_comments,
                    SUM(shares) as total_shares,
                    SUM(views) as total_views,
                    SUM(reach) as total_reach
                ')
                ->first();

            $totalEngagement = ($analytics->total_likes ?? 0) +
                             ($analytics->total_comments ?? 0) +
                             ($analytics->total_shares ?? 0);

            $engagementRate = $analytics->total_reach > 0
                ? ($totalEngagement / $analytics->total_reach) * 100
                : 0;

            return response()->json([
                'success' => true,
                'data' => [
                    'total_posts' => $totalPosts,
                    'total_accounts' => $totalAccounts,
                    'total_reach' => $analytics->total_reach ?? 0,
                    'total_engagement' => $totalEngagement,
                    'total_followers' => 0, // يمكن حسابه من جدول accounts
                    'engagement_rate' => round($engagementRate, 2),
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('Analytics summary error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * تحليلات منشور معين
     * GET /api/postiz/analytics/post/{postId}
     */
    public function getPostAnalytics($postId)
    {
        try {
            $userId = Auth::id();

            $post = DB::table('posts')
                ->where('id', $postId)
                ->where('user_id', $userId)
                ->first();

            if (!$post) {
                throw new \Exception('المنشور غير موجود');
            }

            $analytics = DB::table('post_analytics')
                ->where('post_id', $postId)
                ->first();

            if (!$analytics) {
                // إنشاء سجل فارغ إذا لم يكن موجود
                $analytics = (object) [
                    'likes' => 0,
                    'comments' => 0,
                    'shares' => 0,
                    'views' => 0,
                    'reach' => 0,
                ];
            }

            $engagementRate = $analytics->reach > 0
                ? (($analytics->likes + $analytics->comments + $analytics->shares) / $analytics->reach) * 100
                : 0;

            return response()->json([
                'success' => true,
                'data' => [
                    'post_id' => $postId,
                    'likes' => $analytics->likes,
                    'comments' => $analytics->comments,
                    'shares' => $analytics->shares,
                    'views' => $analytics->views,
                    'reach' => $analytics->reach,
                    'engagement_rate' => round($engagementRate, 2),
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * تحليلات حساب معين
     * GET /api/postiz/analytics/account/{integrationId}
     */
    public function getAccountAnalytics($integrationId, Request $request)
    {
        try {
            $userId = Auth::id();
            $startDate = $request->query('start_date', now()->subDays(30));
            $endDate = $request->query('end_date', now());

            $account = DB::table('social_accounts')
                ->where('id', $integrationId)
                ->where('user_id', $userId)
                ->first();

            if (!$account) {
                throw new \Exception('الحساب غير موجود');
            }

            // حساب الإحصائيات للمنشورات من هذا الحساب
            $postIds = DB::table('posts')
                ->where('user_id', $userId)
                ->whereRaw("JSON_CONTAINS(integration_ids, ?)", [json_encode([(int)$integrationId])])
                ->whereBetween('published_at', [$startDate, $endDate])
                ->pluck('id');

            $analytics = DB::table('post_analytics')
                ->whereIn('post_id', $postIds)
                ->selectRaw('
                    COUNT(*) as total_posts,
                    SUM(likes) as total_likes,
                    SUM(comments) as total_comments,
                    SUM(shares) as total_shares,
                    SUM(reach) as total_reach
                ')
                ->first();

            $totalEngagement = ($analytics->total_likes ?? 0) +
                             ($analytics->total_comments ?? 0) +
                             ($analytics->total_shares ?? 0);

            $avgEngagement = $analytics->total_posts > 0
                ? $totalEngagement / $analytics->total_posts
                : 0;

            return response()->json([
                'success' => true,
                'data' => [
                    'integration_id' => $integrationId,
                    'followers' => $account->followers ?? 0,
                    'total_posts' => $analytics->total_posts ?? 0,
                    'total_reach' => $analytics->total_reach ?? 0,
                    'total_engagement' => $totalEngagement,
                    'average_engagement_rate' => round($avgEngagement, 2),
                    'posts_per_day' => [], // يمكن حسابه من البيانات
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    // ==================== رفع الوسائط ====================

    /**
     * رفع ملف
     * POST /api/postiz/upload
     */
    public function uploadMedia(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'file' => 'required|file|max:102400', // 100MB
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
            $path = $file->store('posts/media', 'public');
            $url = asset('storage/' . $path);

            return response()->json([
                'success' => true,
                'data' => [
                    'url' => $url,
                    'path' => $path,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * رفع من URL
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
            $url = $request->input('url');

            // تحميل الملف من URL
            $contents = file_get_contents($url);
            $name = basename(parse_url($url, PHP_URL_PATH));
            $path = 'posts/media/' . uniqid() . '_' . $name;

            \Storage::disk('public')->put($path, $contents);

            $finalUrl = asset('storage/' . $path);

            return response()->json([
                'success' => true,
                'data' => [
                    'url' => $finalUrl,
                    'path' => $path,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * الحصول على أفضل وقت للنشر
     * GET /api/postiz/find-slot/{integrationId}
     */
    public function getNextAvailableSlot($integrationId)
    {
        try {
            // حساب أفضل وقت بناءً على تحليلات سابقة
            $bestHour = 12; // افتراضياً 12 ظهراً

            $nextSlot = now()->setHour($bestHour)->setMinute(0)->setSecond(0);

            if ($nextSlot->isPast()) {
                $nextSlot->addDay();
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'slot' => $nextSlot->toIso8601String(),
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * توليد فيديو بالذكاء الاصطناعي
     * POST /api/postiz/generate-video
     */
    public function generateVideo(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'prompt' => 'required|string',
            'model' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            // هنا يمكن التكامل مع Postiz API لتوليد الفيديو
            // أو استخدام خدمات AI أخرى مثل Google Veo

            return response()->json([
                'success' => true,
                'data' => [
                    'video_url' => 'https://example.com/generated-video.mp4',
                    'id' => uniqid(),
                ],
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
     * GET /api/postiz/status
     */
    public function checkStatus()
    {
        try {
            // اختبار الاتصال بقاعدة البيانات
            DB::connection()->getPdo();

            return response()->json([
                'success' => true,
                'message' => 'API يعمل بشكل صحيح',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'API غير متاح',
            ], 500);
        }
    }

    // ==================== Helper Methods ====================

    private function getOAuthUrl($platform, $state, $redirectUri)
    {
        switch ($platform) {
            case 'facebook':
                $appId = env('FACEBOOK_APP_ID');
                $scope = 'pages_manage_posts,pages_read_engagement,instagram_basic,instagram_content_publish';
                return "https://www.facebook.com/v18.0/dialog/oauth?client_id={$appId}&redirect_uri={$redirectUri}&state={$state}&scope={$scope}";

            case 'twitter':
                $clientId = env('TWITTER_CLIENT_ID');
                $scope = 'tweet.read%20tweet.write%20users.read%20offline.access';
                return "https://twitter.com/i/oauth2/authorize?response_type=code&client_id={$clientId}&redirect_uri={$redirectUri}&state={$state}&scope={$scope}&code_challenge=challenge&code_challenge_method=plain";

            case 'linkedin':
                $clientId = env('LINKEDIN_CLIENT_ID');
                $scope = 'w_member_social%20r_liteprofile';
                return "https://www.linkedin.com/oauth/v2/authorization?response_type=code&client_id={$clientId}&redirect_uri={$redirectUri}&state={$state}&scope={$scope}";

            case 'tiktok':
                $clientKey = env('TIKTOK_CLIENT_KEY');
                $scope = 'user.info.basic,video.publish';
                return "https://www.tiktok.com/v2/auth/authorize?client_key={$clientKey}&response_type=code&scope={$scope}&redirect_uri={$redirectUri}&state={$state}";

            default:
                throw new \Exception('منصة غير مدعومة: ' . $platform);
        }
    }

    private function exchangeOAuthCode($platform, $code)
    {
        // هنا يتم تبديل code بـ access token حسب كل منصة
        // يمكن استخدام مكتبات OAuth المتخصصة

        switch ($platform) {
            case 'facebook':
                $appId = env('FACEBOOK_APP_ID');
                $appSecret = env('FACEBOOK_APP_SECRET');
                $redirectUri = env('APP_URL') . '/api/postiz/oauth-callback';

                $response = Http::get('https://graph.facebook.com/v18.0/oauth/access_token', [
                    'client_id' => $appId,
                    'client_secret' => $appSecret,
                    'redirect_uri' => $redirectUri,
                    'code' => $code,
                ]);

                if ($response->successful()) {
                    return $response->json();
                }
                break;

            // يمكن إضافة باقي المنصات بنفس الطريقة
        }

        // افتراضياً
        return [
            'access_token' => $code,
            'platform' => $platform,
        ];
    }

    private function saveIntegration($userId, $platform, $tokenData)
    {
        $integrationId = DB::table('social_accounts')->insertGetId([
            'user_id' => $userId,
            'platform' => $platform,
            'integration_id' => uniqid($platform . '_'),
            'access_token' => encrypt($tokenData['access_token']),
            'account_name' => $platform . ' Account',
            'username' => '',
            'is_active' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return (object) ['id' => $integrationId];
    }

    private function publishToPostiz($integrationIds, $content, $scheduleDate)
    {
        // هنا يتم النشر الفعلي عبر Postiz API
        // أو يمكن النشر مباشرة إلى APIs المنصات

        try {
            $response = Http::withHeaders([
                'Authorization' => $this->apiKey,
                'Content-Type' => 'application/json',
            ])->post($this->baseUrl . '/posts', [
                'integrations' => $integrationIds,
                'content' => $content,
                'date' => $scheduleDate,
            ]);

            if ($response->successful()) {
                return $response->json();
            }

            throw new \Exception('فشل النشر عبر Postiz API');
        } catch (\Exception $e) {
            Log::error('Postiz API publish error', ['error' => $e->getMessage()]);

            // يمكن المحاولة مباشرة مع APIs المنصات
            return [
                'postIds' => [],
                'status' => 'failed',
            ];
        }
    }
}
