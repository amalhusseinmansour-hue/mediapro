<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;

class PostizService
{
    private $apiKey;
    private $baseUrl;

    public function __construct()
    {
        $this->apiKey = config('services.postiz.api_key');
        $this->baseUrl = config('services.postiz.base_url', 'https://api.postiz.com/public/v1');
    }

    /**
     * Generate AI Video from content
     */
    public function generateVideo(string $content, string $platform = 'tiktok')
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => $this->apiKey,
                'Content-Type' => 'application/json'
            ])->post("{$this->baseUrl}/generate-video", [
                'content' => $content,
                'platform' => $platform
            ]);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json()
                ];
            }

            return [
                'success' => false,
                'error' => $response->json()['message'] ?? 'Failed to generate video'
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Upload media from URL
     */
    public function uploadFromUrl(string $url)
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => $this->apiKey,
                'Content-Type' => 'application/json'
            ])->post("{$this->baseUrl}/upload-from-url", [
                'url' => $url
            ]);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json()
                ];
            }

            return [
                'success' => false,
                'error' => $response->json()['message'] ?? 'Failed to upload media'
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Upload media file
     */
    public function uploadMedia($file)
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => $this->apiKey
            ])->attach('file', file_get_contents($file), $file->getClientOriginalName())
                ->post("{$this->baseUrl}/upload");

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json()
                ];
            }

            return [
                'success' => false,
                'error' => $response->json()['message'] ?? 'Failed to upload file'
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Get analytics (if user has integrations in Postiz)
     * Note: This requires integrations to be connected in Postiz dashboard
     */
    public function getAnalytics(string $startDate, string $endDate)
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => $this->apiKey
            ])->get("{$this->baseUrl}/posts", [
                'startDate' => $startDate,
                'endDate' => $endDate
            ]);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json()
                ];
            }

            return [
                'success' => false,
                'error' => $response->json()['message'] ?? 'Failed to get analytics'
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Find best time slot for posting
     * Note: Requires integration_id from Postiz
     */
    public function findBestSlot(string $integrationId)
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => $this->apiKey
            ])->get("{$this->baseUrl}/find-slot/{$integrationId}");

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json()
                ];
            }

            return [
                'success' => false,
                'error' => $response->json()['message'] ?? 'Failed to find slot'
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }
}
