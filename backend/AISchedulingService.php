<?php

namespace App\Services;

use App\Models\AutoScheduledPost;
use App\Models\ScheduledPost;
use App\Models\User;
use App\Models\SocialAccount;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

/**
 * AI Scheduling Service
 *
 * خدمة ذكية لجدولة المنشورات تلقائياً باستخدام الذكاء الاصطناعي
 * تقوم بتحليل:
 * - أفضل أوقات النشر لكل منصة
 * - تاريخ النشر السابق
 * - معدل التفاعل
 * - الجمهور المستهدف
 */
class AISchedulingService
{
    protected AdvancedAIService $aiService;
    protected UltimateAgentService $agentService;

    public function __construct()
    {
        $this->aiService = app(AdvancedAIService::class);
        $this->agentService = app(UltimateAgentService::class);
    }

    /**
     * جدولة منشور تلقائياً باستخدام AI
     *
     * @param User $user المستخدم
     * @param string $content محتوى المنشور
     * @param array $platforms المنصات المستهدفة
     * @param array $options خيارات إضافية
     * @return AutoScheduledPost
     */
    public function schedulePost(User $user, string $content, array $platforms, array $options = []): AutoScheduledPost
    {
        // 1. تحليل المحتوى بالAI لتحديد أفضل وقت للنشر
        $aiAnalysis = $this->analyzeContentForScheduling($content, $platforms, $user);

        // 2. الحصول على أفضل أوقات النشر لكل منصة
        $bestTimes = $this->getBestPostingTimes($platforms, $user);

        // 3. إنشاء جدول نشر ذكي
        $scheduledTime = $this->calculateOptimalPostingTime($aiAnalysis, $bestTimes, $options);

        // 4. إنشاء AutoScheduledPost
        $autoPost = AutoScheduledPost::create([
            'user_id' => $user->id,
            'content' => $content,
            'platforms' => $platforms,
            'scheduled_at' => $scheduledTime,
            'ai_analysis' => $aiAnalysis,
            'status' => 'pending',
            'auto_generated' => true,
            'media_urls' => $options['media_urls'] ?? [],
            'hashtags' => $this->generateSmartHashtags($content, $platforms),
            'optimal_time_reason' => $aiAnalysis['scheduling_reason'] ?? 'AI optimized timing',
        ]);

        // 5. إنشاء ScheduledPost لكل منصة
        $this->createScheduledPostsForPlatforms($autoPost, $platforms, $user);

        Log::info("AI Scheduled Post created", [
            'post_id' => $autoPost->id,
            'scheduled_at' => $scheduledTime,
            'platforms' => $platforms
        ]);

        return $autoPost;
    }

    /**
     * توليد منشور + جدولته تلقائياً
     *
     * @param User $user
     * @param string $topic موضوع المنشور
     * @param array $platforms
     * @param array $options
     * @return AutoScheduledPost
     */
    public function generateAndSchedule(User $user, string $topic, array $platforms, array $options = []): AutoScheduledPost
    {
        // 1. توليد محتوى بالAI
        $content = $this->aiService->generateSocialMediaContent([
            'topic' => $topic,
            'platforms' => $platforms,
            'tone' => $options['tone'] ?? 'professional',
            'length' => $options['length'] ?? 'medium',
        ]);

        // 2. توليد صورة إن لم تكن موجودة
        $mediaUrls = $options['media_urls'] ?? [];
        if (empty($mediaUrls) && ($options['generate_image'] ?? true)) {
            try {
                $imageResult = $this->agentService
                    ->forUser($user)
                    ->createImage(
                        $topic,
                        'auto_generated_' . time() . '.png'
                    );

                if ($imageResult['success'] ?? false) {
                    $mediaUrls[] = $imageResult['url'];
                }
            } catch (\Exception $e) {
                Log::warning("Failed to generate image for auto post: " . $e->getMessage());
            }
        }

        // 3. جدولة المنشور
        return $this->schedulePost($user, $content, $platforms, array_merge($options, [
            'media_urls' => $mediaUrls,
        ]));
    }

    /**
     * جدولة متعددة - جدولة عدة منشورات على مدى فترة زمنية
     *
     * @param User $user
     * @param array $topics مواضيع المنشورات
     * @param array $platforms
     * @param int $daysSpread عدد الأيام لتوزيع المنشورات
     * @return array
     */
    public function scheduleMultiplePosts(User $user, array $topics, array $platforms, int $daysSpread = 7): array
    {
        $scheduledPosts = [];
        $interval = $daysSpread * 24 * 60 / count($topics); // minutes per post

        foreach ($topics as $index => $topic) {
            $baseTime = Carbon::now()->addMinutes($interval * $index);

            $post = $this->generateAndSchedule($user, $topic, $platforms, [
                'preferred_time' => $baseTime,
                'allow_time_adjustment' => true,
            ]);

            $scheduledPosts[] = $post;

            // Sleep to avoid rate limiting
            usleep(500000); // 0.5 seconds
        }

        return $scheduledPosts;
    }

