<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Http;

class AdminSettingsController extends Controller
{
    /**
     * Get all settings grouped by category
     */
    public function index()
    {
        $settings = Setting::all()->groupBy('group');

        return response()->json([
            'success' => true,
            'data' => $settings,
        ]);
    }

    /**
     * Update settings
     */
    public function update(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'settings' => 'required|array',
            'settings.*.key' => 'required|string',
            'settings.*.value' => 'nullable',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        foreach ($request->settings as $setting) {
            Setting::updateOrCreate(
                ['key' => $setting['key']],
                [
                    'value' => $setting['value'],
                    'group' => $setting['group'] ?? 'general',
                    'type' => $setting['type'] ?? 'string',
                    'is_public' => $setting['is_public'] ?? false,
                ]
            );
        }

        // Clear settings cache
        Cache::forget('app_settings');

        return response()->json([
            'success' => true,
            'message' => 'Settings updated successfully',
        ]);
    }

    /**
     * Get API keys status (without revealing actual keys)
     */
    public function getApiKeysStatus()
    {
        $keys = [
            // AI Services
            'openai' => [
                'name' => 'OpenAI (GPT-4, DALL-E)',
                'configured' => !empty(env('OPENAI_API_KEY')) && !str_contains(env('OPENAI_API_KEY'), 'your_'),
                'env_key' => 'OPENAI_API_KEY',
            ],
            'claude' => [
                'name' => 'Claude AI (Anthropic)',
                'configured' => !empty(env('CLAUDE_API_KEY')) && !str_contains(env('CLAUDE_API_KEY'), 'your_'),
                'env_key' => 'CLAUDE_API_KEY',
            ],
            'gemini' => [
                'name' => 'Google Gemini',
                'configured' => !empty(env('GOOGLE_AI_API_KEY')) && !str_contains(env('GOOGLE_AI_API_KEY'), 'your_'),
                'env_key' => 'GOOGLE_AI_API_KEY',
            ],
            'stability_ai' => [
                'name' => 'Stability AI',
                'configured' => !empty(env('STABILITY_AI_API_KEY')) && !str_contains(env('STABILITY_AI_API_KEY'), 'your_'),
                'env_key' => 'STABILITY_AI_API_KEY',
            ],
            'runway' => [
                'name' => 'Runway ML',
                'configured' => !empty(env('RUNWAY_API_KEY')) && !str_contains(env('RUNWAY_API_KEY'), 'your_'),
                'env_key' => 'RUNWAY_API_KEY',
            ],
            'replicate' => [
                'name' => 'Replicate',
                'configured' => !empty(env('REPLICATE_API_TOKEN')) && !str_contains(env('REPLICATE_API_TOKEN'), 'your_'),
                'env_key' => 'REPLICATE_API_TOKEN',
            ],

            // Payment Gateways
            'stripe' => [
                'name' => 'Stripe',
                'configured' => !empty(env('STRIPE_SECRET_KEY')) && !str_contains(env('STRIPE_SECRET_KEY'), 'your_'),
                'env_key' => 'STRIPE_SECRET_KEY',
            ],
            'paymob' => [
                'name' => 'Paymob',
                'configured' => !empty(env('PAYMOB_API_KEY')) && !str_contains(env('PAYMOB_API_KEY'), 'your_'),
                'env_key' => 'PAYMOB_API_KEY',
            ],
            'paypal' => [
                'name' => 'PayPal',
                'configured' => !empty(env('PAYPAL_CLIENT_ID')) && !str_contains(env('PAYPAL_CLIENT_ID'), 'your_'),
                'env_key' => 'PAYPAL_CLIENT_ID',
            ],

            // Social Media
            'facebook' => [
                'name' => 'Facebook',
                'configured' => !empty(env('FACEBOOK_APP_ID')) && !str_contains(env('FACEBOOK_APP_ID'), 'your_'),
                'env_key' => 'FACEBOOK_APP_ID',
            ],
            'twitter' => [
                'name' => 'Twitter/X',
                'configured' => !empty(env('TWITTER_API_KEY')) && !str_contains(env('TWITTER_API_KEY'), 'your_'),
                'env_key' => 'TWITTER_API_KEY',
            ],
            'linkedin' => [
                'name' => 'LinkedIn',
                'configured' => !empty(env('LINKEDIN_CLIENT_ID')) && !str_contains(env('LINKEDIN_CLIENT_ID'), 'your_'),
                'env_key' => 'LINKEDIN_CLIENT_ID',
            ],

            // Other Services
            'cloudinary' => [
                'name' => 'Cloudinary',
                'configured' => !empty(env('CLOUDINARY_CLOUD_NAME')) && !str_contains(env('CLOUDINARY_CLOUD_NAME'), 'your_'),
                'env_key' => 'CLOUDINARY_CLOUD_NAME',
            ],
            'firebase' => [
                'name' => 'Firebase',
                'configured' => !empty(env('FIREBASE_API_KEY')) && !str_contains(env('FIREBASE_API_KEY'), 'your_'),
                'env_key' => 'FIREBASE_API_KEY',
            ],
            'telegram' => [
                'name' => 'Telegram Bot',
                'configured' => !empty(env('TELEGRAM_BOT_TOKEN')) && !str_contains(env('TELEGRAM_BOT_TOKEN'), 'your_'),
                'env_key' => 'TELEGRAM_BOT_TOKEN',
            ],
            'ayrshare' => [
                'name' => 'Ayrshare',
                'configured' => !empty(env('AYRSHARE_API_KEY')) && !str_contains(env('AYRSHARE_API_KEY'), 'your_'),
                'env_key' => 'AYRSHARE_API_KEY',
            ],
        ];

        $configuredCount = collect($keys)->where('configured', true)->count();
        $totalCount = count($keys);

        return response()->json([
            'success' => true,
            'data' => [
                'keys' => $keys,
                'summary' => [
                    'configured' => $configuredCount,
                    'total' => $totalCount,
                    'percentage' => round(($configuredCount / $totalCount) * 100, 1),
                ],
            ],
        ]);
    }

