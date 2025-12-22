<?php

namespace App\Services\SocialMedia;

use App\Models\ScheduledPost;
use App\Models\UserSocialAccount;
use App\Services\SocialMedia\Contracts\SocialPublisherInterface;

class ManualPublisher implements SocialPublisherInterface
{
    public function getName(): string
    {
        return 'manual';
    }

    public function supportsPlatform(string $platform): bool
    {
        // Manual publishing supports all platforms
        return true;
    }

    public function publish(ScheduledPost $post, array $accounts): array
    {
        // Manual publishing doesn't actually publish
        // It just marks the post as ready for manual publishing
        // and provides the user with all the data they need

        $platformResponses = [];

        foreach ($post->platforms as $platform) {
            $account = $accounts[$platform] ?? null;

            $platformResponses[$platform] = [
                'success' => false,
                'manual_publishing_required' => true,
                'account' => $account ? [
                    'platform' => $account->platform,
                    'username' => $account->username,
                    'display_name' => $account->display_name,
                ] : null,
                'content' => [
                    'text' => $post->content,
                    'title' => $post->title,
                    'media_urls' => $post->media_urls,
                    'link_url' => $post->link_url,
                ],
                'instructions' => $this->getManualInstructions($platform, $post),
            ];
        }

        return [
            'success' => false,
            'manual_publishing_required' => true,
            'platform_responses' => $platformResponses,
            'message' => 'This post requires manual publishing. Please use the platform-specific apps or websites.',
        ];
    }

    protected function getManualInstructions(string $platform, ScheduledPost $post): array
    {
        $instructions = [
            'facebook' => [
                'url' => 'https://facebook.com',
                'steps' => [
                    '1. Go to Facebook.com and log in',
                    '2. Click "What\'s on your mind?"',
                    '3. Paste the content',
                    '4. Add media files if applicable',
                    '5. Click "Post"',
                ],
            ],
            'instagram' => [
                'url' => 'https://instagram.com',
                'steps' => [
                    '1. Open Instagram app or website',
                    '2. Click the "+" icon',
                    '3. Select your media',
                    '4. Add caption',
                    '5. Share',
                ],
            ],
            'twitter' => [
                'url' => 'https://twitter.com',
                'steps' => [
                    '1. Go to Twitter.com',
                    '2. Click "What\'s happening?"',
                    '3. Paste the content',
                    '4. Add media if applicable',
                    '5. Click "Tweet"',
                ],
            ],
            'linkedin' => [
                'url' => 'https://linkedin.com',
                'steps' => [
                    '1. Go to LinkedIn.com',
                    '2. Click "Start a post"',
                    '3. Paste the content',
                    '4. Add media if applicable',
                    '5. Click "Post"',
                ],
            ],
        ];

        return $instructions[$platform] ?? [
            'url' => "https://{$platform}.com",
            'steps' => [
                '1. Visit the platform',
                '2. Create a new post',
                '3. Add your content',
                '4. Publish',
            ],
        ];
    }

    public function validateAccount(UserSocialAccount $account): bool
    {
        // Manual publishing doesn't require account validation
        return true;
    }

    public function refreshToken(UserSocialAccount $account): bool
    {
        // Manual publishing doesn't use tokens
        return true;
    }
}
