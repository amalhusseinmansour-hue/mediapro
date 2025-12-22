<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\TelegramAdminBotService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;

class TelegramController extends Controller
{
    protected TelegramAdminBotService $botService;

    public function __construct(TelegramAdminBotService $botService)
    {
        $this->botService = $botService;
    }

    /**
     * Handle incoming Telegram webhook
     * This receives ALL updates from Telegram (messages, button clicks, etc.)
     */
    public function webhook(Request $request): JsonResponse
    {
        try {
            $update = $request->all();

            Log::info('Telegram webhook received', [
                'update_id' => $update['update_id'] ?? null,
                'type' => isset($update['message']) ? 'message' : (isset($update['callback_query']) ? 'callback' : 'other')
            ]);

            // Process update via admin bot service
            $result = $this->botService->handleUpdate($update);

            return response()->json([
                'ok' => true,
                'result' => $result
            ]);

        } catch (\Exception $e) {
            Log::error('Telegram webhook error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            // Always return ok to Telegram to avoid retries
            return response()->json(['ok' => true]);
        }
    }

    /**
     * Set webhook URL for Telegram Bot
     */
    public function setWebhook(Request $request): JsonResponse
    {
        $request->validate([
            'webhook_url' => 'required|url'
        ]);

        try {
            $webhookUrl = $request->input('webhook_url');
            $result = $this->botService->setWebhook($webhookUrl);

            if ($result['ok'] ?? false) {
                return response()->json([
                    'success' => true,
                    'message' => 'Webhook set successfully',
                    'webhook_url' => $webhookUrl,
                    'result' => $result
                ]);
            }

            return response()->json([
                'success' => false,
                'error' => $result['description'] ?? 'Failed to set webhook',
                'result' => $result
            ], 400);

        } catch (\Exception $e) {
            Log::error('Set webhook failed', [
                'error' => $e->getMessage(),
                'webhook_url' => $request->input('webhook_url')
            ]);

            return response()->json([
                'success' => false,
                'error' => 'Failed to set webhook: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get webhook info
     */
    public function getWebhookInfo(): JsonResponse
    {
        try {
            $botToken = config('services.telegram.bot_token', env('TELEGRAM_BOT_TOKEN'));

            if (empty($botToken)) {
                return response()->json([
                    'success' => false,
                    'error' => 'Bot token not configured'
                ], 400);
            }

            $response = \Illuminate\Support\Facades\Http::get("https://api.telegram.org/bot{$botToken}/getWebhookInfo");

            if ($response->successful()) {
                return response()->json([
                    'success' => true,
                    'webhook_info' => $response->json()['result'] ?? null
                ]);
            }

            return response()->json([
                'success' => false,
                'error' => 'Failed to get webhook info'
            ], 500);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Delete webhook
     */
    public function deleteWebhook(): JsonResponse
    {
        try {
            $botToken = config('services.telegram.bot_token', env('TELEGRAM_BOT_TOKEN'));

            $response = \Illuminate\Support\Facades\Http::post("https://api.telegram.org/bot{$botToken}/deleteWebhook");

            if ($response->successful()) {
                return response()->json([
                    'success' => true,
                    'message' => 'Webhook deleted successfully'
                ]);
            }

            return response()->json([
                'success' => false,
                'error' => 'Failed to delete webhook'
            ], 500);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Test bot functionality
     */
    public function test(): JsonResponse
    {
        try {
            $botToken = config('services.telegram.bot_token', env('TELEGRAM_BOT_TOKEN'));

            if (empty($botToken)) {
                return response()->json([
                    'success' => false,
                    'error' => 'Telegram bot token not configured'
                ], 400);
            }

            $response = \Illuminate\Support\Facades\Http::get("https://api.telegram.org/bot{$botToken}/getMe");

            if ($response->successful()) {
                $botInfo = $response->json();

                return response()->json([
                    'success' => true,
                    'message' => 'Bot is working correctly',
                    'bot_info' => $botInfo['result'] ?? null
                ]);
            }

            return response()->json([
                'success' => false,
                'error' => 'Bot token is invalid or bot is not accessible'
            ], 400);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Test failed: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get bot configuration for background service
     * Used by Flutter app to initialize background bot features
     */
    public function getBotConfig(): JsonResponse
    {
        try {
            $botToken = config('services.telegram.bot_token', env('TELEGRAM_BOT_TOKEN'));

            if (empty($botToken)) {
                return response()->json([
                    'success' => false,
                    'error' => 'Bot token not configured'
                ], 400);
            }

            return response()->json([
                'success' => true,
                'bot_token' => $botToken,
                'bot_enabled' => !empty($botToken),
                'features' => [
                    'auto_notifications' => true,
                    'admin_panel' => true,
                    'user_support' => false, // Disabled for now
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Send notification to admins (for internal use)
     */
    public function notifyAdmins(Request $request): JsonResponse
    {
        $request->validate([
            'message' => 'required|string'
        ]);

        try {
            $this->botService->notifyAdmins($request->input('message'));

            return response()->json([
                'success' => true,
                'message' => 'Notification sent to admins'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
