<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class RunwayMLService
{
    protected $apiKey;
    protected $baseUrl = 'https://api.dev.runwayml.com/v1';
    protected $apiVersion = '2024-11-06';

    public function __construct()
    {
        $this->apiKey = env('RUNWAY_API_KEY');
    }

    /**
     * Generate video from text prompt
     */
    public function generateFromText(string $prompt, array $options = []): array
    {
        try {
            $payload = [
                'promptText' => $prompt,
                'model' => $options['model'] ?? 'gen3a_turbo',
                'duration' => $options['duration'] ?? 5,
                'ratio' => $options['ratio'] ?? '16:9',
            ];

            if (isset($options['seed'])) {
                $payload['seed'] = $options['seed'];
            }

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'X-Runway-Version' => $this->apiVersion,
                'Content-Type' => 'application/json',
            ])->post("{$this->baseUrl}/text_to_video", $payload);

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'success' => true,
                    'task_id' => $data['id'] ?? null,
                    'status' => $data['status'] ?? 'PENDING',
                    'data' => $data,
                ];
            }

            Log::error('RunwayML Text-to-Video Error', [
                'status' => $response->status(),
                'response' => $response->json(),
            ]);

            return [
                'success' => false,
                'error' => $response->json()['error'] ?? 'فشل في إنشاء الفيديو',
            ];

        } catch (\Exception $e) {
            Log::error('RunwayML Exception', ['error' => $e->getMessage()]);
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
                'promptImage' => $imageUrl,
                'model' => $options['model'] ?? 'gen3a_turbo',
                'duration' => $options['duration'] ?? 5,
                'ratio' => $options['ratio'] ?? '16:9',
            ];

            if (!empty($prompt)) {
                $payload['promptText'] = $prompt;
            }

            if (isset($options['seed'])) {
                $payload['seed'] = $options['seed'];
            }

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'X-Runway-Version' => $this->apiVersion,
                'Content-Type' => 'application/json',
            ])->post("{$this->baseUrl}/image_to_video", $payload);

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'success' => true,
                    'task_id' => $data['id'] ?? null,
                    'status' => $data['status'] ?? 'PENDING',
                    'data' => $data,
                ];
            }

            Log::error('RunwayML Image-to-Video Error', [
                'status' => $response->status(),
                'response' => $response->json(),
            ]);

            return [
                'success' => false,
                'error' => $response->json()['error'] ?? 'فشل في إنشاء الفيديو من الصورة',
            ];

        } catch (\Exception $e) {
            Log::error('RunwayML Image-to-Video Exception', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Check task status
     */
    public function checkStatus(string $taskId): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'X-Runway-Version' => $this->apiVersion,
            ])->get("{$this->baseUrl}/tasks/{$taskId}");

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'success' => true,
                    'task_id' => $taskId,
                    'status' => $data['status'] ?? 'UNKNOWN',
                    'progress' => $data['progress'] ?? 0,
                    'output_url' => $data['output'][0] ?? null,
                    'data' => $data,
                ];
            }

            return [
                'success' => false,
                'error' => 'فشل في جلب حالة المهمة',
            ];

        } catch (\Exception $e) {
            Log::error('RunwayML Check Status Exception', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Cancel a running task
     */
    public function cancelTask(string $taskId): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'X-Runway-Version' => $this->apiVersion,
            ])->delete("{$this->baseUrl}/tasks/{$taskId}");

            return [
                'success' => $response->successful(),
                'message' => $response->successful() ? 'تم إلغاء المهمة' : 'فشل في إلغاء المهمة',
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
            'gen3a_turbo' => [
                'name' => 'Gen-3 Alpha Turbo',
                'description' => 'Fast video generation',
                'max_duration' => 10,
            ],
            'gen3a' => [
                'name' => 'Gen-3 Alpha',
                'description' => 'High quality video generation',
                'max_duration' => 10,
            ],
        ];
    }
}
