<?php

namespace App\Filament\Pages;

use App\Models\Setting;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Pages\Page;
use Filament\Notifications\Notification;

class AnalyticsManagement extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-chart-bar';

    protected static string $view = 'filament.pages.analytics-management';

    protected static ?string $navigationGroup = 'Settings';

    protected static ?string $navigationLabel = 'إدارة التحليلات';

    protected static ?string $title = 'إعدادات التحليلات والإحصائيات';

    protected static ?int $navigationSort = 4;

    public ?array $data = [];

    public function mount(): void
    {
        $this->form->fill($this->getSettingsData());
    }

    protected function getSettingsData(): array
    {
        $settings = Setting::whereIn('key', [
            // General Analytics Settings
            'analytics_enabled',
            'analytics_tracking_enabled',
            'analytics_data_retention_days',
            'analytics_realtime_enabled',
            'analytics_export_enabled',

            // Google Analytics
            'google_analytics_enabled',
            'google_analytics_tracking_id',
            'google_analytics_measurement_id',
            'google_analytics_api_secret',

            // Facebook Analytics
            'facebook_pixel_enabled',
            'facebook_pixel_id',
            'facebook_conversion_api_enabled',
            'facebook_conversion_api_token',

            // Firebase Analytics
            'firebase_analytics_enabled',
            'firebase_analytics_auto_log',
            'firebase_analytics_session_timeout',

            // Custom Analytics
            'custom_analytics_enabled',
            'custom_analytics_endpoint',
            'custom_analytics_api_key',

            // User Analytics
            'track_user_behavior',
            'track_user_location',
            'track_user_device',
            'track_user_sessions',

            // Content Analytics
            'track_post_views',
            'track_post_engagement',
            'track_post_shares',
            'track_content_performance',

            // Social Media Analytics
            'track_instagram_metrics',
            'track_facebook_metrics',
            'track_twitter_metrics',
            'track_tiktok_metrics',

            // Performance Metrics
            'track_app_performance',
            'track_api_calls',
            'track_load_times',
            'track_errors',

            // Reporting
            'enable_daily_reports',
            'enable_weekly_reports',
            'enable_monthly_reports',
            'report_email_recipients',

            // Privacy
            'anonymize_user_data',
            'gdpr_compliant',
            'ccpa_compliant',
            'data_sharing_enabled',
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
                Forms\Components\Tabs::make('Analytics Settings')
                    ->tabs([
                        // General Settings Tab
                        Forms\Components\Tabs\Tab::make('إعدادات عامة')
                            ->icon('heroicon-o-cog-6-tooth')
                            ->schema([
                                Forms\Components\Section::make('التفعيل الأساسي')
                                    ->schema([
                                        Forms\Components\Toggle::make('analytics_enabled')
                                            ->label('تفعيل التحليلات')
                                            ->helperText('تفعيل نظام التحليلات بالكامل')
                                            ->default(true)
                                            ->live(),

                                        Forms\Components\Toggle::make('analytics_tracking_enabled')
                                            ->label('تتبع النشاط')
                                            ->helperText('تتبع نشاط المستخدمين في الوقت الفعلي')
                                            ->default(true)
                                            ->visible(fn ($get) => $get('analytics_enabled')),

                                        Forms\Components\Toggle::make('analytics_realtime_enabled')
                                            ->label('التحليلات الفورية')
                                            ->helperText('عرض البيانات في الوقت الفعلي')
                                            ->default(true)
                                            ->visible(fn ($get) => $get('analytics_enabled')),

                                        Forms\Components\Toggle::make('analytics_export_enabled')
                                            ->label('السماح بتصدير البيانات')
                                            ->helperText('السماح بتصدير التقارير والبيانات')
                                            ->default(true)
                                            ->visible(fn ($get) => $get('analytics_enabled')),
                                    ])->columns(2),

                                Forms\Components\Section::make('الاحتفاظ بالبيانات')
                                    ->schema([
                                        Forms\Components\TextInput::make('analytics_data_retention_days')
                                            ->label('مدة الاحتفاظ بالبيانات (يوم)')
                                            ->helperText('عدد الأيام للاحتفاظ ببيانات التحليلات')
                                            ->numeric()
                                            ->default(90)
                                            ->minValue(30)
                                            ->maxValue(365)
                                            ->suffix('يوم'),
                                    ]),
                            ]),

                        // Google Analytics Tab
                        Forms\Components\Tabs\Tab::make('Google Analytics')
                            ->icon('heroicon-o-globe-alt')
                            ->schema([
                                Forms\Components\Section::make('إعدادات Google Analytics')
                                    ->schema([
                                        Forms\Components\Toggle::make('google_analytics_enabled')
                                            ->label('تفعيل Google Analytics')
                                            ->default(false)
                                            ->live(),

                                        Forms\Components\TextInput::make('google_analytics_tracking_id')
                                            ->label('Tracking ID (UA-XXXXX-X)')
                                            ->placeholder('UA-000000-0')
                                            ->visible(fn ($get) => $get('google_analytics_enabled')),

                                        Forms\Components\TextInput::make('google_analytics_measurement_id')
                                            ->label('Measurement ID (G-XXXXX)')
                                            ->placeholder('G-XXXXXXXXXX')
                                            ->helperText('GA4 Measurement ID')
                                            ->visible(fn ($get) => $get('google_analytics_enabled')),

                                        Forms\Components\TextInput::make('google_analytics_api_secret')
                                            ->label('API Secret')
                                            ->placeholder('API Secret Key')
                                            ->password()
                                            ->revealable()
                                            ->maxLength(255)
                                            ->visible(fn ($get) => $get('google_analytics_enabled')),

                                        Forms\Components\Placeholder::make('google_analytics_help')
                                            ->label('كيفية الحصول على المعلومات')
                                            ->content('1. اذهب إلى https://analytics.google.com
2. Admin → Data Streams
3. انسخ Measurement ID و API Secret')
                                            ->visible(fn ($get) => $get('google_analytics_enabled')),
                                    ])->columns(2),
                            ]),

                        // Facebook Analytics Tab
                        Forms\Components\Tabs\Tab::make('Facebook Pixel')
                            ->icon('heroicon-o-globe-alt')
                            ->schema([
                                Forms\Components\Section::make('إعدادات Facebook Pixel')
                                    ->schema([
                                        Forms\Components\Toggle::make('facebook_pixel_enabled')
                                            ->label('تفعيل Facebook Pixel')
                                            ->default(false)
                                            ->live(),

                                        Forms\Components\TextInput::make('facebook_pixel_id')
                                            ->label('Pixel ID')
                                            ->placeholder('123456789012345')
                                            ->visible(fn ($get) => $get('facebook_pixel_enabled')),

                                        Forms\Components\Toggle::make('facebook_conversion_api_enabled')
                                            ->label('تفعيل Conversion API')
                                            ->helperText('لتتبع أفضل وبيانات أدق')
                                            ->default(false)
                                            ->visible(fn ($get) => $get('facebook_pixel_enabled'))
                                            ->live(),

                                        Forms\Components\TextInput::make('facebook_conversion_api_token')
                                            ->label('Conversion API Access Token')
                                            ->password()
                                            ->revealable()
                                            ->maxLength(255)
                                            ->visible(fn ($get) => $get('facebook_pixel_enabled') && $get('facebook_conversion_api_enabled')),

                                        Forms\Components\Placeholder::make('facebook_pixel_help')
                                            ->label('كيفية الحصول على Pixel ID')
                                            ->content('1. اذهب إلى https://business.facebook.com
2. Events Manager → Pixels
3. انسخ Pixel ID')
                                            ->visible(fn ($get) => $get('facebook_pixel_enabled')),
                                    ])->columns(2),
                            ]),

                        // Firebase Analytics Tab
                        Forms\Components\Tabs\Tab::make('Firebase Analytics')
                            ->icon('heroicon-o-fire')
                            ->schema([
                                Forms\Components\Section::make('إعدادات Firebase Analytics')
                                    ->schema([
                                        Forms\Components\Toggle::make('firebase_analytics_enabled')
                                            ->label('تفعيل Firebase Analytics')
                                            ->default(true)
                                            ->live(),

                                        Forms\Components\Toggle::make('firebase_analytics_auto_log')
                                            ->label('تسجيل الأحداث تلقائياً')
                                            ->helperText('تسجيل الشاشات والأحداث الأساسية تلقائياً')
                                            ->default(true)
                                            ->visible(fn ($get) => $get('firebase_analytics_enabled')),

                                        Forms\Components\TextInput::make('firebase_analytics_session_timeout')
                                            ->label('مهلة الجلسة (دقيقة)')
                                            ->numeric()
                                            ->default(30)
                                            ->minValue(1)
                                            ->maxValue(120)
                                            ->suffix('دقيقة')
                                            ->visible(fn ($get) => $get('firebase_analytics_enabled')),
                                    ])->columns(2),
                            ]),

                        // Tracking Options Tab
                        Forms\Components\Tabs\Tab::make('خيارات التتبع')
                            ->icon('heroicon-o-eye')
                            ->schema([
                                Forms\Components\Section::make('تتبع المستخدمين')
                                    ->schema([
                                        Forms\Components\Toggle::make('track_user_behavior')
                                            ->label('تتبع سلوك المستخدم')
                                            ->helperText('الصفحات، الأزرار، التفاعلات')
                                            ->default(true),

                                        Forms\Components\Toggle::make('track_user_location')
                                            ->label('تتبع الموقع الجغرافي')
                                            ->helperText('الدولة، المدينة')
                                            ->default(true),

                                        Forms\Components\Toggle::make('track_user_device')
                                            ->label('تتبع معلومات الجهاز')
                                            ->helperText('نوع الجهاز، نظام التشغيل، الإصدار')
                                            ->default(true),

                                        Forms\Components\Toggle::make('track_user_sessions')
                                            ->label('تتبع الجلسات')
                                            ->helperText('مدة الجلسة، عدد الشاشات')
                                            ->default(true),
                                    ])->columns(2),

                                Forms\Components\Section::make('تتبع المحتوى')
                                    ->schema([
                                        Forms\Components\Toggle::make('track_post_views')
                                            ->label('تتبع مشاهدات المنشورات')
                                            ->default(true),

                                        Forms\Components\Toggle::make('track_post_engagement')
                                            ->label('تتبع التفاعل (Likes, Comments)')
                                            ->default(true),

                                        Forms\Components\Toggle::make('track_post_shares')
                                            ->label('تتبع المشاركات')
                                            ->default(true),

                                        Forms\Components\Toggle::make('track_content_performance')
                                            ->label('تتبع أداء المحتوى')
                                            ->helperText('Reach, Impressions, Engagement Rate')
                                            ->default(true),
                                    ])->columns(2),

                                Forms\Components\Section::make('تتبع السوشال ميديا')
                                    ->schema([
                                        Forms\Components\Toggle::make('track_instagram_metrics')
                                            ->label('تتبع إحصائيات Instagram')
                                            ->default(true),

                                        Forms\Components\Toggle::make('track_facebook_metrics')
                                            ->label('تتبع إحصائيات Facebook')
                                            ->default(true),

                                        Forms\Components\Toggle::make('track_twitter_metrics')
                                            ->label('تتبع إحصائيات Twitter')
                                            ->default(true),

                                        Forms\Components\Toggle::make('track_tiktok_metrics')
                                            ->label('تتبع إحصائيات TikTok')
                                            ->default(true),
                                    ])->columns(2),
                            ]),

                        // Performance Metrics Tab
                        Forms\Components\Tabs\Tab::make('مقاييس الأداء')
                            ->icon('heroicon-o-bolt')
                            ->schema([
                                Forms\Components\Section::make('تتبع الأداء')
                                    ->schema([
                                        Forms\Components\Toggle::make('track_app_performance')
                                            ->label('تتبع أداء التطبيق')
                                            ->helperText('FPS, Memory Usage, CPU Usage')
                                            ->default(true),

                                        Forms\Components\Toggle::make('track_api_calls')
                                            ->label('تتبع استدعاءات API')
                                            ->helperText('عدد الطلبات، وقت الاستجابة')
                                            ->default(true),

                                        Forms\Components\Toggle::make('track_load_times')
                                            ->label('تتبع أوقات التحميل')
                                            ->helperText('وقت تحميل الشاشات والبيانات')
                                            ->default(true),

                                        Forms\Components\Toggle::make('track_errors')
                                            ->label('تتبع الأخطاء')
                                            ->helperText('Crashes, Exceptions, Errors')
                                            ->default(true),
                                    ])->columns(2),
                            ]),

                        // Reports Tab
                        Forms\Components\Tabs\Tab::make('التقارير')
                            ->icon('heroicon-o-document-text')
                            ->schema([
                                Forms\Components\Section::make('التقارير الدورية')
                                    ->schema([
                                        Forms\Components\Toggle::make('enable_daily_reports')
                                            ->label('تقارير يومية')
                                            ->helperText('إرسال تقرير يومي بالإحصائيات')
                                            ->default(false),

                                        Forms\Components\Toggle::make('enable_weekly_reports')
                                            ->label('تقارير أسبوعية')
                                            ->default(true),

                                        Forms\Components\Toggle::make('enable_monthly_reports')
                                            ->label('تقارير شهرية')
                                            ->default(true),

                                        Forms\Components\TagsInput::make('report_email_recipients')
                                            ->label('المستلمون (Emails)')
                                            ->placeholder('أضف بريد إلكتروني')
                                            ->helperText('قائمة البريد الإلكتروني لإرسال التقارير')
                                            ->columnSpanFull(),
                                    ])->columns(2),
                            ]),

                        // Privacy Tab
                        Forms\Components\Tabs\Tab::make('الخصوصية')
                            ->icon('heroicon-o-shield-check')
                            ->schema([
                                Forms\Components\Section::make('إعدادات الخصوصية')
                                    ->schema([
                                        Forms\Components\Toggle::make('anonymize_user_data')
                                            ->label('إخفاء هوية المستخدمين')
                                            ->helperText('إخفاء البيانات الشخصية في التحليلات')
                                            ->default(true),

                                        Forms\Components\Toggle::make('gdpr_compliant')
                                            ->label('الامتثال لـ GDPR')
                                            ->helperText('الالتزام بقوانين حماية البيانات الأوروبية')
                                            ->default(true),

                                        Forms\Components\Toggle::make('ccpa_compliant')
                                            ->label('الامتثال لـ CCPA')
                                            ->helperText('الالتزام بقوانين خصوصية كاليفورنيا')
                                            ->default(true),

                                        Forms\Components\Toggle::make('data_sharing_enabled')
                                            ->label('السماح بمشاركة البيانات')
                                            ->helperText('مشاركة البيانات مع خدمات التحليلات الخارجية')
                                            ->default(false),
                                    ])->columns(2),

                                Forms\Components\Placeholder::make('privacy_note')
                                    ->label('⚠️ ملاحظة مهمة')
                                    ->content('تأكد من الامتثال لقوانين الخصوصية في منطقتك وإبلاغ المستخدمين بجمع البيانات في سياسة الخصوصية.')
                                    ->columnSpanFull(),
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
                    'group' => 'analytics',
                    'is_public' => in_array($key, [
                        'analytics_enabled',
                        'google_analytics_enabled',
                        'facebook_pixel_enabled',
                        'firebase_analytics_enabled',
                        // Public keys only
                        'google_analytics_measurement_id',
                        'facebook_pixel_id',
                    ]),
                ]
            );
        }

        // Clear cache
        \Cache::forget('app_config');
        \Cache::forget('analytics_settings');

        Notification::make()
            ->title('تم الحفظ بنجاح')
            ->success()
            ->body('تم حفظ إعدادات التحليلات بنجاح')
            ->send();
    }
}
