<?php

namespace App\Filament\Pages;

use App\Models\Setting;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Pages\Page;
use Filament\Notifications\Notification;

class AppSettings extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-cog-6-tooth';

    protected static string $view = 'filament.pages.app-settings';

    protected static ?string $navigationGroup = 'النظام';

    protected static ?string $navigationLabel = 'إعدادات التطبيق';

    protected static ?string $title = 'إعدادات التطبيق';

    public ?array $data = [];

    public function mount(): void
    {
        $settings = Setting::getAllSettings();
        $this->form->fill($settings);
    }

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Tabs::make('الإعدادات')
                    ->tabs([
                        Forms\Components\Tabs\Tab::make('عام')
                            ->icon('heroicon-o-information-circle')
                            ->schema([
                                Forms\Components\TextInput::make('app_name')
                                    ->label('اسم التطبيق')
                                    ->required()
                                    ->maxLength(255),

                                Forms\Components\Textarea::make('app_description')
                                    ->label('وصف التطبيق')
                                    ->rows(3)
                                    ->maxLength(500),

                                Forms\Components\TextInput::make('app_url')
                                    ->label('رابط التطبيق')
                                    ->url()
                                    ->required(),

                                Forms\Components\FileUpload::make('app_logo')
                                    ->label('شعار التطبيق')
                                    ->image()
                                    ->directory('settings')
                                    ->maxSize(2048),

                                Forms\Components\TextInput::make('admin_email')
                                    ->label('بريد المدير')
                                    ->email()
                                    ->required(),

                                Forms\Components\TextInput::make('support_email')
                                    ->label('بريد الدعم الفني')
                                    ->email()
                                    ->required(),
                            ])->columns(2),

                        Forms\Components\Tabs\Tab::make('Stripe')
                            ->icon('heroicon-o-credit-card')
                            ->schema([
                                Forms\Components\Toggle::make('stripe_enabled')
                                    ->label('تفعيل Stripe')
                                    ->default(true)
                                    ->live(),

                                Forms\Components\TextInput::make('stripe_publishable_key')
                                    ->label('Stripe Publishable Key')
                                    ->required(fn (Forms\Get $get) => $get('stripe_enabled'))
                                    ->maxLength(255)
                                    ->password()
                                    ->revealable(),

                                Forms\Components\TextInput::make('stripe_secret_key')
                                    ->label('Stripe Secret Key')
                                    ->required(fn (Forms\Get $get) => $get('stripe_enabled'))
                                    ->maxLength(255)
                                    ->password()
                                    ->revealable(),

                                Forms\Components\TextInput::make('stripe_webhook_secret')
                                    ->label('Stripe Webhook Secret')
                                    ->maxLength(255)
                                    ->password()
                                    ->revealable(),
                            ])->columns(2),

                        Forms\Components\Tabs\Tab::make('PayPal')
                            ->icon('heroicon-o-currency-dollar')
                            ->schema([
                                Forms\Components\Toggle::make('paypal_enabled')
                                    ->label('تفعيل PayPal')
                                    ->default(true)
                                    ->live(),

                                Forms\Components\TextInput::make('paypal_client_id')
                                    ->label('PayPal Client ID')
                                    ->required(fn (Forms\Get $get) => $get('paypal_enabled'))
                                    ->maxLength(255)
                                    ->password()
                                    ->revealable(),

                                Forms\Components\TextInput::make('paypal_secret')
                                    ->label('PayPal Secret')
                                    ->required(fn (Forms\Get $get) => $get('paypal_enabled'))
                                    ->maxLength(255)
                                    ->password()
                                    ->revealable(),

                                Forms\Components\Select::make('paypal_mode')
                                    ->label('وضع PayPal')
                                    ->options([
                                        'sandbox' => 'اختبار (Sandbox)',
                                        'live' => 'مباشر (Live)',
                                    ])
                                    ->default('sandbox')
                                    ->required(fn (Forms\Get $get) => $get('paypal_enabled')),
                            ])->columns(2),

                        Forms\Components\Tabs\Tab::make('Paymob')
                            ->icon('heroicon-o-banknotes')
                            ->schema([
                                Forms\Components\Toggle::make('paymob_enabled')
                                    ->label('تفعيل Paymob')
                                    ->default(false)
                                    ->live()
                                    ->helperText('بوابة الدفع المصرية للدول العربية'),

                                Forms\Components\TextInput::make('paymob_api_key')
                                    ->label('Paymob API Key')
                                    ->required(fn (Forms\Get $get) => $get('paymob_enabled'))
                                    ->maxLength(255)
                                    ->password()
                                    ->revealable()
                                    ->helperText('مفتاح API من لوحة تحكم Paymob'),

                                Forms\Components\TextInput::make('paymob_iframe_id')
                                    ->label('Paymob iFrame ID')
                                    ->required(fn (Forms\Get $get) => $get('paymob_enabled'))
                                    ->numeric()
                                    ->helperText('معرف صفحة الدفع'),

                                Forms\Components\TextInput::make('paymob_integration_id')
                                    ->label('Paymob Integration ID')
                                    ->required(fn (Forms\Get $get) => $get('paymob_enabled'))
                                    ->numeric()
                                    ->helperText('معرف التكامل من Paymob'),

                                Forms\Components\TextInput::make('paymob_hmac_secret')
                                    ->label('Paymob HMAC Secret')
                                    ->required(fn (Forms\Get $get) => $get('paymob_enabled'))
                                    ->maxLength(255)
                                    ->password()
                                    ->revealable()
                                    ->helperText('سر HMAC للتحقق من الطلبات'),

                                Forms\Components\Select::make('paymob_mode')
                                    ->label('وضع Paymob')
                                    ->options([
                                        'sandbox' => 'اختبار (Sandbox)',
                                        'live' => 'مباشر (Live)',
                                    ])
                                    ->default('sandbox')
                                    ->required(fn (Forms\Get $get) => $get('paymob_enabled'))
                                    ->helperText('اختر الوضع المناسب'),

                                Forms\Components\TextInput::make('paymob_currency')
                                    ->label('العملة')
                                    ->default('EGP')
                                    ->maxLength(3)
                                    ->required(fn (Forms\Get $get) => $get('paymob_enabled'))
                                    ->helperText('EGP للجنيه المصري، SAR للريال السعودي'),
                            ])->columns(2),

                        Forms\Components\Tabs\Tab::make('الذكاء الاصطناعي')
                            ->icon('heroicon-o-cpu-chip')
                            ->schema([
                                Forms\Components\Section::make('OpenAI')
                                    ->description('GPT-4, GPT-3.5, DALL-E للنصوص والصور')
                                    ->schema([
                                        Forms\Components\Toggle::make('openai_enabled')
                                            ->label('تفعيل OpenAI')
                                            ->default(false)
                                            ->live(),

                                        Forms\Components\TextInput::make('openai_api_key')
                                            ->label('OpenAI API Key')
                                            ->required(fn (Forms\Get $get) => $get('openai_enabled'))
                                            ->maxLength(255)
                                            ->password()
                                            ->revealable()
                                            ->helperText('احصل عليه من platform.openai.com'),

                                        Forms\Components\Select::make('openai_model')
                                            ->label('النموذج الافتراضي')
                                            ->options([
                                                'gpt-4' => 'GPT-4 (الأقوى)',
                                                'gpt-4-turbo-preview' => 'GPT-4 Turbo',
                                                'gpt-3.5-turbo' => 'GPT-3.5 Turbo (الأسرع)',
                                            ])
                                            ->default('gpt-3.5-turbo')
                                            ->required(fn (Forms\Get $get) => $get('openai_enabled')),

                                        Forms\Components\TextInput::make('openai_max_tokens')
                                            ->label('أقصى عدد للـ Tokens')
                                            ->numeric()
                                            ->default(2000)
                                            ->minValue(100)
                                            ->maxValue(4000)
                                            ->required(fn (Forms\Get $get) => $get('openai_enabled')),
                                    ])->columns(2)->collapsible(),

                                Forms\Components\Section::make('Anthropic Claude')
                                    ->description('Claude 3 للمحادثات المتقدمة')
                                    ->schema([
                                        Forms\Components\Toggle::make('anthropic_enabled')
                                            ->label('تفعيل Claude')
                                            ->default(false)
                                            ->live(),

                                        Forms\Components\TextInput::make('anthropic_api_key')
                                            ->label('Anthropic API Key')
                                            ->required(fn (Forms\Get $get) => $get('anthropic_enabled'))
                                            ->maxLength(255)
                                            ->password()
                                            ->revealable()
                                            ->helperText('احصل عليه من console.anthropic.com'),

                                        Forms\Components\Select::make('anthropic_model')
                                            ->label('النموذج')
                                            ->options([
                                                'claude-3-opus-20240229' => 'Claude 3 Opus (الأقوى)',
                                                'claude-3-sonnet-20240229' => 'Claude 3 Sonnet (متوازن)',
                                                'claude-3-haiku-20240307' => 'Claude 3 Haiku (الأسرع)',
                                            ])
                                            ->default('claude-3-sonnet-20240229')
                                            ->required(fn (Forms\Get $get) => $get('anthropic_enabled')),

                                        Forms\Components\TextInput::make('anthropic_max_tokens')
                                            ->label('أقصى عدد للـ Tokens')
                                            ->numeric()
                                            ->default(2000)
                                            ->minValue(100)
                                            ->maxValue(4000)
                                            ->required(fn (Forms\Get $get) => $get('anthropic_enabled')),
                                    ])->columns(2)->collapsible(),

                                Forms\Components\Section::make('Google Gemini')
                                    ->description('Gemini Pro للنصوص والمحتوى')
                                    ->schema([
                                        Forms\Components\Toggle::make('google_ai_enabled')
                                            ->label('تفعيل Gemini')
                                            ->default(false)
                                            ->live(),

                                        Forms\Components\TextInput::make('google_ai_api_key')
                                            ->label('Google AI API Key')
                                            ->required(fn (Forms\Get $get) => $get('google_ai_enabled'))
                                            ->maxLength(255)
                                            ->password()
                                            ->revealable()
                                            ->helperText('احصل عليه من makersuite.google.com'),

                                        Forms\Components\Select::make('google_ai_model')
                                            ->label('النموذج')
                                            ->options([
                                                'gemini-pro' => 'Gemini Pro',
                                                'gemini-pro-vision' => 'Gemini Pro Vision',
                                            ])
                                            ->default('gemini-pro')
                                            ->required(fn (Forms\Get $get) => $get('google_ai_enabled')),
                                    ])->columns(2)->collapsible(),

                                Forms\Components\Section::make('Stability AI')
                                    ->description('Stable Diffusion لتوليد الصور')
                                    ->schema([
                                        Forms\Components\Toggle::make('stability_ai_enabled')
                                            ->label('تفعيل Stability AI')
                                            ->default(false)
                                            ->live(),

                                        Forms\Components\TextInput::make('stability_ai_api_key')
                                            ->label('Stability AI API Key')
                                            ->required(fn (Forms\Get $get) => $get('stability_ai_enabled'))
                                            ->maxLength(255)
                                            ->password()
                                            ->revealable()
                                            ->helperText('احصل عليه من platform.stability.ai'),

                                        Forms\Components\Select::make('stability_ai_model')
                                            ->label('النموذج')
                                            ->options([
                                                'stable-diffusion-xl-1024-v1-0' => 'SDXL 1.0',
                                                'stable-diffusion-v1-6' => 'SD 1.6',
                                            ])
                                            ->default('stable-diffusion-xl-1024-v1-0')
                                            ->required(fn (Forms\Get $get) => $get('stability_ai_enabled')),
                                    ])->columns(2)->collapsible(),

                                Forms\Components\Section::make('Hugging Face')
                                    ->description('نماذج مفتوحة المصدر متعددة')
                                    ->schema([
                                        Forms\Components\Toggle::make('huggingface_enabled')
                                            ->label('تفعيل Hugging Face')
                                            ->default(false)
                                            ->live(),

                                        Forms\Components\TextInput::make('huggingface_api_key')
                                            ->label('Hugging Face API Token')
                                            ->required(fn (Forms\Get $get) => $get('huggingface_enabled'))
                                            ->maxLength(255)
                                            ->password()
                                            ->revealable()
                                            ->helperText('احصل عليه من huggingface.co/settings/tokens'),
                                    ])->columns(2)->collapsible(),

                                Forms\Components\Section::make('إعدادات عامة')
                                    ->schema([
                                        Forms\Components\Select::make('ai_default_provider')
                                            ->label('الخدمة الافتراضية')
                                            ->options([
                                                'openai' => 'OpenAI',
                                                'anthropic' => 'Anthropic Claude',
                                                'google' => 'Google Gemini',
                                                'stability' => 'Stability AI',
                                                'huggingface' => 'Hugging Face',
                                            ])
                                            ->default('openai')
                                            ->required()
                                            ->helperText('الخدمة المستخدمة افتراضياً لتوليد المحتوى'),

                                        Forms\Components\TextInput::make('ai_requests_per_day')
                                            ->label('الحد اليومي للطلبات')
                                            ->numeric()
                                            ->default(100)
                                            ->minValue(1)
                                            ->required()
                                            ->helperText('عدد الطلبات المسموح بها يومياً لكل مستخدم'),

                                        Forms\Components\Toggle::make('ai_content_moderation')
                                            ->label('تفعيل فلترة المحتوى')
                                            ->default(true)
                                            ->helperText('فحص المحتوى المُولد للتأكد من سلامته'),

                                        Forms\Components\Toggle::make('ai_usage_tracking')
                                            ->label('تتبع الاستخدام')
                                            ->default(true)
                                            ->helperText('حفظ سجل باستخدام خدمات AI'),
                                    ])->columns(2),
                            ]),

                        Forms\Components\Tabs\Tab::make('البريد الإلكتروني')
                            ->icon('heroicon-o-envelope')
                            ->schema([
                                Forms\Components\Select::make('mail_mailer')
                                    ->label('خدمة البريد')
                                    ->options([
                                        'smtp' => 'SMTP',
                                        'mailgun' => 'Mailgun',
                                        'postmark' => 'Postmark',
                                        'ses' => 'Amazon SES',
                                    ])
                                    ->default('smtp')
                                    ->required(),

                                Forms\Components\TextInput::make('mail_host')
                                    ->label('SMTP Host')
                                    ->required()
                                    ->maxLength(255),

                                Forms\Components\TextInput::make('mail_port')
                                    ->label('SMTP Port')
                                    ->numeric()
                                    ->required()
                                    ->default(587),

                                Forms\Components\TextInput::make('mail_username')
                                    ->label('SMTP Username')
                                    ->maxLength(255),

                                Forms\Components\TextInput::make('mail_password')
                                    ->label('SMTP Password')
                                    ->password()
                                    ->revealable()
                                    ->maxLength(255),

                                Forms\Components\Select::make('mail_encryption')
                                    ->label('التشفير')
                                    ->options([
                                        'tls' => 'TLS',
                                        'ssl' => 'SSL',
                                        null => 'بدون تشفير',
                                    ])
                                    ->default('tls'),

                                Forms\Components\TextInput::make('mail_from_address')
                                    ->label('البريد المرسل منه')
                                    ->email()
                                    ->required(),

                                Forms\Components\TextInput::make('mail_from_name')
                                    ->label('اسم المرسل')
                                    ->required(),
                            ])->columns(2),

                        Forms\Components\Tabs\Tab::make('وسائل التواصل')
                            ->icon('heroicon-o-share')
                            ->schema([
                                Forms\Components\TextInput::make('facebook_url')
                                    ->label('Facebook')
                                    ->url()
                                    ->prefix('https://facebook.com/'),

                                Forms\Components\TextInput::make('twitter_url')
                                    ->label('Twitter/X')
                                    ->url()
                                    ->prefix('https://twitter.com/'),

                                Forms\Components\TextInput::make('instagram_url')
                                    ->label('Instagram')
                                    ->url()
                                    ->prefix('https://instagram.com/'),

                                Forms\Components\TextInput::make('linkedin_url')
                                    ->label('LinkedIn')
                                    ->url()
                                    ->prefix('https://linkedin.com/'),

                                Forms\Components\TextInput::make('youtube_url')
                                    ->label('YouTube')
                                    ->url()
                                    ->prefix('https://youtube.com/'),

                                Forms\Components\TextInput::make('whatsapp_number')
                                    ->label('رقم WhatsApp')
                                    ->tel()
                                    ->helperText('مع رمز الدولة بدون +'),
                            ])->columns(2),

                        Forms\Components\Tabs\Tab::make('أخرى')
                            ->icon('heroicon-o-cog')
                            ->schema([
                                Forms\Components\Toggle::make('maintenance_mode')
                                    ->label('وضع الصيانة')
                                    ->default(false)
                                    ->helperText('عند التفعيل، لن يتمكن المستخدمون من الوصول للتطبيق'),

                                Forms\Components\Toggle::make('registration_enabled')
                                    ->label('السماح بالتسجيل')
                                    ->default(true)
                                    ->helperText('عند التعطيل، لن يتمكن مستخدمون جدد من التسجيل'),

                                Forms\Components\Toggle::make('email_verification_required')
                                    ->label('التحقق من البريد مطلوب')
                                    ->default(false),

                                Forms\Components\TextInput::make('items_per_page')
                                    ->label('عدد العناصر في الصفحة')
                                    ->numeric()
                                    ->default(20)
                                    ->required(),

                                Forms\Components\Select::make('default_language')
                                    ->label('اللغة الافتراضية')
                                    ->options([
                                        'ar' => 'العربية',
                                        'en' => 'English',
                                    ])
                                    ->default('ar')
                                    ->required(),

                                Forms\Components\Select::make('timezone')
                                    ->label('المنطقة الزمنية')
                                    ->searchable()
                                    ->options([
                                        'UTC' => 'UTC',
                                        'Asia/Riyadh' => 'الرياض',
                                        'Asia/Dubai' => 'دبي',
                                        'Africa/Cairo' => 'القاهرة',
                                        'Europe/London' => 'لندن',
                                        'America/New_York' => 'نيويورك',
                                    ])
                                    ->default('UTC')
                                    ->required(),
                            ])->columns(2),

                        Forms\Components\Tabs\Tab::make('Twilio SMS')
                            ->icon('heroicon-o-chat-bubble-left-right')
                            ->schema([
                                Forms\Components\Section::make('إعدادات Twilio')
                                    ->description('خدمة إرسال رسائل SMS عبر Twilio')
                                    ->schema([
                                        Forms\Components\Toggle::make('twilio_enabled')
                                            ->label('تفعيل Twilio SMS')
                                            ->default(false)
                                            ->live()
                                            ->helperText('تفعيل إرسال رسائل OTP عبر Twilio'),

                                        Forms\Components\Toggle::make('twilio_test_mode')
                                            ->label('وضع الاختبار')
                                            ->default(true)
                                            ->helperText('في وضع الاختبار، لن يتم إرسال SMS فعلي والرمز الثابت هو 12345678'),

                                        Forms\Components\TextInput::make('twilio_account_sid')
                                            ->label('Twilio Account SID')
                                            ->required(fn (Forms\Get $get) => $get('twilio_enabled') && !$get('twilio_test_mode'))
                                            ->password()
                                            ->revealable()
                                            ->maxLength(255)
                                            ->placeholder('ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
                                            ->helperText('احصل عليه من Twilio Console'),

                                        Forms\Components\TextInput::make('twilio_auth_token')
                                            ->label('Twilio Auth Token')
                                            ->required(fn (Forms\Get $get) => $get('twilio_enabled') && !$get('twilio_test_mode'))
                                            ->password()
                                            ->revealable()
                                            ->maxLength(255)
                                            ->helperText('رمز المصادقة من Twilio Console'),

                                        Forms\Components\TextInput::make('twilio_from_number')
                                            ->label('رقم الإرسال (Twilio Phone Number)')
                                            ->required(fn (Forms\Get $get) => $get('twilio_enabled') && !$get('twilio_test_mode'))
                                            ->tel()
                                            ->placeholder('+1234567890')
                                            ->helperText('رقم الهاتف المشترى من Twilio'),

                                        Forms\Components\Select::make('twilio_default_country_code')
                                            ->label('مقدمة الدولة الافتراضية')
                                            ->options([
                                                '+971' => '+971 (الإمارات)',
                                                '+966' => '+966 (السعودية)',
                                                '+20' => '+20 (مصر)',
                                                '+962' => '+962 (الأردن)',
                                                '+965' => '+965 (الكويت)',
                                                '+973' => '+973 (البحرين)',
                                                '+968' => '+968 (عُمان)',
                                                '+974' => '+974 (قطر)',
                                                '+961' => '+961 (لبنان)',
                                                '+963' => '+963 (سوريا)',
                                                '+964' => '+964 (العراق)',
                                                '+212' => '+212 (المغرب)',
                                                '+216' => '+216 (تونس)',
                                                '+213' => '+213 (الجزائر)',
                                                '+1' => '+1 (أمريكا/كندا)',
                                                '+44' => '+44 (بريطانيا)',
                                            ])
                                            ->default('+971')
                                            ->required()
                                            ->helperText('تُضاف تلقائياً للأرقام التي لا تحتوي على مقدمة'),
                                    ])->columns(2),

                                Forms\Components\Section::make('إعدادات OTP')
                                    ->schema([
                                        Forms\Components\TextInput::make('twilio_otp_length')
                                            ->label('طول رمز OTP')
                                            ->numeric()
                                            ->default(8)
                                            ->minValue(4)
                                            ->maxValue(8)
                                            ->required()
                                            ->helperText('عدد الأرقام في رمز التحقق (4-8)'),

                                        Forms\Components\TextInput::make('twilio_otp_expiry_minutes')
                                            ->label('مدة صلاحية OTP (بالدقائق)')
                                            ->numeric()
                                            ->default(5)
                                            ->minValue(1)
                                            ->maxValue(30)
                                            ->required()
                                            ->helperText('المدة التي يبقى فيها رمز OTP صالحاً'),

                                        Forms\Components\TextInput::make('twilio_resend_cooldown')
                                            ->label('فترة الانتظار لإعادة الإرسال (ثانية)')
                                            ->numeric()
                                            ->default(60)
                                            ->minValue(30)
                                            ->maxValue(300)
                                            ->required()
                                            ->helperText('الوقت الذي يجب انتظاره قبل طلب رمز جديد'),

                                        Forms\Components\Textarea::make('twilio_otp_message_template')
                                            ->label('قالب رسالة OTP')
                                            ->default('رمز التحقق الخاص بك: {otp}\nصالح لمدة {minutes} دقائق')
                                            ->rows(2)
                                            ->helperText('استخدم {otp} للرمز و {minutes} للمدة'),
                                    ])->columns(2)->collapsible(),
                            ]),

                        Forms\Components\Tabs\Tab::make('Firebase OTP')
                            ->icon('heroicon-o-device-phone-mobile')
                            ->schema([
                                Forms\Components\Section::make('إعدادات Firebase')
                                    ->description('إعدادات المصادقة عبر Firebase OTP')
                                    ->schema([
                                        Forms\Components\Toggle::make('firebase_enabled')
                                            ->label('تفعيل Firebase OTP')
                                            ->default(false)
                                            ->live()
                                            ->helperText('تفعيل نظام التحقق من رقم الهاتف عبر Firebase'),

                                        Forms\Components\TextInput::make('firebase_api_key')
                                            ->label('Firebase API Key')
                                            ->required(fn (Forms\Get $get) => $get('firebase_enabled'))
                                            ->password()
                                            ->revealable()
                                            ->maxLength(255)
                                            ->helperText('احصل عليه من Firebase Console > Project Settings > Web API Key'),

                                        Forms\Components\TextInput::make('firebase_auth_domain')
                                            ->label('Firebase Auth Domain')
                                            ->required(fn (Forms\Get $get) => $get('firebase_enabled'))
                                            ->maxLength(255)
                                            ->placeholder('your-project.firebaseapp.com')
                                            ->helperText('نطاق المصادقة من Firebase'),

                                        Forms\Components\TextInput::make('firebase_project_id')
                                            ->label('Firebase Project ID')
                                            ->required(fn (Forms\Get $get) => $get('firebase_enabled'))
                                            ->maxLength(255)
                                            ->helperText('معرف المشروع من Firebase Console'),

                                        Forms\Components\TextInput::make('firebase_storage_bucket')
                                            ->label('Firebase Storage Bucket')
                                            ->maxLength(255)
                                            ->placeholder('your-project.appspot.com')
                                            ->helperText('اختياري - للاستخدام المتقدم'),

                                        Forms\Components\TextInput::make('firebase_messaging_sender_id')
                                            ->label('Firebase Messaging Sender ID')
                                            ->maxLength(255)
                                            ->helperText('اختياري - لإرسال الإشعارات'),

                                        Forms\Components\TextInput::make('firebase_app_id')
                                            ->label('Firebase App ID')
                                            ->maxLength(255)
                                            ->helperText('معرف التطبيق من Firebase'),
                                    ])->columns(2),

                                Forms\Components\Section::make('Service Account (للاستخدام من السيرفر)')
                                    ->description('بيانات حساب الخدمة لاستخدام Firebase Admin SDK')
                                    ->schema([
                                        Forms\Components\Textarea::make('firebase_service_account')
                                            ->label('Service Account JSON')
                                            ->rows(10)
                                            ->helperText('الصق محتوى ملف Service Account JSON من Firebase Console > Project Settings > Service Accounts')
                                            ->placeholder('{ "type": "service_account", ... }'),

                                        Forms\Components\TextInput::make('firebase_database_url')
                                            ->label('Firebase Database URL')
                                            ->url()
                                            ->placeholder('https://your-project.firebaseio.com')
                                            ->helperText('رابط قاعدة البيانات (اختياري)'),
                                    ])->columns(1)->collapsible(),

                                Forms\Components\Section::make('إعدادات OTP')
                                    ->schema([
                                        Forms\Components\TextInput::make('otp_code_length')
                                            ->label('طول رمز OTP')
                                            ->numeric()
                                            ->default(6)
                                            ->minValue(4)
                                            ->maxValue(8)
                                            ->required()
                                            ->helperText('عدد الأرقام في رمز التحقق'),

                                        Forms\Components\TextInput::make('otp_expiry_minutes')
                                            ->label('مدة صلاحية OTP (بالدقائق)')
                                            ->numeric()
                                            ->default(5)
                                            ->minValue(1)
                                            ->maxValue(30)
                                            ->required()
                                            ->helperText('المدة التي يبقى فيها رمز OTP صالحاً'),

                                        Forms\Components\Toggle::make('otp_allow_resend')
                                            ->label('السماح بإعادة الإرسال')
                                            ->default(true)
                                            ->helperText('السماح للمستخدم بطلب رمز جديد'),

                                        Forms\Components\TextInput::make('otp_resend_cooldown_seconds')
                                            ->label('فترة الانتظار لإعادة الإرسال (ثانية)')
                                            ->numeric()
                                            ->default(60)
                                            ->minValue(30)
                                            ->maxValue(300)
                                            ->required()
                                            ->helperText('الوقت الذي يجب انتظاره قبل طلب رمز جديد'),
                                    ])->columns(2)->collapsible(),
                            ]),
                    ])
                    ->columnSpanFull(),
            ])
            ->statePath('data');
    }

    public function save(): void
    {
        $data = $this->form->getState();

        // تعيين أنواع البيانات والمجموعات
        $settingsConfig = [
            // General Settings
            'app_name' => ['type' => 'string', 'group' => 'general'],
            'app_description' => ['type' => 'string', 'group' => 'general'],
            'app_url' => ['type' => 'string', 'group' => 'general'],
            'app_logo' => ['type' => 'string', 'group' => 'general'],
            'admin_email' => ['type' => 'string', 'group' => 'general'],
            'support_email' => ['type' => 'string', 'group' => 'general'],

            // Stripe
            'stripe_enabled' => ['type' => 'boolean', 'group' => 'payment'],
            'stripe_publishable_key' => ['type' => 'string', 'group' => 'payment'],
            'stripe_secret_key' => ['type' => 'string', 'group' => 'payment'],
            'stripe_webhook_secret' => ['type' => 'string', 'group' => 'payment'],

            // PayPal
            'paypal_enabled' => ['type' => 'boolean', 'group' => 'payment'],
            'paypal_client_id' => ['type' => 'string', 'group' => 'payment'],
            'paypal_secret' => ['type' => 'string', 'group' => 'payment'],
            'paypal_mode' => ['type' => 'string', 'group' => 'payment'],

            // Paymob
            'paymob_enabled' => ['type' => 'boolean', 'group' => 'payment'],
            'paymob_api_key' => ['type' => 'string', 'group' => 'payment'],
            'paymob_iframe_id' => ['type' => 'string', 'group' => 'payment'],
            'paymob_integration_id' => ['type' => 'string', 'group' => 'payment'],
            'paymob_hmac_secret' => ['type' => 'string', 'group' => 'payment'],
            'paymob_mode' => ['type' => 'string', 'group' => 'payment'],
            'paymob_currency' => ['type' => 'string', 'group' => 'payment'],

            // AI - OpenAI
            'openai_enabled' => ['type' => 'boolean', 'group' => 'ai'],
            'openai_api_key' => ['type' => 'string', 'group' => 'ai'],
            'openai_model' => ['type' => 'string', 'group' => 'ai'],
            'openai_max_tokens' => ['type' => 'integer', 'group' => 'ai'],

            // AI - Anthropic
            'anthropic_enabled' => ['type' => 'boolean', 'group' => 'ai'],
            'anthropic_api_key' => ['type' => 'string', 'group' => 'ai'],
            'anthropic_model' => ['type' => 'string', 'group' => 'ai'],
            'anthropic_max_tokens' => ['type' => 'integer', 'group' => 'ai'],

            // AI - Google
            'google_ai_enabled' => ['type' => 'boolean', 'group' => 'ai'],
            'google_ai_api_key' => ['type' => 'string', 'group' => 'ai'],
            'google_ai_model' => ['type' => 'string', 'group' => 'ai'],

            // AI - Stability
            'stability_ai_enabled' => ['type' => 'boolean', 'group' => 'ai'],
            'stability_ai_api_key' => ['type' => 'string', 'group' => 'ai'],
            'stability_ai_model' => ['type' => 'string', 'group' => 'ai'],

            // AI - Hugging Face
            'huggingface_enabled' => ['type' => 'boolean', 'group' => 'ai'],
            'huggingface_api_key' => ['type' => 'string', 'group' => 'ai'],

            // AI - General
            'ai_default_provider' => ['type' => 'string', 'group' => 'ai'],
            'ai_requests_per_day' => ['type' => 'integer', 'group' => 'ai'],
            'ai_content_moderation' => ['type' => 'boolean', 'group' => 'ai'],
            'ai_usage_tracking' => ['type' => 'boolean', 'group' => 'ai'],

            // Email
            'mail_mailer' => ['type' => 'string', 'group' => 'email'],
            'mail_host' => ['type' => 'string', 'group' => 'email'],
            'mail_port' => ['type' => 'integer', 'group' => 'email'],
            'mail_username' => ['type' => 'string', 'group' => 'email'],
            'mail_password' => ['type' => 'string', 'group' => 'email'],
            'mail_encryption' => ['type' => 'string', 'group' => 'email'],
            'mail_from_address' => ['type' => 'string', 'group' => 'email'],
            'mail_from_name' => ['type' => 'string', 'group' => 'email'],

            // Social Media
            'facebook_url' => ['type' => 'string', 'group' => 'social'],
            'twitter_url' => ['type' => 'string', 'group' => 'social'],
            'instagram_url' => ['type' => 'string', 'group' => 'social'],
            'linkedin_url' => ['type' => 'string', 'group' => 'social'],
            'youtube_url' => ['type' => 'string', 'group' => 'social'],
            'whatsapp_number' => ['type' => 'string', 'group' => 'social'],

            // Other
            'maintenance_mode' => ['type' => 'boolean', 'group' => 'system'],
            'registration_enabled' => ['type' => 'boolean', 'group' => 'system'],
            'email_verification_required' => ['type' => 'boolean', 'group' => 'system'],
            'items_per_page' => ['type' => 'integer', 'group' => 'system'],
            'default_language' => ['type' => 'string', 'group' => 'system'],
            'timezone' => ['type' => 'string', 'group' => 'system'],

            // Firebase OTP
            'firebase_enabled' => ['type' => 'boolean', 'group' => 'firebase'],
            'firebase_api_key' => ['type' => 'string', 'group' => 'firebase'],
            'firebase_auth_domain' => ['type' => 'string', 'group' => 'firebase'],
            'firebase_project_id' => ['type' => 'string', 'group' => 'firebase'],
            'firebase_storage_bucket' => ['type' => 'string', 'group' => 'firebase'],
            'firebase_messaging_sender_id' => ['type' => 'string', 'group' => 'firebase'],
            'firebase_app_id' => ['type' => 'string', 'group' => 'firebase'],
            'firebase_service_account' => ['type' => 'string', 'group' => 'firebase'],
            'firebase_database_url' => ['type' => 'string', 'group' => 'firebase'],
            'otp_code_length' => ['type' => 'integer', 'group' => 'firebase'],
            'otp_expiry_minutes' => ['type' => 'integer', 'group' => 'firebase'],
            'otp_allow_resend' => ['type' => 'boolean', 'group' => 'firebase'],
            'otp_resend_cooldown_seconds' => ['type' => 'integer', 'group' => 'firebase'],

            // Twilio SMS
            'twilio_enabled' => ['type' => 'boolean', 'group' => 'twilio'],
            'twilio_test_mode' => ['type' => 'boolean', 'group' => 'twilio'],
            'twilio_account_sid' => ['type' => 'string', 'group' => 'twilio'],
            'twilio_auth_token' => ['type' => 'string', 'group' => 'twilio'],
            'twilio_from_number' => ['type' => 'string', 'group' => 'twilio'],
            'twilio_default_country_code' => ['type' => 'string', 'group' => 'twilio'],
            'twilio_otp_length' => ['type' => 'integer', 'group' => 'twilio'],
            'twilio_otp_expiry_minutes' => ['type' => 'integer', 'group' => 'twilio'],
            'twilio_resend_cooldown' => ['type' => 'integer', 'group' => 'twilio'],
            'twilio_otp_message_template' => ['type' => 'string', 'group' => 'twilio'],
        ];

        foreach ($data as $key => $value) {
            $config = $settingsConfig[$key] ?? ['type' => 'string', 'group' => 'general'];
            Setting::set($key, $value, $config['type'], $config['group']);
        }

        // مسح الكاش
        Setting::clearCache();

        Notification::make()
            ->title('تم حفظ الإعدادات بنجاح')
            ->icon('heroicon-o-check-circle')
            ->success()
            ->send();
    }

    protected function getFormActions(): array
    {
        return [
            Forms\Components\Actions\Action::make('save')
                ->label('حفظ الإعدادات')
                ->submit('save'),
        ];
    }
}
