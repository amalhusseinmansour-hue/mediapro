# إعداد AI لتوليد وتعديل الصور والفيديو

## نظرة عامة
هذا الدليل يشرح كيفية ربط توليد وتعديل الصور والفيديو باستخدام:
- **Replicate** (Stable Diffusion, Video Models)
- **Runway ML** (Video Generation)
- **Stability AI** (Image Generation)
- **Leonardo AI** (Image Generation)

مع التحكم الكامل من لوحة الأدمن (Filament Admin Panel).

---

## 1. إعدادات قاعدة البيانات

### إضافة حقول AI في جدول Settings

```sql
-- إعدادات AI العامة
INSERT INTO settings (group_name, key, value, type, description) VALUES
('ai', 'image_generation_enabled', '1', 'boolean', 'تفعيل/إيقاف توليد الصور بالذكاء الاصطناعي'),
('ai', 'video_generation_enabled', '1', 'boolean', 'تفعيل/إيقاف توليد الفيديو بالذكاء الاصطناعي'),
('ai', 'image_provider', 'replicate', 'string', 'مزود خدمة الصور (replicate, stability, leonardo)'),
('ai', 'video_provider', 'runway', 'string', 'مزود خدمة الفيديو (runway, replicate)'),

-- Replicate Settings
('ai', 'replicate_api_key', '', 'string', 'Replicate API Key'),
('ai', 'replicate_image_model', 'stability-ai/sdxl:39ed52f2a78e934b3ba6e2a89f5b1c712de7dfea535525255b1aa35c5565e08b', 'string', 'Replicate Image Model'),
('ai', 'replicate_video_model', 'anotherjesse/zeroscope-v2-xl:9f747673945c62801b13b84701c783929c0ee784e4748ec062204894dda1a351', 'string', 'Replicate Video Model'),

-- Runway Settings
('ai', 'runway_api_key', '', 'string', 'Runway ML API Key'),
('ai', 'runway_base_url', 'https://api.runwayml.com/v1', 'string', 'Runway API Base URL'),

-- Stability AI Settings
('ai', 'stability_api_key', '', 'string', 'Stability AI API Key'),
('ai', 'stability_engine', 'stable-diffusion-xl-1024-v1-0', 'string', 'Stability Engine'),

-- Leonardo AI Settings
('ai', 'leonardo_api_key', '', 'string', 'Leonardo AI API Key'),

-- Default Generation Settings
('ai', 'default_image_width', '1024', 'integer', 'عرض الصورة الافتراضي'),
('ai', 'default_image_height', '1024', 'integer', 'ارتفاع الصورة الافتراضي'),
('ai', 'default_video_length', '3', 'integer', 'طول الفيديو بالثواني'),
('ai', 'guidance_scale', '7.5', 'decimal', 'مقياس التوجيه (CFG Scale)'),
('ai', 'steps', '50', 'integer', 'عدد الخطوات (Steps)'),

-- Cost Settings
('ai', 'image_cost_per_generation', '0.1', 'decimal', 'تكلفة توليد صورة واحدة ($)'),
('ai', 'video_cost_per_second', '0.5', 'decimal', 'تكلفة توليد فيديو لكل ثانية ($)');
```

---

## 2. إنشاء جدول AI Generations

```sql
CREATE TABLE ai_generations (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    type ENUM('image', 'video') NOT NULL,
    provider VARCHAR(50) NOT NULL,
    prompt TEXT NOT NULL,
    negative_prompt TEXT NULL,
    parameters JSON NULL,
    status ENUM('pending', 'processing', 'completed', 'failed') DEFAULT 'pending',
    result_url TEXT NULL,
    cost DECIMAL(10, 2) DEFAULT 0.00,
    error_message TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_user_id (user_id),
    INDEX idx_type (type),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

---

## 3. إنشاء AI Service في Laravel

### ملف: `app/Services/AIMediaService.php`

```php
<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use App\Models\Setting;
use App\Models\AiGeneration;

