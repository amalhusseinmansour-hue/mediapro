<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Http\Client\Pool;

class AiContentOptimizationService
{
    protected string $claudeApiKey;
    protected string $geminiApiKey;
    protected string $openaiApiKey;
    protected string $claudeBaseUrl = 'https://api.anthropic.com/v1';

    // Cache settings
    protected int $cacheMinutes = 60; // Cache for 1 hour
    protected bool $cacheEnabled = true;

    // Rate limiting settings
    protected int $maxRequestsPerMinute = 30;

    public function __construct()
    {
        $this->claudeApiKey = config('services.claude.api_key') ?? env('CLAUDE_API_KEY', '');
        $this->geminiApiKey = config('services.gemini.api_key') ?? env('GEMINI_API_KEY', '');
        $this->openaiApiKey = config('services.openai.api_key') ?? env('OPENAI_API_KEY', '');
        $this->cacheEnabled = config('ai.cache_enabled', true);
        $this->cacheMinutes = config('ai.cache_minutes', 60);
    }

    /**
     * Generate cache key for AI requests
     */
    protected function generateCacheKey(string $type, string $content, array $params = []): string
    {
        $hash = md5($content . serialize($params));
        return "ai_boost:{$type}:{$hash}";
    }

    /**
     * Check rate limit for user
     */
    protected function checkRateLimit(?int $userId = null): bool
    {
        $key = 'ai_requests:' . ($userId ?? 'global');

        if (RateLimiter::tooManyAttempts($key, $this->maxRequestsPerMinute)) {
            return false;
        }

        RateLimiter::hit($key, 60);
        return true;
    }

    /**
     * Get remaining rate limit attempts
     */
    public function getRateLimitRemaining(?int $userId = null): int
    {
        $key = 'ai_requests:' . ($userId ?? 'global');
        return RateLimiter::remaining($key, $this->maxRequestsPerMinute);
    }

    /**
     * Clear cache for specific type or all
     */
    public function clearCache(?string $type = null): bool
    {
        if ($type) {
            Cache::forget("ai_boost:{$type}:*");
        } else {
            // Clear all AI cache
            Cache::tags(['ai_boost'])->flush();
        }
        return true;
    }

