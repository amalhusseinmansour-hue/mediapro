<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;
use Google\Client;
use Google\Service\Drive;
use Google\Service\Drive\DriveFile;
use Google\Service\Drive\Permission;

class GoogleDriveController extends Controller
{
    private $driveService;

    public function __construct()
    {
        $this->initializeDriveService();
    }

    /**
     * Initialize Google Drive Service
     */
    private function initializeDriveService()
    {
        try {
            // Check if Google credentials file exists
            $credentialsPath = storage_path('app/google/credentials.json');

            if (!file_exists($credentialsPath)) {
                Log::warning('Google Drive credentials file not found');
                $this->driveService = null;
                return;
            }

            $client = new Client();
            $client->setApplicationName('Media Pro Social');
            $client->setScopes([Drive::DRIVE_FILE]);
            $client->setAuthConfig($credentialsPath);
            $client->setAccessType('offline');

            // Check for access token
            $tokenPath = storage_path('app/google/token.json');
            if (file_exists($tokenPath)) {
                $accessToken = json_decode(file_get_contents($tokenPath), true);
                $client->setAccessToken($accessToken);
            }

            // Refresh token if expired
            if ($client->isAccessTokenExpired()) {
                if ($client->getRefreshToken()) {
                    $client->fetchAccessTokenWithRefreshToken($client->getRefreshToken());
                    file_put_contents($tokenPath, json_encode($client->getAccessToken()));
                }
            }

            $this->driveService = new Drive($client);
        } catch (\Exception $e) {
            Log::error('Failed to initialize Google Drive service', [
                'error' => $e->getMessage()
            ]);
            $this->driveService = null;
        }
    }

    /**
     * Upload file to Google Drive
     */
    public function upload(Request $request): JsonResponse
    {
        try {
            // Validate request
            $validator = Validator::make($request->all(), [
                'file_data' => 'required|string',
                'file_name' => 'required|string',
                'folder_id' => 'nullable|string',
                'mime_type' => 'nullable|string',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'بيانات غير صحيحة',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Check if Drive service is initialized
            if ($this->driveService === null) {
                return response()->json([
                    'success' => false,
                    'message' => 'Google Drive API غير مكون. يرجى إضافة ملف credentials.json',
                    'note' => 'See documentation for Google Drive API setup'
                ], 500);
            }

            // Decode base64 file
            $fileData = base64_decode($request->file_data);
            $fileName = $request->file_name;
            $mimeType = $request->mime_type ?? 'application/octet-stream';
            $folderId = $request->folder_id ?? env('GOOGLE_DRIVE_FOLDER_ID');

            // Create file metadata
            $fileMetadata = new DriveFile([
                'name' => $fileName,
                'parents' => $folderId ? [$folderId] : []
            ]);

            // Upload file
            $file = $this->driveService->files->create(
                $fileMetadata,
                [
                    'data' => $fileData,
                    'mimeType' => $mimeType,
                    'uploadType' => 'multipart',
                    'fields' => 'id,name,webViewLink,webContentLink'
                ]
            );

            // Make file publicly accessible
            $this->makeFilePublic($file->id);

            return response()->json([
                'success' => true,
                'message' => 'تم رفع الملف بنجاح',
                'data' => [
                    'file_id' => $file->id,
                    'file_name' => $file->name,
                    'file_url' => 'https://drive.google.com/uc?export=view&id=' . $file->id,
                    'web_view_link' => $file->webViewLink,
                    'web_content_link' => $file->webContentLink ?? null,
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Google Drive upload failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'فشل رفع الملف',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Share file (make it publicly accessible)
     */
    public function share(Request $request): JsonResponse
    {
        try {
            $validator = Validator::make($request->all(), [
                'file_id' => 'required|string',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'بيانات غير صحيحة',
                    'errors' => $validator->errors()
                ], 422);
            }

            if ($this->driveService === null) {
                return response()->json([
                    'success' => false,
                    'message' => 'Google Drive API غير مكون'
                ], 500);
            }

            $this->makeFilePublic($request->file_id);

            return response()->json([
                'success' => true,
                'message' => 'تم جعل الملف عاماً بنجاح'
            ]);

        } catch (\Exception $e) {
            Log::error('Google Drive share failed', [
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'فشل في جعل الملف عاماً',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Make file publicly accessible
     */
    private function makeFilePublic(string $fileId): void
    {
        try {
            $permission = new Permission([
                'type' => 'anyone',
                'role' => 'reader',
            ]);

            $this->driveService->permissions->create($fileId, $permission);
        } catch (\Exception $e) {
            Log::warning('Failed to make file public', [
                'file_id' => $fileId,
                'error' => $e->getMessage()
            ]);
        }
    }

    /**
     * Delete file from Google Drive
     */
    public function delete(Request $request): JsonResponse
    {
        try {
            $validator = Validator::make($request->all(), [
                'file_id' => 'required|string',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'بيانات غير صحيحة',
                    'errors' => $validator->errors()
                ], 422);
            }

            if ($this->driveService === null) {
                return response()->json([
                    'success' => false,
                    'message' => 'Google Drive API غير مكون'
                ], 500);
            }

            $this->driveService->files->delete($request->file_id);

            return response()->json([
                'success' => true,
                'message' => 'تم حذف الملف بنجاح'
            ]);

        } catch (\Exception $e) {
            Log::error('Google Drive delete failed', [
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'فشل حذف الملف',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get file information
     */
    public function getFile(Request $request, string $fileId): JsonResponse
    {
        try {
            if ($this->driveService === null) {
                return response()->json([
                    'success' => false,
                    'message' => 'Google Drive API غير مكون'
                ], 500);
            }

            $file = $this->driveService->files->get($fileId, [
                'fields' => 'id,name,mimeType,size,createdTime,modifiedTime,webViewLink,webContentLink'
            ]);

            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $file->id,
                    'name' => $file->name,
                    'mime_type' => $file->mimeType,
                    'size' => $file->size,
                    'created_at' => $file->createdTime,
                    'modified_at' => $file->modifiedTime,
                    'web_view_link' => $file->webViewLink,
                    'web_content_link' => $file->webContentLink ?? null,
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Google Drive get file failed', [
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'فشل في جلب معلومات الملف',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Check Google Drive configuration status
     */
    public function status(): JsonResponse
    {
        $credentialsPath = storage_path('app/google/credentials.json');
        $tokenPath = storage_path('app/google/token.json');

        return response()->json([
            'success' => true,
            'data' => [
                'configured' => $this->driveService !== null,
                'credentials_exists' => file_exists($credentialsPath),
                'token_exists' => file_exists($tokenPath),
                'folder_id' => env('GOOGLE_DRIVE_FOLDER_ID'),
            ]
        ]);
    }
}
