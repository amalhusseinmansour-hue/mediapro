<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PlatformPost extends Model
{
    use HasFactory;

    protected $fillable = [
        'social_media_post_id',
        'platform',
        'platform_post_id',
        'platform_url',
        'status',
        'error_message',
    ];

    protected $casts = [
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected $appends = [
        'status_label',
        'platform_label',
    ];

    /**
     * العلاقة مع المنشور الرئيسي
     */
    public function socialMediaPost(): BelongsTo
    {
        return $this->belongsTo(SocialMediaPost::class);
    }

    /**
     * الحصول على تسمية الحالة
     */
    public function getStatusLabelAttribute(): string
    {
        return match($this->status) {
            'pending' => 'قيد الانتظار',
            'published' => 'منشور',
            'failed' => 'فشل',
            default => $this->status,
        };
    }

    /**
     * الحصول على تسمية المنصة
     */
    public function getPlatformLabelAttribute(): string
    {
        return match($this->platform) {
            'facebook' => 'فيسبوك',
            'twitter' => 'تويتر',
            'instagram' => 'إنستقرام',
            'linkedin' => 'لينكد إن',
            'tiktok' => 'تيك توك',
            'youtube' => 'يوتيوب',
            'pinterest' => 'بينترست',
            'snapchat' => 'سناب شات',
            default => $this->platform,
        };
    }

    /**
     * الحصول على أيقونة المنصة
     */
    public function getPlatformIcon(): string
    {
        return match($this->platform) {
            'facebook' => 'heroicon-o-globe-alt',
            'twitter' => 'heroicon-o-chat-bubble-left',
            'instagram' => 'heroicon-o-camera',
            'linkedin' => 'heroicon-o-briefcase',
            'tiktok' => 'heroicon-o-musical-note',
            'youtube' => 'heroicon-o-video-camera',
            'pinterest' => 'heroicon-o-photo',
            'snapchat' => 'heroicon-o-bolt',
            default => 'heroicon-o-globe-alt',
        };
    }

    /**
     * الحصول على لون المنصة
     */
    public function getPlatformColor(): string
    {
        return match($this->platform) {
            'facebook' => 'primary',
            'twitter' => 'info',
            'instagram' => 'danger',
            'linkedin' => 'success',
            'tiktok' => 'warning',
            'youtube' => 'danger',
            'pinterest' => 'primary',
            'snapchat' => 'warning',
            default => 'gray',
        };
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
     * Scope للمنشورات قيد الانتظار
     */
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    /**
     * التحقق من النجاح
     */
    public function isPublished(): bool
    {
        return $this->status === 'published';
    }

    /**
     * التحقق من الفشل
     */
    public function isFailed(): bool
    {
        return $this->status === 'failed';
    }

    /**
     * التحقق من الانتظار
     */
    public function isPending(): bool
    {
        return $this->status === 'pending';
    }
}
