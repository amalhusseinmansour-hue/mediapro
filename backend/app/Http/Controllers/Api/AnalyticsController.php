<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class AnalyticsController extends Controller
{
    /**
     * GET /api/analytics/usage
     * عرض استخدام المستخدم الحالي مقابل حدود الباقة
     * 
     * Query Parameters (filters):
     * - date_from: string (YYYY-MM-DD) - Start date for filtering
     * - date_to: string (YYYY-MM-DD) - End date for filtering
     * - platforms: array|string - Filter by platforms (comma-separated or array)
     * - metrics: array|string - Filter by metrics to return
     * - period_type: string - daily, weekly, or monthly
     */
    public function getUsage(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 401);
        }

        $subscription = $user->subscription;

        if (!$subscription) {
            return response()->json([
                'success' => false,
                'message' => 'No active subscription found',
            ], 404);
        }

        // إعادة تعيين العدادات إذا لزم الأمر
        $subscription->resetCountersIfNeeded();

        // Get filter parameters
        $dateFrom = $request->get('date_from') ? \Carbon\Carbon::parse($request->get('date_from')) : null;
        $dateTo = $request->get('date_to') ? \Carbon\Carbon::parse($request->get('date_to')) : null;
        $platforms = $request->get('platforms');
        if (is_string($platforms)) {
            $platforms = explode(',', $platforms);
        }
        $metrics = $request->get('metrics');
        if (is_string($metrics)) {
            $metrics = explode(',', $metrics);
        }

        // Build query for posts with filters
        $postsQuery = DB::table('posts')->where('user_id', $user->id);
        if ($dateFrom) $postsQuery->where('created_at', '>=', $dateFrom);
        if ($dateTo) $postsQuery->where('created_at', '<=', $dateTo);
        if (!empty($platforms)) $postsQuery->whereIn('platform', $platforms);

        $maxPosts = $subscription->custom_max_posts ?? $subscription->max_posts ?? 999999;
        $maxAIRequests = $subscription->custom_max_ai_requests ?? 999999;

        return response()->json([
            'success' => true,
            'usage' => [
                // المنشورات
                'posts' => [
                    'current' => $subscription->current_posts_count,
                    'limit' => $maxPosts,
                    'is_unlimited' => $maxPosts >= 999999,
                    'percentage' => $subscription->getPostsUsagePercentage(),
                    'remaining' => $subscription->getRemainingPosts(),
                    'reset_date' => $subscription->posts_reset_date?->toIso8601String(),
                    'filtered_count' => $dateFrom || $dateTo || $platforms ? $postsQuery->count() : null,
                ],

                // الذكاء الاصطناعي
                'ai_requests' => [
                    'current' => $subscription->current_ai_requests_count,
                    'limit' => $maxAIRequests,
                    'is_unlimited' => $maxAIRequests >= 999999,
                    'is_available' => $subscription->ai_features,
                    'percentage' => $subscription->getAIUsagePercentage(),
                    'remaining' => $subscription->getRemainingAIRequests(),
                    'reset_date' => $subscription->ai_requests_reset_date?->toIso8601String(),
                ],

                // الحسابات المربوطة
                'connected_accounts' => [
                    'current' => $user->connected_accounts_count ?? 0,
                    'limit' => $subscription->max_accounts ?? 999999,
                    'percentage' => $subscription->max_accounts > 0
                        ? round((($user->connected_accounts_count ?? 0) / $subscription->max_accounts) * 100, 2)
                        : 0,
                    'remaining' => max(0, ($subscription->max_accounts ?? 999999) - ($user->connected_accounts_count ?? 0)),
                ],
            ],
            'filters' => [
                'date_from' => $dateFrom?->toIso8601String(),
                'date_to' => $dateTo?->toIso8601String(),
                'platforms' => $platforms,
                'metrics' => $metrics,
            ],
        ]);
    }

    /**
     * GET /api/analytics/overview
     * نظرة عامة على الأداء
     * 
     * Query Parameters (filters):
     * - date_from: string (YYYY-MM-DD) - Start date for filtering
     * - date_to: string (YYYY-MM-DD) - End date for filtering
     * - platforms: array|string - Filter by platforms (comma-separated or array)
     * - metrics: array|string - Filter by metrics to return
     * - period_type: string - daily, weekly, or monthly
     */
    public function getOverview(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 401);
        }

        // Get filter parameters
        $dateFrom = $request->get('date_from') ? \Carbon\Carbon::parse($request->get('date_from')) : null;
        $dateTo = $request->get('date_to') ? \Carbon\Carbon::parse($request->get('date_to')) : null;
        $platforms = $request->get('platforms');
        if (is_string($platforms)) {
            $platforms = explode(',', $platforms);
        }
        $metrics = $request->get('metrics');
        if (is_string($metrics)) {
            $metrics = explode(',', $metrics);
        }

        // Build base query
        $baseQuery = DB::table('connected_accounts')->where('user_id', $user->id);
        $postsQuery = DB::table('posts')->where('user_id', $user->id);

        // Apply date filters
        if ($dateFrom) $postsQuery->where('created_at', '>=', $dateFrom);
        if ($dateTo) $postsQuery->where('created_at', '<=', $dateTo);

        // Apply platform filter
        if (!empty($platforms)) {
            $baseQuery->whereIn('platform', $platforms);
            $postsQuery->whereIn('platform', $platforms);
        }

        // جلب بيانات حقيقية من قاعدة البيانات
        $totalFollowers = $baseQuery->sum('followers_count') ?? 0;
        $totalPosts = $postsQuery->count();
        $totalEngagement = $postsQuery->sum('engagement_count') ?? 0;
        $totalReach = $postsQuery->sum('reach_count') ?? 0;

        // حساب معدل التفاعل
        $engagementRate = $totalReach > 0
            ? round(($totalEngagement / $totalReach) * 100, 2)
            : 0;

        // معدل النمو (مقارنة بالشهر السابق)
        $previousMonthFollowers = $baseQuery->sum('previous_month_followers') ?? 0;

        $followersGrowth = $previousMonthFollowers > 0
            ? round((($totalFollowers - $previousMonthFollowers) / $previousMonthFollowers) * 100, 2)
            : 0;

        return response()->json([
            'success' => true,
            'overview' => [
                'total_followers' => $totalFollowers,
                'total_posts' => $totalPosts,
                'total_engagement' => $totalEngagement,
                'total_reach' => $totalReach,
                'engagement_rate' => $engagementRate,
                'followers_growth' => $followersGrowth,
                'followers_growth_percentage' => $followersGrowth > 0 ? "+{$followersGrowth}%" : "{$followersGrowth}%",
            ],
            'filters' => [
                'date_from' => $dateFrom?->toIso8601String(),
                'date_to' => $dateTo?->toIso8601String(),
                'platforms' => $platforms,
                'metrics' => $metrics,
            ],
        ]);
    }

    /**
     * GET /api/analytics/posts
     * تحليلات المنشورات
     */
    public function getPostsAnalytics(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 401);
        }

        $period = $request->get('period', 'week'); // day, week, month, year

        $startDate = match ($period) {
            'day' => now()->subDay(),
            'week' => now()->subWeek(),
            'month' => now()->subMonth(),
            'year' => now()->subYear(),
            default => now()->subWeek(),
        };

        // أفضل المنشورات
        $topPosts = DB::table('posts')
            ->where('user_id', $user->id)
            ->where('created_at', '>=', $startDate)
            ->orderBy('engagement_count', 'desc')
            ->limit(5)
            ->select([
                'id',
                'content',
                'platform',
                'engagement_count',
                'reach_count',
                'shares_count',
                'created_at',
            ])
            ->get();

        // أداء حسب المنصة
        $platformPerformance = DB::table('posts')
            ->where('user_id', $user->id)
            ->where('created_at', '>=', $startDate)
            ->select('platform')
            ->selectRaw('COUNT(*) as posts_count')
            ->selectRaw('SUM(engagement_count) as total_engagement')
            ->selectRaw('SUM(reach_count) as total_reach')
            ->selectRaw('ROUND(AVG(engagement_count), 2) as avg_engagement')
            ->groupBy('platform')
            ->get();

        return response()->json([
            'success' => true,
            'analytics' => [
                'period' => $period,
                'start_date' => $startDate->toIso8601String(),
                'end_date' => now()->toIso8601String(),
                'top_posts' => $topPosts,
                'platform_performance' => $platformPerformance,
            ],
        ]);
    }

    /**
     * GET /api/analytics/platforms
     * تحليلات المنصات
     */
    public function getPlatformsAnalytics(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 401);
        }

        // إحصائيات كل منصة
        $platformsStats = DB::table('connected_accounts')
            ->where('user_id', $user->id)
            ->select([
                'platform',
                'followers_count',
                'is_connected',
                'last_sync_at',
            ])
            ->get();

        // أداء المنشورات حسب المنصة
        $platformsPosts = DB::table('posts')
            ->where('user_id', $user->id)
            ->select('platform')
            ->selectRaw('COUNT(*) as total_posts')
            ->selectRaw('SUM(engagement_count) as total_engagement')
            ->selectRaw('SUM(reach_count) as total_reach')
            ->selectRaw('ROUND(SUM(engagement_count) / NULLIF(SUM(reach_count), 0) * 100, 2) as engagement_rate')
            ->groupBy('platform')
            ->get();

        // دمج البيانات
        $platformsData = [];

        foreach ($platformsStats as $stat) {
            $postData = $platformsPosts->firstWhere('platform', $stat->platform);

            $platformsData[] = [
                'platform' => $stat->platform,
                'followers' => $stat->followers_count ?? 0,
                'is_connected' => $stat->is_connected ?? false,
                'last_sync' => $stat->last_sync_at,
                'total_posts' => $postData->total_posts ?? 0,
                'total_engagement' => $postData->total_engagement ?? 0,
                'total_reach' => $postData->total_reach ?? 0,
                'engagement_rate' => $postData->engagement_rate ?? 0,
            ];
        }

        return response()->json([
            'success' => true,
            'platforms' => $platformsData,
        ]);
    }

    /**
     * GET /api/analytics/check-limit/{type}
     * التحقق من الحد قبل القيام بعملية
     */
    public function checkLimit(Request $request, string $type): JsonResponse
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 401);
        }

        $subscription = $user->subscription;

        if (!$subscription) {
            return response()->json([
                'success' => false,
                'message' => 'No active subscription',
                'can_proceed' => false,
            ], 403);
        }

        $canProceed = false;
        $message = '';
        $current = 0;
        $limit = 0;
        $remaining = 0;

        switch ($type) {
            case 'post':
                $canProceed = !$subscription->hasReachedPostsLimit();
                $current = $subscription->current_posts_count;
                $limit = $subscription->custom_max_posts ?? $subscription->max_posts ?? 999999;
                $remaining = $subscription->getRemainingPosts();
                $message = $canProceed
                    ? 'يمكنك إنشاء منشور جديد'
                    : 'لقد وصلت للحد الأقصى من المنشورات لهذا الشهر';
                break;

            case 'ai':
                $canProceed = !$subscription->hasReachedAILimit();
                $current = $subscription->current_ai_requests_count;
                $limit = $subscription->custom_max_ai_requests ?? 999999;
                $remaining = $subscription->getRemainingAIRequests();
                $message = $canProceed
                    ? 'يمكنك استخدام الذكاء الاصطناعي'
                    : 'لقد وصلت للحد الأقصى من طلبات AI لهذا الشهر';
                break;

            case 'account':
                $currentAccounts = $user->connected_accounts_count ?? 0;
                $maxAccounts = $subscription->max_accounts ?? 999999;
                $canProceed = $currentAccounts < $maxAccounts;
                $current = $currentAccounts;
                $limit = $maxAccounts;
                $remaining = max(0, $maxAccounts - $currentAccounts);
                $message = $canProceed
                    ? 'يمكنك ربط حساب جديد'
                    : 'لقد وصلت للحد الأقصى من الحسابات';
                break;

            default:
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid limit type',
                ], 400);
        }

        return response()->json([
            'success' => true,
            'can_proceed' => $canProceed,
            'message' => $message,
            'usage' => [
                'current' => $current,
                'limit' => $limit,
                'remaining' => $remaining,
                'percentage' => $limit > 0 ? round(($current / $limit) * 100, 2) : 0,
            ],
        ]);
    }

    /**
     * GET /api/analytics/engagement-breakdown
     * تفاصيل التفاعل حسب النوع
     */
    public function engagementBreakdown(Request $request): JsonResponse
    {
        $user = $request->user();
        $period = $request->get('period', 'month');

        $startDate = match ($period) {
            'week' => now()->subWeek(),
            'month' => now()->subMonth(),
            'quarter' => now()->subMonths(3),
            'year' => now()->subYear(),
            default => now()->subMonth(),
        };

        // تفاصيل التفاعل
        $engagement = DB::table('posts')
            ->where('user_id', $user->id)
            ->where('created_at', '>=', $startDate)
            ->selectRaw('SUM(likes_count) as total_likes')
            ->selectRaw('SUM(comments_count) as total_comments')
            ->selectRaw('SUM(shares_count) as total_shares')
            ->selectRaw('SUM(saves_count) as total_saves')
            ->selectRaw('SUM(clicks_count) as total_clicks')
            ->selectRaw('SUM(views_count) as total_views')
            ->selectRaw('SUM(engagement_count) as total_engagement')
            ->first();

        // التفاعل اليومي
        $dailyEngagement = DB::table('posts')
            ->where('user_id', $user->id)
            ->where('created_at', '>=', $startDate)
            ->selectRaw('DATE(created_at) as date')
            ->selectRaw('SUM(engagement_count) as engagement')
            ->selectRaw('COUNT(*) as posts_count')
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        // أفضل أنواع المحتوى
        $contentTypes = DB::table('posts')
            ->where('user_id', $user->id)
            ->where('created_at', '>=', $startDate)
            ->select('media_type')
            ->selectRaw('COUNT(*) as count')
            ->selectRaw('AVG(engagement_count) as avg_engagement')
            ->selectRaw('SUM(engagement_count) as total_engagement')
            ->groupBy('media_type')
            ->orderByDesc('avg_engagement')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'summary' => [
                    'likes' => $engagement->total_likes ?? 0,
                    'comments' => $engagement->total_comments ?? 0,
                    'shares' => $engagement->total_shares ?? 0,
                    'saves' => $engagement->total_saves ?? 0,
                    'clicks' => $engagement->total_clicks ?? 0,
                    'views' => $engagement->total_views ?? 0,
                    'total' => $engagement->total_engagement ?? 0,
                ],
                'daily_trend' => $dailyEngagement,
                'content_performance' => $contentTypes,
                'period' => $period,
                'date_range' => [
                    'from' => $startDate->toDateString(),
                    'to' => now()->toDateString(),
                ],
            ],
        ]);
    }

    /**
     * GET /api/analytics/audience
     * تحليلات الجمهور
     */
    public function audienceAnalytics(Request $request): JsonResponse
    {
        $user = $request->user();

        // بيانات المتابعين من الحسابات المتصلة
        $accounts = DB::table('connected_accounts')
            ->where('user_id', $user->id)
            ->where('is_active', true)
            ->get();

        $totalFollowers = $accounts->sum('followers_count');
        $totalFollowing = $accounts->sum('following_count');

        // نمو المتابعين
        $followerGrowth = DB::table('follower_snapshots')
            ->where('user_id', $user->id)
            ->where('created_at', '>=', now()->subDays(30))
            ->selectRaw('DATE(created_at) as date')
            ->selectRaw('SUM(followers_count) as followers')
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        // توزيع المتابعين حسب المنصة
        $followersByPlatform = $accounts->groupBy('platform')->map(function ($group) {
            return [
                'count' => $group->sum('followers_count'),
                'percentage' => 0,
            ];
        });

        // حساب النسب المئوية
        if ($totalFollowers > 0) {
            $followersByPlatform = $followersByPlatform->map(function ($item) use ($totalFollowers) {
                $item['percentage'] = round(($item['count'] / $totalFollowers) * 100, 1);
                return $item;
            });
        }

        // أفضل أوقات التفاعل
        $bestTimes = DB::table('posts')
            ->where('user_id', $user->id)
            ->where('created_at', '>=', now()->subMonths(3))
            ->selectRaw('HOUR(created_at) as hour')
            ->selectRaw('DAYOFWEEK(created_at) as day_of_week')
            ->selectRaw('AVG(engagement_count) as avg_engagement')
            ->groupBy('hour', 'day_of_week')
            ->orderByDesc('avg_engagement')
            ->limit(10)
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'summary' => [
                    'total_followers' => $totalFollowers,
                    'total_following' => $totalFollowing,
                    'accounts_count' => $accounts->count(),
                ],
                'followers_by_platform' => $followersByPlatform,
                'growth_trend' => $followerGrowth,
                'best_posting_times' => $bestTimes,
            ],
        ]);
    }

    /**
     * GET /api/analytics/content-calendar
     * تقويم المحتوى
     */
    public function contentCalendar(Request $request): JsonResponse
    {
        $user = $request->user();
        $month = $request->get('month', now()->month);
        $year = $request->get('year', now()->year);

        $startDate = \Carbon\Carbon::create($year, $month, 1)->startOfMonth();
        $endDate = $startDate->copy()->endOfMonth();

        // المنشورات المنشورة
        $publishedPosts = DB::table('social_media_posts')
            ->where('user_id', $user->id)
            ->whereBetween('created_at', [$startDate, $endDate])
            ->select(['id', 'content', 'platforms', 'status', 'created_at', 'published_at'])
            ->get()
            ->groupBy(function ($post) {
                return \Carbon\Carbon::parse($post->created_at)->format('Y-m-d');
            });

        // المنشورات المجدولة
        $scheduledPosts = DB::table('scheduled_posts')
            ->where('user_id', $user->id)
            ->whereBetween('scheduled_at', [$startDate, $endDate])
            ->select(['id', 'content_text', 'platforms', 'status', 'scheduled_at'])
            ->get()
            ->groupBy(function ($post) {
                return \Carbon\Carbon::parse($post->scheduled_at)->format('Y-m-d');
            });

        // بناء التقويم
        $calendar = [];
        $currentDate = $startDate->copy();

        while ($currentDate <= $endDate) {
            $dateKey = $currentDate->format('Y-m-d');
            $calendar[$dateKey] = [
                'date' => $dateKey,
                'day' => $currentDate->day,
                'day_name' => $currentDate->locale('ar')->dayName,
                'published' => $publishedPosts->get($dateKey, collect())->values(),
                'scheduled' => $scheduledPosts->get($dateKey, collect())->values(),
                'total_posts' => ($publishedPosts->get($dateKey, collect())->count() + $scheduledPosts->get($dateKey, collect())->count()),
            ];
            $currentDate->addDay();
        }

        // إحصائيات الشهر
        $monthStats = [
            'total_published' => $publishedPosts->flatten()->count(),
            'total_scheduled' => $scheduledPosts->flatten()->count(),
            'busiest_day' => collect($calendar)->sortByDesc('total_posts')->first()['date'] ?? null,
            'average_posts_per_day' => round(($publishedPosts->flatten()->count() + $scheduledPosts->flatten()->count()) / $endDate->day, 1),
        ];

        return response()->json([
            'success' => true,
            'data' => [
                'month' => $month,
                'year' => $year,
                'calendar' => array_values($calendar),
                'statistics' => $monthStats,
            ],
        ]);
    }

    /**
     * GET /api/analytics/best-performing
     * أفضل المنشورات أداءً
     */
    public function bestPerforming(Request $request): JsonResponse
    {
        $user = $request->user();
        $limit = $request->get('limit', 10);
        $period = $request->get('period', 'month');
        $platform = $request->get('platform');

        $startDate = match ($period) {
            'week' => now()->subWeek(),
            'month' => now()->subMonth(),
            'quarter' => now()->subMonths(3),
            'year' => now()->subYear(),
            'all' => now()->subYears(10),
            default => now()->subMonth(),
        };

        $query = DB::table('posts')
            ->where('user_id', $user->id)
            ->where('created_at', '>=', $startDate);

        if ($platform) {
            $query->where('platform', $platform);
        }

        $topPosts = $query->orderByDesc('engagement_count')
            ->limit($limit)
            ->get();

        // تحليل أسباب النجاح
        $insights = [];
        foreach ($topPosts as $post) {
            $insights[] = [
                'post_id' => $post->id,
                'content_preview' => mb_substr($post->content ?? '', 0, 100),
                'platform' => $post->platform,
                'engagement' => $post->engagement_count,
                'reach' => $post->reach_count,
                'engagement_rate' => $post->reach_count > 0
                    ? round(($post->engagement_count / $post->reach_count) * 100, 2)
                    : 0,
                'posted_at' => $post->created_at,
                'day_of_week' => \Carbon\Carbon::parse($post->created_at)->locale('ar')->dayName,
                'hour' => \Carbon\Carbon::parse($post->created_at)->format('H:i'),
                'has_media' => !empty($post->media_url),
                'media_type' => $post->media_type,
            ];
        }

        return response()->json([
            'success' => true,
            'data' => [
                'posts' => $insights,
                'period' => $period,
                'total_analyzed' => count($insights),
            ],
        ]);
    }

    /**
     * GET /api/analytics/hashtag-performance
     * أداء الهاشتاقات
     */
    public function hashtagPerformance(Request $request): JsonResponse
    {
        $user = $request->user();
        $period = $request->get('period', 'month');

        $startDate = match ($period) {
            'week' => now()->subWeek(),
            'month' => now()->subMonth(),
            'quarter' => now()->subMonths(3),
            default => now()->subMonth(),
        };

        // استخراج الهاشتاقات من المنشورات
        $posts = DB::table('posts')
            ->where('user_id', $user->id)
            ->where('created_at', '>=', $startDate)
            ->whereNotNull('content')
            ->select(['content', 'engagement_count', 'reach_count'])
            ->get();

        $hashtagStats = [];

        foreach ($posts as $post) {
            preg_match_all('/#(\w+)/u', $post->content ?? '', $matches);
            $hashtags = $matches[1] ?? [];

            foreach ($hashtags as $hashtag) {
                $hashtag = mb_strtolower($hashtag);
                if (!isset($hashtagStats[$hashtag])) {
                    $hashtagStats[$hashtag] = [
                        'hashtag' => '#' . $hashtag,
                        'usage_count' => 0,
                        'total_engagement' => 0,
                        'total_reach' => 0,
                    ];
                }
                $hashtagStats[$hashtag]['usage_count']++;
                $hashtagStats[$hashtag]['total_engagement'] += $post->engagement_count ?? 0;
                $hashtagStats[$hashtag]['total_reach'] += $post->reach_count ?? 0;
            }
        }

        // حساب المتوسطات وترتيب النتائج
        $hashtagStats = collect($hashtagStats)->map(function ($stat) {
            $stat['avg_engagement'] = $stat['usage_count'] > 0
                ? round($stat['total_engagement'] / $stat['usage_count'], 1)
                : 0;
            $stat['engagement_rate'] = $stat['total_reach'] > 0
                ? round(($stat['total_engagement'] / $stat['total_reach']) * 100, 2)
                : 0;
            return $stat;
        })->sortByDesc('avg_engagement')->values()->take(20);

        return response()->json([
            'success' => true,
            'data' => [
                'hashtags' => $hashtagStats,
                'period' => $period,
                'total_unique_hashtags' => count($hashtagStats),
            ],
        ]);
    }

    /**
     * GET /api/analytics/recommendations
     * توصيات لتحسين الأداء
     */
    public function getRecommendations(Request $request): JsonResponse
    {
        $user = $request->user();

        $recommendations = [];

        // تحليل أفضل أوقات النشر
        $bestHours = DB::table('posts')
            ->where('user_id', $user->id)
            ->where('created_at', '>=', now()->subMonths(3))
            ->selectRaw('HOUR(created_at) as hour')
            ->selectRaw('AVG(engagement_count) as avg_engagement')
            ->groupBy('hour')
            ->orderByDesc('avg_engagement')
            ->limit(3)
            ->get();

        if ($bestHours->count() > 0) {
            $recommendations[] = [
                'type' => 'timing',
                'title' => 'أفضل أوقات النشر',
                'description' => 'بناءً على تحليل منشوراتك السابقة',
                'data' => $bestHours->map(fn($h) => sprintf('%02d:00', $h->hour))->toArray(),
                'priority' => 'high',
            ];
        }

        // تحليل أفضل أنواع المحتوى
        $bestContentTypes = DB::table('posts')
            ->where('user_id', $user->id)
            ->where('created_at', '>=', now()->subMonths(3))
            ->select('media_type')
            ->selectRaw('AVG(engagement_count) as avg_engagement')
            ->groupBy('media_type')
            ->orderByDesc('avg_engagement')
            ->first();

        if ($bestContentTypes) {
            $recommendations[] = [
                'type' => 'content_type',
                'title' => 'نوع المحتوى الأفضل أداءً',
                'description' => "المحتوى من نوع {$bestContentTypes->media_type} يحقق أفضل تفاعل",
                'data' => $bestContentTypes->media_type,
                'priority' => 'medium',
            ];
        }

        // تحليل تكرار النشر
        $postsPerWeek = DB::table('posts')
            ->where('user_id', $user->id)
            ->where('created_at', '>=', now()->subMonth())
            ->count() / 4;

        if ($postsPerWeek < 3) {
            $recommendations[] = [
                'type' => 'frequency',
                'title' => 'زيادة تكرار النشر',
                'description' => 'ننصح بالنشر 3-5 مرات أسبوعياً للحفاظ على التفاعل',
                'data' => ['current' => round($postsPerWeek, 1), 'recommended' => '3-5'],
                'priority' => 'high',
            ];
        }

        // تحليل استخدام الهاشتاقات
        $avgHashtags = DB::table('posts')
            ->where('user_id', $user->id)
            ->where('created_at', '>=', now()->subMonth())
            ->selectRaw("AVG(LENGTH(content) - LENGTH(REPLACE(content, '#', ''))) as avg_hashtags")
            ->first();

        if (($avgHashtags->avg_hashtags ?? 0) < 3) {
            $recommendations[] = [
                'type' => 'hashtags',
                'title' => 'استخدم المزيد من الهاشتاقات',
                'description' => 'استخدام 5-10 هاشتاقات مناسبة يزيد من الوصول',
                'data' => ['current' => round($avgHashtags->avg_hashtags ?? 0), 'recommended' => '5-10'],
                'priority' => 'medium',
            ];
        }

        return response()->json([
            'success' => true,
            'data' => [
                'recommendations' => $recommendations,
                'generated_at' => now()->toIso8601String(),
            ],
        ]);
    }

    /**
     * POST /api/analytics/export
     * تصدير تقرير التحليلات
     */
    public function exportAnalytics(Request $request): JsonResponse
    {
        $user = $request->user();
        $type = $request->get('type', 'overview');
        $format = $request->get('format', 'csv');
        $period = $request->get('period', 'month');

        $startDate = match ($period) {
            'week' => now()->subWeek(),
            'month' => now()->subMonth(),
            'quarter' => now()->subMonths(3),
            'year' => now()->subYear(),
            default => now()->subMonth(),
        };

        $data = [];

        switch ($type) {
            case 'posts':
                $data = DB::table('posts')
                    ->where('user_id', $user->id)
                    ->where('created_at', '>=', $startDate)
                    ->select(['id', 'content', 'platform', 'engagement_count', 'reach_count', 'created_at'])
                    ->get()
                    ->toArray();
                break;

            case 'engagement':
                $data = DB::table('posts')
                    ->where('user_id', $user->id)
                    ->where('created_at', '>=', $startDate)
                    ->selectRaw('DATE(created_at) as date')
                    ->selectRaw('SUM(engagement_count) as engagement')
                    ->selectRaw('SUM(reach_count) as reach')
                    ->selectRaw('COUNT(*) as posts')
                    ->groupBy('date')
                    ->orderBy('date')
                    ->get()
                    ->toArray();
                break;

            default:
                $data = [
                    'period' => $period,
                    'generated_at' => now()->toIso8601String(),
                ];
        }

        $exportService = app(\App\Services\ExportService::class);
        $filename = "analytics_{$type}_{$period}_" . date('Y-m-d');

        $result = $format === 'json'
            ? $exportService->exportToJson(collect($data), $filename)
            : $exportService->exportToCsv(collect($data), array_keys((array)($data[0] ?? [])), $filename);

        return response()->json([
            'success' => $result['success'],
            'data' => [
                'url' => $result['url'] ?? null,
                'filename' => $result['filename'] ?? null,
            ],
        ]);
    }
}