class AIMediaService
{
    /**
     * توليد صورة
     */
    public function generateImage($userId, $prompt, $options = [])
    {
        // Check if enabled
        if (!Setting::get('image_generation_enabled', false)) {
            throw new \Exception('Image generation is disabled');
        }

        // Create generation record
        $generation = AiGeneration::create([
            'user_id' => $userId,
            'type' => 'image',
            'provider' => Setting::get('image_provider', 'replicate'),
            'prompt' => $prompt,
            'negative_prompt' => $options['negative_prompt'] ?? null,
            'parameters' => json_encode($options),
            'status' => 'pending',
            'cost' => Setting::get('image_cost_per_generation', 0.1),
        ]);

        // Call provider
        $provider = Setting::get('image_provider', 'replicate');

        try {
            $generation->update(['status' => 'processing']);

            $result = match($provider) {
                'replicate' => $this->generateImageReplicate($prompt, $options),
                'stability' => $this->generateImageStability($prompt, $options),
                'leonardo' => $this->generateImageLeonardo($prompt, $options),
                default => throw new \Exception("Unknown provider: {$provider}")
            };

            $generation->update([
                'status' => 'completed',
                'result_url' => $result['url'],
            ]);

            return [
                'success' => true,
                'generation_id' => $generation->id,
                'image_url' => $result['url'],
                'cost' => $generation->cost,
            ];

        } catch (\Exception $e) {
            $generation->update([
                'status' => 'failed',
                'error_message' => $e->getMessage(),
            ]);

            throw $e;
        }
    }

    /**
     * توليد صورة عبر Replicate
     */
    private function generateImageReplicate($prompt, $options)
    {
        $apiKey = Setting::get('replicate_api_key');
        if (empty($apiKey)) {
            throw new \Exception('Replicate API key not configured');
        }

        $model = Setting::get('replicate_image_model');

        // Create prediction
        $response = Http::withHeaders([
            'Authorization' => "Token {$apiKey}",
            'Content-Type' => 'application/json',
        ])->post('https://api.replicate.com/v1/predictions', [
            'version' => $model,
            'input' => [
                'prompt' => $prompt,
                'negative_prompt' => $options['negative_prompt'] ?? '',
                'width' => $options['width'] ?? Setting::get('default_image_width', 1024),
                'height' => $options['height'] ?? Setting::get('default_image_height', 1024),
                'num_inference_steps' => $options['steps'] ?? Setting::get('steps', 50),
                'guidance_scale' => $options['guidance_scale'] ?? Setting::get('guidance_scale', 7.5),
            ],
        ]);

        if (!$response->successful()) {
            throw new \Exception('Replicate API error: ' . $response->body());
        }

        $data = $response->json();
        $predictionId = $data['id'];

        // Poll for result
        return $this->pollReplicateResult($predictionId);
    }

    /**
     * استطلاع نتيجة Replicate
     */
    private function pollReplicateResult($predictionId)
    {
        $apiKey = Setting::get('replicate_api_key');
        $maxAttempts = 60;
        $attempts = 0;

        while ($attempts < $maxAttempts) {
            sleep(2);
            $attempts++;

            $response = Http::withHeaders([
                'Authorization' => "Token {$apiKey}",
            ])->get("https://api.replicate.com/v1/predictions/{$predictionId}");

            if ($response->successful()) {
                $data = $response->json();
                $status = $data['status'];

                if ($status === 'succeeded') {
                    $output = $data['output'];
                    $imageUrl = is_array($output) ? $output[0] : $output;

                    return ['url' => $imageUrl];
                } elseif ($status === 'failed') {
                    throw new \Exception('Generation failed: ' . ($data['error'] ?? 'Unknown error'));
                }
            }
        }

        throw new \Exception('Generation timeout');
    }

