<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class AIVideoGeneratorService
{
    protected array $providers = [
        'gemini' => GeminiVideoService::class,
        'runway' => RunwayMLService::class,
        'replicate' => ReplicateService::class,
        'pika' => PikaLabsService::class,
        'd-id' => DIDService::class,
        'stability' => StabilityAIService::class,
    ];

    /**
     * Generate video using specified provider.
     */
    public function generateVideo(
        string $prompt,
        string $provider = 'runway',
        int $duration = 4,
        string $aspectRatio = '16:9',
        array $options = []
    ): array {
        if (!isset($this->providers[$provider])) {
            return [
                'success' => false,
                'error' => 'Provider not supported: ' . $provider,
            ];
        }

        $serviceClass = $this->providers[$provider];
        $service = new $serviceClass();

        try {
            return $service->generateVideo($prompt, $duration, $aspectRatio, $options);
        } catch (\Exception $e) {
            Log::error('AI Video Generation failed', [
                'provider' => $provider,
                'prompt' => $prompt,
                'error' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Check generation status.
     */
    public function checkStatus(string $taskId, string $provider): array
    {
        if (!isset($this->providers[$provider])) {
            return [
                'success' => false,
                'error' => 'Provider not supported: ' . $provider,
            ];
        }

        $serviceClass = $this->providers[$provider];
        $service = new $serviceClass();

        return $service->checkStatus($taskId);
    }

    /**
     * Get available providers with their capabilities.
     */
    public function getAvailableProviders(): array
    {
        // Check which services are configured
        $geminiService = new GeminiVideoService();
        $runwayService = new RunwayMLService();
        $replicateService = new ReplicateService();

        return [
            'gemini' => [
                'name' => 'Google Gemini Veo 3.1',
                'status' => $geminiService->isConfigured() ? 'active' : 'not_configured',
                'cost_per_second' => 0.75,
                'cost_per_second_fast' => 0.25,
                'max_duration' => 8,
                'quality' => 'excellent',
                'features' => ['text-to-video', 'image-to-video', 'video-extension', 'reference-images', 'native-audio', '1080p'],
                'models' => ['veo-3.1-generate-preview', 'veo-3.1-fast-generate-preview'],
                'aspect_ratios' => ['16:9', '9:16'],
                'resolutions' => ['720p', '1080p'],
                'estimated_time' => 120,
                'recommended' => true,
            ],
            'runway' => [
                'name' => 'Runway ML Gen-4 Turbo',
                'status' => $runwayService->isConfigured() ? 'active' : 'not_configured',
                'cost_per_video' => 0.25,
                'max_duration' => 10,
                'quality' => 'excellent',
                'features' => ['text-to-video', 'image-to-video', 'high-quality', 'commercial-use'],
                'models' => ['gen4_turbo', 'gen3a_turbo'],
                'aspect_ratios' => ['16:9', '9:16', '1:1'],
                'estimated_time' => 180,
            ],
            'replicate' => [
                'name' => 'Replicate (Stable Video Diffusion)',
                'status' => $replicateService->isConfigured() ? 'active' : 'not_configured',
                'cost_per_video' => 0.10,
                'max_duration' => 4,
                'quality' => 'good',
                'features' => ['image-to-video', 'open-source', 'customizable'],
                'models' => ['stable-video-diffusion'],
                'aspect_ratios' => ['16:9'],
                'estimated_time' => 120,
            ],
            'pika' => [
                'name' => 'Pika Labs',
                'status' => 'active',
                'cost_per_video' => 0.30,
                'max_duration' => 8,
                'quality' => 'excellent',
                'features' => ['text-to-video', 'image-to-video', 'creative-styles'],
                'aspect_ratios' => ['16:9', '9:16', '1:1'],
                'estimated_time' => 150,
            ],
            'd-id' => [
                'name' => 'D-ID (Avatar Videos)',
                'status' => 'active',
                'cost_per_video' => 0.30,
                'max_duration' => 120,
                'quality' => 'good',
                'features' => ['talking-head', 'avatar-videos', 'multi-language'],
                'aspect_ratios' => ['16:9', '9:16'],
                'estimated_time' => 60,
            ],
            'stability' => [
                'name' => 'Stability AI Video',
                'status' => 'active',
                'cost_per_frame' => 0.02,
                'max_duration' => 10,
                'quality' => 'very-good',
                'features' => ['open-source', 'customizable', 'image-to-video'],
                'aspect_ratios' => ['16:9'],
                'estimated_time' => 180,
            ],
        ];
    }

    /**
     * Get status of all configured providers
     */
    public function getProvidersStatus(): array
    {
        $status = [];
        foreach ($this->providers as $key => $serviceClass) {
            try {
                $service = new $serviceClass();
                $status[$key] = [
                    'configured' => $service->isConfigured(),
                    'available' => true,
                ];
            } catch (\Exception $e) {
                $status[$key] = [
                    'configured' => false,
                    'available' => false,
                    'error' => $e->getMessage(),
                ];
            }
        }
        return $status;
    }
}

/**
 * Runway ML Service - Updated for Gen-4 API
 * Uses the correct api.dev.runwayml.com endpoint
 */
class RunwayMLService
{
    protected string $apiKey;
    protected string $baseUrl = 'https://api.dev.runwayml.com/v1';

    public function __construct()
    {
        $this->apiKey = config('services.runway.api_key', env('RUNWAY_API_KEY'));
    }

    /**
     * Generate video from text/image using Gen-4 Turbo
     */
    public function generateVideo(string $prompt, int $duration, string $aspectRatio, array $options = []): array
    {
        // Convert aspect ratio to resolution format
        $ratio = $this->convertAspectRatio($aspectRatio);

        $payload = [
            'promptText' => $prompt,
            'model' => $options['model'] ?? 'gen4_turbo',
            'ratio' => $ratio,
            'duration' => min($duration, 10), // Max 10 seconds
            'watermark' => $options['watermark'] ?? false,
        ];

        // Add image if provided (image-to-video)
        if (isset($options['image_url']) && !empty($options['image_url'])) {
            $payload['promptImage'] = $options['image_url'];
        } else {
            // For text-to-video, use a placeholder or generated image
            $payload['promptImage'] = $options['placeholder_image'] ??
                'https://picsum.photos/seed/' . abs(crc32($prompt)) . '/1280/720';
        }

        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $this->apiKey,
            'Content-Type' => 'application/json',
            'X-Runway-Version' => '2024-11-06',
        ])->timeout(60)->post($this->baseUrl . '/image_to_video', $payload);

        if ($response->successful()) {
            $data = $response->json();
            Log::info('Runway ML video generation started', [
                'task_id' => $data['id'] ?? null,
                'status' => $data['status'] ?? 'pending',
            ]);

            return [
                'success' => true,
                'task_id' => $data['id'],
                'status' => $data['status'] ?? 'PENDING',
                'estimated_time' => 180, // ~3 minutes
                'provider' => 'runway',
            ];
        }

        $errorData = $response->json();
        $errorMessage = $errorData['error'] ?? $errorData['message'] ?? 'Unknown error';

        // Check for specific errors
        if (str_contains(strtolower($errorMessage), 'credits') ||
            str_contains(strtolower($errorMessage), 'not enough')) {
            $errorMessage = 'Runway ML: Not enough credits. Please top up your account.';
        }

        Log::error('Runway ML video generation failed', [
            'error' => $errorMessage,
            'response' => $errorData,
        ]);

        return [
            'success' => false,
            'error' => $errorMessage,
            'provider' => 'runway',
        ];
    }

    /**
     * Check generation status
     */
    public function checkStatus(string $taskId): array
    {
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $this->apiKey,
            'X-Runway-Version' => '2024-11-06',
        ])->timeout(30)->get($this->baseUrl . '/tasks/' . $taskId);

        if ($response->successful()) {
            $data = $response->json();
            $status = $data['status'] ?? 'unknown';

            $result = [
                'success' => true,
                'status' => $status,
                'progress' => $data['progress'] ?? 0,
                'provider' => 'runway',
            ];

            if ($status === 'SUCCEEDED' && isset($data['output']) && count($data['output']) > 0) {
                $result['video_url'] = $data['output'][0];
                $result['download_url'] = $data['output'][0];
            } elseif ($status === 'FAILED') {
                $result['success'] = false;
                $result['error'] = $data['error'] ?? 'Generation failed';
            }

            return $result;
        }

        return [
            'success' => false,
            'error' => 'Failed to check status',
            'provider' => 'runway',
        ];
    }

    /**
     * Convert aspect ratio string to resolution format
     */
    private function convertAspectRatio(string $aspectRatio): string
    {
        $ratios = [
            '16:9' => '1280:720',
            '9:16' => '720:1280',
            '1:1' => '720:720',
            '4:3' => '960:720',
            '3:4' => '720:960',
        ];

        return $ratios[$aspectRatio] ?? '1280:720';
    }

    /**
     * Check if service is configured
     */
    public function isConfigured(): bool
    {
        return !empty($this->apiKey) && !str_contains($this->apiKey, 'your_');
    }
}

