<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

/**
 * Ayrshare API Controller
 * يتعامل مع جميع طلبات Ayrshare API
 *
 * يجب إضافة هذا Controller في: app/Http/Controllers/Api/AyrshareController.php
 */
class AyrshareController extends Controller
{
    private $apiKey;
    private $baseUrl = 'https://app.ayrshare.com/api';

    public function __construct()
    {
        $this->apiKey = env('AYRSHARE_API_KEY');
    }

    /**
     * إنشاء Ayrshare Profile لمستخدم جديد
     * هذا هو الـ workflow الصحيح لـ Business Plan
     *
     * POST /api/ayrshare/create-profile
     */
    public function createProfile(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|string',
            'title' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صالحة',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $userId = $request->input('user_id');
            $title = $request->input('title', 'User ' . $userId);

            // إنشاء Profile في Ayrshare
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/json',
            ])->post($this->baseUrl . '/profiles/profile', [
                'title' => $title,
            ]);

            if ($response->successful()) {
                $data = $response->json();
                $profileKey = $data['profileKey'];

                // حفظ Profile Key في قاعدة البيانات
                $this->saveUserProfile($userId, $profileKey, $title);

                return response()->json([
                    'success' => true,
                    'message' => 'تم إنشاء Profile بنجاح',
                    'data' => [
                        'profile_key' => $profileKey,
                        'title' => $title,
                    ],
                ]);
            } else {
                throw new \Exception($response->json()['message'] ?? 'فشل في إنشاء Profile');
            }
        } catch (\Exception $e) {
            Log::error('Ayrshare create profile error', [
                'error' => $e->getMessage(),
                'user_id' => $request->input('user_id'),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'فشل في إنشاء Profile: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * إنشاء JWT URL للـ Single Sign-On
     * المستخدم يفتح هذا الرابط لربط حساباته
     *
     * POST /api/ayrshare/generate-jwt
     */
    public function generateJWT(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صالحة',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $userId = $request->input('user_id');

            // الحصول على Profile Key للمستخدم من قاعدة البيانات
            $profileKey = $this->getUserProfileKey($userId);

            if (!$profileKey) {
                // إنشاء Profile جديد إذا لم يكن موجود
                $createResponse = $this->createProfile($request);
                $createData = $createResponse->getData(true);

                if (!$createData['success']) {
                    throw new \Exception('فشل في إنشاء Profile');
                }

                $profileKey = $createData['data']['profile_key'];
            }

            // إنشاء JWT من Ayrshare
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/json',
            ])->post($this->baseUrl . '/profiles/generateJWT', [
                'profileKey' => $profileKey,
                'redirect' => env('APP_URL') . '/oauth-success',
            ]);

            if ($response->successful()) {
                $data = $response->json();

                return response()->json([
                    'success' => true,
                    'message' => 'تم إنشاء JWT بنجاح',
                    'data' => [
                        'url' => $data['url'],
                        'profile_key' => $profileKey,
                    ],
                ]);
            } else {
                throw new \Exception($response->json()['message'] ?? 'فشل في إنشاء JWT');
            }
        } catch (\Exception $e) {
            Log::error('Ayrshare JWT generation error', [
                'error' => $e->getMessage(),
                'user_id' => $request->input('user_id'),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'فشل في إنشاء JWT: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Callback من Ayrshare بعد ربط الحساب
     *
     * GET /api/ayrshare/oauth-callback
     */
    public function oauthCallback(Request $request)
    {
        try {
            $profileKey = $request->query('profileKey');
            $status = $request->query('status');

            if ($status === 'success') {
                // حفظ معلومات الحساب المربوط في قاعدة البيانات
                $this->saveConnectedAccount($profileKey);

                // إعادة توجيه المستخدم إلى Deep Link في التطبيق
                return redirect('mprosocial://oauth-success?profile_key=' . $profileKey);
            } else {
                return redirect('mprosocial://oauth-failed?error=user_cancelled');
            }
        } catch (\Exception $e) {
            Log::error('Ayrshare OAuth callback error', ['error' => $e->getMessage()]);
            return redirect('mprosocial://oauth-failed?error=server_error');
        }
    }

    /**
     * الحصول على قائمة الحسابات المربوطة
     *
     * GET /api/ayrshare/profiles
     */
    public function getProfiles(Request $request)
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->get($this->baseUrl . '/profiles');

            if ($response->successful()) {
                return response()->json([
                    'success' => true,
                    'data' => $response->json(),
                ]);
            } else {
                throw new \Exception('فشل في جلب الحسابات');
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * نشر محتوى على منصات social media
     * يستخدم Profile Key للنشر نيابة عن المستخدم
     *
     * POST /api/ayrshare/post
     */
    public function publishPost(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|string',
            'platforms' => 'required|array',
            'platforms.*' => 'string|in:facebook,instagram,twitter,linkedin,tiktok,youtube,pinterest',
            'post' => 'required|string',
            'mediaUrls' => 'nullable|array',
            'scheduleDate' => 'nullable|date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صالحة',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $userId = $request->input('user_id');

            // الحصول على Profile Key للمستخدم
            $profileKey = $this->getUserProfileKey($userId);

            if (!$profileKey) {
                throw new \Exception('المستخدم ليس لديه Ayrshare Profile. يرجى ربط الحسابات أولاً.');
            }

            $postData = [
                'post' => $request->input('post'),
                'platforms' => $request->input('platforms'),
                'profileKey' => $profileKey, // مهم جداً!
            ];

            if ($request->has('mediaUrls')) {
                $postData['mediaUrls'] = $request->input('mediaUrls');
            }

            if ($request->has('scheduleDate')) {
                $postData['scheduleDate'] = $request->input('scheduleDate');
            }

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/json',
            ])->post($this->baseUrl . '/post', $postData);

            if ($response->successful()) {
                $data = $response->json();

                // حفظ في قاعدة البيانات
                $this->savePost($data);

                return response()->json([
                    'success' => true,
                    'message' => 'تم النشر بنجاح',
                    'data' => $data,
                ]);
            } else {
                throw new \Exception($response->json()['message'] ?? 'فشل النشر');
            }
        } catch (\Exception $e) {
            Log::error('Ayrshare post error', ['error' => $e->getMessage()]);

            return response()->json([
                'success' => false,
                'message' => 'فشل النشر: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * حذف منشور
     *
     * DELETE /api/ayrshare/post/{postId}
     */
    public function deletePost($postId)
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->delete($this->baseUrl . '/post', [
                'id' => $postId,
            ]);

            if ($response->successful()) {
                return response()->json([
                    'success' => true,
                    'message' => 'تم حذف المنشور بنجاح',
                ]);
            } else {
                throw new \Exception('فشل حذف المنشور');
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * الحصول على إحصائيات الحسابات
     *
     * GET /api/ayrshare/analytics
     */
    public function getAnalytics(Request $request)
    {
        try {
            $platforms = $request->query('platforms');

            $url = $this->baseUrl . '/analytics';
            if ($platforms) {
                $url .= '?platforms=' . $platforms;
            }

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->get($url);

            if ($response->successful()) {
                return response()->json([
                    'success' => true,
                    'data' => $response->json(),
                ]);
            } else {
                throw new \Exception('فشل جلب الإحصائيات');
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * الحصول على إحصائيات منشور معين
     *
     * GET /api/ayrshare/analytics/post/{postId}
     */
    public function getPostAnalytics($postId)
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->get($this->baseUrl . '/post/' . $postId);

            if ($response->successful()) {
                return response()->json([
                    'success' => true,
                    'data' => $response->json(),
                ]);
            } else {
                throw new \Exception('فشل جلب إحصائيات المنشور');
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * الحصول على تاريخ المنشورات
     *
     * GET /api/ayrshare/history
     */
    public function getPostHistory(Request $request)
    {
        try {
            $limit = $request->query('limit', 50);
            $platform = $request->query('platform');

            $queryParams = ['limit' => $limit];
            if ($platform) {
                $queryParams['platform'] = $platform;
            }

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->get($this->baseUrl . '/history', $queryParams);

            if ($response->successful()) {
                return response()->json([
                    'success' => true,
                    'data' => $response->json(),
                ]);
            } else {
                throw new \Exception('فشل جلب التاريخ');
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * فصل حساب مرتبط
     *
     * DELETE /api/ayrshare/profile/{profileKey}
     */
    public function unlinkProfile($profileKey)
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->delete($this->baseUrl . '/profiles/' . $profileKey);

            if ($response->successful()) {
                return response()->json([
                    'success' => true,
                    'message' => 'تم فصل الحساب بنجاح',
                ]);
            } else {
                throw new \Exception('فشل فصل الحساب');
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * رفع صورة/فيديو
     *
     * POST /api/ayrshare/upload
     */
    public function uploadMedia(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'file' => 'required|file|max:50000', // 50MB max
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'ملف غير صالح',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $file = $request->file('file');

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->attach(
                'file',
                file_get_contents($file->getRealPath()),
                $file->getClientOriginalName()
            )->post($this->baseUrl . '/upload');

            if ($response->successful()) {
                $data = $response->json();

                return response()->json([
                    'success' => true,
                    'data' => [
                        'url' => $data['url'],
                    ],
                ]);
            } else {
                throw new \Exception('فشل رفع الملف');
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * التحقق من حالة API
     *
     * GET /api/ayrshare/status
     */
    public function checkStatus()
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->get($this->baseUrl . '/user');

            return response()->json([
                'success' => $response->successful(),
                'message' => $response->successful() ? 'API يعمل بشكل صحيح' : 'API غير متاح',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'API غير متاح',
            ], 500);
        }
    }

    /**
     * الحصول على أفضل أوقات النشر
     *
     * GET /api/ayrshare/best-times
     */
    public function getBestTimes(Request $request)
    {
        try {
            $platform = $request->query('platform');

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->get($this->baseUrl . '/analytics/social', [
                'platforms' => $platform,
            ]);

            if ($response->successful()) {
                return response()->json([
                    'success' => true,
                    'data' => $response->json(),
                ]);
            } else {
                throw new \Exception('فشل جلب أفضل الأوقات');
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    // ========== Helper Methods ==========

    /**
     * حفظ Profile Key للمستخدم في قاعدة البيانات
     */
    private function saveUserProfile($userId, $profileKey, $title)
    {
        // حفظ في جدول users أو ayrshare_profiles
        \DB::table('users')->where('id', $userId)->update([
            'ayrshare_profile_key' => $profileKey,
            'ayrshare_profile_title' => $title,
            'updated_at' => now(),
        ]);
    }

    /**
     * الحصول على Profile Key للمستخدم
     */
    private function getUserProfileKey($userId)
    {
        $user = \DB::table('users')->where('id', $userId)->first();
        return $user->ayrshare_profile_key ?? null;
    }

    /**
     * حفظ معلومات الحساب المربوط
     */
    private function saveConnectedAccount($profileKey)
    {
        // حفظ في جدول social_accounts
        // يمكن استخدام model SocialAccount
    }

    /**
     * حفظ معلومات المنشور
     */
    private function savePost($postData)
    {
        // حفظ في جدول posts
        // يمكن استخدام model Post
    }
}