    /**
     * توليد صورة عبر Stability AI
     */
    private function generateImageStability($prompt, $options)
    {
        $apiKey = Setting::get('stability_api_key');
        if (empty($apiKey)) {
            throw new \Exception('Stability AI API key not configured');
        }

        $engine = Setting::get('stability_engine', 'stable-diffusion-xl-1024-v1-0');

        $response = Http::withHeaders([
            'Authorization' => "Bearer {$apiKey}",
            'Content-Type' => 'application/json',
        ])->post("https://api.stability.ai/v1/generation/{$engine}/text-to-image", [
            'text_prompts' => [
                ['text' => $prompt, 'weight' => 1.0],
            ],
            'cfg_scale' => $options['guidance_scale'] ?? Setting::get('guidance_scale', 7.5),
            'height' => $options['height'] ?? Setting::get('default_image_height', 1024),
            'width' => $options['width'] ?? Setting::get('default_image_width', 1024),
            'steps' => $options['steps'] ?? Setting::get('steps', 50),
            'samples' => 1,
        ]);

        if (!$response->successful()) {
            throw new \Exception('Stability AI error: ' . $response->body());
        }

        $data = $response->json();
        $artifacts = $data['artifacts'];

        if (empty($artifacts)) {
            throw new \Exception('No image generated');
        }

        // Save base64 image to storage
        $base64Image = $artifacts[0]['base64'];
        $imageUrl = $this->saveBase64Image($base64Image);

        return ['url' => $imageUrl];
    }

    /**
     * توليد صورة عبر Leonardo AI
     */
    private function generateImageLeonardo($prompt, $options)
    {
        $apiKey = Setting::get('leonardo_api_key');
        if (empty($apiKey)) {
            throw new \Exception('Leonardo AI API key not configured');
        }

        $response = Http::withHeaders([
            'Authorization' => "Bearer {$apiKey}",
            'Content-Type' => 'application/json',
        ])->post('https://cloud.leonardo.ai/api/rest/v1/generations', [
            'prompt' => $prompt,
            'negative_prompt' => $options['negative_prompt'] ?? '',
            'width' => $options['width'] ?? Setting::get('default_image_width', 1024),
            'height' => $options['height'] ?? Setting::get('default_image_height', 1024),
            'num_images' => 1,
        ]);

        if (!$response->successful()) {
            throw new \Exception('Leonardo AI error: ' . $response->body());
        }

        $data = $response->json();
        $generationId = $data['sdGenerationJob']['generationId'];

        return $this->pollLeonardoResult($generationId);
    }

    /**
     * استطلاع نتيجة Leonardo
     */
    private function pollLeonardoResult($generationId)
    {
        $apiKey = Setting::get('leonardo_api_key');
        $maxAttempts = 30;
        $attempts = 0;

        while ($attempts < $maxAttempts) {
            sleep(3);
            $attempts++;

            $response = Http::withHeaders([
                'Authorization' => "Bearer {$apiKey}",
            ])->get("https://cloud.leonardo.ai/api/rest/v1/generations/{$generationId}");

            if ($response->successful()) {
                $data = $response->json();
                $generation = $data['generations_by_pk'];

                if ($generation['status'] === 'COMPLETE') {
                    $images = $generation['generated_images'];
                    if (!empty($images)) {
                        return ['url' => $images[0]['url']];
                    }
                }
            }
        }

        throw new \Exception('Leonardo generation timeout');
    }