/**
 * Replicate Service - For Stable Video Diffusion
 */
class ReplicateService
{
    protected string $apiToken;
    protected string $baseUrl = 'https://api.replicate.com/v1';
    protected string $defaultModel = 'stability-ai/stable-video-diffusion:3f0457e4619daac51203dedb472816fd4af51f3149fa7a9e0b5ffcf1b8172438';

    public function __construct()
    {
        $this->apiToken = config('services.replicate.api_token', env('REPLICATE_API_TOKEN'));
    }

    /**
     * Generate video using Stable Video Diffusion
     */
    public function generateVideo(string $prompt, int $duration, string $aspectRatio, array $options = []): array
    {
        // For image-to-video, we need an image URL
        $imageUrl = $options['image_url'] ?? null;

        if (!$imageUrl) {
            // Generate an image first using a placeholder
            $imageUrl = 'https://picsum.photos/seed/' . abs(crc32($prompt)) . '/1024/576';
        }

        $payload = [
            'version' => $options['version'] ?? $this->defaultModel,
            'input' => [
                'input_image' => $imageUrl,
                'motion_bucket_id' => $options['motion'] ?? 127,
                'fps' => $options['fps'] ?? 25,
                'cond_aug' => $options['cond_aug'] ?? 0.02,
                'decoding_t' => $options['decoding_t'] ?? 7,
                'seed' => $options['seed'] ?? rand(0, 999999),
            ],
        ];

        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $this->apiToken,
            'Content-Type' => 'application/json',
        ])->timeout(60)->post($this->baseUrl . '/predictions', $payload);

        if ($response->successful()) {
            $data = $response->json();

            Log::info('Replicate video generation started', [
                'prediction_id' => $data['id'] ?? null,
                'status' => $data['status'] ?? 'pending',
            ]);

            return [
                'success' => true,
                'task_id' => $data['id'],
                'status' => $data['status'] ?? 'starting',
                'estimated_time' => 120, // ~2 minutes
                'provider' => 'replicate',
            ];
        }

        $errorData = $response->json();
        Log::error('Replicate video generation failed', [
            'error' => $errorData,
        ]);

        return [
            'success' => false,
            'error' => $errorData['detail'] ?? 'Unknown error',
            'provider' => 'replicate',
        ];
    }

    /**
     * Check prediction status
     */
    public function checkStatus(string $taskId): array
    {
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $this->apiToken,
        ])->timeout(30)->get($this->baseUrl . '/predictions/' . $taskId);

        if ($response->successful()) {
            $data = $response->json();
            $status = $data['status'] ?? 'unknown';

            $result = [
                'success' => true,
                'status' => $status,
                'provider' => 'replicate',
            ];

            if ($status === 'succeeded' && isset($data['output'])) {
                $result['video_url'] = is_array($data['output']) ? $data['output'][0] : $data['output'];
                $result['download_url'] = $result['video_url'];
            } elseif ($status === 'failed') {
                $result['success'] = false;
                $result['error'] = $data['error'] ?? 'Generation failed';
            }

            return $result;
        }

        return [
            'success' => false,
            'error' => 'Failed to check status',
            'provider' => 'replicate',
        ];
    }

    /**
     * Check if service is configured
     */
    public function isConfigured(): bool
    {
        return !empty($this->apiToken) && !str_contains($this->apiToken, 'your_');
    }
}

