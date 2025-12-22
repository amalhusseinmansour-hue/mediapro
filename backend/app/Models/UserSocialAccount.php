<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Facades\Crypt;

class UserSocialAccount extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'platform',
        'platform_user_id',
        'username',
        'display_name',
        'profile_image_url',
        'access_token',
        'refresh_token',
        'token_expires_at',
        'platform_data',
        'status',
        'last_used_at',
        'last_token_refresh_at',
        'failed_attempts',
        'last_error',
        'rate_limit_remaining',
        'rate_limit_reset_at',
    ];

    protected $casts = [
        'platform_data' => 'array',
        'token_expires_at' => 'datetime',
        'last_used_at' => 'datetime',
        'last_token_refresh_at' => 'datetime',
        'rate_limit_reset_at' => 'datetime',
        'failed_attempts' => 'integer',
        'rate_limit_remaining' => 'integer',
    ];

    protected $hidden = [
        'access_token',
        'refresh_token',
    ];

    /**
     * Relationships
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function postLogs(): HasMany
    {
        return $this->hasMany(PostLog::class, 'social_account_id');
    }

    /**
     * Accessors & Mutators
     */
    public function getAccessTokenAttribute($value): ?string
    {
        return $value ? Crypt::decryptString($value) : null;
    }

    public function setAccessTokenAttribute($value): void
    {
        $this->attributes['access_token'] = $value ? Crypt::encryptString($value) : null;
    }

    public function getRefreshTokenAttribute($value): ?string
    {
        return $value ? Crypt::decryptString($value) : null;
    }

    public function setRefreshTokenAttribute($value): void
    {
        $this->attributes['refresh_token'] = $value ? Crypt::encryptString($value) : null;
    }

    /**
     * Scopes
     */
    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopeForPlatform($query, string $platform)
    {
        return $query->where('platform', $platform);
    }

    public function scopeTokenExpiringSoon($query, int $hoursThreshold = 1)
    {
        return $query->where('token_expires_at', '<=', now()->addHours($hoursThreshold))
            ->where('token_expires_at', '>', now());
    }

    public function scopeTokenExpired($query)
    {
        return $query->where('token_expires_at', '<=', now());
    }

    /**
     * Helper methods
     */
    public function isTokenExpired(): bool
    {
        if (!$this->token_expires_at) {
            return false;
        }

        return $this->token_expires_at->isPast();
    }

    public function isTokenExpiringSoon(int $hoursThreshold = 1): bool
    {
        if (!$this->token_expires_at) {
            return false;
        }

        return $this->token_expires_at->lte(now()->addHours($hoursThreshold));
    }

    public function markAsUsed(): void
    {
        $this->update([
            'last_used_at' => now(),
            'failed_attempts' => 0,
        ]);
    }

    public function markAsFailed(string $error): void
    {
        $this->increment('failed_attempts');
        $this->update([
            'last_error' => $error,
            'status' => $this->failed_attempts >= 3 ? 'authentication_failed' : $this->status,
        ]);
    }

    public function updateRateLimit(?int $remaining, ?\DateTime $resetAt): void
    {
        $this->update([
            'rate_limit_remaining' => $remaining,
            'rate_limit_reset_at' => $resetAt,
            'status' => $remaining === 0 ? 'rate_limited' : $this->status,
        ]);
    }

    public function isRateLimited(): bool
    {
        if ($this->status === 'rate_limited') {
            // Check if rate limit has reset
            if ($this->rate_limit_reset_at && $this->rate_limit_reset_at->isPast()) {
                $this->update(['status' => 'active', 'rate_limit_remaining' => null]);
                return false;
            }
            return true;
        }

        return false;
    }
}
