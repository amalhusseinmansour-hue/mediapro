<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional file to locate the various service credentials.
    |
    */

    'postmark' => [
        'token' => env('POSTMARK_TOKEN'),
    ],

    'resend' => [
        'key' => env('RESEND_KEY'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

    'stripe' => [
        'key' => env('STRIPE_KEY'),
        'secret' => env('STRIPE_SECRET'),
        'webhook_secret' => env('STRIPE_WEBHOOK_SECRET'),
    ],

    'paypal' => [
        'mode' => env('PAYPAL_MODE', 'sandbox'), // sandbox or live
        'client_id' => env('PAYPAL_CLIENT_ID'),
        'secret' => env('PAYPAL_SECRET'),
        'webhook_id' => env('PAYPAL_WEBHOOK_ID'),
    ],

    'twilio' => [
        'account_sid' => env('TWILIO_ACCOUNT_SID'),
        'auth_token' => env('TWILIO_AUTH_TOKEN'),
        'from_number' => env('TWILIO_FROM_NUMBER'),
        'test_mode' => env('TWILIO_TEST_MODE', true),
        'default_country_code' => env('TWILIO_DEFAULT_COUNTRY_CODE', '+971'), // UAE default
    ],

    'upload_post' => [
        'api_key' => env('UPLOAD_POST_API_KEY'),
        'endpoint' => env('UPLOAD_POST_ENDPOINT', 'https://api.upload-post.com/api'),
    ],

    'kie_ai' => [
        'api_key' => env('KIE_AI_API_KEY'),
        'secret_key' => env('KIE_AI_SECRET_KEY'),
        'endpoint' => env('KIE_AI_ENDPOINT', 'https://api.kie.ai/v1'),
    ],

    'n8n' => [
        'base_url' => env('N8N_BASE_URL', 'http://localhost:5678'),
        'api_key' => env('N8N_API_KEY'),
        'webhook_token' => env('N8N_WEBHOOK_TOKEN'),
    ],

    // AI Video Generation Services
    'runway' => [
        'api_key' => env('RUNWAY_API_KEY'),
        'endpoint' => env('RUNWAY_ENDPOINT', 'https://api.runwayml.com/v1'),
    ],

    'pika' => [
        'api_key' => env('PIKA_API_KEY'),
        'endpoint' => env('PIKA_ENDPOINT', 'https://api.pikalabs.com/v1'),
    ],

    'd_id' => [
        'api_key' => env('DID_API_KEY'),
        'endpoint' => env('DID_ENDPOINT', 'https://api.d-id.com'),
    ],

    'stability' => [
        'api_key' => env('STABILITY_API_KEY'),
        'endpoint' => env('STABILITY_ENDPOINT', 'https://api.stability.ai/v2beta'),
    ],

    'paymob' => [
        'api_key' => env('PAYMOB_API_KEY'),
        'hmac' => env('PAYMOB_HMAC'),
    ],

    // Social Media OAuth Services
    'facebook' => [
        'client_id' => env('FACEBOOK_APP_ID'),
        'client_secret' => env('FACEBOOK_APP_SECRET'),
        'redirect' => env('FACEBOOK_REDIRECT_URI'),
    ],

    'instagram' => [
        'client_id' => env('INSTAGRAM_CLIENT_ID'),
        'client_secret' => env('INSTAGRAM_CLIENT_SECRET'),
        'redirect' => env('APP_URL') . '/api/auth/instagram/callback',
    ],

    'twitter' => [
        'client_id' => env('TWITTER_API_KEY'),
        'client_secret' => env('TWITTER_API_SECRET'),
        'bearer_token' => env('TWITTER_BEARER_TOKEN'),
        'redirect' => env('APP_URL') . '/api/auth/twitter/callback',
    ],

    'linkedin' => [
        'client_id' => env('LINKEDIN_CLIENT_ID'),
        'client_secret' => env('LINKEDIN_CLIENT_SECRET'),
        'redirect' => env('APP_URL') . '/api/auth/linkedin/callback',
    ],

    'tiktok' => [
        'client_id' => env('TIKTOK_CLIENT_ID'),
        'client_secret' => env('TIKTOK_CLIENT_SECRET'),
        'redirect' => env('APP_URL') . '/api/auth/tiktok/callback',
    ],

    'google' => [
        'client_id' => env('GOOGLE_CLIENT_ID'),
        'client_secret' => env('GOOGLE_CLIENT_SECRET'),
        'redirect' => env('APP_URL') . '/api/auth/youtube/callback',
    ],

    'snapchat' => [
        'client_id' => env('SNAPCHAT_CLIENT_ID'),
        'client_secret' => env('SNAPCHAT_CLIENT_SECRET'),
        'redirect' => env('APP_URL') . '/api/auth/snapchat/callback',
    ],

    'apify' => [
        'api_token' => env('APIFY_API_TOKEN'),
    ],

    // AI Text & Content Generation
    'openai' => [
        'api_key' => env('OPENAI_API_KEY'),
        'organization' => env('OPENAI_ORGANIZATION'),
        'request_timeout' => 120,
    ],

    'claude' => [
        'api_key' => env('CLAUDE_API_KEY'),
        'model' => env('CLAUDE_MODEL', 'claude-3-5-sonnet-20241022'),
    ],

    'gemini' => [
        'api_key' => env('GEMINI_API_KEY'),
        'model' => env('GEMINI_MODEL', 'gemini-2.0-flash'),
    ],

    'replicate' => [
        'api_token' => env('REPLICATE_API_TOKEN'),
    ],

    // Social Media Management (Ayrshare)
    'ayrshare' => [
        'enabled' => env('AYRSHARE_ENABLED', true),
        'api_key' => env('AYRSHARE_API_KEY'),
        'profile_key' => env('AYRSHARE_PROFILE_KEY'), // Optional: for specific profile
    ],

    // Telegram Bot Configuration
    'telegram' => [
        'bot_token' => env('TELEGRAM_BOT_TOKEN'),
        'webhook_url' => env('TELEGRAM_WEBHOOK_URL'),
    ],

];
