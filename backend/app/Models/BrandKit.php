<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class BrandKit extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'name',
        'description',
        'logo',
        'colors',
        'fonts',
        'tone',
        'voice',
        'tagline',
        'keywords',
        'target_audience',
        'social_links',
        'is_default',
    ];

    protected $casts = [
        'colors' => 'array',
        'fonts' => 'array',
        'keywords' => 'array',
        'target_audience' => 'array',
        'social_links' => 'array',
        'is_default' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function aiGenerations()
    {
        return $this->hasMany(AiGeneration::class);
    }

    // Set this brand kit as default and unset others
    public function setAsDefault()
    {
        // Unset all other default brand kits for this user
        self::where('user_id', $this->user_id)
            ->where('id', '!=', $this->id)
            ->update(['is_default' => false]);

        $this->update(['is_default' => true]);
    }
}
