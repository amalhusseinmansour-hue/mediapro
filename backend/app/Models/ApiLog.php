<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ApiLog extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'api_key_id',
        'user_id',
        'method',
        'endpoint',
        'ip_address',
        'user_agent',
        'request_headers',
        'request_body',
        'response_status',
        'response_body',
        'response_time',
        'created_at',
    ];

    protected $casts = [
        'request_headers' => 'array',
        'request_body' => 'array',
        'response_body' => 'array',
        'response_status' => 'integer',
        'response_time' => 'integer',
        'created_at' => 'datetime',
    ];

    /**
     * العلاقة مع API Key
     */
    public function apiKey()
    {
        return $this->belongsTo(ApiKey::class);
    }

    /**
     * العلاقة مع المستخدم
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Scope for successful requests
     */
    public function scopeSuccessful($query)
    {
        return $query->whereBetween('response_status', [200, 299]);
    }

    /**
     * Scope for failed requests
     */
    public function scopeFailed($query)
    {
        return $query->where('response_status', '>=', 400);
    }

    /**
     * Scope for today's logs
     */
    public function scopeToday($query)
    {
        return $query->whereDate('created_at', today());
    }

    /**
     * Scope for specific endpoint
     */
    public function scopeForEndpoint($query, string $endpoint)
    {
        return $query->where('endpoint', 'like', "%{$endpoint}%");
    }

    /**
     * Get status color
     */
    public function getStatusColorAttribute(): string
    {
        return match (true) {
            $this->response_status >= 200 && $this->response_status < 300 => 'success',
            $this->response_status >= 300 && $this->response_status < 400 => 'info',
            $this->response_status >= 400 && $this->response_status < 500 => 'warning',
            $this->response_status >= 500 => 'danger',
            default => 'gray',
        };
    }

    /**
     * Get response time in a human-readable format
     */
    public function getFormattedResponseTimeAttribute(): string
    {
        if ($this->response_time < 1000) {
            return $this->response_time . 'ms';
        }

        return round($this->response_time / 1000, 2) . 's';
    }
}
