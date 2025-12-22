<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Support\Facades\App;

class SetLocale
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // التحقق من اللغة من الهيدر
        $locale = $request->header('Accept-Language', config('app.locale'));

        // التحقق من اللغة من الـ query parameter
        if ($request->has('lang')) {
            $locale = $request->get('lang');
        }

        // التحقق من اللغات المدعومة
        $supportedLocales = ['ar', 'en'];
        if (in_array($locale, $supportedLocales)) {
            App::setLocale($locale);
        }

        return $next($request);
    }
}