    /**
     * Test API key connectivity
     */
    public function testApiKey(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'provider' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $provider = $request->provider;
        $result = ['provider' => $provider, 'status' => 'unknown', 'message' => ''];

        try {
            switch ($provider) {
                case 'openai':
                    $response = Http::withHeaders([
                        'Authorization' => 'Bearer ' . env('OPENAI_API_KEY'),
                    ])->get('https://api.openai.com/v1/models');
                    $result['status'] = $response->successful() ? 'connected' : 'failed';
                    $result['message'] = $response->successful() ? 'OpenAI API connected successfully' : 'Failed to connect';
                    break;

                case 'gemini':
                    $key = env('GOOGLE_AI_API_KEY');
                    $response = Http::get("https://generativelanguage.googleapis.com/v1beta/models?key={$key}");
                    $result['status'] = $response->successful() ? 'connected' : 'failed';
                    $result['message'] = $response->successful() ? 'Gemini API connected successfully' : 'Failed to connect';
                    break;

                case 'stability_ai':
                    $response = Http::withHeaders([
                        'Authorization' => 'Bearer ' . env('STABILITY_AI_API_KEY'),
                    ])->get('https://api.stability.ai/v1/engines/list');
                    $result['status'] = $response->successful() ? 'connected' : 'failed';
                    $result['message'] = $response->successful() ? 'Stability AI connected successfully' : 'Failed to connect';
                    if ($response->successful()) {
                        $result['credits'] = 'Check dashboard for credit balance';
                    }
                    break;

                case 'runway':
                    $response = Http::withHeaders([
                        'Authorization' => 'Bearer ' . env('RUNWAY_API_KEY'),
                        'X-Runway-Version' => '2024-11-06',
                    ])->get('https://api.dev.runwayml.com/v1/tasks');
                    $result['status'] = $response->status() !== 401 ? 'connected' : 'failed';
                    $result['message'] = $response->status() !== 401 ? 'Runway ML API key is valid' : 'Invalid API key';
                    break;

                case 'replicate':
                    $response = Http::withHeaders([
                        'Authorization' => 'Bearer ' . env('REPLICATE_API_TOKEN'),
                    ])->get('https://api.replicate.com/v1/models');
                    $result['status'] = $response->successful() ? 'connected' : 'failed';
                    $result['message'] = $response->successful() ? 'Replicate API connected successfully' : 'Failed to connect';
                    break;

                case 'cloudinary':
                    $cloudName = env('CLOUDINARY_CLOUD_NAME');
                    $apiKey = env('CLOUDINARY_API_KEY');
                    $apiSecret = env('CLOUDINARY_API_SECRET');
                    if ($cloudName && $apiKey && $apiSecret) {
                        $result['status'] = 'configured';
                        $result['message'] = 'Cloudinary credentials configured';
                    } else {
                        $result['status'] = 'failed';
                        $result['message'] = 'Missing Cloudinary credentials';
                    }
                    break;

                case 'stripe':
                    $response = Http::withHeaders([
                        'Authorization' => 'Bearer ' . env('STRIPE_SECRET_KEY'),
                    ])->get('https://api.stripe.com/v1/balance');
                    $result['status'] = $response->successful() ? 'connected' : 'failed';
                    $result['message'] = $response->successful() ? 'Stripe API connected successfully' : 'Failed to connect';
                    if ($response->successful()) {
                        $balance = $response->json();
                        $result['balance'] = $balance['available'][0]['amount'] ?? 0;
                    }
                    break;

                case 'paymob':
                    $response = Http::withHeaders([
                        'Authorization' => 'Token ' . env('PAYMOB_SECRET_KEY'),
                    ])->get('https://uae.paymob.com/api/acceptance/payment_keys');
                    $result['status'] = $response->status() !== 401 ? 'connected' : 'failed';
                    $result['message'] = $response->status() !== 401 ? 'Paymob API connected' : 'Invalid API key';
                    break;

                case 'paypal':
                    $clientId = env('PAYPAL_CLIENT_ID');
                    $secret = env('PAYPAL_SECRET');
                    if ($clientId && $secret) {
                        $response = Http::withBasicAuth($clientId, $secret)
                            ->asForm()
                            ->post('https://api-m.sandbox.paypal.com/v1/oauth2/token', [
                                'grant_type' => 'client_credentials',
                            ]);
                        $result['status'] = $response->successful() ? 'connected' : 'failed';
                        $result['message'] = $response->successful() ? 'PayPal API connected' : 'Failed to connect';
                    } else {
                        $result['status'] = 'failed';
                        $result['message'] = 'Missing PayPal credentials';
                    }
                    break;

                case 'claude':
                    $response = Http::withHeaders([
                        'x-api-key' => env('CLAUDE_API_KEY'),
                        'anthropic-version' => '2023-06-01',
                    ])->get('https://api.anthropic.com/v1/models');
                    $result['status'] = $response->status() !== 401 ? 'connected' : 'failed';
                    $result['message'] = $response->status() !== 401 ? 'Claude API connected' : 'Invalid API key';
                    break;

                case 'telegram':
                    $token = env('TELEGRAM_BOT_TOKEN');
                    if ($token) {
                        $response = Http::get("https://api.telegram.org/bot{$token}/getMe");
                        $result['status'] = $response->successful() ? 'connected' : 'failed';
                        $result['message'] = $response->successful() ? 'Telegram Bot connected' : 'Invalid bot token';
                        if ($response->successful()) {
                            $result['bot_name'] = $response->json()['result']['username'] ?? 'Unknown';
                        }
                    } else {
                        $result['status'] = 'failed';
                        $result['message'] = 'Missing Telegram bot token';
                    }
                    break;

                case 'firebase':
                    $apiKey = env('FIREBASE_API_KEY');
                    $projectId = env('FIREBASE_PROJECT_ID');
                    if ($apiKey && $projectId) {
                        $result['status'] = 'configured';
                        $result['message'] = 'Firebase credentials configured';
                        $result['project_id'] = $projectId;
                    } else {
                        $result['status'] = 'failed';
                        $result['message'] = 'Missing Firebase credentials';
                    }
                    break;

                case 'ayrshare':
                    $response = Http::withHeaders([
                        'Authorization' => 'Bearer ' . env('AYRSHARE_API_KEY'),
                    ])->get('https://api.ayrshare.com/api/user');
                    $result['status'] = $response->successful() ? 'connected' : 'failed';
                    $result['message'] = $response->successful() ? 'Ayrshare API connected' : 'Failed to connect';
                    break;

                case 'twilio':
                    $sid = env('TWILIO_SID');
                    $token = env('TWILIO_AUTH_TOKEN');
                    if ($sid && $token) {
                        $response = Http::withBasicAuth($sid, $token)
                            ->get("https://api.twilio.com/2010-04-01/Accounts/{$sid}.json");
                        $result['status'] = $response->successful() ? 'connected' : 'failed';
                        $result['message'] = $response->successful() ? 'Twilio API connected' : 'Failed to connect';
                    } else {
                        $result['status'] = 'failed';
                        $result['message'] = 'Missing Twilio credentials';
                    }
                    break;

                case 'd-id':
                    $response = Http::withHeaders([
                        'Authorization' => 'Basic ' . env('DID_API_KEY'),
                    ])->get('https://api.d-id.com/credits');
                    $result['status'] = $response->successful() ? 'connected' : 'failed';
                    $result['message'] = $response->successful() ? 'D-ID API connected' : 'Failed to connect';
                    if ($response->successful()) {
                        $result['credits'] = $response->json()['remaining'] ?? 0;
                    }
                    break;

                case 'facebook':
                    $appId = env('FACEBOOK_APP_ID');
                    $appSecret = env('FACEBOOK_APP_SECRET');
                    if ($appId && $appSecret) {
                        $result['status'] = 'configured';
                        $result['message'] = 'Facebook App credentials configured';
                    } else {
                        $result['status'] = 'failed';
                        $result['message'] = 'Missing Facebook App credentials';
                    }
                    break;

                case 'twitter':
                    $apiKey = env('TWITTER_API_KEY');
                    $apiSecret = env('TWITTER_API_SECRET');
                    if ($apiKey && $apiSecret) {
                        $result['status'] = 'configured';
                        $result['message'] = 'Twitter API credentials configured';
                    } else {
                        $result['status'] = 'failed';
                        $result['message'] = 'Missing Twitter API credentials';
                    }
                    break;

                case 'linkedin':
                    $clientId = env('LINKEDIN_CLIENT_ID');
                    $clientSecret = env('LINKEDIN_CLIENT_SECRET');
                    if ($clientId && $clientSecret) {
                        $result['status'] = 'configured';
                        $result['message'] = 'LinkedIn API credentials configured';
                    } else {
                        $result['status'] = 'failed';
                        $result['message'] = 'Missing LinkedIn API credentials';
                    }
                    break;

                default:
                    $result['status'] = 'not_testable';
                    $result['message'] = 'API testing not implemented for this provider';
            }
        } catch (\Exception $e) {
            $result['status'] = 'error';
            $result['message'] = 'Error testing API: ' . $e->getMessage();
        }

        return response()->json([
            'success' => true,
            'data' => $result,
        ]);
    }