    /**
     * Generate content variations for A/B testing (with caching)
     */
    public function generateVariations(string $content, string $platform, int $count = 3, ?int $userId = null): array
    {
        // Check rate limit
        if (!$this->checkRateLimit($userId)) {
            return [
                'success' => false,
                'error' => 'Rate limit exceeded. Please try again later.',
                'retry_after' => 60,
            ];
        }

        // Check cache first
        $cacheKey = $this->generateCacheKey('variations', $content, ['platform' => $platform, 'count' => $count]);

        if ($this->cacheEnabled && Cache::has($cacheKey)) {
            Log::info('AI Boost: Cache hit for variations', ['cache_key' => $cacheKey]);
            $cached = Cache::get($cacheKey);
            $cached['cached'] = true;
            return $cached;
        }

        try {
            $prompt = $this->buildVariationsPrompt($content, $platform, $count);
            $response = $this->callAiApi($prompt);

            if (!$response['success']) {
                return $response;
            }

            $variations = $this->parseVariationsResponse($response['content']);

            $result = [
                'success' => true,
                'original' => $content,
                'variations' => $variations,
                'platform' => $platform,
                'provider' => $response['provider'] ?? 'claude',
                'cached' => false,
            ];

            // Cache the result
            if ($this->cacheEnabled) {
                Cache::put($cacheKey, $result, now()->addMinutes($this->cacheMinutes));
            }

            return $result;
        } catch (\Exception $e) {
            Log::error('AI Variations Error: ' . $e->getMessage());
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Optimize content for a specific platform (with caching)
     */
    public function optimizeForPlatform(string $content, string $platform, ?int $userId = null): array
    {
        // Check rate limit
        if (!$this->checkRateLimit($userId)) {
            return [
                'success' => false,
                'error' => 'Rate limit exceeded. Please try again later.',
                'retry_after' => 60,
            ];
        }

        // Check cache
        $cacheKey = $this->generateCacheKey('optimize', $content, ['platform' => $platform]);

        if ($this->cacheEnabled && Cache::has($cacheKey)) {
            Log::info('AI Boost: Cache hit for optimization', ['cache_key' => $cacheKey]);
            $cached = Cache::get($cacheKey);
            $cached['cached'] = true;
            return $cached;
        }

        try {
            $prompt = $this->buildOptimizationPrompt($content, $platform);
            $response = $this->callAiApi($prompt);

            if (!$response['success']) {
                return $response;
            }

            $optimized = $this->parseOptimizedResponse($response['content']);

            $result = [
                'success' => true,
                'original' => $content,
                'optimized' => $optimized,
                'platform' => $platform,
                'provider' => $response['provider'] ?? 'claude',
                'cached' => false,
            ];

            // Cache the result
            if ($this->cacheEnabled) {
                Cache::put($cacheKey, $result, now()->addMinutes($this->cacheMinutes));
            }

            return $result;
        } catch (\Exception $e) {
            Log::error('AI Optimization Error: ' . $e->getMessage());
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Analyze content and provide improvement suggestions (with caching)
     */
    public function analyzeContent(string $content, string $platform, ?string $targetAudience = null, ?int $userId = null): array
    {
        if (!$this->checkRateLimit($userId)) {
            return ['success' => false, 'error' => 'Rate limit exceeded.', 'retry_after' => 60];
        }

        $cacheKey = $this->generateCacheKey('analyze', $content, ['platform' => $platform, 'audience' => $targetAudience]);

        if ($this->cacheEnabled && Cache::has($cacheKey)) {
            $cached = Cache::get($cacheKey);
            $cached['cached'] = true;
            return $cached;
        }

        try {
            $prompt = $this->buildAnalysisPrompt($content, $platform, $targetAudience);
            $response = $this->callAiApi($prompt);

            if (!$response['success']) {
                return $response;
            }

            $analysis = $this->parseAnalysisResponse($response['content']);

            $result = [
                'success' => true,
                'content' => $content,
                'analysis' => $analysis,
                'provider' => $response['provider'] ?? 'unknown',
                'cached' => false,
            ];

            if ($this->cacheEnabled) {
                Cache::put($cacheKey, $result, now()->addMinutes($this->cacheMinutes));
            }

            return $result;
        } catch (\Exception $e) {
            Log::error('AI Analysis Error: ' . $e->getMessage());
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Generate hashtag suggestions (with caching)
     */
    public function suggestHashtags(string $content, string $platform, int $count = 10, ?int $userId = null): array
    {
        if (!$this->checkRateLimit($userId)) {
            return ['success' => false, 'error' => 'Rate limit exceeded.', 'retry_after' => 60];
        }

        $cacheKey = $this->generateCacheKey('hashtags', $content, ['platform' => $platform, 'count' => $count]);

        if ($this->cacheEnabled && Cache::has($cacheKey)) {
            $cached = Cache::get($cacheKey);
            $cached['cached'] = true;
            return $cached;
        }

        try {
            $prompt = $this->buildHashtagPrompt($content, $platform, $count);
            $response = $this->callAiApi($prompt);

            if (!$response['success']) {
                return $response;
            }

            $hashtags = $this->parseHashtagResponse($response['content']);

            $result = [
                'success' => true,
                'hashtags' => $hashtags,
                'platform' => $platform,
                'provider' => $response['provider'] ?? 'unknown',
                'cached' => false,
            ];

            if ($this->cacheEnabled) {
                Cache::put($cacheKey, $result, now()->addMinutes($this->cacheMinutes));
            }

            return $result;
        } catch (\Exception $e) {
            Log::error('AI Hashtag Error: ' . $e->getMessage());
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Suggest best posting times based on content and audience (with caching)
     */
    public function suggestPostingTimes(string $content, string $platform, ?string $timezone = 'Asia/Dubai', ?int $userId = null): array
    {
        if (!$this->checkRateLimit($userId)) {
            return ['success' => false, 'error' => 'Rate limit exceeded.', 'retry_after' => 60];
        }

        $cacheKey = $this->generateCacheKey('posting_times', $content, ['platform' => $platform, 'tz' => $timezone]);

        if ($this->cacheEnabled && Cache::has($cacheKey)) {
            $cached = Cache::get($cacheKey);
            $cached['cached'] = true;
            return $cached;
        }

        try {
            $prompt = $this->buildPostingTimePrompt($content, $platform, $timezone);
            $response = $this->callAiApi($prompt);

            if (!$response['success']) {
                return $response;
            }

            $times = $this->parsePostingTimesResponse($response['content']);

            $result = [
                'success' => true,
                'suggested_times' => $times,
                'timezone' => $timezone,
                'provider' => $response['provider'] ?? 'unknown',
                'cached' => false,
            ];

            if ($this->cacheEnabled) {
                Cache::put($cacheKey, $result, now()->addMinutes($this->cacheMinutes));
            }

            return $result;
        } catch (\Exception $e) {
            Log::error('AI Posting Times Error: ' . $e->getMessage());
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Rewrite content in different tones (with caching)
     */
    public function rewriteInTone(string $content, string $tone, string $platform, ?int $userId = null): array
    {
        if (!$this->checkRateLimit($userId)) {
            return ['success' => false, 'error' => 'Rate limit exceeded.', 'retry_after' => 60];
        }

        $cacheKey = $this->generateCacheKey('tone', $content, ['tone' => $tone, 'platform' => $platform]);

        if ($this->cacheEnabled && Cache::has($cacheKey)) {
            $cached = Cache::get($cacheKey);
            $cached['cached'] = true;
            return $cached;
        }

        try {
            $prompt = $this->buildToneRewritePrompt($content, $tone, $platform);
            $response = $this->callAiApi($prompt);

            if (!$response['success']) {
                return $response;
            }

            $result = [
                'success' => true,
                'original' => $content,
                'rewritten' => trim($response['content']),
                'tone' => $tone,
                'provider' => $response['provider'] ?? 'unknown',
                'cached' => false,
            ];

            if ($this->cacheEnabled) {
                Cache::put($cacheKey, $result, now()->addMinutes($this->cacheMinutes));
            }

            return $result;
        } catch (\Exception $e) {
            Log::error('AI Tone Rewrite Error: ' . $e->getMessage());
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Translate and localize content (with caching)
     */
    public function translateContent(string $content, string $targetLanguage, string $platform, ?int $userId = null): array
    {
        if (!$this->checkRateLimit($userId)) {
            return ['success' => false, 'error' => 'Rate limit exceeded.', 'retry_after' => 60];
        }

        $cacheKey = $this->generateCacheKey('translate', $content, ['lang' => $targetLanguage, 'platform' => $platform]);

        if ($this->cacheEnabled && Cache::has($cacheKey)) {
            $cached = Cache::get($cacheKey);
            $cached['cached'] = true;
            return $cached;
        }

        try {
            $prompt = $this->buildTranslationPrompt($content, $targetLanguage, $platform);
            $response = $this->callAiApi($prompt);

            if (!$response['success']) {
                return $response;
            }

            $result = [
                'success' => true,
                'original' => $content,
                'translated' => trim($response['content']),
                'target_language' => $targetLanguage,
                'provider' => $response['provider'] ?? 'unknown',
                'cached' => false,
            ];

            if ($this->cacheEnabled) {
                Cache::put($cacheKey, $result, now()->addMinutes($this->cacheMinutes));
            }

            return $result;
        } catch (\Exception $e) {
            Log::error('AI Translation Error: ' . $e->getMessage());
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Generate content from brief/idea (with caching)
     */
    public function generateFromBrief(array $brief, ?int $userId = null): array
    {
        if (!$this->checkRateLimit($userId)) {
            return ['success' => false, 'error' => 'Rate limit exceeded.', 'retry_after' => 60];
        }

        $cacheKey = $this->generateCacheKey('brief', json_encode($brief), []);

        if ($this->cacheEnabled && Cache::has($cacheKey)) {
            $cached = Cache::get($cacheKey);
            $cached['cached'] = true;
            return $cached;
        }

        try {
            $prompt = $this->buildBriefPrompt($brief);
            $response = $this->callAiApi($prompt);

            if (!$response['success']) {
                return $response;
            }

            $generated = $this->parseGeneratedContent($response['content'], $brief['platforms'] ?? ['instagram']);

            $result = [
                'success' => true,
                'brief' => $brief,
                'generated' => $generated,
                'provider' => $response['provider'] ?? 'unknown',
                'cached' => false,
            ];

            if ($this->cacheEnabled) {
                Cache::put($cacheKey, $result, now()->addMinutes($this->cacheMinutes));
            }

            return $result;
        } catch (\Exception $e) {
            Log::error('AI Brief Generation Error: ' . $e->getMessage());
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Check content for potential issues (with caching)
     */
    public function checkContent(string $content, ?int $userId = null): array
    {
        if (!$this->checkRateLimit($userId)) {
            return ['success' => false, 'error' => 'Rate limit exceeded.', 'retry_after' => 60];
        }

        $cacheKey = $this->generateCacheKey('check', $content, []);

        if ($this->cacheEnabled && Cache::has($cacheKey)) {
            $cached = Cache::get($cacheKey);
            $cached['cached'] = true;
            return $cached;
        }

        try {
            $prompt = $this->buildContentCheckPrompt($content);
            $response = $this->callAiApi($prompt);

            if (!$response['success']) {
                return $response;
            }

            $check = $this->parseContentCheckResponse($response['content']);

            $result = [
                'success' => true,
                'content' => $content,
                'check' => $check,
                'provider' => $response['provider'] ?? 'unknown',
                'cached' => false,
            ];

            if ($this->cacheEnabled) {
                Cache::put($cacheKey, $result, now()->addMinutes($this->cacheMinutes));
            }

            return $result;
        } catch (\Exception $e) {
            Log::error('AI Content Check Error: ' . $e->getMessage());
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Call AI API with multi-provider support and fallback
     * Priority: Gemini (fast/cheap) -> Claude (quality) -> OpenAI (fallback)
     */
    protected function callAiApi(string $prompt, ?string $preferredProvider = null): array
    {
        $providers = $this->getAvailableProviders();

        if (empty($providers)) {
            return [
                'success' => false,
                'error' => 'No AI provider configured. Please configure Claude, Gemini, or OpenAI API key.',
            ];
        }

        // Use preferred provider if available
        if ($preferredProvider && in_array($preferredProvider, $providers)) {
            array_unshift($providers, $preferredProvider);
            $providers = array_unique($providers);
        }

        $lastError = '';

        foreach ($providers as $provider) {
            try {
                Log::info("AI Boost: Trying provider {$provider}");

                $result = match ($provider) {
                    'gemini' => $this->callGeminiApi($prompt),
                    'claude' => $this->callClaudeApi($prompt),
                    'openai' => $this->callOpenAiApi($prompt),
                    default => null,
                };

                if ($result && $result['success']) {
                    $result['provider'] = $provider;
                    Log::info("AI Boost: Success with provider {$provider}");
                    return $result;
                }

                $lastError = $result['error'] ?? 'Unknown error';
                Log::warning("AI Boost: Provider {$provider} failed: {$lastError}");

            } catch (\Exception $e) {
                $lastError = $e->getMessage();
                Log::warning("AI Boost: Provider {$provider} exception: {$lastError}");
            }
        }

        return [
            'success' => false,
            'error' => "All providers failed. Last error: {$lastError}",
        ];
    }

    /**
     * Get available AI providers
     */
    protected function getAvailableProviders(): array
    {
        $providers = [];

        // Priority order: Gemini (fast/cheap) -> Claude (quality) -> OpenAI
        if (!empty($this->geminiApiKey)) {
            $providers[] = 'gemini';
        }
        if (!empty($this->claudeApiKey)) {
            $providers[] = 'claude';
        }
        if (!empty($this->openaiApiKey)) {
            $providers[] = 'openai';
        }

        return $providers;
    }

    /**
     * Call Gemini API (fast and cost-effective)
     */
    protected function callGeminiApi(string $prompt): array
    {
        $model = config('services.gemini.model', 'gemini-2.0-flash');

        $response = Http::timeout(60)->post(
            "https://generativelanguage.googleapis.com/v1beta/models/{$model}:generateContent?key={$this->geminiApiKey}",
            [
                'contents' => [
                    [
                        'parts' => [
                            ['text' => $prompt],
                        ],
                    ],
                ],
                'generationConfig' => [
                    'temperature' => 0.7,
                    'maxOutputTokens' => 2048,
                ],
            ]
        );

        if (!$response->successful()) {
            return [
                'success' => false,
                'error' => $response->json('error.message') ?? 'Gemini API request failed',
            ];
        }

        $data = $response->json();
        $content = $data['candidates'][0]['content']['parts'][0]['text'] ?? '';

        return [
            'success' => true,
            'content' => $content,
            'provider' => 'gemini',
        ];
    }

    /**
     * Call Claude API (high quality)
     */
    protected function callClaudeApi(string $prompt, string $model = 'claude-3-5-sonnet-20241022'): array
    {
        $response = Http::withHeaders([
            'x-api-key' => $this->claudeApiKey,
            'anthropic-version' => '2023-06-01',
            'Content-Type' => 'application/json',
        ])->timeout(60)->post($this->claudeBaseUrl . '/messages', [
            'model' => $model,
            'max_tokens' => 2048,
            'messages' => [
                ['role' => 'user', 'content' => $prompt]
            ],
        ]);

        if (!$response->successful()) {
            return [
                'success' => false,
                'error' => $response->json('error.message') ?? 'Claude API request failed',
            ];
        }

        $data = $response->json();
        $content = $data['content'][0]['text'] ?? '';

        return [
            'success' => true,
            'content' => $content,
            'provider' => 'claude',
        ];
    }

    /**
     * Call OpenAI API (fallback)
     */
    protected function callOpenAiApi(string $prompt): array
    {
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $this->openaiApiKey,
            'Content-Type' => 'application/json',
        ])->timeout(60)->post('https://api.openai.com/v1/chat/completions', [
            'model' => 'gpt-4-turbo',
            'max_tokens' => 2048,
            'messages' => [
                ['role' => 'system', 'content' => 'You are a helpful social media content assistant.'],
                ['role' => 'user', 'content' => $prompt]
            ],
        ]);

        if (!$response->successful()) {
            return [
                'success' => false,
                'error' => $response->json('error.message') ?? 'OpenAI API request failed',
            ];
        }

        $data = $response->json();
        $content = $data['choices'][0]['message']['content'] ?? '';

        return [
            'success' => true,
            'content' => $content,
            'provider' => 'openai',
        ];
    }

    /**
     * Batch process multiple prompts concurrently
     */
    public function batchProcess(array $prompts): array
    {
        $results = Http::pool(fn (Pool $pool) =>
            collect($prompts)->map(fn ($prompt, $key) =>
                $pool->as($key)
                    ->timeout(60)
                    ->withHeaders([
                        'x-api-key' => $this->claudeApiKey,
                        'anthropic-version' => '2023-06-01',
                        'Content-Type' => 'application/json',
                    ])
                    ->post($this->claudeBaseUrl . '/messages', [
                        'model' => 'claude-3-5-sonnet-20241022',
                        'max_tokens' => 2048,
                        'messages' => [['role' => 'user', 'content' => $prompt]],
                    ])
            )->toArray()
        );

        $parsed = [];
        foreach ($results as $key => $response) {
            if ($response->successful()) {
                $data = $response->json();
                $parsed[$key] = [
                    'success' => true,
                    'content' => $data['content'][0]['text'] ?? '',
                ];
            } else {
                $parsed[$key] = [
                    'success' => false,
                    'error' => $response->json('error.message') ?? 'Request failed',
                ];
            }
        }

        return $parsed;
    }

    /**
     * Get AI service stats
     */
    public function getStats(?int $userId = null): array
    {
        return [
            'rate_limit_remaining' => $this->getRateLimitRemaining($userId),
            'cache_enabled' => $this->cacheEnabled,
            'cache_ttl_minutes' => $this->cacheMinutes,
            'available_providers' => $this->getAvailableProviders(),
        ];
    }

    // Prompt builders
    protected function buildVariationsPrompt(string $content, string $platform, int $count): string
    {
        return <<<PROMPT
Generate {$count} variations of the following social media content for {$platform}.
Each variation should:
- Keep the core message but approach it differently
- Be optimized for {$platform}'s best practices
- Have different hooks/openings
- Vary in tone while staying professional

Original content:
"{$content}"

Respond in JSON format:
{
  "variations": [
    {
      "content": "variation text",
      "hook_type": "question/statistic/story/bold_statement",
      "tone": "formal/casual/inspiring/educational"
    }
  ]
}
PROMPT;
    }

    protected function buildOptimizationPrompt(string $content, string $platform): string
    {
        $platformGuidelines = $this->getPlatformGuidelines($platform);

        return <<<PROMPT
Optimize the following content for {$platform}.

Platform Guidelines:
{$platformGuidelines}

Original content:
"{$content}"

Provide an optimized version that:
1. Follows platform best practices
2. Has an engaging hook
3. Includes clear call-to-action
4. Is properly formatted for the platform

Respond in JSON format:
{
  "optimized_content": "the optimized text",
  "changes_made": ["list of improvements"],
  "character_count": number,
  "recommended_hashtags": ["hashtag1", "hashtag2"]
}
PROMPT;
    }

    protected function buildAnalysisPrompt(string $content, string $platform, ?string $targetAudience): string
    {
        $audienceInfo = $targetAudience ? "Target Audience: {$targetAudience}" : "";

        return <<<PROMPT
Analyze this social media content for {$platform}.
{$audienceInfo}

Content:
"{$content}"

Provide a comprehensive analysis in JSON format:
{
  "overall_score": 0-100,
  "engagement_potential": "low/medium/high",
  "strengths": ["list of strengths"],
  "weaknesses": ["list of weaknesses"],
  "suggestions": [
    {
      "aspect": "hook/cta/formatting/etc",
      "current": "current state",
      "suggestion": "improvement suggestion",
      "priority": "high/medium/low"
    }
  ],
  "readability_score": 0-100,
  "emotional_tone": "positive/neutral/negative",
  "estimated_reach": "low/medium/high"
}
PROMPT;
    }

    protected function buildHashtagPrompt(string $content, string $platform, int $count): string
    {
        return <<<PROMPT
Suggest {$count} relevant hashtags for this {$platform} content.

Content:
"{$content}"

Consider:
- Relevance to content
- Search volume potential
- Mix of popular and niche hashtags
- Platform-specific best practices

Respond in JSON format:
{
  "hashtags": [
    {
      "tag": "#hashtag",
      "category": "niche/trending/branded/community",
      "estimated_reach": "low/medium/high",
      "relevance_score": 0-100
    }
  ]
}
PROMPT;
    }

    protected function buildPostingTimePrompt(string $content, string $platform, string $timezone): string
    {
        return <<<PROMPT
Suggest optimal posting times for this {$platform} content.
Timezone: {$timezone}

Content:
"{$content}"

Consider:
- Platform engagement patterns
- Content type (educational, entertaining, promotional)
- General audience behavior

Respond in JSON format:
{
  "best_days": ["Monday", "Wednesday"],
  "best_times": [
    {
      "day": "Monday",
      "time": "09:00",
      "reason": "why this time is good"
    }
  ],
  "avoid_times": ["times to avoid"],
  "general_tip": "overall posting strategy tip"
}
PROMPT;
    }

    protected function buildToneRewritePrompt(string $content, string $tone, string $platform): string
    {
        return <<<PROMPT
Rewrite this {$platform} content in a {$tone} tone.

Original:
"{$content}"

Keep the core message but adjust the tone to be more {$tone}.
Ensure it's still appropriate for {$platform}.

Respond with ONLY the rewritten content, no explanations.
PROMPT;
    }

    protected function buildTranslationPrompt(string $content, string $targetLanguage, string $platform): string
    {
        return <<<PROMPT
Translate and culturally adapt this {$platform} content to {$targetLanguage}.

Original:
"{$content}"

Don't just translate - localize it:
- Adapt idioms and expressions
- Consider cultural context
- Keep it engaging for {$targetLanguage} speakers
- Maintain platform best practices

Respond with ONLY the translated content, no explanations.
PROMPT;
    }

    protected function buildBriefPrompt(array $brief): string
    {
        $topic = $brief['topic'] ?? '';
        $platforms = implode(', ', $brief['platforms'] ?? ['instagram']);
        $tone = $brief['tone'] ?? 'professional';
        $goals = implode(', ', $brief['goals'] ?? ['engagement']);
        $keywords = implode(', ', $brief['keywords'] ?? []);
        $audience = $brief['target_audience'] ?? '';
        $notes = $brief['additional_notes'] ?? '';

        return <<<PROMPT
Generate social media content based on this brief:

Topic: {$topic}
Platforms: {$platforms}
Tone: {$tone}
Goals: {$goals}
Keywords to include: {$keywords}
Target audience: {$audience}
Additional notes: {$notes}

Create optimized content for each platform specified.

Respond in JSON format:
{
  "content": {
    "platform_name": {
      "main_content": "the post content",
      "hook": "attention-grabbing opening",
      "call_to_action": "CTA text",
      "hashtags": ["relevant", "hashtags"],
      "character_count": number
    }
  }
}
PROMPT;
    }

    protected function buildContentCheckPrompt(string $content): string
    {
        return <<<PROMPT
Review this social media content for potential issues:

Content:
"{$content}"

Check for:
1. Sensitive topics or language
2. Potential misinformation
3. Legal/compliance issues
4. Brand safety concerns
5. Accessibility issues

Respond in JSON format:
{
  "is_safe": true/false,
  "risk_level": "low/medium/high",
  "issues": [
    {
      "type": "sensitivity/legal/brand_safety/etc",
      "description": "what the issue is",
      "severity": "low/medium/high",
      "suggestion": "how to fix it"
    }
  ],
  "accessibility_notes": ["any accessibility concerns"],
  "overall_recommendation": "proceed/review/revise"
}
PROMPT;
    }

    protected function getPlatformGuidelines(string $platform): string
    {
        return match (strtolower($platform)) {
            'instagram' => "- Optimal length: 125-150 characters for high engagement
- Use line breaks for readability
- Hashtags: 5-10 relevant tags
- Include call-to-action
- Use emojis strategically",
            'twitter', 'x' => "- Max 280 characters
- Be concise and punchy
- Use 1-2 hashtags maximum
- Include media when possible
- Ask questions to drive engagement",
            'facebook' => "- Optimal: 40-80 characters for high engagement
- Can go longer for storytelling
- Minimal hashtags (1-2)
- Include call-to-action
- Questions perform well",
            'linkedin' => "- Professional tone
- Optimal: 150-300 characters
- Use line breaks for readability
- 3-5 relevant hashtags
- Include industry insights
- Personal stories work well",
            'tiktok' => "- Casual, authentic tone
- Hook in first 3 seconds
- Trending sounds/hashtags
- Call-to-action for engagement
- Keep it entertaining",
            default => "- Be clear and concise
- Include call-to-action
- Use relevant hashtags
- Engage your audience"
        };
    }

    // Response parsers
    protected function parseVariationsResponse(string $response): array
    {
        try {
            // Extract JSON from response
            preg_match('/\{[\s\S]*\}/', $response, $matches);
            if (!empty($matches[0])) {
                $data = json_decode($matches[0], true);
                return $data['variations'] ?? [];
            }
        } catch (\Exception $e) {
            Log::warning('Failed to parse variations response: ' . $e->getMessage());
        }
        return [];
    }

    protected function parseOptimizedResponse(string $response): array
    {
        try {
            preg_match('/\{[\s\S]*\}/', $response, $matches);
            if (!empty($matches[0])) {
                return json_decode($matches[0], true) ?? [];
            }
        } catch (\Exception $e) {
            Log::warning('Failed to parse optimized response: ' . $e->getMessage());
        }
        return ['optimized_content' => $response];
    }

    protected function parseAnalysisResponse(string $response): array
    {
        try {
            preg_match('/\{[\s\S]*\}/', $response, $matches);
            if (!empty($matches[0])) {
                return json_decode($matches[0], true) ?? [];
            }
        } catch (\Exception $e) {
            Log::warning('Failed to parse analysis response: ' . $e->getMessage());
        }
        return [];
    }

    protected function parseHashtagResponse(string $response): array
    {
        try {
            preg_match('/\{[\s\S]*\}/', $response, $matches);
            if (!empty($matches[0])) {
                $data = json_decode($matches[0], true);
                return $data['hashtags'] ?? [];
            }
        } catch (\Exception $e) {
            Log::warning('Failed to parse hashtag response: ' . $e->getMessage());
        }
        return [];
    }

    protected function parsePostingTimesResponse(string $response): array
    {
        try {
            preg_match('/\{[\s\S]*\}/', $response, $matches);
            if (!empty($matches[0])) {
                return json_decode($matches[0], true) ?? [];
            }
        } catch (\Exception $e) {
            Log::warning('Failed to parse posting times response: ' . $e->getMessage());
        }
        return [];
    }

    protected function parseGeneratedContent(string $response, array $platforms): array
    {
        try {
            preg_match('/\{[\s\S]*\}/', $response, $matches);
            if (!empty($matches[0])) {
                $data = json_decode($matches[0], true);
                return $data['content'] ?? [];
            }
        } catch (\Exception $e) {
            Log::warning('Failed to parse generated content: ' . $e->getMessage());
        }
        return [];
    }

    protected function parseContentCheckResponse(string $response): array
    {
        try {
            preg_match('/\{[\s\S]*\}/', $response, $matches);
            if (!empty($matches[0])) {
                return json_decode($matches[0], true) ?? [];
            }
        } catch (\Exception $e) {
            Log::warning('Failed to parse content check response: ' . $e->getMessage());
        }
        return ['is_safe' => true, 'risk_level' => 'low'];
    }
}
