<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class TrackUsage
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // معالجة الطلب أولاً
        $response = $next($request);

        // التتبع بعد معالجة الطلب بنجاح
        if ($response->getStatusCode() >= 200 && $response->getStatusCode() < 300) {
            $user = $request->user();

            if ($user && $user->subscription) {
                // تتبع إنشاء منشور
                if ($request->is('api/posts') && $request->isMethod('POST')) {
                    $this->trackPostCreation($user);
                }

                // تتبع طلبات AI
                if ($request->is('api/ai/*') && $request->isMethod('POST')) {
                    $this->trackAIRequest($user);
                }

                // تتبع ربط حساب جديد
                if ($request->is('api/connected-accounts') && $request->isMethod('POST')) {
                    $this->trackAccountConnection($user);
                }
            }
        }

        return $response;
    }

    /**
     * تتبع إنشاء منشور
     */
    private function trackPostCreation($user): void
    {
        try {
            $subscription = $user->subscription;

            if ($subscription) {
                $subscription->incrementPostsCount();
            }
        } catch (\Exception $e) {
            // تسجيل الخطأ بدون إيقاف التنفيذ
            logger()->error('Failed to track post creation', [
                'user_id' => $user->id,
                'error' => $e->getMessage(),
            ]);
        }
    }

    /**
     * تتبع طلب AI
     */
    private function trackAIRequest($user): void
    {
        try {
            $subscription = $user->subscription;

            if ($subscription && $subscription->ai_features) {
                $subscription->incrementAIRequestsCount();
            }
        } catch (\Exception $e) {
            logger()->error('Failed to track AI request', [
                'user_id' => $user->id,
                'error' => $e->getMessage(),
            ]);
        }
    }

    /**
     * تتبع ربط حساب
     */
    private function trackAccountConnection($user): void
    {
        try {
            // زيادة عدد الحسابات المربوطة
            $user->increment('connected_accounts_count');
        } catch (\Exception $e) {
            logger()->error('Failed to track account connection', [
                'user_id' => $user->id,
                'error' => $e->getMessage(),
            ]);
        }
    }
}
