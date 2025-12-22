<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class AutomationRule extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'name',
        'description',
        'rule_type',
        'trigger_config',
        'action_config',
        'platforms',
        'account_ids',
        'frequency',
        'schedule_pattern',
        'time_of_day',
        'timezone',
        'start_date',
        'end_date',
        'last_executed_at',
        'next_execution_at',
        'content_pool',
        'current_content_index',
        'status',
        'execution_count',
        'max_executions',
        'failed_executions',
        'last_error',
        'conditions',
    ];

    protected $casts = [
        'trigger_config' => 'array',
        'action_config' => 'array',
        'platforms' => 'array',
        'account_ids' => 'array',
        'schedule_pattern' => 'array',
        'start_date' => 'date',
        'end_date' => 'date',
        'last_executed_at' => 'datetime',
        'next_execution_at' => 'datetime',
        'content_pool' => 'array',
        'current_content_index' => 'integer',
        'execution_count' => 'integer',
        'max_executions' => 'integer',
        'failed_executions' => 'integer',
        'conditions' => 'array',
    ];

    /**
     * Relationships
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function scheduledPosts(): HasMany
    {
        return $this->hasMany(ScheduledPost::class);
    }

    public function logs(): HasMany
    {
        return $this->hasMany(PostLog::class);
    }

    /**
     * Scopes
     */
    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopeDue($query)
    {
        return $query->where('status', 'active')
            ->where('next_execution_at', '<=', now())
            ->where(function ($q) {
                $q->whereNull('start_date')
                    ->orWhere('start_date', '<=', now());
            })
            ->where(function ($q) {
                $q->whereNull('end_date')
                    ->orWhere('end_date', '>=', now());
            })
            ->where(function ($q) {
                $q->whereNull('max_executions')
                    ->orWhereRaw('execution_count < max_executions');
            });
    }

    public function scopeForUser($query, int $userId)
    {
        return $query->where('user_id', $userId);
    }

    public function scopeOfType($query, string $type)
    {
        return $query->where('rule_type', $type);
    }

    /**
     * Helper methods
     */
    public function isDue(): bool
    {
        if ($this->status !== 'active') {
            return false;
        }

        if ($this->next_execution_at?->isFuture()) {
            return false;
        }

        if ($this->start_date && $this->start_date->isFuture()) {
            return false;
        }

        if ($this->end_date && $this->end_date->isPast()) {
            return false;
        }

        if ($this->max_executions && $this->execution_count >= $this->max_executions) {
            return false;
        }

        return true;
    }

    public function execute(): void
    {
        $this->increment('execution_count');
        $this->update([
            'last_executed_at' => now(),
            'next_execution_at' => $this->calculateNextExecution(),
        ]);

        // Check if rule should be completed
        if ($this->max_executions && $this->execution_count >= $this->max_executions) {
            $this->update(['status' => 'completed']);
        }

        if ($this->end_date && $this->end_date->isPast()) {
            $this->update(['status' => 'completed']);
        }
    }

    public function markAsFailed(string $error): void
    {
        $this->increment('failed_executions');
        $this->update([
            'last_error' => $error,
            'status' => $this->failed_executions >= 5 ? 'failed' : $this->status,
        ]);
    }

    public function getNextContent(): ?array
    {
        if (!$this->content_pool || empty($this->content_pool)) {
            return null;
        }

        $content = $this->content_pool[$this->current_content_index] ?? null;

        // Move to next content index
        $nextIndex = ($this->current_content_index + 1) % count($this->content_pool);
        $this->update(['current_content_index' => $nextIndex]);

        return $content;
    }

    private function calculateNextExecution(): ?\DateTime
    {
        if (!$this->frequency) {
            return null;
        }

        $timezone = new \DateTimeZone($this->timezone);
        $now = now()->setTimezone($timezone);

        switch ($this->frequency) {
            case 'daily':
                $next = $now->addDay();
                break;
            case 'weekly':
                $next = $now->addWeek();
                break;
            case 'monthly':
                $next = $now->addMonth();
                break;
            case 'custom':
                // Use schedule_pattern for custom scheduling
                $next = $this->calculateCustomSchedule();
                break;
            default:
                return null;
        }

        // Set time of day if specified
        if ($this->time_of_day) {
            $time = explode(':', $this->time_of_day);
            $next->setTime((int)$time[0], (int)$time[1]);
        }

        return $next;
    }

    private function calculateCustomSchedule(): ?\DateTime
    {
        // Implement custom schedule logic based on schedule_pattern
        // This could use cron expression parsing or custom logic
        return now()->addDay(); // Placeholder
    }
}
