<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Wallet extends Model
{
    protected $fillable = [
        'user_id',
        'balance',
        'currency',
        'is_active',
    ];

    protected $casts = [
        'balance' => 'decimal:2',
        'is_active' => 'boolean',
    ];

    protected $hidden = [];

    protected $appends = ['formatted_balance'];

    // Relationships
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id', 'id');
    }

    public function transactions(): HasMany
    {
        return $this->hasMany(WalletTransaction::class)->orderBy('created_at', 'desc');
    }

    // Accessors
    public function getFormattedBalanceAttribute(): string
    {
        return number_format($this->balance, 2) . ' ' . $this->currency;
    }

    // Methods
    public function credit(float $amount, string $description, ?string $referenceId = null, ?array $metadata = null): WalletTransaction
    {
        $this->balance += $amount;
        $this->save();

        return $this->transactions()->create([
            'transaction_id' => \Illuminate\Support\Str::uuid(),
            'user_id' => $this->user_id,
            'type' => 'credit',
            'amount' => $amount,
            'balance_after' => $this->balance,
            'currency' => $this->currency,
            'description' => $description,
            'reference_id' => $referenceId,
            'status' => 'completed',
            'metadata' => $metadata,
        ]);
    }

    public function debit(float $amount, string $description, ?string $referenceId = null, ?array $metadata = null): WalletTransaction
    {
        if ($this->balance < $amount) {
            throw new \Exception('Insufficient balance');
        }

        $this->balance -= $amount;
        $this->save();

        return $this->transactions()->create([
            'transaction_id' => \Illuminate\Support\Str::uuid(),
            'user_id' => $this->user_id,
            'type' => 'debit',
            'amount' => $amount,
            'balance_after' => $this->balance,
            'currency' => $this->currency,
            'description' => $description,
            'reference_id' => $referenceId,
            'status' => 'completed',
            'metadata' => $metadata,
        ]);
    }

    public function hasEnoughBalance(float $amount): bool
    {
        return $this->balance >= $amount;
    }

    public function getTotalCredits(): float
    {
        return $this->transactions()
            ->where('type', 'credit')
            ->where('status', 'completed')
            ->sum('amount');
    }

    public function getTotalDebits(): float
    {
        return $this->transactions()
            ->where('type', 'debit')
            ->where('status', 'completed')
            ->sum('amount');
    }

    // Static Methods
    public static function createForUser(string $userId): self
    {
        return self::create([
            'user_id' => $userId,
            'balance' => 0,
            'currency' => 'SAR',
            'is_active' => true,
        ]);
    }
}
