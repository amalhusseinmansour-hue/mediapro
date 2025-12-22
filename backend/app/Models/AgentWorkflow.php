<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class AgentWorkflow extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'name',
        'description',
        'workflow_type',
        'is_active',
        'n8n_workflow_id',
        'webhook_id',
        'webhook_url',
        'trigger_config',
        'steps_config',
        'success_actions',
        'failure_actions',
        'total_executions',
        'successful_executions',
        'failed_executions',
        'last_executed_at',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'trigger_config' => 'array',
        'steps_config' => 'array',
        'success_actions' => 'array',
        'failure_actions' => 'array',
        'last_executed_at' => 'datetime',
    ];

    protected $appends = ['success_rate'];

    /**
     * Relationships
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function executions(): HasMany
    {
        return $this->hasMany(AgentExecution::class, 'workflow_id');
    }

    /**
     * Scopes
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeByType($query, string $type)
    {
        return $query->where('workflow_type', $type);
    }

    /**
     * Helpers
     */
    public function activate(): void
    {
        $this->update(['is_active' => true]);
    }

    public function deactivate(): void
    {
        $this->update(['is_active' => false]);
    }

    public function incrementExecutions(bool $success = true): void
    {
        $this->increment('total_executions');

        if ($success) {
            $this->increment('successful_executions');
        } else {
            $this->increment('failed_executions');
        }

        $this->update(['last_executed_at' => now()]);
    }

    /**
     * Accessors
     */
    public function getSuccessRateAttribute(): float
    {
        if ($this->total_executions === 0) {
            return 0;
        }

        return round(($this->successful_executions / $this->total_executions) * 100, 2);
    }

    public function getWebhookUrlFullAttribute(): string
    {
        if ($this->webhook_url) {
            return $this->webhook_url;
        }

        $baseUrl = config('services.n8n.base_url');
        return "{$baseUrl}/webhook/{$this->webhook_id}";
    }
}
