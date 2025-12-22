<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CommunityPost;
use App\Models\CommunityComment;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;

class CommunityPostController extends Controller
{
    /**
     * Get all community posts (with pagination)
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $page = $request->get('page', 1);
            $perPage = $request->get('per_page', 20);
            $visibility = $request->get('visibility', 'public');

            $query = CommunityPost::published();

            if ($visibility === 'public') {
                $query->where('visibility', 'public');
            } else {
                // If authenticated, show user's own posts and public posts
                $userId = Auth::id();
                if ($userId) {
                    $query->where(function ($q) use ($userId) {
                        $q->where('visibility', 'public')
                          ->orWhere('user_id', $userId);
                    });
                } else {
                    $query->where('visibility', 'public');
                }
            }

            $posts = $query->with('user')
                ->orderBy('is_pinned', 'desc')
                ->orderBy('published_at', 'desc')
                ->paginate($perPage, ['*'], 'page', $page);

            return response()->json([
                'success' => true,
                'data' => $posts->items(),
                'pagination' => [
                    'current_page' => $posts->currentPage(),
                    'total' => $posts->total(),
                    'per_page' => $posts->perPage(),
                    'last_page' => $posts->lastPage(),
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل تحميل المنشورات',
                'error' => config('app.debug') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Create a new community post
     */
    public function store(Request $request): JsonResponse
    {
        $userId = Auth::id();

        if (!$userId) {
            return response()->json([
                'success' => false,
                'message' => 'يجب عليك تسجيل الدخول أولاً',
            ], 401);
        }

        $validator = Validator::make($request->all(), [
            'content' => 'required|string|min:1|max:5000',
            'media_urls' => 'nullable|array',
            'media_urls.*' => 'url',
            'tags' => 'nullable|array',
            'visibility' => 'nullable|in:public,followers,private',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صحيحة',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $post = CommunityPost::create([
                'user_id' => $userId,
                'content' => $request->content,
                'media_urls' => $request->media_urls ?? [],
                'tags' => $request->tags ?? [],
                'visibility' => $request->visibility ?? 'public',
                'published_at' => now(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'تم إنشاء المنشور بنجاح',
                'data' => $post->load('user'),
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل إنشاء المنشور',
                'error' => config('app.debug') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Get a specific community post
     */
    public function show(Request $request, int $id): JsonResponse
    {
        try {
            $post = CommunityPost::published()->findOrFail($id);

            return response()->json([
                'success' => true,
                'data' => $post->load('user'),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'المنشور غير موجود',
            ], 404);
        }
    }

    /**
     * Update a community post
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $userId = Auth::id();

        if (!$userId) {
            return response()->json([
                'success' => false,
                'message' => 'يجب عليك تسجيل الدخول أولاً',
            ], 401);
        }

        try {
            $post = CommunityPost::find($id);

            if (!$post) {
                return response()->json([
                    'success' => false,
                    'message' => 'المنشور غير موجود',
                ], 404);
            }

            // Check if user owns the post
            if ($post->user_id !== $userId) {
                return response()->json([
                    'success' => false,
                    'message' => 'لا يمكنك تعديل هذا المنشور',
                ], 403);
            }

            $validator = Validator::make($request->all(), [
                'content' => 'nullable|string|min:1|max:5000',
                'media_urls' => 'nullable|array',
                'media_urls.*' => 'url',
                'tags' => 'nullable|array',
                'visibility' => 'nullable|in:public,followers,private',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'بيانات غير صحيحة',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $updates = [];
            if ($request->has('content')) {
                $updates['content'] = $request->content;
            }
            if ($request->has('media_urls')) {
                $updates['media_urls'] = $request->media_urls;
            }
            if ($request->has('tags')) {
                $updates['tags'] = $request->tags;
            }
            if ($request->has('visibility')) {
                $updates['visibility'] = $request->visibility;
            }

            if (!empty($updates)) {
                $post->update($updates);
            }

            return response()->json([
                'success' => true,
                'message' => 'تم تحديث المنشور بنجاح',
                'data' => $post,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل تحديث المنشور',
                'error' => config('app.debug') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Delete a community post
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $userId = Auth::id();

        if (!$userId) {
            return response()->json([
                'success' => false,
                'message' => 'يجب عليك تسجيل الدخول أولاً',
            ], 401);
        }

        try {
            $post = CommunityPost::find($id);

            if (!$post) {
                return response()->json([
                    'success' => false,
                    'message' => 'المنشور غير موجود',
                ], 404);
            }

            // Check if user owns the post
            if ($post->user_id !== $userId) {
                return response()->json([
                    'success' => false,
                    'message' => 'لا يمكنك حذف هذا المنشور',
                ], 403);
            }

            $post->delete();

            return response()->json([
                'success' => true,
                'message' => 'تم حذف المنشور بنجاح',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل حذف المنشور',
                'error' => config('app.debug') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Get user's community posts
     */
    public function userPosts(Request $request, int $userId = null): JsonResponse
    {
        try {
            $userId = $userId ?? Auth::id();

            if (!$userId) {
                return response()->json([
                    'success' => false,
                    'message' => 'يجب عليك تسجيل الدخول أولاً',
                ], 401);
            }

            $page = $request->get('page', 1);
            $perPage = $request->get('per_page', 20);

            $posts = CommunityPost::byUser($userId)
                ->published()
                ->with('user')
                ->orderBy('is_pinned', 'desc')
                ->orderBy('published_at', 'desc')
                ->paginate($perPage, ['*'], 'page', $page);

            return response()->json([
                'success' => true,
                'data' => $posts->items(),
                'pagination' => [
                    'current_page' => $posts->currentPage(),
                    'total' => $posts->total(),
                    'per_page' => $posts->perPage(),
                    'last_page' => $posts->lastPage(),
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل تحميل منشورات المستخدم',
                'error' => config('app.debug') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Pin a post
     */
    public function pin(Request $request, int $id): JsonResponse
    {
        $userId = Auth::id();

        if (!$userId) {
            return response()->json([
                'success' => false,
                'message' => 'يجب عليك تسجيل الدخول أولاً',
            ], 401);
        }

        try {
            $post = CommunityPost::find($id);

            if (!$post) {
                return response()->json([
                    'success' => false,
                    'message' => 'المنشور غير موجود',
                ], 404);
            }

            if ($post->user_id !== $userId) {
                return response()->json([
                    'success' => false,
                    'message' => 'لا يمكنك تثبيت هذا المنشور',
                ], 403);
            }

            $post->pin();

            return response()->json([
                'success' => true,
                'message' => 'تم تثبيت المنشور بنجاح',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل تثبيت المنشور',
                'error' => config('app.debug') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Unpin a post
     */
    public function unpin(Request $request, int $id): JsonResponse
    {
        $userId = Auth::id();

        if (!$userId) {
            return response()->json([
                'success' => false,
                'message' => 'يجب عليك تسجيل الدخول أولاً',
            ], 401);
        }

        try {
            $post = CommunityPost::find($id);

            if (!$post) {
                return response()->json([
                    'success' => false,
                    'message' => 'المنشور غير موجود',
                ], 404);
            }

            if ($post->user_id !== $userId) {
                return response()->json([
                    'success' => false,
                    'message' => 'لا يمكنك إلغاء تثبيت هذا المنشور',
                ], 403);
            }

            $post->unpin();

            return response()->json([
                'success' => true,
                'message' => 'تم إلغاء تثبيت المنشور بنجاح',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل إلغاء تثبيت المنشور',
                'error' => config('app.debug') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Get comments for a post
     */
    public function getComments(Request $request, int $id): JsonResponse
    {
        try {
            $post = CommunityPost::findOrFail($id);

            $comments = CommunityComment::where('post_id', $id)
                ->with(['user', 'replies.user'])
                ->topLevel()
                ->orderBy('created_at', 'desc')
                ->get();

            return response()->json([
                'success' => true,
                'data' => $comments,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل تحميل التعليقات',
                'error' => config('app.debug') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Add a comment to a post
     */
    public function storeComment(Request $request, int $id): JsonResponse
    {
        $userId = Auth::id();

        if (!$userId) {
            return response()->json([
                'success' => false,
                'message' => 'يجب عليك تسجيل الدخول أولاً',
            ], 401);
        }

        $validator = Validator::make($request->all(), [
            'comment' => 'required|string|min:1|max:1000',
            'parent_id' => 'nullable|exists:community_comments,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صحيحة',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $post = CommunityPost::findOrFail($id);

            $comment = CommunityComment::create([
                'post_id' => $id,
                'user_id' => $userId,
                'parent_id' => $request->parent_id,
                'content' => $request->comment,
            ]);

            // Increment comments count if column exists
            if (schema()->hasColumn('community_posts', 'comments_count')) {
                $post->increment('comments_count');
            }

            return response()->json([
                'success' => true,
                'message' => 'تم إضافة التعليق بنجاح',
                'data' => $comment->load('user'),
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل إضافة التعليق',
                'error' => config('app.debug') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Delete a comment
     */
    public function deleteComment(Request $request, int $postId, int $commentId): JsonResponse
    {
        $userId = Auth::id();

        if (!$userId) {
            return response()->json([
                'success' => false,
                'message' => 'يجب عليك تسجيل الدخول أولاً',
            ], 401);
        }

        try {
            $comment = CommunityComment::findOrFail($commentId);

            // Check if user owns the comment
            if ($comment->user_id !== $userId) {
                return response()->json([
                    'success' => false,
                    'message' => 'لا يمكنك حذف هذا التعليق',
                ], 403);
            }

            $comment->delete();

            // Decrement comments count if column exists
            $post = CommunityPost::find($postId);
            if ($post && schema()->hasColumn('community_posts', 'comments_count') && $post->comments_count > 0) {
                $post->decrement('comments_count');
            }

            return response()->json([
                'success' => true,
                'message' => 'تم حذف التعليق بنجاح',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل حذف التعليق',
                'error' => config('app.debug') ? $e->getMessage() : null,
            ], 500);
        }
    }
}
