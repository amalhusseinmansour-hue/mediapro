<?php

namespace App\Services\SocialMedia;

use App\Models\ConnectedAccount;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class LinkedInService
{
    protected string $apiUrl = 'https://api.linkedin.com/v2';
    protected string $restliUrl = 'https://api.linkedin.com/rest';

    /**
     * Get user's LinkedIn profile ID (URN)
     */
    public function getUserUrn(string $accessToken): ?string
    {
        try {
            $response = Http::withToken($accessToken)
                ->withHeaders([
                    'LinkedIn-Version' => '202401',
                ])
                ->get("{$this->apiUrl}/userinfo");

            if ($response->successful()) {
                $data = $response->json();
                return $data['sub'] ?? null; // Returns the person URN
            }

            // Fallback to /me endpoint
            $response = Http::withToken($accessToken)->get("{$this->apiUrl}/me");

            if ($response->successful()) {
                $data = $response->json();
                return $data['id'] ?? null;
            }

            return null;
        } catch (\Exception $e) {
            Log::error('LinkedIn getUserUrn error: ' . $e->getMessage());
            return null;
        }
    }

    /**
     * Post text content to LinkedIn
     */
    public function postText(ConnectedAccount $account, string $content): array
    {
        try {
            $accessToken = decrypt($account->access_token);
            $userUrn = $this->getUserUrn($accessToken);

            if (!$userUrn) {
                return [
                    'success' => false,
                    'error' => 'فشل الحصول على معرف المستخدم',
                ];
            }

            $authorUrn = "urn:li:person:{$userUrn}";

            $payload = [
                'author' => $authorUrn,
                'lifecycleState' => 'PUBLISHED',
                'specificContent' => [
                    'com.linkedin.ugc.ShareContent' => [
                        'shareCommentary' => [
                            'text' => $content,
                        ],
                        'shareMediaCategory' => 'NONE',
                    ],
                ],
                'visibility' => [
                    'com.linkedin.ugc.MemberNetworkVisibility' => 'PUBLIC',
                ],
            ];

            $response = Http::withToken($accessToken)
                ->withHeaders([
                    'Content-Type' => 'application/json',
                    'X-Restli-Protocol-Version' => '2.0.0',
                ])
                ->post("{$this->apiUrl}/ugcPosts", $payload);

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'success' => true,
                    'post_id' => $data['id'] ?? null,
                    'message' => 'تم النشر بنجاح على LinkedIn',
                ];
            }

            $error = $response->json();
            Log::error('LinkedIn postText error', ['response' => $error]);

            return [
                'success' => false,
                'error' => $error['message'] ?? 'فشل النشر على LinkedIn',
                'error_details' => $error,
            ];

        } catch (\Exception $e) {
            Log::error('LinkedIn postText exception: ' . $e->getMessage());
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Post with image to LinkedIn
     */
    public function postWithImage(ConnectedAccount $account, string $content, string $imageUrl): array
    {
        try {
            $accessToken = decrypt($account->access_token);
            $userUrn = $this->getUserUrn($accessToken);

            if (!$userUrn) {
                return [
                    'success' => false,
                    'error' => 'فشل الحصول على معرف المستخدم',
                ];
            }

            $authorUrn = "urn:li:person:{$userUrn}";

            // Step 1: Register image upload
            $registerResponse = $this->registerImageUpload($accessToken, $authorUrn);

            if (!$registerResponse['success']) {
                return $registerResponse;
            }

            $uploadUrl = $registerResponse['upload_url'];
            $asset = $registerResponse['asset'];

            // Step 2: Upload image
            $uploadResult = $this->uploadImage($uploadUrl, $imageUrl, $accessToken);

            if (!$uploadResult['success']) {
                return $uploadResult;
            }

            // Step 3: Create post with image
            $payload = [
                'author' => $authorUrn,
                'lifecycleState' => 'PUBLISHED',
                'specificContent' => [
                    'com.linkedin.ugc.ShareContent' => [
                        'shareCommentary' => [
                            'text' => $content,
                        ],
                        'shareMediaCategory' => 'IMAGE',
                        'media' => [
                            [
                                'status' => 'READY',
                                'media' => $asset,
                            ],
                        ],
                    ],
                ],
                'visibility' => [
                    'com.linkedin.ugc.MemberNetworkVisibility' => 'PUBLIC',
                ],
            ];

            $response = Http::withToken($accessToken)
                ->withHeaders([
                    'Content-Type' => 'application/json',
                    'X-Restli-Protocol-Version' => '2.0.0',
                ])
                ->post("{$this->apiUrl}/ugcPosts", $payload);

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'success' => true,
                    'post_id' => $data['id'] ?? null,
                    'message' => 'تم النشر مع الصورة بنجاح على LinkedIn',
                ];
            }

            $error = $response->json();
            return [
                'success' => false,
                'error' => $error['message'] ?? 'فشل النشر',
                'error_details' => $error,
            ];

        } catch (\Exception $e) {
            Log::error('LinkedIn postWithImage exception: ' . $e->getMessage());
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Post with link/article to LinkedIn
     */
    public function postWithLink(ConnectedAccount $account, string $content, string $linkUrl, ?string $title = null, ?string $description = null): array
    {
        try {
            $accessToken = decrypt($account->access_token);
            $userUrn = $this->getUserUrn($accessToken);

            if (!$userUrn) {
                return [
                    'success' => false,
                    'error' => 'فشل الحصول على معرف المستخدم',
                ];
            }

            $authorUrn = "urn:li:person:{$userUrn}";

            $payload = [
                'author' => $authorUrn,
                'lifecycleState' => 'PUBLISHED',
                'specificContent' => [
                    'com.linkedin.ugc.ShareContent' => [
                        'shareCommentary' => [
                            'text' => $content,
                        ],
                        'shareMediaCategory' => 'ARTICLE',
                        'media' => [
                            [
                                'status' => 'READY',
                                'originalUrl' => $linkUrl,
                                'title' => [
                                    'text' => $title ?? 'مقال',
                                ],
                                'description' => [
                                    'text' => $description ?? '',
                                ],
                            ],
                        ],
                    ],
                ],
                'visibility' => [
                    'com.linkedin.ugc.MemberNetworkVisibility' => 'PUBLIC',
                ],
            ];

            $response = Http::withToken($accessToken)
                ->withHeaders([
                    'Content-Type' => 'application/json',
                    'X-Restli-Protocol-Version' => '2.0.0',
                ])
                ->post("{$this->apiUrl}/ugcPosts", $payload);

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'success' => true,
                    'post_id' => $data['id'] ?? null,
                    'message' => 'تم النشر مع الرابط بنجاح على LinkedIn',
                ];
            }

            $error = $response->json();
            return [
                'success' => false,
                'error' => $error['message'] ?? 'فشل النشر',
                'error_details' => $error,
            ];

        } catch (\Exception $e) {
            Log::error('LinkedIn postWithLink exception: ' . $e->getMessage());
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Register image upload with LinkedIn
     */
    protected function registerImageUpload(string $accessToken, string $authorUrn): array
    {
        $payload = [
            'registerUploadRequest' => [
                'recipes' => ['urn:li:digitalmediaRecipe:feedshare-image'],
                'owner' => $authorUrn,
                'serviceRelationships' => [
                    [
                        'relationshipType' => 'OWNER',
                        'identifier' => 'urn:li:userGeneratedContent',
                    ],
                ],
            ],
        ];

        $response = Http::withToken($accessToken)
            ->withHeaders([
                'Content-Type' => 'application/json',
                'X-Restli-Protocol-Version' => '2.0.0',
            ])
            ->post("{$this->apiUrl}/assets?action=registerUpload", $payload);

        if ($response->successful()) {
            $data = $response->json();
            $uploadInfo = $data['value']['uploadMechanism']['com.linkedin.digitalmedia.uploading.MediaUploadHttpRequest'] ?? null;

            return [
                'success' => true,
                'upload_url' => $uploadInfo['uploadUrl'] ?? null,
                'asset' => $data['value']['asset'] ?? null,
            ];
        }

        return [
            'success' => false,
            'error' => 'فشل تسجيل رفع الصورة',
            'error_details' => $response->json(),
        ];
    }

    /**
     * Upload image to LinkedIn
     */
    protected function uploadImage(string $uploadUrl, string $imageUrl, string $accessToken): array
    {
        try {
            // Download image from URL
            $imageContent = Http::get($imageUrl)->body();

            // Upload to LinkedIn
            $response = Http::withToken($accessToken)
                ->withHeaders([
                    'Content-Type' => 'application/octet-stream',
                ])
                ->withBody($imageContent, 'application/octet-stream')
                ->put($uploadUrl);

            if ($response->successful() || $response->status() === 201) {
                return ['success' => true];
            }

            return [
                'success' => false,
                'error' => 'فشل رفع الصورة',
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Validate account token
     */
    public function validateToken(ConnectedAccount $account): bool
    {
        try {
            $accessToken = decrypt($account->access_token);

            $response = Http::withToken($accessToken)
                ->get("{$this->apiUrl}/me");

            return $response->successful();
        } catch (\Exception $e) {
            return false;
        }
    }

    /**
     * Delete a post from LinkedIn
     */
    public function deletePost(ConnectedAccount $account, string $postUrn): array
    {
        try {
            $accessToken = decrypt($account->access_token);

            $response = Http::withToken($accessToken)
                ->withHeaders([
                    'X-Restli-Protocol-Version' => '2.0.0',
                ])
                ->delete("{$this->apiUrl}/ugcPosts/{$postUrn}");

            if ($response->successful()) {
                return [
                    'success' => true,
                    'message' => 'تم حذف المنشور بنجاح',
                ];
            }

            return [
                'success' => false,
                'error' => 'فشل حذف المنشور',
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }
}
