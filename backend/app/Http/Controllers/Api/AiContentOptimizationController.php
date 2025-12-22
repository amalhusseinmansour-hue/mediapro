<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\AiContentOptimizationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AiContentOptimizationController extends Controller
{
    protected AiContentOptimizationService $aiService;

    public function __construct(AiContentOptimizationService $aiService)
    {
        $this->aiService = $aiService;
    }

    /**
     * Generate content variations for A/B testing
     */
    public function generateVariations(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'content' => 'required|string|min:10|max:5000',
            'platform' => 'required|string|in:instagram,facebook,twitter,linkedin,tiktok',
            'count' => 'nullable|integer|min:2|max:5',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $userId = $request->user()?->id;
        $result = $this->aiService->generateVariations(
            $request->content,
            $request->platform,
            $request->count ?? 3,
            $userId
        );

        return response()->json($result, $result['success'] ? 200 : ($result['retry_after'] ?? false ? 429 : 500));
    }

    /**
     * Optimize content for specific platform
     */
    public function optimizeContent(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'content' => 'required|string|min:10|max:5000',
            'platform' => 'required|string|in:instagram,facebook,twitter,linkedin,tiktok',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $userId = $request->user()?->id;
        $result = $this->aiService->optimizeForPlatform(
            $request->content,
            $request->platform,
            $userId
        );

        return response()->json($result, $result['success'] ? 200 : ($result['retry_after'] ?? false ? 429 : 500));
    }

    /**
     * Analyze content and get improvement suggestions
     */
    public function analyzeContent(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'content' => 'required|string|min:10|max:5000',
            'platform' => 'required|string|in:instagram,facebook,twitter,linkedin,tiktok',
            'target_audience' => 'nullable|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $userId = $request->user()?->id;
        $result = $this->aiService->analyzeContent(
            $request->content,
            $request->platform,
            $request->target_audience,
            $userId
        );

        return response()->json($result, $result['success'] ? 200 : ($result['retry_after'] ?? false ? 429 : 500));
    }

    /**
     * Get hashtag suggestions
     */
    public function suggestHashtags(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'content' => 'required|string|min:10|max:5000',
            'platform' => 'required|string|in:instagram,facebook,twitter,linkedin,tiktok',
            'count' => 'nullable|integer|min:5|max:30',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $userId = $request->user()?->id;
        $result = $this->aiService->suggestHashtags(
            $request->content,
            $request->platform,
            $request->count ?? 10,
            $userId
        );

        return response()->json($result, $result['success'] ? 200 : ($result['retry_after'] ?? false ? 429 : 500));
    }

    /**
     * Get best posting time suggestions
     */
    public function suggestPostingTimes(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'content' => 'required|string|min:10|max:5000',
            'platform' => 'required|string|in:instagram,facebook,twitter,linkedin,tiktok',
            'timezone' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $userId = $request->user()?->id;
        $result = $this->aiService->suggestPostingTimes(
            $request->content,
            $request->platform,
            $request->timezone ?? 'Asia/Dubai',
            $userId
        );

        return response()->json($result, $result['success'] ? 200 : ($result['retry_after'] ?? false ? 429 : 500));
    }

    /**
     * Rewrite content in different tone
     */
    public function rewriteInTone(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'content' => 'required|string|min:10|max:5000',
            'tone' => 'required|string|in:professional,casual,funny,inspiring,educational,urgent,friendly,formal',
            'platform' => 'required|string|in:instagram,facebook,twitter,linkedin,tiktok',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $userId = $request->user()?->id;
        $result = $this->aiService->rewriteInTone(
            $request->content,
            $request->tone,
            $request->platform,
            $userId
        );

        return response()->json($result, $result['success'] ? 200 : ($result['retry_after'] ?? false ? 429 : 500));
    }

    /**
     * Translate and localize content
     */
    public function translateContent(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'content' => 'required|string|min:10|max:5000',
            'target_language' => 'required|string|in:arabic,english,french,spanish,german,chinese,japanese,korean,hindi,portuguese',
            'platform' => 'required|string|in:instagram,facebook,twitter,linkedin,tiktok',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $userId = $request->user()?->id;
        $result = $this->aiService->translateContent(
            $request->content,
            $request->target_language,
            $request->platform,
            $userId
        );

        return response()->json($result, $result['success'] ? 200 : ($result['retry_after'] ?? false ? 429 : 500));
    }

    /**
     * Generate content from brief
     */
    public function generateFromBrief(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'topic' => 'required|string|min:5|max:500',
            'platforms' => 'required|array|min:1',
            'platforms.*' => 'string|in:instagram,facebook,twitter,linkedin,tiktok',
            'tone' => 'nullable|string|in:professional,casual,funny,inspiring,educational,urgent,friendly,formal',
            'goals' => 'nullable|array',
            'goals.*' => 'string|in:engagement,awareness,traffic,sales,education,entertainment',
            'keywords' => 'nullable|array',
            'keywords.*' => 'string|max:50',
            'target_audience' => 'nullable|string|max:500',
            'additional_notes' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $userId = $request->user()?->id;
        $result = $this->aiService->generateFromBrief([
            'topic' => $request->topic,
            'platforms' => $request->platforms,
            'tone' => $request->tone ?? 'professional',
            'goals' => $request->goals ?? ['engagement'],
            'keywords' => $request->keywords ?? [],
            'target_audience' => $request->target_audience ?? '',
            'additional_notes' => $request->additional_notes ?? '',
        ], $userId);

        return response()->json($result, $result['success'] ? 200 : ($result['retry_after'] ?? false ? 429 : 500));
    }

    /**
     * Check content for potential issues
     */
    public function checkContent(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'content' => 'required|string|min:10|max:5000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $userId = $request->user()?->id;
        $result = $this->aiService->checkContent($request->content, $userId);

        return response()->json($result, $result['success'] ? 200 : ($result['retry_after'] ?? false ? 429 : 500));
    }

    /**
     * Batch optimize content for multiple platforms
     */
    public function batchOptimize(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'content' => 'required|string|min:10|max:5000',
            'platforms' => 'required|array|min:1|max:5',
            'platforms.*' => 'string|in:instagram,facebook,twitter,linkedin,tiktok',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $userId = $request->user()?->id;
        $results = [];
        foreach ($request->platforms as $platform) {
            $results[$platform] = $this->aiService->optimizeForPlatform(
                $request->content,
                $platform,
                $userId
            );
        }

        return response()->json([
            'success' => true,
            'original' => $request->content,
            'optimized' => $results,
        ]);
    }

    /**
     * Get available tones
     */
    public function getAvailableTones(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'tones' => [
                ['id' => 'professional', 'name' => 'Professional', 'name_ar' => 'احترافي', 'description' => 'Formal and business-oriented'],
                ['id' => 'casual', 'name' => 'Casual', 'name_ar' => 'غير رسمي', 'description' => 'Relaxed and conversational'],
                ['id' => 'funny', 'name' => 'Funny', 'name_ar' => 'مرح', 'description' => 'Humorous and entertaining'],
                ['id' => 'inspiring', 'name' => 'Inspiring', 'name_ar' => 'ملهم', 'description' => 'Motivational and uplifting'],
                ['id' => 'educational', 'name' => 'Educational', 'name_ar' => 'تعليمي', 'description' => 'Informative and teaching'],
                ['id' => 'urgent', 'name' => 'Urgent', 'name_ar' => 'عاجل', 'description' => 'Creates sense of urgency'],
                ['id' => 'friendly', 'name' => 'Friendly', 'name_ar' => 'ودود', 'description' => 'Warm and approachable'],
                ['id' => 'formal', 'name' => 'Formal', 'name_ar' => 'رسمي', 'description' => 'Highly professional and formal'],
            ],
        ]);
    }

    /**
     * Get supported languages
     */
    public function getSupportedLanguages(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'languages' => [
                ['id' => 'arabic', 'name' => 'Arabic', 'name_ar' => 'العربية', 'code' => 'ar'],
                ['id' => 'english', 'name' => 'English', 'name_ar' => 'الإنجليزية', 'code' => 'en'],
                ['id' => 'french', 'name' => 'French', 'name_ar' => 'الفرنسية', 'code' => 'fr'],
                ['id' => 'spanish', 'name' => 'Spanish', 'name_ar' => 'الإسبانية', 'code' => 'es'],
                ['id' => 'german', 'name' => 'German', 'name_ar' => 'الألمانية', 'code' => 'de'],
                ['id' => 'chinese', 'name' => 'Chinese', 'name_ar' => 'الصينية', 'code' => 'zh'],
                ['id' => 'japanese', 'name' => 'Japanese', 'name_ar' => 'اليابانية', 'code' => 'ja'],
                ['id' => 'korean', 'name' => 'Korean', 'name_ar' => 'الكورية', 'code' => 'ko'],
                ['id' => 'hindi', 'name' => 'Hindi', 'name_ar' => 'الهندية', 'code' => 'hi'],
                ['id' => 'portuguese', 'name' => 'Portuguese', 'name_ar' => 'البرتغالية', 'code' => 'pt'],
            ],
        ]);
    }

    /**
     * Get AI service stats (rate limits, cache status, providers)
     */
    public function getStats(Request $request): JsonResponse
    {
        $userId = $request->user()?->id;
        $stats = $this->aiService->getStats($userId);

        return response()->json([
            'success' => true,
            'stats' => $stats,
            'config' => [
                'platforms' => config('ai.platforms'),
                'tones' => config('ai.tones'),
                'languages' => config('ai.languages'),
                'max_content_length' => config('ai.optimization.max_content_length', 5000),
            ],
        ]);
    }

    /**
     * Clear AI cache (admin only)
     */
    public function clearCache(Request $request): JsonResponse
    {
        // Check if user is admin
        if (!$request->user()?->is_admin) {
            return response()->json([
                'success' => false,
                'error' => 'Unauthorized. Admin access required.',
            ], 403);
        }

        $type = $request->input('type'); // null = all, or specific type like 'variations'
        $this->aiService->clearCache($type);

        return response()->json([
            'success' => true,
            'message' => $type ? "Cache cleared for type: {$type}" : 'All AI cache cleared',
        ]);
    }

    /**
     * Batch process multiple prompts concurrently
     */
    public function batchProcess(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'prompts' => 'required|array|min:1|max:10',
            'prompts.*' => 'required|string|min:10|max:2000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $results = $this->aiService->batchProcess($request->prompts);

        return response()->json([
            'success' => true,
            'results' => $results,
        ]);
    }
}
