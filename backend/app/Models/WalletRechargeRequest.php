<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WalletRechargeRequest extends Model
{
    protected $fillable = [
        'user_id',
        'amount',
        'currency',
        'receipt_image',
        'payment_method',
        'bank_name',
        'transaction_reference',
        'notes',
        'status',
        'admin_notes',
        'processed_by',
        'processed_at',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'processed_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected $appends = ['status_text', 'formatted_amount'];

    // Status constants
    const STATUS_PENDING = 'pending';
    const STATUS_APPROVED = 'approved';
    const STATUS_REJECTED = 'rejected';

    // Relationships
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id', 'id');
    }

    public function processedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'processed_by', 'id');
    }

    // Accessors
    public function getStatusTextAttribute(): string
    {
        return match($this->status) {
            self::STATUS_PENDING => 'قيد الانتظار',
            self::STATUS_APPROVED => 'مقبول',
            self::STATUS_REJECTED => 'مرفوض',
            default => $this->status,
        };
    }

    public function getFormattedAmountAttribute(): string
    {
        return number_format($this->amount, 2) . ' ' . $this->currency;
    }

    public function getReceiptUrlAttribute(): ?string
    {
        if (!$this->receipt_image) {
            return null;
        }

        // If it's already a full URL, return it
        if (filter_var($this->receipt_image, FILTER_VALIDATE_URL)) {
            return $this->receipt_image;
        }

        // Otherwise, prepend storage URL
        return url('storage/' . $this->receipt_image);
    }

    // Methods
    public function approve(string $adminId, ?string $adminNotes = null): bool
    {
        if ($this->status !== self::STATUS_PENDING) {
            return false;
        }

        try {
            \DB::beginTransaction();

            // Update request status
            $this->status = self::STATUS_APPROVED;
            $this->admin_notes = $adminNotes;
            $this->processed_by = $adminId;
            $this->processed_at = now();
            $this->save();

            // Credit user wallet
            $wallet = Wallet::where('user_id', $this->user_id)->first();
            if (!$wallet) {
                $wallet = Wallet::createForUser($this->user_id);
            }

            $wallet->credit(
                $this->amount,
                'إعادة شحن المحفظة - طلب رقم ' . $this->id,
                'recharge_request_' . $this->id,
                [
                    'recharge_request_id' => $this->id,
                    'payment_method' => $this->payment_method,
                    'bank_name' => $this->bank_name,
                ]
            );

            \DB::commit();
            return true;
        } catch (\Exception $e) {
            \DB::rollBack();
            \Log::error('Failed to approve recharge request: ' . $e->getMessage());
            return false;
        }
    }

    public function reject(string $adminId, ?string $adminNotes = null): bool
    {
        if ($this->status !== self::STATUS_PENDING) {
            return false;
        }

        $this->status = self::STATUS_REJECTED;
        $this->admin_notes = $adminNotes;
        $this->processed_by = $adminId;
        $this->processed_at = now();

        return $this->save();
    }

    public function isPending(): bool
    {
        return $this->status === self::STATUS_PENDING;
    }

    public function isApproved(): bool
    {
        return $this->status === self::STATUS_APPROVED;
    }

    public function isRejected(): bool
    {
        return $this->status === self::STATUS_REJECTED;
    }

    // Scopes
    public function scopePending($query)
    {
        return $query->where('status', self::STATUS_PENDING);
    }

    public function scopeApproved($query)
    {
        return $query->where('status', self::STATUS_APPROVED);
    }

    public function scopeRejected($query)
    {
        return $query->where('status', self::STATUS_REJECTED);
    }

    public function scopeRecent($query)
    {
        return $query->orderBy('created_at', 'desc');
    }
}
