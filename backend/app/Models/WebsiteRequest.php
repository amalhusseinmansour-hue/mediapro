<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WebsiteRequest extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'name',
        'email',
        'phone',
        'company_name',
        'website_type',
        'description',
        'budget',
        'currency',
        'deadline',
        'features',
        'status',
        'admin_notes',
    ];

    protected $casts = [
        'features' => 'array',
        'deadline' => 'date',
        'budget' => 'decimal:2',
    ];

    /**
     * Get the website type in Arabic
     */
    public function getWebsiteTypeArabicAttribute(): string
    {
        $types = [
            'corporate' => 'موقع شركة',
            'ecommerce' => 'متجر إلكتروني',
            'blog' => 'مدونة',
            'portfolio' => 'معرض أعمال',
            'custom' => 'مخصص',
        ];

        return $types[$this->website_type] ?? $this->website_type;
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
     * Get the user that made this request
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
