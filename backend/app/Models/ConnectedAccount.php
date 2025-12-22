<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ConnectedAccount extends Model
{
    use HasFactory, SoftDeletes;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'social_accounts';

    protected $fillable = [
        'user_id',
        'platform',
        'platform_user_id',
        'username',
        'display_name',
        'profile_picture',
        'email',
        'access_token',
        'refresh_token',
        'token_expires_at',
        'scopes',
        'is_active',
        'connected_at',
        'last_used_at',
        'metadata',
    ];

    protected $casts = [
        'scopes' => 'array',
        'metadata' => 'array',
        'is_active' => 'boolean',
        'token_expires_at' => 'datetime',
        'connected_at' => 'datetime',
        'last_used_at' => 'datetime',
    ];

    protected $hidden = [
        'access_token',
        'refresh_token',
    ];

    /**
     * Get the user that owns the connected account
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Check if the token is expired
     */
    public function isTokenExpired(): bool
    {
        if (!$this->token_expires_at) {
            return false;
        }

        return $this->token_expires_at->isPast();
    }

    /**
     * Mark the account as used
     */
    public function markAsUsed(): void
    {
        $this->update(['last_used_at' => now()]);
    }

    /**
     * Scope for active accounts
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope by platform
     */
    public function scopeByPlatform($query, string $platform)
    {
        return $query->where('platform', $platform);
    }

    /**
     * Scope by user
     */
    public function scopeByUser($query, int $userId)
    {
        return $query->where('user_id', $userId);
    }

    /**
     * Get platform display name
     */
    public function getPlatformNameAttribute(): string
    {
        return match($this->platform) {
            'facebook' => 'Facebook',
            'instagram' => 'Instagram',
            'twitter' => 'Twitter (X)',
            'linkedin' => 'LinkedIn',
            'tiktok' => 'TikTok',
            'youtube' => 'YouTube',
            'snapchat' => 'Snapchat',
            'pinterest' => 'Pinterest',
            default => ucfirst($this->platform),
        };
    }

    /**
     * Get platform icon
     */
    public function getPlatformIconAttribute(): string
    {
        return match($this->platform) {
            'facebook' => 'facebook',
            'instagram' => 'instagram',
            'twitter' => 'twitter',
            'linkedin' => 'linkedin',
            'tiktok' => 'tiktok',
            'youtube' => 'youtube',
            'snapchat' => 'snapchat',
            'pinterest' => 'pinterest',
            default => 'link',
        };
    }

    /**
     * Get platform color
     */
    public function getPlatformColorAttribute(): string
    {
        return match($this->platform) {
            'facebook' => '#1877F2',
            'instagram' => '#E4405F',
            'twitter' => '#1DA1F2',
            'linkedin' => '#0A66C2',
            'tiktok' => '#000000',
            'youtube' => '#FF0000',
            'snapchat' => '#FFFC00',
            'pinterest' => '#E60023',
            default => '#6B7280',
        };
    }
}
