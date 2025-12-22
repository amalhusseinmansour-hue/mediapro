<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Exception;

class AdvancedAIContentService
{
    protected string $openaiKey;
    protected string $geminiKey;
    protected string $claudeKey;
    protected string $replaceKey;
    
    public function __construct()
    {
        $this->openaiKey = config('services.openai.api_key', env('OPENAI_API_KEY', ''));
        $this->geminiKey = config('services.gemini.api_key', env('GEMINI_API_KEY', ''));
        $this->claudeKey = env('CLAUDE_API_KEY', '');
        $this->replaceKey = env('REPLICATE_API_TOKEN', '');
    }

    /**
     * Generate text content using Gemini or Claude (primary providers)
     * Priority: Gemini -> Claude -> OpenAI (fallback)
     */
    public function generateText(string $prompt, array $options = []): array
    {
        $provider = $options['provider'] ?? 'gemini'; // Default to Gemini

        try {
            // Try requested provider first
            if ($provider === 'gemini' && $this->geminiKey) {
                return $this->generateWithGemini($prompt, $options);
            } else if ($provider === 'claude' && $this->claudeKey) {
                return $this->generateWithClaude($prompt, $options);
            }

            // Fallback chain: Gemini -> Claude -> OpenAI
            if ($this->geminiKey) {
                Log::info('🔄 Falling back to Gemini');
                return $this->generateWithGemini($prompt, $options);
            } else if ($this->claudeKey) {
                Log::info('🔄 Falling back to Claude');
                return $this->generateWithClaude($prompt, $options);
            } else if ($this->openaiKey) {
                Log::info('🔄 Falling back to OpenAI');
                return $this->generateWithOpenAI($prompt, $options);
            }

            throw new Exception('No AI provider configured. Please configure Gemini or Claude API key.');
        } catch (Exception $e) {
            Log::error('❌ AI text generation failed', [
                'provider' => $provider,
                'error' => $e->getMessage(),
            ]);

            // Try fallback providers on error
            if ($provider === 'gemini' && $this->claudeKey) {
                Log::info('🔄 Gemini failed, trying Claude...');
                try {
                    return $this->generateWithClaude($prompt, $options);
                } catch (Exception $e2) {
                    Log::error('❌ Claude fallback also failed: ' . $e2->getMessage());
                }
            } else if ($provider === 'claude' && $this->geminiKey) {
                Log::info('🔄 Claude failed, trying Gemini...');
                try {
                    return $this->generateWithGemini($prompt, $options);
                } catch (Exception $e2) {
                    Log::error('❌ Gemini fallback also failed: ' . $e2->getMessage());
                }
            }

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Generate content using OpenAI API
     */
    protected function generateWithOpenAI(string $prompt, array $options = []): array
    {
        $model = $options['model'] ?? 'gpt-4-turbo';
        $temperature = $options['temperature'] ?? 0.7;
        $maxTokens = $options['max_tokens'] ?? 2000;

        Log::info('🤖 Generating text with OpenAI', [
            'model' => $model,
            'prompt_length' => strlen($prompt),
        ]);

        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $this->openaiKey,
            'Content-Type' => 'application/json',
        ])->timeout(120)->post('https://api.openai.com/v1/chat/completions', [
            'model' => $model,
            'messages' => [
                ['role' => 'system', 'content' => 'You are a helpful content creation assistant. Generate engaging, creative content.'],
                ['role' => 'user', 'content' => $prompt],
            ],
            'temperature' => $temperature,
            'max_tokens' => $maxTokens,
        ]);

        if ($response->successful()) {
            $data = $response->json();
            $content = $data['choices'][0]['message']['content'] ?? '';

            Log::info('✅ OpenAI text generated successfully', [
                'tokens_used' => $data['usage']['total_tokens'] ?? 0,
            ]);

            return [
                'success' => true,
                'content' => $content,
                'provider' => 'openai',
                'model' => $model,
                'tokens_used' => $data['usage']['total_tokens'] ?? 0,
            ];
        }

        throw new Exception('OpenAI API error: ' . $response->body());
    }

    /**
     * Generate content using Claude API
     */
    protected function generateWithClaude(string $prompt, array $options = []): array
    {
        $model = $options['model'] ?? 'claude-3-5-sonnet-20241022';
        $temperature = $options['temperature'] ?? 0.7;
        $maxTokens = $options['max_tokens'] ?? 2000;

        Log::info('🤖 Generating text with Claude', [
            'model' => $model,
            'prompt_length' => strlen($prompt),
        ]);

        $response = Http::withHeaders([
            'x-api-key' => $this->claudeKey,
            'anthropic-version' => '2023-06-01',
            'content-type' => 'application/json',
        ])->timeout(120)->post('https://api.anthropic.com/v1/messages', [
            'model' => $model,
            'max_tokens' => $maxTokens,
            'temperature' => $temperature,
            'system' => 'You are a helpful content creation assistant. Generate engaging, creative content in Arabic and English.',
            'messages' => [
                ['role' => 'user', 'content' => $prompt],
            ],
        ]);

        if ($response->successful()) {
            $data = $response->json();
            $content = $data['content'][0]['text'] ?? '';

            Log::info('✅ Claude text generated successfully', [
                'input_tokens' => $data['usage']['input_tokens'] ?? 0,
                'output_tokens' => $data['usage']['output_tokens'] ?? 0,
            ]);

            return [
                'success' => true,
                'content' => $content,
                'provider' => 'claude',
                'model' => $model,
                'tokens_used' => ($data['usage']['input_tokens'] ?? 0) + ($data['usage']['output_tokens'] ?? 0),
            ];
        }

        throw new Exception('Claude API error: ' . $response->body());
    }

