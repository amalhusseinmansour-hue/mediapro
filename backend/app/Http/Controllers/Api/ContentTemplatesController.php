<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ContentTemplate;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class ContentTemplatesController extends Controller
{
    /**
     * Get all content templates
     */
    public function index(Request $request)
    {
        $query = ContentTemplate::query();

        // Filter by platform
        if ($request->has('platform') && !empty($request->platform)) {
            $query->where('platform', $request->platform);
        }

        // Filter by category
        if ($request->has('category') && !empty($request->category)) {
            $query->where('category', $request->category);
        }

        // Filter by type
        if ($request->has('type') && !empty($request->type)) {
            $query->where('type', $request->type);
        }

        // Search
        if ($request->has('search') && !empty($request->search)) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%");
            });
        }

        // Filter by user (for user-specific templates)
        if ($request->has('user_id')) {
            $query->where('user_id', $request->user_id);
        } else {
            // Show system templates (null user_id) or user's own
            $query->where(function($q) use ($request) {
                $q->whereNull('user_id');
                if ($request->user()) {
                    $q->orWhere('user_id', $request->user()->id);
                }
            });
        }

        // Only active templates
        if (!$request->has('include_inactive')) {
            $query->where('is_active', true);
        }

        $templates = $query->orderBy('sort_order')->orderBy('name')->paginate($request->get('per_page', 20));

        return response()->json([
            'success' => true,
            'data' => $templates,
        ]);
    }

    /**
     * Get single template
     */
    public function show($id)
    {
        $template = ContentTemplate::findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $template,
        ]);
    }

    /**
     * Create new template
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'platform' => 'required|string|in:facebook,instagram,twitter,linkedin,tiktok,youtube,all',
            'category' => 'nullable|string',
            'type' => 'required|string|in:text,image,video,carousel,story,reel',
            'content' => 'required|string',
            'variables' => 'nullable|array',
            'hashtags' => 'nullable|array',
            'media_requirements' => 'nullable|array',
            'best_posting_times' => 'nullable|array',
            'is_system' => 'nullable|boolean',
            'sort_order' => 'nullable|integer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $template = ContentTemplate::create([
            'name' => $request->name,
            'slug' => Str::slug($request->name),
            'description' => $request->description,
            'platform' => $request->platform,
            'category' => $request->category,
            'type' => $request->type,
            'content' => $request->content,
            'variables' => $request->variables ?? [],
            'hashtags' => $request->hashtags ?? [],
            'media_requirements' => $request->media_requirements ?? [],
            'best_posting_times' => $request->best_posting_times ?? [],
            'user_id' => $request->is_system ? null : $request->user()->id,
            'is_active' => true,
            'sort_order' => $request->sort_order ?? 0,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Template created successfully',
            'data' => $template,
        ], 201);
    }

    /**
     * Update template
     */
    public function update(Request $request, $id)
    {
        $template = ContentTemplate::findOrFail($id);

        // Check ownership (unless admin)
        if ($template->user_id && $template->user_id !== $request->user()->id) {
            if ($request->user()->role !== 'admin' && $request->user()->role !== 'super_admin') {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized to update this template',
                ], 403);
            }
        }

        $validator = Validator::make($request->all(), [
            'name' => 'nullable|string|max:255',
            'description' => 'nullable|string',
            'platform' => 'nullable|string|in:facebook,instagram,twitter,linkedin,tiktok,youtube,all',
            'category' => 'nullable|string',
            'type' => 'nullable|string|in:text,image,video,carousel,story,reel',
            'content' => 'nullable|string',
            'variables' => 'nullable|array',
            'hashtags' => 'nullable|array',
            'media_requirements' => 'nullable|array',
            'best_posting_times' => 'nullable|array',
            'is_active' => 'nullable|boolean',
            'sort_order' => 'nullable|integer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $updateData = array_filter($request->only([
            'name', 'description', 'platform', 'category', 'type',
            'content', 'variables', 'hashtags', 'media_requirements',
            'best_posting_times', 'is_active', 'sort_order'
        ]), fn($v) => $v !== null);

        if (isset($updateData['name'])) {
            $updateData['slug'] = Str::slug($updateData['name']);
        }

        $template->update($updateData);

        return response()->json([
            'success' => true,
            'message' => 'Template updated successfully',
            'data' => $template->fresh(),
        ]);
    }

    /**
     * Delete template
     */
    public function destroy(Request $request, $id)
    {
        $template = ContentTemplate::findOrFail($id);

        // Check ownership (unless admin)
        if ($template->user_id && $template->user_id !== $request->user()->id) {
            if ($request->user()->role !== 'admin' && $request->user()->role !== 'super_admin') {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized to delete this template',
                ], 403);
            }
        }

        // Don't allow deleting system templates (unless super_admin)
        if (!$template->user_id && $request->user()->role !== 'super_admin') {
            return response()->json([
                'success' => false,
                'message' => 'Cannot delete system templates',
            ], 403);
        }

        $template->delete();

        return response()->json([
            'success' => true,
            'message' => 'Template deleted successfully',
        ]);
    }

    /**
     * Duplicate a template
     */
    public function duplicate(Request $request, $id)
    {
        $template = ContentTemplate::findOrFail($id);

        $newTemplate = $template->replicate();
        $newTemplate->name = $template->name . ' (Copy)';
        $newTemplate->slug = Str::slug($newTemplate->name) . '-' . time();
        $newTemplate->user_id = $request->user()->id;
        $newTemplate->save();

        return response()->json([
            'success' => true,
            'message' => 'Template duplicated successfully',
            'data' => $newTemplate,
        ], 201);
    }

    /**
     * Get template categories
     */
    public function getCategories()
    {
        $categories = ContentTemplate::whereNotNull('category')
            ->where('is_active', true)
            ->distinct()
            ->pluck('category');

        return response()->json([
            'success' => true,
            'data' => $categories,
        ]);
    }

    /**
     * Use template (fill in variables)
     */
    public function useTemplate(Request $request, $id)
    {
        $template = ContentTemplate::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'variables' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $content = $template->content;
        $variables = $request->variables ?? [];

        // Replace variables in content
        foreach ($variables as $key => $value) {
            $content = str_replace('{{' . $key . '}}', $value, $content);
            $content = str_replace('{' . $key . '}', $value, $content);
        }

        // Add hashtags if specified
        $finalHashtags = $template->hashtags ?? [];
        if ($request->has('include_hashtags') && $request->include_hashtags) {
            $content .= "\n\n" . implode(' ', array_map(fn($h) => '#' . $h, $finalHashtags));
        }

        // Increment usage count
        $template->increment('usage_count');

        return response()->json([
            'success' => true,
            'data' => [
                'content' => $content,
                'hashtags' => $finalHashtags,
                'media_requirements' => $template->media_requirements,
                'best_posting_times' => $template->best_posting_times,
                'platform' => $template->platform,
                'type' => $template->type,
            ],
        ]);
    }

    /**
     * Get popular templates
     */
    public function getPopular(Request $request)
    {
        $platform = $request->get('platform');
        $limit = $request->get('limit', 10);

        $query = ContentTemplate::where('is_active', true)
            ->orderBy('usage_count', 'desc');

        if ($platform) {
            $query->where(function($q) use ($platform) {
                $q->where('platform', $platform)
                  ->orWhere('platform', 'all');
            });
        }

        $templates = $query->take($limit)->get();

        return response()->json([
            'success' => true,
            'data' => $templates,
        ]);
    }

    /**
     * Bulk create system templates
     */
    public function bulkCreateSystemTemplates(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'templates' => 'required|array',
            'templates.*.name' => 'required|string',
            'templates.*.platform' => 'required|string',
            'templates.*.type' => 'required|string',
            'templates.*.content' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $created = [];
        foreach ($request->templates as $templateData) {
            $template = ContentTemplate::create([
                'name' => $templateData['name'],
                'slug' => Str::slug($templateData['name']) . '-' . time() . rand(100, 999),
                'description' => $templateData['description'] ?? null,
                'platform' => $templateData['platform'],
                'category' => $templateData['category'] ?? 'general',
                'type' => $templateData['type'],
                'content' => $templateData['content'],
                'variables' => $templateData['variables'] ?? [],
                'hashtags' => $templateData['hashtags'] ?? [],
                'media_requirements' => $templateData['media_requirements'] ?? [],
                'best_posting_times' => $templateData['best_posting_times'] ?? [],
                'user_id' => null, // System template
                'is_active' => true,
                'sort_order' => $templateData['sort_order'] ?? 0,
            ]);
            $created[] = $template;
        }

        return response()->json([
            'success' => true,
            'message' => count($created) . ' templates created successfully',
            'data' => $created,
        ], 201);
    }
}
