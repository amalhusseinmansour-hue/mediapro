<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ScheduledPost;
use App\Jobs\PublishScheduledPostJob;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ScheduledPostController extends Controller
{
    public function index(Request $request)
    {
        $posts = ScheduledPost::where('user_id', $request->user()->id)
            ->when($request->has('status'), function ($q) use ($request) {
                $q->where('status', $request->status);
            })
            ->orderBy('scheduled_at', 'desc')
            ->paginate($request->get('per_page', 20));

        return response()->json([
            'success' => true,
            'posts' => $posts,
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'content_text' => 'required|string|max:5000',
            'media_urls' => 'nullable|array',
            'media_urls.*' => 'url',
            'platforms' => 'required|array|min:1',
            'platforms.*' => 'string|in:facebook,instagram,twitter,linkedin,tiktok,youtube,pinterest',
            'scheduled_at' => 'required|date|after:now',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $post = ScheduledPost::create([
            'user_id' => $request->user()->id,
            'content_text' => $request->content_text,
            'media_urls' => $request->media_urls,
            'platforms' => $request->platforms,
            'scheduled_at' => $request->scheduled_at,
            'status' => 'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Post scheduled successfully',
            'post' => $post,
        ], 201);
    }

    public function show(Request $request, int $id)
    {
        $post = ScheduledPost::where('user_id', $request->user()->id)
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'post' => $post,
        ]);
    }

    public function update(Request $request, int $id)
    {
        $post = ScheduledPost::where('user_id', $request->user()->id)
            ->findOrFail($id);

        if ($post->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Cannot update post with status: ' . $post->status,
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'content_text' => 'sometimes|string|max:5000',
            'media_urls' => 'sometimes|array',
            'platforms' => 'sometimes|array|min:1',
            'scheduled_at' => 'sometimes|date|after:now',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $post->update($request->only([
            'content_text',
            'media_urls',
            'platforms',
            'scheduled_at',
        ]));

        return response()->json([
            'success' => true,
            'message' => 'Post updated successfully',
            'post' => $post->fresh(),
        ]);
    }

    public function destroy(Request $request, int $id)
    {
        $post = ScheduledPost::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $post->delete();

        return response()->json([
            'success' => true,
            'message' => 'Post deleted successfully',
        ]);
    }

    public function sendNow(Request $request, int $id)
    {
        $post = ScheduledPost::where('user_id', $request->user()->id)
            ->findOrFail($id);

        if (!in_array($post->status, ['pending', 'failed'])) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot send post with status: ' . $post->status,
            ], 400);
        }

        PublishScheduledPostJob::dispatch($post);

        return response()->json([
            'success' => true,
            'message' => 'Post queued for immediate sending',
            'post' => $post->fresh(),
        ]);
    }

    public function retry(Request $request, int $id)
    {
        $post = ScheduledPost::where('user_id', $request->user()->id)
            ->findOrFail($id);

        if ($post->status !== 'failed') {
            return response()->json([
                'success' => false,
                'message' => 'Only failed posts can be retried',
            ], 400);
        }

        if (!$post->canRetry()) {
            return response()->json([
                'success' => false,
                'message' => 'Maximum retry attempts reached',
            ], 400);
        }

        $post->update(['status' => 'pending']);
        PublishScheduledPostJob::dispatch($post);

        return response()->json([
            'success' => true,
            'message' => 'Post queued for retry',
            'post' => $post->fresh(),
        ]);
    }

    public function dispatchScheduled()
    {
        $duePosts = ScheduledPost::due()->get();

        $dispatched = 0;
        foreach ($duePosts as $post) {
            PublishScheduledPostJob::dispatch($post);
            $dispatched++;
        }

        return response()->json([
            'success' => true,
            'message' => "Dispatched {$dispatched} scheduled posts",
            'count' => $dispatched,
        ]);
    }
}
