<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class N8nService
{
    protected $httpClient;
    protected $webhookUrl;

    public function __construct()
    {
        // The N8N webhook URL should be stored securely in your .env file
        // Example: N8N_IMAGE_EDIT_WEBHOOK=https://n8n.example.com/webhook/QDmg9rBsQuXE8vx9
        $this->webhookUrl = config('services.n8n.image_edit_webhook');

        if (empty($this->webhookUrl)) {
            Log::error('N8N Webhook URL is not configured in services.n8n.image_edit_webhook');
        }
    }

    /**
     * Triggers the N8N workflow for image editing.
     *
     * @param array $data The data to send to the webhook.
     * @return array
     */
    public function triggerImageEditWorkflow(array $data): array
    {
        if (empty($this->webhookUrl)) {
            return ['success' => false, 'message' => 'N8N service is not configured.'];
        }

        $response = Http::post($this->webhookUrl, [
            'pictureID' => $data['pictureID'],
            'edit_prompt' => $data['edit_prompt'],
            'image_name' => $data['image_name'],
            'chatID' => $data['chatID'] ?? null,
        ]);

        if ($response->successful()) {
            return ['success' => true, 'message' => 'N8N workflow triggered successfully.', 'data' => $response->json()];
        }

        return ['success' => false, 'message' => 'Failed to trigger N8N workflow.', 'data' => $response->body()];
    }
}