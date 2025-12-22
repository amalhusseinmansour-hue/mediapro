<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Telegram Bot Service for Video Generation Integration
 * Similar to n8n Ultimate Media Agent workflow
 */
class TelegramVideoService
{
    protected string $botToken;
    protected KieAIVideoService $videoService;

    public function __construct(KieAIVideoService $videoService)
    {
        $this->botToken = config('services.telegram.bot_token', env('TELEGRAM_BOT_TOKEN'));
        $this->videoService = $videoService;
    }

    /**
     * Handle incoming message from Telegram
     * Similar to n8n Telegram Trigger
     */
    public function handleIncomingMessage(array $update): array
    {
        $message = $update['message'] ?? null;
        
        if (!$message) {
            return ['success' => false, 'error' => 'No message found'];
        }

        $chatId = $message['chat']['id'];
        $text = $message['text'] ?? null;
        $photo = $message['photo'] ?? null;

        Log::info('Telegram message received', [
            'chat_id' => $chatId,
            'has_text' => !empty($text),
            'has_photo' => !empty($photo)
        ]);

        // Handle photo messages (similar to n8n Switch node)
        if ($photo) {
            return $this->handlePhotoMessage($chatId, $photo, $message);
        }

        // Handle text messages
        if ($text) {
            return $this->handleTextMessage($chatId, $text);
        }

        return $this->sendMessage($chatId, '❌ نوع الرسالة غير مدعوم. يرجى إرسال نص أو صورة.');
    }