    /**
     * تحليل المحتوى بالAI لتحديد أفضل وقت للنشر
     */
    protected function analyzeContentForScheduling(string $content, array $platforms, User $user): array
    {
        try {
            $prompt = "Analyze this social media post and suggest the best posting time. Consider:\n";
            $prompt .= "- Content type and topic\n";
            $prompt .= "- Target platforms: " . implode(', ', $platforms) . "\n";
            $prompt .= "- Engagement patterns\n\n";
            $prompt .= "Post content: " . $content . "\n\n";
            $prompt .= "Provide:\n";
            $prompt .= "1. Best time of day (morning/afternoon/evening/night)\n";
            $prompt .= "2. Best day of week\n";
            $prompt .= "3. Reason for this timing\n";
            $prompt .= "4. Expected engagement level (low/medium/high)\n";
            $prompt .= "Return as JSON format.";

            $response = $this->aiService->generateText($prompt, [
                'max_tokens' => 300,
                'temperature' => 0.7,
            ]);

            // محاولة تحويل النص إلى JSON
            $jsonMatch = preg_match('/\{.*\}/s', $response, $matches);
            if ($jsonMatch) {
                $analysis = json_decode($matches[0], true);
                if ($analysis) {
                    return $analysis;
                }
            }

            // Fallback analysis
            return [
                'best_time_of_day' => 'afternoon',
                'best_day_of_week' => 'wednesday',
                'scheduling_reason' => 'Default optimal time based on general engagement patterns',
                'expected_engagement' => 'medium'
            ];

        } catch (\Exception $e) {
            Log::error("AI scheduling analysis failed: " . $e->getMessage());

            return [
                'best_time_of_day' => 'afternoon',
                'best_day_of_week' => 'wednesday',
                'scheduling_reason' => 'Fallback: General best practices',
                'expected_engagement' => 'medium'
            ];
        }
    }

    /**
     * الحصول على أفضل أوقات النشر بناءً على البيانات التاريخية
     */
    protected function getBestPostingTimes(array $platforms, User $user): array
    {
        $bestTimes = [];

        foreach ($platforms as $platform) {
            // جلب المنشورات السابقة للمستخدم على هذه المنصة
            $historicalPosts = ScheduledPost::where('user_id', $user->id)
                ->where('platform', $platform)
                ->where('status', 'published')
                ->whereNotNull('published_at')
                ->orderBy('published_at', 'desc')
                ->limit(50)
                ->get();

            if ($historicalPosts->count() > 10) {
                // تحليل أوقات النشر الناجحة
                $timeAnalysis = $historicalPosts->groupBy(function($post) {
                    return $post->published_at->hour;
                });

                $bestHour = $timeAnalysis->sortByDesc->count()->keys()->first() ?? 14;
            } else {
                // أوقات افتراضية مثالية لكل منصة
                $bestHour = match($platform) {
                    'instagram' => 18, // 6 PM
                    'facebook' => 13,  // 1 PM
                    'twitter' => 12,   // 12 PM
                    'linkedin' => 10,  // 10 AM
                    'tiktok' => 19,    // 7 PM
                    'youtube' => 15,   // 3 PM
                    default => 14,     // 2 PM
                };
            }

            $bestTimes[$platform] = [
                'hour' => $bestHour,
                'minute' => 0,
                'timezone' => $user->timezone ?? 'UTC',
            ];
        }

        return $bestTimes;
    }

    /**
     * حساب أفضل وقت للنشر بناءً على التحليل
     */
    protected function calculateOptimalPostingTime(array $aiAnalysis, array $platformTimes, array $options = []): Carbon
    {
        // إذا كان هناك وقت مفضل من المستخدم
        if (isset($options['preferred_time'])) {
            $baseTime = Carbon::parse($options['preferred_time']);

            // السماح بتعديل الوقت إذا كان مسموحاً
            if ($options['allow_time_adjustment'] ?? true) {
                return $this->adjustTimeBasedOnAI($baseTime, $aiAnalysis);
            }

            return $baseTime;
        }

        // حساب الوقت الأمثل من تحليل AI + البيانات التاريخية
        $now = Carbon::now();

        // تحديد اليوم الأمثل
        $targetDay = $this->getNextBestDay($aiAnalysis['best_day_of_week'] ?? 'wednesday');

        // تحديد الساعة الأمثل (متوسط أفضل أوقات كل المنصات)
        $avgHour = collect($platformTimes)->avg('hour');
        $targetHour = round($avgHour);

        // تعديل بناءً على AI
        $targetHour = $this->adjustHourBasedOnTimeOfDay(
            $targetHour,
            $aiAnalysis['best_time_of_day'] ?? 'afternoon'
        );

        return $targetDay->setTime($targetHour, 0);
    }

