<?php

namespace App\Filament\Pages;

use App\Models\Setting;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Pages\Page;
use Filament\Notifications\Notification;

class AIContentManagement extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-sparkles';

    protected static string $view = 'filament.pages.ai-content-management';

    protected static ?string $navigationGroup = 'Settings';

    protected static ?string $navigationLabel = 'إدارة المحتوى الذكي';

    protected static ?string $title = 'إعدادات توليد المحتوى بالذكاء الاصطناعي';

    protected static ?int $navigationSort = 5;

    public ?array $data = [];

    public function mount(): void
    {
        $this->form->fill($this->getSettingsData());
    }

    protected function getSettingsData(): array
    {
        $settings = Setting::whereIn('key', [
            // General AI Settings
            'ai_content_generation_enabled',
            'ai_provider',
            'ai_default_language',
            'ai_response_timeout',

            // Text Generation
            'ai_text_generation_enabled',
            'ai_text_model',
            'ai_text_max_tokens',
            'ai_text_temperature',
            'ai_text_top_p',

            // Image Generation
            'ai_image_generation_enabled',
            'ai_image_provider',
            'ai_image_model',
            'ai_image_quality',
            'ai_image_size',
            'ai_image_max_count',

            // Video Generation
            'ai_video_generation_enabled',
            'ai_video_provider',
            'ai_video_model',
            'ai_video_max_duration',
            'ai_video_quality',
            'ai_video_resolution',

            // Content Ideas
            'ai_content_ideas_enabled',
            'ai_hashtag_generator_enabled',
            'ai_caption_generator_enabled',
            'ai_content_scheduler_enabled',

            // Image Editing
            'ai_image_edit_enabled',
            'ai_image_enhance_enabled',
            'ai_background_removal_enabled',
            'ai_image_resize_enabled',
            'ai_image_filters_enabled',

            // Video Editing
            'ai_video_edit_enabled',
            'ai_video_trim_enabled',
            'ai_video_subtitle_enabled',
            'ai_video_effects_enabled',

            // OpenAI Settings
            'openai_enabled',
            'openai_api_key',
            'openai_organization_id',
            'openai_model',
            'openai_max_tokens',

            // Stability AI Settings
            'stability_ai_enabled',
            'stability_ai_api_key',
            'stability_ai_engine',

            // Midjourney Settings
            'midjourney_enabled',
            'midjourney_api_key',
            'midjourney_version',

            // DALL-E Settings
            'dalle_enabled',
            'dalle_version',
            'dalle_quality',
            'dalle_size',

            // Usage Limits
            'ai_daily_request_limit',
            'ai_monthly_request_limit',
            'ai_per_user_daily_limit',
            'ai_cost_tracking_enabled',

            // Features
            'ai_auto_translate_enabled',
            'ai_content_moderation_enabled',
            'ai_plagiarism_check_enabled',
            'ai_seo_optimization_enabled',
        ])->get();

        $data = [];
        foreach ($settings as $setting) {
            $data[$setting->key] = $setting->value;
        }

        return $data;
    }

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Tabs::make('AI Content Settings')
                    ->tabs([
                        // General Settings Tab
                        Forms\Components\Tabs\Tab::make('إعدادات عامة')
                            ->icon('heroicon-o-cog-6-tooth')
                            ->schema([
                                Forms\Components\Section::make('التفعيل الأساسي')
                                    ->schema([
                                        Forms\Components\Toggle::make('ai_content_generation_enabled')
                                            ->label('تفعيل توليد المحتوى بالذكاء الاصطناعي')
                                            ->helperText('تفعيل جميع ميزات الذكاء الاصطناعي')
                                            ->default(true)
                                            ->live(),

                                        Forms\Components\Select::make('ai_provider')
                                            ->label('مزود الخدمة الافتراضي')
                                            ->options([
                                                'openai' => 'OpenAI (GPT-4, DALL-E)',
                                                'stability_ai' => 'Stability AI (Stable Diffusion)',
                                                'midjourney' => 'Midjourney',
                                                'anthropic' => 'Anthropic (Claude)',
                                                'google' => 'Google (Gemini)',
                                            ])
                                            ->default('openai')
                                            ->searchable()
                                            ->visible(fn ($get) => $get('ai_content_generation_enabled')),

                                        Forms\Components\Select::make('ai_default_language')
                                            ->label('اللغة الافتراضية')
                                            ->options([
                                                'ar' => 'العربية',
                                                'en' => 'English',
                                                'fr' => 'Français',
                                                'es' => 'Español',
                                            ])
                                            ->default('ar')
                                            ->searchable()
                                            ->visible(fn ($get) => $get('ai_content_generation_enabled')),

                                        Forms\Components\TextInput::make('ai_response_timeout')
                                            ->label('مهلة الاستجابة (ثانية)')
                                            ->numeric()
                                            ->default(30)
                                            ->minValue(10)
                                            ->maxValue(120)
                                            ->suffix('ثانية')
                                            ->visible(fn ($get) => $get('ai_content_generation_enabled')),
                                    ])->columns(2),
                            ]),

                        // Text Generation Tab
                        Forms\Components\Tabs\Tab::make('توليد النصوص')
                            ->icon('heroicon-o-document-text')
                            ->schema([
                                Forms\Components\Section::make('إعدادات توليد النصوص')
                                    ->schema([
                                        Forms\Components\Toggle::make('ai_text_generation_enabled')
                                            ->label('تفعيل توليد النصوص')
                                            ->default(true)
                                            ->live(),

                                        Forms\Components\Select::make('ai_text_model')
                                            ->label('النموذج المستخدم')
                                            ->options([
                                                'gpt-4' => 'GPT-4 (الأفضل)',
                                                'gpt-4-turbo' => 'GPT-4 Turbo (أسرع)',
                                                'gpt-3.5-turbo' => 'GPT-3.5 Turbo (اقتصادي)',
                                                'claude-3-opus' => 'Claude 3 Opus',
                                                'gemini-pro' => 'Gemini Pro',
                                            ])
                                            ->default('gpt-4')
                                            ->searchable()
                                            ->visible(fn ($get) => $get('ai_text_generation_enabled')),

                                        Forms\Components\TextInput::make('ai_text_max_tokens')
                                            ->label('الحد الأقصى للكلمات (Tokens)')
                                            ->numeric()
                                            ->default(2000)
                                            ->minValue(100)
                                            ->maxValue(8000)
                                            ->visible(fn ($get) => $get('ai_text_generation_enabled')),

                                        Forms\Components\TextInput::make('ai_text_temperature')
                                            ->label('درجة الإبداع (Temperature)')
                                            ->helperText('0 = محافظ، 1 = مبدع')
                                            ->numeric()
                                            ->default(0.7)
                                            ->minValue(0)
                                            ->maxValue(1)
                                            ->step(0.1)
                                            ->visible(fn ($get) => $get('ai_text_generation_enabled')),

                                        Forms\Components\TextInput::make('ai_text_top_p')
                                            ->label('Top P')
                                            ->helperText('التحكم في تنوع النتائج')
                                            ->numeric()
                                            ->default(1)
                                            ->minValue(0)
                                            ->maxValue(1)
                                            ->step(0.1)
                                            ->visible(fn ($get) => $get('ai_text_generation_enabled')),
                                    ])->columns(2),

                                Forms\Components\Section::make('ميزات النصوص')
                                    ->schema([
                                        Forms\Components\Toggle::make('ai_content_ideas_enabled')
                                            ->label('توليد أفكار المحتوى')
                                            ->default(true),

                                        Forms\Components\Toggle::make('ai_hashtag_generator_enabled')
                                            ->label('مولد الهاشتاجات')
                                            ->default(true),

                                        Forms\Components\Toggle::make('ai_caption_generator_enabled')
                                            ->label('مولد التعليقات')
                                            ->default(true),

                                        Forms\Components\Toggle::make('ai_content_scheduler_enabled')
                                            ->label('جدولة المحتوى الذكية')
                                            ->helperText('اقتراح أفضل أوقات النشر')
                                            ->default(true),
                                    ])->columns(2),
                            ]),

                        // Image Generation Tab
                        Forms\Components\Tabs\Tab::make('توليد الصور')
                            ->icon('heroicon-o-photo')
                            ->schema([
                                Forms\Components\Section::make('إعدادات توليد الصور')
                                    ->schema([
                                        Forms\Components\Toggle::make('ai_image_generation_enabled')
                                            ->label('تفعيل توليد الصور')
                                            ->default(true)
                                            ->live(),

                                        Forms\Components\Select::make('ai_image_provider')
                                            ->label('مزود الخدمة')
                                            ->options([
                                                'dalle' => 'DALL-E (OpenAI)',
                                                'stability_ai' => 'Stable Diffusion (Stability AI)',
                                                'midjourney' => 'Midjourney',
                                            ])
                                            ->default('dalle')
                                            ->searchable()
                                            ->visible(fn ($get) => $get('ai_image_generation_enabled')),

                                        Forms\Components\Select::make('ai_image_model')
                                            ->label('النموذج')
                                            ->options([
                                                'dall-e-3' => 'DALL-E 3 (الأحدث)',
                                                'dall-e-2' => 'DALL-E 2',
                                                'stable-diffusion-xl' => 'Stable Diffusion XL',
                                                'midjourney-v6' => 'Midjourney V6',
                                            ])
                                            ->default('dall-e-3')
                                            ->searchable()
                                            ->visible(fn ($get) => $get('ai_image_generation_enabled')),

                                        Forms\Components\Select::make('ai_image_quality')
                                            ->label('جودة الصورة')
                                            ->options([
                                                'standard' => 'قياسية (أسرع وأرخص)',
                                                'hd' => 'عالية الدقة (HD)',
                                            ])
                                            ->default('hd')
                                            ->visible(fn ($get) => $get('ai_image_generation_enabled')),

                                        Forms\Components\Select::make('ai_image_size')
                                            ->label('حجم الصورة')
                                            ->options([
                                                '256x256' => '256 × 256',
                                                '512x512' => '512 × 512',
                                                '1024x1024' => '1024 × 1024 (مربع)',
                                                '1024x1792' => '1024 × 1792 (عمودي)',
                                                '1792x1024' => '1792 × 1024 (أفقي)',
                                            ])
                                            ->default('1024x1024')
                                            ->visible(fn ($get) => $get('ai_image_generation_enabled')),

                                        Forms\Components\TextInput::make('ai_image_max_count')
                                            ->label('الحد الأقصى لعدد الصور')
                                            ->helperText('عدد الصور التي يمكن توليدها في طلب واحد')
                                            ->numeric()
                                            ->default(4)
                                            ->minValue(1)
                                            ->maxValue(10)
                                            ->visible(fn ($get) => $get('ai_image_generation_enabled')),
                                    ])->columns(2),

                                Forms\Components\Section::make('تحرير الصور')
                                    ->schema([
                                        Forms\Components\Toggle::make('ai_image_edit_enabled')
                                            ->label('تفعيل تحرير الصور')
                                            ->default(true),

                                        Forms\Components\Toggle::make('ai_image_enhance_enabled')
                                            ->label('تحسين جودة الصور')
                                            ->default(true),

                                        Forms\Components\Toggle::make('ai_background_removal_enabled')
                                            ->label('إزالة الخلفية')
                                            ->default(true),

                                        Forms\Components\Toggle::make('ai_image_resize_enabled')
                                            ->label('تغيير حجم الصور')
                                            ->default(true),

                                        Forms\Components\Toggle::make('ai_image_filters_enabled')
                                            ->label('الفلاتر والتأثيرات')
                                            ->default(true),
                                    ])->columns(2),
                            ]),

                        // Video Generation Tab
                        Forms\Components\Tabs\Tab::make('توليد الفيديو')
                            ->icon('heroicon-o-video-camera')
                            ->schema([
                                Forms\Components\Section::make('إعدادات توليد الفيديو')
                                    ->schema([
                                        Forms\Components\Toggle::make('ai_video_generation_enabled')
                                            ->label('تفعيل توليد الفيديو')
                                            ->helperText('ميزة تجريبية')
                                            ->default(false)
                                            ->live(),

                                        Forms\Components\Select::make('ai_video_provider')
                                            ->label('مزود الخدمة')
                                            ->options([
                                                'runway' => 'Runway ML',
                                                'pika' => 'Pika Labs',
                                                'synthesia' => 'Synthesia',
                                            ])
                                            ->default('runway')
                                            ->searchable()
                                            ->visible(fn ($get) => $get('ai_video_generation_enabled')),

                                        Forms\Components\Select::make('ai_video_model')
                                            ->label('النموذج')
                                            ->options([
                                                'gen-2' => 'Gen-2 (Runway)',
                                                'pika-1.0' => 'Pika 1.0',
                                            ])
                                            ->default('gen-2')
                                            ->visible(fn ($get) => $get('ai_video_generation_enabled')),

                                        Forms\Components\TextInput::make('ai_video_max_duration')
                                            ->label('الحد الأقصى للمدة (ثانية)')
                                            ->numeric()
                                            ->default(10)
                                            ->minValue(3)
                                            ->maxValue(60)
                                            ->suffix('ثانية')
                                            ->visible(fn ($get) => $get('ai_video_generation_enabled')),

                                        Forms\Components\Select::make('ai_video_quality')
                                            ->label('جودة الفيديو')
                                            ->options([
                                                'draft' => 'مسودة (أسرع)',
                                                'standard' => 'قياسية',
                                                'high' => 'عالية',
                                            ])
                                            ->default('standard')
                                            ->visible(fn ($get) => $get('ai_video_generation_enabled')),

                                        Forms\Components\Select::make('ai_video_resolution')
                                            ->label('الدقة')
                                            ->options([
                                                '720p' => '720p (HD)',
                                                '1080p' => '1080p (Full HD)',
                                                '4k' => '4K (Ultra HD)',
                                            ])
                                            ->default('1080p')
                                            ->visible(fn ($get) => $get('ai_video_generation_enabled')),
                                    ])->columns(2),

                                Forms\Components\Section::make('تحرير الفيديو')
                                    ->schema([
                                        Forms\Components\Toggle::make('ai_video_edit_enabled')
                                            ->label('تفعيل تحرير الفيديو')
                                            ->default(true),

                                        Forms\Components\Toggle::make('ai_video_trim_enabled')
                                            ->label('قص الفيديو')
                                            ->default(true),

                                        Forms\Components\Toggle::make('ai_video_subtitle_enabled')
                                            ->label('إضافة ترجمات تلقائية')
                                            ->default(true),

                                        Forms\Components\Toggle::make('ai_video_effects_enabled')
                                            ->label('المؤثرات')
                                            ->default(true),
                                    ])->columns(2),
                            ]),

                        // API Keys Tab
                        Forms\Components\Tabs\Tab::make('مفاتيح API')
                            ->icon('heroicon-o-key')
                            ->schema([
                                Forms\Components\Section::make('OpenAI')
                                    ->schema([
                                        Forms\Components\Toggle::make('openai_enabled')
                                            ->label('تفعيل OpenAI')
                                            ->default(true)
                                            ->live(),

                                        Forms\Components\TextInput::make('openai_api_key')
                                            ->label('OpenAI API Key')
                                            ->placeholder('sk-xxxxxxxxxxxxxxxxxxxxxxxx')
                                            ->password()
                                            ->revealable()
                                            ->maxLength(255)
                                            ->visible(fn ($get) => $get('openai_enabled')),

                                        Forms\Components\TextInput::make('openai_organization_id')
                                            ->label('Organization ID (اختياري)')
                                            ->visible(fn ($get) => $get('openai_enabled')),

                                        Forms\Components\Placeholder::make('openai_help')
                                            ->label('كيفية الحصول على API Key')
                                            ->content('اذهب إلى https://platform.openai.com/api-keys')
                                            ->visible(fn ($get) => $get('openai_enabled')),
                                    ])->columns(2),

                                Forms\Components\Section::make('Stability AI')
                                    ->schema([
                                        Forms\Components\Toggle::make('stability_ai_enabled')
                                            ->label('تفعيل Stability AI')
                                            ->default(false)
                                            ->live(),

                                        Forms\Components\TextInput::make('stability_ai_api_key')
                                            ->label('Stability AI API Key')
                                            ->password()
                                            ->revealable()
                                            ->maxLength(255)
                                            ->visible(fn ($get) => $get('stability_ai_enabled')),

                                        Forms\Components\Placeholder::make('stability_help')
                                            ->label('كيفية الحصول على API Key')
                                            ->content('اذهب إلى https://platform.stability.ai/')
                                            ->visible(fn ($get) => $get('stability_ai_enabled')),
                                    ])->columns(2),

                                Forms\Components\Section::make('Midjourney')
                                    ->schema([
                                        Forms\Components\Toggle::make('midjourney_enabled')
                                            ->label('تفعيل Midjourney')
                                            ->default(false)
                                            ->live(),

                                        Forms\Components\TextInput::make('midjourney_api_key')
                                            ->label('Midjourney API Key')
                                            ->password()
                                            ->revealable()
                                            ->maxLength(255)
                                            ->visible(fn ($get) => $get('midjourney_enabled')),

                                        Forms\Components\Placeholder::make('midjourney_note')
                                            ->label('ملاحظة')
                                            ->content('Midjourney لا يوفر API رسمي حالياً. استخدم خدمات طرف ثالث.')
                                            ->visible(fn ($get) => $get('midjourney_enabled')),
                                    ])->columns(2),
                            ]),

                        // Usage Limits Tab
                        Forms\Components\Tabs\Tab::make('حدود الاستخدام')
                            ->icon('heroicon-o-shield-check')
                            ->schema([
                                Forms\Components\Section::make('الحدود')
                                    ->schema([
                                        Forms\Components\TextInput::make('ai_daily_request_limit')
                                            ->label('الحد اليومي للطلبات (إجمالي)')
                                            ->numeric()
                                            ->default(1000)
                                            ->minValue(10)
                                            ->suffix('طلب/يوم'),

                                        Forms\Components\TextInput::make('ai_monthly_request_limit')
                                            ->label('الحد الشهري للطلبات')
                                            ->numeric()
                                            ->default(10000)
                                            ->minValue(100)
                                            ->suffix('طلب/شهر'),

                                        Forms\Components\TextInput::make('ai_per_user_daily_limit')
                                            ->label('الحد اليومي للمستخدم الواحد')
                                            ->numeric()
                                            ->default(50)
                                            ->minValue(5)
                                            ->suffix('طلب/يوم'),

                                        Forms\Components\Toggle::make('ai_cost_tracking_enabled')
                                            ->label('تتبع التكاليف')
                                            ->helperText('تتبع التكاليف الفعلية لاستخدام API')
                                            ->default(true),
                                    ])->columns(2),

                                Forms\Components\Placeholder::make('limits_note')
                                    ->label('💡 نصيحة')
                                    ->content('ضع حدود معقولة لتجنب التكاليف الزائدة')
                                    ->columnSpanFull(),
                            ]),

                        // Additional Features Tab
                        Forms\Components\Tabs\Tab::make('ميزات إضافية')
                            ->icon('heroicon-o-plus-circle')
                            ->schema([
                                Forms\Components\Section::make('ميزات ذكية إضافية')
                                    ->schema([
                                        Forms\Components\Toggle::make('ai_auto_translate_enabled')
                                            ->label('الترجمة التلقائية')
                                            ->helperText('ترجمة المحتوى تلقائياً بين اللغات')
                                            ->default(true),

                                        Forms\Components\Toggle::make('ai_content_moderation_enabled')
                                            ->label('فحص المحتوى')
                                            ->helperText('كشف المحتوى غير المناسب')
                                            ->default(true),

                                        Forms\Components\Toggle::make('ai_plagiarism_check_enabled')
                                            ->label('كشف الانتحال')
                                            ->helperText('التحقق من أصالة المحتوى')
                                            ->default(false),

                                        Forms\Components\Toggle::make('ai_seo_optimization_enabled')
                                            ->label('تحسين SEO')
                                            ->helperText('تحسين المحتوى لمحركات البحث')
                                            ->default(true),
                                    ])->columns(2),
                            ]),
                    ])
                    ->columnSpanFull()
            ])
            ->statePath('data');
    }

    public function save(): void
    {
        $data = $this->form->getState();

        foreach ($data as $key => $value) {
            Setting::updateOrCreate(
                ['key' => $key],
                [
                    'value' => $value,
                    'type' => is_bool($value) ? 'boolean' : (is_array($value) ? 'array' : (is_numeric($value) ? 'number' : 'string')),
                    'group' => 'ai_content',
                    'is_public' => in_array($key, [
                        'ai_content_generation_enabled',
                        'ai_text_generation_enabled',
                        'ai_image_generation_enabled',
                        'ai_video_generation_enabled',
                        'ai_image_edit_enabled',
                        'ai_content_ideas_enabled',
                        'ai_hashtag_generator_enabled',
                        'ai_caption_generator_enabled',
                        // Feature flags - safe to expose
                    ]),
                ]
            );
        }

        // Clear cache
        \Cache::forget('app_config');
        \Cache::forget('ai_content_settings');

        Notification::make()
            ->title('تم الحفظ بنجاح')
            ->success()
            ->body('تم حفظ إعدادات توليد المحتوى الذكي بنجاح')
            ->send();
    }
}
