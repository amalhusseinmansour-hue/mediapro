<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class N8nWorkflow extends Model
{
    use HasFactory;

    protected $fillable = [
        'workflow_id',
        'name',
        'description',
        'platform',
        'type',
        'workflow_json',
        'input_schema',
        'n8n_url',
        'credential_id',
        'upload_post_user',
        'is_active',
        'execution_count',
        'last_executed_at',
    ];

    protected $casts = [
        'workflow_json' => 'array',
        'input_schema' => 'array',
        'is_active' => 'boolean',
        'execution_count' => 'integer',
        'last_executed_at' => 'datetime',
    ];

    /**
     * Get all workflow executions
     */
    public function executions(): HasMany
    {
        return $this->hasMany(N8nWorkflowExecution::class, 'workflow_id', 'workflow_id');
    }

    /**
     * Get successful executions
     */
    public function successfulExecutions(): HasMany
    {
        return $this->executions()->where('status', 'success');
    }

    /**
     * Get failed executions
     */
    public function failedExecutions(): HasMany
    {
        return $this->executions()->where('status', 'failed');
    }

    /**
     * Increment execution count
     */
    public function incrementExecutionCount(): void
    {
        $this->increment('execution_count');
        $this->update(['last_executed_at' => now()]);
    }

    /**
     * Get workflow by platform
     */
    public static function getByPlatform(string $platform)
    {
        return static::where('platform', $platform)
            ->where('is_active', true)
            ->first();
    }

    /**
     * Get all active workflows
     */
    public static function getActive()
    {
        return static::where('is_active', true)->get();
    }

    /**
     * Get workflow statistics
     */
    public function getStatistics(): array
    {
        return [
            'total_executions' => $this->execution_count,
            'successful_executions' => $this->successfulExecutions()->count(),
            'failed_executions' => $this->failedExecutions()->count(),
            'success_rate' => $this->execution_count > 0
                ? round(($this->successfulExecutions()->count() / $this->execution_count) * 100, 2)
                : 0,
            'last_executed_at' => $this->last_executed_at?->format('Y-m-d H:i:s'),
        ];
    }
}
