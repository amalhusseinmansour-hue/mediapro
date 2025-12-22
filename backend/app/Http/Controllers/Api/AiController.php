<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AiGeneration;
use App\Models\BrandKit;
use App\Services\AdvancedAIContentService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Http;

class AiController extends Controller
{
    /**
     * التحقق من حدود الاشتراك للفيديو
     */
    private function checkVideoLimit($user)
    {
        $subscription = $user->subscription;

        if (!$subscription) {
            return [
                'allowed' => false,
                'error' => 'يجب الاشتراك لاستخدام ميزة توليد الفيديو',
                'error_en' => 'Subscription required to use video generation',
            ];
        }

        if ($subscription->hasReachedVideoLimit()) {
            $remaining = $subscription->getRemainingVideos();
            $limit = $subscription->max_ai_videos ?? 0;
            return [
                'allowed' => false,
                'error' => "لقد وصلت للحد الأقصى من الفيديوهات ({$limit} فيديو شهرياً)",
                'error_en' => "You have reached the video limit ({$limit} videos/month)",
                'remaining' => $remaining,
                'limit' => $limit,
            ];
        }

        return [
            'allowed' => true,
            'remaining' => $subscription->getRemainingVideos(),
            'limit' => $subscription->max_ai_videos ?? 0,
            'max_duration' => $subscription->getMaxVideoDuration(),
            'quality' => $subscription->getAllowedVideoQuality(),
        ];
    }

    /**
     * التحقق من حدود الاشتراك للصور
     */
    private function checkImageLimit($user)
    {
        $subscription = $user->subscription;

        if (!$subscription) {
            return [
                'allowed' => false,
                'error' => 'يجب الاشتراك لاستخدام ميزة توليد الصور',
                'error_en' => 'Subscription required to use image generation',
            ];
        }

        if ($subscription->hasReachedImageLimit()) {
            $limit = $subscription->max_ai_images ?? 0;
            return [
                'allowed' => false,
                'error' => "لقد وصلت للحد الأقصى من الصور ({$limit} صورة شهرياً)",
                'error_en' => "You have reached the image limit ({$limit} images/month)",
                'remaining' => 0,
                'limit' => $limit,
            ];
        }

        return [
            'allowed' => true,
            'remaining' => $subscription->getRemainingImages(),
            'limit' => $subscription->max_ai_images ?? 0,
        ];
    }

    /**
     * التحقق من حدود الاشتراك للنصوص
     */
    private function checkTextLimit($user)
    {
        $subscription = $user->subscription;

        if (!$subscription) {
            return [
                'allowed' => false,
                'error' => 'يجب الاشتراك لاستخدام ميزة توليد النصوص',
                'error_en' => 'Subscription required to use text generation',
            ];
        }

        if ($subscription->hasReachedTextLimit()) {
            $limit = $subscription->max_ai_texts ?? 0;
            return [
                'allowed' => false,
                'error' => "لقد وصلت للحد الأقصى من النصوص ({$limit} نص شهرياً)",
                'error_en' => "You have reached the text limit ({$limit} texts/month)",
                'remaining' => 0,
                'limit' => $limit,
            ];
        }

        return [
            'allowed' => true,
            'remaining' => $subscription->getRemainingTexts(),
            'limit' => $subscription->max_ai_texts ?? 0,
        ];
    }

