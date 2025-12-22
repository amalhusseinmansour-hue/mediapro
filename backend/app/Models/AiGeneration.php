<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AiGeneration extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'brand_kit_id',
        'type',
        'prompt',
        'result',
        'settings',
        'status',
        'error_message',
        'tokens_used',
    ];

    protected $casts = [
        'settings' => 'array',
        'tokens_used' => 'integer',
    ];

    const TYPE_IMAGE = 'image';
    const TYPE_VIDEO_SCRIPT = 'video_script';
    const TYPE_AUDIO_TRANSCRIPTION = 'audio_transcription';
    const TYPE_SOCIAL_CONTENT = 'social_content';

    const STATUS_PENDING = 'pending';
    const STATUS_PROCESSING = 'processing';
    const STATUS_COMPLETED = 'completed';
    const STATUS_FAILED = 'failed';

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function brandKit()
    {
        return $this->belongsTo(BrandKit::class);
    }

    public function scopeByType($query, $type)
    {
        return $query->where('type', $type);
    }

    public function scopeCompleted($query)
    {
        return $query->where('status', self::STATUS_COMPLETED);
    }

    public function scopeFailed($query)
    {
        return $query->where('status', self::STATUS_FAILED);
    }
}
