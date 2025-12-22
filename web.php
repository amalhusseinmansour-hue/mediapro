<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\LandingPageController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\PricingController;
use App\Models\Page;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Admin\RequestController;

// Landing Page
Route::get('/', function () {
    return view('landing');
});

// Authentication Routes
Route::get('/login', function () {
    return view('auth.login');
})->name('login');

Route::post('/login', [App\Http\Controllers\Web\AuthController::class, 'login']);

Route::get('/register', function () {
    return view('auth.register');
})->name('register');

Route::post('/register', [App\Http\Controllers\Web\AuthController::class, 'register']);

Route::post('/logout', [App\Http\Controllers\Web\AuthController::class, 'logout'])->name('logout');

// Pricing Page
Route::get('/pricing', function () {
    return view('pricing');
})->name('pricing');

// About Page
Route::get('/about', function () {
    return view('about');
})->name('about');

// Privacy Policy Page
Route::get('/privacy-policy', function () {
    return view('privacy-policy');
})->name('privacy-policy');

// Contact Page
Route::get('/contact', function () {
    return view('contact');
})->name('contact');

// Terms of Service Page
Route::get('/terms-of-service', function () {
    return view('terms-of-service');
})->name('terms-of-service');

// Payment Routes
Route::post('/payment/initiate', [PaymentController::class, 'initiatePayment'])->name('payment.initiate');
Route::get('/payment/callback', [PaymentController::class, 'handleCallback'])->name('payment.callback');
Route::post('/payment/webhook', [PaymentController::class, 'handleWebhook'])->name('payment.webhook');
Route::get('/payment/success', [PaymentController::class, 'success'])->name('payment.success');
Route::get('/payment/failed', [PaymentController::class, 'failed'])->name('payment.failed');

// Admin Routes (Protected - should add auth middleware)
Route::prefix('admin')->name('admin.')->group(function () {

    // Dashboard
    Route::get('/', [DashboardController::class, 'index'])->name('dashboard');

    // Users Management
    Route::prefix('users')->name('users.')->group(function () {
        Route::get('/', [UserController::class, 'index'])->name('index');
        Route::get('/{id}', [UserController::class, 'show'])->name('show');
        Route::post('/{id}/toggle-admin', [UserController::class, 'toggleAdmin'])->name('toggle-admin');
        Route::delete('/{id}', [UserController::class, 'destroy'])->name('destroy');
    });

    // Requests Management
    Route::prefix('requests')->name('requests.')->group(function () {

        // Website Requests
        Route::get('/website', [RequestController::class, 'websiteRequests'])->name('website');
        Route::post('/website/{id}', [RequestController::class, 'updateWebsiteRequest'])->name('website.update');

        // Sponsored Ads Requests
        Route::get('/ads', [RequestController::class, 'adRequests'])->name('ads');
        Route::post('/ads/{id}', [RequestController::class, 'updateAdRequest'])->name('ads.update');

        // Support Tickets
        Route::get('/support', [RequestController::class, 'supportTickets'])->name('support');
        Route::post('/support/{id}', [RequestController::class, 'updateSupportTicket'])->name('support.update');

        // Bank Transfer Requests
        Route::get('/bank-transfers', [RequestController::class, 'bankTransfers'])->name('bank-transfers');
        Route::post('/bank-transfers/{id}', [RequestController::class, 'updateBankTransfer'])->name('bank-transfers.update');
    });
});

// Pages Routes
Route::get('/{slug}', function (string $slug) {
    $page = Page::where('slug', $slug)
        ->where('is_published', true)
        ->firstOrFail();

    return view('page', compact('page'));
})->where('slug', '[a-zA-Z0-9\-]+');