/**
 * Pika Labs Service
 */
class PikaLabsService
{
    protected string $apiKey;
    protected string $baseUrl = 'https://api.pikalabs.com/v1';

    public function __construct()
    {
        $this->apiKey = config('services.pika.api_key', env('PIKA_API_KEY'));
    }

    public function generateVideo(string $prompt, int $duration, string $aspectRatio, array $options = []): array
    {
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $this->apiKey,
            'Content-Type' => 'application/json',
        ])->post($this->baseUrl . '/videos/generate', [
            'prompt' => $prompt,
            'duration' => $duration,
            'aspect_ratio' => $aspectRatio,
            'style' => $options['style'] ?? 'realistic',
            'motion_strength' => $options['motion'] ?? 0.7,
        ]);

        if ($response->successful()) {
            $data = $response->json();
            return [
                'success' => true,
                'task_id' => $data['generation_id'],
                'status' => $data['status'],
                'estimated_time' => $duration * 3,
            ];
        }

        return [
            'success' => false,
            'error' => $response->json()['error'] ?? 'Unknown error',
        ];
    }

    public function checkStatus(string $taskId): array
    {
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $this->apiKey,
        ])->get($this->baseUrl . '/videos/' . $taskId);

        if ($response->successful()) {
            return $response->json();
        }

        return [
            'success' => false,
            'error' => 'Failed to check status',
        ];
    }
}

