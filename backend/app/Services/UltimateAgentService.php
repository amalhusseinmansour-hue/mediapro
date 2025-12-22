<?php

namespace App\Services;

use App\Models\AgentExecution;
use App\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Exception;

/**
 * Ultimate Agent Service
 *
 * هذا السيرفس يحل محل جميع الخدمات التالية:
 * - AIVideoGeneratorService
 * - KieAiService
 * - UploadPostService (جزئياً)
 * - N8nService
 *
 * ويوفر واجهة موحدة للتعامل مع Ultimate Media Agent
 */
class UltimateAgentService
{
    protected string $n8nBaseUrl;
    protected ?string $telegramChatId = null;
    protected ?int $userId = null;

    public function __construct()
    {
        $this->n8nBaseUrl = config('services.n8n.base_url', 'http://localhost:5678');
    }

    /**
     * Set the user context
     */
    public function forUser(?User $user = null): self
    {
        if ($user) {
            $this->userId = $user->id;
            $this->telegramChatId = $user->telegram_connections()->first()?->chat_id;
        } else if (auth()->check()) {
            $this->userId = auth()->id();
            $this->telegramChatId = auth()->user()->telegram_connections()->first()?->chat_id;
        }

        return $this;
    }

    /**
     * Set Telegram chat ID manually
     */
    public function forTelegramChat(string $chatId): self
    {
        $this->telegramChatId = $chatId;
        return $this;
    }

    // ============================================
    // 🎨 CONTENT GENERATION (يحل محل AIVideoGeneratorService & KieAiService)
    // ============================================

    /**
     * Create an image using AI
     *
     * @param string $prompt وصف الصورة
     * @param string $name اسم الملف
     * @return array
     */
    public function createImage(string $prompt, string $name): array
    {
        return $this->executeAgentCommand('content', 'create_image', [
            'prompt' => $prompt,
            'image' => $name,
            'chatID' => $this->telegramChatId,
        ]);
    }

    /**
     * Edit an existing image
     *
     * @param string $fileId Google Drive file ID
     * @param string $editRequest وصف التعديل المطلوب
     * @param string $imageName اسم الصورة
     * @return array
     */
    public function editImage(string $fileId, string $editRequest, string $imageName): array
    {
        return $this->executeAgentCommand('content', 'edit_image', [
            'pictureID' => $fileId,
            'request' => $editRequest,
            'image' => $imageName,
            'chatID' => $this->telegramChatId,
        ]);
    }

    /**
     * Create a video from text (يحل محل AIVideoGeneratorService::generateVideo)
     *
     * @param string $prompt وصف الفيديو
     * @param string $title عنوان الفيديو
     * @param string $aspectRatio نسبة العرض (9:16, 16:9, 1:1)
     * @return array
     */
    public function createVideo(string $prompt, string $title, string $aspectRatio = '9:16'): array
    {
        return $this->executeAgentCommand('content', 'create_video', [
            'prompt' => $prompt,
            'videoTitle' => $title,
            'aspectRatio' => $aspectRatio,
            'chatID' => $this->telegramChatId,
        ]);
    }

    /**
     * Create a video using Sora 2 Text-to-Video model via Kie.ai
     *
     * @param string $prompt وصف الفيديو
     * @param string $title عنوان الفيديو
     * @param string $aspectRatio نسبة العرض (landscape, portrait, square)
     * @param int $nFrames عدد الإطارات (5-10)
     * @param bool $removeWatermark إزالة العلامة المائية
     * @return array
     */
    public function createVideoSora(
        string $prompt,
        string $title,
        string $aspectRatio = 'landscape',
        int $nFrames = 10,
        bool $removeWatermark = true
    ): array {
        return $this->executeAgentCommand('content', 'create_video_sora', [
            'prompt' => $prompt,
            'videoTitle' => $title,
            'aspectRatio' => $aspectRatio,
            'n_frames' => $nFrames,
            'remove_watermark' => $removeWatermark,
            'chatID' => $this->telegramChatId,
        ]);
    }

    /**
     * Convert image to video (يحل محل AIVideoGeneratorService::imageToVideo)
     *
     * @param string $fileId Google Drive file ID
     * @param string $videoPrompt وصف حركة الفيديو
     * @param string $imageName اسم الصورة
     * @return array
     */
    public function imageToVideo(string $fileId, string $videoPrompt, string $imageName): array
    {
        return $this->executeAgentCommand('content', 'image_to_video', [
            'fileID' => $fileId,
            'videoPrompt' => $videoPrompt,
            'image' => $imageName,
            'chatID' => $this->telegramChatId,
        ]);
    }