    // Generate Image using AI (Gemini API)
    public function generateImage(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'prompt' => 'required|string|min:3',
            'brand_kit_id' => 'nullable|exists:brand_kits,id',
            'width' => 'nullable|integer|min:256|max:1024',
            'height' => 'nullable|integer|min:256|max:1024',
            'negative_prompt' => 'nullable|string',
            'style' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();

        // Check subscription image limit
        $limitCheck = $this->checkImageLimit($user);
        if (!$limitCheck['allowed']) {
            return response()->json([
                'success' => false,
                'message' => $limitCheck['error'],
                'error' => $limitCheck['error_en'],
                'limit_reached' => true,
                'remaining' => $limitCheck['remaining'] ?? 0,
                'limit' => $limitCheck['limit'] ?? 0,
            ], 403);
        }

        $width = $request->width ?? 512;
        $height = $request->height ?? 512;

        // Create AI Generation record
        $aiGeneration = AiGeneration::create([
            'user_id' => $user->id,
            'brand_kit_id' => $request->brand_kit_id,
            'type' => AiGeneration::TYPE_IMAGE,
            'prompt' => $request->prompt,
            'settings' => [
                'width' => $width,
                'height' => $height,
                'style' => $request->style,
                'negative_prompt' => $request->negative_prompt,
            ],
            'status' => AiGeneration::STATUS_PROCESSING,
        ]);

        try {
            // Get Gemini API Key from environment
            $geminiApiKey = env('GEMINI_API_KEY', env('GOOGLE_AI_API_KEY', ''));

            if (empty($geminiApiKey)) {
                throw new \Exception('Gemini API key not configured on server');
            }

            // Prepare enhanced prompt
            $enhancedPrompt = $request->prompt;
            if (!str_contains(strtolower($enhancedPrompt), 'quality')) {
                $enhancedPrompt .= ', high quality, detailed, professional';
            }
            if ($request->negative_prompt) {
                $enhancedPrompt .= '. Avoid: ' . $request->negative_prompt;
            }

            // Call Gemini API
            $response = Http::timeout(120)->post(
                "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key={$geminiApiKey}",
                [
                    'contents' => [
                        [
                            'parts' => [
                                ['text' => "Generate an image: {$enhancedPrompt}"]
                            ]
                        ]
                    ],
                    'generationConfig' => [
                        'responseModalities' => ['image', 'text'],
                        'temperature' => 1.0,
                    ]
                ]
            );

            if ($response->successful()) {
                $data = $response->json();

                // Extract image from response
                if (isset($data['candidates'][0]['content']['parts'])) {
                    foreach ($data['candidates'][0]['content']['parts'] as $part) {
                        if (isset($part['inlineData']['data'])) {
                            $imageBase64 = $part['inlineData']['data'];

                            // Save image to storage
                            $fileName = 'ai_images/' . uniqid() . '_' . time() . '.png';
                            $imagePath = storage_path('app/public/' . $fileName);

                            // Ensure directory exists
                            if (!file_exists(dirname($imagePath))) {
                                mkdir(dirname($imagePath), 0755, true);
                            }

                            file_put_contents($imagePath, base64_decode($imageBase64));

                            $imageUrl = url('storage/' . $fileName);

                            $result = [
                                'image_url' => $imageUrl,
                                'image_base64' => $imageBase64,
                                'generated_at' => now()->toISOString(),
                            ];

                            $aiGeneration->update([
                                'result' => json_encode($result),
                                'status' => AiGeneration::STATUS_COMPLETED,
                                'tokens_used' => 1000,
                            ]);

                            // Increment image count
                            $user->subscription?->incrementImageCount();

                            return response()->json([
                                'success' => true,
                                'message' => 'Image generated successfully',
                                'data' => [
                                    'id' => $aiGeneration->id,
                                    'image_url' => $imageUrl,
                                    'image_base64' => $imageBase64,
                                    'prompt' => $request->prompt,
                                ],
                                'generation' => $aiGeneration->fresh(),
                                'usage' => $user->subscription?->getUsageSummary(),
                            ]);
                        }
                    }
                }

                throw new \Exception('No image data in Gemini response');
            } else {
                $errorBody = $response->json();
                $errorMessage = $errorBody['error']['message'] ?? 'Gemini API error';
                throw new \Exception($errorMessage);
            }
        } catch (\Exception $e) {
            $aiGeneration->update([
                'status' => AiGeneration::STATUS_FAILED,
                'error_message' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to generate image',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    // Generate Video Script using AI
    public function generateVideoScript(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'topic' => 'required|string',
            'brand_kit_id' => 'nullable|exists:brand_kits,id',
            'duration' => 'nullable|integer|min:30|max:600',
            'platform' => 'nullable|string|in:youtube,tiktok,instagram,facebook',
            'tone' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $user = $request->user();

        // Check subscription text limit
        $limitCheck = $this->checkTextLimit($user);
        if (!$limitCheck['allowed']) {
            return response()->json([
                'success' => false,
                'message' => $limitCheck['error'],
                'error' => $limitCheck['error_en'],
                'limit_reached' => true,
            ], 403);
        }

        $brandKit = null;
        if ($request->brand_kit_id) {
            $brandKit = BrandKit::find($request->brand_kit_id);
        }

        $prompt = "Generate a video script for: {$request->topic}";
        if ($brandKit) {
            $prompt .= "\nBrand Voice: {$brandKit->voice}";
            $prompt .= "\nTone: {$brandKit->tone}";
        }
        if ($request->duration) {
            $prompt .= "\nDuration: {$request->duration} seconds";
        }
        if ($request->platform) {
            $prompt .= "\nPlatform: {$request->platform}";
        }

        $aiGeneration = AiGeneration::create([
            'user_id' => $request->user()->id,
            'brand_kit_id' => $request->brand_kit_id,
            'type' => AiGeneration::TYPE_VIDEO_SCRIPT,
            'prompt' => $prompt,
            'settings' => [
                'topic' => $request->topic,
                'duration' => $request->duration ?? 60,
                'platform' => $request->platform,
                'tone' => $request->tone ?? ($brandKit->tone ?? 'professional'),
            ],
            'status' => AiGeneration::STATUS_PROCESSING,
        ]);

        try {
            // Use AdvancedAIContentService for actual generation
            $aiService = app(AdvancedAIContentService::class);
            
            $result = $aiService->generateText($prompt, [
                'provider' => $request->input('ai_provider', 'gemini'),
                'temperature' => 0.8,
                'max_tokens' => 2000,
            ]);

            if (!$result['success']) {
                throw new \Exception($result['error'] ?? 'Failed to generate video script');
            }

            $data = [
                'script' => $result['content'],
                'estimated_duration' => $request->duration ?? 60,
                'provider' => $result['provider'] ?? 'openai',
                'model' => $result['model'] ?? 'unknown',
                'generated_at' => now()->toISOString(),
            ];

            $aiGeneration->update([
                'result' => json_encode($data),
                'status' => AiGeneration::STATUS_COMPLETED,
                'tokens_used' => $result['tokens_used'] ?? 0,
            ]);

            // Increment text count
            $user->subscription?->incrementTextCount();

            return response()->json([
                'success' => true,
                'message' => 'Video script generated successfully',
                'generation' => $aiGeneration->fresh(),
                'usage' => $user->subscription?->getUsageSummary(),
            ]);
        } catch (\Exception $e) {
            $aiGeneration->update([
                'status' => AiGeneration::STATUS_FAILED,
                'error_message' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'error' => 'Failed to generate video script: ' . $e->getMessage()
            ], 500);
        }
    }

    // Transcribe Audio to Text
    public function transcribeAudio(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'audio_file' => 'required|file|mimes:mp3,wav,m4a,ogg|max:25600',
            'language' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $audioPath = $request->file('audio_file')->store('audio-transcriptions', 'public');

        $aiGeneration = AiGeneration::create([
            'user_id' => $request->user()->id,
            'type' => AiGeneration::TYPE_AUDIO_TRANSCRIPTION,
            'prompt' => 'Audio file: ' . $audioPath,
            'settings' => [
                'file_path' => $audioPath,
                'language' => $request->language ?? 'auto',
            ],
            'status' => AiGeneration::STATUS_PROCESSING,
        ]);

        try {
            // Use OpenAI Whisper API for transcription
            $openaiKey = env('OPENAI_API_KEY');

            if (empty($openaiKey)) {
                throw new \Exception('OpenAI API key not configured');
            }

            $filePath = storage_path('app/public/' . $audioPath);

            // Use multipart form data for file upload
            $multipartData = [
                [
                    'name' => 'file',
                    'contents' => fopen($filePath, 'r'),
                    'filename' => basename($filePath),
                ],
                [
                    'name' => 'model',
                    'contents' => 'whisper-1',
                ],
                [
                    'name' => 'response_format',
                    'contents' => 'json',
                ],
            ];

            // Add language if specified
            if ($request->language) {
                $multipartData[] = [
                    'name' => 'language',
                    'contents' => $request->language,
                ];
            }

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $openaiKey,
            ])->timeout(120)->asMultipart()->post('https://api.openai.com/v1/audio/transcriptions', $multipartData);

            if ($response->successful()) {
                $data = $response->json();
                $transcription = $data['text'] ?? '';

                $result = [
                    'transcription' => $transcription,
                    'language' => $request->language ?? 'auto-detected',
                    'generated_at' => now()->toISOString(),
                ];

                $aiGeneration->update([
                    'result' => json_encode($result),
                    'status' => AiGeneration::STATUS_COMPLETED,
                    'tokens_used' => 0,
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Audio transcribed successfully',
                    'data' => [
                        'transcription' => $transcription,
                        'language' => $request->language ?? 'auto-detected',
                    ],
                    'generation' => $aiGeneration->fresh(),
                ]);
            }

            $errorBody = $response->json();
            throw new \Exception($errorBody['error']['message'] ?? 'OpenAI Whisper API error');
        } catch (\Exception $e) {
            $aiGeneration->update([
                'status' => AiGeneration::STATUS_FAILED,
                'error_message' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'error' => 'Failed to transcribe audio: ' . $e->getMessage()
            ], 500);
        }
    }

    // Generate Social Media Content
    public function generateSocialContent(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'topic' => 'required|string',
            'brand_kit_id' => 'nullable|exists:brand_kits,id',
            'platform' => 'required|string|in:facebook,instagram,twitter,linkedin,tiktok',
            'content_type' => 'required|string|in:post,story,reel,tweet,article',
            'include_hashtags' => 'nullable|boolean',
            'include_emojis' => 'nullable|boolean',
            'ai_provider' => 'nullable|string|in:openai,claude,gemini',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $user = $request->user();

        // Check subscription text limit
        $limitCheck = $this->checkTextLimit($user);
        if (!$limitCheck['allowed']) {
            return response()->json([
                'success' => false,
                'message' => $limitCheck['error'],
                'error' => $limitCheck['error_en'],
                'limit_reached' => true,
            ], 403);
        }

        $brandKit = null;
        if ($request->brand_kit_id) {
            $brandKit = BrandKit::find($request->brand_kit_id);
        }

        $prompt = "Generate {$request->content_type} content for {$request->platform} about: {$request->topic}";
        if ($brandKit) {
            $prompt .= "\nBrand Voice: {$brandKit->voice}";
            $prompt .= "\nTone: {$brandKit->tone}";
            if ($brandKit->keywords) {
                $prompt .= "\nKeywords: " . implode(', ', $brandKit->keywords);
            }
        }
        if ($user->type_of_audience) {
            $prompt .= "\nTarget Audience: {$user->type_of_audience}";
        }

        if ($request->include_hashtags) {
            $prompt .= "\nInclude relevant hashtags";
        }
        if ($request->include_emojis) {
            $prompt .= "\nInclude appropriate emojis";
        }

        $aiGeneration = AiGeneration::create([
            'user_id' => $user->id,
            'brand_kit_id' => $request->brand_kit_id,
            'type' => AiGeneration::TYPE_SOCIAL_CONTENT,
            'prompt' => $prompt,
            'settings' => [
                'topic' => $request->topic,
                'platform' => $request->platform,
                'content_type' => $request->content_type,
                'include_hashtags' => $request->include_hashtags ?? true,
                'include_emojis' => $request->include_emojis ?? true,
                'ai_provider' => $request->input('ai_provider', 'openai'),
            ],
            'status' => AiGeneration::STATUS_PROCESSING,
        ]);

        try {
            // Use AdvancedAIContentService for actual generation
            $aiService = app(AdvancedAIContentService::class);
            
            $result = $aiService->generateText($prompt, [
                'provider' => $request->input('ai_provider', 'gemini'),
                'temperature' => 0.8,
                'max_tokens' => 2000,
            ]);

            if (!$result['success']) {
                throw new \Exception($result['error'] ?? 'Failed to generate content');
            }

            $data = [
                'content' => $result['content'],
                'provider' => $result['provider'] ?? 'openai',
                'model' => $result['model'] ?? 'unknown',
                'estimated_reach' => rand(1000, 10000),
                'best_time_to_post' => now()->addHours(2)->toISOString(),
                'generated_at' => now()->toISOString(),
            ];

            $aiGeneration->update([
                'result' => json_encode($data),
                'status' => AiGeneration::STATUS_COMPLETED,
                'tokens_used' => $result['tokens_used'] ?? 0,
            ]);

            // Increment text count
            $user->subscription?->incrementTextCount();

            return response()->json([
                'success' => true,
                'message' => 'Social media content generated successfully',
                'generation' => $aiGeneration->fresh(),
                'usage' => $user->subscription?->getUsageSummary(),
            ]);
        } catch (\Exception $e) {
            $aiGeneration->update([
                'status' => AiGeneration::STATUS_FAILED,
                'error_message' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'error' => 'Failed to generate social media content: ' . $e->getMessage()
            ], 500);
        }
    }

    // Get AI Generation History
    public function getHistory(Request $request)
    {
        $type = $request->query('type');

        $query = $request->user()->aiGenerations()->latest();

        if ($type) {
            $query->byType($type);
        }

        $generations = $query->paginate(20);

        return response()->json($generations);
    }

    // Get specific AI Generation
    public function getGeneration(Request $request, $id)
    {
        $generation = $request->user()->aiGenerations()->findOrFail($id);
        return response()->json($generation);
    }

    // Generate Image using Nano Banana API (Gemini 2.5 Flash / Gemini 3 Pro)
    public function generateImageNanoBanana(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'prompt' => 'required|string|min:3',
            'brand_kit_id' => 'nullable|exists:brand_kits,id',
            'num_images' => 'nullable|integer|min:1|max:4',
            'type' => 'nullable|string|in:TEXTTOIAMGE,IMAGETOIAMGE',
            'image_urls' => 'nullable|array',
            'image_urls.*' => 'nullable|url',
            'use_pro' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();

        // Check subscription image limit
        $limitCheck = $this->checkImageLimit($user);
        if (!$limitCheck['allowed']) {
            return response()->json([
                'success' => false,
                'message' => $limitCheck['error'],
                'error' => $limitCheck['error_en'],
                'limit_reached' => true,
                'remaining' => $limitCheck['remaining'] ?? 0,
                'limit' => $limitCheck['limit'] ?? 0,
            ], 403);
        }

        $numImages = $request->num_images ?? 1;
        $usePro = $request->use_pro ?? false;
        $type = $request->type ?? 'TEXTTOIAMGE';

        // Create AI Generation record
        $aiGeneration = AiGeneration::create([
            'user_id' => $user->id,
            'brand_kit_id' => $request->brand_kit_id,
            'type' => AiGeneration::TYPE_IMAGE,
            'prompt' => $request->prompt,
            'settings' => [
                'provider' => 'nanobanana',
                'model' => $usePro ? 'nano-banana-pro' : 'nano-banana',
                'num_images' => $numImages,
                'generation_type' => $type,
                'image_urls' => $request->image_urls,
            ],
            'status' => AiGeneration::STATUS_PROCESSING,
        ]);

        try {
            // Get Nano Banana API Key from environment
            $nanoBananaKey = env('NANOBANANA_API_KEY', '');

            if (empty($nanoBananaKey)) {
                throw new \Exception('Nano Banana API key not configured on server');
            }

            // Determine endpoint based on pro/standard
            $endpoint = $usePro
                ? 'https://api.nanobananaapi.ai/api/v1/nanobanana/generate-pro'
                : 'https://api.nanobananaapi.ai/api/v1/nanobanana/generate';

            // Prepare request body
            $requestBody = [
                'prompt' => $request->prompt,
                'type' => $type,
                'numImages' => $numImages,
            ];

            // Add image URLs for image-to-image editing
            if ($type === 'IMAGETOIAMGE' && $request->image_urls) {
                $requestBody['imageUrls'] = $request->image_urls;
            }

            // Start generation task
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $nanoBananaKey,
                'Content-Type' => 'application/json',
            ])->timeout(30)->post($endpoint, $requestBody);

            if (!$response->successful()) {
                $errorBody = $response->json();
                throw new \Exception($errorBody['message'] ?? $errorBody['error'] ?? 'Nano Banana API error');
            }

            $taskData = $response->json();
            $taskId = $taskData['data']['taskId'] ?? $taskData['taskId'] ?? null;

            if (!$taskId) {
                throw new \Exception('No task ID received from Nano Banana API');
            }

            // Poll for completion (max 120 seconds)
            $maxAttempts = 60;
            $attempt = 0;
            $completed = false;
            $resultImages = [];

            while ($attempt < $maxAttempts && !$completed) {
                sleep(2); // Wait 2 seconds between polls
                $attempt++;

                $statusResponse = Http::withHeaders([
                    'Authorization' => 'Bearer ' . $nanoBananaKey,
                ])->get('https://api.nanobananaapi.ai/api/v1/nanobanana/record-info', [
                    'taskId' => $taskId,
                ]);

                if ($statusResponse->successful()) {
                    $statusData = $statusResponse->json();
                    $code = $statusData['code'] ?? null;

                    // If record doesn't exist yet, continue polling
                    if ($code === 422) {
                        continue;
                    }

                    $successFlag = $statusData['data']['successFlag'] ?? null;
                    $errorMessage = $statusData['data']['errorMessage'] ?? null;
                    $errorCode = $statusData['data']['errorCode'] ?? null;

                    if ($successFlag === 1) {
                        $completed = true;
                        // Extract image URL from response structure
                        $responseData = $statusData['data']['response'] ?? [];
                        $imageUrl = $responseData['resultImageUrl'] ?? $responseData['originImageUrl'] ?? null;
                        if ($imageUrl) {
                            $resultImages = [$imageUrl];
                        }
                    } elseif ($successFlag === 0 && ($errorMessage || $errorCode)) {
                        throw new \Exception($errorMessage ?? 'Image generation failed: ' . $errorCode);
                    }
                    // If successFlag is null, task is still processing - continue polling
                }
            }

            if (!$completed) {
                throw new \Exception('Image generation timed out');
            }

            // Save images locally
            $savedImages = [];
            foreach ($resultImages as $index => $imageUrl) {
                try {
                    $imageData = Http::timeout(60)->get($imageUrl)->body();
                    $extension = pathinfo(parse_url($imageUrl, PHP_URL_PATH), PATHINFO_EXTENSION) ?: 'png';
                    $fileName = 'ai_images/nanobanana_' . uniqid() . '_' . time() . '_' . $index . '.' . $extension;
                    $imagePath = storage_path('app/public/' . $fileName);

                    // Ensure directory exists
                    if (!file_exists(dirname($imagePath))) {
                        mkdir(dirname($imagePath), 0755, true);
                    }

                    file_put_contents($imagePath, $imageData);
                    $savedImages[] = url('storage/' . $fileName);
                } catch (\Exception $e) {
                    // If saving fails, use original URL
                    $savedImages[] = $imageUrl;
                }
            }

            $result = [
                'image_url' => $savedImages[0] ?? $resultImages[0] ?? null,
                'image_urls' => !empty($savedImages) ? $savedImages : $resultImages,
                'model' => $usePro ? 'nano-banana-pro (Gemini 3 Pro)' : 'nano-banana (Gemini 2.5 Flash)',
                'provider' => 'nanobanana',
                'task_id' => $taskId,
                'generated_at' => now()->toISOString(),
            ];

            $aiGeneration->update([
                'result' => json_encode($result),
                'status' => AiGeneration::STATUS_COMPLETED,
                'tokens_used' => $numImages,
            ]);

            // Increment image count
            $user->subscription?->incrementImageCount();

            return response()->json([
                'success' => true,
                'message' => 'Image generated successfully via Nano Banana',
                'data' => [
                    'id' => $aiGeneration->id,
                    'image_url' => $result['image_url'],
                    'image_urls' => $result['image_urls'],
                    'prompt' => $request->prompt,
                    'model' => $result['model'],
                ],
                'generation' => $aiGeneration->fresh(),
                'usage' => $user->subscription?->getUsageSummary(),
            ]);

        } catch (\Exception $e) {
            $aiGeneration->update([
                'status' => AiGeneration::STATUS_FAILED,
                'error_message' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to generate image via Nano Banana',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    // Generate Image using Replicate API (FLUX Schnell - Fast)
    public function generateImageReplicate(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'prompt' => 'required|string|min:3',
            'model' => 'nullable|string',
            'brand_kit_id' => 'nullable|exists:brand_kits,id',
            'width' => 'nullable|integer|min:256|max:1440',
            'height' => 'nullable|integer|min:256|max:1440',
            'num_outputs' => 'nullable|integer|min:1|max:4',
            'negative_prompt' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();

        // Check subscription image limit
        $limitCheck = $this->checkImageLimit($user);
        if (!$limitCheck['allowed']) {
            return response()->json([
                'success' => false,
                'message' => $limitCheck['error'],
                'error' => $limitCheck['error_en'],
                'limit_reached' => true,
                'remaining' => $limitCheck['remaining'] ?? 0,
                'limit' => $limitCheck['limit'] ?? 0,
            ], 403);
        }

        $width = $request->width ?? 1024;
        $height = $request->height ?? 1024;
        $numOutputs = $request->num_outputs ?? 1;

        // Default to FLUX Schnell (fast) model
        $model = $request->model ?? 'black-forest-labs/flux-schnell';

        // Create AI Generation record
        $aiGeneration = AiGeneration::create([
            'user_id' => $user->id,
            'brand_kit_id' => $request->brand_kit_id,
            'type' => AiGeneration::TYPE_IMAGE,
            'prompt' => $request->prompt,
            'settings' => [
                'provider' => 'replicate',
                'model' => $model,
                'width' => $width,
                'height' => $height,
                'num_outputs' => $numOutputs,
                'negative_prompt' => $request->negative_prompt,
            ],
            'status' => AiGeneration::STATUS_PROCESSING,
        ]);

        try {
            // Get Replicate API Token from environment
            $replicateToken = env('REPLICATE_API_TOKEN', '');

            if (empty($replicateToken)) {
                throw new \Exception('Replicate API token not configured on server');
            }

            // Prepare input based on model
            $input = [
                'prompt' => $request->prompt,
                'num_outputs' => $numOutputs,
            ];

            // FLUX models use different parameter names
            if (str_contains($model, 'flux')) {
                $input['width'] = $width;
                $input['height'] = $height;
                $input['num_inference_steps'] = 4; // FLUX Schnell is fast with 4 steps
                $input['output_format'] = 'webp';
                $input['output_quality'] = 90;
            } else {
                // For other models like SDXL
                $input['width'] = $width;
                $input['height'] = $height;
                if ($request->negative_prompt) {
                    $input['negative_prompt'] = $request->negative_prompt;
                }
            }

            // Start prediction on Replicate
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $replicateToken,
                'Content-Type' => 'application/json',
            ])->timeout(30)->post('https://api.replicate.com/v1/models/' . $model . '/predictions', [
                'input' => $input,
            ]);

            if (!$response->successful()) {
                $errorBody = $response->json();
                throw new \Exception($errorBody['detail'] ?? 'Replicate API error');
            }

            $prediction = $response->json();
            $predictionId = $prediction['id'];

            // Poll for completion (max 120 seconds)
            $maxAttempts = 60;
            $attempt = 0;
            $completed = false;
            $output = null;

            while ($attempt < $maxAttempts && !$completed) {
                sleep(2); // Wait 2 seconds between polls
                $attempt++;

                $statusResponse = Http::withHeaders([
                    'Authorization' => 'Bearer ' . $replicateToken,
                ])->get('https://api.replicate.com/v1/predictions/' . $predictionId);

                if ($statusResponse->successful()) {
                    $statusData = $statusResponse->json();
                    $status = $statusData['status'];

                    if ($status === 'succeeded') {
                        $completed = true;
                        $output = $statusData['output'];
                    } elseif ($status === 'failed' || $status === 'canceled') {
                        throw new \Exception($statusData['error'] ?? 'Image generation failed');
                    }
                }
            }

            if (!$completed) {
                throw new \Exception('Image generation timed out');
            }

            // Process output - can be single URL or array
            $imageUrls = is_array($output) ? $output : [$output];
            $savedImages = [];

            foreach ($imageUrls as $index => $imageUrl) {
                // Download and save image
                $imageData = Http::timeout(60)->get($imageUrl)->body();
                $fileName = 'ai_images/replicate_' . uniqid() . '_' . time() . '_' . $index . '.webp';
                $imagePath = storage_path('app/public/' . $fileName);

                // Ensure directory exists
                if (!file_exists(dirname($imagePath))) {
                    mkdir(dirname($imagePath), 0755, true);
                }

                file_put_contents($imagePath, $imageData);
                $savedImages[] = url('storage/' . $fileName);
            }

            $result = [
                'image_url' => $savedImages[0],
                'image_urls' => $savedImages,
                'model' => $model,
                'provider' => 'replicate',
                'generated_at' => now()->toISOString(),
            ];

            $aiGeneration->update([
                'result' => json_encode($result),
                'status' => AiGeneration::STATUS_COMPLETED,
                'tokens_used' => 1,
            ]);

            // Increment image count
            $user->subscription?->incrementImageCount();

            return response()->json([
                'success' => true,
                'message' => 'Image generated successfully via Replicate',
                'data' => [
                    'id' => $aiGeneration->id,
                    'image_url' => $savedImages[0],
                    'image_urls' => $savedImages,
                    'prompt' => $request->prompt,
                    'model' => $model,
                ],
                'generation' => $aiGeneration->fresh(),
                'usage' => $user->subscription?->getUsageSummary(),
            ]);

        } catch (\Exception $e) {
            $aiGeneration->update([
                'status' => AiGeneration::STATUS_FAILED,
                'error_message' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to generate image via Replicate',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    // Generate Video using Google Veo 3.1 API (Latest)
    public function generateVideoVeo3(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'prompt' => 'required|string|min:3',
            'brand_kit_id' => 'nullable|exists:brand_kits,id',
            'duration' => 'nullable|integer|min:4|max:8',
            'aspect_ratio' => 'nullable|string|in:16:9,9:16',
            'style' => 'nullable|string',
            'resolution' => 'nullable|string|in:720p,1080p',
            'fast' => 'nullable|boolean',
            'image_url' => 'nullable|url',
            'negative_prompt' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();

        // Check subscription video limit
        $limitCheck = $this->checkVideoLimit($user);
        if (!$limitCheck['allowed']) {
            return response()->json([
                'success' => false,
                'message' => $limitCheck['error'],
                'error' => $limitCheck['error_en'],
                'limit_reached' => true,
                'remaining' => $limitCheck['remaining'] ?? 0,
                'limit' => $limitCheck['limit'] ?? 0,
            ], 403);
        }

        // Respect subscription duration limit
        $maxAllowedDuration = $limitCheck['max_duration'] ?? 8;
        $duration = min($request->duration ?? $maxAllowedDuration, $maxAllowedDuration); // Respect subscription limit
        $aspectRatio = $request->aspect_ratio ?? '16:9';
        $useFastModel = $request->fast ?? false;
        $model = $useFastModel ? 'veo-3.1-fast-generate-preview' : 'veo-3.1-generate-preview';

        // Create AI Generation record
        $aiGeneration = AiGeneration::create([
            'user_id' => $user->id,
            'brand_kit_id' => $request->brand_kit_id,
            'type' => 'video',
            'prompt' => $request->prompt,
            'settings' => [
                'provider' => 'gemini_veo',
                'model' => $model,
                'duration' => $duration,
                'aspect_ratio' => $aspectRatio,
                'style' => $request->style,
                'resolution' => $request->resolution ?? '720p',
                'fast' => $useFastModel,
            ],
            'status' => AiGeneration::STATUS_PROCESSING,
        ]);

        try {
            // Enhance prompt for better video output
            $enhancedPrompt = $request->prompt;
            if ($request->style) {
                $enhancedPrompt .= ". Style: {$request->style}";
            }

            $result = null;
            $usedProvider = 'gemini_veo';

            // Try Gemini Veo first
            $geminiService = new \App\Services\GeminiVideoService();
            if ($geminiService->isConfigured()) {
                $result = $geminiService->generateVideo(
                    $enhancedPrompt,
                    $duration,
                    $aspectRatio,
                    [
                        'fast' => $useFastModel,
                        'negative_prompt' => $request->negative_prompt,
                        'image_url' => $request->image_url,
                    ]
                );

                // Check if quota exceeded - fallback to Stability AI
                if (!$result['success'] && str_contains(strtolower($result['error'] ?? ''), 'quota')) {
                    \Illuminate\Support\Facades\Log::info('Gemini quota exceeded, falling back to Stability AI');
                    $result = null; // Reset to try fallback
                }
            }

            // Fallback to Replicate if Gemini failed or not configured
            if (!$result || !$result['success']) {
                $replicateToken = env('REPLICATE_API_TOKEN');
                if (!empty($replicateToken)) {
                    $usedProvider = 'replicate';
                    $model = 'wan-2.1';

                    \Illuminate\Support\Facades\Log::info('Trying Replicate video generation', ['prompt' => $enhancedPrompt]);

                    // Use Stable Video Diffusion model (more stable and available)
                    $replicateResponse = Http::withHeaders([
                        'Authorization' => 'Bearer ' . $replicateToken,
                        'Content-Type' => 'application/json',
                        'Prefer' => 'wait',
                    ])->timeout(300)->post('https://api.replicate.com/v1/models/stability-ai/stable-video-diffusion/predictions', [
                        'input' => [
                            'input_image' => 'https://picsum.photos/seed/' . abs(crc32($enhancedPrompt)) . '/1024/576',
                            'video_length' => 'short_length',
                            'sizing_strategy' => 'maintain_aspect_ratio',
                            'frames_per_second' => 6,
                            'motion_bucket_id' => 127,
                            'cond_aug' => 0.02,
                            'decoding_t' => 7,
                            'seed' => rand(0, 999999),
                        ],
                    ]);

                    if ($replicateResponse->successful()) {
                        $replicateData = $replicateResponse->json();
                        $result = [
                            'success' => true,
                            'task_id' => $replicateData['id'] ?? uniqid('rep_'),
                            'status' => $replicateData['status'] ?? 'starting',
                            'provider' => 'replicate',
                        ];
                        \Illuminate\Support\Facades\Log::info('Replicate video generation started', $result);
                    } else {
                        \Illuminate\Support\Facades\Log::error('Replicate failed', [
                            'status' => $replicateResponse->status(),
                            'body' => $replicateResponse->json(),
                        ]);
                    }
                }
            }

            // If still no result, try Runway as last resort
            if (!$result || !$result['success']) {
                $runwayApiKey = env('RUNWAY_API_KEY');
                if (!empty($runwayApiKey)) {
                    $usedProvider = 'runway';
                    $model = 'gen4_turbo';

                    // Use AIVideoGeneratorService which contains RunwayMLService
                    $videoService = new \App\Services\AIVideoGeneratorService();
                    $result = $videoService->generateVideo($enhancedPrompt, 'runway', $duration, $aspectRatio, [
                        'model' => 'gen4_turbo',
                    ]);
                }
            }

            if (!$result || !$result['success']) {
                throw new \Exception($result['error'] ?? 'All video generation providers failed');
            }

            $operationName = $result['task_id'];
            $actualProvider = $result['provider'] ?? $usedProvider;

            // Poll for completion (max 5 minutes for video generation)
            $maxAttempts = 150;
            $attempt = 0;
            $completed = false;
            $videoUrl = null;

            while ($attempt < $maxAttempts && !$completed) {
                sleep(2); // Wait 2 seconds between polls
                $attempt++;

                // Check status based on provider
                if ($actualProvider === 'gemini_veo' || $actualProvider === 'gemini') {
                    $statusResult = $geminiService->checkStatus($operationName);
                } elseif ($actualProvider === 'replicate') {
                    // Replicate status check
                    $statusResponse = Http::withHeaders([
                        'Authorization' => 'Bearer ' . env('REPLICATE_API_TOKEN'),
                    ])->timeout(30)->get("https://api.replicate.com/v1/predictions/{$operationName}");

                    if ($statusResponse->successful()) {
                        $repData = $statusResponse->json();
                        $repStatus = $repData['status'] ?? 'unknown';

                        if ($repStatus === 'succeeded') {
                            $output = $repData['output'] ?? null;
                            $statusResult = [
                                'success' => true,
                                'status' => 'succeeded',
                                'video_url' => is_array($output) ? ($output[0] ?? null) : $output,
                            ];
                        } elseif ($repStatus === 'failed' || $repStatus === 'canceled') {
                            $statusResult = [
                                'success' => false,
                                'status' => 'failed',
                                'error' => $repData['error'] ?? 'Video generation failed',
                            ];
                        } else {
                            $statusResult = ['success' => true, 'status' => 'processing'];
                        }
                    } else {
                        $statusResult = ['success' => false, 'status' => 'failed'];
                    }
                } elseif ($actualProvider === 'runway') {
                    $videoService = new \App\Services\AIVideoGeneratorService();
                    $statusResult = $videoService->checkStatus($operationName, 'runway');
                } else {
                    $statusResult = $geminiService->checkStatus($operationName);
                }

                if ($statusResult['success'] ?? false) {
                    $status = strtolower($statusResult['status'] ?? 'unknown');

                    if ($status === 'succeeded' || $status === 'completed') {
                        $completed = true;
                        $videoUrl = $statusResult['local_url'] ?? $statusResult['video_url'] ?? $statusResult['download_url'] ?? null;
                    } elseif ($status === 'failed') {
                        throw new \Exception($statusResult['error'] ?? 'Video generation failed');
                    }
                }
            }

            if (!$completed) {
                // Return async response - video will be ready later
                $aiGeneration->update([
                    'result' => json_encode([
                        'operation_id' => $operationName,
                        'status' => 'processing',
                        'model' => $model,
                        'provider' => $actualProvider,
                    ]),
                    'status' => AiGeneration::STATUS_PROCESSING,
                ]);

                return response()->json([
                    'success' => true,
                    'message' => "Video generation started via {$actualProvider}. It may take 2-5 minutes.",
                    'data' => [
                        'id' => $aiGeneration->id,
                        'operation_id' => $operationName,
                        'status' => 'processing',
                        'estimated_time' => '2-5 minutes',
                        'model' => $model,
                        'provider' => $actualProvider,
                    ],
                ], 202);
            }

            if (!$videoUrl) {
                throw new \Exception("No video URL received from {$actualProvider}");
            }

            $resultData = [
                'video_url' => $videoUrl,
                'duration' => $duration,
                'aspect_ratio' => $aspectRatio,
                'model' => $model,
                'provider' => $actualProvider,
                'operation_id' => $operationName,
                'generated_at' => now()->toISOString(),
            ];

            $aiGeneration->update([
                'result' => json_encode($resultData),
                'status' => AiGeneration::STATUS_COMPLETED,
                'tokens_used' => $duration * 10,
            ]);

            // Increment video count
            $user->subscription?->incrementVideoCount();

            return response()->json([
                'success' => true,
                'message' => "Video generated successfully via {$actualProvider}",
                'data' => [
                    'id' => $aiGeneration->id,
                    'video_url' => $videoUrl,
                    'duration' => $duration,
                    'aspect_ratio' => $aspectRatio,
                    'prompt' => $request->prompt,
                    'model' => $model,
                    'provider' => $actualProvider,
                ],
                'generation' => $aiGeneration->fresh(),
                'usage' => $user->subscription?->getUsageSummary(),
            ]);

        } catch (\Exception $e) {
            $aiGeneration->update([
                'status' => AiGeneration::STATUS_FAILED,
                'error_message' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to generate video via Veo 3.1',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    // Generate Image using Stability AI (SDXL, SD3, Ultra)
    public function generateImageStabilityAI(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'prompt' => 'required|string|min:3',
            'brand_kit_id' => 'nullable|exists:brand_kits,id',
            'model' => 'nullable|string|in:core,ultra,sd3-large,sd3-medium',
            'aspect_ratio' => 'nullable|string|in:1:1,16:9,9:16,4:3,3:2,21:9',
            'output_format' => 'nullable|string|in:png,jpeg,webp',
            'negative_prompt' => 'nullable|string',
            'style_preset' => 'nullable|string',
            'seed' => 'nullable|integer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();

        // Check subscription image limit
        $limitCheck = $this->checkImageLimit($user);
        if (!$limitCheck['allowed']) {
            return response()->json([
                'success' => false,
                'message' => $limitCheck['error'],
                'error' => $limitCheck['error_en'],
                'limit_reached' => true,
                'remaining' => $limitCheck['remaining'] ?? 0,
                'limit' => $limitCheck['limit'] ?? 0,
            ], 403);
        }

        $model = $request->model ?? 'core';
        $aspectRatio = $request->aspect_ratio ?? '1:1';
        $outputFormat = $request->output_format ?? 'png';

        // Create AI Generation record
        $aiGeneration = AiGeneration::create([
            'user_id' => $user->id,
            'brand_kit_id' => $request->brand_kit_id,
            'type' => AiGeneration::TYPE_IMAGE,
            'prompt' => $request->prompt,
            'settings' => [
                'provider' => 'stability_ai',
                'model' => $model,
                'aspect_ratio' => $aspectRatio,
                'output_format' => $outputFormat,
                'negative_prompt' => $request->negative_prompt,
                'style_preset' => $request->style_preset,
                'seed' => $request->seed,
            ],
            'status' => AiGeneration::STATUS_PROCESSING,
        ]);

        try {
            // Get Stability AI API Key from environment
            $stabilityApiKey = env('STABILITY_AI_API_KEY', env('STABILITY_API_KEY', ''));

            if (empty($stabilityApiKey)) {
                throw new \Exception('Stability AI API key not configured on server');
            }

            // Determine endpoint based on model
            $endpoint = match($model) {
                'ultra' => 'https://api.stability.ai/v2beta/stable-image/generate/ultra',
                'sd3-large' => 'https://api.stability.ai/v2beta/stable-image/generate/sd3',
                'sd3-medium' => 'https://api.stability.ai/v2beta/stable-image/generate/sd3',
                default => 'https://api.stability.ai/v2beta/stable-image/generate/core',
            };

            // Prepare multipart form data
            $formData = [
                ['name' => 'prompt', 'contents' => $request->prompt],
                ['name' => 'aspect_ratio', 'contents' => $aspectRatio],
                ['name' => 'output_format', 'contents' => $outputFormat],
            ];

            // Add optional parameters
            if ($request->negative_prompt) {
                $formData[] = ['name' => 'negative_prompt', 'contents' => $request->negative_prompt];
            }
            if ($request->style_preset) {
                $formData[] = ['name' => 'style_preset', 'contents' => $request->style_preset];
            }
            if ($request->seed) {
                $formData[] = ['name' => 'seed', 'contents' => (string)$request->seed];
            }

            // For SD3 models, specify the model variant
            if (str_starts_with($model, 'sd3-')) {
                $formData[] = ['name' => 'model', 'contents' => $model === 'sd3-large' ? 'sd3-large' : 'sd3-medium'];
            }

            // Call Stability AI API
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $stabilityApiKey,
                'Accept' => 'application/json',
            ])->asMultipart()->timeout(120)->post($endpoint, $formData);

            if ($response->successful()) {
                $data = $response->json();

                if (isset($data['image'])) {
                    $imageBase64 = $data['image'];

                    // Save image to storage
                    $fileName = 'ai_images/stability_' . uniqid() . '_' . time() . '.' . $outputFormat;
                    $imagePath = storage_path('app/public/' . $fileName);

                    // Ensure directory exists
                    if (!file_exists(dirname($imagePath))) {
                        mkdir(dirname($imagePath), 0755, true);
                    }

                    file_put_contents($imagePath, base64_decode($imageBase64));
                    $imageUrl = url('storage/' . $fileName);

                    $result = [
                        'image_url' => $imageUrl,
                        'image_base64' => $imageBase64,
                        'model' => $model,
                        'provider' => 'stability_ai',
                        'aspect_ratio' => $aspectRatio,
                        'seed' => $data['seed'] ?? null,
                        'finish_reason' => $data['finish_reason'] ?? 'SUCCESS',
                        'generated_at' => now()->toISOString(),
                    ];

                    $aiGeneration->update([
                        'result' => json_encode($result),
                        'status' => AiGeneration::STATUS_COMPLETED,
                        'tokens_used' => $model === 'ultra' ? 8 : ($model === 'core' ? 3 : 6),
                    ]);

                    // Increment image count
                    $user->subscription?->incrementImageCount();

                    return response()->json([
                        'success' => true,
                        'message' => 'Image generated successfully via Stability AI',
                        'data' => [
                            'id' => $aiGeneration->id,
                            'image_url' => $imageUrl,
                            'image_base64' => $imageBase64,
                            'prompt' => $request->prompt,
                            'model' => 'Stability AI ' . ucfirst($model),
                            'aspect_ratio' => $aspectRatio,
                            'seed' => $data['seed'] ?? null,
                        ],
                        'generation' => $aiGeneration->fresh(),
                        'usage' => $user->subscription?->getUsageSummary(),
                    ]);
                }

                throw new \Exception('No image data in Stability AI response');
            } else {
                $errorBody = $response->json();
                $errorMessage = $errorBody['message'] ?? $errorBody['errors'][0]['message'] ?? 'Stability AI API error';

                // Check for specific error messages
                if (str_contains(strtolower($errorMessage), 'content moderation')) {
                    $errorMessage = 'Content was blocked by safety filters. Please modify your prompt.';
                } elseif (str_contains(strtolower($errorMessage), 'insufficient_balance') ||
                          str_contains(strtolower($errorMessage), 'credits')) {
                    $errorMessage = 'Stability AI: Insufficient credits. Please top up your account.';
                }

                throw new \Exception($errorMessage);
            }
        } catch (\Exception $e) {
            $aiGeneration->update([
                'status' => AiGeneration::STATUS_FAILED,
                'error_message' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to generate image via Stability AI',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    // Generate Video using Runway ML Gen-4
    public function generateVideoRunway(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'prompt' => 'required|string|min:3',
            'brand_kit_id' => 'nullable|exists:brand_kits,id',
            'image_url' => 'nullable|url',
            'duration' => 'nullable|integer|min:5|max:10',
            'aspect_ratio' => 'nullable|string|in:16:9,9:16,1:1',
            'model' => 'nullable|string|in:gen4_turbo,gen3a_turbo',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();

        // Check subscription video limit
        $limitCheck = $this->checkVideoLimit($user);
        if (!$limitCheck['allowed']) {
            return response()->json([
                'success' => false,
                'message' => $limitCheck['error'],
                'error' => $limitCheck['error_en'],
                'limit_reached' => true,
                'remaining' => $limitCheck['remaining'] ?? 0,
                'limit' => $limitCheck['limit'] ?? 0,
            ], 403);
        }

        // Respect subscription duration limit
        $maxAllowedDuration = $limitCheck['max_duration'] ?? 10;
        $duration = min($request->duration ?? 5, $maxAllowedDuration);
        $aspectRatio = $request->aspect_ratio ?? '16:9';
        $model = $request->model ?? 'gen4_turbo';

        // Create AI Generation record
        $aiGeneration = AiGeneration::create([
            'user_id' => $user->id,
            'brand_kit_id' => $request->brand_kit_id,
            'type' => 'video',
            'prompt' => $request->prompt,
            'settings' => [
                'provider' => 'runway',
                'model' => $model,
                'duration' => $duration,
                'aspect_ratio' => $aspectRatio,
                'image_url' => $request->image_url,
            ],
            'status' => AiGeneration::STATUS_PROCESSING,
        ]);

        try {
            $runwayApiKey = env('RUNWAY_API_KEY', '');

            if (empty($runwayApiKey)) {
                throw new \Exception('Runway API key not configured on server');
            }

            // Convert aspect ratio to resolution
            $ratioMap = [
                '16:9' => '1280:720',
                '9:16' => '720:1280',
                '1:1' => '720:720',
            ];
            $ratio = $ratioMap[$aspectRatio] ?? '1280:720';

            // Prepare request payload
            $payload = [
                'promptText' => $request->prompt,
                'model' => $model,
                'ratio' => $ratio,
                'duration' => $duration,
                'watermark' => false,
            ];

            // Add image for image-to-video
            if ($request->image_url) {
                $payload['promptImage'] = $request->image_url;
            } else {
                // Use a placeholder image for text-to-video
                $payload['promptImage'] = 'https://picsum.photos/seed/' . abs(crc32($request->prompt)) . '/1280/720';
            }

            // Start video generation
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $runwayApiKey,
                'Content-Type' => 'application/json',
                'X-Runway-Version' => '2024-11-06',
            ])->timeout(60)->post('https://api.dev.runwayml.com/v1/image_to_video', $payload);

            if (!$response->successful()) {
                $errorBody = $response->json();
                $errorMessage = $errorBody['error'] ?? $errorBody['message'] ?? 'Runway API error';

                if (str_contains(strtolower($errorMessage), 'credits') ||
                    str_contains(strtolower($errorMessage), 'not enough')) {
                    $errorMessage = 'Runway ML: Not enough credits. Please top up your account.';
                }

                throw new \Exception($errorMessage);
            }

            $data = $response->json();
            $taskId = $data['id'] ?? null;

            if (!$taskId) {
                throw new \Exception('No task ID received from Runway API');
            }

            // Update generation with task info
            $aiGeneration->update([
                'result' => json_encode([
                    'task_id' => $taskId,
                    'status' => 'processing',
                    'provider' => 'runway',
                    'model' => $model,
                ]),
            ]);

            // Return immediately with task ID (client can poll for status)
            return response()->json([
                'success' => true,
                'message' => 'Video generation started via Runway ML',
                'data' => [
                    'id' => $aiGeneration->id,
                    'task_id' => $taskId,
                    'status' => 'processing',
                    'estimated_time' => 180,
                    'model' => 'Runway ML ' . $model,
                    'prompt' => $request->prompt,
                ],
                'generation' => $aiGeneration,
            ]);

        } catch (\Exception $e) {
            $aiGeneration->update([
                'status' => AiGeneration::STATUS_FAILED,
                'error_message' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to start video generation via Runway ML',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    // Check Runway video generation status
    public function checkRunwayStatus(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'task_id' => 'required|string',
            'generation_id' => 'nullable|integer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $runwayApiKey = env('RUNWAY_API_KEY', '');

            if (empty($runwayApiKey)) {
                throw new \Exception('Runway API key not configured');
            }

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $runwayApiKey,
                'X-Runway-Version' => '2024-11-06',
            ])->timeout(30)->get('https://api.dev.runwayml.com/v1/tasks/' . $request->task_id);

            if (!$response->successful()) {
                throw new \Exception('Failed to check task status');
            }

            $data = $response->json();
            $status = $data['status'] ?? 'unknown';

            $result = [
                'success' => true,
                'task_id' => $request->task_id,
                'status' => $status,
                'progress' => $data['progress'] ?? 0,
            ];

            // If completed, get the video URL
            if ($status === 'SUCCEEDED' && isset($data['output']) && count($data['output']) > 0) {
                $videoUrl = $data['output'][0];
                $result['video_url'] = $videoUrl;

                // Update the generation record if provided
                if ($request->generation_id) {
                    $generation = AiGeneration::find($request->generation_id);
                    if ($generation) {
                        $existingResult = json_decode($generation->result, true) ?? [];
                        $existingResult['video_url'] = $videoUrl;
                        $existingResult['status'] = 'completed';

                        $generation->update([
                            'result' => json_encode($existingResult),
                            'status' => AiGeneration::STATUS_COMPLETED,
                        ]);
                    }
                }
            } elseif ($status === 'FAILED') {
                $result['error'] = $data['error'] ?? 'Video generation failed';

                if ($request->generation_id) {
                    $generation = AiGeneration::find($request->generation_id);
                    if ($generation) {
                        $generation->update([
                            'status' => AiGeneration::STATUS_FAILED,
                            'error_message' => $result['error'],
                        ]);
                    }
                }
            }

            return response()->json($result);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    // Get available AI providers status
    public function getProviders()
    {
        $providers = [];

        // Check Stability AI
        $stabilityKey = env('STABILITY_AI_API_KEY', env('STABILITY_API_KEY', ''));
        $providers['stability_ai'] = [
            'name' => 'Stability AI',
            'configured' => !empty($stabilityKey) && !str_contains($stabilityKey, 'your_'),
            'type' => 'image',
            'models' => ['core', 'ultra', 'sd3-large', 'sd3-medium'],
            'features' => ['text-to-image', 'style-presets', 'negative-prompt'],
        ];

        // Check Runway ML
        $runwayKey = env('RUNWAY_API_KEY', '');
        $providers['runway'] = [
            'name' => 'Runway ML',
            'configured' => !empty($runwayKey) && !str_contains($runwayKey, 'your_'),
            'type' => 'video',
            'models' => ['gen4_turbo', 'gen3a_turbo'],
            'features' => ['text-to-video', 'image-to-video'],
        ];

        // Check Replicate
        $replicateKey = env('REPLICATE_API_TOKEN', '');
        $providers['replicate'] = [
            'name' => 'Replicate',
            'configured' => !empty($replicateKey) && !str_contains($replicateKey, 'your_'),
            'type' => 'both',
            'models' => ['flux-schnell', 'stable-video-diffusion'],
            'features' => ['text-to-image', 'image-to-video'],
        ];

        // Check Google Veo
        $geminiKey = env('GEMINI_API_KEY', env('GOOGLE_AI_API_KEY', ''));
        $providers['google_veo'] = [
            'name' => 'Google Veo',
            'configured' => !empty($geminiKey) && !str_contains($geminiKey, 'your_'),
            'type' => 'video',
            'models' => ['veo-3.0', 'veo-2.0'],
            'features' => ['text-to-video', 'high-quality'],
        ];

        // Check Gemini (Images)
        $providers['gemini'] = [
            'name' => 'Google Gemini',
            'configured' => !empty($geminiKey) && !str_contains($geminiKey, 'your_'),
            'type' => 'image',
            'models' => ['gemini-2.0-flash-exp'],
            'features' => ['text-to-image', 'multimodal'],
        ];

        return response()->json([
            'success' => true,
            'providers' => $providers,
        ]);
    }

    // Generate Video using Replicate (Stable Video Diffusion)
    public function generateVideoReplicate(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'prompt' => 'required|string|min:3',
            'brand_kit_id' => 'nullable|exists:brand_kits,id',
            'image_url' => 'required|url',
            'motion_bucket_id' => 'nullable|integer|min:1|max:255',
            'fps' => 'nullable|integer|min:6|max:30',
            'noise_aug_strength' => 'nullable|numeric|min:0|max:0.1',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();

        // Check subscription video limit
        $limitCheck = $this->checkVideoLimit($user);
        if (!$limitCheck['allowed']) {
            return response()->json([
                'success' => false,
                'message' => $limitCheck['error'],
                'error' => $limitCheck['error_en'],
                'limit_reached' => true,
                'remaining' => $limitCheck['remaining'] ?? 0,
                'limit' => $limitCheck['limit'] ?? 0,
            ], 403);
        }

        // Create AI Generation record
        $aiGeneration = AiGeneration::create([
            'user_id' => $user->id,
            'brand_kit_id' => $request->brand_kit_id,
            'type' => 'video',
            'prompt' => $request->prompt,
            'settings' => [
                'provider' => 'replicate',
                'model' => 'stable-video-diffusion',
                'image_url' => $request->image_url,
                'motion_bucket_id' => $request->motion_bucket_id ?? 127,
                'fps' => $request->fps ?? 25,
                'noise_aug_strength' => $request->noise_aug_strength ?? 0.02,
            ],
            'status' => AiGeneration::STATUS_PROCESSING,
        ]);

        try {
            $replicateToken = env('REPLICATE_API_TOKEN', '');

            if (empty($replicateToken)) {
                throw new \Exception('Replicate API token not configured on server');
            }

            // Stable Video Diffusion model on Replicate
            $modelVersion = 'stability-ai/stable-video-diffusion:3f0457e4619daac51203dedb472816fd4af51f3149fa7a9e0b5ffcf1b8172438';

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $replicateToken,
                'Content-Type' => 'application/json',
            ])->timeout(30)->post('https://api.replicate.com/v1/predictions', [
                'version' => explode(':', $modelVersion)[1],
                'input' => [
                    'input_image' => $request->image_url,
                    'motion_bucket_id' => $request->motion_bucket_id ?? 127,
                    'fps' => $request->fps ?? 25,
                    'noise_aug_strength' => $request->noise_aug_strength ?? 0.02,
                    'decoding_t' => 14,
                    'cond_aug' => 0.02,
                ],
            ]);

            if (!$response->successful()) {
                $errorBody = $response->json();
                throw new \Exception($errorBody['detail'] ?? 'Replicate API error');
            }

            $prediction = $response->json();
            $predictionId = $prediction['id'];

            // Poll for completion (max 5 minutes)
            $maxAttempts = 150;
            $attempt = 0;
            $completed = false;
            $videoUrl = null;

            while ($attempt < $maxAttempts && !$completed) {
                sleep(2);
                $attempt++;

                $statusResponse = Http::withHeaders([
                    'Authorization' => 'Bearer ' . $replicateToken,
                ])->get('https://api.replicate.com/v1/predictions/' . $predictionId);

                if ($statusResponse->successful()) {
                    $statusData = $statusResponse->json();
                    $status = $statusData['status'];

                    if ($status === 'succeeded') {
                        $completed = true;
                        $videoUrl = $statusData['output'] ?? null;
                    } elseif ($status === 'failed' || $status === 'canceled') {
                        throw new \Exception($statusData['error'] ?? 'Video generation failed');
                    }
                }
            }

            if (!$completed) {
                throw new \Exception('Video generation timed out');
            }

            // Download and save video locally
            $savedVideoUrl = $videoUrl;
            if ($videoUrl) {
                try {
                    $videoData = Http::timeout(120)->get($videoUrl)->body();
                    $fileName = 'ai_videos/replicate_' . uniqid() . '_' . time() . '.mp4';
                    $videoPath = storage_path('app/public/' . $fileName);

                    if (!file_exists(dirname($videoPath))) {
                        mkdir(dirname($videoPath), 0755, true);
                    }

                    file_put_contents($videoPath, $videoData);
                    $savedVideoUrl = url('storage/' . $fileName);
                } catch (\Exception $e) {
                    // Use original URL if saving fails
                }
            }

            $result = [
                'video_url' => $savedVideoUrl,
                'original_url' => $videoUrl,
                'model' => 'stable-video-diffusion',
                'provider' => 'replicate',
                'prediction_id' => $predictionId,
                'generated_at' => now()->toISOString(),
            ];

            $aiGeneration->update([
                'result' => json_encode($result),
                'status' => AiGeneration::STATUS_COMPLETED,
                'tokens_used' => 1,
            ]);

            // Increment video count
            $user->subscription?->incrementVideoCount();

            return response()->json([
                'success' => true,
                'message' => 'Video generated successfully via Replicate',
                'data' => [
                    'id' => $aiGeneration->id,
                    'video_url' => $savedVideoUrl,
                    'prompt' => $request->prompt,
                    'model' => 'Replicate Stable Video Diffusion',
                ],
                'generation' => $aiGeneration->fresh(),
                'usage' => $user->subscription?->getUsageSummary(),
            ]);

        } catch (\Exception $e) {
            $aiGeneration->update([
                'status' => AiGeneration::STATUS_FAILED,
                'error_message' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to generate video via Replicate',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    // Generate Video using Veo 2 (fallback/cheaper option)
    public function generateVideoVeo2(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'prompt' => 'required|string|min:3',
            'brand_kit_id' => 'nullable|exists:brand_kits,id',
            'duration' => 'nullable|integer|min:5|max:16',
            'aspect_ratio' => 'nullable|string|in:16:9,9:16,1:1',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();

        // Check subscription video limit
        $limitCheck = $this->checkVideoLimit($user);
        if (!$limitCheck['allowed']) {
            return response()->json([
                'success' => false,
                'message' => $limitCheck['error'],
                'error' => $limitCheck['error_en'],
                'limit_reached' => true,
                'remaining' => $limitCheck['remaining'] ?? 0,
                'limit' => $limitCheck['limit'] ?? 0,
            ], 403);
        }

        // Respect subscription duration limit
        $maxAllowedDuration = $limitCheck['max_duration'] ?? 16;
        $duration = min($request->duration ?? 8, $maxAllowedDuration); // Respect subscription limit
        $aspectRatio = $request->aspect_ratio ?? '16:9';

        // Create AI Generation record
        $aiGeneration = AiGeneration::create([
            'user_id' => $user->id,
            'brand_kit_id' => $request->brand_kit_id,
            'type' => 'video',
            'prompt' => $request->prompt,
            'settings' => [
                'provider' => 'veo2',
                'model' => 'veo-2.0-generate-001',
                'duration' => $duration,
                'aspect_ratio' => $aspectRatio,
            ],
            'status' => AiGeneration::STATUS_PROCESSING,
        ]);

        try {
            $geminiApiKey = env('GEMINI_API_KEY', env('GOOGLE_AI_API_KEY', ''));

            if (empty($geminiApiKey)) {
                throw new \Exception('Gemini API key not configured on server');
            }

            // Start video generation with Veo 2
            $response = Http::withHeaders([
                'Content-Type' => 'application/json',
            ])->timeout(30)->post(
                "https://generativelanguage.googleapis.com/v1beta/models/veo-2.0-generate-001:predictLongRunning?key={$geminiApiKey}",
                [
                    'instances' => [
                        ['prompt' => $request->prompt . '. Professional quality, cinematic.']
                    ],
                    'parameters' => [
                        'aspectRatio' => $aspectRatio,
                        'durationSeconds' => $duration,
                    ]
                ]
            );

            if (!$response->successful()) {
                $errorBody = $response->json();
                throw new \Exception($errorBody['error']['message'] ?? 'Veo 2 API error');
            }

            $data = $response->json();
            $operationName = $data['name'] ?? null;

            if (!$operationName) {
                throw new \Exception('No operation name received from Veo 2 API');
            }

            // Poll for completion
            $maxAttempts = 120;
            $attempt = 0;
            $completed = false;
            $videoUrl = null;

            while ($attempt < $maxAttempts && !$completed) {
                sleep(2);
                $attempt++;

                $statusResponse = Http::get(
                    "https://generativelanguage.googleapis.com/v1beta/{$operationName}?key={$geminiApiKey}"
                );

                if ($statusResponse->successful()) {
                    $statusData = $statusResponse->json();

                    if (isset($statusData['done']) && $statusData['done'] === true) {
                        $completed = true;

                        if (isset($statusData['error'])) {
                            throw new \Exception($statusData['error']['message'] ?? 'Video generation failed');
                        }

                        $videoResponse = $statusData['response'] ?? null;
                        if ($videoResponse) {
                            $generatedVideos = $videoResponse['generatedVideos'] ?? [];
                            if (!empty($generatedVideos)) {
                                $videoBase64 = $generatedVideos[0]['video']['bytesBase64Encoded'] ?? null;

                                if ($videoBase64) {
                                    $fileName = 'ai_videos/veo2_' . uniqid() . '_' . time() . '.mp4';
                                    $videoPath = storage_path('app/public/' . $fileName);

                                    if (!file_exists(dirname($videoPath))) {
                                        mkdir(dirname($videoPath), 0755, true);
                                    }

                                    file_put_contents($videoPath, base64_decode($videoBase64));
                                    $videoUrl = url('storage/' . $fileName);
                                }
                            }
                        }
                    }
                }
            }

            if (!$completed) {
                throw new \Exception('Video generation timed out');
            }

            $result = [
                'video_url' => $videoUrl,
                'duration' => $duration,
                'aspect_ratio' => $aspectRatio,
                'model' => 'veo-2.0-generate-001',
                'provider' => 'google_veo2',
                'generated_at' => now()->toISOString(),
            ];

            $aiGeneration->update([
                'result' => json_encode($result),
                'status' => AiGeneration::STATUS_COMPLETED,
                'tokens_used' => $duration * 5,
            ]);

            // Increment video count
            $user->subscription?->incrementVideoCount();

            return response()->json([
                'success' => true,
                'message' => 'Video generated successfully via Veo 2',
                'data' => [
                    'id' => $aiGeneration->id,
                    'video_url' => $videoUrl,
                    'duration' => $duration,
                    'aspect_ratio' => $aspectRatio,
                    'prompt' => $request->prompt,
                    'model' => 'Google Veo 2',
                ],
                'generation' => $aiGeneration->fresh(),
                'usage' => $user->subscription?->getUsageSummary(),
            ]);

        } catch (\Exception $e) {
            $aiGeneration->update([
                'status' => AiGeneration::STATUS_FAILED,
                'error_message' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to generate video via Veo 2',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get subscription usage summary
     */
    public function getUsageSummary(Request $request)
    {
        $user = $request->user();
        $subscription = $user->subscription;

        if (!$subscription) {
            return response()->json([
                'success' => false,
                'message' => 'No active subscription',
                'error' => 'Subscription required',
            ], 403);
        }

        return response()->json([
            'success' => true,
            'usage' => $subscription->getUsageSummary(),
            'subscription' => [
                'name' => $subscription->name,
                'type' => $subscription->type,
                'status' => $subscription->status,
                'ends_at' => $subscription->ends_at,
            ],
        ]);
    }
}
