<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\LandingPageController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\PricingController;
use App\Models\Page;

// Landing Page
Route::get('/', function () {
    return view('landing');
})->name('home');

// Authentication Routes
Route::get('/login', function () {
    return view('auth.login');
})->name('login');

Route::post('/login', [App\Http\Controllers\Web\AuthController::class, 'login'])->name('login.post');

Route::get('/register', function () {
    return view('auth.register');
})->name('register');

Route::post('/register', [App\Http\Controllers\Web\AuthController::class, 'register'])->name('register.post');

Route::post('/logout', [App\Http\Controllers\Web\AuthController::class, 'logout'])->name('logout');

// Dashboard
Route::get('/dashboard', function () {
    return view('dashboard.index');
})->middleware('auth')->name('dashboard');

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

// Pages Routes
Route::get('/{slug}', function (string $slug) {
    $page = Page::where('slug', $slug)
        ->where('is_published', true)
        ->firstOrFail();

    return view('page', compact('page'));
})->where('slug', '[a-zA-Z0-9\-]+');