    // ============================================
    // 📤 SOCIAL MEDIA POSTING (يحل محل UploadPostService جزئياً)
    // ============================================

    /**
     * Post to Instagram
     *
     * @param string $fileId Google Drive file ID
     * @param string $caption النص المصاحب
     * @return array
     */
    public function postToInstagram(string $fileId, string $caption): array
    {
        return $this->executeAgentCommand('posting', 'post_instagram', [
            'fileID' => $fileId,
            'text' => $caption,
        ]);
    }

    /**
     * Post to TikTok
     *
     * @param string $fileId Google Drive file ID
     * @param string $caption النص المصاحب
     * @return array
     */
    public function postToTikTok(string $fileId, string $caption): array
    {
        return $this->executeAgentCommand('posting', 'post_tiktok', [
            'fileID' => $fileId,
            'text' => $caption,
        ]);
    }

    /**
     * Post to YouTube
     *
     * @param string $fileId Google Drive file ID
     * @param string $title عنوان الفيديو
     * @return array
     */
    public function postToYouTube(string $fileId, string $title): array
    {
        return $this->executeAgentCommand('posting', 'post_youtube', [
            'fileID' => $fileId,
            'text' => $title,
        ]);
    }

    /**
     * Post to multiple platforms at once
     *
     * @param string $fileId Google Drive file ID
     * @param array $platforms ['instagram', 'tiktok', 'youtube']
     * @param string $caption النص المصاحب
     * @return array
     */
    public function postToMultiplePlatforms(string $fileId, array $platforms, string $caption): array
    {
        $results = [];

        foreach ($platforms as $platform) {
            $method = 'postTo' . ucfirst($platform);

            if (method_exists($this, $method)) {
                $results[$platform] = $this->$method($fileId, $caption);
            }
        }

        return $results;
    }

    // ============================================
    // 📧 EMAIL MANAGEMENT
    // ============================================

    /**
     * Send email via agent
     */
    public function sendEmail(string $to, string $subject, string $message): array
    {
        return $this->executeAgentCommand('email', 'send_email', [
            'To' => $to,
            'Subject' => $subject,
            'Message' => $message,
        ]);
    }

    /**
     * Get emails
     */
    public function getEmails(int $limit = 10, ?string $from = null): array
    {
        return $this->executeAgentCommand('email', 'get_emails', [
            'Limit' => $limit,
            'Sender' => $from,
        ]);
    }

    // ============================================
    // 📅 CALENDAR MANAGEMENT
    // ============================================

    /**
     * Create calendar event
     */
    public function createCalendarEvent(
        string $title,
        string $start,
        string $end,
        ?array $attendees = null
    ): array {
        $data = [
            'Summary' => $title,
            'Start' => $start,
            'End' => $end,
        ];

        if ($attendees && count($attendees) > 0) {
            $data['attendees0_Attendees'] = $attendees[0];
        }

        return $this->executeAgentCommand('calendar', 'create_event', $data);
    }

    /**
     * Get calendar events
     */
    public function getCalendarEvents(string $after, string $before): array
    {
        return $this->executeAgentCommand('calendar', 'get_events', [
            'After' => $after,
            'Before' => $before,
        ]);
    }

    // ============================================
    // 🌐 INTERNET & RESEARCH
    // ============================================

    /**
     * Search the web
     */
    public function searchWeb(string $query): array
    {
        return $this->executeAgentCommand('internet', 'search_web', [
            'Query' => $query,
        ]);
    }

    /**
     * Get weather information
     */
    public function getWeather(string $city): array
    {
        return $this->executeAgentCommand('internet', 'get_weather', [
            'City' => $city,
        ]);
    }

    // ============================================
    // 📁 GOOGLE DRIVE MANAGEMENT
    // ============================================

    /**
     * Rename file in Google Drive
     */
    public function renameFile(string $fileId, string $newName): array
    {
        return $this->executeAgentCommand('drive', 'rename_file', [
            'File_to_Update' => $fileId,
            'New_Updated_File_Name' => $newName,
        ]);
    }

    /**
     * Share file with anyone
     */
    public function shareFileWithAnyone(string $fileId): array
    {
        return $this->executeAgentCommand('drive', 'share_with_anyone', [
            'File' => $fileId,
        ]);
    }

    /**
     * Search for media files
     */
    public function searchMedia(): array
    {
        return $this->executeAgentCommand('drive', 'search_media', []);
    }

