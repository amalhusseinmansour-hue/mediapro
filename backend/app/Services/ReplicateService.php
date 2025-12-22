<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class ReplicateService
{
    protected $apiToken;
    protected $baseUrl = 'https://api.replicate.com/v1';

    // Popular models
    const MODEL_FLUX_SCHNELL = 'black-forest-labs/flux-schnell';
    const MODEL_FLUX_DEV = 'black-forest-labs/flux-dev';
    const MODEL_STABLE_VIDEO = 'stability-ai/stable-video-diffusion';
    const MODEL_SDXL = 'stability-ai/sdxl';

    public function __construct()
    {
        $this->apiToken = env('REPLICATE_API_TOKEN');
    }

    /**
     * Generate image using FLUX Schnell (fast)
     */
    public function generateImage(string $prompt, array $options = []): array
    {
        try {
            $model = $options['model'] ?? self::MODEL_FLUX_SCHNELL;

            $input = [
                'prompt' => $prompt,
                'num_outputs' => $options['num_outputs'] ?? 1,
                'aspect_ratio' => $options['aspect_ratio'] ?? '1:1',
                'output_format' => $options['output_format'] ?? 'webp',
                'output_quality' => $options['output_quality'] ?? 80,
            ];

            if (isset($options['seed'])) {
                $input['seed'] = $options['seed'];
            }

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiToken,
                'Content-Type' => 'application/json',
            ])->post("{$this->baseUrl}/models/{$model}/predictions", [
                'input' => $input,
            ]);

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'success' => true,
                    'prediction_id' => $data['id'] ?? null,
                    'status' => $data['status'] ?? 'starting',
                    'output' => $data['output'] ?? null,
                    'data' => $data,
                ];
            }

            Log::error('Replicate Image Generation Error', [
                'status' => $response->status(),
                'response' => $response->json(),
            ]);

            return [
                'success' => false,
                'error' => $response->json()['detail'] ?? 'فشل في إنشاء الصورة',
            ];

        } catch (\Exception $e) {
            Log::error('Replicate Image Exception', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Generate video from image using Stable Video Diffusion
     */
    public function generateVideo(string $imageUrl, array $options = []): array
    {
        try {
            $input = [
                'input_image' => $imageUrl,
                'video_length' => $options['video_length'] ?? '14_frames_with_svd',
                'sizing_strategy' => $options['sizing_strategy'] ?? 'maintain_aspect_ratio',
                'frames_per_second' => $options['fps'] ?? 6,
                'motion_bucket_id' => $options['motion_bucket_id'] ?? 127,
                'cond_aug' => $options['cond_aug'] ?? 0.02,
                'decoding_t' => $options['decoding_t'] ?? 7,
            ];

            if (isset($options['seed'])) {
                $input['seed'] = $options['seed'];
            }

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiToken,
                'Content-Type' => 'application/json',
            ])->post("{$this->baseUrl}/models/" . self::MODEL_STABLE_VIDEO . "/predictions", [
                'input' => $input,
            ]);

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'success' => true,
                    'prediction_id' => $data['id'] ?? null,
                    'status' => $data['status'] ?? 'starting',
                    'data' => $data,
                ];
            }

            Log::error('Replicate Video Generation Error', [
                'status' => $response->status(),
                'response' => $response->json(),
            ]);

            return [
                'success' => false,
                'error' => $response->json()['detail'] ?? 'فشل في إنشاء الفيديو',
            ];

        } catch (\Exception $e) {
            Log::error('Replicate Video Exception', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Run any Replicate model
     */
    public function runModel(string $modelVersion, array $input): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiToken,
                'Content-Type' => 'application/json',
            ])->post("{$this->baseUrl}/predictions", [
                'version' => $modelVersion,
                'input' => $input,
            ]);

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'success' => true,
                    'prediction_id' => $data['id'] ?? null,
                    'status' => $data['status'] ?? 'starting',
                    'data' => $data,
                ];
            }

            return [
                'success' => false,
                'error' => $response->json()['detail'] ?? 'فشل في تشغيل النموذج',
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Check prediction status
     */
    public function checkStatus(string $predictionId): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiToken,
            ])->get("{$this->baseUrl}/predictions/{$predictionId}");

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'success' => true,
                    'prediction_id' => $predictionId,
                    'status' => $data['status'] ?? 'unknown',
                    'output' => $data['output'] ?? null,
                    'error' => $data['error'] ?? null,
                    'metrics' => $data['metrics'] ?? null,
                    'data' => $data,
                ];
            }

            return [
                'success' => false,
                'error' => 'فشل في جلب حالة التوقع',
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Cancel a prediction
     */
    public function cancelPrediction(string $predictionId): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiToken,
            ])->post("{$this->baseUrl}/predictions/{$predictionId}/cancel");

            return [
                'success' => $response->successful(),
                'message' => $response->successful() ? 'تم إلغاء التوقع' : 'فشل في الإلغاء',
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Get available models
     */
    public function getModels(): array
    {
        return [
            'flux-schnell' => [
                'id' => self::MODEL_FLUX_SCHNELL,
                'name' => 'FLUX Schnell',
                'type' => 'image',
                'description' => 'Fast image generation',
            ],
            'flux-dev' => [
                'id' => self::MODEL_FLUX_DEV,
                'name' => 'FLUX Dev',
                'type' => 'image',
                'description' => 'High quality image generation',
            ],
            'stable-video' => [
                'id' => self::MODEL_STABLE_VIDEO,
                'name' => 'Stable Video Diffusion',
                'type' => 'video',
                'description' => 'Generate video from image',
            ],
            'sdxl' => [
                'id' => self::MODEL_SDXL,
                'name' => 'SDXL',
                'type' => 'image',
                'description' => 'Stable Diffusion XL',
            ],
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
