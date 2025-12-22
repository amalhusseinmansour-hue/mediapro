<?php

namespace App\Services\SocialMedia\Contracts;

use App\Models\ScheduledPost;
use App\Models\UserSocialAccount;

interface SocialPublisherInterface
{
    /**
     * Publish a post to social media platform(s)
     *
     * @param ScheduledPost $post
     * @param array $accounts Array of UserSocialAccount models
     * @return array Result with status and platform_responses
     */
    public function publish(ScheduledPost $post, array $accounts): array;

    /**
     * Get the name/identifier of this publisher
     *
     * @return string
     */
    public function getName(): string;

    /**
     * Check if this publisher supports the given platform
     *
     * @param string $platform
     * @return bool
     */
    public function supportsPlatform(string $platform): bool;

    /**
     * Validate account credentials
     *
     * @param UserSocialAccount $account
     * @return bool
     */
    public function validateAccount(UserSocialAccount $account): bool;

    /**
     * Refresh access token if needed
     *
     * @param UserSocialAccount $account
     * @return bool Success status
     */
    public function refreshToken(UserSocialAccount $account): bool;
}
