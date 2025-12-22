<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;

/**
 * Kie AI Video Generation Service
 * Integrates with Kie AI API similar to the n8n workflow
 */
class KieAIVideoService
{
    protected string $apiKey;
    protected string $baseUrl = 'https://api.kie.ai/api/v1/veo';

    public function __construct()
    {
        $this->apiKey = config('services.kie_ai.api_key', env('KIE_AI_API_KEY'));
    }

    /**
     * Generate video from text prompt
     */
    public function generateVideoFromText(string $prompt, array $options = []): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/json',
            ])->post($this->baseUrl . '/generate', [
                'prompt' => $prompt,
                'model' => $options['model'] ?? 'veo3_fast',
                'aspectRatio' => $options['aspectRatio'] ?? '9:16',
                'duration' => $options['duration'] ?? null,
                'style' => $options['style'] ?? null,
            ]);

            if ($response->successful()) {
                $data = $response->json();
                
                Log::info('Kie AI Video generation started', [
                    'task_id' => $data['data']['taskId'],
                    'prompt' => $prompt
                ]);

                return [
                    'success' => true,
                    'task_id' => $data['data']['taskId'],
                    'status' => 'processing',
                    'estimated_time' => 180, // 3 minutes similar to n8n workflow
                    'message' => 'Video generation started successfully'
                ];
            }

            return [
                'success' => false,
                'error' => $response->json()['error'] ?? 'Unknown error occurred',
            ];

        } catch (\Exception $e) {
            Log::error('Kie AI Video generation failed', [
                'error' => $e->getMessage(),
                'prompt' => $prompt
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Generate video from image (Image to Video)
     */
    public function generateVideoFromImage(string $imageUrl, string $videoPrompt, array $options = []): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/json',
            ])->post($this->baseUrl . '/generate', [
                'prompt' => $videoPrompt,
                'imageUrls' => [$imageUrl],
                'model' => $options['model'] ?? 'veo3_fast',
                'aspectRatio' => $options['aspectRatio'] ?? '9:16',
                'duration' => $options['duration'] ?? null,
            ]);

            if ($response->successful()) {
                $data = $response->json();
                
                Log::info('Kie AI Image-to-Video generation started', [
                    'task_id' => $data['data']['taskId'],
                    'image_url' => $imageUrl,
                    'prompt' => $videoPrompt
                ]);

                return [
                    'success' => true,
                    'task_id' => $data['data']['taskId'],
                    'status' => 'processing',
                    'estimated_time' => 180,
                    'message' => 'Image-to-video generation started successfully'
                ];
            }

            return [
                'success' => false,
                'error' => $response->json()['error'] ?? 'Unknown error occurred',
            ];

        } catch (\Exception $e) {
            Log::error('Kie AI Image-to-Video generation failed', [
                'error' => $e->getMessage(),
                'image_url' => $imageUrl,
                'prompt' => $videoPrompt
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Check video generation status
     */
    public function checkStatus(string $taskId): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->get('https://api.kie.ai/api/v1/veo/record-info', [
                'taskId' => $taskId
            ]);

            if ($response->successful()) {
                $data = $response->json();
                
                // Check if video is ready
                if (isset($data['data']['resultJson']) && !empty($data['data']['resultJson'])) {
                    $resultData = json_decode($data['data']['resultJson'], true);
                    
                    if (isset($resultData['resultUrls']) && !empty($resultData['resultUrls'])) {
                        return [
                            'success' => true,
                            'status' => 'completed',
                            'video_url' => $resultData['resultUrls'][0],
                            'download_url' => $resultData['resultUrls'][0],
                            'result_data' => $resultData,
                        ];
                    }
                }

                return [
                    'success' => true,
                    'status' => 'processing',
                    'message' => 'Video is still being generated'
                ];
            }

            return [
                'success' => false,
                'error' => 'Failed to check video status',
            ];

        } catch (\Exception $e) {
            Log::error('Kie AI status check failed', [
                'task_id' => $taskId,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Download and save video to local storage
     */
    public function downloadVideo(string $videoUrl, string $fileName = null): array
    {
        try {
            if (!$fileName) {
                $fileName = 'generated_video_' . time() . '.mp4';
            }

            $response = Http::get($videoUrl);

            if ($response->successful()) {
                $videoContent = $response->body();
                $path = 'videos/generated/' . $fileName;
                
                Storage::disk('public')->put($path, $videoContent);
                
                return [
                    'success' => true,
                    'file_path' => $path,
                    'public_url' => Storage::disk('public')->url($path),
                    'file_name' => $fileName,
                ];
            }

            return [
                'success' => false,
                'error' => 'Failed to download video',
            ];

        } catch (\Exception $e) {
            Log::error('Video download failed', [
                'video_url' => $videoUrl,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Get generation capabilities and models
     */
    public function getCapabilities(): array
    {
        return [
            'models' => [
                'veo3_fast' => [
                    'name' => 'Veo 3 Fast',
                    'description' => 'Fast video generation with good quality',
                    'max_duration' => 10,
                    'supported_ratios' => ['16:9', '9:16', '1:1'],
                    'features' => ['text-to-video', 'image-to-video']
                ],
                'veo3_standard' => [
                    'name' => 'Veo 3 Standard',
                    'description' => 'Standard video generation with high quality',
                    'max_duration' => 10,
                    'supported_ratios' => ['16:9', '9:16', '1:1'],
                    'features' => ['text-to-video', 'image-to-video']
                ]
            ],
            'aspect_ratios' => [
                '16:9' => 'Landscape (YouTube, horizontal)',
                '9:16' => 'Portrait (TikTok, Instagram Stories)',
                '1:1' => 'Square (Instagram, Facebook)'
            ],
            'supported_formats' => ['mp4'],
            'max_duration' => 10, // seconds
            'estimated_processing_time' => 180, // seconds (3 minutes)
        ];
    }

    /**
     * Validate generation parameters
     */
    public function validateParameters(array $params): array
    {
        $errors = [];

        // Check prompt
        if (empty($params['prompt'])) {
            $errors[] = 'Prompt is required';
        } elseif (strlen($params['prompt']) > 500) {
            $errors[] = 'Prompt must be less than 500 characters';
        }

        // Check aspect ratio
        if (isset($params['aspectRatio'])) {
            $validRatios = ['16:9', '9:16', '1:1'];
            if (!in_array($params['aspectRatio'], $validRatios)) {
                $errors[] = 'Invalid aspect ratio. Supported: ' . implode(', ', $validRatios);
            }
        }

        // Check duration
        if (isset($params['duration']) && $params['duration'] > 10) {
            $errors[] = 'Duration cannot exceed 10 seconds';
        }

        // Check model
        if (isset($params['model'])) {
            $validModels = ['veo3_fast', 'veo3_standard'];
            if (!in_array($params['model'], $validModels)) {
                $errors[] = 'Invalid model. Supported: ' . implode(', ', $validModels);
            }
        }

        return [
            'valid' => empty($errors),
            'errors' => $errors
        ];
    }

    /**
     * Generate video with automatic retry logic
     */
    public function generateWithRetry(array $params, int $maxRetries = 3): array
    {
        $validation = $this->validateParameters($params);
        if (!$validation['valid']) {
            return [
                'success' => false,
                'error' => 'Validation failed: ' . implode(', ', $validation['errors'])
            ];
        }

        $attempt = 1;
        while ($attempt <= $maxRetries) {
            if (isset($params['image_url'])) {
                $result = $this->generateVideoFromImage(
                    $params['image_url'],
                    $params['prompt'],
                    $params
                );
            } else {
                $result = $this->generateVideoFromText(
                    $params['prompt'],
                    $params
                );
            }

            if ($result['success']) {
                return $result;
            }

            Log::warning("Kie AI generation attempt {$attempt} failed", [
                'attempt' => $attempt,
                'error' => $result['error']
            ]);

            $attempt++;
            if ($attempt <= $maxRetries) {
                sleep(2); // Wait 2 seconds before retry
            }
        }

        return [
            'success' => false,
            'error' => 'Failed after ' . $maxRetries . ' attempts'
        ];
    }
}