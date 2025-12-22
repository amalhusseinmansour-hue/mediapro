<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Cache;

class Translation extends Model
{
    use HasFactory;

    protected $fillable = [
        'language_id',
        'group',
        'key',
        'value',
    ];

    /**
     * علاقة اللغة
     */
    public function language(): BelongsTo
    {
        return $this->belongsTo(Language::class);
    }

    /**
     * الحصول على ترجمة
     */
    public static function get(string $key, string $languageCode = null, $default = null)
    {
        $languageCode = $languageCode ?? app()->getLocale();

        return Cache::remember("translation_{$languageCode}_{$key}", 3600, function () use ($key, $languageCode, $default) {
            $language = Language::getByCode($languageCode);

            if (!$language) {
                return $default ?? $key;
            }

            $translation = static::where('language_id', $language->id)
                ->where('key', $key)
                ->first();

            return $translation?->value ?? $default ?? $key;
        });
    }

    /**
     * تعيين ترجمة
     */
    public static function set(string $key, string $value, string $languageCode, string $group = 'general'): void
    {
        $language = Language::getByCode($languageCode);

        if (!$language) {
            return;
        }

        static::updateOrCreate(
            [
                'language_id' => $language->id,
                'key' => $key,
            ],
            [
                'value' => $value,
                'group' => $group,
            ]
        );

        Cache::forget("translation_{$languageCode}_{$key}");
        Cache::forget("translations_{$languageCode}_{$group}");
    }

    /**
     * الحصول على جميع الترجمات لمجموعة معينة
     */
    public static function getGroup(string $group, string $languageCode = null): array
    {
        $languageCode = $languageCode ?? app()->getLocale();

        return Cache::remember("translations_{$languageCode}_{$group}", 3600, function () use ($group, $languageCode) {
            $language = Language::getByCode($languageCode);

            if (!$language) {
                return [];
            }

            return static::where('language_id', $language->id)
                ->where('group', $group)
                ->pluck('value', 'key')
                ->toArray();
        });
    }

    /**
     * الترجمات حسب المجموعة
     */
    public function scopeGroup($query, string $group)
    {
        return $query->where('group', $group);
    }

    /**
     * مسح كاش الترجمات
     */
    public static function clearCache(string $languageCode = null): void
    {
        if ($languageCode) {
            Cache::forget("translations_{$languageCode}");
        } else {
            Cache::flush();
        }
    }
}
