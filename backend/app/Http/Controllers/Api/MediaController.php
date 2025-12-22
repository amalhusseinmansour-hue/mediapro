<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\MediaUploadService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class MediaController extends Controller
{
    protected $mediaService;

    public function __construct(MediaUploadService $mediaService)
    {
        $this->mediaService = $mediaService;
    }

    /**
     * Upload image
     */
    public function uploadImage(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'image' => 'required|image|max:10240', // 10MB max
            'folder' => 'nullable|string|max:50',
            'resize_width' => 'nullable|integer|min:100|max:2000',
            'resize_height' => 'nullable|integer|min:100|max:2000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $options = [];
        if ($request->has('resize_width') || $request->has('resize_height')) {
            $options['resize'] = [
                'width' => $request->resize_width,
                'height' => $request->resize_height,
            ];
        }

        $folder = $request->folder ?? 'images/user_' . $request->user()->id;
        $result = $this->mediaService->uploadImage($request->file('image'), $folder, $options);

        if (!$result['success']) {
            return response()->json($result, 400);
        }

        return response()->json([
            'success' => true,
            'message' => 'تم رفع الصورة بنجاح',
            'data' => $result,
        ]);
    }

    /**
     * Upload video
     */
    public function uploadVideo(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'video' => 'required|mimetypes:video/mp4,video/quicktime,video/x-msvideo,video/webm|max:102400', // 100MB max
            'folder' => 'nullable|string|max:50',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $folder = $request->folder ?? 'videos/user_' . $request->user()->id;
        $result = $this->mediaService->uploadVideo($request->file('video'), $folder);

        if (!$result['success']) {
            return response()->json($result, 400);
        }

        return response()->json([
            'success' => true,
            'message' => 'تم رفع الفيديو بنجاح',
            'data' => $result,
        ]);
    }

    /**
     * Upload any file
     */
    public function uploadFile(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'file' => 'required|file|max:51200', // 50MB max
            'folder' => 'nullable|string|max:50',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $folder = $request->folder ?? 'files/user_' . $request->user()->id;
        $result = $this->mediaService->uploadFile($request->file('file'), $folder);

        if (!$result['success']) {
            return response()->json($result, 400);
        }

        return response()->json([
            'success' => true,
            'message' => 'تم رفع الملف بنجاح',
            'data' => $result,
        ]);
    }

    /**
     * Upload from URL
     */
    public function uploadFromUrl(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'url' => 'required|url',
            'folder' => 'nullable|string|max:50',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $folder = $request->folder ?? 'downloads/user_' . $request->user()->id;
        $result = $this->mediaService->uploadFromUrl($request->url, $folder);

        if (!$result['success']) {
            return response()->json($result, 400);
        }

        return response()->json([
            'success' => true,
            'message' => 'تم تحميل الملف بنجاح',
            'data' => $result,
        ]);
    }

    /**
     * Delete file
     */
    public function deleteFile(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'path' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        // Security check - ensure user can only delete their own files
        $path = $request->path;
        $userId = $request->user()->id;

        if (!str_contains($path, "user_{$userId}") && $request->user()->user_type !== 'admin') {
            return response()->json([
                'success' => false,
                'error' => 'غير مصرح لك بحذف هذا الملف'
            ], 403);
        }

        $deleted = $this->mediaService->deleteFile($path);

        return response()->json([
            'success' => $deleted,
            'message' => $deleted ? 'تم حذف الملف بنجاح' : 'فشل في حذف الملف',
        ]);
    }

    /**
     * Upload multiple images
     */
    public function uploadMultipleImages(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'images' => 'required|array|min:1|max:10',
            'images.*' => 'image|max:10240',
            'folder' => 'nullable|string|max:50',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $folder = $request->folder ?? 'images/user_' . $request->user()->id;
        $results = [];
        $successCount = 0;

        foreach ($request->file('images') as $image) {
            $result = $this->mediaService->uploadImage($image, $folder);
            $results[] = $result;
            if ($result['success']) {
                $successCount++;
            }
        }

        return response()->json([
            'success' => $successCount > 0,
            'message' => "تم رفع {$successCount} من " . count($results) . " صورة",
            'data' => $results,
        ]);
    }
}
