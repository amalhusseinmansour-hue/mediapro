<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;

/**
 * Gemini Video Service - Using Veo 3.1 for video generation
 *
 * Veo 3.1 capabilities:
 * - Text-to-video generation
 * - Image-to-video (first frame)
 * - Video extension
 * - Reference images (up to 3)
 * - Native audio generation
 */
class GeminiVideoService
{
    protected string $apiKey;
    protected string $baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
    protected string $model = 'veo-3.1-generate-preview';
    protected string $fastModel = 'veo-3.1-fast-generate-preview';

    public function __construct()
    {
        $this->apiKey = config('services.gemini.api_key', env('GEMINI_API_KEY'));
    }

    /**
     * Generate video from text prompt using Veo 3.1
     */
    public function generateVideo(
        string $prompt,
        int $duration = 4,
        string $aspectRatio = '16:9',
        array $options = []
    ): array {
        try {
            // Use fast model if requested
            $modelToUse = ($options['fast'] ?? false) ? $this->fastModel : $this->model;

            // Build the request payload
            $payload = [
                'instances' => [
                    [
                        'prompt' => $prompt,
                    ]
                ],
                'parameters' => [
                    'aspectRatio' => $aspectRatio,
                    'durationSeconds' => min($duration, 8), // Max 8 seconds - must be integer
                ]
            ];

            // Add negative prompt if provided
            if (!empty($options['negative_prompt'])) {
                $payload['instances'][0]['negativePrompt'] = $options['negative_prompt'];
            }

            // Add first frame image if provided (image-to-video)
            if (!empty($options['image_url'])) {
                $imageData = $this->getImageAsBase64($options['image_url']);
                if ($imageData) {
                    $payload['instances'][0]['image'] = [
                        'bytesBase64Encoded' => $imageData['base64'],
                        'mimeType' => $imageData['mimeType'],
                    ];
                }
            }

            // Add last frame for interpolation
            if (!empty($options['last_frame_url'])) {
                $lastFrameData = $this->getImageAsBase64($options['last_frame_url']);
                if ($lastFrameData) {
                    $payload['instances'][0]['lastFrame'] = [
                        'bytesBase64Encoded' => $lastFrameData['base64'],
                        'mimeType' => $lastFrameData['mimeType'],
                    ];
                }
            }

            // Add reference images (up to 3) for Veo 3.1
            if (!empty($options['reference_images']) && is_array($options['reference_images'])) {
                $refImages = [];
                foreach (array_slice($options['reference_images'], 0, 3) as $refUrl) {
                    $refData = $this->getImageAsBase64($refUrl);
                    if ($refData) {
                        $refImages[] = [
                            'bytesBase64Encoded' => $refData['base64'],
                            'mimeType' => $refData['mimeType'],
                        ];
                    }
                }
                if (!empty($refImages)) {
                    $payload['instances'][0]['referenceImages'] = $refImages;
                }
            }

            Log::info('Gemini Veo video generation request', [
                'model' => $modelToUse,
                'prompt' => substr($prompt, 0, 100),
                'duration' => $duration,
                'aspectRatio' => $aspectRatio,
            ]);

            // Make the API request
            $response = Http::withHeaders([
                'Content-Type' => 'application/json',
            ])->timeout(120)->post(
                "{$this->baseUrl}/models/{$modelToUse}:predictLongRunning?key={$this->apiKey}",
                $payload
            );

            if ($response->successful()) {
                $data = $response->json();

                // Extract operation name for polling
                $operationName = $data['name'] ?? null;

                if (!$operationName) {
                    throw new \Exception('No operation name returned from Gemini API');
                }

                Log::info('Gemini Veo video generation started', [
                    'operation' => $operationName,
                ]);

                return [
                    'success' => true,
                    'task_id' => $operationName,
                    'status' => 'PROCESSING',
                    'estimated_time' => $this->getEstimatedTime($duration, $options['fast'] ?? false),
                    'provider' => 'gemini',
                    'model' => $modelToUse,
                ];
            }

            $errorData = $response->json();
            $errorMessage = $this->parseError($errorData);

            Log::error('Gemini Veo video generation failed', [
                'error' => $errorMessage,
                'response' => $errorData,
                'status_code' => $response->status(),
            ]);

            return [
                'success' => false,
                'error' => $errorMessage,
                'provider' => 'gemini',
            ];

        } catch (\Exception $e) {
            Log::error('Gemini Veo exception', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
                'provider' => 'gemini',
            ];
        }
    }

