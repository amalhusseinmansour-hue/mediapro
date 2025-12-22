<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use App\Models\SocialAccount;
use Carbon\Carbon;

class SocialMediaPublisher
{
    /**
     * Publish to social media platforms
     */
    public function publish(SocialAccount $account, string $content, array $mediaUrls = [])
    {
        // Check if token is expired
        if ($account->expires_at && Carbon::parse($account->expires_at)->isPast()) {
            return [
                'success' => false,
                'error' => 'Token expired. Please reconnect your account.'
            ];
        }

        $accessToken = decrypt($account->access_token);

        switch ($account->platform) {
            case 'facebook':
                return $this->publishToFacebook($accessToken, $account->account_id, $content, $mediaUrls);

            case 'twitter':
                return $this->publishToTwitter($accessToken, $content, $mediaUrls);

            case 'linkedin':
                return $this->publishToLinkedIn($accessToken, $content, $mediaUrls);

            default:
                return [
                    'success' => false,
                    'error' => 'Platform not supported'
                ];
        }
    }

    /**
     * Publish to Facebook Page
     */
    private function publishToFacebook($accessToken, $pageId, $content, $mediaUrls = [])
    {
        try {
            $endpoint = "https://graph.facebook.com/v18.0/{$pageId}/feed";

            $params = [
                'message' => $content,
                'access_token' => $accessToken
            ];

            // Add photo if provided
            if (!empty($mediaUrls)) {
                $params['link'] = $mediaUrls[0];
            }

            $response = Http::post($endpoint, $params);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'platform' => 'facebook',
                    'post_id' => $response->json()['id'] ?? null,
                    'url' => "https://facebook.com/{$response->json()['id']}"
                ];
            }

            return [
                'success' => false,
                'platform' => 'facebook',
                'error' => $response->json()['error']['message'] ?? 'Failed to publish'
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'platform' => 'facebook',
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Publish to Twitter/X
     */
    private function publishToTwitter($accessToken, $content, $mediaUrls = [])
    {
        try {
            $endpoint = "https://api.twitter.com/2/tweets";

            $params = [
                'text' => $content
            ];

            // TODO: Add media upload support

            $response = Http::withToken($accessToken)
                ->post($endpoint, $params);

            if ($response->successful()) {
                $data = $response->json()['data'];
                return [
                    'success' => true,
                    'platform' => 'twitter',
                    'post_id' => $data['id'] ?? null,
                    'url' => "https://twitter.com/i/web/status/{$data['id']}"
                ];
            }

            return [
                'success' => false,
                'platform' => 'twitter',
                'error' => $response->json()['title'] ?? 'Failed to publish'
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'platform' => 'twitter',
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Publish to LinkedIn
     */
    private function publishToLinkedIn($accessToken, $content, $mediaUrls = [])
    {
        try {
            // Get user ID first
            $userResponse = Http::withToken($accessToken)
                ->get('https://api.linkedin.com/v2/me');

            if (!$userResponse->successful()) {
                return [
                    'success' => false,
                    'platform' => 'linkedin',
                    'error' => 'Failed to get user ID'
                ];
            }

            $userId = $userResponse->json()['id'];

            // Create post
            $postData = [
                'author' => 'urn:li:person:' . $userId,
                'lifecycleState' => 'PUBLISHED',
                'specificContent' => [
                    'com.linkedin.ugc.ShareContent' => [
                        'shareCommentary' => [
                            'text' => $content
                        ],
                        'shareMediaCategory' => 'NONE'
                    ]
                ],
                'visibility' => [
                    'com.linkedin.ugc.MemberNetworkVisibility' => 'PUBLIC'
                ]
            ];

            $response = Http::withToken($accessToken)
                ->withHeaders([
                    'X-Restli-Protocol-Version' => '2.0.0'
                ])
                ->post('https://api.linkedin.com/v2/ugcPosts', $postData);

            if ($response->successful()) {
                $postId = $response->json()['id'];
                return [
                    'success' => true,
                    'platform' => 'linkedin',
                    'post_id' => $postId,
                    'url' => "https://www.linkedin.com/feed/update/{$postId}"
                ];
            }

            return [
                'success' => false,
                'platform' => 'linkedin',
                'error' => $response->json()['message'] ?? 'Failed to publish'
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'platform' => 'linkedin',
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Schedule post for later (using Laravel Queue)
     */
    public function schedule(SocialAccount $account, string $content, string $scheduleAt, array $mediaUrls = [])
    {
        // TODO: Implement Laravel Queue job
        \App\Jobs\PublishScheduledPost::dispatch($account, $content, $mediaUrls)
            ->delay(Carbon::parse($scheduleAt));

        return [
            'success' => true,
            'message' => 'Post scheduled successfully',
            'scheduled_at' => $scheduleAt
        ];
    }
}