    /**
     * الحصول على أقرب يوم مطابق لليوم المطلوب
     */
    protected function getNextBestDay(string $dayName): Carbon
    {
        $dayMap = [
            'sunday' => 0,
            'monday' => 1,
            'tuesday' => 2,
            'wednesday' => 3,
            'thursday' => 4,
            'friday' => 5,
            'saturday' => 6,
        ];

        $targetDayNum = $dayMap[strtolower($dayName)] ?? 3;
        $now = Carbon::now();
        $currentDayNum = $now->dayOfWeek;

        $daysUntilTarget = ($targetDayNum - $currentDayNum + 7) % 7;

        if ($daysUntilTarget == 0 && $now->hour >= 20) {
            $daysUntilTarget = 7; // Next week
        }

        return $now->addDays($daysUntilTarget);
    }

    /**
     * تعديل الساعة بناءً على الفترة المطلوبة
     */
    protected function adjustHourBasedOnTimeOfDay(int $hour, string $timeOfDay): int
    {
        $ranges = [
            'morning' => [8, 11],
            'afternoon' => [12, 17],
            'evening' => [18, 21],
            'night' => [22, 23],
        ];

        $range = $ranges[$timeOfDay] ?? $ranges['afternoon'];

        // إذا كانت الساعة خارج النطاق، عدّلها
        if ($hour < $range[0]) {
            return $range[0];
        } else if ($hour > $range[1]) {
            return $range[1];
        }

        return $hour;
    }

    /**
     * تعديل الوقت بناءً على تحليل AI
     */
    protected function adjustTimeBasedOnAI(Carbon $baseTime, array $aiAnalysis): Carbon
    {
        $timeOfDay = $aiAnalysis['best_time_of_day'] ?? 'afternoon';

        $adjustedHour = $this->adjustHourBasedOnTimeOfDay($baseTime->hour, $timeOfDay);

        return $baseTime->setTime($adjustedHour, 0);
    }

    /**
     * توليد هاشتاجات ذكية للمنشور
     */
    protected function generateSmartHashtags(string $content, array $platforms): array
    {
        try {
            $prompt = "Generate 5-10 relevant hashtags for this social media post:\n\n";
            $prompt .= $content . "\n\n";
            $prompt .= "Platforms: " . implode(', ', $platforms) . "\n";
            $prompt .= "Return only the hashtags, one per line, starting with #";

            $response = $this->aiService->generateText($prompt, [
                'max_tokens' => 150,
                'temperature' => 0.8,
            ]);

            // استخراج الهاشتاجات
            preg_match_all('/#\w+/', $response, $matches);
            $hashtags = $matches[0] ?? [];

            // إزالة التكرار وترتيبها
            return array_values(array_unique($hashtags));

        } catch (\Exception $e) {
            Log::warning("Failed to generate hashtags: " . $e->getMessage());
            return [];
        }
    }

    /**
     * إنشاء منشورات مجدولة لكل منصة
     */
    protected function createScheduledPostsForPlatforms(AutoScheduledPost $autoPost, array $platforms, User $user): void
    {
        foreach ($platforms as $platform) {
            // الحصول على حساب المنصة للمستخدم
            $socialAccount = SocialAccount::where('user_id', $user->id)
                ->where('platform', $platform)
                ->first();

            if (!$socialAccount) {
                Log::warning("No social account found for platform: $platform (user: {$user->id})");
                continue;
            }

            ScheduledPost::create([
                'user_id' => $user->id,
                'social_account_id' => $socialAccount->id,
                'platform' => $platform,
                'content' => $autoPost->content,
                'media_urls' => $autoPost->media_urls,
                'scheduled_at' => $autoPost->scheduled_at,
                'status' => 'pending',
                'auto_scheduled_post_id' => $autoPost->id,
            ]);
        }
    }

    /**
     * الحصول على إحصائيات الجدولة التلقائية للمستخدم
     */
    public function getUserSchedulingStats(User $user): array
    {
        $stats = [
            'total_scheduled' => 0,
            'pending' => 0,
            'published' => 0,
            'failed' => 0,
            'avg_engagement' => 0,
            'best_performing_time' => null,
            'best_performing_platform' => null,
        ];

        $autoPosts = AutoScheduledPost::where('user_id', $user->id)->get();

        $stats['total_scheduled'] = $autoPosts->count();
        $stats['pending'] = $autoPosts->where('status', 'pending')->count();
        $stats['published'] = $autoPosts->where('status', 'published')->count();
        $stats['failed'] = $autoPosts->where('status', 'failed')->count();

        // تحليل أفضل الأوقات والمنصات
        $published = $autoPosts->where('status', 'published');

        if ($published->count() > 0) {
            // أفضل وقت
            $timeGroups = $published->groupBy(function($post) {
                return $post->scheduled_at->format('H:00');
            });

            $stats['best_performing_time'] = $timeGroups->sortByDesc->count()->keys()->first();

            // أفضل منصة
            $platformCounts = [];
            foreach ($published as $post) {
                foreach ($post->platforms as $platform) {
                    $platformCounts[$platform] = ($platformCounts[$platform] ?? 0) + 1;
                }
            }

            arsort($platformCounts);
            $stats['best_performing_platform'] = array_key_first($platformCounts);
        }

        return $stats;
    }
}
