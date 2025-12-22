<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AutoScheduledPost;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AutoScheduledPostController extends Controller
{
    /**
     * Get all auto scheduled posts for a user
     */
    public function index(Request $request, string $userId)
    {
        try {
            $perPage = $request->input('per_page', 20);
            $status = $request->input('status');

            $query = AutoScheduledPost::where('user_id', $userId)->recent();

            if ($status) {
                $query->where('status', $status);
            }

            $posts = $query->paginate($perPage);

            return response()->json([
                'success' => true,
                'posts' => $posts->items(),
                'pagination' => [
                    'current_page' => $posts->currentPage(),
                    'last_page' => $posts->lastPage(),
                    'per_page' => $posts->perPage(),
                    'total' => $posts->total(),
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to get posts',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Create a new auto scheduled post
     */
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'user_id' => 'required|string|exists:users,id',
                'content' => 'required|string',
                'media_urls' => 'nullable|array',
                'platforms' => 'required|array|min:1',
                'schedule_time' => 'required|date|after:now',
                'recurrence_pattern' => 'required|in:once,daily,weekly,monthly,custom',
                'recurrence_interval' => 'nullable|integer|min:1',
                'recurrence_end_date' => 'nullable|date|after:schedule_time',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $post = AutoScheduledPost::create([
                'user_id' => $request->user_id,
                'content' => $request->content,
                'media_urls' => $request->media_urls ?? [],
                'platforms' => $request->platforms,
                'schedule_time' => $request->schedule_time,
                'recurrence_pattern' => $request->recurrence_pattern,
                'recurrence_interval' => $request->recurrence_interval,
                'recurrence_end_date' => $request->recurrence_end_date,
                'next_post_at' => $request->schedule_time,
                'status' => AutoScheduledPost::STATUS_PENDING,
                'is_active' => false,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'تم إنشاء الجدولة بنجاح',
                'post' => $post,
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to create post',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get a single auto scheduled post
     */
    public function show(int $id)
    {
        try {
            $post = AutoScheduledPost::with('user')->findOrFail($id);

            return response()->json([
                'success' => true,
                'post' => $post,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Post not found',
            ], 404);
        }
    }

    /**
     * Update an auto scheduled post
     */
    public function update(Request $request, int $id)
    {
        try {
            $post = AutoScheduledPost::findOrFail($id);

            $validator = Validator::make($request->all(), [
                'content' => 'nullable|string',
                'media_urls' => 'nullable|array',
                'platforms' => 'nullable|array|min:1',
                'schedule_time' => 'nullable|date',
                'recurrence_pattern' => 'nullable|in:once,daily,weekly,monthly,custom',
                'recurrence_interval' => 'nullable|integer|min:1',
                'recurrence_end_date' => 'nullable|date',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $post->update($request->only([
                'content',
                'media_urls',
                'platforms',
                'schedule_time',
                'recurrence_pattern',
                'recurrence_interval',
                'recurrence_end_date',
            ]));

            return response()->json([
                'success' => true,
                'message' => 'تم تحديث الجدولة بنجاح',
                'post' => $post,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update post',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Delete an auto scheduled post
     */
    public function destroy(int $id)
    {
        try {
            $post = AutoScheduledPost::findOrFail($id);
            $post->delete();

            return response()->json([
                'success' => true,
                'message' => 'تم حذف الجدولة بنجاح',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete post',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Activate an auto scheduled post
     */
    public function activate(int $id)
    {
        try {
            $post = AutoScheduledPost::findOrFail($id);

            if (!$post->isPending() && !$post->isPaused()) {
                return response()->json([
                    'success' => false,
                    'message' => 'لا يمكن تفعيل هذه الجدولة',
                ], 400);
            }

            $post->activate();

            return response()->json([
                'success' => true,
                'message' => 'تم تفعيل الجدولة بنجاح',
                'post' => $post,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to activate post',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Pause an auto scheduled post
     */
    public function pause(int $id)
    {
        try {
            $post = AutoScheduledPost::findOrFail($id);

            if (!$post->isActive()) {
                return response()->json([
                    'success' => false,
                    'message' => 'لا يمكن إيقاف هذه الجدولة',
                ], 400);
            }

            $post->pause();

            return response()->json([
                'success' => true,
                'message' => 'تم إيقاف الجدولة مؤقتاً',
                'post' => $post,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to pause post',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get posts that are due for posting
     */
    public function getDueForPosting()
    {
        try {
            $posts = AutoScheduledPost::dueForPosting()->with('user')->get();

            return response()->json([
                'success' => true,
                'posts' => $posts,
                'count' => $posts->count(),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to get due posts',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get statistics
     */
    public function statistics(Request $request)
    {
        try {
            $userId = $request->input('user_id');

            $query = AutoScheduledPost::query();

            if ($userId) {
                $query->where('user_id', $userId);
            }

            $totalPosts = $query->count();
            $activePosts = (clone $query)->active()->count();
            $pendingPosts = (clone $query)->pending()->count();
            $pausedPosts = (clone $query)->paused()->count();
            $completedPosts = (clone $query)->where('status', AutoScheduledPost::STATUS_COMPLETED)->count();
            $totalPostsPublished = (clone $query)->sum('post_count');

            return response()->json([
                'success' => true,
                'statistics' => [
                    'total_posts' => $totalPosts,
                    'active_posts' => $activePosts,
                    'pending_posts' => $pendingPosts,
                    'paused_posts' => $pausedPosts,
                    'completed_posts' => $completedPosts,
                    'total_posts_published' => $totalPostsPublished,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to get statistics',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
