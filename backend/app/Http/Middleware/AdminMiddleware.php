<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'error' => 'غير مصرح - يرجى تسجيل الدخول',
                'message' => 'Unauthorized - Please login'
            ], 401);
        }

        // Check if user is admin through multiple methods
        $isAdmin = $user->is_admin === true ||
                   $user->user_type === 'admin' ||
                   $user->user_type === 'super_admin' ||
                   $user->hasAnyRole(['admin', 'super_admin']);

        if (!$isAdmin) {
            return response()->json([
                'success' => false,
                'error' => 'غير مصرح لك بالوصول إلى هذا المورد',
                'message' => 'Admin access required'
            ], 403);
        }

        return $next($request);
    }
}