    /**
     * Get system health status
     */
    public function systemHealth()
    {
        $health = [
            'database' => $this->checkDatabase(),
            'cache' => $this->checkCache(),
            'storage' => $this->checkStorage(),
            'queue' => $this->checkQueue(),
        ];

        $allHealthy = collect($health)->every(fn($item) => $item['status'] === 'healthy');

        return response()->json([
            'success' => true,
            'data' => [
                'overall_status' => $allHealthy ? 'healthy' : 'degraded',
                'checks' => $health,
                'timestamp' => now()->toISOString(),
                'environment' => app()->environment(),
                'php_version' => phpversion(),
                'laravel_version' => app()->version(),
            ],
        ]);
    }

    private function checkDatabase()
    {
        try {
            \DB::connection()->getPdo();
            $tables = \DB::select('SHOW TABLES');
            return [
                'status' => 'healthy',
                'message' => 'Database connected',
                'tables_count' => count($tables),
            ];
        } catch (\Exception $e) {
            return [
                'status' => 'unhealthy',
                'message' => 'Database connection failed: ' . $e->getMessage(),
            ];
        }
    }

    private function checkCache()
    {
        try {
            Cache::put('health_check', 'ok', 10);
            $value = Cache::get('health_check');
            Cache::forget('health_check');
            return [
                'status' => $value === 'ok' ? 'healthy' : 'unhealthy',
                'message' => $value === 'ok' ? 'Cache working' : 'Cache not working',
                'driver' => config('cache.default'),
            ];
        } catch (\Exception $e) {
            return [
                'status' => 'unhealthy',
                'message' => 'Cache error: ' . $e->getMessage(),
            ];
        }
    }

