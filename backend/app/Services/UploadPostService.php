<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Http\UploadedFile;

class UploadPostService
{
    protected $apiKey;
    protected $baseUrl = 'https://api.upload-post.com/api';

    public function __construct()
    {
        $this->apiKey = config('services.upload_post.api_key');
    }

    /**
     * Check if Upload-Post is configured
     *
     * @return bool
     */
    public function isConfigured(): bool
    {
        return !empty($this->apiKey);
    }

    /**
     * Upload photo to multiple platforms
     *
     * @param UploadedFile $image
     * @param string $caption
     * @param array $platforms
     * @param string|null $scheduleTime
     * @return array
     */
    public function uploadPhoto(UploadedFile $image, string $caption, array $platforms, ?string $scheduleTime = null): array
    {
        if (!$this->isConfigured()) {
            return [
                'success' => false,
                'error' => 'Upload-Post API not configured',
            ];
        }

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Apikey ' . $this->apiKey,
            ])->attach(
                'image',
                file_get_contents($image->getRealPath()),
                $image->getClientOriginalName()
            )->post($this->baseUrl . '/upload_photos', [
                'caption' => $caption,
                'platforms' => $this->normalizePlatforms($platforms),
                'schedule_time' => $scheduleTime,
            ]);

            if ($response->successful()) {
                Log::info('✅ Photo uploaded via Upload-Post', [
                    'platforms' => $platforms,
                ]);

                return [
                    'success' => true,
                    'data' => $response->json(),
                ];
            } else {
                Log::error('❌ Upload-Post API error', [
                    'status' => $response->status(),
                    'error' => $response->json(),
                ]);

                return [
                    'success' => false,
                    'error' => $response->json('message') ?? 'Upload failed',
                    'status_code' => $response->status(),
                ];
            }
        } catch (\Exception $e) {
            Log::error('❌ Error uploading photo', [
                'error' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Upload video to multiple platforms
     *
     * @param UploadedFile $video
     * @param string $caption
     * @param array $platforms
     * @param string|null $title
     * @param string|null $scheduleTime
     * @return array
     */
    public function uploadVideo(UploadedFile $video, string $caption, array $platforms, ?string $title = null, ?string $scheduleTime = null): array
    {
        if (!$this->isConfigured()) {
            return [
                'success' => false,
                'error' => 'Upload-Post API not configured',
            ];
        }

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Apikey ' . $this->apiKey,
            ])->attach(
                'video',
                file_get_contents($video->getRealPath()),
                $video->getClientOriginalName()
            )->post($this->baseUrl . '/upload_videos', [
                'caption' => $caption,
                'title' => $title,
                'platforms' => $this->normalizePlatforms($platforms),
                'schedule_time' => $scheduleTime,
                'async_upload' => 'true',
            ]);

            if ($response->successful()) {
                Log::info('✅ Video uploaded via Upload-Post', [
                    'platforms' => $platforms,
                ]);

                return [
                    'success' => true,
                    'data' => $response->json(),
                ];
            } else {
                Log::error('❌ Upload-Post API error', [
                    'status' => $response->status(),
                    'error' => $response->json(),
                ]);

                return [
                    'success' => false,
                    'error' => $response->json('message') ?? 'Upload failed',
                    'status_code' => $response->status(),
                ];
            }
        } catch (\Exception $e) {
            Log::error('❌ Error uploading video', [
                'error' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Upload text post to multiple platforms
     *
     * @param string $text
     * @param array $platforms
     * @param string|null $scheduleTime
     * @return array
     */
    public function uploadText(string $text, array $platforms, ?string $scheduleTime = null): array
    {
        if (!$this->isConfigured()) {
            return [
                'success' => false,
                'error' => 'Upload-Post API not configured',
            ];
        }

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Apikey ' . $this->apiKey,
                'Content-Type' => 'application/json',
            ])->post($this->baseUrl . '/upload_text', [
                'text' => $text,
                'platforms' => $this->normalizePlatforms($platforms),
                'schedule_time' => $scheduleTime,
            ]);

            if ($response->successful()) {
                Log::info('✅ Text uploaded via Upload-Post', [
                    'platforms' => $platforms,
                ]);

                return [
                    'success' => true,
                    'data' => $response->json(),
                ];
            } else {
                Log::error('❌ Upload-Post API error', [
                    'status' => $response->status(),
                    'error' => $response->json(),
                ]);

                return [
                    'success' => false,
                    'error' => $response->json('message') ?? 'Upload failed',
                    'status_code' => $response->status(),
                ];
            }
        } catch (\Exception $e) {
            Log::error('❌ Error uploading text', [
                'error' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Normalize platform names to Upload-Post format
     *
     * @param array $platforms
     * @return array
     */
    protected function normalizePlatforms(array $platforms): array
    {
        $map = [
            'twitter' => 'x',
            'x (twitter)' => 'x',
            'tiktok' => 'tiktok',
            'instagram' => 'instagram',
            'facebook' => 'facebook',
            'linkedin' => 'linkedin',
            'youtube' => 'youtube',
            'threads' => 'threads',
            'pinterest' => 'pinterest',
            'reddit' => 'reddit',
        ];

        return array_map(function ($platform) use ($map) {
            $normalized = strtolower(trim($platform));
            return $map[$normalized] ?? $normalized;
        }, $platforms);
    }

    /**
     * Get supported platforms
     *
     * @return array
     */
    public function getSupportedPlatforms(): array
    {
        return [
            'photo' => ['LinkedIn', 'Facebook', 'X (Twitter)', 'Instagram', 'TikTok', 'Threads', 'Pinterest'],
            'video' => ['TikTok', 'Instagram', 'LinkedIn', 'YouTube', 'Facebook', 'X (Twitter)', 'Threads', 'Pinterest'],
            'text' => ['X (Twitter)', 'LinkedIn', 'Facebook', 'Threads', 'Reddit'],
        ];
    }

    /**
     * Get connected accounts
     *
     * @return array
     */
    public function getConnectedAccounts(): array
    {
        if (!$this->isConfigured()) {
            return [];
        }

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Apikey ' . $this->apiKey,
            ])->get($this->baseUrl . '/accounts');

            if ($response->successful()) {
                return $response->json('data', []);
            }

            return [];
        } catch (\Exception $e) {
            Log::error('Error fetching connected accounts', [
                'error' => $e->getMessage(),
            ]);
            return [];
        }
    }

    /**
     * Get post status by ID
     *
     * @param string $postId
     * @return array|null
     */
    public function getPostStatus(string $postId): ?array
    {
        if (!$this->isConfigured()) {
            return null;
        }

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Apikey ' . $this->apiKey,
            ])->get($this->baseUrl . '/posts/' . $postId);

            if ($response->successful()) {
                return $response->json('data');
            }

            return null;
        } catch (\Exception $e) {
            Log::error('Error fetching post status', [
                'post_id' => $postId,
                'error' => $e->getMessage(),
            ]);
            return null;
        }
    }

    /**
     * Delete scheduled post
     *
     * @param string $postId
     * @return bool
     */
    public function deletePost(string $postId): bool
    {
        if (!$this->isConfigured()) {
            return false;
        }

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Apikey ' . $this->apiKey,
            ])->delete($this->baseUrl . '/posts/' . $postId);

            return $response->successful();
        } catch (\Exception $e) {
            Log::error('Error deleting post', [
                'post_id' => $postId,
                'error' => $e->getMessage(),
            ]);
            return false;
        }
    }

    /**
     * Get analytics for a post
     *
     * @param string $postId
     * @return array|null
     */
    public function getPostAnalytics(string $postId): ?array
    {
        if (!$this->isConfigured()) {
            return null;
        }

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Apikey ' . $this->apiKey,
            ])->get($this->baseUrl . '/posts/' . $postId . '/analytics');

            if ($response->successful()) {
                return $response->json('data');
            }

            return null;
        } catch (\Exception $e) {
            Log::error('Error fetching post analytics', [
                'post_id' => $postId,
                'error' => $e->getMessage(),
            ]);
            return null;
        }
    }
}
