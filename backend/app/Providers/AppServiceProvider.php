<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use App\Services\MediaUploadService;
use App\Services\PaymobService;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        // Register MediaUploadService as singleton
        $this->app->singleton(MediaUploadService::class, function ($app) {
            return new MediaUploadService();
        });

        // Register PaymobService as singleton
        $this->app->singleton(PaymobService::class, function ($app) {
            return new PaymobService();
        });
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Force HTTPS in production
        if (config('app.env') === 'production') {
            \URL::forceScheme('https');
        }
    }
}