    /**
     * توليد فيديو
     */
    public function generateVideo($userId, $prompt, $options = [])
    {
        // Check if enabled
        if (!Setting::get('video_generation_enabled', false)) {
            throw new \Exception('Video generation is disabled');
        }

        $duration = $options['duration'] ?? Setting::get('default_video_length', 3);
        $cost = Setting::get('video_cost_per_second', 0.5) * $duration;

        // Create generation record
        $generation = AiGeneration::create([
            'user_id' => $userId,
            'type' => 'video',
            'provider' => Setting::get('video_provider', 'runway'),
            'prompt' => $prompt,
            'parameters' => json_encode($options),
            'status' => 'pending',
            'cost' => $cost,
        ]);

        $provider = Setting::get('video_provider', 'runway');

        try {
            $generation->update(['status' => 'processing']);

            $result = match($provider) {
                'runway' => $this->generateVideoRunway($prompt, $options),
                'replicate' => $this->generateVideoReplicate($prompt, $options),
                default => throw new \Exception("Unknown provider: {$provider}")
            };

            $generation->update([
                'status' => 'completed',
                'result_url' => $result['url'],
            ]);

            return [
                'success' => true,
                'generation_id' => $generation->id,
                'video_url' => $result['url'],
                'cost' => $generation->cost,
            ];

        } catch (\Exception $e) {
            $generation->update([
                'status' => 'failed',
                'error_message' => $e->getMessage(),
            ]);

            throw $e;
        }
    }

    /**
     * توليد فيديو عبر Runway
     */
    private function generateVideoRunway($prompt, $options)
    {
        $apiKey = Setting::get('runway_api_key');
        if (empty($apiKey)) {
            throw new \Exception('Runway API key not configured');
        }

        $baseUrl = Setting::get('runway_base_url', 'https://api.runwayml.com/v1');
        $duration = $options['duration'] ?? Setting::get('default_video_length', 3);

        $response = Http::withHeaders([
            'Authorization' => "Bearer {$apiKey}",
            'Content-Type' => 'application/json',
        ])->post("{$baseUrl}/generate", [
            'prompt' => $prompt,
            'duration' => $duration,
        ]);

        if (!$response->successful()) {
            throw new \Exception('Runway API error: ' . $response->body());
        }

        $data = $response->json();
        $taskId = $data['task_id'];

        return $this->pollRunwayResult($taskId);
    }

    /**
     * استطلاع نتيجة Runway
     */
    private function pollRunwayResult($taskId)
    {
        $apiKey = Setting::get('runway_api_key');
        $baseUrl = Setting::get('runway_base_url');
        $maxAttempts = 120;
        $attempts = 0;

        while ($attempts < $maxAttempts) {
            sleep(2);
            $attempts++;

            $response = Http::withHeaders([
                'Authorization' => "Bearer {$apiKey}",
            ])->get("{$baseUrl}/tasks/{$taskId}");

            if ($response->successful()) {
                $data = $response->json();
                $status = $data['status'];

                if ($status === 'succeeded') {
                    return ['url' => $data['output']];
                } elseif ($status === 'failed') {
                    throw new \Exception('Video generation failed');
                }
            }
        }

        throw new \Exception('Video generation timeout');
    }

    /**
     * توليد فيديو عبر Replicate
     */
    private function generateVideoReplicate($prompt, $options)
    {
        $apiKey = Setting::get('replicate_api_key');
        if (empty($apiKey)) {
            throw new \Exception('Replicate API key not configured');
        }

        $model = Setting::get('replicate_video_model');
        $duration = $options['duration'] ?? Setting::get('default_video_length', 3);
        $numFrames = $duration * 24; // 24 FPS

        $response = Http::withHeaders([
            'Authorization' => "Token {$apiKey}",
            'Content-Type' => 'application/json',
        ])->post('https://api.replicate.com/v1/predictions', [
            'version' => $model,
            'input' => [
                'prompt' => $prompt,
                'num_frames' => $numFrames,
            ],
        ]);

        if (!$response->successful()) {
            throw new \Exception('Replicate Video API error: ' . $response->body());
        }

        $data = $response->json();
        $predictionId = $data['id'];

        return $this->pollReplicateVideoResult($predictionId);
    }

