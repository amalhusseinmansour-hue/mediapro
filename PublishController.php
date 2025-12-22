<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\SocialMediaPublisher;
use App\Services\PostizService;
use App\Models\SocialAccount;
use Illuminate\Http\Request;

class PublishController extends Controller
{
    private $publisher;
    private $postiz;

    public function __construct(SocialMediaPublisher $publisher, PostizService $postiz)
    {
        $this->publisher = $publisher;
        $this->postiz = $postiz;
    }

    /**
     * Get user's connected social accounts
     * GET /api/social/accounts
     */
    public function getAccounts(Request $request)
    {
        $user = $request->user();

        $accounts = SocialAccount::where('user_id', $user->id)
            ->where('is_active', true)
            ->select([
                'id',
                'platform',
                'account_name',
                'account_id',
                'expires_at',
                'created_at'
            ])
            ->get();

        return response()->json([
            'success' => true,
            'accounts' => $accounts
        ]);
    }

    /**
     * Disconnect social account
     * DELETE /api/social/accounts/{id}
     */
    public function disconnect(Request $request, $accountId)
    {
        $user = $request->user();

        $account = SocialAccount::where('id', $accountId)
            ->where('user_id', $user->id)
            ->first();

        if (!$account) {
            return response()->json([
                'success' => false,
                'message' => 'Account not found'
            ], 404);
        }

        $account->delete();

        return response()->json([
            'success' => true,
            'message' => 'Account disconnected successfully'
        ]);
    }

    /**
     * Publish post to social media
     * POST /api/social/publish
     */
    public function publish(Request $request)
    {
        $request->validate([
            'account_ids' => 'required|array',
            'account_ids.*' => 'required|integer',
            'content' => 'required|string',
            'media_urls' => 'nullable|array',
            'schedule_at' => 'nullable|date|after:now'
        ]);

        $user = $request->user();
        $results = [];

        foreach ($request->account_ids as $accountId) {
            $account = SocialAccount::where('id', $accountId)
                ->where('user_id', $user->id)
                ->where('is_active', true)
                ->first();

            if (!$account) {
                $results[] = [
                    'account_id' => $accountId,
                    'success' => false,
                    'error' => 'Account not found'
                ];
                continue;
            }

            // Schedule or publish immediately
            if ($request->schedule_at) {
                $result = $this->publisher->schedule(
                    $account,
                    $request->content,
                    $request->schedule_at,
                    $request->media_urls ?? []
                );
            } else {
                $result = $this->publisher->publish(
                    $account,
                    $request->content,
                    $request->media_urls ?? []
                );
            }

            $results[] = array_merge($result, [
                'account_id' => $accountId,
                'account_name' => $account->account_name
            ]);
        }

        return response()->json([
            'success' => true,
            'results' => $results
        ]);
    }

    /**
     * Generate AI Video (Postiz)
     * POST /api/social/generate-video
     */
    public function generateVideo(Request $request)
    {
        $request->validate([
            'content' => 'required|string',
            'platform' => 'nullable|string|in:tiktok,instagram,youtube'
        ]);

        $result = $this->postiz->generateVideo(
            $request->content,
            $request->platform ?? 'tiktok'
        );

        return response()->json($result);
    }

    /**
     * Upload media (Postiz CDN)
     * POST /api/social/upload-media
     */
    public function uploadMedia(Request $request)
    {
        if ($request->hasFile('file')) {
            $result = $this->postiz->uploadMedia($request->file('file'));
        } elseif ($request->url) {
            $result = $this->postiz->uploadFromUrl($request->url);
        } else {
            return response()->json([
                'success' => false,
                'error' => 'No file or URL provided'
            ], 400);
        }

        return response()->json($result);
    }

    /**
     * Get analytics
     * GET /api/social/analytics
     */
    public function getAnalytics(Request $request)
    {
        $request->validate([
            'start_date' => 'required|date',
            'end_date' => 'required|date|after:start_date'
        ]);

        $result = $this->postiz->getAnalytics(
            $request->start_date,
            $request->end_date
        );

        return response()->json($result);
    }
}