    /**
     * Generate content using Gemini API
     */
    protected function generateWithGemini(string $prompt, array $options = []): array
    {
        $model = $options['model'] ?? 'gemini-2.0-flash';
        $temperature = $options['temperature'] ?? 0.7;

        Log::info('🤖 Generating text with Gemini', [
            'model' => $model,
            'prompt_length' => strlen($prompt),
        ]);

        $response = Http::timeout(120)->post(
            "https://generativelanguage.googleapis.com/v1beta/models/{$model}:generateContent?key={$this->geminiKey}",
            [
                'contents' => [
                    [
                        'parts' => [
                            ['text' => $prompt],
                        ],
                    ],
                ],
                'generationConfig' => [
                    'temperature' => $temperature,
                    'maxOutputTokens' => $options['max_tokens'] ?? 2000,
                ],
            ]
        );

        if ($response->successful()) {
            $data = $response->json();
            $content = $data['candidates'][0]['content']['parts'][0]['text'] ?? '';

            Log::info('✅ Gemini text generated successfully');

            return [
                'success' => true,
                'content' => $content,
                'provider' => 'gemini',
                'model' => $model,
                'tokens_used' => 0,
            ];
        }

        throw new Exception('Gemini API error: ' . $response->body());
    }

    /**
     * Generate social media content with optimization
     */
    public function generateSocialMediaContent(array $options = []): array
    {
        $topic = $options['topic'] ?? 'general';
        $platform = $options['platform'] ?? 'instagram';
        $tone = $options['tone'] ?? 'professional';
        $language = $options['language'] ?? 'ar';
        $includeHashtags = $options['include_hashtags'] ?? true;
        $includeEmojis = $options['include_emojis'] ?? true;

        $prompt = "Generate engaging {$platform} content about: {$topic}\n";
        $prompt .= "Language: {$language}\n";
        $prompt .= "Tone: {$tone}\n";

        if ($platform === 'instagram') {
            $prompt .= "Format: Caption for Instagram post (max 2200 characters)\n";
            if ($includeHashtags) $prompt .= "Include 10-15 relevant hashtags\n";
            if ($includeEmojis) $prompt .= "Add appropriate emojis\n";
        } elseif ($platform === 'twitter') {
            $prompt .= "Format: Multiple tweets (280 characters each)\n";
            if ($includeHashtags) $prompt .= "Include relevant hashtags\n";
        } elseif ($platform === 'tiktok') {
            $prompt .= "Format: Video script (30-60 seconds)\n";
            $prompt .= "Include hook, main content, call-to-action\n";
        } elseif ($platform === 'linkedin') {
            $prompt .= "Format: Professional article (500-800 words)\n";
            $prompt .= "Include key takeaways\n";
        }

        return $this->generateText($prompt, [
            'provider' => $options['provider'] ?? 'gemini', // Use Gemini as default
            'temperature' => 0.8,
            'max_tokens' => 2000,
        ]);
    }

    /**
     * Check which AI providers are configured
     */
    public function getConfiguredProviders(): array
    {
        $providers = [];

        if (!empty($this->openaiKey)) {
            $providers[] = 'openai';
        }
        if (!empty($this->claudeKey)) {
            $providers[] = 'claude';
        }
        if (!empty($this->geminiKey)) {
            $providers[] = 'gemini';
        }

        return $providers;
    }

    /**
     * Get status of all AI providers
     */
    public function getProvidersStatus(): array
    {
        return [
            'openai' => [
                'configured' => !empty($this->openaiKey),
                'key_preview' => $this->getKeyPreview($this->openaiKey),
            ],
            'claude' => [
                'configured' => !empty($this->claudeKey),
                'key_preview' => $this->getKeyPreview($this->claudeKey),
            ],
            'gemini' => [
                'configured' => !empty($this->geminiKey),
                'key_preview' => $this->getKeyPreview($this->geminiKey),
            ],
        ];
    }

    /**
     * Get safe preview of API key
     */
    protected function getKeyPreview(string $key, int $chars = 6): string
    {
        if (empty($key)) return 'Not configured';
        return substr($key, 0, $chars) . '***' . substr($key, -$chars);
    }
}