    /**
     * استطلاع نتيجة فيديو Replicate
     */
    private function pollReplicateVideoResult($predictionId)
    {
        $apiKey = Setting::get('replicate_api_key');
        $maxAttempts = 180; // 3 minutes
        $attempts = 0;

        while ($attempts < $maxAttempts) {
            sleep(2);
            $attempts++;

            $response = Http::withHeaders([
                'Authorization' => "Token {$apiKey}",
            ])->get("https://api.replicate.com/v1/predictions/{$predictionId}");

            if ($response->successful()) {
                $data = $response->json();
                $status = $data['status'];

                if ($status === 'succeeded') {
                    $output = $data['output'];
                    $videoUrl = is_array($output) ? $output[0] : $output;

                    return ['url' => $videoUrl];
                } elseif ($status === 'failed') {
                    throw new \Exception('Video generation failed');
                }
            }
        }

        throw new \Exception('Video generation timeout');
    }

    /**
     * حفظ صورة base64 في التخزين
     */
    private function saveBase64Image($base64Image)
    {
        $imageData = base64_decode($base64Image);
        $fileName = 'ai-images/' . uniqid() . '.png';

        \Storage::disk('public')->put($fileName, $imageData);

        return \Storage::disk('public')->url($fileName);
    }
}
```

---

## 4. إنشاء Model للـ AI Generation

### ملف: `app/Models/AiGeneration.php`

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AiGeneration extends Model
{
    protected $fillable = [
        'user_id',
        'type',
        'provider',
        'prompt',
        'negative_prompt',
        'parameters',
        'status',
        'result_url',
        'cost',
        'error_message',
    ];

    protected $casts = [
        'parameters' => 'array',
        'cost' => 'decimal:2',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
```

---

## 5. إنشاء Controller للـ API

### ملف: `app/Http/Controllers/Api/AIMediaController.php`

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Services\AIMediaService;

class AIMediaController extends Controller
{
    protected $aiService;

    public function __construct(AIMediaService $aiService)
    {
        $this->aiService = $aiService;
    }

