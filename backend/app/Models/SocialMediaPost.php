<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class SocialMediaPost extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'content',
        'platforms',
        'media',
        'media_type',
        'link',
        'status',
        'scheduled_at',
        'published_at',
        'publish_results',
        'error_message',
    ];

    protected $casts = [
        'platforms' => 'array',
        'media' => 'array',
        'publish_results' => 'array',
        'scheduled_at' => 'datetime',
        'published_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    protected $appends = [
        'status_label',
        'is_scheduled',
        'is_published',
        'is_failed',
    ];

    /**
     * العلاقة مع المستخدم
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * العلاقة مع منشورات المنصات
     */
    public function platformPosts(): HasMany
    {
        return $this->hasMany(PlatformPost::class);
    }

    /**
     * الحصول على تسمية الحالة
     */
    public function getStatusLabelAttribute(): string
    {
        return match($this->status) {
            'draft' => 'مسودة',
            'scheduled' => 'مجدول',
            'published' => 'منشور',
            'failed' => 'فشل',
            default => $this->status,
        };
    }

    /**
     * التحقق من كون المنشور مجدول
     */
    public function getIsScheduledAttribute(): bool
    {
        return $this->status === 'scheduled';
    }

    /**
     * التحقق من كون المنشور منشور
     */
    public function getIsPublishedAttribute(): bool
    {
        return $this->status === 'published';
    }

    /**
     * التحقق من كون المنشور فاشل
     */
    public function getIsFailedAttribute(): bool
    {
        return $this->status === 'failed';
    }

    /**
     * Scope للمنشورات المجدولة
     */
    public function scopeScheduled($query)
    {
        return $query->where('status', 'scheduled');
    }

    /**
     * Scope للمنشورات المنشورة
     */
    public function scopePublished($query)
    {
        return $query->where('status', 'published');
    }

    /**
     * Scope للمنشورات الفاشلة
     */
    public function scopeFailed($query)
    {
        return $query->where('status', 'failed');
    }

    /**
     * Scope للمنشورات المسودة
     */
    public function scopeDraft($query)
    {
        return $query->where('status', 'draft');
    }

    /**
     * الحصول على عدد المنصات الناجحة
     */
    public function getSuccessfulPlatformsCount(): int
    {
        return $this->platformPosts()->where('status', 'published')->count();
    }

    /**
     * الحصول على عدد المنصات الفاشلة
     */
    public function getFailedPlatformsCount(): int
    {
        return $this->platformPosts()->where('status', 'failed')->count();
    }

    /**
     * التحقق من كون المنشور يحتوي على صور
     */
    public function hasMedia(): bool
    {
        return !empty($this->media) && count($this->media) > 0;
    }

    /**
     * الحصول على أول صورة
     */
    public function getFirstMedia(): ?string
    {
        if ($this->hasMedia()) {
            return $this->media[0] ?? null;
        }
        return null;
    }
}