/**
 * D-ID Service (for talking head videos)
 */
class DIDService
{
    protected string $apiKey;
    protected string $baseUrl = 'https://api.d-id.com';

    public function __construct()
    {
        $this->apiKey = config('services.d_id.api_key', env('DID_API_KEY'));
    }

    public function generateVideo(string $prompt, int $duration, string $aspectRatio, array $options = []): array
    {
        // D-ID focuses on talking head videos, so we modify the approach
        $script = [
            'type' => 'text',
            'input' => $prompt,
            'provider' => [
                'type' => 'microsoft',
                'voice_id' => $options['voice'] ?? 'en-US-AriaNeural',
            ],
        ];

        $presenter = [
            'type' => 'talk',
            'source_url' => $options['avatar_image'] ?? 'https://via.placeholder.com/512x512/0000FF/FFFFFF?text=Avatar',
        ];

        $response = Http::withHeaders([
            'Authorization' => 'Basic ' . base64_encode($this->apiKey),
            'Content-Type' => 'application/json',
        ])->post($this->baseUrl . '/talks', [
            'script' => $script,
            'presenter' => $presenter,
            'config' => [
                'stitch' => true,
                'result_format' => 'mp4',
            ],
        ]);

        if ($response->successful()) {
            $data = $response->json();
            return [
                'success' => true,
                'task_id' => $data['id'],
                'status' => $data['status'],
                'estimated_time' => 60, // D-ID usually takes about 1 minute
            ];
        }

        return [
            'success' => false,
            'error' => $response->json()['error'] ?? 'Unknown error',
        ];
    }

    public function checkStatus(string $taskId): array
    {
        $response = Http::withHeaders([
            'Authorization' => 'Basic ' . base64_encode($this->apiKey),
        ])->get($this->baseUrl . '/talks/' . $taskId);

        if ($response->successful()) {
            return $response->json();
        }

        return [
            'success' => false,
            'error' => 'Failed to check status',
        ];
    }
}

/**
 * Stability AI Service
 */
class StabilityAIService
{
    protected string $apiKey;
    protected string $baseUrl = 'https://api.stability.ai/v2beta';

    public function __construct()
    {
        $this->apiKey = config('services.stability.api_key', env('STABILITY_API_KEY'));
    }

    public function generateVideo(string $prompt, int $duration, string $aspectRatio, array $options = []): array
    {
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $this->apiKey,
            'Content-Type' => 'application/json',
        ])->post($this->baseUrl . '/image-to-video', [
            'prompt' => $prompt,
            'aspect_ratio' => $aspectRatio,
            'motion_bucket_id' => $options['motion'] ?? 127,
            'seed' => $options['seed'] ?? rand(0, 1000000),
        ]);

        if ($response->successful()) {
            $data = $response->json();
            return [
                'success' => true,
                'task_id' => $data['id'],
                'status' => 'processing',
                'estimated_time' => $duration * 4, // Stability AI takes longer
            ];
        }

        return [
            'success' => false,
            'error' => $response->json()['error'] ?? 'Unknown error',
        ];
    }

    public function checkStatus(string $taskId): array
    {
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $this->apiKey,
        ])->get($this->baseUrl . '/generation/' . $taskId);

        if ($response->successful()) {
            return $response->json();
        }

        return [
            'success' => false,
            'error' => 'Failed to check status',
        ];
    }
}