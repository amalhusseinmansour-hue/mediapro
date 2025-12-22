<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BankTransferRequest extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'amount',
        'currency',
        'sender_name',
        'sender_bank',
        'sender_account_number',
        'transfer_reference',
        'transfer_date',
        'transfer_notes',
        'receipt_image',
        'status',
        'admin_notes',
        'reviewed_by',
        'reviewed_at',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'transfer_date' => 'datetime',
        'reviewed_at' => 'datetime',
    ];

    /**
     * Get the user that owns the transfer request
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the admin who reviewed this request
     */
    public function reviewer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reviewed_by');
    }

    /**
     * Get status in Arabic
     */
    public function getStatusArabicAttribute(): string
    {
        $statuses = [
            'pending' => 'قيد الانتظار',
            'reviewing' => 'قيد المراجعة',
            'approved' => 'تم الموافقة',
            'rejected' => 'مرفوض',
        ];

        return $statuses[$this->status] ?? $this->status;
    }

    /**
     * Get receipt image URL
     */
    public function getReceiptUrlAttribute(): ?string
    {
        if (!$this->receipt_image) {
            return null;
        }

        // If it's already a full URL, return it
        if (filter_var($this->receipt_image, FILTER_VALIDATE_URL)) {
            return $this->receipt_image;
        }

        // Otherwise, prepend the storage URL
        return url('storage/' . $this->receipt_image);
    }

    /**
     * Scope to filter by status
     */
    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    /**
     * Scope to get pending requests
     */
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    /**
     * Scope to get approved requests
     */
    public function scopeApproved($query)
    {
        return $query->where('status', 'approved');
    }

    /**
     * Scope to get rejected requests
     */
    public function scopeRejected($query)
    {
        return $query->where('status', 'rejected');
    }

    /**
     * Scope to filter by user
     */
    public function scopeByUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }
}
