<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class DIDService
{
    protected $apiKey;
    protected $baseUrl = 'https://api.d-id.com';

    public function __construct()
    {
        $this->apiKey = env('DID_API_KEY');
    }

    /**
     * Create talking avatar video from text
     */
    public function createTalkingAvatar(string $text, array $options = []): array
    {
        try {
            $payload = [
                'script' => [
                    'type' => 'text',
                    'input' => $text,
                    'provider' => [
                        'type' => $options['voice_provider'] ?? 'microsoft',
                        'voice_id' => $options['voice_id'] ?? 'en-US-JennyNeural',
                    ],
                ],
                'config' => [
                    'fluent' => $options['fluent'] ?? true,
                    'pad_audio' => $options['pad_audio'] ?? 0,
                ],
            ];

            // Use provided image or default avatar
            if (isset($options['source_url'])) {
                $payload['source_url'] = $options['source_url'];
            } else {
                $payload['presenter_id'] = $options['presenter_id'] ?? 'amy-Aq6OmGZnMt';
            }

            if (isset($options['driver_id'])) {
                $payload['driver_id'] = $options['driver_id'];
            }

            $response = Http::withHeaders([
                'Authorization' => 'Basic ' . $this->apiKey,
                'Content-Type' => 'application/json',
            ])->post("{$this->baseUrl}/talks", $payload);

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'success' => true,
                    'talk_id' => $data['id'] ?? null,
                    'status' => $data['status'] ?? 'created',
                    'data' => $data,
                ];
            }

            Log::error('D-ID Create Talk Error', [
                'status' => $response->status(),
                'response' => $response->json(),
            ]);

            return [
                'success' => false,
                'error' => $response->json()['description'] ?? 'فشل في إنشاء الفيديو',
            ];

        } catch (\Exception $e) {
            Log::error('D-ID Exception', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Create video with audio file
     */
    public function createWithAudio(string $audioUrl, array $options = []): array
    {
        try {
            $payload = [
                'script' => [
                    'type' => 'audio',
                    'audio_url' => $audioUrl,
                ],
                'config' => [
                    'fluent' => $options['fluent'] ?? true,
                ],
            ];

            if (isset($options['source_url'])) {
                $payload['source_url'] = $options['source_url'];
            } else {
                $payload['presenter_id'] = $options['presenter_id'] ?? 'amy-Aq6OmGZnMt';
            }

            $response = Http::withHeaders([
                'Authorization' => 'Basic ' . $this->apiKey,
                'Content-Type' => 'application/json',
            ])->post("{$this->baseUrl}/talks", $payload);

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'success' => true,
                    'talk_id' => $data['id'] ?? null,
                    'status' => $data['status'] ?? 'created',
                    'data' => $data,
                ];
            }

            return [
                'success' => false,
                'error' => $response->json()['description'] ?? 'فشل في إنشاء الفيديو',
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Check talk status
     */
    public function checkStatus(string $talkId): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Basic ' . $this->apiKey,
            ])->get("{$this->baseUrl}/talks/{$talkId}");

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'success' => true,
                    'talk_id' => $talkId,
                    'status' => $data['status'] ?? 'unknown',
                    'result_url' => $data['result_url'] ?? null,
                    'duration' => $data['duration'] ?? null,
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
     * Delete a talk
     */
    public function deleteTalk(string $talkId): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Basic ' . $this->apiKey,
            ])->delete("{$this->baseUrl}/talks/{$talkId}");

            return [
                'success' => $response->successful(),
                'message' => $response->successful() ? 'تم حذف الفيديو' : 'فشل في الحذف',
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Get available presenters
     */
    public function getPresenters(): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Basic ' . $this->apiKey,
            ])->get("{$this->baseUrl}/clips/presenters");

            if ($response->successful()) {
                return [
                    'success' => true,
                    'presenters' => $response->json()['presenters'] ?? [],
                ];
            }

            return [
                'success' => false,
                'error' => 'فشل في جلب قائمة المقدمين',
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Get available voices
     */
    public function getVoices(): array
    {
        return [
            'microsoft' => [
                'en-US-JennyNeural' => 'Jenny (English US)',
                'en-US-GuyNeural' => 'Guy (English US)',
                'en-GB-SoniaNeural' => 'Sonia (English UK)',
                'ar-SA-HamedNeural' => 'Hamed (Arabic)',
                'ar-SA-ZariyahNeural' => 'Zariyah (Arabic Female)',
                'ar-EG-SalmaNeural' => 'Salma (Arabic Egyptian)',
            ],
            'elevenlabs' => [
                'rachel' => 'Rachel',
                'adam' => 'Adam',
                'antoni' => 'Antoni',
            ],
        ];
    }

    /**
     * Get credits/usage
     */
    public function getCredits(): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Basic ' . $this->apiKey,
            ])->get("{$this->baseUrl}/credits");

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'success' => true,
                    'remaining' => $data['remaining'] ?? 0,
                    'total' => $data['total'] ?? 0,
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
}
