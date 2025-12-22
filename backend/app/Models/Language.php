<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Facades\Cache;

class Language extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'code',
        'direction',
        'flag',
        'is_active',
        'is_default',
        'sort_order',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'is_default' => 'boolean',
    ];

    /**
     * علاقة الترجمات
     */
    public function translations(): HasMany
    {
        return $this->hasMany(Translation::class);
    }

    /**
     * اللغات النشطة
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * اللغة الافتراضية
     */
    public static function getDefault()
    {
        return Cache::remember('default_language', 3600, function () {
            return static::where('is_default', true)->first()
                ?? static::where('code', 'ar')->first()
                ?? static::first();
        });
    }

    /**
     * الحصول على لغة حسب الكود
     */
    public static function getByCode(string $code)
    {
        return Cache::remember("language_{$code}", 3600, function () use ($code) {
            return static::where('code', $code)->first();
        });
    }

    /**
     * تعيين كلغة افتراضية
     */
    public function setAsDefault(): void
    {
        static::where('is_default', true)->update(['is_default' => false]);
        $this->update(['is_default' => true]);
        Cache::forget('default_language');
    }

    /**
     * ترتيب اللغات
     */
    public function scopeOrdered($query)
    {
        return $query->orderBy('sort_order')->orderBy('name');
    }

    /**
     * الحصول على جميع اللغات النشطة
     */
    public static function getAllActive()
    {
        return Cache::remember('active_languages', 3600, function () {
            return static::active()->ordered()->get();
        });
    }
}