    /**
     * توليد صورة
     */
    public function generateImage(Request $request)
    {
        $request->validate([
            'prompt' => 'required|string|max:1000',
            'negative_prompt' => 'nullable|string|max:1000',
            'width' => 'nullable|integer|min:256|max:2048',
            'height' => 'nullable|integer|min:256|max:2048',
            'steps' => 'nullable|integer|min:1|max:150',
            'guidance_scale' => 'nullable|numeric|min:1|max:20',
        ]);

        try {
            $userId = $request->user()->id;
            $prompt = $request->input('prompt');
            $options = $request->only(['negative_prompt', 'width', 'height', 'steps', 'guidance_scale']);

            $result = $this->aiService->generateImage($userId, $prompt, $options);

            return response()->json([
                'success' => true,
                'data' => $result,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * توليد فيديو
     */
    public function generateVideo(Request $request)
    {
        $request->validate([
            'prompt' => 'required|string|max:1000',
            'duration' => 'nullable|integer|min:1|max:10',
        ]);

        try {
            $userId = $request->user()->id;
            $prompt = $request->input('prompt');
            $options = $request->only(['duration']);

            $result = $this->aiService->generateVideo($userId, $prompt, $options);

            return response()->json([
                'success' => true,
                'data' => $result,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * الحصول على سجل التوليدات
     */
    public function getHistory(Request $request)
    {
        $userId = $request->user()->id;

        $generations = AiGeneration::where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $generations,
        ]);
    }
}
```

---

## 6. إضافة Routes

في ملف `routes/api.php`:

```php
use App\Http\Controllers\Api\AIMediaController;

Route::middleware('auth:sanctum')->prefix('ai')->group(function () {
    Route::post('/image/generate', [AIMediaController::class, 'generateImage']);
    Route::post('/video/generate', [AIMediaController::class, 'generateVideo']);
    Route::get('/history', [AIMediaController::class, 'getHistory']);
});
```

---

## 7. إنشاء صفحة AI Settings في Filament

### ملف: `app/Filament/Pages/AISettings.php`

```php
<?php

namespace App\Filament\Pages;

use Filament\Pages\Page;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Toggle;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use Filament\Notifications\Notification;
use App\Models\Setting;

class AISettings extends Page implements HasForms
{
    use InteractsWithForms;

    protected static ?string $navigationIcon = 'heroicon-o-sparkles';
    protected static string $view = 'filament.pages.ai-settings';
    protected static ?string $navigationLabel = 'AI Settings';
    protected static ?string $title = 'AI Media Generation Settings';
    protected static ?string $navigationGroup = 'Settings';
    protected static ?int $navigationSort = 6;

    public $image_generation_enabled;
    public $video_generation_enabled;
    public $image_provider;
    public $video_provider;

    // Replicate
    public $replicate_api_key;
    public $replicate_image_model;
    public $replicate_video_model;

    // Runway
    public $runway_api_key;
    public $runway_base_url;

    // Stability
    public $stability_api_key;
    public $stability_engine;

    // Leonardo
    public $leonardo_api_key;

    // Defaults
    public $default_image_width;
    public $default_image_height;
    public $default_video_length;
    public $guidance_scale;
    public $steps;

    // Costs
    public $image_cost_per_generation;
    public $video_cost_per_second;

    public function mount(): void
    {
        $this->form->fill([
            'image_generation_enabled' => Setting::get('image_generation_enabled', false),
            'video_generation_enabled' => Setting::get('video_generation_enabled', false),
            'image_provider' => Setting::get('image_provider', 'replicate'),
            'video_provider' => Setting::get('video_provider', 'runway'),
            'replicate_api_key' => Setting::get('replicate_api_key', ''),
            'replicate_image_model' => Setting::get('replicate_image_model', 'stability-ai/sdxl'),
            'replicate_video_model' => Setting::get('replicate_video_model', 'anotherjesse/zeroscope-v2-xl'),
            'runway_api_key' => Setting::get('runway_api_key', ''),
            'runway_base_url' => Setting::get('runway_base_url', 'https://api.runwayml.com/v1'),
            'stability_api_key' => Setting::get('stability_api_key', ''),
            'stability_engine' => Setting::get('stability_engine', 'stable-diffusion-xl-1024-v1-0'),
            'leonardo_api_key' => Setting::get('leonardo_api_key', ''),
            'default_image_width' => Setting::get('default_image_width', 1024),
            'default_image_height' => Setting::get('default_image_height', 1024),
            'default_video_length' => Setting::get('default_video_length', 3),
            'guidance_scale' => Setting::get('guidance_scale', 7.5),
            'steps' => Setting::get('steps', 50),
            'image_cost_per_generation' => Setting::get('image_cost_per_generation', 0.1),
            'video_cost_per_second' => Setting::get('video_cost_per_second', 0.5),
        ]);
    }

    protected function getFormSchema(): array
    {
        return [
            Section::make('General Settings')
                ->schema([
                    Toggle::make('image_generation_enabled')
                        ->label('Enable Image Generation'),
                    Toggle::make('video_generation_enabled')
                        ->label('Enable Video Generation'),
                ]),

            Section::make('Provider Selection')
                ->schema([
                    Select::make('image_provider')
                        ->label('Image Provider')
                        ->options([
                            'replicate' => 'Replicate',
                            'stability' => 'Stability AI',
                            'leonardo' => 'Leonardo AI',
                        ]),
                    Select::make('video_provider')
                        ->label('Video Provider')
                        ->options([
                            'runway' => 'Runway ML',
                            'replicate' => 'Replicate',
                        ]),
                ]),

            Section::make('Replicate Configuration')
                ->collapsed()
                ->schema([
                    TextInput::make('replicate_api_key')
                        ->label('API Key')
                        ->password(),
                    TextInput::make('replicate_image_model')
                        ->label('Image Model'),
                    TextInput::make('replicate_video_model')
                        ->label('Video Model'),
                ]),

            Section::make('Runway Configuration')
                ->collapsed()
                ->schema([
                    TextInput::make('runway_api_key')
                        ->label('API Key')
                        ->password(),
                    TextInput::make('runway_base_url')
                        ->label('Base URL'),
                ]),

            Section::make('Stability AI Configuration')
                ->collapsed()
                ->schema([
                    TextInput::make('stability_api_key')
                        ->label('API Key')
                        ->password(),
                    TextInput::make('stability_engine')
                        ->label('Engine'),
                ]),

            Section::make('Leonardo AI Configuration')
                ->collapsed()
                ->schema([
                    TextInput::make('leonardo_api_key')
                        ->label('API Key')
                        ->password(),
                ]),

            Section::make('Default Generation Settings')
                ->schema([
                    TextInput::make('default_image_width')
                        ->numeric()
                        ->minValue(256)
                        ->maxValue(2048),
                    TextInput::make('default_image_height')
                        ->numeric()
                        ->minValue(256)
                        ->maxValue(2048),
                    TextInput::make('default_video_length')
                        ->label('Video Length (seconds)')
                        ->numeric()
                        ->minValue(1)
                        ->maxValue(10),
                    TextInput::make('guidance_scale')
                        ->numeric()
                        ->step(0.1)
                        ->minValue(1)
                        ->maxValue(20),
                    TextInput::make('steps')
                        ->numeric()
                        ->minValue(1)
                        ->maxValue(150),
                ]),

            Section::make('Cost Settings')
                ->schema([
                    TextInput::make('image_cost_per_generation')
                        ->label('Cost per Image ($)')
                        ->numeric()
                        ->step(0.01),
                    TextInput::make('video_cost_per_second')
                        ->label('Cost per Second ($)')
                        ->numeric()
                        ->step(0.01),
                ]),
        ];
    }

    public function submit(): void
    {
        $data = $this->form->getState();

        foreach ($data as $key => $value) {
            Setting::set($key, $value);
        }

        Notification::make()
            ->title('AI Settings saved successfully')
            ->success()
            ->send();
    }
}
```

### View: `resources/views/filament/pages/ai-settings.blade.php`

```blade
<x-filament::page>
    <form wire:submit.prevent="submit">
        {{ $this->form }}

        <div class="flex justify-end mt-6">
            <x-filament::button type="submit">
                Save Settings
            </x-filament::button>
        </div>
    </form>
</x-filament::page>
```

---

## 8. الحصول على API Keys

### Replicate
1. سجّل في: https://replicate.com/
2. اذهب إلى Account Settings > API tokens
3. انسخ API Token

### Runway ML
1. سجّل في: https://runwayml.com/
2. احصل على API Key من Dashboard

### Stability AI
1. سجّل في: https://platform.stability.ai/
2. احصل على API Key من Account

### Leonardo AI
1. سجّل في: https://leonardo.ai/
2. احصل على API Key من Settings

---

## 9. تسجيل الـ Service في Laravel

في `app/Providers/AppServiceProvider.php`:

```php
use App\Services\AIMediaService;

public function register()
{
    $this->app->singleton(AIMediaService::class);
}
```

---

## 10. الاستخدام من Flutter

```dart
final aiService = Get.find<AIMediaService>();

// توليد صورة
final result = await aiService.generateImage(
  prompt: 'A beautiful sunset over mountains',
  negativePrompt: 'blurry, low quality',
);

// توليد فيديو
final videoResult = await aiService.generateVideo(
  prompt: 'A cat walking on the beach',
  duration: 3,
);
```

---

## ملخص الميزات

✅ ربط كامل مع Replicate, Runway, Stability AI, Leonardo AI
✅ التحكم 100% من الأدمن بانل
✅ اختيار المزود (Provider) ديناميكياً
✅ إعدادات قابلة للتخصيص (الأبعاد، الخطوات، إلخ)
✅ تتبع التكاليف
✅ حفظ سجل التوليدات
✅ معالجة الأخطاء
✅ Polling للنتائج

كل شيء جاهز للاستخدام! 🎉