    private function checkStorage()
    {
        try {
            $storagePath = storage_path('app');
            $freeSpace = disk_free_space($storagePath);
            $totalSpace = disk_total_space($storagePath);
            $usedPercentage = round((1 - ($freeSpace / $totalSpace)) * 100, 1);

            return [
                'status' => $usedPercentage < 90 ? 'healthy' : 'warning',
                'message' => "Storage {$usedPercentage}% used",
                'free_space_gb' => round($freeSpace / 1024 / 1024 / 1024, 2),
                'total_space_gb' => round($totalSpace / 1024 / 1024 / 1024, 2),
                'used_percentage' => $usedPercentage,
            ];
        } catch (\Exception $e) {
            return [
                'status' => 'unknown',
                'message' => 'Cannot check storage: ' . $e->getMessage(),
            ];
        }
    }

    private function checkQueue()
    {
        try {
            // Check if queue is configured
            $driver = config('queue.default');
            return [
                'status' => 'healthy',
                'message' => 'Queue configured',
                'driver' => $driver,
            ];
        } catch (\Exception $e) {
            return [
                'status' => 'unknown',
                'message' => 'Queue status unknown',
            ];
        }
    }

    /**
     * Clear application cache
     */
    public function clearCache(Request $request)
    {
        $types = $request->get('types', ['all']);

        $cleared = [];

        if (in_array('all', $types) || in_array('config', $types)) {
            Artisan::call('config:clear');
            $cleared[] = 'config';
        }

        if (in_array('all', $types) || in_array('cache', $types)) {
            Artisan::call('cache:clear');
            $cleared[] = 'cache';
        }

        if (in_array('all', $types) || in_array('route', $types)) {
            Artisan::call('route:clear');
            $cleared[] = 'route';
        }

        if (in_array('all', $types) || in_array('view', $types)) {
            Artisan::call('view:clear');
            $cleared[] = 'view';
        }

        return response()->json([
            'success' => true,
            'message' => 'Cache cleared successfully',
            'cleared' => $cleared,
        ]);
    }