    /**
     * Check video generation status
     */
    public function checkStatus(string $operationName): array
    {
        try {
            $response = Http::timeout(30)->get(
                "{$this->baseUrl}/{$operationName}?key={$this->apiKey}"
            );

            if ($response->successful()) {
                $data = $response->json();

                $isDone = $data['done'] ?? false;

                $result = [
                    'success' => true,
                    'status' => $isDone ? 'SUCCEEDED' : 'PROCESSING',
                    'provider' => 'gemini',
                ];

                if ($isDone) {
                    // Check for error in response
                    if (isset($data['error'])) {
                        $result['success'] = false;
                        $result['status'] = 'FAILED';
                        $result['error'] = $data['error']['message'] ?? 'Generation failed';
                        return $result;
                    }

                    // Extract video URL from response
                    $response = $data['response'] ?? [];
                    $generatedVideos = $response['generatedVideos'] ?? $response['generated_videos'] ?? [];

                    if (!empty($generatedVideos)) {
                        $videoUri = $generatedVideos[0]['video']['uri'] ?? $generatedVideos[0]['uri'] ?? null;

                        if ($videoUri) {
                            $result['video_url'] = $videoUri;
                            $result['download_url'] = $videoUri;

                            // Try to download and store the video
                            $localUrl = $this->downloadAndStoreVideo($videoUri, $operationName);
                            if ($localUrl) {
                                $result['local_url'] = $localUrl;
                            }
                        }
                    }
                }

                return $result;
            }

            return [
                'success' => false,
                'status' => 'UNKNOWN',
                'error' => 'Failed to check status',
                'provider' => 'gemini',
            ];

        } catch (\Exception $e) {
            Log::error('Gemini status check exception', [
                'operation' => $operationName,
                'error' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
                'provider' => 'gemini',
            ];
        }
    }

    /**
     * Download video from Gemini servers (videos expire after 2 days)
     */
    public function downloadVideo(string $videoUri): ?string
    {
        try {
            $response = Http::withHeaders([
                'x-goog-api-key' => $this->apiKey,
            ])->timeout(300)->get($videoUri);

            if ($response->successful()) {
                $filename = 'gemini_video_' . time() . '_' . uniqid() . '.mp4';
                $path = 'videos/generated/' . $filename;

                Storage::disk('public')->put($path, $response->body());

                return Storage::disk('public')->url($path);
            }

            return null;
        } catch (\Exception $e) {
            Log::error('Failed to download Gemini video', [
                'uri' => $videoUri,
                'error' => $e->getMessage(),
            ]);
            return null;
        }
    }

    /**
     * Extend an existing video (Veo 3.1 feature)
     */
    public function extendVideo(
        string $videoUrl,
        string $prompt,
        int $additionalSeconds = 4
    ): array {
        try {
            $videoData = $this->getVideoAsBase64($videoUrl);

            if (!$videoData) {
                return [
                    'success' => false,
                    'error' => 'Failed to load video for extension',
                    'provider' => 'gemini',
                ];
            }

            $payload = [
                'instances' => [
                    [
                        'prompt' => $prompt,
                        'video' => [
                            'bytesBase64Encoded' => $videoData['base64'],
                            'mimeType' => $videoData['mimeType'],
                        ],
                    ]
                ],
                'parameters' => [
                    'durationSeconds' => min($additionalSeconds, 8), // Must be integer
                ]
            ];

            $response = Http::withHeaders([
                'Content-Type' => 'application/json',
            ])->timeout(120)->post(
                "{$this->baseUrl}/models/{$this->model}:predictLongRunning?key={$this->apiKey}",
                $payload
            );

            if ($response->successful()) {
                $data = $response->json();
                $operationName = $data['name'] ?? null;

                return [
                    'success' => true,
                    'task_id' => $operationName,
                    'status' => 'PROCESSING',
                    'estimated_time' => 180,
                    'provider' => 'gemini',
                    'type' => 'extension',
                ];
            }

            return [
                'success' => false,
                'error' => $this->parseError($response->json()),
                'provider' => 'gemini',
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
                'provider' => 'gemini',
            ];
        }
    }

    /**
     * Check if service is configured
     */
    public function isConfigured(): bool
    {
        return !empty($this->apiKey) &&
               !str_contains($this->apiKey, 'your_') &&
               strlen($this->apiKey) > 20;
    }

    /**
     * Get provider capabilities info
     */
    public function getCapabilities(): array
    {
        return [
            'name' => 'Google Gemini Veo 3.1',
            'status' => $this->isConfigured() ? 'active' : 'not_configured',
            'cost_per_second' => 0.75, // Standard Veo 3 pricing
            'cost_per_second_fast' => 0.25, // Veo 3.1 Fast pricing
            'max_duration' => 8,
            'quality' => 'excellent',
            'features' => [
                'text-to-video',
                'image-to-video',
                'video-extension',
                'reference-images',
                'native-audio',
                'cinematic-styles',
                '1080p-resolution',
            ],
            'models' => ['veo-3.1-generate-preview', 'veo-3.1-fast-generate-preview'],
            'aspect_ratios' => ['16:9', '9:16'],
            'resolutions' => ['720p', '1080p'],
            'estimated_time' => 120,
        ];
    }

    /**
     * Convert image URL to base64
     */
    private function getImageAsBase64(string $url): ?array
    {
        try {
            $response = Http::timeout(30)->get($url);

            if ($response->successful()) {
                $contentType = $response->header('Content-Type') ?? 'image/jpeg';
                $mimeType = explode(';', $contentType)[0];

                return [
                    'base64' => base64_encode($response->body()),
                    'mimeType' => $mimeType,
                ];
            }

            return null;
        } catch (\Exception $e) {
            Log::warning('Failed to convert image to base64', [
                'url' => $url,
                'error' => $e->getMessage(),
            ]);
            return null;
        }
    }

    /**
     * Convert video URL to base64
     */
    private function getVideoAsBase64(string $url): ?array
    {
        try {
            $response = Http::timeout(120)->get($url);

            if ($response->successful()) {
                $contentType = $response->header('Content-Type') ?? 'video/mp4';
                $mimeType = explode(';', $contentType)[0];

                return [
                    'base64' => base64_encode($response->body()),
                    'mimeType' => $mimeType,
                ];
            }

            return null;
        } catch (\Exception $e) {
            Log::warning('Failed to convert video to base64', [
                'url' => $url,
                'error' => $e->getMessage(),
            ]);
            return null;
        }
    }

    /**
     * Download and store video locally
     */
    private function downloadAndStoreVideo(string $videoUri, string $operationName): ?string
    {
        try {
            // Add API key for authenticated download
            $separator = strpos($videoUri, '?') !== false ? '&' : '?';
            $downloadUrl = $videoUri . $separator . 'key=' . $this->apiKey;

            $response = Http::withHeaders([
                'x-goog-api-key' => $this->apiKey,
            ])->timeout(300)->get($downloadUrl);

            if ($response->successful()) {
                $filename = 'gemini_' . substr(md5($operationName), 0, 12) . '_' . time() . '.mp4';
                $path = 'videos/generated/' . $filename;

                Storage::disk('public')->put($path, $response->body());

                return Storage::disk('public')->url($path);
            }

            return null;
        } catch (\Exception $e) {
            Log::warning('Failed to download and store video', [
                'operation' => $operationName,
                'error' => $e->getMessage(),
            ]);
            return null;
        }
    }

    /**
     * Parse error response from API
     */
    private function parseError(array $errorData): string
    {
        if (isset($errorData['error']['message'])) {
            $message = $errorData['error']['message'];

            // Check for quota/billing issues
            if (str_contains(strtolower($message), 'quota') ||
                str_contains(strtolower($message), 'billing')) {
                return 'Gemini API quota exceeded or billing issue. Please check your Google Cloud account.';
            }

            // Check for model availability
            if (str_contains(strtolower($message), 'not found') ||
                str_contains(strtolower($message), 'unavailable')) {
                return 'Veo model is not available in your region or requires paid preview access.';
            }

            return $message;
        }

        if (isset($errorData['message'])) {
            return $errorData['message'];
        }

        return 'Unknown error occurred';
    }

    /**
     * Get estimated generation time
     */
    private function getEstimatedTime(int $duration, bool $fast = false): int
    {
        $baseTime = $fast ? 60 : 120; // Fast model is quicker
        return $baseTime + ($duration * 15);
    }
}
