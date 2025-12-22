<?php

namespace App\Observers;

use App\Services\TelegramAdminBotService;
use Illuminate\Support\Facades\Log;

/**
 * Observer to automatically notify admins via Telegram when important events occur
 */
class AdminNotificationObserver
{
    protected TelegramAdminBotService $botService;

    public function __construct(TelegramAdminBotService $botService)
    {
        $this->botService = $botService;
    }

    /**
     * Send notification to admins
     */
    protected function notify(string $message): void
    {
        try {
            $this->botService->notifyAdmins($message);
        } catch (\Exception $e) {
            Log::error('Failed to send Telegram notification', [
                'error' => $e->getMessage(),
                'message' => $message
            ]);
        }
    }

    /**
     * Handle created event for various models
     */
    public function created($model): void
    {
        $modelClass = class_basename($model);

        switch ($modelClass) {
            case 'User':
                $this->notify(
                    "🆕 *New User Registered*\n\n" .
                    "👤 Name: {$model->name}\n" .
                    "📧 Email: {$model->email}\n" .
                    "📱 Phone: {$model->phone}\n" .
                    "🆔 ID: `{$model->id}`\n" .
                    "📅 Date: {$model->created_at->format('Y-m-d H:i')}"
                );
                break;

            case 'Subscription':
                $user = $model->user;
                $plan = $model->plan;
                $this->notify(
                    "💳 *New Subscription*\n\n" .
                    "👤 User: {$user->name}\n" .
                    "📦 Plan: {$plan->name}\n" .
                    "💰 Amount: AED {$model->amount}\n" .
                    "📅 Period: {$model->start_date} to {$model->end_date}\n" .
                    "🆔 ID: `{$model->id}`"
                );
                break;

            case 'SupportTicket':
                $this->notify(
                    "🎫 *New Support Ticket*\n\n" .
                    "👤 Name: {$model->name}\n" .
                    "📧 Email: {$model->email}\n" .
                    "🏷️ Category: {$model->category}\n" .
                    "⚡ Priority: {$model->priority}\n" .
                    "📝 Message: " . substr($model->message, 0, 100) . "...\n" .
                    "🆔 ID: `{$model->id}`\n\n" .
                    "👉 Use /support to view and manage"
                );
                break;

            case 'WalletRechargeRequest':
                $user = $model->user;
                $this->notify(
                    "💰 *New Wallet Recharge Request*\n\n" .
                    "👤 User: {$user->name}\n" .
                    "💵 Amount: AED {$model->amount}\n" .
                    "🏦 Method: {$model->payment_method}\n" .
                    "📝 Notes: {$model->notes}\n" .
                    "🆔 ID: `{$model->id}`\n\n" .
                    "👉 Use /wallet to approve or reject"
                );
                break;

            case 'WebsiteRequest':
                $this->notify(
                    "🌐 *New Website Request*\n\n" .
                    "👤 Name: {$model->name}\n" .
                    "📧 Email: {$model->email}\n" .
                    "📱 Phone: {$model->phone}\n" .
                    "💼 Company: {$model->company_name}\n" .
                    "🌐 Type: {$model->website_type}\n" .
                    "💰 Budget: AED {$model->budget}\n" .
                    "🆔 ID: `{$model->id}`"
                );
                break;

            case 'SponsoredAdRequest':
                $this->notify(
                    "📢 *New Sponsored Ad Request*\n\n" .
                    "👤 Name: {$model->name}\n" .
                    "📧 Email: {$model->email}\n" .
                    "📱 Platforms: " . implode(', ', $model->platforms ?? []) . "\n" .
                    "💰 Budget: AED {$model->budget}\n" .
                    "🎯 Objective: {$model->objective}\n" .
                    "🆔 ID: `{$model->id}`"
                );
                break;
        }
    }

    /**
     * Handle updated event for important status changes
     */
    public function updated($model): void
    {
        $modelClass = class_basename($model);

        // Notify about subscription status changes
        if ($modelClass === 'Subscription' && $model->isDirty('status')) {
            $user = $model->user;
            $oldStatus = $model->getOriginal('status');
            $newStatus = $model->status;

            $this->notify(
                "📝 *Subscription Status Changed*\n\n" .
                "👤 User: {$user->name}\n" .
                "🆔 Subscription ID: `{$model->id}`\n" .
                "📊 Status: {$oldStatus} → {$newStatus}\n" .
                "💰 Amount: AED {$model->amount}"
            );
        }

        // Notify about user status changes (ban/activate)
        if ($modelClass === 'User' && $model->isDirty('status')) {
            $oldStatus = $model->getOriginal('status');
            $newStatus = $model->status;

            $emoji = $newStatus === 'active' ? '✅' : '🔴';
            $this->notify(
                "{$emoji} *User Status Changed*\n\n" .
                "👤 Name: {$model->name}\n" .
                "📧 Email: {$model->email}\n" .
                "📊 Status: {$oldStatus} → {$newStatus}\n" .
                "🆔 ID: `{$model->id}`"
            );
        }
    }

    /**
     * Handle deleted event
     */
    public function deleted($model): void
    {
        $modelClass = class_basename($model);

        // Only notify for important deletions
        if (in_array($modelClass, ['User', 'Subscription'])) {
            $this->notify(
                "🗑️ *{$modelClass} Deleted*\n\n" .
                "🆔 ID: `{$model->id}`\n" .
                "📅 Deleted at: " . now()->format('Y-m-d H:i')
            );
        }
    }
}
