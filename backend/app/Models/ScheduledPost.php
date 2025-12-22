<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class ScheduledPost extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'content_text',
        'media_urls',
        'platforms',
        'scheduled_at',
        'status',
        'error_message',
        'webhook_response',
        'attempts',
        'last_attempt_at',
        'sent_at',
    ];

    protected $casts = [
        'media_urls' => 'array',
        'platforms' => 'array',
        'webhook_response' => 'array',
        'scheduled_at' => 'datetime',
        'last_attempt_at' => 'datetime',
        'sent_at' => 'datetime',
        'attempts' => 'integer',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeDue($query)
    {
        return $query->where('status', 'pending')
            ->where('scheduled_at', '<=', now());
    }

    public function scopeFailed($query)
    {
        return $query->where('status', 'failed');
    }

    public function isDue(): bool
    {
        return $this->status === 'pending' && $this->scheduled_at <= now();
    }

    public function canRetry(): bool
    {
        return $this->attempts < 3;
    }

    public function markAsProcessing(): void
    {
        $this->update([
            'status' => 'processing',
            'attempts' => $this->attempts + 1,
            'last_attempt_at' => now(),
        ]);
    }

    public function markAsSent(array $response = []): void
    {
        $this->update([
            'status' => 'sent',
            'sent_at' => now(),
            'webhook_response' => $response,
            'error_message' => null,
        ]);
    }

    public function markAsFailed(string $error, array $response = []): void
    {
        $this->update([
            'status' => 'failed',
            'error_message' => $error,
            'webhook_response' => $response,
        ]);
    }
}