    /**
     * Handle photo message (similar to n8n Download File + Upload file workflow)
     */
    protected function handlePhotoMessage(string $chatId, array $photos, array $message): array
    {
        try {
            // Get the highest quality photo (similar to n8n workflow)
            $photo = end($photos);
            $fileId = $photo['file_id'];

            // Download file from Telegram
            $fileInfo = $this->getFile($fileId);
            if (!$fileInfo['success']) {
                return $this->sendMessage($chatId, '❌ خطأ في تحميل الصورة');
            }

            $imageUrl = "https://api.telegram.org/file/bot{$this->botToken}/{$fileInfo['file_path']}";
            
            // Send confirmation message
            $this->sendMessage($chatId, '✅ تم استلام الصورة! ماذا تريد أن أفعل بها؟ 

يمكنك كتابة:
• "حول إلى فيديو: [وصف الحركة]"
• "أضف تأثيرات: [نوع التأثير]"

مثال: حول إلى فيديو: اجعل الأمواج تتحرك بلطف');

            // Store image info for later use
            // In production, you might want to store this in database or cache
            
            return [
                'success' => true,
                'action' => 'photo_received',
                'image_url' => $imageUrl,
                'chat_id' => $chatId
            ];

        } catch (\Exception $e) {
            Log::error('Photo handling failed', ['error' => $e->getMessage()]);
            return $this->sendMessage($chatId, '❌ حدث خطأ في معالجة الصورة');
        }
    }

    /**
     * Handle text message (similar to n8n Best Media Agent)
     */
    protected function handleTextMessage(string $chatId, string $text): array
    {
        try {
            // Check if it's a video generation request
            if ($this->isVideoGenerationRequest($text)) {
                return $this->handleVideoGenerationRequest($chatId, $text);
            }

            // Check if it's an image-to-video request
            if ($this->isImageToVideoRequest($text)) {
                return $this->handleImageToVideoRequest($chatId, $text);
            }

            // General AI response (you can integrate with your existing AI services)
            return $this->sendMessage($chatId, '🤖 مرحباً! يمكنني مساعدتك في:

🎬 توليد فيديوهات من النص
📸 تحويل الصور إلى فيديوهات
🎨 إنشاء محتوى إبداعي

أمثلة على الطلبات:
• "أنشئ فيديو: منظر طبيعي جميل"
• أرسل صورة ثم اكتب "حول إلى فيديو: [وصف]"');

        } catch (\Exception $e) {
            Log::error('Text handling failed', ['error' => $e->getMessage()]);
            return $this->sendMessage($chatId, '❌ حدث خطأ في معالجة الرسالة');
        }
    }

    /**
     * Check if text is a video generation request
     */
    protected function isVideoGenerationRequest(string $text): bool
    {
        $patterns = [
            'أنشئ فيديو',
            'إنشاء فيديو',
            'create video',
            'generate video',
            'فيديو عن'
        ];

        foreach ($patterns as $pattern) {
            if (stripos($text, $pattern) !== false) {
                return true;
            }
        }

        return false;
    }

    /**
     * Check if text is an image-to-video request
     */
    protected function isImageToVideoRequest(string $text): bool
    {
        $patterns = [
            'حول إلى فيديو',
            'تحويل إلى فيديو',
            'convert to video',
            'image to video',
            'أضف حركة'
        ];

        foreach ($patterns as $pattern) {
            if (stripos($text, $pattern) !== false) {
                return true;
            }
        }

        return false;
    }

    /**
     * Handle video generation request (similar to n8n Create Video Tool)
     */
    protected function handleVideoGenerationRequest(string $chatId, string $text): array
    {
        try {
            // Extract prompt from text
            $prompt = $this->extractPrompt($text);
            
            if (empty($prompt)) {
                return $this->sendMessage($chatId, '❌ يرجى تحديد وصف أوضح للفيديو المطلوب');
            }

            // Send processing message
            $this->sendMessage($chatId, '⏳ جاري إنشاء الفيديو... سيستغرق حوالي 3 دقائق');

            // Generate video using Kie AI
            $result = $this->videoService->generateWithRetry([
                'prompt' => $prompt,
                'aspectRatio' => '9:16', // Default for social media
                'model' => 'veo3_fast',
            ]);

            if ($result['success']) {
                // Start monitoring the generation
                $this->monitorVideoGeneration($chatId, $result['task_id'], 'Generated Video');
                
                return [
                    'success' => true,
                    'action' => 'video_generation_started',
                    'task_id' => $result['task_id']
                ];
            } else {
                return $this->sendMessage($chatId, '❌ فشل في إنشاء الفيديو: ' . $result['error']);
            }

        } catch (\Exception $e) {
            Log::error('Video generation request failed', ['error' => $e->getMessage()]);
            return $this->sendMessage($chatId, '❌ حدث خطأ في إنشاء الفيديو');
        }
    }

    /**
     * Handle image-to-video request (similar to n8n Image to Video Tool)
     */
    protected function handleImageToVideoRequest(string $chatId, string $text): array
    {
        // This would require storing the image URL from previous message
        // For simplicity, we'll ask user to send image again
        return $this->sendMessage($chatId, '📸 يرجى إرسال الصورة أولاً، ثم اكتب الوصف المطلوب للحركة');
    }

    /**
     * Extract prompt from text
     */
    protected function extractPrompt(string $text): string
    {
        $patterns = [
            '/أنشئ فيديو:?\s*(.+)/i',
            '/إنشاء فيديو:?\s*(.+)/i',
            '/create video:?\s*(.+)/i',
            '/generate video:?\s*(.+)/i',
            '/فيديو عن:?\s*(.+)/i'
        ];

        foreach ($patterns as $pattern) {
            if (preg_match($pattern, $text, $matches)) {
                return trim($matches[1]);
            }
        }

        // If no pattern matches, return the whole text
        return $text;
    }

    /**
     * Monitor video generation status (similar to n8n Wait + Get_video workflow)
     */
    protected function monitorVideoGeneration(string $chatId, string $taskId, string $title): void
    {
        // In production, you should use Queue Jobs for this
        // For simplicity, we'll use a basic approach
        
        dispatch(function () use ($chatId, $taskId, $title) {
            $maxAttempts = 20; // 10 minutes max (30 seconds * 20)
            $attempt = 0;

            while ($attempt < $maxAttempts) {
                sleep(30); // Wait 30 seconds

                $status = $this->videoService->checkStatus($taskId);
                
                if ($status['success'] && isset($status['status'])) {
                    if ($status['status'] === 'completed' && !empty($status['video_url'])) {
                        // Video is ready, send it to user
                        $this->sendVideoToUser($chatId, $status['video_url'], $title);
                        break;
                    } elseif ($status['status'] === 'failed') {
                        $this->sendMessage($chatId, '❌ فشل في توليد الفيديو. يرجى المحاولة مرة أخرى.');
                        break;
                    }
                }

                $attempt++;
                
                // Send progress update every 3 minutes
                if ($attempt % 6 === 0) {
                    $this->sendMessage($chatId, '⏳ ما زال العمل جارياً على إنشاء الفيديو... يرجى الانتظار');
                }
            }

            if ($attempt >= $maxAttempts) {
                $this->sendMessage($chatId, '⏰ انتهت مهلة انتظار إنشاء الفيديو. يرجى المحاولة مرة أخرى.');
            }
        });
    }

    /**
     * Send video to user (similar to n8n Send Video)
     */
    protected function sendVideoToUser(string $chatId, string $videoUrl, string $title): array
    {
        try {
            return Http::post("https://api.telegram.org/bot{$this->botToken}/sendVideo", [
                'chat_id' => $chatId,
                'video' => $videoUrl,
                'caption' => "✅ تم إنشاء الفيديو بنجاح!\n📹 العنوان: {$title}",
            ])->json();

        } catch (\Exception $e) {
            Log::error('Send video failed', ['error' => $e->getMessage()]);
            return $this->sendMessage($chatId, '✅ تم إنشاء الفيديو! لكن حدث خطأ في الإرسال. رابط التحميل: ' . $videoUrl);
        }
    }

    /**
     * Get file info from Telegram
     */
    protected function getFile(string $fileId): array
    {
        try {
            $response = Http::get("https://api.telegram.org/bot{$this->botToken}/getFile", [
                'file_id' => $fileId
            ]);

            if ($response->successful()) {
                $data = $response->json();
                if ($data['ok']) {
                    return [
                        'success' => true,
                        'file_path' => $data['result']['file_path']
                    ];
                }
            }

            return ['success' => false, 'error' => 'Failed to get file info'];

        } catch (\Exception $e) {
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Send message to Telegram chat
     */
    protected function sendMessage(string $chatId, string $text): array
    {
        try {
            return Http::post("https://api.telegram.org/bot{$this->botToken}/sendMessage", [
                'chat_id' => $chatId,
                'text' => $text,
                'parse_mode' => 'HTML',
            ])->json();

        } catch (\Exception $e) {
            Log::error('Send message failed', ['error' => $e->getMessage()]);
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Set webhook URL (for setup)
     */
    public function setWebhook(string $webhookUrl): array
    {
        try {
            $response = Http::post("https://api.telegram.org/bot{$this->botToken}/setWebhook", [
                'url' => $webhookUrl
            ]);

            return $response->json();

        } catch (\Exception $e) {
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }
}