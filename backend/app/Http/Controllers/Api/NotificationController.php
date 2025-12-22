<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class NotificationController extends Controller
{
    /**
     * عرض جميع الإشعارات
     */
    public function index(Request $request): JsonResponse
    {
        $query = Notification::query()
            ->where(function ($q) use ($request) {
                $q->where('user_id', $request->user()->id)
                    ->orWhere('is_global', true);
            })
            ->active();

        // Filter by read status
        if ($request->has('unread_only') && $request->unread_only) {
            $query->unread();
        }

        // Filter by type
        if ($request->has('type')) {
            $query->ofType($request->type);
        }

        $notifications = $query->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json($notifications);
    }

    /**
     * عرض إشعار واحد
     */
    public function show(string $id): JsonResponse
    {
        $notification = Notification::findOrFail($id);

        // تحقق من الصلاحية
        if (!$notification->is_global && $notification->user_id !== auth()->id()) {
            return response()->json(['error' => 'غير مصرح'], 403);
        }

        return response()->json($notification);
    }

    /**
     * عدد الإشعارات غير المقروءة
     */
    public function unreadCount(Request $request): JsonResponse
    {
        $count = Notification::where(function ($q) use ($request) {
                $q->where('user_id', $request->user()->id)
                    ->orWhere('is_global', true);
            })
            ->unread()
            ->active()
            ->count();

        return response()->json(['count' => $count]);
    }

    /**
     * وضع علامة كمقروء
     */
    public function markAsRead(Request $request, string $id): JsonResponse
    {
        $notification = Notification::findOrFail($id);

        // تحقق من الصلاحية
        if (!$notification->is_global && $notification->user_id !== $request->user()->id) {
            return response()->json(['error' => 'غير مصرح'], 403);
        }

        $notification->markAsRead();

        return response()->json([
            'message' => 'تم وضع علامة مقروء',
            'notification' => $notification
        ]);
    }

    /**
     * وضع علامة مقروء للكل
     */
    public function markAllAsRead(Request $request): JsonResponse
    {
        Notification::where('user_id', $request->user()->id)
            ->orWhere('is_global', true)
            ->unread()
            ->update([
                'is_read' => true,
                'read_at' => now(),
            ]);

        return response()->json(['message' => 'تم وضع علامة مقروء لجميع الإشعارات']);
    }

    /**
     * حذف إشعار
     */
    public function destroy(Request $request, string $id): JsonResponse
    {
        $notification = Notification::findOrFail($id);

        // تحقق من الصلاحية
        if (!$notification->is_global && $notification->user_id !== $request->user()->id) {
            return response()->json(['error' => 'غير مصرح'], 403);
        }

        $notification->delete();

        return response()->json(['message' => 'تم حذف الإشعار']);
    }

    /**
     * حذف جميع الإشعارات المقروءة
     */
    public function deleteRead(Request $request): JsonResponse
    {
        Notification::where('user_id', $request->user()->id)
            ->read()
            ->delete();

        return response()->json(['message' => 'تم حذف جميع الإشعارات المقروءة']);
    }
}
