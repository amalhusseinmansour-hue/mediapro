<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CommunityLike extends Model
{
    use HasFactory;

    protected $fillable = [
        'post_id',
        'user_id',
    ];

    public $timestamps = true;

    /**
     * Get the post that owns the like
     */
    public function post()
    {
        return $this->belongsTo(CommunityPost::class, 'post_id');
    }

    /**
     * Get the user who liked the post
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Scope to get likes by user
     */
    public function scopeByUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    /**
     * Scope to get likes for post
     */
    public function scopeForPost($query, $postId)
    {
        return $query->where('post_id', $postId);
    }
}
