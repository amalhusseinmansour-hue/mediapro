<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class SettingController extends Controller
{
    /**
     * عرض جميع الإعدادات
     */
    public function index(Request $request): JsonResponse
    {
        $query = Setting::query();

        if ($request->has('group')) {
            $query->group($request->group);
        }

        $settings = $query->orderBy('group')->orderBy('key')->get();

        return response()->json($settings);
    }

    /**
     * عرض إعداد واحد
     */
    public function show(string $key): JsonResponse
    {
        $value = Setting::get($key);

        return response()->json([
            'key' => $key,
            'value' => $value
        ]);
    }

    /**
     * إنشاء/تحديث إعداد
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'key' => 'required|string|max:255',
            'value' => 'required',
            'type' => 'required|in:string,integer,boolean,json,array',
            'group' => 'required|string',
            'description' => 'nullable|string',
            'is_public' => 'boolean',
        ]);

        Setting::set(
            $validated['key'],
            $validated['value'],
            $validated['type'],
            $validated['group']
        );

        if (isset($validated['description']) || isset($validated['is_public'])) {
            $setting = Setting::where('key', $validated['key'])->first();
            $setting->update([
                'description' => $validated['description'] ?? $setting->description,
                'is_public' => $validated['is_public'] ?? $setting->is_public,
            ]);
        }

        return response()->json([
            'message' => 'تم حفظ الإعداد بنجاح',
            'key' => $validated['key']
        ]);
    }

    /**
     * تحديث إعداد
     */
    public function update(Request $request, string $key): JsonResponse
    {
        $validated = $request->validate([
            'value' => 'required',
            'type' => 'sometimes|in:string,integer,boolean,json,array',
            'group' => 'sometimes|string',
            'description' => 'nullable|string',
            'is_public' => 'boolean',
        ]);

        $setting = Setting::where('key', $key)->firstOrFail();

        Setting::set(
            $key,
            $validated['value'],
            $validated['type'] ?? $setting->type,
            $validated['group'] ?? $setting->group
        );

        if (isset($validated['description']) || isset($validated['is_public'])) {
            $setting->update([
                'description' => $validated['description'] ?? $setting->description,
                'is_public' => $validated['is_public'] ?? $setting->is_public,
            ]);
        }

        return response()->json([
            'message' => 'تم تحديث الإعداد بنجاح',
            'key' => $key
        ]);
    }

    /**
     * حذف إعداد
     */
    public function destroy(string $key): JsonResponse
    {
        $setting = Setting::where('key', $key)->firstOrFail();
        $setting->delete();

        Setting::clearCache();

        return response()->json(['message' => 'تم حذف الإعداد بنجاح']);
    }

    /**
     * عرض الإعدادات العامة
     */
    public function public(): JsonResponse
    {
        $settings = Setting::public()->get();

        $result = [];
        foreach ($settings as $setting) {
            $result[$setting->key] = Setting::get($setting->key);
        }

        return response()->json($result);
    }
}
