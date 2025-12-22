<?php

return [

    /*
    |--------------------------------------------------------------------------
    | AI Boost Configuration
    |--------------------------------------------------------------------------
    |
    | Configure AI services performance settings for Laravel Boost AI
    |
    */

    // Cache Configuration
    'cache_enabled' => env('AI_CACHE_ENABLED', true),
    'cache_minutes' => env('AI_CACHE_MINUTES', 60),
    'cache_driver' => env('AI_CACHE_DRIVER', 'redis'),

    // Rate Limiting
    'rate_limit_enabled' => env('AI_RATE_LIMIT_ENABLED', true),
    'rate_limit_per_minute' => env('AI_RATE_LIMIT_PER_MINUTE', 30),
    'rate_limit_per_hour' => env('AI_RATE_LIMIT_PER_HOUR', 500),

    // Provider Priority (first available will be used)
    'provider_priority' => [
        'gemini',  // Fast and cost-effective
        'claude',  // High quality
        'openai',  // Fallback
    ],

    // Default Provider (optional override)
    'default_provider' => env('AI_DEFAULT_PROVIDER', null),

    // Request Timeout (seconds)
    'request_timeout' => env('AI_REQUEST_TIMEOUT', 60),

    // Retry Configuration
    'retry_enabled' => env('AI_RETRY_ENABLED', true),
    'retry_times' => env('AI_RETRY_TIMES', 2),
    'retry_delay' => env('AI_RETRY_DELAY', 1000), // milliseconds

    // Queue Configuration
    'queue_enabled' => env('AI_QUEUE_ENABLED', false),
    'queue_name' => env('AI_QUEUE_NAME', 'ai-requests'),
    'queue_connection' => env('AI_QUEUE_CONNECTION', 'redis'),

    // Content Optimization Settings
    'optimization' => [
        'max_content_length' => 5000,
        'min_content_length' => 10,
        'default_variations_count' => 3,
        'max_variations_count' => 5,
        'default_hashtags_count' => 10,
        'max_hashtags_count' => 30,
    ],

    // Supported Platforms
    'platforms' => [
        'instagram',
        'facebook',
        'twitter',
        'linkedin',
        'tiktok',
        'youtube',
        'snapchat',
    ],

    // Supported Tones
    'tones' => [
        'professional',
        'casual',
        'funny',
        'inspiring',
        'educational',
        'urgent',
        'friendly',
        'formal',
    ],

    // Supported Languages
    'languages' => [
        'arabic' => 'ar',
        'english' => 'en',
        'french' => 'fr',
        'spanish' => 'es',
        'german' => 'de',
        'chinese' => 'zh',
        'japanese' => 'ja',
        'korean' => 'ko',
        'hindi' => 'hi',
        'portuguese' => 'pt',
    ],

    // Logging
    'logging_enabled' => env('AI_LOGGING_ENABLED', true),
    'log_channel' => env('AI_LOG_CHANNEL', 'stack'),

];
