<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ApiKey;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class ApiKeyController extends Controller
{
    /**
     * عرض جميع مفاتيح API الخاصة بالمستخدم
     */
    public function index(Request $request): JsonResponse
    {
        $apiKeys = ApiKey::where('user_id', $request->user()->id)
            ->latest()
            ->get()
            ->map(function ($key) {
                return [
                    'id' => $key->id,
                    'name' => $key->name,
                    'description' => $key->description,
                    'masked_key' => $key->masked_key,
                    'is_active' => $key->is_active,
                    'rate_limit' => $key->rate_limit,
                    'total_requests' => $key->total_requests,
                    'last_used_at' => $key->last_used_at,
                    'expires_at' => $key->expires_at,
                    'created_at' => $key->created_at,
                ];
            });

        return response()->json($apiKeys);
    }

    /**
     * إنشاء مفتاح API جديد
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'permissions' => 'nullable|array',
            'allowed_ips' => 'nullable|array',
            'rate_limit' => 'nullable|integer|min:1|max:1000',
            'expires_at' => 'nullable|date|after:now',
        ]);

        $validated['user_id'] = $request->user()->id;

        $apiKey = ApiKey::create($validated);

        return response()->json([
            'message' => 'تم إنشاء مفتاح API بنجاح',
            'api_key' => [
                'id' => $apiKey->id,
                'name' => $apiKey->name,
                'key' => $apiKey->key, // Show full key only on creation
                'description' => $apiKey->description,
                'is_active' => $apiKey->is_active,
                'rate_limit' => $apiKey->rate_limit,
                'expires_at' => $apiKey->expires_at,
            ],
        ], 201);
    }

    /**
     * عرض مفتاح API واحد
     */
    public function show(Request $request, string $id): JsonResponse
    {
        $apiKey = ApiKey::where('user_id', $request->user()->id)
            ->findOrFail($id);

        return response()->json([
            'id' => $apiKey->id,
            'name' => $apiKey->name,
            'description' => $apiKey->description,
            'masked_key' => $apiKey->masked_key,
            'permissions' => $apiKey->permissions,
            'allowed_ips' => $apiKey->allowed_ips,
            'is_active' => $apiKey->is_active,
            'rate_limit' => $apiKey->rate_limit,
            'total_requests' => $apiKey->total_requests,
            'last_used_at' => $apiKey->last_used_at,
            'expires_at' => $apiKey->expires_at,
            'created_at' => $apiKey->created_at,
        ]);
    }

    /**
     * تحديث مفتاح API
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $apiKey = ApiKey::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
            'permissions' => 'nullable|array',
            'allowed_ips' => 'nullable|array',
            'rate_limit' => 'nullable|integer|min:1|max:1000',
            'is_active' => 'sometimes|boolean',
            'expires_at' => 'nullable|date|after:now',
        ]);

        $apiKey->update($validated);

        return response()->json([
            'message' => 'تم تحديث مفتاح API بنجاح',
            'api_key' => $apiKey,
        ]);
    }

    /**
     * حذف مفتاح API
     */
    public function destroy(Request $request, string $id): JsonResponse
    {
        $apiKey = ApiKey::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $apiKey->delete();

        return response()->json([
            'message' => 'تم حذف مفتاح API بنجاح',
        ]);
    }

    /**
     * إحصائيات استخدام مفتاح API
     */
    public function stats(Request $request, string $id): JsonResponse
    {
        $apiKey = ApiKey::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $logs = $apiKey->logs();

        return response()->json([
            'total_requests' => $logs->count(),
            'successful_requests' => $logs->successful()->count(),
            'failed_requests' => $logs->failed()->count(),
            'today_requests' => $logs->today()->count(),
            'avg_response_time' => round($logs->avg('response_time') ?? 0),
            'last_used_at' => $apiKey->last_used_at,
        ]);
    }

    /**
     * تجديد مفتاح API (إنشاء مفتاح جديد)
     */
    public function regenerate(Request $request, string $id): JsonResponse
    {
        $apiKey = ApiKey::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $newKey = ApiKey::generateKey();
        $apiKey->update(['key' => $newKey]);

        return response()->json([
            'message' => 'تم تجديد مفتاح API بنجاح',
            'new_key' => $newKey, // Show new key only once
        ]);
    }
}
