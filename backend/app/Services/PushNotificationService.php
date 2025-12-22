<?php

namespace App\Services;

use App\Models\User;
use App\Models\Notification;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class PushNotificationService
{
    protected $firebaseServerKey;
    protected $firebaseProjectId;

    public function __construct()
    {
        $this->firebaseServerKey = env('FIREBASE_SERVER_KEY');
        $this->firebaseProjectId = env('FIREBASE_PROJECT_ID');
    }

    /**
     * Send push notification to user
     */
    public function sendToUser(User $user, string $title, string $body, array $data = []): array
    {
        try {
            // Get user's FCM tokens
            $tokens = $this->getUserTokens($user);

            if (empty($tokens)) {
                return [
                    'success' => false,
                    'error' => 'لا يوجد توكن للإشعارات لهذا المستخدم',
                ];
            }

            // Save notification to database
            $notification = Notification::create([
                'user_id' => $user->id,
                'type' => $data['type'] ?? 'general',
                'title' => $title,
                'message' => $body,
                'data' => $data,
                'is_read' => false,
            ]);

            // Send FCM notification
            $result = $this->sendFcmNotification($tokens, $title, $body, $data);

            return [
                'success' => $result['success'],
                'notification_id' => $notification->id,
                'sent_count' => $result['sent_count'] ?? 0,
                'failed_count' => $result['failed_count'] ?? 0,
            ];

        } catch (\Exception $e) {
            Log::error('Push Notification Error', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Send to multiple users
     */
    public function sendToUsers(array $userIds, string $title, string $body, array $data = []): array
    {
        $results = [];
        $successCount = 0;

        foreach ($userIds as $userId) {
            $user = User::find($userId);
            if ($user) {
                $result = $this->sendToUser($user, $title, $body, $data);
                $results[$userId] = $result;
                if ($result['success']) {
                    $successCount++;
                }
            }
        }

        return [
            'success' => $successCount > 0,
            'total' => count($userIds),
            'sent' => $successCount,
            'results' => $results,
        ];
    }

    /**
     * Send to all users (broadcast)
     */
    public function broadcast(string $title, string $body, array $data = []): array
    {
        try {
            // Create global notification
            $notification = Notification::create([
                'type' => $data['type'] ?? 'broadcast',
                'title' => $title,
                'message' => $body,
                'data' => $data,
                'is_global' => true,
                'is_read' => false,
            ]);

            // Get all active users with FCM tokens
            $tokens = $this->getAllActiveTokens();

            if (empty($tokens)) {
                return [
                    'success' => true,
                    'notification_id' => $notification->id,
                    'message' => 'تم حفظ الإشعار - لا يوجد توكنات لإرسال إشعارات فورية',
                ];
            }

            // Send in batches (FCM limit is 500 per request)
            $batches = array_chunk($tokens, 500);
            $totalSent = 0;
            $totalFailed = 0;

            foreach ($batches as $batch) {
                $result = $this->sendFcmNotification($batch, $title, $body, $data);
                $totalSent += $result['sent_count'] ?? 0;
                $totalFailed += $result['failed_count'] ?? 0;
            }

            return [
                'success' => true,
                'notification_id' => $notification->id,
                'sent_count' => $totalSent,
                'failed_count' => $totalFailed,
            ];

        } catch (\Exception $e) {
            Log::error('Broadcast Error', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Send to topic subscribers
     */
    public function sendToTopic(string $topic, string $title, string $body, array $data = []): array
    {
        try {
            $payload = [
                'message' => [
                    'topic' => $topic,
                    'notification' => [
                        'title' => $title,
                        'body' => $body,
                    ],
                    'data' => array_map('strval', $data),
                    'android' => [
                        'priority' => 'high',
                    ],
                    'apns' => [
                        'payload' => [
                            'aps' => [
                                'sound' => 'default',
                            ],
                        ],
                    ],
                ],
            ];

            $response = $this->sendToFcmV1($payload);

            return [
                'success' => $response['success'],
                'message_id' => $response['message_id'] ?? null,
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Subscribe user to topic
     */
    public function subscribeToTopic(string $token, string $topic): bool
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'key=' . $this->firebaseServerKey,
                'Content-Type' => 'application/json',
            ])->post("https://iid.googleapis.com/iid/v1/{$token}/rel/topics/{$topic}");

            return $response->successful();

        } catch (\Exception $e) {
            Log::error('Subscribe to Topic Error', ['error' => $e->getMessage()]);
            return false;
        }
    }

    /**
     * Unsubscribe user from topic
     */
    public function unsubscribeFromTopic(string $token, string $topic): bool
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'key=' . $this->firebaseServerKey,
                'Content-Type' => 'application/json',
            ])->delete("https://iid.googleapis.com/iid/v1/{$token}/rel/topics/{$topic}");

            return $response->successful();

        } catch (\Exception $e) {
            return false;
        }
    }

    /**
     * Register FCM token for user
     */
    public function registerToken(User $user, string $token, string $platform = 'android'): bool
    {
        try {
            $tokens = $user->fcm_tokens ?? [];

            // Remove duplicate
            $tokens = array_filter($tokens, fn($t) => $t['token'] !== $token);

            // Add new token
            $tokens[] = [
                'token' => $token,
                'platform' => $platform,
                'created_at' => now()->toIso8601String(),
            ];

            // Keep only last 5 tokens per user
            $tokens = array_slice($tokens, -5);

            $user->update(['fcm_tokens' => $tokens]);

            return true;

        } catch (\Exception $e) {
            Log::error('Register Token Error', ['error' => $e->getMessage()]);
            return false;
        }
    }

    /**
     * Remove FCM token
     */
    public function removeToken(User $user, string $token): bool
    {
        try {
            $tokens = $user->fcm_tokens ?? [];
            $tokens = array_filter($tokens, fn($t) => $t['token'] !== $token);
            $user->update(['fcm_tokens' => array_values($tokens)]);
            return true;
        } catch (\Exception $e) {
            return false;
        }
    }

    /**
     * Send FCM notification (legacy API)
     */
    protected function sendFcmNotification(array $tokens, string $title, string $body, array $data = []): array
    {
        try {
            $payload = [
                'registration_ids' => $tokens,
                'notification' => [
                    'title' => $title,
                    'body' => $body,
                    'sound' => 'default',
                    'badge' => 1,
                ],
                'data' => $data,
                'priority' => 'high',
            ];

            $response = Http::withHeaders([
                'Authorization' => 'key=' . $this->firebaseServerKey,
                'Content-Type' => 'application/json',
            ])->post('https://fcm.googleapis.com/fcm/send', $payload);

            if ($response->successful()) {
                $result = $response->json();
                return [
                    'success' => true,
                    'sent_count' => $result['success'] ?? 0,
                    'failed_count' => $result['failure'] ?? 0,
                ];
            }

            return [
                'success' => false,
                'error' => 'FCM request failed',
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Send using FCM v1 API
     */
    protected function sendToFcmV1(array $payload): array
    {
        try {
            $accessToken = $this->getAccessToken();

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'Content-Type' => 'application/json',
            ])->post(
                "https://fcm.googleapis.com/v1/projects/{$this->firebaseProjectId}/messages:send",
                $payload
            );

            if ($response->successful()) {
                return [
                    'success' => true,
                    'message_id' => $response->json()['name'] ?? null,
                ];
            }

            return [
                'success' => false,
                'error' => $response->json()['error']['message'] ?? 'Unknown error',
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Get user's FCM tokens
     */
    protected function getUserTokens(User $user): array
    {
        $tokens = $user->fcm_tokens ?? [];
        return array_column($tokens, 'token');
    }

    /**
     * Get all active users' tokens
     */
    protected function getAllActiveTokens(): array
    {
        $users = User::whereNotNull('fcm_tokens')
            ->where('is_active', true)
            ->get();

        $tokens = [];
        foreach ($users as $user) {
            $userTokens = $user->fcm_tokens ?? [];
            foreach ($userTokens as $t) {
                $tokens[] = $t['token'];
            }
        }

        return array_unique($tokens);
    }

    /**
     * Get OAuth access token for FCM v1
     */
    protected function getAccessToken(): string
    {
        // This requires google/auth library
        // For simplicity, we'll use the legacy API
        // In production, use Firebase Admin SDK or service account
        return $this->firebaseServerKey;
    }

    /**
     * Check if service is configured
     */
    public function isConfigured(): bool
    {
        return !empty($this->firebaseServerKey) && !str_contains($this->firebaseServerKey, 'your_');
    }
}
