<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Intervention\Image\Facades\Image;

class MediaUploadService
{
    protected $allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    protected $allowedVideoTypes = ['mp4', 'mov', 'avi', 'webm', 'm4v'];
    protected $maxImageSize = 10 * 1024 * 1024; // 10MB
    protected $maxVideoSize = 100 * 1024 * 1024; // 100MB

    /**
     * Upload an image file
     */
    public function uploadImage(UploadedFile $file, string $folder = 'images', array $options = []): array
    {
        // Validate file type
        $extension = strtolower($file->getClientOriginalExtension());
        if (!in_array($extension, $this->allowedImageTypes)) {
            return [
                'success' => false,
                'error' => 'نوع الملف غير مدعوم. الأنواع المدعومة: ' . implode(', ', $this->allowedImageTypes)
            ];
        }

        // Validate file size
        if ($file->getSize() > $this->maxImageSize) {
            return [
                'success' => false,
                'error' => 'حجم الصورة يتجاوز الحد المسموح (10MB)'
            ];
        }

        try {
            // Generate unique filename
            $filename = $this->generateFilename($file);
            $path = "{$folder}/{$filename}";

            // Resize if needed
            if (isset($options['resize'])) {
                $image = Image::make($file->getRealPath());
                $image->resize($options['resize']['width'] ?? null, $options['resize']['height'] ?? null, function ($constraint) {
                    $constraint->aspectRatio();
                    $constraint->upsize();
                });

                $content = (string) $image->encode($extension);
                Storage::disk('public')->put($path, $content);
            } else {
                Storage::disk('public')->put($path, file_get_contents($file->getRealPath()));
            }

            $url = Storage::disk('public')->url($path);

            return [
                'success' => true,
                'path' => $path,
                'url' => $url,
                'filename' => $filename,
                'size' => $file->getSize(),
                'mime_type' => $file->getMimeType(),
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => 'فشل في رفع الصورة: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Upload a video file
     */
    public function uploadVideo(UploadedFile $file, string $folder = 'videos'): array
    {
        // Validate file type
        $extension = strtolower($file->getClientOriginalExtension());
        if (!in_array($extension, $this->allowedVideoTypes)) {
            return [
                'success' => false,
                'error' => 'نوع الفيديو غير مدعوم. الأنواع المدعومة: ' . implode(', ', $this->allowedVideoTypes)
            ];
        }

        // Validate file size
        if ($file->getSize() > $this->maxVideoSize) {
            return [
                'success' => false,
                'error' => 'حجم الفيديو يتجاوز الحد المسموح (100MB)'
            ];
        }

        try {
            // Generate unique filename
            $filename = $this->generateFilename($file);
            $path = "{$folder}/{$filename}";

            Storage::disk('public')->put($path, file_get_contents($file->getRealPath()));

            $url = Storage::disk('public')->url($path);

            return [
                'success' => true,
                'path' => $path,
                'url' => $url,
                'filename' => $filename,
                'size' => $file->getSize(),
                'mime_type' => $file->getMimeType(),
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => 'فشل في رفع الفيديو: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Upload any file
     */
    public function uploadFile(UploadedFile $file, string $folder = 'files'): array
    {
        try {
            $filename = $this->generateFilename($file);
            $path = "{$folder}/{$filename}";

            Storage::disk('public')->put($path, file_get_contents($file->getRealPath()));

            $url = Storage::disk('public')->url($path);

            return [
                'success' => true,
                'path' => $path,
                'url' => $url,
                'filename' => $filename,
                'size' => $file->getSize(),
                'mime_type' => $file->getMimeType(),
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => 'فشل في رفع الملف: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Upload from URL
     */
    public function uploadFromUrl(string $url, string $folder = 'downloads'): array
    {
        try {
            $content = file_get_contents($url);
            if ($content === false) {
                return [
                    'success' => false,
                    'error' => 'فشل في تحميل الملف من الرابط'
                ];
            }

            // Get file extension from URL
            $extension = pathinfo(parse_url($url, PHP_URL_PATH), PATHINFO_EXTENSION) ?: 'jpg';
            $filename = Str::uuid() . '.' . $extension;
            $path = "{$folder}/{$filename}";

            Storage::disk('public')->put($path, $content);

            return [
                'success' => true,
                'path' => $path,
                'url' => Storage::disk('public')->url($path),
                'filename' => $filename,
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => 'فشل في تحميل الملف: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Delete a file
     */
    public function deleteFile(string $path): bool
    {
        try {
            return Storage::disk('public')->delete($path);
        } catch (\Exception $e) {
            return false;
        }
    }

    /**
     * Generate unique filename
     */
    protected function generateFilename(UploadedFile $file): string
    {
        $extension = $file->getClientOriginalExtension();
        return Str::uuid() . '.' . $extension;
    }

    /**
     * Get file URL
     */
    public function getUrl(string $path): string
    {
        return Storage::disk('public')->url($path);
    }

    /**
     * Check if file exists
     */
    public function exists(string $path): bool
    {
        return Storage::disk('public')->exists($path);
    }
}
