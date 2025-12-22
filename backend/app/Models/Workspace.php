<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

class Workspace extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'name',
        'slug',
        'description',
        'logo',
        'owner_id',
        'plan_type',
        'max_members',
        'max_social_accounts',
        'settings',
        'is_active',
        'trial_ends_at',
    ];

    protected $casts = [
        'settings' => 'array',
        'is_active' => 'boolean',
        'trial_ends_at' => 'datetime',
    ];

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($workspace) {
            if (empty($workspace->slug)) {
                $workspace->slug = Str::slug($workspace->name) . '-' . Str::random(6);
            }
        });
    }

    /**
     * Get the owner of the workspace
     */
    public function owner(): BelongsTo
    {
        return $this->belongsTo(User::class, 'owner_id');
    }

    /**
     * Get all members of the workspace
     */
    public function members(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'workspace_members')
            ->withPivot(['role', 'permissions', 'invited_at', 'accepted_at', 'invited_by', 'is_active'])
            ->withTimestamps();
    }

    /**
     * Get active members only
     */
    public function activeMembers(): BelongsToMany
    {
        return $this->members()->wherePivot('is_active', true);
    }

    /**
     * Get workspace invitations
     */
    public function invitations(): HasMany
    {
        return $this->hasMany(WorkspaceInvitation::class);
    }

    /**
     * Get pending invitations
     */
    public function pendingInvitations(): HasMany
    {
        return $this->invitations()
            ->whereNull('accepted_at')
            ->where('expires_at', '>', now());
    }

    /**
     * Get workspace activities
     */
    public function activities(): HasMany
    {
        return $this->hasMany(WorkspaceActivity::class);
    }

    /**
     * Get social accounts for this workspace
     */
    public function socialAccounts(): HasMany
    {
        return $this->hasMany(SocialAccount::class);
    }

    /**
     * Get posts for this workspace
     */
    public function posts(): HasMany
    {
        return $this->hasMany(SocialMediaPost::class);
    }

    /**
     * Check if user is a member
     */
    public function hasMember(User $user): bool
    {
        return $this->members()->where('user_id', $user->id)->exists();
    }

    /**
     * Check if user is owner
     */
    public function isOwner(User $user): bool
    {
        return $this->owner_id === $user->id;
    }

    /**
     * Check if user is admin (owner or admin role)
     */
    public function isAdmin(User $user): bool
    {
        if ($this->isOwner($user)) {
            return true;
        }

        $member = $this->members()->where('user_id', $user->id)->first();
        return $member && in_array($member->pivot->role, ['owner', 'admin']);
    }

    /**
     * Check if user can edit (owner, admin, or editor)
     */
    public function canEdit(User $user): bool
    {
        if ($this->isOwner($user)) {
            return true;
        }

        $member = $this->members()->where('user_id', $user->id)->first();
        return $member && in_array($member->pivot->role, ['owner', 'admin', 'editor']);
    }

    /**
     * Get user's role in workspace
     */
    public function getUserRole(User $user): ?string
    {
        if ($this->isOwner($user)) {
            return 'owner';
        }

        $member = $this->members()->where('user_id', $user->id)->first();
        return $member ? $member->pivot->role : null;
    }

    /**
     * Add a member to workspace
     */
    public function addMember(User $user, string $role = 'viewer', ?User $invitedBy = null): void
    {
        $this->members()->attach($user->id, [
            'role' => $role,
            'invited_at' => now(),
            'accepted_at' => now(),
            'invited_by' => $invitedBy?->id,
            'is_active' => true,
        ]);

        $this->logActivity('member_added', $user, [
            'role' => $role,
            'invited_by' => $invitedBy?->name,
        ]);
    }

    /**
     * Remove a member from workspace
     */
    public function removeMember(User $user): void
    {
        $this->members()->detach($user->id);

        $this->logActivity('member_removed', $user);
    }

    /**
     * Update member role
     */
    public function updateMemberRole(User $user, string $role): void
    {
        $this->members()->updateExistingPivot($user->id, ['role' => $role]);

        $this->logActivity('member_role_updated', $user, ['role' => $role]);
    }

    /**
     * Log an activity
     */
    public function logActivity(string $action, $subject = null, array $properties = []): WorkspaceActivity
    {
        return $this->activities()->create([
            'user_id' => auth()->id(),
            'action' => $action,
            'subject_type' => $subject ? get_class($subject) : null,
            'subject_id' => $subject?->id ?? null,
            'properties' => $properties,
            'ip_address' => request()->ip(),
            'user_agent' => request()->userAgent(),
        ]);
    }

    /**
     * Check if workspace can add more members
     */
    public function canAddMembers(): bool
    {
        return $this->activeMembers()->count() < $this->max_members;
    }

    /**
     * Check if workspace can add more social accounts
     */
    public function canAddSocialAccounts(): bool
    {
        return $this->socialAccounts()->count() < $this->max_social_accounts;
    }

    /**
     * Check if trial is active
     */
    public function isTrialActive(): bool
    {
        return $this->trial_ends_at && $this->trial_ends_at->isFuture();
    }

    /**
     * Scope: Active workspaces
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope: By owner
     */
    public function scopeOwnedBy($query, $userId)
    {
        return $query->where('owner_id', $userId);
    }

    /**
     * Scope: Where user is member
     */
    public function scopeWhereMember($query, $userId)
    {
        return $query->whereHas('members', function ($q) use ($userId) {
            $q->where('user_id', $userId);
        });
    }
}
