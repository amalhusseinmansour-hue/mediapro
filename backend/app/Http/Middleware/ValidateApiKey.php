<?php

namespace App\Http\Middleware;

use App\Models\ApiKey;
use App\Models\ApiLog;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\RateLimiter;

class ValidateApiKey
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $startTime = microtime(true);

        // Get API key from header or query parameter
        $apiKeyValue = $request->header('X-API-Key') ?? $request->query('api_key');

        if (!$apiKeyValue) {
            return $this->unauthorizedResponse('API key is missing');
        }

        // Get API key from cache or database
        $apiKey = Cache::remember("api_key:{$apiKeyValue}", 3600, function () use ($apiKeyValue) {
            return ApiKey::where('key', $apiKeyValue)->first();
        });

        if (!$apiKey) {
            $this->logRequest($request, null, null, 401, $startTime);
            return $this->unauthorizedResponse('Invalid API key');
        }

        // Check if key is active and not expired
        if (!$apiKey->isValid()) {
            $this->logRequest($request, $apiKey, null, 401, $startTime);
            return $this->unauthorizedResponse('API key is inactive or expired');
        }

        // Check IP whitelist
        if (!$apiKey->isIpAllowed($request->ip())) {
            $this->logRequest($request, $apiKey, null, 403, $startTime);
            return $this->forbiddenResponse('Your IP address is not allowed');
        }

        // Check rate limiting
        $rateLimitKey = "api_rate_limit:{$apiKey->id}";
        $maxAttempts = $apiKey->rate_limit;

        if (RateLimiter::tooManyAttempts($rateLimitKey, $maxAttempts)) {
            $this->logRequest($request, $apiKey, null, 429, $startTime);
            return $this->tooManyRequestsResponse($maxAttempts);
        }

        RateLimiter::hit($rateLimitKey, 60); // 60 seconds window

        // Attach API key and user to request
        $request->merge(['api_key' => $apiKey]);

        if ($apiKey->user_id) {
            $request->setUserResolver(function () use ($apiKey) {
                return $apiKey->user;
            });
        }

        // Process request
        $response = $next($request);

        // Update usage stats
        $apiKey->recordUsage();

        // Log the request
        $this->logRequest(
            $request,
            $apiKey,
            $apiKey->user_id,
            $response->getStatusCode(),
            $startTime,
            $response
        );

        return $response;
    }

    /**
     * Log API request
     */
    protected function logRequest(
        Request $request,
        ?ApiKey $apiKey,
        ?int $userId,
        int $statusCode,
        float $startTime,
        ?Response $response = null
    ): void {
        $responseTime = (microtime(true) - $startTime) * 1000; // Convert to milliseconds

        ApiLog::create([
            'api_key_id' => $apiKey?->id,
            'user_id' => $userId,
            'method' => $request->method(),
            'endpoint' => $request->path(),
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'request_headers' => $this->filterHeaders($request->headers->all()),
            'request_body' => $this->filterSensitiveData($request->except(['password', 'password_confirmation', 'api_key'])),
            'response_status' => $statusCode,
            'response_body' => $response ? $this->getResponseBody($response) : null,
            'response_time' => round($responseTime),
            'created_at' => now(),
        ]);
    }

    /**
     * Filter sensitive headers
     */
    protected function filterHeaders(array $headers): array
    {
        $filtered = [];
        $allowedHeaders = ['content-type', 'accept', 'user-agent', 'x-requested-with'];

        foreach ($headers as $key => $value) {
            if (in_array(strtolower($key), $allowedHeaders)) {
                $filtered[$key] = $value;
            }
        }

        return $filtered;
    }

    /**
     * Filter sensitive data from request
     */
    protected function filterSensitiveData(array $data): array
    {
        $sensitive = ['password', 'token', 'secret', 'key', 'authorization'];

        foreach ($data as $key => $value) {
            foreach ($sensitive as $sensitiveKey) {
                if (stripos($key, $sensitiveKey) !== false) {
                    $data[$key] = '***FILTERED***';
                }
            }
        }

        return $data;
    }

    /**
     * Get response body (limited to first 1000 characters)
     */
    protected function getResponseBody(Response $response): ?array
    {
        $content = $response->getContent();

        if (strlen($content) > 1000) {
            $content = substr($content, 0, 1000) . '... (truncated)';
        }

        $decoded = json_decode($content, true);
        return is_array($decoded) ? $decoded : ['raw' => $content];
    }

    /**
     * Return unauthorized response
     */
    protected function unauthorizedResponse(string $message): Response
    {
        return response()->json([
            'error' => 'Unauthorized',
            'message' => $message,
        ], 401);
    }

    /**
     * Return forbidden response
     */
    protected function forbiddenResponse(string $message): Response
    {
        return response()->json([
            'error' => 'Forbidden',
            'message' => $message,
        ], 403);
    }

    /**
     * Return too many requests response
     */
    protected function tooManyRequestsResponse(int $maxAttempts): Response
    {
        return response()->json([
            'error' => 'Too Many Requests',
            'message' => "Rate limit exceeded. Maximum {$maxAttempts} requests per minute.",
        ], 429);
    }
}
