<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;

class CloudinaryController extends Controller
{
    protected string $cloudName;
    protected string $apiKey;
    protected string $apiSecret;

    public function __construct()
    {
        $this->cloudName = env('CLOUDINARY_CLOUD_NAME', '');
        $this->apiKey = env('CLOUDINARY_API_KEY', '');
        $this->apiSecret = env('CLOUDINARY_API_SECRET', '');
    }

    /**
     * Check if Cloudinary is configured
     */
    protected function isConfigured(): bool
    {
        return !empty($this->cloudName) && !empty($this->apiKey) && !empty($this->apiSecret);
    }

    /**
     * Upload image to Cloudinary
     */
    public function upload(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'image' => 'required|string', // base64 image
            'folder' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        if (!$this->isConfigured()) {
            return response()->json([
                'success' => false,
                'message' => 'Cloudinary is not configured'
            ], 500);
        }

        try {
            $timestamp = time();
            $folder = $request->folder ?? 'social_media';

            // Generate signature
            $signature = $this->generateSignature($timestamp, $folder);

            // Upload to Cloudinary
            $response = Http::asForm()->post(
                "https://api.cloudinary.com/v1_1/{$this->cloudName}/image/upload",
                [
                    'file' => 'data:image/jpeg;base64,' . $request->image,
                    'api_key' => $this->apiKey,
                    'timestamp' => $timestamp,
                    'signature' => $signature,
                    'folder' => $folder,
                ]
            );

            if ($response->successful()) {
                $data = $response->json();

                Log::info('✅ Image uploaded to Cloudinary', [
                    'public_id' => $data['public_id'],
                    'url' => $data['secure_url'],
                ]);

                return response()->json([
                    'success' => true,
                    'public_id' => $data['public_id'],
                    'url' => $data['secure_url'],
                    'width' => $data['width'],
                    'height' => $data['height'],
                    'format' => $data['format'],
                    'bytes' => $data['bytes'],
                ]);
            }

            Log::error('❌ Cloudinary upload failed', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to upload image to Cloudinary',
                'error' => $response->json()['error']['message'] ?? 'Unknown error',
            ], 500);

        } catch (\Exception $e) {
            Log::error('❌ Cloudinary upload exception', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Error uploading image',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Apply transformation to an image
     */
    public function transform(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'public_id' => 'required|string',
            'transformations' => 'required|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        if (!$this->isConfigured()) {
            return response()->json([
                'success' => false,
                'message' => 'Cloudinary is not configured'
            ], 500);
        }

        try {
            $publicId = $request->public_id;
            $transformations = implode('/', $request->transformations);

            $transformedUrl = "https://res.cloudinary.com/{$this->cloudName}/image/upload/{$transformations}/{$publicId}";

            return response()->json([
                'success' => true,
                'url' => $transformedUrl,
                'public_id' => $publicId,
                'transformations' => $request->transformations,
            ]);

        } catch (\Exception $e) {
            Log::error('❌ Cloudinary transform error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Error applying transformation',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Remove background from image
     */
    public function removeBackground(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'image' => 'required|string', // base64 or public_id
            'is_public_id' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $publicId = $request->image;

            // If it's a base64 image, upload first
            if (!$request->is_public_id) {
                $uploadResult = $this->uploadBase64($request->image, 'bg_remove');
                if (!$uploadResult['success']) {
                    return response()->json($uploadResult, 500);
                }
                $publicId = $uploadResult['public_id'];
            }

            // Apply background removal
            $transformedUrl = "https://res.cloudinary.com/{$this->cloudName}/image/upload/e_background_removal/{$publicId}";

            return response()->json([
                'success' => true,
                'url' => $transformedUrl,
                'public_id' => $publicId,
                'message' => 'Background removed successfully',
            ]);

        } catch (\Exception $e) {
            Log::error('❌ Background removal error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Error removing background',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Apply filter to image
     */
    public function applyFilter(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'image' => 'required|string',
            'filter' => 'required|string',
            'is_public_id' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $publicId = $request->image;

            // If it's a base64 image, upload first
            if (!$request->is_public_id) {
                $uploadResult = $this->uploadBase64($request->image, 'filters');
                if (!$uploadResult['success']) {
                    return response()->json($uploadResult, 500);
                }
                $publicId = $uploadResult['public_id'];
            }

            // Get filter transformation
            $filterTransform = $this->getFilterTransformation($request->filter);
            $transformString = implode('/', $filterTransform);

            $transformedUrl = "https://res.cloudinary.com/{$this->cloudName}/image/upload/{$transformString}/{$publicId}";

            return response()->json([
                'success' => true,
                'url' => $transformedUrl,
                'public_id' => $publicId,
                'filter' => $request->filter,
                'message' => 'Filter applied successfully',
            ]);

        } catch (\Exception $e) {
            Log::error('❌ Filter error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Error applying filter',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Enhance image quality
     */
    public function enhance(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'image' => 'required|string',
            'is_public_id' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $publicId = $request->image;

            if (!$request->is_public_id) {
                $uploadResult = $this->uploadBase64($request->image, 'enhanced');
                if (!$uploadResult['success']) {
                    return response()->json($uploadResult, 500);
                }
                $publicId = $uploadResult['public_id'];
            }

            // Apply enhancement transformations
            $transforms = 'e_improve/e_sharpen:100/e_auto_brightness/e_auto_contrast/q_auto:best';
            $transformedUrl = "https://res.cloudinary.com/{$this->cloudName}/image/upload/{$transforms}/{$publicId}";

            return response()->json([
                'success' => true,
                'url' => $transformedUrl,
                'public_id' => $publicId,
                'message' => 'Image enhanced successfully',
            ]);

        } catch (\Exception $e) {
            Log::error('❌ Enhancement error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Error enhancing image',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Resize image for social media
     */
    public function resize(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'image' => 'required|string',
            'width' => 'required|integer|min:50|max:4096',
            'height' => 'required|integer|min:50|max:4096',
            'crop' => 'nullable|string|in:fill,fit,scale,crop,thumb',
            'is_public_id' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $publicId = $request->image;

            if (!$request->is_public_id) {
                $uploadResult = $this->uploadBase64($request->image, 'resized');
                if (!$uploadResult['success']) {
                    return response()->json($uploadResult, 500);
                }
                $publicId = $uploadResult['public_id'];
            }

            $crop = $request->crop ?? 'fill';
            $width = $request->width;
            $height = $request->height;

            $transforms = "c_{$crop},w_{$width},h_{$height}/q_auto:best";
            $transformedUrl = "https://res.cloudinary.com/{$this->cloudName}/image/upload/{$transforms}/{$publicId}";

            return response()->json([
                'success' => true,
                'url' => $transformedUrl,
                'public_id' => $publicId,
                'width' => $width,
                'height' => $height,
                'message' => 'Image resized successfully',
            ]);

        } catch (\Exception $e) {
            Log::error('❌ Resize error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Error resizing image',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get available filters
     */
    public function getFilters()
    {
        return response()->json([
            'success' => true,
            'filters' => [
                ['id' => 'grayscale', 'name' => 'أبيض وأسود', 'icon' => '⬛'],
                ['id' => 'sepia', 'name' => 'بني قديم', 'icon' => '🟤'],
                ['id' => 'vintage', 'name' => 'كلاسيكي', 'icon' => '📷'],
                ['id' => 'vivid', 'name' => 'حيوي', 'icon' => '🌈'],
                ['id' => 'warm', 'name' => 'دافئ', 'icon' => '🔥'],
                ['id' => 'cool', 'name' => 'بارد', 'icon' => '❄️'],
                ['id' => 'dramatic', 'name' => 'درامي', 'icon' => '🎭'],
                ['id' => 'bright', 'name' => 'مشرق', 'icon' => '☀️'],
                ['id' => 'dark', 'name' => 'داكن', 'icon' => '🌙'],
                ['id' => 'soft', 'name' => 'ناعم', 'icon' => '☁️'],
                ['id' => 'sharp', 'name' => 'حاد', 'icon' => '🔪'],
                ['id' => 'neon', 'name' => 'نيون', 'icon' => '💜'],
            ],
            'effects' => [
                ['id' => 'oil_paint', 'name' => 'رسم زيتي', 'icon' => '🎨'],
                ['id' => 'cartoon', 'name' => 'كرتون', 'icon' => '🖼️'],
                ['id' => 'pixelate', 'name' => 'بكسل', 'icon' => '👾'],
                ['id' => 'vignette', 'name' => 'إطار داكن', 'icon' => '🖤'],
                ['id' => 'shadow', 'name' => 'ظل', 'icon' => '👤'],
            ],
            'presets' => [
                'instagram_post' => ['width' => 1080, 'height' => 1080],
                'instagram_story' => ['width' => 1080, 'height' => 1920],
                'facebook_post' => ['width' => 1200, 'height' => 630],
                'twitter_post' => ['width' => 1200, 'height' => 675],
                'youtube_thumbnail' => ['width' => 1280, 'height' => 720],
            ],
        ]);
    }

    /**
     * Get Cloudinary status
     */
    public function status()
    {
        return response()->json([
            'success' => true,
            'configured' => $this->isConfigured(),
            'cloud_name' => $this->isConfigured() ? substr($this->cloudName, 0, 3) . '***' : null,
        ]);
    }

    /**
     * Helper: Upload base64 image
     */
    protected function uploadBase64(string $base64Image, string $folder): array
    {
        try {
            $timestamp = time();
            $signature = $this->generateSignature($timestamp, $folder);

            $response = Http::asForm()->post(
                "https://api.cloudinary.com/v1_1/{$this->cloudName}/image/upload",
                [
                    'file' => 'data:image/jpeg;base64,' . $base64Image,
                    'api_key' => $this->apiKey,
                    'timestamp' => $timestamp,
                    'signature' => $signature,
                    'folder' => $folder,
                ]
            );

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'success' => true,
                    'public_id' => $data['public_id'],
                    'url' => $data['secure_url'],
                ];
            }

            return [
                'success' => false,
                'message' => 'Upload failed',
            ];
        } catch (\Exception $e) {
            return [
                'success' => false,
                'message' => $e->getMessage(),
            ];
        }
    }

    /**
     * Helper: Generate signature
     */
    protected function generateSignature(int $timestamp, string $folder): string
    {
        $params = "folder={$folder}&timestamp={$timestamp}";
        return sha1($params . $this->apiSecret);
    }

    /**
     * Helper: Get filter transformation
     */
    protected function getFilterTransformation(string $filter): array
    {
        return match($filter) {
            'grayscale' => ['e_grayscale'],
            'sepia' => ['e_sepia:80'],
            'vintage' => ['e_sepia:50', 'e_vignette:30'],
            'vivid' => ['e_vibrance:50', 'e_saturation:30'],
            'warm' => ['e_tint:40:orange'],
            'cool' => ['e_tint:40:blue'],
            'dramatic' => ['e_contrast:30', 'e_saturation:-20', 'e_vignette:40'],
            'bright' => ['e_brightness:20', 'e_contrast:10'],
            'dark' => ['e_brightness:-30', 'e_contrast:20'],
            'soft' => ['e_blur:100', 'e_brightness:10'],
            'sharp' => ['e_sharpen:150', 'e_contrast:15'],
            'neon' => ['e_negate', 'e_tint:80:ff00ff:0p:00ffff:100p'],
            'oil_paint' => ['e_oil_paint:70'],
            'cartoon' => ['e_cartoonify'],
            'pixelate' => ['e_pixelate:10'],
            'vignette' => ['e_vignette:60'],
            'shadow' => ['e_shadow:50'],
            default => [],
        };
    }
}
