<?php

namespace App\Services;

use App\Models\User;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use App\Models\Wallet;
use App\Models\SupportTicket;
use App\Models\WebsiteRequest;
use App\Models\SponsoredAdRequest;
use App\Models\WalletRechargeRequest;
use App\Models\SocialAccount;
use App\Models\AutoScheduledPost;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class TelegramAdminBotService
{
    private string $botToken;
    private string $apiUrl;
    private array $adminChatIds;

    public function __construct()
    {
        $this->botToken = config('services.telegram.bot_token', env('TELEGRAM_BOT_TOKEN'));
        $this->apiUrl = "https://api.telegram.org/bot{$this->botToken}";
        $this->adminChatIds = explode(',', env('TELEGRAM_ADMIN_CHAT_IDS', ''));
    }

    /**
     * Handle incoming webhook updates
     */
    public function handleUpdate(array $update): array
    {
        try {
            // Handle callback queries (button clicks)
            if (isset($update['callback_query'])) {
                return $this->handleCallbackQuery($update['callback_query']);
            }

            // Handle messages
            if (isset($update['message'])) {
                return $this->handleMessage($update['message']);
            }

            return ['status' => 'ok'];
        } catch (\Exception $e) {
            Log::error('Telegram bot error', ['error' => $e->getMessage()]);
            return ['status' => 'error', 'message' => $e->getMessage()];
        }
    }

    /**
     * Handle incoming messages
     */
    private function handleMessage(array $message): array
    {
        $chatId = $message['chat']['id'];
        $text = $message['text'] ?? '';

        // Check if user is admin
        if (!$this->isAdmin($chatId)) {
            $this->sendMessage($chatId, "⛔ Unauthorized. This bot is for admins only.");
            return ['status' => 'unauthorized'];
        }

        // Handle commands
        if (str_starts_with($text, '/')) {
            return $this->handleCommand($chatId, $text);
        }

        // Default response
        $this->sendMessage($chatId, "Use /menu to see available commands.");
        return ['status' => 'ok'];
    }

    /**
     * Handle bot commands
     */
    private function handleCommand(int $chatId, string $command): array
    {
        $cmd = explode(' ', $command)[0];

        switch ($cmd) {
            case '/start':
            case '/menu':
                return $this->showMainMenu($chatId);

            case '/stats':
                return $this->showDashboardStats($chatId);

            case '/users':
                return $this->showUsersMenu($chatId);

            case '/subscriptions':
                return $this->showSubscriptionsMenu($chatId);

            case '/support':
                return $this->showSupportTickets($chatId);

            case '/requests':
                return $this->showRequestsMenu($chatId);

            case '/wallet':
                return $this->showWalletRequests($chatId);

            case '/settings':
                return $this->showSettingsMenu($chatId);

            case '/posts':
                return $this->showScheduledPosts($chatId);

            default:
                $this->sendMessage($chatId, "❌ Unknown command. Use /menu to see available commands.");
                return ['status' => 'unknown_command'];
        }
    }

    /**
     * Handle callback queries (button clicks)
     */
    private function handleCallbackQuery(array $callback): array
    {
        $chatId = $callback['message']['chat']['id'];
        $messageId = $callback['message']['message_id'];
        $data = $callback['data'];

        // Answer callback to remove loading state
        $this->answerCallbackQuery($callback['id']);

        // Parse callback data
        [$action, $id] = explode(':', $data . ':');

        switch ($action) {
            case 'approve_support':
                return $this->approveSupportTicket($chatId, $messageId, $id);

            case 'reject_support':
                return $this->rejectSupportTicket($chatId, $messageId, $id);

            case 'approve_wallet':
                return $this->approveWalletRecharge($chatId, $messageId, $id);

            case 'reject_wallet':
                return $this->rejectWalletRecharge($chatId, $messageId, $id);

            case 'approve_website':
                return $this->approveWebsiteRequest($chatId, $messageId, $id);

            case 'reject_website':
                return $this->rejectWebsiteRequest($chatId, $messageId, $id);

            case 'view_user':
                return $this->showUserDetails($chatId, $id);

            case 'ban_user':
                return $this->banUser($chatId, $messageId, $id);

            case 'activate_user':
                return $this->activateUser($chatId, $messageId, $id);

            default:
                $this->sendMessage($chatId, "❌ Unknown action.");
                return ['status' => 'unknown_action'];
        }
    }

    /**
     * Show main menu
     */
    private function showMainMenu(int $chatId): array
    {
        $keyboard = [
            [
                ['text' => '📊 Dashboard Stats', 'callback_data' => 'stats'],
                ['text' => '👥 Users', 'callback_data' => 'users'],
            ],
            [
                ['text' => '💳 Subscriptions', 'callback_data' => 'subscriptions'],
                ['text' => '🎫 Support Tickets', 'callback_data' => 'support'],
            ],
            [
                ['text' => '💰 Wallet Requests', 'callback_data' => 'wallet'],
                ['text' => '📝 Requests', 'callback_data' => 'requests'],
            ],
            [
                ['text' => '📅 Scheduled Posts', 'callback_data' => 'posts'],
                ['text' => '⚙️ Settings', 'callback_data' => 'settings'],
            ],
        ];

        $message = "🤖 *MediaPro Social Admin Panel*\n\n"
                 . "Welcome! Choose an option below to manage the platform:\n\n"
                 . "📊 *Dashboard Stats* - View system statistics\n"
                 . "👥 *Users* - Manage users\n"
                 . "💳 *Subscriptions* - Manage subscriptions\n"
                 . "🎫 *Support* - Handle support tickets\n"
                 . "💰 *Wallet* - Approve wallet recharges\n"
                 . "📝 *Requests* - Website & Ad requests\n"
                 . "📅 *Posts* - View scheduled posts\n"
                 . "⚙️ *Settings* - System settings";

        $this->sendMessage($chatId, $message, $keyboard);
        return ['status' => 'menu_sent'];
    }

    /**
     * Show dashboard statistics
     */
    private function showDashboardStats(int $chatId): array
    {
        $stats = [
            'total_users' => User::count(),
            'active_users' => User::where('status', 'active')->count(),
            'total_subscriptions' => Subscription::where('status', 'active')->count(),
            'total_revenue' => Subscription::where('status', 'active')->sum('amount'),
            'pending_support' => SupportTicket::where('status', 'open')->count(),
            'pending_wallet' => WalletRechargeRequest::where('status', 'pending')->count(),
            'total_accounts' => SocialAccount::count(),
            'scheduled_posts' => AutoScheduledPost::where('status', 'active')->count(),
        ];

        $message = "📊 *Dashboard Statistics*\n\n"
                 . "👥 *Users*\n"
                 . "├ Total: {$stats['total_users']}\n"
                 . "└ Active: {$stats['active_users']}\n\n"
                 . "💳 *Subscriptions*\n"
                 . "├ Active: {$stats['total_subscriptions']}\n"
                 . "└ Revenue: AED {$stats['total_revenue']}\n\n"
                 . "🎫 *Support*\n"
                 . "└ Pending: {$stats['pending_support']}\n\n"
                 . "💰 *Wallet*\n"
                 . "└ Pending: {$stats['pending_wallet']}\n\n"
                 . "📱 *Social Accounts*\n"
                 . "└ Connected: {$stats['total_accounts']}\n\n"
                 . "📅 *Scheduled Posts*\n"
                 . "└ Active: {$stats['scheduled_posts']}";

        $keyboard = [
            [['text' => '🔄 Refresh', 'callback_data' => 'stats']],
            [['text' => '« Back to Menu', 'callback_data' => 'menu']],
        ];

        $this->sendMessage($chatId, $message, $keyboard);
        return ['status' => 'stats_sent'];
    }

    /**
     * Show users menu
     */
    private function showUsersMenu(int $chatId): array
    {
        $recentUsers = User::latest()->take(5)->get();

        $message = "👥 *Recent Users*\n\n";

        foreach ($recentUsers as $user) {
            $status = $user->status === 'active' ? '✅' : '🔴';
            $message .= "{$status} *{$user->name}*\n"
                     . "   Email: {$user->email}\n"
                     . "   Phone: {$user->phone}\n"
                     . "   ID: `{$user->id}`\n\n";
        }

        $keyboard = [
            [['text' => '🔍 Search User', 'callback_data' => 'search_user']],
            [['text' => '« Back to Menu', 'callback_data' => 'menu']],
        ];

        $this->sendMessage($chatId, $message, $keyboard);
        return ['status' => 'users_sent'];
    }

    /**
     * Show support tickets
     */
    private function showSupportTickets(int $chatId): array
    {
        $tickets = SupportTicket::where('status', 'open')
            ->orWhere('status', 'pending')
            ->latest()
            ->take(5)
            ->get();

        if ($tickets->isEmpty()) {
            $this->sendMessage($chatId, "✅ No pending support tickets!");
            return ['status' => 'no_tickets'];
        }

        foreach ($tickets as $ticket) {
            $message = "🎫 *Support Ticket #{$ticket->id}*\n\n"
                     . "👤 *User:* {$ticket->name}\n"
                     . "📧 *Email:* {$ticket->email}\n"
                     . "📱 *Phone:* {$ticket->phone}\n"
                     . "🏷️ *Category:* {$ticket->category}\n"
                     . "⚡ *Priority:* {$ticket->priority}\n\n"
                     . "📝 *Message:*\n{$ticket->message}\n\n"
                     . "📅 *Date:* {$ticket->created_at->format('Y-m-d H:i')}";

            $keyboard = [
                [
                    ['text' => '✅ Approve', 'callback_data' => "approve_support:{$ticket->id}"],
                    ['text' => '❌ Reject', 'callback_data' => "reject_support:{$ticket->id}"],
                ],
            ];

            $this->sendMessage($chatId, $message, $keyboard);
        }

        return ['status' => 'tickets_sent', 'count' => $tickets->count()];
    }

    /**
     * Show wallet recharge requests
     */
    private function showWalletRequests(int $chatId): array
    {
        $requests = WalletRechargeRequest::where('status', 'pending')
            ->latest()
            ->take(5)
            ->get();

        if ($requests->isEmpty()) {
            $this->sendMessage($chatId, "✅ No pending wallet requests!");
            return ['status' => 'no_requests'];
        }

        foreach ($requests as $request) {
            $user = User::find($request->user_id);

            $message = "💰 *Wallet Recharge Request #{$request->id}*\n\n"
                     . "👤 *User:* {$user->name}\n"
                     . "📧 *Email:* {$user->email}\n"
                     . "💵 *Amount:* AED {$request->amount}\n"
                     . "🏦 *Method:* {$request->payment_method}\n\n"
                     . "📝 *Notes:* {$request->notes}\n\n"
                     . "📅 *Date:* {$request->created_at->format('Y-m-d H:i')}";

            $keyboard = [
                [
                    ['text' => '✅ Approve', 'callback_data' => "approve_wallet:{$request->id}"],
                    ['text' => '❌ Reject', 'callback_data' => "reject_wallet:{$request->id}"],
                ],
            ];

            $this->sendMessage($chatId, $message, $keyboard);
        }

        return ['status' => 'wallet_requests_sent', 'count' => $requests->count()];
    }

    /**
     * Show requests menu
     */
    private function showRequestsMenu(int $chatId): array
    {
        $websiteRequests = WebsiteRequest::where('status', 'pending')->count();
        $adRequests = SponsoredAdRequest::where('status', 'pending')->count();

        $message = "📝 *Requests Management*\n\n"
                 . "🌐 Website Requests: {$websiteRequests} pending\n"
                 . "📢 Ad Requests: {$adRequests} pending";

        $keyboard = [
            [['text' => '🌐 View Website Requests', 'callback_data' => 'website_requests']],
            [['text' => '📢 View Ad Requests', 'callback_data' => 'ad_requests']],
            [['text' => '« Back to Menu', 'callback_data' => 'menu']],
        ];

        $this->sendMessage($chatId, $message, $keyboard);
        return ['status' => 'requests_menu_sent'];
    }

    /**
     * Show subscriptions menu
     */
    private function showSubscriptionsMenu(int $chatId): array
    {
        $plans = SubscriptionPlan::active()->get();
        $activeSubscriptions = Subscription::where('status', 'active')->count();
        $totalRevenue = Subscription::where('status', 'active')->sum('amount');

        $message = "💳 *Subscriptions Overview*\n\n"
                 . "📊 Active Subscriptions: {$activeSubscriptions}\n"
                 . "💰 Total Revenue: AED {$totalRevenue}\n\n"
                 . "*Available Plans:*\n\n";

        foreach ($plans as $plan) {
            $subscribers = Subscription::where('plan_id', $plan->id)
                ->where('status', 'active')
                ->count();

            $message .= "• *{$plan->name}* (AED {$plan->price}/{$plan->type})\n"
                     . "  Subscribers: {$subscribers}\n\n";
        }

        $keyboard = [
            [['text' => '« Back to Menu', 'callback_data' => 'menu']],
        ];

        $this->sendMessage($chatId, $message, $keyboard);
        return ['status' => 'subscriptions_sent'];
    }

    /**
     * Show scheduled posts
     */
    private function showScheduledPosts(int $chatId): array
    {
        $posts = AutoScheduledPost::where('status', 'active')
            ->latest()
            ->take(10)
            ->get();

        $message = "📅 *Scheduled Posts ({$posts->count()})*\n\n";

        foreach ($posts as $post) {
            $user = User::find($post->user_id);
            $message .= "• {$post->title}\n"
                     . "  User: {$user->name}\n"
                     . "  Next: {$post->next_post_at}\n\n";
        }

        $keyboard = [
            [['text' => '« Back to Menu', 'callback_data' => 'menu']],
        ];

        $this->sendMessage($chatId, $message, $keyboard);
        return ['status' => 'posts_sent'];
    }

    /**
     * Show settings menu
     */
    private function showSettingsMenu(int $chatId): array
    {
        $message = "⚙️ *System Settings*\n\n"
                 . "Configure system-wide settings here.";

        $keyboard = [
            [['text' => '« Back to Menu', 'callback_data' => 'menu']],
        ];

        $this->sendMessage($chatId, $message, $keyboard);
        return ['status' => 'settings_sent'];
    }

    /**
     * Approve support ticket
     */
    private function approveSupportTicket(int $chatId, int $messageId, string $ticketId): array
    {
        $ticket = SupportTicket::find($ticketId);
        if (!$ticket) {
            $this->editMessage($chatId, $messageId, "❌ Ticket not found.");
            return ['status' => 'not_found'];
        }

        $ticket->update(['status' => 'in_progress']);
        $this->editMessage($chatId, $messageId, "✅ Ticket #{$ticketId} approved and moved to in progress.");

        return ['status' => 'approved'];
    }

    /**
     * Reject support ticket
     */
    private function rejectSupportTicket(int $chatId, int $messageId, string $ticketId): array
    {
        $ticket = SupportTicket::find($ticketId);
        if (!$ticket) {
            $this->editMessage($chatId, $messageId, "❌ Ticket not found.");
            return ['status' => 'not_found'];
        }

        $ticket->update(['status' => 'closed']);
        $this->editMessage($chatId, $messageId, "❌ Ticket #{$ticketId} rejected and closed.");

        return ['status' => 'rejected'];
    }

    /**
     * Approve wallet recharge
     */
    private function approveWalletRecharge(int $chatId, int $messageId, string $requestId): array
    {
        DB::beginTransaction();
        try {
            $request = WalletRechargeRequest::find($requestId);
            if (!$request) {
                $this->editMessage($chatId, $messageId, "❌ Request not found.");
                return ['status' => 'not_found'];
            }

            $wallet = Wallet::firstOrCreate(['user_id' => $request->user_id]);
            $wallet->balance += $request->amount;
            $wallet->save();

            $request->update(['status' => 'approved']);

            $this->editMessage($chatId, $messageId, "✅ Wallet recharge #{$requestId} approved! User credited with AED {$request->amount}.");

            DB::commit();
            return ['status' => 'approved'];
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Wallet approval error', ['error' => $e->getMessage()]);
            $this->editMessage($chatId, $messageId, "❌ Error approving request.");
            return ['status' => 'error'];
        }
    }

    /**
     * Reject wallet recharge
     */
    private function rejectWalletRecharge(int $chatId, int $messageId, string $requestId): array
    {
        $request = WalletRechargeRequest::find($requestId);
        if (!$request) {
            $this->editMessage($chatId, $messageId, "❌ Request not found.");
            return ['status' => 'not_found'];
        }

        $request->update(['status' => 'rejected']);
        $this->editMessage($chatId, $messageId, "❌ Wallet recharge #{$requestId} rejected.");

        return ['status' => 'rejected'];
    }

    /**
     * Send message via Telegram Bot API
     */
    private function sendMessage(int $chatId, string $text, ?array $keyboard = null): array
    {
        $data = [
            'chat_id' => $chatId,
            'text' => $text,
            'parse_mode' => 'Markdown',
        ];

        if ($keyboard) {
            $data['reply_markup'] = json_encode(['inline_keyboard' => $keyboard]);
        }

        $response = Http::post("{$this->apiUrl}/sendMessage", $data);
        return $response->json();
    }

    /**
     * Edit message
     */
    private function editMessage(int $chatId, int $messageId, string $text): array
    {
        $data = [
            'chat_id' => $chatId,
            'message_id' => $messageId,
            'text' => $text,
            'parse_mode' => 'Markdown',
        ];

        $response = Http::post("{$this->apiUrl}/editMessageText", $data);
        return $response->json();
    }

    /**
     * Answer callback query
     */
    private function answerCallbackQuery(string $callbackId, ?string $text = null): array
    {
        $data = ['callback_query_id' => $callbackId];
        if ($text) {
            $data['text'] = $text;
        }

        $response = Http::post("{$this->apiUrl}/answerCallbackQuery", $data);
        return $response->json();
    }

    /**
     * Check if user is admin
     */
    private function isAdmin(int $chatId): bool
    {
        return in_array((string)$chatId, $this->adminChatIds);
    }

    /**
     * Set webhook
     */
    public function setWebhook(string $webhookUrl): array
    {
        $response = Http::post("{$this->apiUrl}/setWebhook", [
            'url' => $webhookUrl,
            'allowed_updates' => ['message', 'callback_query'],
        ]);

        return $response->json();
    }

    /**
     * Send notification to all admins
     */
    public function notifyAdmins(string $message): void
    {
        foreach ($this->adminChatIds as $chatId) {
            if (!empty($chatId)) {
                $this->sendMessage((int)$chatId, $message);
            }
        }
    }
}
