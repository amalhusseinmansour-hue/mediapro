<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Translation;
use App\Models\Language;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class TranslationController extends Controller
{
    /**
     * عرض جميع الترجمات
     */
    public function index(Request $request): JsonResponse
    {
        $query = Translation::with('language');

        if ($request->has('language_id')) {
            $query->where('language_id', $request->language_id);
        }

        if ($request->has('group')) {
            $query->group($request->group);
        }

        $translations = $query->orderBy('group')->orderBy('key')->paginate(50);

        return response()->json($translations);
    }

    /**
     * إنشاء ترجمة جديدة
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'language_code' => 'required|exists:languages,code',
            'key' => 'required|string|max:255',
            'value' => 'required|string',
            'group' => 'required|string|max:255',
        ]);

        Translation::set(
            $validated['key'],
            $validated['value'],
            $validated['language_code'],
            $validated['group']
        );

        return response()->json([
            'message' => 'تم إنشاء الترجمة بنجاح'
        ], 201);
    }

    /**
     * تحديث ترجمة
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $translation = Translation::findOrFail($id);

        $validated = $request->validate([
            'value' => 'required|string',
            'group' => 'sometimes|string|max:255',
        ]);

        $translation->update($validated);

        Translation::clearCache($translation->language->code);

        return response()->json([
            'message' => 'تم تحديث الترجمة بنجاح',
            'translation' => $translation
        ]);
    }

    /**
     * حذف ترجمة
     */
    public function destroy(string $id): JsonResponse
    {
        $translation = Translation::findOrFail($id);
        $languageCode = $translation->language->code;
        $translation->delete();

        Translation::clearCache($languageCode);

        return response()->json(['message' => 'تم حذف الترجمة بنجاح']);
    }

    /**
     * الحصول على الترجمات حسب اللغة
     */
    public function getByLanguage(string $languageCode): JsonResponse
    {
        $language = Language::getByCode($languageCode);

        if (!$language) {
            return response()->json(['error' => 'اللغة غير موجودة'], 404);
        }

        $translations = Translation::where('language_id', $language->id)
            ->get()
            ->groupBy('group')
            ->map(function ($items) {
                return $items->pluck('value', 'key')->toArray();
            });

        return response()->json($translations);
    }

    /**
     * استيراد ترجمات من ملف JSON
     */
    public function import(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'language_code' => 'required|exists:languages,code',
            'translations' => 'required|array',
            'group' => 'required|string',
        ]);

        $count = 0;
        foreach ($validated['translations'] as $key => $value) {
            Translation::set($key, $value, $validated['language_code'], $validated['group']);
            $count++;
        }

        return response()->json([
            'message' => "تم استيراد {$count} ترجمة بنجاح"
        ]);
    }

    /**
     * تصدير ترجمات إلى JSON
     */
    public function export(string $languageCode): JsonResponse
    {
        $language = Language::getByCode($languageCode);

        if (!$language) {
            return response()->json(['error' => 'اللغة غير موجودة'], 404);
        }

        $translations = Translation::where('language_id', $language->id)
            ->get()
            ->groupBy('group')
            ->map(function ($items) {
                return $items->pluck('value', 'key')->toArray();
            });

        return response()->json($translations);
    }
}
