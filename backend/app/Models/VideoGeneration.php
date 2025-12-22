<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class VideoGeneration extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'provider',
        'task_id',
        'prompt',
        'image_url',
        'options',
        'status',
        'progress',
        'video_url',
        'thumbnail_url',
        'duration',
        'error_message',
        'cost',
        'started_at',
        'completed_at',
    ];

    protected $casts = [
        'options' => 'array',
        'cost' => 'decimal:4',
        'progress' => 'integer',
        'duration' => 'integer',
        'started_at' => 'datetime',
        'completed_at' => 'datetime',
    ];

    protected $appends = [
        'status_label',
        'provider_label',
        'is_completed',
        'is_failed',
    ];

    /**
     * Relationship with user
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get status label
     */
    public function getStatusLabelAttribute(): string
    {
        return match($this->status) {
            'pending' => 'قيد الانتظار',
            'processing' => 'جاري المعالجة',
            'completed' => 'مكتمل',
            'failed' => 'فشل',
            'cancelled' => 'ملغي',
            default => $this->status,
        };
    }

    /**
     * Get provider label
     */
    public function getProviderLabelAttribute(): string
    {
        return match($this->provider) {
            'runway' => 'Runway ML',
            'replicate' => 'Replicate',
            'stability' => 'Stability AI',
            'pika' => 'Pika Labs',
            'did' => 'D-ID',
            'kieai' => 'Kie AI',
            default => $this->provider,
        };
    }

    /**
     * Check if completed
     */
    public function getIsCompletedAttribute(): bool
    {
        return $this->status === 'completed';
    }

    /**
     * Check if failed
     */
    public function getIsFailedAttribute(): bool
    {
        return $this->status === 'failed';
    }

    /**
     * Scope for pending
     */
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    /**
     * Scope for processing
     */
    public function scopeProcessing($query)
    {
        return $query->where('status', 'processing');
    }

    /**
     * Scope for completed
     */
    public function scopeCompleted($query)
    {
        return $query->where('status', 'completed');
    }

    /**
     * Scope for failed
     */
    public function scopeFailed($query)
    {
        return $query->where('status', 'failed');
    }

    /**
     * Scope by provider
     */
    public function scopeByProvider($query, string $provider)
    {
        return $query->where('provider', $provider);
    }

    /**
     * Scope by user
     */
    public function scopeForUser($query, int $userId)
    {
        return $query->where('user_id', $userId);
    }

    /**
     * Mark as processing
     */
    public function markAsProcessing(): void
    {
        $this->update([
            'status' => 'processing',
            'started_at' => now(),
        ]);
    }

    /**
     * Mark as completed
     */
    public function markAsCompleted(string $videoUrl, ?string $thumbnailUrl = null, ?int $duration = null): void
    {
        $this->update([
            'status' => 'completed',
            'video_url' => $videoUrl,
            'thumbnail_url' => $thumbnailUrl,
            'duration' => $duration,
            'progress' => 100,
            'completed_at' => now(),
        ]);
    }

    /**
     * Mark as failed
     */
    public function markAsFailed(string $error): void
    {
        $this->update([
            'status' => 'failed',
            'error_message' => $error,
            'completed_at' => now(),
        ]);
    }

    /**
     * Update progress
     */
    public function updateProgress(int $progress): void
    {
        $this->update(['progress' => min($progress, 100)]);
    }

    /**
     * Calculate processing time in seconds
     */
    public function getProcessingTimeAttribute(): ?int
    {
        if ($this->started_at && $this->completed_at) {
            return $this->completed_at->diffInSeconds($this->started_at);
        }
        return null;
    }

    /**
     * Get cost by provider
     */
    public static function getCostPerGeneration(string $provider): float
    {
        return match($provider) {
            'runway' => 0.05, // per second
            'replicate' => 0.03,
            'stability' => 0.04,
            'pika' => 0.05,
            'did' => 0.10,
            default => 0.05,
        };
    }
}
