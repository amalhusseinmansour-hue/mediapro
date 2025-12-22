<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class SponsoredAdRequest extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'name',
        'email',
        'phone',
        'company_name',
        'ad_platform',
        'ad_type',
        'target_audience',
        'budget',
        'currency',
        'duration_days',
        'start_date',
        'ad_content',
        'targeting_options',
        'status',
        'admin_notes',
    ];

    protected $casts = [
        'targeting_options' => 'array',
        'start_date' => 'date',
        'budget' => 'decimal:2',
    ];

    /**
     * Get the ad platform in Arabic
     */
    public function getAdPlatformArabicAttribute(): string
    {
        $platforms = [
            'facebook' => 'فيسبوك',
            'instagram' => 'إنستغرام',
            'google' => 'جوجل',
            'tiktok' => 'تيك توك',
            'twitter' => 'تويتر (X)',
            'linkedin' => 'لينكد إن',
            'snapchat' => 'سناب شات',
            'multiple' => 'عدة منصات',
        ];

        return $platforms[$this->ad_platform] ?? $this->ad_platform;
    }

    /**
     * Get the ad type in Arabic
     */
    public function getAdTypeArabicAttribute(): string
    {
        $types = [
            'awareness' => 'زيادة الوعي',
            'traffic' => 'زيادة الزيارات',
            'engagement' => 'زيادة التفاعل',
            'leads' => 'جمع العملاء المحتملين',
            'sales' => 'زيادة المبيعات',
            'app_installs' => 'تثبيت التطبيق',
        ];

        return $types[$this->ad_type] ?? $this->ad_type;
    }

    /**
     * Get the status in Arabic
     */
    public function getStatusArabicAttribute(): string
    {
        $statuses = [
            'pending' => 'قيد الانتظار',
            'reviewing' => 'قيد المراجعة',
            'accepted' => 'مقبول',
            'rejected' => 'مرفوض',
            'running' => 'قيد التنفيذ',
            'completed' => 'مكتمل',
        ];

        return $statuses[$this->status] ?? $this->status;
    }

    /**
     * Scope to filter by status
     */
    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    /**
     * Scope to get pending requests
     */
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    /**
     * Scope to filter by platform
     */
    public function scopeByPlatform($query, $platform)
    {
        return $query->where('ad_platform', $platform);
    }

    /**
     * العلاقة مع المستخدم
     */
    public function user()
    {
        return $this->belongsTo(\App\Models\User::class);
    }
}
