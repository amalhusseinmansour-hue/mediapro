<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class N8nWorkflowExecution extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'workflow_id',
        'execution_id',
        'platform',
        'status',
        'input_data',
        'output_data',
        'error_message',
        'error_details',
        'post_url',
        'duration',
        'started_at',
        'completed_at',
    ];

    protected $casts = [
        'input_data' => 'array',
        'output_data' => 'array',
        'error_details' => 'array',
        'duration' => 'integer',
        'started_at' => 'datetime',
        'completed_at' => 'datetime',
    ];

    /**
     * Get the user that owns the execution
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the workflow
     */
    public function workflow(): BelongsTo
    {
        return $this->belongsTo(N8nWorkflow::class, 'workflow_id', 'workflow_id');
    }

    /**
     * Mark execution as started
     */
    public function markAsStarted(): void
    {
        $this->update([
            'status' => 'running',
            'started_at' => now(),
        ]);
    }

    /**
     * Mark execution as successful
     */
    public function markAsSuccess(array $outputData = [], ?string $postUrl = null): void
    {
        $this->update([
            'status' => 'success',
            'output_data' => $outputData,
            'post_url' => $postUrl,
            'completed_at' => now(),
            'duration' => $this->started_at ? now()->diffInSeconds($this->started_at) : null,
        ]);
    }

    /**
     * Mark execution as failed
     */
    public function markAsFailed(string $errorMessage, array $errorDetails = []): void
    {
        $this->update([
            'status' => 'failed',
            'error_message' => $errorMessage,
            'error_details' => $errorDetails,
            'completed_at' => now(),
            'duration' => $this->started_at ? now()->diffInSeconds($this->started_at) : null,
        ]);
    }

    /**
     * Check if execution is successful
     */
    public function isSuccessful(): bool
    {
        return $this->status === 'success';
    }

    /**
     * Check if execution is failed
     */
    public function isFailed(): bool
    {
        return $this->status === 'failed';
    }

    /**
     * Check if execution is pending
     */
    public function isPending(): bool
    {
        return $this->status === 'pending';
    }

    /**
     * Check if execution is running
     */
    public function isRunning(): bool
    {
        return $this->status === 'running';
    }
}
