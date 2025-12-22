<?php

namespace App\Filament\Pages;

use App\Models\Setting;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Pages\Page;
use Filament\Notifications\Notification;

class SocialMediaAccounts extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-share';

    protected static string $view = 'filament.pages.social-media-accounts';

    protected static ?string $navigationGroup = 'Settings';

    protected static ?string $navigationLabel = 'حسابات السوشال ميديا';

    protected static ?string $title = 'ربط حسابات السوشال ميديا';

    protected static ?int $navigationSort = 3;

    public ?array $data = [];

    public function mount(): void
    {
        $this->form->fill($this->getSettingsData());
    }

    protected function getSettingsData(): array
    {
        $settings = Setting::whereIn('key', [
            // Facebook
            'facebook_app_id',
            'facebook_app_secret',
            'facebook_access_token',
            'facebook_page_id',
            'facebook_enabled',

            // Instagram
            'instagram_app_id',
            'instagram_app_secret',
            'instagram_access_token',
            'instagram_user_id',
            'instagram_enabled',

            // Twitter/X
            'twitter_api_key',
            'twitter_api_secret',
            'twitter_access_token',
            'twitter_access_secret',
            'twitter_bearer_token',
            'twitter_enabled',

            // LinkedIn
            'linkedin_client_id',
            'linkedin_client_secret',
            'linkedin_access_token',
            'linkedin_organization_id',
            'linkedin_enabled',

            // TikTok
            'tiktok_client_key',
            'tiktok_client_secret',
            'tiktok_access_token',
            'tiktok_enabled',

            // YouTube
            'youtube_client_id',
            'youtube_client_secret',
            'youtube_access_token',
            'youtube_refresh_token',
            'youtube_channel_id',
            'youtube_enabled',

            // Pinterest
            'pinterest_app_id',
            'pinterest_app_secret',
            'pinterest_access_token',
            'pinterest_enabled',

            // Telegram
            'telegram_bot_token',
            'telegram_chat_id',
            'telegram_enabled',
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
                Forms\Components\Tabs::make('Social Media Platforms')
                    ->tabs([
                        // Facebook Tab
                        Forms\Components\Tabs\Tab::make('Facebook')
                            ->icon('heroicon-o-globe-alt')
                            ->schema([
                                Forms\Components\Section::make('إعدادات Facebook')
                                    ->description('قم بربط حساب Facebook الخاص بك')
                                    ->schema([
                                        Forms\Components\Toggle::make('facebook_enabled')
                                            ->label('تفعيل Facebook')
                                            ->default(false)
                                            ->live(),

                                        Forms\Components\TextInput::make('facebook_app_id')
                                            ->label('Facebook App ID')
                                            ->placeholder('123456789012345')
                                            ->required(fn ($get) => $get('facebook_enabled'))
                                            ->visible(fn ($get) => $get('facebook_enabled')),

                                        Forms\Components\TextInput::make('facebook_app_secret')
                                            ->label('Facebook App Secret')
                                            ->password()
                                            ->revealable()
                                            ->placeholder('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
                                            ->required(fn ($get) => $get('facebook_enabled'))
                                            ->visible(fn ($get) => $get('facebook_enabled')),

                                        Forms\Components\Textarea::make('facebook_access_token')
                                            ->label('Facebook Access Token')
                                            ->placeholder('EAAxxxxxxxxxxxxxxxxxxxxx')
                                            ->rows(3)
                                            ->visible(fn ($get) => $get('facebook_enabled')),

                                        Forms\Components\TextInput::make('facebook_page_id')
                                            ->label('Facebook Page ID')
                                            ->placeholder('109876543210987')
                                            ->visible(fn ($get) => $get('facebook_enabled')),

                                        Forms\Components\Placeholder::make('facebook_help')
                                            ->label('كيفية الحصول على المفاتيح')
                                            ->content('1. اذهب إلى https://developers.facebook.com
2. أنشئ تطبيق جديد
3. انسخ App ID و App Secret
4. قم بتوليد Access Token من Graph API Explorer')
                                            ->visible(fn ($get) => $get('facebook_enabled')),
                                    ])->columns(2),
                            ]),

                        // Instagram Tab
                        Forms\Components\Tabs\Tab::make('Instagram')
                            ->icon('heroicon-o-camera')
                            ->schema([
                                Forms\Components\Section::make('إعدادات Instagram')
                                    ->description('قم بربط حساب Instagram Business الخاص بك')
                                    ->schema([
                                        Forms\Components\Toggle::make('instagram_enabled')
                                            ->label('تفعيل Instagram')
                                            ->default(false)
                                            ->live(),

                                        Forms\Components\TextInput::make('instagram_app_id')
                                            ->label('Instagram App ID')
                                            ->required(fn ($get) => $get('instagram_enabled'))
                                            ->visible(fn ($get) => $get('instagram_enabled')),

                                        Forms\Components\TextInput::make('instagram_app_secret')
                                            ->label('Instagram App Secret')
                                            ->password()
                                            ->revealable()
                                            ->required(fn ($get) => $get('instagram_enabled'))
                                            ->visible(fn ($get) => $get('instagram_enabled')),

                                        Forms\Components\Textarea::make('instagram_access_token')
                                            ->label('Instagram Access Token')
                                            ->rows(3)
                                            ->visible(fn ($get) => $get('instagram_enabled')),

                                        Forms\Components\TextInput::make('instagram_user_id')
                                            ->label('Instagram User ID')
                                            ->visible(fn ($get) => $get('instagram_enabled')),

                                        Forms\Components\Placeholder::make('instagram_help')
                                            ->label('ملاحظة')
                                            ->content('يتطلب Instagram حساب Business أو Creator متصل بصفحة Facebook')
                                            ->visible(fn ($get) => $get('instagram_enabled')),
                                    ])->columns(2),
                            ]),

                        // Twitter/X Tab
                        Forms\Components\Tabs\Tab::make('Twitter / X')
                            ->icon('heroicon-o-chat-bubble-left-right')
                            ->schema([
                                Forms\Components\Section::make('إعدادات Twitter (X)')
                                    ->description('قم بربط حساب Twitter/X الخاص بك')
                                    ->schema([
                                        Forms\Components\Toggle::make('twitter_enabled')
                                            ->label('تفعيل Twitter/X')
                                            ->default(false)
                                            ->live(),

                                        Forms\Components\TextInput::make('twitter_api_key')
                                            ->label('Twitter API Key')
                                            ->required(fn ($get) => $get('twitter_enabled'))
                                            ->visible(fn ($get) => $get('twitter_enabled')),

                                        Forms\Components\TextInput::make('twitter_api_secret')
                                            ->label('Twitter API Secret')
                                            ->password()
                                            ->revealable()
                                            ->required(fn ($get) => $get('twitter_enabled'))
                                            ->visible(fn ($get) => $get('twitter_enabled')),

                                        Forms\Components\Textarea::make('twitter_access_token')
                                            ->label('Access Token')
                                            ->rows(2)
                                            ->visible(fn ($get) => $get('twitter_enabled')),

                                        Forms\Components\Textarea::make('twitter_access_secret')
                                            ->label('Access Token Secret')
                                            ->rows(2)
                                            ->visible(fn ($get) => $get('twitter_enabled')),

                                        Forms\Components\Textarea::make('twitter_bearer_token')
                                            ->label('Bearer Token')
                                            ->rows(2)
                                            ->visible(fn ($get) => $get('twitter_enabled')),

                                        Forms\Components\Placeholder::make('twitter_help')
                                            ->label('كيفية الحصول على المفاتيح')
                                            ->content('1. اذهب إلى https://developer.twitter.com
2. أنشئ مشروع وتطبيق جديد
3. انسخ API Key و API Secret
4. قم بتوليد Access Token و Bearer Token')
                                            ->visible(fn ($get) => $get('twitter_enabled')),
                                    ])->columns(2),
                            ]),

                        // LinkedIn Tab
                        Forms\Components\Tabs\Tab::make('LinkedIn')
                            ->icon('heroicon-o-briefcase')
                            ->schema([
                                Forms\Components\Section::make('إعدادات LinkedIn')
                                    ->description('قم بربط صفحة LinkedIn الخاصة بشركتك')
                                    ->schema([
                                        Forms\Components\Toggle::make('linkedin_enabled')
                                            ->label('تفعيل LinkedIn')
                                            ->default(false)
                                            ->live(),

                                        Forms\Components\TextInput::make('linkedin_client_id')
                                            ->label('LinkedIn Client ID')
                                            ->required(fn ($get) => $get('linkedin_enabled'))
                                            ->visible(fn ($get) => $get('linkedin_enabled')),

                                        Forms\Components\TextInput::make('linkedin_client_secret')
                                            ->label('LinkedIn Client Secret')
                                            ->password()
                                            ->revealable()
                                            ->required(fn ($get) => $get('linkedin_enabled'))
                                            ->visible(fn ($get) => $get('linkedin_enabled')),

                                        Forms\Components\Textarea::make('linkedin_access_token')
                                            ->label('Access Token')
                                            ->rows(3)
                                            ->visible(fn ($get) => $get('linkedin_enabled')),

                                        Forms\Components\TextInput::make('linkedin_organization_id')
                                            ->label('Organization ID')
                                            ->placeholder('12345678')
                                            ->helperText('معرف صفحة الشركة على LinkedIn')
                                            ->visible(fn ($get) => $get('linkedin_enabled')),

                                        Forms\Components\Placeholder::make('linkedin_help')
                                            ->label('كيفية الحصول على المفاتيح')
                                            ->content('1. اذهب إلى https://www.linkedin.com/developers
2. أنشئ تطبيق جديد
3. انسخ Client ID و Client Secret
4. أضف OAuth 2.0 Redirect URLs')
                                            ->visible(fn ($get) => $get('linkedin_enabled')),
                                    ])->columns(2),
                            ]),

                        // TikTok Tab
                        Forms\Components\Tabs\Tab::make('TikTok')
                            ->icon('heroicon-o-musical-note')
                            ->schema([
                                Forms\Components\Section::make('إعدادات TikTok')
                                    ->description('قم بربط حساب TikTok Business الخاص بك')
                                    ->schema([
                                        Forms\Components\Toggle::make('tiktok_enabled')
                                            ->label('تفعيل TikTok')
                                            ->default(false)
                                            ->live(),

                                        Forms\Components\TextInput::make('tiktok_client_key')
                                            ->label('TikTok Client Key')
                                            ->required(fn ($get) => $get('tiktok_enabled'))
                                            ->visible(fn ($get) => $get('tiktok_enabled')),

                                        Forms\Components\TextInput::make('tiktok_client_secret')
                                            ->label('TikTok Client Secret')
                                            ->password()
                                            ->revealable()
                                            ->required(fn ($get) => $get('tiktok_enabled'))
                                            ->visible(fn ($get) => $get('tiktok_enabled')),

                                        Forms\Components\Textarea::make('tiktok_access_token')
                                            ->label('Access Token')
                                            ->rows(3)
                                            ->visible(fn ($get) => $get('tiktok_enabled')),

                                        Forms\Components\Placeholder::make('tiktok_help')
                                            ->label('كيفية الحصول على المفاتيح')
                                            ->content('1. اذهب إلى https://developers.tiktok.com
2. أنشئ تطبيق جديد
3. انسخ Client Key و Client Secret
4. استخدم OAuth للحصول على Access Token')
                                            ->visible(fn ($get) => $get('tiktok_enabled')),
                                    ])->columns(2),
                            ]),

                        // YouTube Tab
                        Forms\Components\Tabs\Tab::make('YouTube')
                            ->icon('heroicon-o-video-camera')
                            ->schema([
                                Forms\Components\Section::make('إعدادات YouTube')
                                    ->description('قم بربط قناة YouTube الخاصة بك')
                                    ->schema([
                                        Forms\Components\Toggle::make('youtube_enabled')
                                            ->label('تفعيل YouTube')
                                            ->default(false)
                                            ->live(),

                                        Forms\Components\TextInput::make('youtube_client_id')
                                            ->label('YouTube Client ID')
                                            ->required(fn ($get) => $get('youtube_enabled'))
                                            ->visible(fn ($get) => $get('youtube_enabled')),

                                        Forms\Components\TextInput::make('youtube_client_secret')
                                            ->label('YouTube Client Secret')
                                            ->password()
                                            ->revealable()
                                            ->required(fn ($get) => $get('youtube_enabled'))
                                            ->visible(fn ($get) => $get('youtube_enabled')),

                                        Forms\Components\Textarea::make('youtube_access_token')
                                            ->label('Access Token')
                                            ->rows(2)
                                            ->visible(fn ($get) => $get('youtube_enabled')),

                                        Forms\Components\Textarea::make('youtube_refresh_token')
                                            ->label('Refresh Token')
                                            ->rows(2)
                                            ->visible(fn ($get) => $get('youtube_enabled')),

                                        Forms\Components\TextInput::make('youtube_channel_id')
                                            ->label('Channel ID')
                                            ->placeholder('UCxxxxxxxxxxxxxxxxxxxxxxx')
                                            ->visible(fn ($get) => $get('youtube_enabled')),

                                        Forms\Components\Placeholder::make('youtube_help')
                                            ->label('كيفية الحصول على المفاتيح')
                                            ->content('1. اذهب إلى https://console.cloud.google.com
2. أنشئ مشروع جديد
3. فعّل YouTube Data API v3
4. أنشئ OAuth 2.0 Client ID
5. انسخ Client ID و Client Secret')
                                            ->visible(fn ($get) => $get('youtube_enabled')),
                                    ])->columns(2),
                            ]),

                        // Pinterest Tab
                        Forms\Components\Tabs\Tab::make('Pinterest')
                            ->icon('heroicon-o-photo')
                            ->schema([
                                Forms\Components\Section::make('إعدادات Pinterest')
                                    ->description('قم بربط حساب Pinterest Business الخاص بك')
                                    ->schema([
                                        Forms\Components\Toggle::make('pinterest_enabled')
                                            ->label('تفعيل Pinterest')
                                            ->default(false)
                                            ->live(),

                                        Forms\Components\TextInput::make('pinterest_app_id')
                                            ->label('Pinterest App ID')
                                            ->required(fn ($get) => $get('pinterest_enabled'))
                                            ->visible(fn ($get) => $get('pinterest_enabled')),

                                        Forms\Components\TextInput::make('pinterest_app_secret')
                                            ->label('Pinterest App Secret')
                                            ->password()
                                            ->revealable()
                                            ->required(fn ($get) => $get('pinterest_enabled'))
                                            ->visible(fn ($get) => $get('pinterest_enabled')),

                                        Forms\Components\Textarea::make('pinterest_access_token')
                                            ->label('Access Token')
                                            ->rows(3)
                                            ->visible(fn ($get) => $get('pinterest_enabled')),

                                        Forms\Components\Placeholder::make('pinterest_help')
                                            ->label('كيفية الحصول على المفاتيح')
                                            ->content('1. اذهب إلى https://developers.pinterest.com
2. أنشئ تطبيق جديد
3. انسخ App ID و App Secret
4. قم بتوليد Access Token')
                                            ->visible(fn ($get) => $get('pinterest_enabled')),
                                    ])->columns(2),
                            ]),

                        // Telegram Tab
                        Forms\Components\Tabs\Tab::make('Telegram')
                            ->icon('heroicon-o-paper-airplane')
                            ->schema([
                                Forms\Components\Section::make('إعدادات Telegram')
                                    ->description('قم بربط قناة أو مجموعة Telegram')
                                    ->schema([
                                        Forms\Components\Toggle::make('telegram_enabled')
                                            ->label('تفعيل Telegram')
                                            ->default(false)
                                            ->live(),

                                        Forms\Components\TextInput::make('telegram_bot_token')
                                            ->label('Telegram Bot Token')
                                            ->placeholder('123456789:ABCdefGHIjklMNOpqrsTUVwxyz')
                                            ->required(fn ($get) => $get('telegram_enabled'))
                                            ->visible(fn ($get) => $get('telegram_enabled')),

                                        Forms\Components\TextInput::make('telegram_chat_id')
                                            ->label('Chat ID / Channel ID')
                                            ->placeholder('@channel_name أو -100123456789')
                                            ->helperText('معرف القناة أو المجموعة')
                                            ->visible(fn ($get) => $get('telegram_enabled')),

                                        Forms\Components\Placeholder::make('telegram_help')
                                            ->label('كيفية الحصول على Bot Token')
                                            ->content('1. افتح Telegram وابحث عن @BotFather
2. أرسل /newbot واتبع التعليمات
3. انسخ Bot Token
4. أضف البوت إلى قناتك وامنحه صلاحيات النشر')
                                            ->visible(fn ($get) => $get('telegram_enabled')),
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
                    'type' => is_bool($value) ? 'boolean' : (is_numeric($value) ? 'number' : 'string'),
                    'group' => 'social_media',
                    'is_public' => false, // Social media credentials should be private
                ]
            );
        }

        Notification::make()
            ->title('تم الحفظ بنجاح')
            ->success()
            ->body('تم حفظ إعدادات حسابات السوشال ميديا بنجاح')
            ->send();
    }
}
