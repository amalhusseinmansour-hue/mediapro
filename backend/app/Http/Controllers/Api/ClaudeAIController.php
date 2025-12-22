<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ClaudeAIService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;
use Exception;

class ClaudeAIController extends Controller
{
    protected ClaudeAIService $claudeService;

    public function __construct(ClaudeAIService $claudeService)
    {
        $this->claudeService = $claudeService;
    }

    /**
     * Check service status
     */
    public function status(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'configured' => $this->claudeService->isConfigured(),
            'provider' => 'claude',
        ]);
    }

    /**
     * Generate social media content
     */
    public function generateContent(Request $request): JsonResponse
    {
        $request->validate([
            'topic' => 'required|string|max:1000',
            'platform' => 'required|string|in:instagram,facebook,twitter,tiktok,linkedin,youtube,snapchat',
            'content_type' => 'string|in:post,story,reel,carousel,tweet,thread,video,article,caption,title,description,script',
            'language' => 'string|in:ar,en,fr,es',
            'tone' => 'string|in:professional,casual,funny,inspiring,educational,urgent,friendly,formal',
            'include_hashtags' => 'boolean',
            'include_emojis' => 'boolean',
            'target_audience' => 'string|max:200',
            'brand' => 'string|max:200',
            'keywords' => 'array',
            'variations' => 'integer|min:1|max:5',
        ]);

        try {
            $result = $this->claudeService->generateContent([
                'topic' => $request->topic,
                'platform' => $request->platform,
                'content_type' => $request->content_type ?? 'post',
                'language' => $request->language ?? 'ar',
                'tone' => $request->tone ?? 'professional',
                'include_hashtags' => $request->include_hashtags ?? true,
                'include_emojis' => $request->include_emojis ?? true,
                'target_audience' => $request->target_audience ?? 'general',
                'brand' => $request->brand,
                'keywords' => $request->keywords ?? [],
                'variations' => $request->variations ?? 1,
            ]);

            // Parse JSON from content if present
            $content = $result['content'];
            $parsedContent = $this->parseJsonFromContent($content);

            return response()->json([
                'success' => true,
                'data' => [
                    'raw_content' => $content,
                    'parsed' => $parsedContent,
                    'provider' => 'claude',
                    'usage' => $result['usage'] ?? null,
                ],
            ]);
        } catch (Exception $e) {
            Log::error('Claude content generation error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Generate hashtags only
     */
    public function generateHashtags(Request $request): JsonResponse
    {
        $request->validate([
            'topic' => 'required|string|max:500',
            'platform' => 'string|in:instagram,facebook,twitter,tiktok,linkedin',
            'count' => 'integer|min:5|max:30',
            'language' => 'string|in:ar,en,fr,es',
        ]);

        try {
            $result = $this->claudeService->generateHashtags(
                $request->topic,
                $request->platform ?? 'instagram',
                $request->count ?? 15,
                $request->language ?? 'ar'
            );

            $parsedContent = $this->parseJsonFromContent($result['content']);

            return response()->json([
                'success' => true,
                'data' => [
                    'hashtags' => $parsedContent,
                    'usage' => $result['usage'] ?? null,
                ],
            ]);
        } catch (Exception $e) {
            Log::error('Claude hashtag generation error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Generate content ideas
     */
    public function generateIdeas(Request $request): JsonResponse
    {
        $request->validate([
            'niche' => 'required|string|max:200',
            'platform' => 'string|in:instagram,facebook,twitter,tiktok,linkedin,youtube',
            'count' => 'integer|min:5|max:30',
            'timeframe' => 'string|in:day,week,month',
        ]);

        try {
            $result = $this->claudeService->generateContentIdeas([
                'niche' => $request->niche,
                'platform' => $request->platform ?? 'instagram',
                'count' => $request->count ?? 10,
                'timeframe' => $request->timeframe ?? 'week',
            ]);

            $parsedContent = $this->parseJsonFromContent($result['content']);

            return response()->json([
                'success' => true,
                'data' => [
                    'ideas' => $parsedContent,
                    'usage' => $result['usage'] ?? null,
                ],
            ]);
        } catch (Exception $e) {
            Log::error('Claude ideas generation error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Improve existing content
     */
    public function improveContent(Request $request): JsonResponse
    {
        $request->validate([
            'content' => 'required|string|max:5000',
            'platform' => 'string|in:instagram,facebook,twitter,tiktok,linkedin',
            'improvements' => 'array',
            'improvements.*' => 'string|in:engagement,clarity,hashtags,hook,length',
        ]);

        try {
            $result = $this->claudeService->improveContent(
                $request->content,
                [
                    'platform' => $request->platform ?? 'instagram',
                    'improvements' => $request->improvements ?? ['engagement', 'clarity', 'hashtags'],
                ]
            );

            $parsedContent = $this->parseJsonFromContent($result['content']);

            return response()->json([
                'success' => true,
                'data' => [
                    'improved' => $parsedContent,
                    'usage' => $result['usage'] ?? null,
                ],
            ]);
        } catch (Exception $e) {
            Log::error('Claude content improvement error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Generate video script
     */
    public function generateVideoScript(Request $request): JsonResponse
    {
        $request->validate([
            'topic' => 'required|string|max:500',
            'platform' => 'string|in:tiktok,instagram,youtube,facebook',
            'duration' => 'integer|min:15|max:600',
            'style' => 'string|in:educational,entertaining,promotional,storytelling',
            'language' => 'string|in:ar,en,fr,es',
        ]);

        try {
            $result = $this->claudeService->generateVideoScript([
                'topic' => $request->topic,
                'platform' => $request->platform ?? 'tiktok',
                'duration' => $request->duration ?? 60,
                'style' => $request->style ?? 'educational',
                'language' => $request->language ?? 'ar',
            ]);

            $parsedContent = $this->parseJsonFromContent($result['content']);

            return response()->json([
                'success' => true,
                'data' => [
                    'script' => $parsedContent,
                    'usage' => $result['usage'] ?? null,
                ],
            ]);
        } catch (Exception $e) {
            Log::error('Claude video script generation error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Analyze content
     */
    public function analyzeContent(Request $request): JsonResponse
    {
        $request->validate([
            'content' => 'required|string|max:5000',
            'platform' => 'string|in:instagram,facebook,twitter,tiktok,linkedin',
        ]);

        try {
            $result = $this->claudeService->analyzeContent(
                $request->content,
                $request->platform ?? 'instagram'
            );

            $parsedContent = $this->parseJsonFromContent($result['content']);

            return response()->json([
                'success' => true,
                'data' => [
                    'analysis' => $parsedContent,
                    'usage' => $result['usage'] ?? null,
                ],
            ]);
        } catch (Exception $e) {
            Log::error('Claude content analysis error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Generate content calendar
     */
    public function generateCalendar(Request $request): JsonResponse
    {
        $request->validate([
            'niche' => 'required|string|max:200',
            'platforms' => 'array',
            'platforms.*' => 'string|in:instagram,facebook,twitter,tiktok,linkedin,youtube',
            'days' => 'integer|min:1|max:30',
            'posts_per_day' => 'integer|min:1|max:5',
        ]);

        try {
            $result = $this->claudeService->generateContentCalendar([
                'niche' => $request->niche,
                'platforms' => $request->platforms ?? ['instagram'],
                'days' => $request->days ?? 7,
                'posts_per_day' => $request->posts_per_day ?? 1,
            ]);

            $parsedContent = $this->parseJsonFromContent($result['content']);

            return response()->json([
                'success' => true,
                'data' => [
                    'calendar' => $parsedContent,
                    'usage' => $result['usage'] ?? null,
                ],
            ]);
        } catch (Exception $e) {
            Log::error('Claude calendar generation error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Generate comprehensive content for all platforms
     */
    public function generateComprehensive(Request $request): JsonResponse
    {
        $request->validate([
            'topic' => 'required|string|max:1000',
            'platforms' => 'array',
            'platforms.*' => 'string|in:instagram,facebook,twitter,tiktok,linkedin,youtube',
            'language' => 'string|in:ar,en,fr,es',
            'tone' => 'string|in:professional,casual,funny,inspiring,educational',
            'brand' => 'string|max:200',
        ]);

        try {
            $result = $this->claudeService->generateComprehensiveContent([
                'topic' => $request->topic,
                'platforms' => $request->platforms ?? ['instagram', 'facebook', 'twitter'],
                'language' => $request->language ?? 'ar',
                'tone' => $request->tone ?? 'professional',
                'brand' => $request->brand,
            ]);

            $parsedContent = $this->parseJsonFromContent($result['content']);

            return response()->json([
                'success' => true,
                'data' => [
                    'content' => $parsedContent,
                    'usage' => $result['usage'] ?? null,
                ],
            ]);
        } catch (Exception $e) {
            Log::error('Claude comprehensive generation error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Parse JSON from Claude response
     */
    protected function parseJsonFromContent(string $content): ?array
    {
        // Try to extract JSON from markdown code blocks
        if (preg_match('/```json\s*([\s\S]*?)\s*```/', $content, $matches)) {
            $jsonStr = $matches[1];
            $decoded = json_decode($jsonStr, true);
            if (json_last_error() === JSON_ERROR_NONE) {
                return $decoded;
            }
        }

        // Try to parse the entire content as JSON
        $decoded = json_decode($content, true);
        if (json_last_error() === JSON_ERROR_NONE) {
            return $decoded;
        }

        // Return as text if not valid JSON
        return ['text' => $content];
    }
}
