<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphTo;

class WorkspaceActivity extends Model
{
    use HasFactory;

    protected $fillable = [
        'workspace_id',
        'user_id',
        'action',
        'subject_type',
        'subject_id',
        'properties',
        'ip_address',
        'user_agent',
    ];

    protected $casts = [
        'properties' => 'array',
    ];

    /**
     * Get the workspace
     */
    public function workspace(): BelongsTo
    {
        return $this->belongsTo(Workspace::class);
    }

    /**
     * Get the user who performed the action
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the subject of the activity
     */
    public function subject(): MorphTo
    {
        return $this->morphTo();
    }

    /**
     * Get human-readable description
     */
    public function getDescriptionAttribute(): string
    {
        $userName = $this->user?->name ?? 'System';

        return match ($this->action) {
            'created' => "{$userName} created the workspace",
            'updated' => "{$userName} updated workspace settings",
            'member_added' => "{$userName} added a new member",
            'member_removed' => "{$userName} removed a member",
            'member_role_updated' => "{$userName} updated member role",
            'invitation_sent' => "{$userName} sent an invitation",
            'invitation_accepted' => "New member joined the workspace",
            'post_created' => "{$userName} created a new post",
            'post_published' => "{$userName} published a post",
            'post_scheduled' => "{$userName} scheduled a post",
            'social_account_connected' => "{$userName} connected a social account",
            'social_account_disconnected' => "{$userName} disconnected a social account",
            default => "{$userName} performed {$this->action}",
        };
    }

    /**
     * Get icon for activity type
     */
    public function getIconAttribute(): string
    {
        return match ($this->action) {
            'created' => 'plus-circle',
            'updated' => 'edit',
            'member_added', 'invitation_accepted' => 'user-plus',
            'member_removed' => 'user-minus',
            'member_role_updated' => 'shield',
            'invitation_sent' => 'mail',
            'post_created', 'post_published', 'post_scheduled' => 'file-text',
            'social_account_connected' => 'link',
            'social_account_disconnected' => 'unlink',
            default => 'activity',
        };
    }

    /**
     * Scope: By action
     */
    public function scopeByAction($query, string $action)
    {
        return $query->where('action', $action);
    }

    /**
     * Scope: Recent activities
     */
    public function scopeRecent($query, int $days = 30)
    {
        return $query->where('created_at', '>=', now()->subDays($days));
    }

    /**
     * Scope: By user
     */
    public function scopeByUser($query, int $userId)
    {
        return $query->where('user_id', $userId);
    }
}
