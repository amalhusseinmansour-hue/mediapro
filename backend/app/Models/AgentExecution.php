<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AgentExecution extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'agent_type',
        'action',
        'status',
        'input_data',
        'output_data',
        'error_data',
        'n8n_execution_id',
        'telegram_chat_id',
        'telegram_message_id',
        'google_drive_file_id',
        'result_url',
        'execution_time',
        'credits_used',
        'started_at',
        'completed_at',
    ];

    protected $casts = [
        'input_data' => 'array',
        'output_data' => 'array',
        'error_data' => 'array',
        'started_at' => 'datetime',
        'completed_at' => 'datetime',
    ];

    protected $appends = ['duration_human'];

    /**
     * User relationship
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Scopes
     */
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeProcessing($query)
    {
        return $query->where('status', 'processing');
    }

    public function scopeCompleted($query)
    {
        return $query->where('status', 'completed');
    }

    public function scopeFailed($query)
    {
        return $query->where('status', 'failed');
    }

    public function scopeByAgent($query, string $agentType)
    {
        return $query->where('agent_type', $agentType);
    }

    public function scopeByAction($query, string $action)
    {
        return $query->where('action', $action);
    }

    /**
     * Helpers
     */
    public function markAsProcessing(): void
    {
        $this->update([
            'status' => 'processing',
            'started_at' => now(),
        ]);
    }

    public function markAsCompleted(array $outputData = []): void
    {
        $this->update([
            'status' => 'completed',
            'output_data' => $outputData,
            'completed_at' => now(),
            'execution_time' => $this->started_at ? now()->diffInSeconds($this->started_at) : null,
        ]);
    }

    public function markAsFailed(string $error, array $errorData = []): void
    {
        $this->update([
            'status' => 'failed',
            'error_data' => array_merge($errorData, ['message' => $error]),
            'completed_at' => now(),
            'execution_time' => $this->started_at ? now()->diffInSeconds($this->started_at) : null,
        ]);
    }

    /**
     * Accessors
     */
    public function getDurationHumanAttribute(): ?string
    {
        if (!$this->execution_time) {
            return null;
        }

        if ($this->execution_time < 60) {
            return $this->execution_time . 's';
        }

        $minutes = floor($this->execution_time / 60);
        $seconds = $this->execution_time % 60;

        return "{$minutes}m {$seconds}s";
    }

    public function getStatusBadgeAttribute(): string
    {
        return match($this->status) {
            'completed' => 'success',
            'processing' => 'warning',
            'failed' => 'danger',
            default => 'secondary',
        };
    }

    public function getAgentTypeNameAttribute(): string
    {
        return match($this->agent_type) {
            'content' => 'Content Agent',
            'posting' => 'Posting Agent',
            'email' => 'Email Agent',
            'calendar' => 'Calendar Agent',
            'drive' => 'Google Drive Agent',
            'contact' => 'Contact Agent',
            'internet' => 'Internet Agent',
            default => ucfirst($this->agent_type),
        };
    }
}
