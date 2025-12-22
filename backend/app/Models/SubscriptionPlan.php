<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class SubscriptionPlan extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'name',
        'slug',
        'description',
        'type',
        'audience_type',
        'price',
        'currency',
        'max_accounts',
        'max_posts',
        'ai_features',
        'analytics',
        'scheduling',
        'is_popular',
        'is_active',
        'sort_order',
        'features',
        'stripe_price_id',
        'paypal_plan_id',
    ];

    protected $casts = [
        'features' => 'array',
        'ai_features' => 'boolean',
        'analytics' => 'boolean',
        'scheduling' => 'boolean',
        'is_popular' => 'boolean',
        'is_active' => 'boolean',
        'price' => 'decimal:2',
    ];

    /**
     * الباقات النشطة
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * الباقات الشهرية
     */
    public function scopeMonthly($query)
    {
        return $query->where('type', 'monthly');
    }

    /**
     * الباقات السنوية
     */
    public function scopeYearly($query)
    {
        return $query->where('type', 'yearly');
    }

    /**
     * الباقات الأكثر شعبية
     */
    public function scopePopular($query)
    {
        return $query->where('is_popular', true);
    }

    /**
     * ترتيب الباقات
     */
    public function scopeOrdered($query)
    {
        return $query->orderBy('sort_order');
    }

    /**
     * باقات الأفراد
     */
    public function scopeIndividual($query)
    {
        return $query->where('audience_type', 'individual');
    }

    /**
     * باقات الأعمال
     */
    public function scopeBusiness($query)
    {
        return $query->where('audience_type', 'business');
    }
}
