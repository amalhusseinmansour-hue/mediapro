<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SubscriptionPlanResource\Pages;
use App\Models\SubscriptionPlan;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class SubscriptionPlanResource extends Resource
{
    protected static ?string $model = SubscriptionPlan::class;

    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';

    protected static ?string $navigationGroup = 'إدارة الاشتراكات';

    protected static ?string $navigationLabel = 'خطط الاشتراكات';

    protected static ?string $modelLabel = 'خطة اشتراك';

    protected static ?string $pluralModelLabel = 'خطط الاشتراكات';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('المعلومات الأساسية')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('اسم الخطة')
                            ->required()
                            ->maxLength(255),

                        Forms\Components\TextInput::make('slug')
                            ->label('الرمز')
                            ->required()
                            ->maxLength(255)
                            ->unique(ignoreRecord: true),

                        Forms\Components\Textarea::make('description')
                            ->label('الوصف')
                            ->rows(3),

                        Forms\Components\Select::make('type')
                            ->label('النوع')
                            ->options([
                                'monthly' => 'شهري',
                                'yearly' => 'سنوي',
                                'lifetime' => 'مدى الحياة',
                            ])
                            ->required(),

                        Forms\Components\TextInput::make('price')
                            ->label('السعر')
                            ->required()
                            ->numeric()
                            ->prefix('$'),

                        Forms\Components\TextInput::make('currency')
                            ->label('العملة')
                            ->default('USD')
                            ->maxLength(3),
                    ])->columns(2),

                Forms\Components\Section::make('الميزات')
                    ->schema([
                        Forms\Components\TextInput::make('max_accounts')
                            ->label('عدد الحسابات')
                            ->required()
                            ->numeric()
                            ->default(0),

                        Forms\Components\TextInput::make('max_posts')
                            ->label('عدد المنشورات')
                            ->required()
                            ->numeric()
                            ->default(0),

                        Forms\Components\Toggle::make('ai_features')
                            ->label('ميزات الذكاء الاصطناعي'),

                        Forms\Components\Toggle::make('analytics')
                            ->label('التحليلات'),

                        Forms\Components\Toggle::make('scheduling')
                            ->label('الجدولة'),

                        Forms\Components\KeyValue::make('features')
                            ->label('ميزات إضافية'),
                    ])->columns(2),

                Forms\Components\Section::make('إعدادات العرض')
                    ->schema([
                        Forms\Components\Toggle::make('is_popular')
                            ->label('شعبية'),

                        Forms\Components\Toggle::make('is_active')
                            ->label('نشط')
                            ->default(true),

                        Forms\Components\TextInput::make('sort_order')
                            ->label('الترتيب')
                            ->numeric()
                            ->default(0),
                    ])->columns(3),

                Forms\Components\Section::make('معرفات بوابات الدفع')
                    ->schema([
                        Forms\Components\TextInput::make('stripe_price_id')
                            ->label('معرف سعر Stripe')
                            ->maxLength(255),

                        Forms\Components\TextInput::make('paypal_plan_id')
                            ->label('معرف خطة PayPal')
                            ->maxLength(255),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('الاسم')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('type')
                    ->label('النوع')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'monthly' => 'info',
                        'yearly' => 'success',
                        'lifetime' => 'warning',
                    }),

                Tables\Columns\TextColumn::make('price')
                    ->label('السعر')
                    ->money('USD')
                    ->sortable(),

                Tables\Columns\IconColumn::make('is_popular')
                    ->label('شعبية')
                    ->boolean(),

                Tables\Columns\IconColumn::make('is_active')
                    ->label('نشط')
                    ->boolean(),

                Tables\Columns\TextColumn::make('sort_order')
                    ->label('الترتيب')
                    ->sortable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('type')
                    ->label('النوع')
                    ->options([
                        'monthly' => 'شهري',
                        'yearly' => 'سنوي',
                        'lifetime' => 'مدى الحياة',
                    ]),

                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('نشط'),

                Tables\Filters\TernaryFilter::make('is_popular')
                    ->label('شعبية'),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('sort_order');
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListSubscriptionPlans::route('/'),
            'create' => Pages\CreateSubscriptionPlan::route('/create'),
            'edit' => Pages\EditSubscriptionPlan::route('/{record}/edit'),
        ];
    }
}
