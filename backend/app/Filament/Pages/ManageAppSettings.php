<?php

namespace App\Filament\Pages;

use App\Models\Setting;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Pages\Page;
use Filament\Notifications\Notification;
use Illuminate\Support\Facades\Cache;

class ManageAppSettings extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-cog-6-tooth';

    protected static string $view = 'filament.pages.manage-app-settings';

    protected static ?string $navigationGroup = 'Settings';

    protected static ?string $navigationLabel = 'إعدادات التطبيق';

    protected static ?string $title = 'إعدادات التطبيق';

    protected static ?int $navigationSort = 1;

    public ?array $data = [];

    public function mount(): void
    {
        $this->form->fill($this->getSettingsArray());
    }

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Tabs::make('Settings')
                    ->tabs([
                        // Tab 1: معلومات التطبيق الأساسية
                        Forms\Components\Tabs\Tab::make('معلومات التطبيق')
                            ->icon('heroicon-o-device-phone-mobile')
                            ->schema([
                                Forms\Components\Section::make('المعلومات الأساسية')
                                    ->description('معلومات التطبيق الأساسية التي تظهر للمستخدمين')
                                    ->schema([
                                        Forms\Components\Grid::make(2)
                                            ->schema([
                                                Forms\Components\TextInput::make('app_name')
                                                    ->label('اسم التطبيق (عربي)')
                                                    ->required()
                                                    ->maxLength(255),

                                                Forms\Components\TextInput::make('app_name_en')
                                                    ->label('اسم التطبيق (English)')
                                                    ->required()
                                                    ->maxLength(255),

                                                Forms\Components\TextInput::make('app_version')
                                                    ->label('إصدار التطبيق')
                                                    ->required()
                                                    ->placeholder('1.0.0'),

                                                Forms\Components\TextInput::make('min_supported_version')
                                                    ->label('أقل إصدار مدعوم')
                                                    ->required()
                                                    ->placeholder('1.0.0'),

                                                Forms\Components\FileUpload::make('app_logo')
                                                    ->label('شعار التطبيق')
                                                    ->image()
                                                    ->directory('app-assets')
                                                    ->visibility('public')
                                                    ->columnSpanFull(),

                                                Forms\Components\TextInput::make('splash_screen_duration')
                                                    ->label('مدة شاشة البداية (ثواني)')
                                                    ->numeric()
                                                    ->default(3)
                                                    ->minValue(1)
                                                    ->maxValue(10),

                                                Forms\Components\Select::make('default_theme')
                                                    ->label('المظهر الافتراضي')
                                                    ->options([
                                                        'dark' => 'داكن',
                                                        'light' => 'فاتح',
                                                        'system' => 'حسب النظام',
                                                    ])
                                                    ->default('dark'),
                                            ]),
                                    ]),

                                Forms\Components\Section::make('الألوان والتصميم')
                                    ->description('ألوان العلامة التجارية للتطبيق')
                                    ->schema([
                                        Forms\Components\Grid::make(3)
                                            ->schema([
                                                Forms\Components\ColorPicker::make('primary_color')
                                                    ->label('اللون الأساسي')
                                                    ->default('#6366F1'),

                                                Forms\Components\ColorPicker::make('secondary_color')
                                                    ->label('اللون الثانوي')
                                                    ->default('#8B5CF6'),

                                                Forms\Components\ColorPicker::make('accent_color')
                                                    ->label('لون التمييز')
                                                    ->default('#10B981'),
                                            ]),
                                    ]),
                            ]),

                        // Tab 2: التحديثات والصيانة
                        Forms\Components\Tabs\Tab::make('التحديثات والصيانة')
                            ->icon('heroicon-o-arrow-path')
                            ->schema([
                                Forms\Components\Section::make('إدارة التحديثات')
                                    ->description('التحكم في تحديثات التطبيق')
                                    ->schema([
                                        Forms\Components\Toggle::make('force_update')
                                            ->label('إجبار المستخدمين على التحديث')
                                            ->helperText('عند التفعيل، سيُطلب من المستخدمين تحديث التطبيق')
                                            ->inline(false),

                                        Forms\Components\Toggle::make('enable_onboarding')
                                            ->label('تفعيل شاشات التعريف للمستخدمين الجدد')
                                            ->default(true)
                                            ->inline(false),
                                    ]),

                                Forms\Components\Section::make('وضع الصيانة')
                                    ->description('تفعيل وضع الصيانة للتطبيق')
                                    ->schema([
                                        Forms\Components\Toggle::make('maintenance_mode')
                                            ->label('تفعيل وضع الصيانة')
                                            ->helperText('عند التفعيل، لن يتمكن المستخدمون من استخدام التطبيق')
                                            ->reactive()
                                            ->inline(false),

                                        Forms\Components\Textarea::make('maintenance_message')
                                            ->label('رسالة الصيانة')
                                            ->rows(3)
                                            ->default('التطبيق تحت الصيانة حالياً. سنعود قريباً!')
                                            ->visible(fn ($get) => $get('maintenance_mode')),
                                    ]),
                            ]),

                        // Tab 3: الإعدادات العامة
                        Forms\Components\Tabs\Tab::make('إعدادات عامة')
                            ->icon('heroicon-o-globe-alt')
                            ->schema([
                                Forms\Components\Section::make('اللغة والعملة')
                                    ->schema([
                                        Forms\Components\Grid::make(2)
                                            ->schema([
                                                Forms\Components\Select::make('default_language')
                                                    ->label('اللغة الافتراضية')
                                                    ->options([
                                                        'ar' => 'العربية',
                                                        'en' => 'English',
                                                    ])
                                                    ->default('ar'),

                                                Forms\Components\Select::make('currency')
                                                    ->label('العملة')
                                                    ->options([
                                                        'AED' => 'درهم إماراتي (AED)',
                                                        'USD' => 'دولار أمريكي (USD)',
                                                        'EUR' => 'يورو (EUR)',
                                                        'GBP' => 'جنيه إسترليني (GBP)',
                                                        'SAR' => 'ريال سعودي (SAR)',
                                                    ])
                                                    ->default('AED'),

                                                Forms\Components\Toggle::make('rtl_enabled')
                                                    ->label('تفعيل الكتابة من اليمين لليسار (RTL)')
                                                    ->default(true)
                                                    ->inline(false),
                                            ]),
                                    ]),

                                Forms\Components\Section::make('معلومات الدعم والتواصل')
                                    ->schema([
                                        Forms\Components\Grid::make(2)
                                            ->schema([
                                                Forms\Components\TextInput::make('support_email')
                                                    ->label('البريد الإلكتروني للدعم')
                                                    ->email()
                                                    ->required(),

                                                Forms\Components\TextInput::make('support_phone')
                                                    ->label('رقم الهاتف للدعم')
                                                    ->tel()
                                                    ->required(),

                                                Forms\Components\TextInput::make('support_whatsapp')
                                                    ->label('رقم واتساب للدعم')
                                                    ->tel(),
                                            ]),
                                    ]),

                                Forms\Components\Section::make('الروابط القانونية')
                                    ->schema([
                                        Forms\Components\Grid::make(2)
                                            ->schema([
                                                Forms\Components\TextInput::make('terms_url')
                                                    ->label('رابط الشروط والأحكام')
                                                    ->url()
                                                    ->required(),

                                                Forms\Components\TextInput::make('privacy_url')
                                                    ->label('رابط سياسة الخصوصية')
                                                    ->url()
                                                    ->required(),

                                                Forms\Components\TextInput::make('help_center_url')
                                                    ->label('رابط مركز المساعدة')
                                                    ->url(),
                                            ]),
                                    ]),
                            ]),

                        // Tab 4: الميزات
                        Forms\Components\Tabs\Tab::make('الميزات')
                            ->icon('heroicon-o-sparkles')
                            ->schema([
                                Forms\Components\Section::make('تفعيل/تعطيل الميزات')
                                    ->description('التحكم في الميزات المتاحة في التطبيق')
                                    ->schema([
                                        Forms\Components\Grid::make(2)
                                            ->schema([
                                                Forms\Components\Toggle::make('payment_enabled')
                                                    ->label('تفعيل نظام الدفع')
                                                    ->default(true)
                                                    ->inline(false),

                                                Forms\Components\Toggle::make('ai_enabled')
                                                    ->label('تفعيل ميزات الذكاء الاصطناعي')
                                                    ->default(true)
                                                    ->inline(false),

                                                Forms\Components\Toggle::make('sms_enabled')
                                                    ->label('تفعيل خدمة الرسائل النصية')
                                                    ->default(true)
                                                    ->inline(false),

                                                Forms\Components\Toggle::make('firebase_enabled')
                                                    ->label('تفعيل Firebase')
                                                    ->default(false)
                                                    ->inline(false),

                                                Forms\Components\Toggle::make('analytics_enabled')
                                                    ->label('تفعيل التحليلات')
                                                    ->default(true)
                                                    ->inline(false),

                                                Forms\Components\Toggle::make('notifications_enabled')
                                                    ->label('تفعيل الإشعارات')
                                                    ->default(true)
                                                    ->inline(false),
                                            ]),
                                    ]),

                                Forms\Components\Section::make('إعدادات الذكاء الاصطناعي')
                                    ->schema([
                                        Forms\Components\Grid::make(2)
                                            ->schema([
                                                Forms\Components\Select::make('ai_default_model')
                                                    ->label('النموذج الافتراضي')
                                                    ->options([
                                                        'gpt-4' => 'GPT-4',
                                                        'gpt-3.5-turbo' => 'GPT-3.5 Turbo',
                                                        'gemini-pro' => 'Gemini Pro',
                                                        'claude-3' => 'Claude 3',
                                                    ])
                                                    ->default('gpt-4'),

                                                Forms\Components\TextInput::make('ai_max_tokens')
                                                    ->label('الحد الأقصى للتوكنز')
                                                    ->numeric()
                                                    ->default(2000)
                                                    ->minValue(100)
                                                    ->maxValue(10000),
                                            ]),
                                    ]),
                            ]),

                        // Tab 5: القيود والحدود
                        Forms\Components\Tabs\Tab::make('القيود والحدود')
                            ->icon('heroicon-o-shield-check')
                            ->schema([
                                Forms\Components\Section::make('حدود الرفع والاستخدام')
                                    ->schema([
                                        Forms\Components\Grid::make(2)
                                            ->schema([
                                                Forms\Components\TextInput::make('max_upload_size_mb')
                                                    ->label('الحد الأقصى لحجم الملف (MB)')
                                                    ->numeric()
                                                    ->default(50)
                                                    ->suffix('MB'),

                                                Forms\Components\TextInput::make('max_post_images')
                                                    ->label('الحد الأقصى لعدد الصور في المنشور')
                                                    ->numeric()
                                                    ->default(10),

                                                Forms\Components\TextInput::make('max_video_duration_seconds')
                                                    ->label('الحد الأقصى لمدة الفيديو (ثواني)')
                                                    ->numeric()
                                                    ->default(300)
                                                    ->suffix('ثانية'),

                                                Forms\Components\TextInput::make('rate_limit_per_minute')
                                                    ->label('عدد الطلبات المسموح بها في الدقيقة')
                                                    ->numeric()
                                                    ->default(60),
                                            ]),
                                    ]),
                            ]),

                        // Tab 6: وسائل التواصل الاجتماعي
                        Forms\Components\Tabs\Tab::make('وسائل التواصل')
                            ->icon('heroicon-o-share')
                            ->schema([
                                Forms\Components\Section::make('روابط وسائل التواصل الاجتماعي')
                                    ->description('أضف روابط حساباتك على وسائل التواصل')
                                    ->schema([
                                        Forms\Components\Grid::make(2)
                                            ->schema([
                                                Forms\Components\TextInput::make('facebook_page_url')
                                                    ->label('Facebook')
                                                    ->url()
                                                    ->prefix('https://'),

                                                Forms\Components\TextInput::make('instagram_url')
                                                    ->label('Instagram')
                                                    ->url()
                                                    ->prefix('https://'),

                                                Forms\Components\TextInput::make('twitter_url')
                                                    ->label('Twitter / X')
                                                    ->url()
                                                    ->prefix('https://'),

                                                Forms\Components\TextInput::make('linkedin_url')
                                                    ->label('LinkedIn')
                                                    ->url()
                                                    ->prefix('https://'),

                                                Forms\Components\TextInput::make('youtube_url')
                                                    ->label('YouTube')
                                                    ->url()
                                                    ->prefix('https://'),
                                            ]),
                                    ]),
                            ]),
                    ])
                    ->columnSpanFull(),
            ])
            ->statePath('data');
    }

    protected function getSettingsArray(): array
    {
        $settings = Setting::whereIn('key', [
            // App Info
            'app_name', 'app_name_en', 'app_version', 'min_supported_version',
            'app_logo', 'splash_screen_duration', 'default_theme',

            // Colors
            'primary_color', 'secondary_color', 'accent_color',

            // Updates & Maintenance
            'force_update', 'enable_onboarding', 'maintenance_mode', 'maintenance_message',

            // General
            'default_language', 'currency', 'rtl_enabled',
            'support_email', 'support_phone', 'support_whatsapp',
            'terms_url', 'privacy_url', 'help_center_url',

            // Features
            'payment_enabled', 'ai_enabled', 'sms_enabled', 'firebase_enabled',
            'analytics_enabled', 'notifications_enabled',
            'ai_default_model', 'ai_max_tokens',

            // Limits
            'max_upload_size_mb', 'max_post_images', 'max_video_duration_seconds', 'rate_limit_per_minute',

            // Social Media
            'facebook_page_url', 'instagram_url', 'twitter_url', 'linkedin_url', 'youtube_url',
        ])->get();

        $data = [];
        foreach ($settings as $setting) {
            $data[$setting->key] = $this->castValueForForm($setting->value, $setting->type);
        }

        return $data;
    }

    protected function castValueForForm($value, string $type)
    {
        return match($type) {
            'boolean' => filter_var($value, FILTER_VALIDATE_BOOLEAN),
            'integer' => (int) $value,
            'json' => is_string($value) ? json_decode($value, true) : $value,
            default => $value,
        };
    }

    public function save(): void
    {
        $data = $this->form->getState();

        foreach ($data as $key => $value) {
            $setting = Setting::where('key', $key)->first();

            if ($setting) {
                $setting->update([
                    'value' => $this->castValueForDatabase($value, $setting->type),
                ]);
            } else {
                Setting::create([
                    'key' => $key,
                    'value' => $value,
                    'type' => $this->detectType($value),
                    'group' => $this->detectGroup($key),
                    'is_public' => true,
                ]);
            }
        }

        // Clear cache
        Cache::forget('app_config');
        Cache::forget('public_settings');

        Notification::make()
            ->title('✅ تم الحفظ بنجاح')
            ->success()
            ->body('تم حفظ إعدادات التطبيق وتحديث البيانات')
            ->send();
    }

    protected function castValueForDatabase($value, string $type)
    {
        return match($type) {
            'boolean' => $value ? 1 : 0,
            'json' => is_array($value) ? json_encode($value) : $value,
            default => $value,
        };
    }

    protected function detectType($value): string
    {
        if (is_bool($value)) return 'boolean';
        if (is_int($value)) return 'integer';
        if (is_array($value)) return 'json';
        return 'string';
    }

    protected function detectGroup(string $key): string
    {
        if (str_contains($key, 'facebook') || str_contains($key, 'instagram') || str_contains($key, 'twitter') || str_contains($key, 'linkedin')) {
            return 'social';
        }
        if (str_contains($key, 'ai_')) {
            return 'ai';
        }
        if (str_contains($key, 'app_')) {
            return 'app';
        }
        return 'general';
    }

    protected function getFormActions(): array
    {
        return [
            Forms\Components\Actions\Action::make('save')
                ->label('حفظ الإعدادات')
                ->action('save')
                ->icon('heroicon-o-check')
                ->color('success'),
        ];
    }
}
