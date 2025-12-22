<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AiGeneratedVideo extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'prompt',
        'provider',
        'video_url',
        'thumbnail_url',
        'task_id',
        'status',
        'duration',
        'aspect_ratio',
        'cost',
        'metadata',
        'api_response',
        'started_at',
        'completed_at',
    ];

    protected $casts = [
        'metadata' => 'array',
        'api_response' => 'array',
        'cost' => 'decimal:4',
        'started_at' => 'datetime',
        'completed_at' => 'datetime',
    ];

    /**
     * Get the user that owns the video.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Scope a query to only include videos by status.
     */
    public function scopeByStatus($query, string $status)
    {
        return $query->where('status', $status);
    }

    /**
     * Scope a query to only include videos by provider.
     */
    public function scopeByProvider($query, string $provider)
    {
        return $query->where('provider', $provider);
    }

    /**
     * Get the video generation duration in a human-readable format.
     */
    public function getFormattedDurationAttribute(): string
    {
        return $this->duration . ' seconds';
    }

    /**
     * Check if video is ready for download.
     */
    public function isReady(): bool
    {
        return $this->status === 'completed' && !empty($this->video_url);
    }

    /**
     * Check if video generation failed.
     */
    public function hasFailed(): bool
    {
        return $this->status === 'failed';
    }

    /**
     * Check if video is still processing.
     */
    public function isProcessing(): bool
    {
        return in_array($this->status, ['pending', 'processing']);
    }

    /**
     * Get the estimated cost in USD.
     */
    public function getEstimatedCostAttribute(): float
    {
        switch ($this->provider) {
            case 'runway':
                return $this->duration * 0.05; // $0.05 per second
            case 'pika':
                return 0.30; // subscription-based, estimated cost
            case 'd-id':
                return 0.30; // $0.30 per video
            case 'stability':
                return $this->duration * 0.02; // $0.02 per frame (assuming 30fps)
            default:
                return 0;
        }
    }

    /**
     * Mark video generation as started.
     */
    public function markAsStarted(): self
    {
        $this->update([
            'status' => 'processing',
            'started_at' => now(),
        ]);

        return $this;
    }

    /**
     * Mark video generation as completed.
     */
    public function markAsCompleted(string $videoUrl, ?string $thumbnailUrl = null): self
    {
        $this->update([
            'status' => 'completed',
            'video_url' => $videoUrl,
            'thumbnail_url' => $thumbnailUrl,
            'completed_at' => now(),
        ]);

        return $this;
    }

    /**
     * Mark video generation as failed.
     */
    public function markAsFailed(string $error): self
    {
        $metadata = $this->metadata ?? [];
        $metadata['error'] = $error;

        $this->update([
            'status' => 'failed',
            'metadata' => $metadata,
            'completed_at' => now(),
        ]);

        return $this;
    }
}