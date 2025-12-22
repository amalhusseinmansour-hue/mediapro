<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ContentTemplate extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'slug',
        'description',
        'platform',
        'category',
        'type',
        'content',
        'variables',
        'hashtags',
        'media_requirements',
        'best_posting_times',
        'user_id',
        'is_active',
        'sort_order',
        'usage_count',
    ];

    protected $casts = [
        'variables' => 'array',
        'hashtags' => 'array',
        'media_requirements' => 'array',
        'best_posting_times' => 'array',
        'is_active' => 'boolean',
    ];

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeForPlatform($query, $platform)
    {
        return $query->where(function($q) use ($platform) {
            $q->where('platform', $platform)
              ->orWhere('platform', 'all');
        });
    }

    public function scopeSystem($query)
    {
        return $query->whereNull('user_id');
    }

    public function scopeUserTemplates($query, $userId)
    {
        return $query->where('user_id', $userId);
    }
}
