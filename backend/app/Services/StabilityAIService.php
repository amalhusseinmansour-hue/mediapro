<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;

class StabilityAIService
{
    protected $apiKey;
    protected $baseUrl = 'https://api.stability.ai';

    public function __construct()
    {
        $this->apiKey = env('STABILITY_AI_API_KEY');
    }

    /**
     * Generate image using Stable Diffusion 3
     */
    public function generateImage(string $prompt, array $options = []): array
    {
        try {
            $model = $options['model'] ?? 'sd3-large';

            $payload = [
                'prompt' => $prompt,
                'output_format' => $options['output_format'] ?? 'png',
                'aspect_ratio' => $options['aspect_ratio'] ?? '1:1',
            ];

            if (isset($options['negative_prompt'])) {
                $payload['negative_prompt'] = $options['negative_prompt'];
            }

            if (isset($options['seed'])) {
                $payload['seed'] = $options['seed'];
            }

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Accept' => 'image/*',
            ])->asMultipart()->post("{$this->baseUrl}/v2beta/stable-image/generate/{$model}", $payload);

            if ($response->successful()) {
                // Save image to storage
                $filename = 'stability_' . time() . '_' . uniqid() . '.' . ($options['output_format'] ?? 'png');
                $path = "ai_images/{$filename}";
                Storage::disk('public')->put($path, $response->body());

                return [
                    'success' => true,
                    'image_url' => Storage::disk('public')->url($path),
                    'path' => $path,
                    'seed' => $response->header('seed'),
                    'finish_reason' => $response->header('finish-reason'),
                ];
            }

            Log::error('Stability AI Image Generation Error', [
                'status' => $response->status(),
                'response' => $response->body(),
            ]);

            return [
                'success' => false,
                'error' => 'فشل في إنشاء الصورة: ' . $response->status(),
            ];

        } catch (\Exception $e) {
            Log::error('Stability AI Exception', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Generate image using Ultra model (highest quality)
     */
    public function generateUltra(string $prompt, array $options = []): array
    {
        try {
            $payload = [
                'prompt' => $prompt,
                'output_format' => $options['output_format'] ?? 'png',
                'aspect_ratio' => $options['aspect_ratio'] ?? '1:1',
            ];

            if (isset($options['negative_prompt'])) {
                $payload['negative_prompt'] = $options['negative_prompt'];
            }

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Accept' => 'image/*',
            ])->asMultipart()->post("{$this->baseUrl}/v2beta/stable-image/generate/ultra", $payload);

            if ($response->successful()) {
                $filename = 'stability_ultra_' . time() . '_' . uniqid() . '.' . ($options['output_format'] ?? 'png');
                $path = "ai_images/{$filename}";
                Storage::disk('public')->put($path, $response->body());

                return [
                    'success' => true,
                    'image_url' => Storage::disk('public')->url($path),
                    'path' => $path,
                ];
            }

            return [
                'success' => false,
                'error' => 'فشل في إنشاء الصورة',
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Upscale image
     */
    public function upscaleImage(string $imagePath, array $options = []): array
    {
        try {
            $imageContent = Storage::disk('public')->get($imagePath);

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Accept' => 'image/*',
            ])->attach('image', $imageContent, 'image.png')
              ->post("{$this->baseUrl}/v2beta/stable-image/upscale/conservative", [
                  'output_format' => $options['output_format'] ?? 'png',
              ]);

            if ($response->successful()) {
                $filename = 'upscaled_' . time() . '_' . uniqid() . '.png';
                $path = "ai_images/{$filename}";
                Storage::disk('public')->put($path, $response->body());

                return [
                    'success' => true,
                    'image_url' => Storage::disk('public')->url($path),
                    'path' => $path,
                ];
            }

            return [
                'success' => false,
                'error' => 'فشل في تكبير الصورة',
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Remove background from image
     */
    public function removeBackground(string $imagePath): array
    {
        try {
            $imageContent = Storage::disk('public')->get($imagePath);

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Accept' => 'image/*',
            ])->attach('image', $imageContent, 'image.png')
              ->post("{$this->baseUrl}/v2beta/stable-image/edit/remove-background", [
                  'output_format' => 'png',
              ]);

            if ($response->successful()) {
                $filename = 'nobg_' . time() . '_' . uniqid() . '.png';
                $path = "ai_images/{$filename}";
                Storage::disk('public')->put($path, $response->body());

                return [
                    'success' => true,
                    'image_url' => Storage::disk('public')->url($path),
                    'path' => $path,
                ];
            }

            return [
                'success' => false,
                'error' => 'فشل في إزالة الخلفية',
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Image to video generation
     */
    public function imageToVideo(string $imageUrl, array $options = []): array
    {
        try {
            $payload = [
                'image' => $imageUrl,
                'cfg_scale' => $options['cfg_scale'] ?? 1.8,
                'motion_bucket_id' => $options['motion_bucket_id'] ?? 127,
            ];

            if (isset($options['seed'])) {
                $payload['seed'] = $options['seed'];
            }

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/json',
            ])->post("{$this->baseUrl}/v2beta/image-to-video", $payload);

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'success' => true,
                    'generation_id' => $data['id'] ?? null,
                    'data' => $data,
                ];
            }

            return [
                'success' => false,
                'error' => 'فشل في بدء إنشاء الفيديو',
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Check video generation status
     */
    public function checkVideoStatus(string $generationId): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Accept' => 'video/*',
            ])->get("{$this->baseUrl}/v2beta/image-to-video/result/{$generationId}");

            if ($response->status() === 202) {
                return [
                    'success' => true,
                    'status' => 'processing',
                    'message' => 'الفيديو قيد المعالجة',
                ];
            }

            if ($response->successful()) {
                $filename = 'video_' . time() . '_' . uniqid() . '.mp4';
                $path = "ai_videos/{$filename}";
                Storage::disk('public')->put($path, $response->body());

                return [
                    'success' => true,
                    'status' => 'completed',
                    'video_url' => Storage::disk('public')->url($path),
                    'path' => $path,
                ];
            }

            return [
                'success' => false,
                'status' => 'failed',
                'error' => 'فشل في جلب الفيديو',
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Get account balance
     */
    public function getBalance(): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->get("{$this->baseUrl}/v1/user/balance");

            if ($response->successful()) {
                return [
                    'success' => true,
                    'credits' => $response->json()['credits'] ?? 0,
                ];
            }

            return [
                'success' => false,
                'error' => 'فشل في جلب الرصيد',
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Check if service is configured
     */
    public function isConfigured(): bool
    {
        return !empty($this->apiKey) && !str_contains($this->apiKey, 'your_');
    }

    /**
     * Get available models
     */
    public function getModels(): array
    {
        return [
            'sd3-large' => [
                'name' => 'Stable Diffusion 3 Large',
                'description' => 'High quality image generation',
                'credits_per_image' => 6.5,
            ],
            'sd3-large-turbo' => [
                'name' => 'SD3 Large Turbo',
                'description' => 'Fast image generation',
                'credits_per_image' => 4,
            ],
            'sd3-medium' => [
                'name' => 'Stable Diffusion 3 Medium',
                'description' => 'Balanced quality and speed',
                'credits_per_image' => 3.5,
            ],
            'ultra' => [
                'name' => 'Stable Image Ultra',
                'description' => 'Highest quality',
                'credits_per_image' => 8,
            ],
        ];
    }
}
