<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Subscription extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'is_plan',
        'name',
        'description',
        'type',
        'price',
        'currency',
        'features',
        'max_accounts',
        'max_posts',
        'ai_features',
        'analytics',
        'scheduling',
        'status',
        'is_active',
        'starts_at',
        'ends_at',
        'cancelled_at',
        'stripe_subscription_id',
        'paypal_subscription_id',
        // Usage tracking fields
        'current_posts_count',
        'posts_reset_date',
        'current_ai_requests_count',
        'ai_requests_reset_date',
        'custom_max_posts',
        'custom_max_ai_requests',
        // AI specific limits
        'max_ai_videos',
        'current_ai_videos_count',
        'max_video_duration',
        'video_quality',
        'max_ai_images',
        'current_ai_images_count',
        'max_ai_texts',
        'current_ai_texts_count',
        'max_social_accounts',
        'max_team_members',
        'priority_processing',
        'advanced_analytics',
    ];

    protected $casts = [
        'is_plan' => 'boolean',
        'features' => 'array',
        'ai_features' => 'boolean',
        'analytics' => 'boolean',
        'scheduling' => 'boolean',
        'is_active' => 'boolean',
        'starts_at' => 'datetime',
        'ends_at' => 'datetime',
        'cancelled_at' => 'datetime',
        'price' => 'decimal:2',
        'posts_reset_date' => 'datetime',
        'ai_requests_reset_date' => 'datetime',
        'priority_processing' => 'boolean',
        'advanced_analytics' => 'boolean',
    ];

    /**
     * علاقة المستخدم
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * علاقة المدفوعات
     */
    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }

    /**
     * علاقة الأرباح
     */
    public function earnings(): HasMany
    {
        return $this->hasMany(Earning::class);
    }

    /**
     * تحقق من أن الاشتراك نشط
     */
    public function isActive(): bool
    {
        return $this->status === 'active'
            && $this->starts_at <= now()
            && ($this->ends_at === null || $this->ends_at >= now());
    }

    /**
     * تحقق من أن الاشتراك منتهي
     */
    public function isExpired(): bool
    {
        return $this->ends_at !== null && $this->ends_at < now();
    }

    /**
     * إلغاء الاشتراك
     */
    public function cancel(): void
    {
        $this->update([
            'status' => 'cancelled',
            'cancelled_at' => now(),
        ]);
    }

    /**
     * تجديد الاشتراك
     */
    public function renew(int $months = 1): void
    {
        $this->update([
            'status' => 'active',
            'ends_at' => now()->addMonths($months),
        ]);
    }

    /**
     * علاقة خطة الاشتراك
     */
    public function subscriptionPlan(): BelongsTo
    {
        return $this->belongsTo(SubscriptionPlan::class, 'subscription_plan_id');
    }

    /**
     * التحقق من وصول حد المنشورات
     */
    public function hasReachedPostsLimit(): bool
    {
        $this->resetCountersIfNeeded();

        $maxPosts = $this->custom_max_posts ?? $this->max_posts ?? 999999;
        return $this->current_posts_count >= $maxPosts;
    }

    /**
     * التحقق من وصول حد AI
     */
    public function hasReachedAILimit(): bool
    {
        $this->resetCountersIfNeeded();

        if (!$this->ai_features) {
            return true; // AI غير متاح أصلاً
        }

        $maxAIRequests = $this->custom_max_ai_requests ?? 999999;

        // إذا كان الحد 999999 أو أكثر فهو غير محدود
        if ($maxAIRequests >= 999999) {
            return false;
        }

        return $this->current_ai_requests_count >= $maxAIRequests;
    }

    /**
     * زيادة عداد المنشورات
     */
    public function incrementPostsCount(): void
    {
        $this->resetCountersIfNeeded();
        $this->increment('current_posts_count');
    }

    /**
     * زيادة عداد AI
     */
    public function incrementAIRequestsCount(): void
    {
        $this->resetCountersIfNeeded();
        $this->increment('current_ai_requests_count');
    }

    /**
     * إعادة تعيين العدادات إذا مر شهر
     */
    public function resetCountersIfNeeded(): void
    {
        $now = now();

        // إعادة تعيين عداد المنشورات
        if ($this->posts_reset_date === null || $this->posts_reset_date < $now) {
            $this->update([
                'current_posts_count' => 0,
                'posts_reset_date' => $now->copy()->addMonth(),
            ]);
        }

        // إعادة تعيين عداد AI
        if ($this->ai_requests_reset_date === null || $this->ai_requests_reset_date < $now) {
            $this->update([
                'current_ai_requests_count' => 0,
                'ai_requests_reset_date' => $now->copy()->addMonth(),
            ]);
        }
    }

    /**
     * الحصول على نسبة استخدام المنشورات
     */
    public function getPostsUsagePercentage(): float
    {
        $this->resetCountersIfNeeded();

        $maxPosts = $this->custom_max_posts ?? $this->max_posts ?? 999999;

        if ($maxPosts >= 999999) {
            return 0; // غير محدود
        }

        return min(100, round(($this->current_posts_count / $maxPosts) * 100, 2));
    }

    /**
     * الحصول على نسبة استخدام AI
     */
    public function getAIUsagePercentage(): float
    {
        $this->resetCountersIfNeeded();

        if (!$this->ai_features) {
            return 100; // غير متاح
        }

        $maxAIRequests = $this->custom_max_ai_requests ?? 999999;

        if ($maxAIRequests >= 999999) {
            return 0; // غير محدود
        }

        return min(100, round(($this->current_ai_requests_count / $maxAIRequests) * 100, 2));
    }

    /**
     * الحصول على المنشورات المتبقية
     */
    public function getRemainingPosts(): int
    {
        $this->resetCountersIfNeeded();

        $maxPosts = $this->custom_max_posts ?? $this->max_posts ?? 999999;

        if ($maxPosts >= 999999) {
            return 999999; // غير محدود
        }

        return max(0, $maxPosts - $this->current_posts_count);
    }

    /**
     * الحصول على طلبات AI المتبقية
     */
    public function getRemainingAIRequests(): int
    {
        $this->resetCountersIfNeeded();

        if (!$this->ai_features) {
            return 0; // غير متاح
        }

        $maxAIRequests = $this->custom_max_ai_requests ?? 999999;

        if ($maxAIRequests >= 999999) {
            return 999999; // غير محدود
        }

        return max(0, $maxAIRequests - $this->current_ai_requests_count);
    }

    // ============== AI Video Limits ==============

    /**
     * التحقق من وصول حد الفيديوهات
     */
    public function hasReachedVideoLimit(): bool
    {
        $this->resetCountersIfNeeded();

        if (!$this->ai_features) {
            return true;
        }

        $maxVideos = $this->max_ai_videos ?? 0;
        if ($maxVideos <= 0) {
            return true; // غير متاح
        }

        return $this->current_ai_videos_count >= $maxVideos;
    }

    /**
     * زيادة عداد الفيديوهات
     */
    public function incrementVideoCount(): void
    {
        $this->resetCountersIfNeeded();
        $this->increment('current_ai_videos_count');
    }

    /**
     * الحصول على الفيديوهات المتبقية
     */
    public function getRemainingVideos(): int
    {
        $this->resetCountersIfNeeded();

        $maxVideos = $this->max_ai_videos ?? 0;
        if ($maxVideos <= 0) {
            return 0;
        }

        return max(0, $maxVideos - $this->current_ai_videos_count);
    }

    /**
     * الحصول على جودة الفيديو المسموحة
     */
    public function getAllowedVideoQuality(): string
    {
        return $this->video_quality ?? '480p';
    }

    /**
     * الحصول على أقصى مدة فيديو
     */
    public function getMaxVideoDuration(): int
    {
        return $this->max_video_duration ?? 4;
    }

    // ============== AI Image Limits ==============

    /**
     * التحقق من وصول حد الصور
     */
    public function hasReachedImageLimit(): bool
    {
        $this->resetCountersIfNeeded();

        if (!$this->ai_features) {
            return true;
        }

        $maxImages = $this->max_ai_images ?? 0;
        if ($maxImages <= 0) {
            return true;
        }

        return $this->current_ai_images_count >= $maxImages;
    }

    /**
     * زيادة عداد الصور
     */
    public function incrementImageCount(): void
    {
        $this->resetCountersIfNeeded();
        $this->increment('current_ai_images_count');
    }

    /**
     * الحصول على الصور المتبقية
     */
    public function getRemainingImages(): int
    {
        $this->resetCountersIfNeeded();

        $maxImages = $this->max_ai_images ?? 0;
        if ($maxImages <= 0) {
            return 0;
        }

        return max(0, $maxImages - $this->current_ai_images_count);
    }

    // ============== AI Text Limits ==============

    /**
     * التحقق من وصول حد النصوص
     */
    public function hasReachedTextLimit(): bool
    {
        $this->resetCountersIfNeeded();

        if (!$this->ai_features) {
            return true;
        }

        $maxTexts = $this->max_ai_texts ?? 0;
        if ($maxTexts <= 0 || $maxTexts >= 999999) {
            return false; // غير محدود
        }

        return $this->current_ai_texts_count >= $maxTexts;
    }

    /**
     * زيادة عداد النصوص
     */
    public function incrementTextCount(): void
    {
        $this->resetCountersIfNeeded();
        $this->increment('current_ai_texts_count');
    }

    /**
     * الحصول على النصوص المتبقية
     */
    public function getRemainingTexts(): int
    {
        $this->resetCountersIfNeeded();

        $maxTexts = $this->max_ai_texts ?? 0;
        if ($maxTexts <= 0 || $maxTexts >= 999999) {
            return 999999; // غير محدود
        }

        return max(0, $maxTexts - $this->current_ai_texts_count);
    }

    // ============== Usage Summary ==============

    /**
     * الحصول على ملخص الاستخدام
     */
    public function getUsageSummary(): array
    {
        $this->resetCountersIfNeeded();

        return [
            'videos' => [
                'used' => $this->current_ai_videos_count ?? 0,
                'limit' => $this->max_ai_videos ?? 0,
                'remaining' => $this->getRemainingVideos(),
                'quality' => $this->getAllowedVideoQuality(),
                'max_duration' => $this->getMaxVideoDuration(),
            ],
            'images' => [
                'used' => $this->current_ai_images_count ?? 0,
                'limit' => $this->max_ai_images ?? 0,
                'remaining' => $this->getRemainingImages(),
            ],
            'texts' => [
                'used' => $this->current_ai_texts_count ?? 0,
                'limit' => $this->max_ai_texts ?? 0,
                'remaining' => $this->getRemainingTexts(),
                'unlimited' => ($this->max_ai_texts ?? 0) >= 999999,
            ],
            'posts' => [
                'used' => $this->current_posts_count ?? 0,
                'limit' => $this->max_posts ?? 0,
                'remaining' => $this->getRemainingPosts(),
            ],
            'social_accounts' => [
                'limit' => $this->max_social_accounts ?? 1,
            ],
            'team_members' => [
                'limit' => $this->max_team_members ?? 1,
            ],
            'features' => [
                'priority_processing' => $this->priority_processing ?? false,
                'advanced_analytics' => $this->advanced_analytics ?? false,
            ],
        ];
    }
}
