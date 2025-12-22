<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Exception;

class KieAiService
{
    protected string $apiKey;
    protected string $secretKey;
    protected string $baseUrl = 'https://api.kie.ai/v1';
    protected int $timeout = 120; // AI generation can take time

    public function __construct()
    {
        $this->apiKey = config('services.kie_ai.api_key');
        $this->secretKey = config('services.kie_ai.secret_key');
    }

    /**
     * Check if Kie.ai is configured
     *
     * @return bool
     */
    public function isConfigured(): bool
    {
        return !empty($this->apiKey) && !empty($this->secretKey);
    }

    /**
     * Get authenticated HTTP client
     */
    protected function client()
    {
        return Http::withHeaders([
            'Authorization' => 'Bearer ' . $this->apiKey,
            'X-Secret-Key' => $this->secretKey,
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
        ])->timeout($this->timeout);
    }

    /**
     * Generate an image from text prompt
     *
     * @param string $prompt
     * @param array $options
     * @return array
     */
    public function generateImage(string $prompt, array $options = []): array
    {
        if (!$this->isConfigured()) {
            return [
                'success' => false,
                'error' => 'Kie.ai API not configured',
            ];
        }

        try {
            $payload = array_merge([
                'prompt' => $prompt,
                'size' => $options['size'] ?? '1024x1024',
                'quality' => $options['quality'] ?? 'hd',
                'style' => $options['style'] ?? 'vivid',
                'n' => $options['count'] ?? 1,
            ], $options);

            Log::info('🎨 Generating image with Kie.ai', [
                'prompt' => $prompt,
                'size' => $payload['size'],
            ]);

            $response = $this->client()->post($this->baseUrl . '/generate/image', $payload);

            if ($response->successful()) {
                $data = $response->json('data');

                Log::info('✅ Image generated successfully', [
                    'image_count' => count($data['images'] ?? []),
                ]);

                // Download and store images locally
                $localImages = $this->downloadImages($data['images'] ?? []);

                return [
                    'success' => true,
                    'data' => [
                        'images' => $localImages,
                        'prompt' => $prompt,
                        'credits_used' => $data['credits_used'] ?? 0,
                    ],
                ];
            }

            Log::error('❌ Kie.ai image generation failed', [
                'status' => $response->status(),
                'error' => $response->json(),
            ]);

            return [
                'success' => false,
                'error' => $response->json('message') ?? 'Image generation failed',
            ];
        } catch (Exception $e) {
            Log::error('❌ Error generating image', [
                'error' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Generate a video from text prompt
     *
     * @param string $prompt
     * @param array $options
     * @return array
     */
    public function generateVideo(string $prompt, array $options = []): array
    {
        if (!$this->isConfigured()) {
            return [
                'success' => false,
                'error' => 'Kie.ai API not configured',
            ];
        }

        try {
            $payload = array_merge([
                'prompt' => $prompt,
                'duration' => $options['duration'] ?? 5, // seconds
                'resolution' => $options['resolution'] ?? '1080p',
                'fps' => $options['fps'] ?? 30,
                'aspect_ratio' => $options['aspect_ratio'] ?? '16:9',
            ], $options);

            Log::info('🎥 Generating video with Kie.ai', [
                'prompt' => $prompt,
                'duration' => $payload['duration'],
            ]);

            $response = $this->client()->post($this->baseUrl . '/generate/video', $payload);

            if ($response->successful()) {
                $data = $response->json('data');

                // Video generation is usually async
                if (isset($data['job_id'])) {
                    return [
                        'success' => true,
                        'async' => true,
                        'data' => [
                            'job_id' => $data['job_id'],
                            'status' => 'processing',
                            'estimated_time' => $data['estimated_time'] ?? 60,
                        ],
                    ];
                }

                Log::info('✅ Video generated successfully');

                // Download and store video locally
                $localVideo = $this->downloadVideo($data['video_url']);

                return [
                    'success' => true,
                    'data' => [
                        'video_url' => $localVideo,
                        'prompt' => $prompt,
                        'duration' => $data['duration'] ?? 0,
                        'credits_used' => $data['credits_used'] ?? 0,
                    ],
                ];
            }

            Log::error('❌ Kie.ai video generation failed', [
                'status' => $response->status(),
                'error' => $response->json(),
            ]);

            return [
                'success' => false,
                'error' => $response->json('message') ?? 'Video generation failed',
            ];
        } catch (Exception $e) {
            Log::error('❌ Error generating video', [
                'error' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Edit an existing image
     *
     * @param string $imagePath
     * @param string $instructions
     * @param array $options
     * @return array
     */
    public function editImage(string $imagePath, string $instructions, array $options = []): array
    {
        if (!$this->isConfigured()) {
            return [
                'success' => false,
                'error' => 'Kie.ai API not configured',
            ];
        }

        try {
            Log::info('✏️ Editing image with Kie.ai', [
                'instructions' => $instructions,
            ]);

            $response = $this->client()->attach(
                'image',
                file_get_contents($imagePath),
                basename($imagePath)
            )->post($this->baseUrl . '/edit/image', [
                'instructions' => $instructions,
                'size' => $options['size'] ?? '1024x1024',
            ]);

            if ($response->successful()) {
                $data = $response->json('data');

                Log::info('✅ Image edited successfully');

                $localImage = $this->downloadImage($data['image_url']);

                return [
                    'success' => true,
                    'data' => [
                        'image_url' => $localImage,
                        'instructions' => $instructions,
                        'credits_used' => $data['credits_used'] ?? 0,
                    ],
                ];
            }

            Log::error('❌ Kie.ai image editing failed', [
                'status' => $response->status(),
                'error' => $response->json(),
            ]);

            return [
                'success' => false,
                'error' => $response->json('message') ?? 'Image editing failed',
            ];
        } catch (Exception $e) {
            Log::error('❌ Error editing image', [
                'error' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Check video generation job status
     *
     * @param string $jobId
     * @return array
     */
    public function checkJobStatus(string $jobId): array
    {
        if (!$this->isConfigured()) {
            return [
                'success' => false,
                'error' => 'Kie.ai API not configured',
            ];
        }

        try {
            $response = $this->client()->get($this->baseUrl . '/jobs/' . $jobId);

            if ($response->successful()) {
                $data = $response->json('data');

                if ($data['status'] === 'completed' && isset($data['video_url'])) {
                    $localVideo = $this->downloadVideo($data['video_url']);

                    return [
                        'success' => true,
                        'status' => 'completed',
                        'data' => [
                            'video_url' => $localVideo,
                            'duration' => $data['duration'] ?? 0,
                        ],
                    ];
                }

                return [
                    'success' => true,
                    'status' => $data['status'],
                    'progress' => $data['progress'] ?? 0,
                    'estimated_time' => $data['estimated_time'] ?? 0,
                ];
            }

            return [
                'success' => false,
                'error' => 'Failed to check job status',
            ];
        } catch (Exception $e) {
            Log::error('❌ Error checking job status', [
                'job_id' => $jobId,
                'error' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Get account credits and usage
     *
     * @return array|null
     */
    public function getCredits(): ?array
    {
        if (!$this->isConfigured()) {
            return null;
        }

        try {
            $response = $this->client()->get($this->baseUrl . '/account/credits');

            if ($response->successful()) {
                return $response->json('data');
            }

            return null;
        } catch (Exception $e) {
            Log::error('Error fetching Kie.ai credits', [
                'error' => $e->getMessage(),
            ]);

            return null;
        }
    }

    /**
     * Download images from URLs and store locally
     *
     * @param array $imageUrls
     * @return array
     */
    protected function downloadImages(array $imageUrls): array
    {
        $localImages = [];

        foreach ($imageUrls as $url) {
            try {
                $localPath = $this->downloadImage($url);
                if ($localPath) {
                    $localImages[] = $localPath;
                }
            } catch (Exception $e) {
                Log::error('Error downloading image', [
                    'url' => $url,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        return $localImages;
    }

    /**
     * Download a single image from URL
     *
     * @param string $url
     * @return string|null
     */
    protected function downloadImage(string $url): ?string
    {
        try {
            $content = Http::get($url)->body();
            $filename = 'kie_ai/' . date('Y/m/d') . '/' . uniqid() . '.png';

            Storage::disk('public')->put($filename, $content);

            return Storage::url($filename);
        } catch (Exception $e) {
            Log::error('Error downloading image', [
                'url' => $url,
                'error' => $e->getMessage(),
            ]);

            return null;
        }
    }

    /**
     * Download video from URL
     *
     * @param string $url
     * @return string|null
     */
    protected function downloadVideo(string $url): ?string
    {
        try {
            $content = Http::timeout(300)->get($url)->body();
            $filename = 'kie_ai/videos/' . date('Y/m/d') . '/' . uniqid() . '.mp4';

            Storage::disk('public')->put($filename, $content);

            return Storage::url($filename);
        } catch (Exception $e) {
            Log::error('Error downloading video', [
                'url' => $url,
                'error' => $e->getMessage(),
            ]);

            return null;
        }
    }

    /**
     * Generate image variations
     *
     * @param string $imagePath
     * @param int $count
     * @return array
     */
    public function generateVariations(string $imagePath, int $count = 3): array
    {
        if (!$this->isConfigured()) {
            return [
                'success' => false,
                'error' => 'Kie.ai API not configured',
            ];
        }

        try {
            $response = $this->client()->attach(
                'image',
                file_get_contents($imagePath),
                basename($imagePath)
            )->post($this->baseUrl . '/variations', [
                'n' => $count,
            ]);

            if ($response->successful()) {
                $data = $response->json('data');
                $localImages = $this->downloadImages($data['images'] ?? []);

                return [
                    'success' => true,
                    'data' => [
                        'images' => $localImages,
                        'count' => count($localImages),
                        'credits_used' => $data['credits_used'] ?? 0,
                    ],
                ];
            }

            return [
                'success' => false,
                'error' => $response->json('message') ?? 'Failed to generate variations',
            ];
        } catch (Exception $e) {
            Log::error('Error generating variations', [
                'error' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }
}
