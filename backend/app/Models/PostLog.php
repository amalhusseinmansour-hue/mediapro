<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PostLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'scheduled_post_id',
        'automation_rule_id',
        'platform',
        'social_account_id',
        'action',
        'request_url',
        'request_payload',
        'response_data',
        'http_status_code',
        'publish_method',
        'status',
        'error_message',
        'error_code',
        'error_details',
        'platform_post_id',
        'platform_post_url',
        'execution_time_ms',
        'attempt_number',
        'rate_limit_remaining',
        'rate_limit_reset_at',
        'metadata',
        'ip_address',
        'user_agent',
    ];

    protected $casts = [
        'request_payload' => 'array',
        'response_data' => 'array',
        'error_details' => 'array',
        'metadata' => 'array',
        'http_status_code' => 'integer',
        'execution_time_ms' => 'integer',
        'attempt_number' => 'integer',
        'rate_limit_remaining' => 'integer',
        'rate_limit_reset_at' => 'datetime',
    ];

    /**
     * Relationships
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function scheduledPost(): BelongsTo
    {
        return $this->belongsTo(ScheduledPost::class);
    }

    public function automationRule(): BelongsTo
    {
        return $this->belongsTo(AutomationRule::class);
    }

    public function socialAccount(): BelongsTo
    {
        return $this->belongsTo(UserSocialAccount::class, 'social_account_id');
    }

    /**
     * Scopes
     */
    public function scopeForUser($query, int $userId)
    {
        return $query->where('user_id', $userId);
    }

    public function scopeForPost($query, int $scheduledPostId)
    {
        return $query->where('scheduled_post_id', $scheduledPostId);
    }

    public function scopeForPlatform($query, string $platform)
    {
        return $query->where('platform', $platform);
    }

    public function scopeSuccess($query)
    {
        return $query->where('status', 'success');
    }

    public function scopeFailed($query)
    {
        return $query->where('status', 'failed');
    }

    public function scopeRecentErrors($query, int $hours = 24)
    {
        return $query->where('status', 'failed')
            ->where('created_at', '>=', now()->subHours($hours));
    }

    /**
     * Helper methods
     */
    public static function logPublishAttempt(
        ScheduledPost $post,
        string $platform,
        ?UserSocialAccount $account = null,
        string $method = 'ayrshare'
    ): self {
        return self::create([
            'user_id' => $post->user_id,
            'scheduled_post_id' => $post->id,
            'automation_rule_id' => $post->automation_rule_id,
            'platform' => $platform,
            'social_account_id' => $account?->id,
            'action' => 'publish_attempt',
            'publish_method' => $method,
            'status' => 'pending',
            'attempt_number' => $post->attempts,
        ]);
    }

    public function logSuccess(
        array $response,
        ?string $platformPostId = null,
        ?string $platformPostUrl = null,
        ?int $executionTime = null
    ): void {
        $this->update([
            'status' => 'success',
            'action' => 'publish_success',
            'response_data' => $response,
            'platform_post_id' => $platformPostId,
            'platform_post_url' => $platformPostUrl,
            'execution_time_ms' => $executionTime,
            'http_status_code' => $response['http_status'] ?? 200,
        ]);
    }

    public function logFailure(
        string $error,
        ?array $details = null,
        ?int $httpStatus = null,
        ?int $executionTime = null
    ): void {
        $this->update([
            'status' => 'failed',
            'action' => 'publish_failed',
            'error_message' => $error,
            'error_details' => $details,
            'http_status_code' => $httpStatus,
            'execution_time_ms' => $executionTime,
        ]);
    }
}