    /**
     * Get application logs (recent entries)
     */
    public function getLogs(Request $request)
    {
        $lines = $request->get('lines', 100);
        $logFile = storage_path('logs/laravel.log');

        if (!file_exists($logFile)) {
            return response()->json([
                'success' => true,
                'data' => [],
                'message' => 'No log file found',
            ]);
        }

        // Read last N lines
        $file = new \SplFileObject($logFile, 'r');
        $file->seek(PHP_INT_MAX);
        $totalLines = $file->key();

        $startLine = max(0, $totalLines - $lines);
        $file->seek($startLine);

        $logs = [];
        while (!$file->eof()) {
            $line = $file->fgets();
            if (!empty(trim($line))) {
                $logs[] = $line;
            }
        }

        return response()->json([
            'success' => true,
            'data' => $logs,
            'total_lines' => $totalLines,
        ]);
    }

    /**
     * Get environment info (safe version)
     */
    public function getEnvironmentInfo()
    {
        return response()->json([
            'success' => true,
            'data' => [
                'app_name' => config('app.name'),
                'app_env' => app()->environment(),
                'app_debug' => config('app.debug'),
                'app_url' => config('app.url'),
                'php_version' => phpversion(),
                'laravel_version' => app()->version(),
                'timezone' => config('app.timezone'),
                'locale' => config('app.locale'),
                'database_driver' => config('database.default'),
                'cache_driver' => config('cache.default'),
                'queue_driver' => config('queue.default'),
                'session_driver' => config('session.driver'),
                'mail_driver' => config('mail.default'),
            ],
        ]);
    }
}
