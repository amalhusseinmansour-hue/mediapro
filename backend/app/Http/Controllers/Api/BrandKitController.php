<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\BrandKit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class BrandKitController extends Controller
{
    public function index(Request $request)
    {
        $brandKits = $request->user()->brandKits()->latest()->get();
        return response()->json($brandKits);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'logo' => 'nullable|image|max:2048',
            'colors' => 'nullable|array',
            'fonts' => 'nullable|array',
            'tone' => 'nullable|string',
            'voice' => 'nullable|string',
            'tagline' => 'nullable|string',
            'keywords' => 'nullable|array',
            'target_audience' => 'nullable|array',
            'social_links' => 'nullable|array',
            'is_default' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        $data['user_id'] = $request->user()->id;

        // Handle logo upload
        if ($request->hasFile('logo')) {
            $data['logo'] = $request->file('logo')->store('brand-kits', 'public');
        }

        $brandKit = BrandKit::create($data);

        if ($data['is_default'] ?? false) {
            $brandKit->setAsDefault();
        }

        return response()->json([
            'message' => 'Brand Kit created successfully',
            'brand_kit' => $brandKit,
        ], 201);
    }

    public function show(Request $request, $id)
    {
        $brandKit = $request->user()->brandKits()->findOrFail($id);
        return response()->json($brandKit);
    }

    public function update(Request $request, $id)
    {
        $brandKit = $request->user()->brandKits()->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
            'logo' => 'nullable|image|max:2048',
            'colors' => 'nullable|array',
            'fonts' => 'nullable|array',
            'tone' => 'nullable|string',
            'voice' => 'nullable|string',
            'tagline' => 'nullable|string',
            'keywords' => 'nullable|array',
            'target_audience' => 'nullable|array',
            'social_links' => 'nullable|array',
            'is_default' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();

        // Handle logo upload
        if ($request->hasFile('logo')) {
            if ($brandKit->logo) {
                Storage::disk('public')->delete($brandKit->logo);
            }
            $data['logo'] = $request->file('logo')->store('brand-kits', 'public');
        }

        $brandKit->update($data);

        if ($data['is_default'] ?? false) {
            $brandKit->setAsDefault();
        }

        return response()->json([
            'message' => 'Brand Kit updated successfully',
            'brand_kit' => $brandKit->fresh(),
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $brandKit = $request->user()->brandKits()->findOrFail($id);

        if ($brandKit->logo) {
            Storage::disk('public')->delete($brandKit->logo);
        }

        $brandKit->delete();

        return response()->json(['message' => 'Brand Kit deleted successfully']);
    }

    public function setDefault(Request $request, $id)
    {
        $brandKit = $request->user()->brandKits()->findOrFail($id);
        $brandKit->setAsDefault();

        return response()->json([
            'message' => 'Brand Kit set as default',
            'brand_kit' => $brandKit->fresh(),
        ]);
    }

    public function getDefault(Request $request)
    {
        $brandKit = $request->user()->brandKits()->where('is_default', true)->first();

        if (!$brandKit) {
            return response()->json(['message' => 'No default brand kit found'], 404);
        }

        return response()->json($brandKit);
    }
}
