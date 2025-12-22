<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TelegramConnection extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'chat_id',
        'username',
        'first_name',
        'last_name',
        'is_active',
        'notifications_enabled',
        'preferences',
        'language',
        'last_interaction_at',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'notifications_enabled' => 'boolean',
        'preferences' => 'array',
        'last_interaction_at' => 'datetime',
    ];

    /**
     * Relationships
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Scopes
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeWithNotifications($query)
    {
        return $query->where('notifications_enabled', true);
    }

    /**
     * Helpers
     */
    public function updateInteraction(): void
    {
        $this->update(['last_interaction_at' => now()]);
    }

    public function enableNotifications(): void
    {
        $this->update(['notifications_enabled' => true]);
    }

    public function disableNotifications(): void
    {
        $this->update(['notifications_enabled' => false]);
    }

    /**
     * Accessors
     */
    public function getFullNameAttribute(): string
    {
        return trim($this->first_name . ' ' . $this->last_name) ?: $this->username;
    }
}
