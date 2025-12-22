<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class PikaLabsService
{
    protected $apiKey;
    protected $baseUrl;

    public function __construct()
    {
        $this->apiKey = env('PIKA_API_KEY');
        $this->baseUrl = env('PIKA_API_URL', 'https://api.pika.art/v1');
    }

    /**
     * Generate video from text prompt
     */
    public function generateFromText(string $prompt, array $options = []): array
    {
        try {
            $payload = [
                'prompt' => $prompt,
                'style' => $options['style'] ?? 'realistic',
                'aspect_ratio' => $options['aspect_ratio'] ?? '16:9',
                'duration' => $options['duration'] ?? 3,
                'fps' => $options['fps'] ?? 24,
            ];

            if (isset($options['negative_prompt'])) {
                $payload['negative_prompt'] = $options['negative_prompt'];
            }

            if (isset($options['seed'])) {
                $payload['seed'] = $options['seed'];
            }

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/json',
            ])->post("{$this->baseUrl}/generate", $payload);

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'success' => true,
                    'generation_id' => $data['id'] ?? null,
                    'status' => $data['status'] ?? 'processing',
                    'data' => $data,
                ];
            }

            Log::error('Pika Labs Generation Error', [
                'status' => $response->status(),
                'response' => $response->json(),
            ]);

            return [
                'success' => false,
                'error' => $response->json()['message'] ?? 'فشل في إنشاء الفيديو',
            ];

        } catch (\Exception $e) {
            Log::error('Pika Labs Exception', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Generate video from image
     */
    public function generateFromImage(string $imageUrl, string $prompt = '', array $options = []): array
    {
        try {
            $payload = [
                'image_url' => $imageUrl,
                'prompt' => $prompt,
                'motion_strength' => $options['motion_strength'] ?? 1.0,
                'duration' => $options['duration'] ?? 3,
            ];

            if (isset($options['negative_prompt'])) {
                $payload['negative_prompt'] = $options['negative_prompt'];
            }

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/json',
            ])->post("{$this->baseUrl}/image-to-video", $payload);

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'success' => true,
                    'generation_id' => $data['id'] ?? null,
                    'status' => $data['status'] ?? 'processing',
                    'data' => $data,
                ];
            }

            return [
                'success' => false,
                'error' => $response->json()['message'] ?? 'فشل في إنشاء الفيديو من الصورة',
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Check generation status
     */
    public function checkStatus(string $generationId): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->get("{$this->baseUrl}/generations/{$generationId}");

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'success' => true,
                    'generation_id' => $generationId,
                    'status' => $data['status'] ?? 'unknown',
                    'progress' => $data['progress'] ?? 0,
                    'video_url' => $data['video_url'] ?? null,
                    'thumbnail_url' => $data['thumbnail_url'] ?? null,
                    'data' => $data,
                ];
            }

            return [
                'success' => false,
                'error' => 'فشل في جلب حالة الفيديو',
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Get user generations history
     */
    public function getGenerations(int $limit = 20, int $offset = 0): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->get("{$this->baseUrl}/generations", [
                'limit' => $limit,
                'offset' => $offset,
            ]);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'generations' => $response->json()['generations'] ?? [],
                    'total' => $response->json()['total'] ?? 0,
                ];
            }

            return [
                'success' => false,
                'error' => 'فشل في جلب السجل',
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Delete a generation
     */
    public function deleteGeneration(string $generationId): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->delete("{$this->baseUrl}/generations/{$generationId}");

            return [
                'success' => $response->successful(),
                'message' => $response->successful() ? 'تم الحذف بنجاح' : 'فشل في الحذف',
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Get available styles
     */
    public function getStyles(): array
    {
        return [
            'realistic' => 'واقعي',
            'anime' => 'أنمي',
            '3d' => 'ثلاثي الأبعاد',
            'cinematic' => 'سينمائي',
            'watercolor' => 'ألوان مائية',
            'oil_painting' => 'لوحة زيتية',
        ];
    }

    /**
     * Check if service is configured
     */
    public function isConfigured(): bool
    {
        return !empty($this->apiKey) && !str_contains($this->apiKey, 'your_');
    }
}
