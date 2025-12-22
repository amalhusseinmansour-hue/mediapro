<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        apiPrefix: 'api',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        // Trust all proxies for HTTPS detection
        $middleware->trustProxies(at: "*", headers:
            Symfony\Component\HttpFoundation\Request::HEADER_X_FORWARDED_FOR |
            Symfony\Component\HttpFoundation\Request::HEADER_X_FORWARDED_HOST |
            Symfony\Component\HttpFoundation\Request::HEADER_X_FORWARDED_PORT |
            Symfony\Component\HttpFoundation\Request::HEADER_X_FORWARDED_PROTO
        );

        $middleware->alias([
            'admin' => \App\Http\Middleware\AdminMiddleware::class,
            'locale' => \App\Http\Middleware\SetLocale::class,
            'api.key' => \App\Http\Middleware\ValidateApiKey::class,
        ]);

        $middleware->api(prepend: [
            \Illuminate\Http\Middleware\HandleCors::class,
            \App\Http\Middleware\SetLocale::class,
        ]);

        // Validate CSRF except for Livewire, Filament and Admin routes
        $middleware->validateCsrfTokens(except: [
            'livewire/*',
            'filament/*',
            'admin/*',  // Added: Exclude admin panel from CSRF validation
        ]);

        // Disable redirecting to login for API routes - return JSON instead
        $middleware->redirectGuestsTo(fn () => null);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        //
    })->create();
