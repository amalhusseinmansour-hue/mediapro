<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SupportTicket extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'name',
        'email',
        'phone',
        'whatsapp_number',
        'subject',
        'message',
        'category',
        'priority',
        'status',
        'admin_notes',
        'assigned_to',
        'resolved_at',
    ];

    protected $casts = [
        'resolved_at' => 'datetime',
    ];

    /**
     * Get the user that owns the ticket
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the admin assigned to this ticket
     */
    public function assignedAdmin(): BelongsTo
    {
        return $this->belongsTo(User::class, 'assigned_to');
    }

    /**
     * Get category in Arabic
     */
    public function getCategoryArabicAttribute(): string
    {
        $categories = [
            'technical' => 'دعم تقني',
            'billing' => 'فواتير',
            'feature' => 'طلب ميزة',
            'bug' => 'بلاغ عن خطأ',
            'account' => 'حساب المستخدم',
            'other' => 'أخرى',
        ];

        return $categories[$this->category] ?? $this->category;
    }

    /**
     * Get priority in Arabic
     */
    public function getPriorityArabicAttribute(): string
    {
        $priorities = [
            'low' => 'منخفضة',
            'medium' => 'متوسطة',
            'high' => 'عالية',
            'urgent' => 'عاجلة',
        ];

        return $priorities[$this->priority] ?? $this->priority;
    }

    /**
     * Get status in Arabic
     */
    public function getStatusArabicAttribute(): string
    {
        $statuses = [
            'open' => 'مفتوحة',
            'in_progress' => 'قيد المعالجة',
            'resolved' => 'محلولة',
            'closed' => 'مغلقة',
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
     * Scope to filter by priority
     */
    public function scopeByPriority($query, $priority)
    {
        return $query->where('priority', $priority);
    }

    /**
     * Scope to get open tickets
     */
    public function scopeOpen($query)
    {
        return $query->where('status', 'open');
    }

    /**
     * Scope to get unresolved tickets
     */
    public function scopeUnresolved($query)
    {
        return $query->whereIn('status', ['open', 'in_progress']);
    }
}
