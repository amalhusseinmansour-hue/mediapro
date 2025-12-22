<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\AISchedulingService;
use App\Models\AutoScheduledPost;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AISchedulingController extends Controller
{
    protected AISchedulingService $schedulingService;

    public function __construct(AISchedulingService $schedulingService)
    {
        $this->schedulingService = $schedulingService;
    }

    /**
     * جدولة منشور واحد باستخدام AI
     *
     * POST /api/ai-scheduling/schedule-post
     */
    public function schedulePost(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'content' => 'required|string|max:5000',
            'platforms' => 'required|array|min:1',
            'platforms.*' => 'string|in:facebook,instagram,twitter,linkedin,tiktok,youtube',
            'media_urls' => 'nullable|array',
            'media_urls.*' => 'url',
            'preferred_time' => 'nullable|date',
            'allow_time_adjustment' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $user = auth()->user();

            $autoPost = $this->schedulingService->schedulePost(
                $user,
                $request->input('content'),
                $request->input('platforms'),
                [
                    'media_urls' => $request->input('media_urls', []),
                    'preferred_time' => $request->input('preferred_time'),
                    'allow_time_adjustment' => $request->input('allow_time_adjustment', true),
                ]
            );

            return response()->json([
                'success' => true,
                'message' => 'تم جدولة المنشور بنجاح باستخدام AI',
                'data' => [
                    'post_id' => $autoPost->id,
                    'scheduled_at' => $autoPost->scheduled_at->toIso8601String(),
                    'platforms' => $autoPost->platforms,
                    'ai_analysis' => $autoPost->ai_analysis,
                    'hashtags' => $autoPost->hashtags,
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشلت عملية الجدولة: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * توليد + جدولة منشور تلقائياً
     *
     * POST /api/ai-scheduling/generate-and-schedule
     */
    public function generateAndSchedule(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'topic' => 'required|string|max:500',
            'platforms' => 'required|array|min:1',
            'platforms.*' => 'string|in:facebook,instagram,twitter,linkedin,tiktok,youtube',
            'tone' => 'nullable|string|in:professional,casual,friendly,formal,humorous',
            'length' => 'nullable|string|in:short,medium,long',
            'generate_image' => 'nullable|boolean',
            'preferred_time' => 'nullable|date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $user = auth()->user();

            $autoPost = $this->schedulingService->generateAndSchedule(
                $user,
                $request->input('topic'),
                $request->input('platforms'),
                [
                    'tone' => $request->input('tone', 'professional'),
                    'length' => $request->input('length', 'medium'),
                    'generate_image' => $request->input('generate_image', true),
                    'preferred_time' => $request->input('preferred_time'),
                ]
            );

            return response()->json([
                'success' => true,
                'message' => 'تم توليد وجدولة المنشور بنجاح',
                'data' => [
                    'post_id' => $autoPost->id,
                    'content' => $autoPost->content,
                    'scheduled_at' => $autoPost->scheduled_at->toIso8601String(),
                    'platforms' => $autoPost->platforms,
                    'media_urls' => $autoPost->media_urls,
                    'hashtags' => $autoPost->hashtags,
                    'ai_analysis' => $autoPost->ai_analysis,
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشلت عملية التوليد والجدولة: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * جدولة عدة منشورات على مدى فترة زمنية
     *
     * POST /api/ai-scheduling/schedule-multiple
     */
    public function scheduleMultiplePosts(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'topics' => 'required|array|min:1|max:20',
            'topics.*' => 'required|string|max:500',
            'platforms' => 'required|array|min:1',
            'platforms.*' => 'string|in:facebook,instagram,twitter,linkedin,tiktok,youtube',
            'days_spread' => 'nullable|integer|min:1|max:30',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $user = auth()->user();

            $posts = $this->schedulingService->scheduleMultiplePosts(
                $user,
                $request->input('topics'),
                $request->input('platforms'),
                $request->input('days_spread', 7)
            );

            return response()->json([
                'success' => true,
                'message' => 'تم جدولة ' . count($posts) . ' منشور بنجاح',
                'data' => [
                    'posts_count' => count($posts),
                    'posts' => array_map(function($post) {
                        return [
                            'id' => $post->id,
                            'content' => substr($post->content, 0, 100) . '...',
                            'scheduled_at' => $post->scheduled_at->toIso8601String(),
                            'platforms' => $post->platforms,
                        ];
                    }, $posts),
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشلت عملية الجدولة المتعددة: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * الحصول على جميع المنشورات المجدولة تلقائياً
     *
     * GET /api/ai-scheduling/my-scheduled-posts
     */
    public function getMyScheduledPosts(Request $request)
    {
        try {
            $user = auth()->user();

            $query = AutoScheduledPost::where('user_id', $user->id)
                ->orderBy('scheduled_at', 'desc');

            // Filter by status
            if ($request->has('status')) {
                $query->where('status', $request->input('status'));
            }

            // Pagination
            $perPage = $request->input('per_page', 20);
            $posts = $query->paginate($perPage);

            return response()->json([
                'success' => true,
                'data' => [
                    'posts' => $posts->items(),
                    'pagination' => [
                        'total' => $posts->total(),
                        'per_page' => $posts->perPage(),
                        'current_page' => $posts->currentPage(),
                        'last_page' => $posts->lastPage(),
                    ],
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل جلب المنشورات: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * إلغاء منشور مجدول
     *
     * DELETE /api/ai-scheduling/{id}
     */
    public function cancelScheduledPost($id)
    {
        try {
            $user = auth()->user();

            $post = AutoScheduledPost::where('user_id', $user->id)
                ->where('id', $id)
                ->firstOrFail();

            if ($post->status !== 'pending') {
                return response()->json([
                    'success' => false,
                    'message' => 'لا يمكن إلغاء منشور تم نشره بالفعل',
                ], 400);
            }

            // Update status
            $post->status = 'cancelled';
            $post->save();

            // Cancel related scheduled posts
            $post->scheduledPosts()->where('status', 'pending')->update([
                'status' => 'cancelled',
            ]);

            return response()->json([
                'success' => true,
                'message' => 'تم إلغاء المنشور بنجاح',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل إلغاء المنشور: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * الحصول على إحصائيات الجدولة التلقائية
     *
     * GET /api/ai-scheduling/stats
     */
    public function getSchedulingStats()
    {
        try {
            $user = auth()->user();

            $stats = $this->schedulingService->getUserSchedulingStats($user);

            return response()->json([
                'success' => true,
                'data' => $stats,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل جلب الإحصائيات: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * تحديث وقت منشور مجدول
     *
     * PUT /api/ai-scheduling/{id}/reschedule
     */
    public function reschedulePost($id, Request $request)
    {
        $validator = Validator::make($request->all(), [
            'new_time' => 'required|date|after:now',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $user = auth()->user();

            $post = AutoScheduledPost::where('user_id', $user->id)
                ->where('id', $id)
                ->firstOrFail();

            if ($post->status !== 'pending') {
                return response()->json([
                    'success' => false,
                    'message' => 'لا يمكن إعادة جدولة منشور تم نشره بالفعل',
                ], 400);
            }

            $newTime = new \Carbon\Carbon($request->input('new_time'));

            $post->scheduled_at = $newTime;
            $post->save();

            // Update related scheduled posts
            $post->scheduledPosts()->where('status', 'pending')->update([
                'scheduled_at' => $newTime,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'تم تحديث موعد النشر بنجاح',
                'data' => [
                    'new_scheduled_at' => $newTime->toIso8601String(),
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل تحديث الموعد: ' . $e->getMessage(),
            ], 500);
        }
    }
}
