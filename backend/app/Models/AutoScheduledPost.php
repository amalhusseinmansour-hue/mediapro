<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AutoScheduledPost extends Model
{
    protected $fillable = [
        'user_id',
        'content',
        'media_urls',
        'platforms',
        'schedule_time',
        'recurrence_pattern',
        'recurrence_interval',
        'recurrence_end_date',
        'is_active',
        'status',
        'last_posted_at',
        'next_post_at',
        'post_count',
        'metadata',
    ];

    protected $casts = [
        'media_urls' => 'array',
        'platforms' => 'array',
        'schedule_time' => 'datetime',
        'recurrence_end_date' => 'datetime',
        'last_posted_at' => 'datetime',
        'next_post_at' => 'datetime',
        'is_active' => 'boolean',
        'metadata' => 'array',
        'post_count' => 'integer',
    ];

    // Status constants
    const STATUS_PENDING = 'pending';
    const STATUS_ACTIVE = 'active';
    const STATUS_PAUSED = 'paused';
    const STATUS_COMPLETED = 'completed';
    const STATUS_FAILED = 'failed';

    // Recurrence pattern constants
    const PATTERN_ONCE = 'once';
    const PATTERN_DAILY = 'daily';
    const PATTERN_WEEKLY = 'weekly';
    const PATTERN_MONTHLY = 'monthly';
    const PATTERN_CUSTOM = 'custom';

    // Relationships
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id', 'id');
    }

    // Accessors
    public function getStatusTextAttribute(): string
    {
        return match($this->status) {
            self::STATUS_PENDING => 'قيد الانتظار',
            self::STATUS_ACTIVE => 'نشط',
            self::STATUS_PAUSED => 'متوقف مؤقتاً',
            self::STATUS_COMPLETED => 'مكتمل',
            self::STATUS_FAILED => 'فشل',
            default => $this->status,
        };
    }

    public function getRecurrencePatternTextAttribute(): string
    {
        return match($this->recurrence_pattern) {
            self::PATTERN_ONCE => 'مرة واحدة',
            self::PATTERN_DAILY => 'يومي',
            self::PATTERN_WEEKLY => 'أسبوعي',
            self::PATTERN_MONTHLY => 'شهري',
            self::PATTERN_CUSTOM => 'مخصص',
            default => $this->recurrence_pattern,
        };
    }

    // Methods
    public function isPending(): bool
    {
        return $this->status === self::STATUS_PENDING;
    }

    public function isActive(): bool
    {
        return $this->status === self::STATUS_ACTIVE;
    }

    public function isPaused(): bool
    {
        return $this->status === self::STATUS_PAUSED;
    }

    public function isCompleted(): bool
    {
        return $this->status === self::STATUS_COMPLETED;
    }

    public function activate(): bool
    {
        $this->status = self::STATUS_ACTIVE;
        $this->is_active = true;
        return $this->save();
    }

    public function pause(): bool
    {
        $this->status = self::STATUS_PAUSED;
        $this->is_active = false;
        return $this->save();
    }

    public function complete(): bool
    {
        $this->status = self::STATUS_COMPLETED;
        $this->is_active = false;
        return $this->save();
    }

    public function calculateNextPostTime(): void
    {
        if (!$this->last_posted_at) {
            $this->next_post_at = $this->schedule_time;
            return;
        }

        switch ($this->recurrence_pattern) {
            case self::PATTERN_ONCE:
                $this->next_post_at = null;
                $this->complete();
                break;

            case self::PATTERN_DAILY:
                $this->next_post_at = $this->last_posted_at->addDays($this->recurrence_interval ?? 1);
                break;

            case self::PATTERN_WEEKLY:
                $this->next_post_at = $this->last_posted_at->addWeeks($this->recurrence_interval ?? 1);
                break;

            case self::PATTERN_MONTHLY:
                $this->next_post_at = $this->last_posted_at->addMonths($this->recurrence_interval ?? 1);
                break;

            case self::PATTERN_CUSTOM:
                if ($this->recurrence_interval) {
                    $this->next_post_at = $this->last_posted_at->addHours($this->recurrence_interval);
                }
                break;
        }

        // Check if we've passed the end date
        if ($this->recurrence_end_date && $this->next_post_at > $this->recurrence_end_date) {
            $this->complete();
        }

        $this->save();
    }

    public function markAsPosted(): void
    {
        $this->last_posted_at = now();
        $this->post_count = ($this->post_count ?? 0) + 1;
        $this->calculateNextPostTime();
        $this->save();
    }

    public function shouldPost(): bool
    {
        if (!$this->is_active || !$this->isActive()) {
            return false;
        }

        if (!$this->next_post_at) {
            return false;
        }

        return $this->next_post_at <= now();
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('is_active', true)->where('status', self::STATUS_ACTIVE);
    }

    public function scopePending($query)
    {
        return $query->where('status', self::STATUS_PENDING);
    }

    public function scopePaused($query)
    {
        return $query->where('status', self::STATUS_PAUSED);
    }

    public function scopeDueForPosting($query)
    {
        return $query->active()
            ->whereNotNull('next_post_at')
            ->where('next_post_at', '<=', now());
    }

    public function scopeRecent($query)
    {
        return $query->orderBy('created_at', 'desc');
    }
}