    // ============================================
    // 🤖 CORE EXECUTION METHOD
    // ============================================

    /**
     * Execute agent command
     *
     * @param string $agentType (content, posting, email, calendar, drive, internet)
     * @param string $action الإجراء المطلوب
     * @param array $data البيانات
     * @return array
     */
    protected function executeAgentCommand(string $agentType, string $action, array $data = []): array
    {
        // Create execution record
        $execution = AgentExecution::create([
            'user_id' => $this->userId ?? auth()->id(),
            'agent_type' => $agentType,
            'action' => $action,
            'status' => 'pending',
            'input_data' => $data,
            'telegram_chat_id' => $this->telegramChatId,
        ]);

        try {
            $execution->markAsProcessing();

            // Build webhook URL based on agent type
            $webhookUrl = $this->getWebhookUrl($agentType);

            Log::info('🤖 Ultimate Agent Command', [
                'agent' => $agentType,
                'action' => $action,
                'webhook' => $webhookUrl,
                'data' => $data,
            ]);

            // Send request to n8n
            $response = Http::timeout(120)->post($webhookUrl, array_merge($data, [
                'execution_id' => $execution->id,
                'user_id' => $this->userId ?? auth()->id(),
            ]));

            if ($response->successful()) {
                $responseData = $response->json();

                Log::info('✅ Agent Command Success', [
                    'execution_id' => $execution->id,
                    'response' => $responseData,
                ]);

                $execution->markAsCompleted($responseData);

                return [
                    'success' => true,
                    'data' => $responseData,
                    'execution_id' => $execution->id,
                ];
            }

            $error = $response->json('message', 'Agent execution failed');

            Log::error('❌ Agent Command Failed', [
                'execution_id' => $execution->id,
                'status' => $response->status(),
                'error' => $error,
            ]);

            $execution->markAsFailed($error);

            return [
                'success' => false,
                'error' => $error,
                'execution_id' => $execution->id,
            ];

        } catch (Exception $e) {
            Log::error('❌ Agent Command Exception', [
                'execution_id' => $execution->id,
                'error' => $e->getMessage(),
            ]);

            $execution->markAsFailed($e->getMessage());

            return [
                'success' => false,
                'error' => $e->getMessage(),
                'execution_id' => $execution->id,
            ];
        }
    }

    /**
     * Get webhook URL for agent type
     */
    protected function getWebhookUrl(string $agentType): string
    {
        // Map agent types to n8n webhook IDs
        $webhookMap = [
            'content' => 'content-agent',
            'posting' => 'posting-agent',
            'email' => 'email-agent',
            'calendar' => 'calendar-agent',
            'drive' => 'drive-agent',
            'contact' => 'contact-agent',
            'internet' => 'internet-agent',
        ];

        $webhookId = $webhookMap[$agentType] ?? 'ultimate-agent';

        return "{$this->n8nBaseUrl}/webhook/{$webhookId}";
    }

    // ============================================
    // 📊 STATISTICS & MONITORING
    // ============================================

    /**
     * Get user's execution statistics
     */
    public function getUserStats(?int $userId = null): array
    {
        $userId = $userId ?? $this->userId ?? auth()->id();

        $executions = AgentExecution::where('user_id', $userId);

        return [
            'total' => $executions->count(),
            'completed' => $executions->clone()->completed()->count(),
            'failed' => $executions->clone()->failed()->count(),
            'processing' => $executions->clone()->processing()->count(),
            'by_agent' => $executions->clone()
                ->selectRaw('agent_type, count(*) as count')
                ->groupBy('agent_type')
                ->get()
                ->mapWithKeys(fn($item) => [$item->agent_type => $item->count])
                ->toArray(),
            'total_credits_used' => $executions->sum('credits_used'),
        ];
    }

    /**
     * Get recent executions
     */
    public function getRecentExecutions(int $limit = 10, ?int $userId = null): array
    {
        $userId = $userId ?? $this->userId ?? auth()->id();

        return AgentExecution::where('user_id', $userId)
            ->with('user')
            ->orderBy('created_at', 'desc')
            ->limit($limit)
            ->get()
            ->map(function ($execution) {
                return [
                    'id' => $execution->id,
                    'agent' => $execution->agent_type_name,
                    'action' => $execution->action,
                    'status' => $execution->status,
                    'duration' => $execution->duration_human,
                    'created_at' => $execution->created_at->diffForHumans(),
                ];
            })
            ->toArray();
    }
}
