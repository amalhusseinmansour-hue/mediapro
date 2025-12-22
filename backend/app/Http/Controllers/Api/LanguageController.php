<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Language;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Str;

class LanguageController extends Controller
{
    /**
     * عرض جميع اللغات
     */
    public function index(): JsonResponse
    {
        $languages = Language::active()->ordered()->get();

        return response()->json($languages);
    }

    /**
     * عرض لغة واحدة
     */
    public function show(string $id): JsonResponse
    {
        $language = Language::findOrFail($id);

        return response()->json($language);
    }

    /**
     * إنشاء لغة جديدة
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'required|string|max:10|unique:languages,code',
            'direction' => 'required|in:ltr,rtl',
            'flag' => 'nullable|string',
            'is_active' => 'boolean',
            'is_default' => 'boolean',
            'sort_order' => 'integer',
        ]);

        $language = Language::create($validated);

        if ($validated['is_default'] ?? false) {
            $language->setAsDefault();
        }

        return response()->json($language, 201);
    }

    /**
     * تحديث لغة
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $language = Language::findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'code' => 'sometimes|string|max:10|unique:languages,code,' . $id,
            'direction' => 'sometimes|in:ltr,rtl',
            'flag' => 'nullable|string',
            'is_active' => 'boolean',
            'is_default' => 'boolean',
            'sort_order' => 'integer',
        ]);

        $language->update($validated);

        if ($validated['is_default'] ?? false) {
            $language->setAsDefault();
        }

        return response()->json($language);
    }

    /**
     * حذف لغة
     */
    public function destroy(string $id): JsonResponse
    {
        $language = Language::findOrFail($id);

        if ($language->is_default) {
            return response()->json([
                'error' => 'لا يمكن حذف اللغة الافتراضية'
            ], 400);
        }

        $language->delete();

        return response()->json(['message' => 'تم حذف اللغة بنجاح']);
    }

    /**
     * تعيين لغة كافتراضية
     */
    public function setDefault(string $id): JsonResponse
    {
        $language = Language::findOrFail($id);
        $language->setAsDefault();

        return response()->json([
            'message' => 'تم تعيين اللغة كافتراضية بنجاح',
            'language' => $language
        ]);
    }
}
