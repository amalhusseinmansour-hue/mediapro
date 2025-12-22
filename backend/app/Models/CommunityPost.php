<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class CommunityPost extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'content',
        'media_urls',
        'tags',
        'visibility',
        'is_pinned',
        'published_at',
    ];

    protected $casts = [
        'media_urls' => 'array',
        'tags' => 'array',
        'is_pinned' => 'boolean',
        'published_at' => 'datetime',
    ];

    protected $appends = ['media_count', 'comments_count', 'likes_count'];

    /**
     * Get the user who created the post
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get comments on this post
     */
    public function comments()
    {
        return $this->hasMany(CommunityComment::class, 'post_id');
    }

    /**
     * Get likes on this post
     */
    public function likes()
    {
        return $this->hasMany(CommunityLike::class, 'post_id');
    }

    /**
     * Get comments count
     */
    public function getCommentsCountAttribute()
    {
        return $this->comments()->count();
    }

    /**
     * Get likes count
     */
    public function getLikesCountAttribute()
    {
        return $this->likes()->count();
    }

    /**
     * Check if user has liked this post
     */
    public function isLikedBy($userId)
    {
        return $this->likes()->where('user_id', $userId)->exists();
    }

    /**
     * Scope to get public posts
     */
    public function scopePublic($query)
    {
        return $query->where('visibility', 'public');
    }

    /**
     * Scope to get user's own posts
     */
    public function scopeByUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    /**
     * Scope to get only published posts
     */
    public function scopePublished($query)
    {
        return $query->whereNotNull('published_at')->where('published_at', '<=', now());
    }

    /**
     * Get media count
     */
    public function getMediaCountAttribute()
    {
        return count($this->media_urls ?? []);
    }

    /**
     * Publish the post
     */
    public function publish()
    {
        $this->update(['published_at' => now()]);
        return $this;
    }

    /**
     * Pin the post
     */
    public function pin()
    {
        $this->update(['is_pinned' => true]);
        return $this;
    }

    /**
     * Unpin the post
     */
    public function unpin()
    {
        $this->update(['is_pinned' => false]);
        return $this;
    }
}
