<?php

namespace App\Filament\Pages;

use App\Models\Setting;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Pages\Page;
use Filament\Notifications\Notification;
use Illuminate\Support\Facades\Cache;

class PaymentSettings extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-credit-card';

    protected static string $view = 'filament.pages.payment-settings';

    protected static ?string $navigationGroup = 'Settings';

    protected static ?string $navigationLabel = 'إعدادات الدفع';

    protected static ?string $title = 'إعدادات بوابات الدفع';

    protected static ?int $navigationSort = 2;

    public ?array $data = [];

    public function mount(): void
    {
        $this->form->fill($this->getSettingsArray());
    }

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Tabs::make('Payment Gateways')
                    ->tabs([
                        // Tab 1: Stripe
                        Forms\Components\Tabs\Tab::make('Stripe')
                            ->icon('heroicon-o-credit-card')
                            ->schema([
                                Forms\Components\Section::make('إعدادات Stripe')
                                    ->description('بوابة الدفع Stripe للبطاقات الائتمانية والمحافظ الإلكترونية')
                                    ->schema([
                                        Forms\Components\Toggle::make('stripe_enabled')
                                            ->label('تفعيل Stripe')
                                            ->helperText('تفعيل بوابة الدفع Stripe')
                                            ->default(false)
                                            ->reactive()
                                            ->inline(false),

                                        Forms\Components\Grid::make(2)
                                            ->schema([
                                                Forms\Components\TextInput::make('stripe_public_key')
                                                    ->label('Stripe Public Key')
                                                    ->helperText('المفتاح العام (Publishable Key)')
                                                    ->placeholder('pk_live_...')
                                                    ->required(fn ($get) => $get('stripe_enabled'))
                                                    ->visible(fn ($get) => $get('stripe_enabled')),

                                                Forms\Components\TextInput::make('stripe_secret_key')
                                                    ->label('Stripe Secret Key')
                                                    ->helperText('المفتاح السري (Secret Key)')
                                                    ->placeholder('sk_live_...')
                                                    ->password()
                                                    ->revealable()
                                                    ->required(fn ($get) => $get('stripe_enabled'))
                                                    ->visible(fn ($get) => $get('stripe_enabled')),

                                                Forms\Components\TextInput::make('stripe_webhook_secret')
                                                    ->label('Webhook Secret')
                                                    ->helperText('سر Webhook للتحقق من الأحداث')
                                                    ->placeholder('whsec_...')
                                                    ->password()
                                                    ->revealable()
                                                    ->visible(fn ($get) => $get('stripe_enabled')),

                                                Forms\Components\Select::make('stripe_currency')
                                                    ->label('العملة الافتراضية')
                                                    ->options([
                                                        'usd' => 'USD - دولار أمريكي',
                                                        'aed' => 'AED - درهم إماراتي',
                                                        'eur' => 'EUR - يورو',
                                                        'gbp' => 'GBP - جنيه إسترليني',
                                                        'sar' => 'SAR - ريال سعودي',
                                                    ])
                                                    ->default('usd')
                                                    ->visible(fn ($get) => $get('stripe_enabled')),
                                            ]),

                                        Forms\Components\Placeholder::make('stripe_webhook_url')
                                            ->label('رابط Webhook')
                                            ->content('https://mediaprosocial.io/api/webhooks/stripe')
                                            ->helperText('أضف هذا الرابط في لوحة تحكم Stripe -> Webhooks')
                                            ->visible(fn ($get) => $get('stripe_enabled')),
                                    ]),

                                Forms\Components\Section::make('ميزات Stripe المتقدمة')
                                    ->description('خيارات إضافية لـ Stripe')
                                    ->schema([
                                        Forms\Components\Grid::make(2)
                                            ->schema([
                                                Forms\Components\Toggle::make('stripe_enable_apple_pay')
                                                    ->label('تفعيل Apple Pay')
                                                    ->default(true)
                                                    ->inline(false)
                                                    ->visible(fn ($get) => $get('stripe_enabled')),

                                                Forms\Components\Toggle::make('stripe_enable_google_pay')
                                                    ->label('تفعيل Google Pay')
                                                    ->default(true)
                                                    ->inline(false)
                                                    ->visible(fn ($get) => $get('stripe_enabled')),

                                                Forms\Components\Toggle::make('stripe_save_cards')
                                                    ->label('السماح بحفظ البطاقات')
                                                    ->helperText('للدفع السريع مستقبلاً')
                                                    ->default(true)
                                                    ->inline(false)
                                                    ->visible(fn ($get) => $get('stripe_enabled')),

                                                Forms\Components\Toggle::make('stripe_test_mode')
                                                    ->label('وضع الاختبار (Test Mode)')
                                                    ->helperText('استخدام مفاتيح الاختبار بدلاً من الحقيقية')
                                                    ->default(false)
                                                    ->inline(false)
                                                    ->visible(fn ($get) => $get('stripe_enabled')),
                                            ]),
                                    ])
                                    ->collapsible(),
                            ]),

                        // Tab 2: Paymob
                        Forms\Components\Tabs\Tab::make('Paymob')
                            ->icon('heroicon-o-banknotes')
                            ->schema([
                                Forms\Components\Section::make('إعدادات Paymob')
                                    ->description('بوابة الدفع Paymob للدول العربية')
                                    ->schema([
                                        Forms\Components\Toggle::make('paymob_enabled')
                                            ->label('تفعيل Paymob')
                                            ->helperText('تفعيل بوابة الدفع Paymob')
                                            ->default(false)
                                            ->reactive()
                                            ->inline(false),

                                        Forms\Components\Grid::make(2)
                                            ->schema([
                                                Forms\Components\TextInput::make('paymob_api_key')
                                                    ->label('API Key')
                                                    ->helperText('مفتاح API من Paymob')
                                                    ->password()
                                                    ->revealable()
                                                    ->required(fn ($get) => $get('paymob_enabled'))
                                                    ->visible(fn ($get) => $get('paymob_enabled')),

                                                Forms\Components\TextInput::make('paymob_integration_id')
                                                    ->label('Integration ID')
                                                    ->helperText('معرف التكامل')
                                                    ->required(fn ($get) => $get('paymob_enabled'))
                                                    ->visible(fn ($get) => $get('paymob_enabled')),

                                                Forms\Components\TextInput::make('paymob_iframe_id')
                                                    ->label('iFrame ID')
                                                    ->helperText('معرف الـ iFrame للدفع')
                                                    ->required(fn ($get) => $get('paymob_enabled'))
                                                    ->visible(fn ($get) => $get('paymob_enabled')),

                                                Forms\Components\TextInput::make('paymob_hmac_secret')
                                                    ->label('HMAC Secret')
                                                    ->helperText('للتحقق من صحة Callbacks')
                                                    ->password()
                                                    ->revealable()
                                                    ->visible(fn ($get) => $get('paymob_enabled')),

                                                Forms\Components\Select::make('paymob_currency')
                                                    ->label('العملة الافتراضية')
                                                    ->options([
                                                        'EGP' => 'EGP - جنيه مصري',
                                                        'SAR' => 'SAR - ريال سعودي',
                                                        'AED' => 'AED - درهم إماراتي',
                                                        'KWD' => 'KWD - دينار كويتي',
                                                    ])
                                                    ->default('EGP')
                                                    ->visible(fn ($get) => $get('paymob_enabled')),
                                            ]),

                                        Forms\Components\Placeholder::make('paymob_callback_url')
                                            ->label('روابط Callback')
                                            ->content(function () {
                                                return "Success: https://mediaprosocial.io/api/payment/paymob/success\n" .
                                                       "Failed: https://mediaprosocial.io/api/payment/paymob/failed\n" .
                                                       "Callback: https://mediaprosocial.io/api/payment/paymob/callback";
                                            })
                                            ->helperText('أضف هذه الروابط في لوحة تحكم Paymob')
                                            ->visible(fn ($get) => $get('paymob_enabled')),
                                    ]),

                                Forms\Components\Section::make('طرق الدفع المتاحة')
                                    ->description('فعّل طرق الدفع المتاحة في Paymob')
                                    ->schema([
                                        Forms\Components\Grid::make(3)
                                            ->schema([
                                                Forms\Components\Toggle::make('paymob_card_payment')
                                                    ->label('بطاقات الائتمان')
                                                    ->default(true)
                                                    ->inline(false)
                                                    ->visible(fn ($get) => $get('paymob_enabled')),

                                                Forms\Components\Toggle::make('paymob_wallet')
                                                    ->label('المحافظ الإلكترونية')
                                                    ->default(true)
                                                    ->inline(false)
                                                    ->visible(fn ($get) => $get('paymob_enabled')),

                                                Forms\Components\Toggle::make('paymob_installments')
                                                    ->label('التقسيط')
                                                    ->default(false)
                                                    ->inline(false)
                                                    ->visible(fn ($get) => $get('paymob_enabled')),
                                            ]),
                                    ])
                                    ->collapsible(),
                            ]),

                        // Tab 3: PayPal
                        Forms\Components\Tabs\Tab::make('PayPal')
                            ->icon('heroicon-o-globe-alt')
                            ->schema([
                                Forms\Components\Section::make('إعدادات PayPal')
                                    ->description('بوابة الدفع PayPal العالمية')
                                    ->schema([
                                        Forms\Components\Toggle::make('paypal_enabled')
                                            ->label('تفعيل PayPal')
                                            ->helperText('تفعيل بوابة الدفع PayPal')
                                            ->default(false)
                                            ->reactive()
                                            ->inline(false),

                                        Forms\Components\Grid::make(2)
                                            ->schema([
                                                Forms\Components\TextInput::make('paypal_client_id')
                                                    ->label('Client ID')
                                                    ->helperText('معرف العميل من PayPal')
                                                    ->placeholder('AXXXxxxxXXXxxx...')
                                                    ->required(fn ($get) => $get('paypal_enabled'))
                                                    ->visible(fn ($get) => $get('paypal_enabled')),

                                                Forms\Components\TextInput::make('paypal_client_secret')
                                                    ->label('Client Secret')
                                                    ->helperText('المفتاح السري')
                                                    ->password()
                                                    ->revealable()
                                                    ->required(fn ($get) => $get('paypal_enabled'))
                                                    ->visible(fn ($get) => $get('paypal_enabled')),

                                                Forms\Components\TextInput::make('paypal_webhook_id')
                                                    ->label('Webhook ID')
                                                    ->helperText('معرف Webhook للأحداث')
                                                    ->visible(fn ($get) => $get('paypal_enabled')),

                                                Forms\Components\Select::make('paypal_mode')
                                                    ->label('البيئة')
                                                    ->options([
                                                        'sandbox' => 'Sandbox (اختبار)',
                                                        'live' => 'Live (حقيقي)',
                                                    ])
                                                    ->default('sandbox')
                                                    ->required()
                                                    ->visible(fn ($get) => $get('paypal_enabled')),

                                                Forms\Components\Select::make('paypal_currency')
                                                    ->label('العملة الافتراضية')
                                                    ->options([
                                                        'USD' => 'USD - دولار أمريكي',
                                                        'EUR' => 'EUR - يورو',
                                                        'GBP' => 'GBP - جنيه إسترليني',
                                                        'AED' => 'AED - درهم إماراتي',
                                                        'SAR' => 'SAR - ريال سعودي',
                                                    ])
                                                    ->default('USD')
                                                    ->visible(fn ($get) => $get('paypal_enabled')),
                                            ]),

                                        Forms\Components\Placeholder::make('paypal_webhook_url')
                                            ->label('رابط Webhook')
                                            ->content('https://mediaprosocial.io/api/webhooks/paypal')
                                            ->helperText('أضف هذا الرابط في لوحة تحكم PayPal -> Webhooks')
                                            ->visible(fn ($get) => $get('paypal_enabled')),
                                    ]),

                                Forms\Components\Section::make('خيارات PayPal المتقدمة')
                                    ->description('إعدادات إضافية لـ PayPal')
                                    ->schema([
                                        Forms\Components\Grid::make(2)
                                            ->schema([
                                                Forms\Components\Toggle::make('paypal_enable_venmo')
                                                    ->label('تفعيل Venmo')
                                                    ->helperText('للمستخدمين في الولايات المتحدة')
                                                    ->default(false)
                                                    ->inline(false)
                                                    ->visible(fn ($get) => $get('paypal_enabled')),

                                                Forms\Components\Toggle::make('paypal_enable_credit')
                                                    ->label('تفعيل PayPal Credit')
                                                    ->helperText('خيار الائتمان')
                                                    ->default(false)
                                                    ->inline(false)
                                                    ->visible(fn ($get) => $get('paypal_enabled')),

                                                Forms\Components\TextInput::make('paypal_brand_name')
                                                    ->label('اسم العلامة التجارية')
                                                    ->helperText('يظهر في صفحة الدفع')
                                                    ->default('Media Pro Social')
                                                    ->visible(fn ($get) => $get('paypal_enabled')),
                                            ]),
                                    ])
                                    ->collapsible(),
                            ]),

                        // Tab 4: Google Pay
                        Forms\Components\Tabs\Tab::make('Google Pay')
                            ->icon('heroicon-o-device-phone-mobile')
                            ->schema([
                                Forms\Components\Section::make('إعدادات Google Pay')
                                    ->description('بوابة الدفع Google Pay للهواتف الذكية')
                                    ->schema([
                                        Forms\Components\Toggle::make('google_pay_enabled')
                                            ->label('تفعيل Google Pay')
                                            ->helperText('تفعيل الدفع عبر Google Pay')
                                            ->default(false)
                                            ->reactive()
                                            ->inline(false),

                                        Forms\Components\Grid::make(2)
                                            ->schema([
                                                Forms\Components\TextInput::make('google_pay_merchant_id')
                                                    ->label('Merchant ID')
                                                    ->helperText('معرف التاجر من Google Pay')
                                                    ->placeholder('BCR2DN...')
                                                    ->required(fn ($get) => $get('google_pay_enabled'))
                                                    ->visible(fn ($get) => $get('google_pay_enabled')),

                                                Forms\Components\TextInput::make('google_pay_merchant_name')
                                                    ->label('اسم التاجر')
                                                    ->helperText('اسمك التجاري الذي سيظهر للعملاء')
                                                    ->default('Media Pro Social')
                                                    ->required(fn ($get) => $get('google_pay_enabled'))
                                                    ->visible(fn ($get) => $get('google_pay_enabled')),

                                                Forms\Components\Select::make('google_pay_environment')
                                                    ->label('البيئة')
                                                    ->options([
                                                        'TEST' => 'TEST (اختبار)',
                                                        'PRODUCTION' => 'PRODUCTION (حقيقي)',
                                                    ])
                                                    ->default('TEST')
                                                    ->required()
                                                    ->visible(fn ($get) => $get('google_pay_enabled')),

                                                Forms\Components\Select::make('google_pay_gateway')
                                                    ->label('بوابة الدفع')
                                                    ->helperText('البوابة التي ستعالج الدفع')
                                                    ->options([
                                                        'stripe' => 'Stripe',
                                                        'paymob' => 'Paymob',
                                                        'adyen' => 'Adyen',
                                                        'cybersource' => 'CyberSource',
                                                    ])
                                                    ->default('stripe')
                                                    ->required()
                                                    ->visible(fn ($get) => $get('google_pay_enabled')),

                                                Forms\Components\TextInput::make('google_pay_gateway_merchant_id')
                                                    ->label('Gateway Merchant ID')
                                                    ->helperText('معرف التاجر في البوابة المختارة')
                                                    ->required(fn ($get) => $get('google_pay_enabled'))
                                                    ->visible(fn ($get) => $get('google_pay_enabled')),
                                            ]),
                                    ]),

                                Forms\Components\Section::make('إعدادات متقدمة')
                                    ->description('خيارات إضافية لـ Google Pay')
                                    ->schema([
                                        Forms\Components\Grid::make(2)
                                            ->schema([
                                                Forms\Components\Toggle::make('google_pay_billing_address_required')
                                                    ->label('طلب عنوان الفاتورة')
                                                    ->default(true)
                                                    ->inline(false)
                                                    ->visible(fn ($get) => $get('google_pay_enabled')),

                                                Forms\Components\Toggle::make('google_pay_shipping_address_required')
                                                    ->label('طلب عنوان الشحن')
                                                    ->default(false)
                                                    ->inline(false)
                                                    ->visible(fn ($get) => $get('google_pay_enabled')),

                                                Forms\Components\Toggle::make('google_pay_email_required')
                                                    ->label('طلب البريد الإلكتروني')
                                                    ->default(true)
                                                    ->inline(false)
                                                    ->visible(fn ($get) => $get('google_pay_enabled')),

                                                Forms\Components\Toggle::make('google_pay_phone_required')
                                                    ->label('طلب رقم الهاتف')
                                                    ->default(false)
                                                    ->inline(false)
                                                    ->visible(fn ($get) => $get('google_pay_enabled')),

                                                Forms\Components\Select::make('google_pay_button_color')
                                                    ->label('لون زر Google Pay')
                                                    ->options([
                                                        'default' => 'افتراضي (أسود)',
                                                        'black' => 'أسود',
                                                        'white' => 'أبيض',
                                                    ])
                                                    ->default('default')
                                                    ->visible(fn ($get) => $get('google_pay_enabled')),

                                                Forms\Components\Select::make('google_pay_button_type')
                                                    ->label('نوع زر Google Pay')
                                                    ->options([
                                                        'buy' => 'Buy (شراء)',
                                                        'donate' => 'Donate (تبرع)',
                                                        'pay' => 'Pay (دفع)',
                                                        'plain' => 'Plain (عادي)',
                                                    ])
                                                    ->default('pay')
                                                    ->visible(fn ($get) => $get('google_pay_enabled')),
                                            ]),
                                    ])
                                    ->collapsible(),
                            ]),

                        // Tab 5: Apple Pay
                        Forms\Components\Tabs\Tab::make('Apple Pay')
                            ->icon('heroicon-o-device-tablet')
                            ->schema([
                                Forms\Components\Section::make('إعدادات Apple Pay')
                                    ->description('بوابة الدفع Apple Pay لأجهزة Apple')
                                    ->schema([
                                        Forms\Components\Toggle::make('apple_pay_enabled')
                                            ->label('تفعيل Apple Pay')
                                            ->helperText('تفعيل الدفع عبر Apple Pay')
                                            ->default(false)
                                            ->reactive()
                                            ->inline(false),

                                        Forms\Components\Grid::make(2)
                                            ->schema([
                                                Forms\Components\TextInput::make('apple_pay_merchant_id')
                                                    ->label('Merchant ID')
                                                    ->helperText('معرف التاجر من Apple Developer')
                                                    ->placeholder('merchant.com.yourcompany.app')
                                                    ->required(fn ($get) => $get('apple_pay_enabled'))
                                                    ->visible(fn ($get) => $get('apple_pay_enabled')),

                                                Forms\Components\TextInput::make('apple_pay_merchant_name')
                                                    ->label('اسم التاجر')
                                                    ->helperText('اسمك التجاري الذي سيظهر للعملاء')
                                                    ->default('Media Pro Social')
                                                    ->required(fn ($get) => $get('apple_pay_enabled'))
                                                    ->visible(fn ($get) => $get('apple_pay_enabled')),

                                                Forms\Components\Select::make('apple_pay_country_code')
                                                    ->label('كود الدولة')
                                                    ->options([
                                                        'US' => 'United States',
                                                        'AE' => 'United Arab Emirates',
                                                        'SA' => 'Saudi Arabia',
                                                        'GB' => 'United Kingdom',
                                                        'DE' => 'Germany',
                                                    ])
                                                    ->default('AE')
                                                    ->required()
                                                    ->visible(fn ($get) => $get('apple_pay_enabled')),

                                                Forms\Components\Select::make('apple_pay_currency_code')
                                                    ->label('كود العملة')
                                                    ->options([
                                                        'USD' => 'USD',
                                                        'AED' => 'AED',
                                                        'SAR' => 'SAR',
                                                        'EUR' => 'EUR',
                                                        'GBP' => 'GBP',
                                                    ])
                                                    ->default('AED')
                                                    ->required()
                                                    ->visible(fn ($get) => $get('apple_pay_enabled')),

                                                Forms\Components\Select::make('apple_pay_gateway')
                                                    ->label('بوابة الدفع')
                                                    ->helperText('البوابة التي ستعالج الدفع')
                                                    ->options([
                                                        'stripe' => 'Stripe',
                                                        'paymob' => 'Paymob',
                                                        'adyen' => 'Adyen',
                                                        'square' => 'Square',
                                                    ])
                                                    ->default('stripe')
                                                    ->required()
                                                    ->visible(fn ($get) => $get('apple_pay_enabled')),
                                            ]),

                                        Forms\Components\Placeholder::make('apple_pay_setup_note')
                                            ->label('ملاحظة مهمة')
                                            ->content('يجب عليك إعداد Apple Pay Merchant ID في Apple Developer Console وتحميل شهادة التفويض (Payment Processing Certificate)')
                                            ->visible(fn ($get) => $get('apple_pay_enabled')),
                                    ]),

                                Forms\Components\Section::make('إعدادات متقدمة')
                                    ->description('خيارات إضافية لـ Apple Pay')
                                    ->schema([
                                        Forms\Components\Grid::make(2)
                                            ->schema([
                                                Forms\Components\Toggle::make('apple_pay_require_billing')
                                                    ->label('طلب عنوان الفاتورة')
                                                    ->default(true)
                                                    ->inline(false)
                                                    ->visible(fn ($get) => $get('apple_pay_enabled')),

                                                Forms\Components\Toggle::make('apple_pay_require_shipping')
                                                    ->label('طلب عنوان الشحن')
                                                    ->default(false)
                                                    ->inline(false)
                                                    ->visible(fn ($get) => $get('apple_pay_enabled')),

                                                Forms\Components\Toggle::make('apple_pay_require_email')
                                                    ->label('طلب البريد الإلكتروني')
                                                    ->default(true)
                                                    ->inline(false)
                                                    ->visible(fn ($get) => $get('apple_pay_enabled')),

                                                Forms\Components\Toggle::make('apple_pay_require_phone')
                                                    ->label('طلب رقم الهاتف')
                                                    ->default(false)
                                                    ->inline(false)
                                                    ->visible(fn ($get) => $get('apple_pay_enabled')),

                                                Forms\Components\Select::make('apple_pay_button_style')
                                                    ->label('نمط زر Apple Pay')
                                                    ->options([
                                                        'black' => 'أسود',
                                                        'white' => 'أبيض',
                                                        'white-outline' => 'أبيض مع حدود',
                                                    ])
                                                    ->default('black')
                                                    ->visible(fn ($get) => $get('apple_pay_enabled')),

                                                Forms\Components\Select::make('apple_pay_button_type')
                                                    ->label('نوع زر Apple Pay')
                                                    ->options([
                                                        'buy' => 'Buy (شراء)',
                                                        'donate' => 'Donate (تبرع)',
                                                        'plain' => 'Plain (عادي)',
                                                        'check-out' => 'Check Out (سداد)',
                                                    ])
                                                    ->default('buy')
                                                    ->visible(fn ($get) => $get('apple_pay_enabled')),
                                            ]),
                                    ])
                                    ->collapsible(),
                            ]),

                        // Tab 6: إعدادات عامة
                        Forms\Components\Tabs\Tab::make('إعدادات عامة')
                            ->icon('heroicon-o-cog-6-tooth')
                            ->schema([
                                Forms\Components\Section::make('إعدادات الدفع العامة')
                                    ->schema([
                                        Forms\Components\Select::make('default_payment_gateway')
                                            ->label('بوابة الدفع الافتراضية')
                                            ->options([
                                                'stripe' => 'Stripe',
                                                'paymob' => 'Paymob',
                                                'paypal' => 'PayPal',
                                            ])
                                            ->default('stripe')
                                            ->required()
                                            ->helperText('البوابة التي ستظهر أولاً للمستخدمين'),

                                        Forms\Components\Grid::make(2)
                                            ->schema([
                                                Forms\Components\TextInput::make('minimum_payment_amount')
                                                    ->label('الحد الأدنى للدفع')
                                                    ->numeric()
                                                    ->default(1)
                                                    ->suffix('USD')
                                                    ->helperText('أقل مبلغ يمكن دفعه'),

                                                Forms\Components\TextInput::make('payment_processing_fee')
                                                    ->label('رسوم المعالجة (%)')
                                                    ->numeric()
                                                    ->default(2.9)
                                                    ->suffix('%')
                                                    ->helperText('رسوم إضافية على المعاملات'),

                                                Forms\Components\Toggle::make('enable_refunds')
                                                    ->label('تفعيل الاسترجاع')
                                                    ->default(true)
                                                    ->inline(false),

                                                Forms\Components\TextInput::make('refund_window_days')
                                                    ->label('فترة الاسترجاع (أيام)')
                                                    ->numeric()
                                                    ->default(14)
                                                    ->helperText('عدد الأيام المسموح فيها بالاسترجاع'),
                                            ]),
                                    ]),

                                Forms\Components\Section::make('إعدادات الأمان')
                                    ->schema([
                                        Forms\Components\Grid::make(2)
                                            ->schema([
                                                Forms\Components\Toggle::make('require_3d_secure')
                                                    ->label('طلب 3D Secure')
                                                    ->helperText('للمزيد من الأمان في المعاملات')
                                                    ->default(true)
                                                    ->inline(false),

                                                Forms\Components\Toggle::make('verify_cvv')
                                                    ->label('التحقق من CVV')
                                                    ->default(true)
                                                    ->inline(false),

                                                Forms\Components\Toggle::make('enable_fraud_detection')
                                                    ->label('تفعيل كشف الاحتيال')
                                                    ->default(true)
                                                    ->inline(false),

                                                Forms\Components\TextInput::make('max_failed_attempts')
                                                    ->label('عدد المحاولات الفاشلة المسموح بها')
                                                    ->numeric()
                                                    ->default(3),
                                            ]),
                                    ])
                                    ->collapsible(),

                                Forms\Components\Section::make('الإشعارات')
                                    ->schema([
                                        Forms\Components\Grid::make(2)
                                            ->schema([
                                                Forms\Components\Toggle::make('notify_successful_payment')
                                                    ->label('إشعار عند نجاح الدفع')
                                                    ->default(true)
                                                    ->inline(false),

                                                Forms\Components\Toggle::make('notify_failed_payment')
                                                    ->label('إشعار عند فشل الدفع')
                                                    ->default(true)
                                                    ->inline(false),

                                                Forms\Components\Toggle::make('notify_refund')
                                                    ->label('إشعار عند الاسترجاع')
                                                    ->default(true)
                                                    ->inline(false),

                                                Forms\Components\TextInput::make('payment_notification_email')
                                                    ->label('بريد إشعارات الدفع')
                                                    ->email()
                                                    ->default('payments@mediaprosocial.io'),
                                            ]),
                                    ])
                                    ->collapsible(),
                            ]),
                    ])
                    ->columnSpanFull(),
            ])
            ->statePath('data');
    }

    protected function getSettingsArray(): array
    {
        $settings = Setting::whereIn('key', [
            // Stripe
            'stripe_enabled', 'stripe_public_key', 'stripe_secret_key', 'stripe_webhook_secret',
            'stripe_currency', 'stripe_enable_apple_pay', 'stripe_enable_google_pay',
            'stripe_save_cards', 'stripe_test_mode',

            // Paymob
            'paymob_enabled', 'paymob_api_key', 'paymob_integration_id', 'paymob_iframe_id',
            'paymob_hmac_secret', 'paymob_currency', 'paymob_card_payment', 'paymob_wallet',
            'paymob_installments',

            // PayPal
            'paypal_enabled', 'paypal_client_id', 'paypal_client_secret', 'paypal_webhook_id',
            'paypal_mode', 'paypal_currency', 'paypal_enable_venmo', 'paypal_enable_credit',
            'paypal_brand_name',

            // Google Pay
            'google_pay_enabled', 'google_pay_merchant_id', 'google_pay_merchant_name',
            'google_pay_environment', 'google_pay_gateway', 'google_pay_gateway_merchant_id',
            'google_pay_billing_address_required', 'google_pay_shipping_address_required',
            'google_pay_email_required', 'google_pay_phone_required',
            'google_pay_button_color', 'google_pay_button_type',

            // Apple Pay
            'apple_pay_enabled', 'apple_pay_merchant_id', 'apple_pay_merchant_name',
            'apple_pay_country_code', 'apple_pay_currency_code', 'apple_pay_gateway',
            'apple_pay_require_billing', 'apple_pay_require_shipping',
            'apple_pay_require_email', 'apple_pay_require_phone',
            'apple_pay_button_style', 'apple_pay_button_type',

            // General
            'default_payment_gateway', 'minimum_payment_amount', 'payment_processing_fee',
            'enable_refunds', 'refund_window_days', 'require_3d_secure', 'verify_cvv',
            'enable_fraud_detection', 'max_failed_attempts', 'notify_successful_payment',
            'notify_failed_payment', 'notify_refund', 'payment_notification_email',
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
            'float' => (float) $value,
            default => $value,
        };
    }

    public function save(): void
    {
        $data = $this->form->getState();

        foreach ($data as $key => $value) {
            Setting::updateOrCreate(
                ['key' => $key],
                [
                    'value' => $value,
                    'type' => $this->detectType($value),
                    'group' => 'payment',
                    'is_public' => false, // Payment settings are private
                ]
            );
        }

        // Clear cache
        Cache::forget('app_config');
        Cache::forget('public_settings');
        Cache::forget('payment_settings');

        Notification::make()
            ->title('✅ تم الحفظ بنجاح')
            ->success()
            ->body('تم حفظ إعدادات الدفع بنجاح')
            ->send();
    }

    protected function detectType($value): string
    {
        if (is_bool($value)) return 'boolean';
        if (is_int($value)) return 'integer';
        if (is_float($value)) return 'float';
        return 'string';
    }

    protected function getFormActions(): array
    {
        return [
            Forms\Components\Actions\Action::make('save')
                ->label('حفظ إعدادات الدفع')
                ->action('save')
                ->icon('heroicon-o-check')
                ->color('success'),
        ];
    }
}
