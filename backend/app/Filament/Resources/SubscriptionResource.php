<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SubscriptionResource\Pages;
use App\Models\Subscription;
use App\Models\User;
use App\Models\SubscriptionPlan;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class SubscriptionResource extends Resource
{
    protected static ?string $model = Subscription::class;

    protected static ?string $navigationIcon = 'heroicon-o-credit-card';

    protected static ?string $navigationGroup = 'الاشتراكات';

    protected static ?string $navigationLabel = 'الاشتراكات';

    protected static ?string $modelLabel = 'اشتراك';

    protected static ?string $pluralModelLabel = 'الاشتراكات';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('معلومات الاشتراك')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->label('المستخدم')
                            ->relationship('user', 'name')
                            ->searchable()
                            ->required(),

                        Forms\Components\TextInput::make('name')
                            ->label('اسم الخطة')
                            ->required()
                            ->maxLength(255),

                        Forms\Components\Select::make('type')
                            ->label('نوع الخطة')
                            ->options([
                                'free' => 'مجاني',
                                'basic' => 'أساسي',
                                'pro' => 'احترافي',
                                'business' => 'الأعمال',
                            ])
                            ->required()
                            ->default('free'),

                        Forms\Components\TextInput::make('price')
                            ->label('السعر')
                            ->numeric()
                            ->prefix('$')
                            ->default(0)
                            ->required(),

                        Forms\Components\Select::make('status')
                            ->label('الحالة')
                            ->options([
                                'active' => 'نشط',
                                'cancelled' => 'ملغي',
                                'expired' => 'منتهي',
                                'pending' => 'معلق',
                            ])
                            ->required()
                            ->default('pending'),

                        Forms\Components\TextInput::make('currency')
                            ->label('العملة')
                            ->default('USD')
                            ->maxLength(3)
                            ->required(),
                    ])->columns(2),

                Forms\Components\Section::make('التواريخ')
                    ->schema([
                        Forms\Components\DateTimePicker::make('starts_at')
                            ->label('تاريخ البدء')
                            ->required()
                            ->default(now()),

                        Forms\Components\DateTimePicker::make('ends_at')
                            ->label('تاريخ الانتهاء')
                            ->required(),

                        Forms\Components\DateTimePicker::make('trial_ends_at')
                            ->label('تاريخ انتهاء التجربة')
                            ->nullable(),

                        Forms\Components\DateTimePicker::make('cancelled_at')
                            ->label('تاريخ الإلغاء')
                            ->nullable(),
                    ])->columns(2),

                Forms\Components\Section::make('المميزات')
                    ->schema([
                        Forms\Components\TextInput::make('max_accounts')
                            ->label('الحد الأقصى للحسابات')
                            ->numeric()
                            ->default(1)
                            ->required(),

                        Forms\Components\TextInput::make('max_posts')
                            ->label('الحد الأقصى للمنشورات')
                            ->numeric()
                            ->default(10)
                            ->required(),

                        Forms\Components\Toggle::make('ai_features')
                            ->label('مميزات الذكاء الاصطناعي')
                            ->default(false),

                        Forms\Components\Toggle::make('analytics')
                            ->label('التحليلات')
                            ->default(false),

                        Forms\Components\Toggle::make('scheduling')
                            ->label('الجدولة')
                            ->default(true),
                    ])->columns(3),

                Forms\Components\Section::make('معلومات إضافية')
                    ->schema([
                        Forms\Components\Placeholder::make('created_at')
                            ->label('تاريخ الإنشاء')
                            ->content(fn ($record) => $record?->created_at?->diffForHumans() ?? '-'),

                        Forms\Components\Placeholder::make('updated_at')
                            ->label('آخر تحديث')
                            ->content(fn ($record) => $record?->updated_at?->diffForHumans() ?? '-'),
                    ])->columns(2)->visible(fn ($operation) => $operation === 'edit'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('#')
                    ->sortable()
                    ->searchable()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('user.name')
                    ->label('المستخدم')
                    ->searchable()
                    ->sortable()
                    ->limit(20)
                    ->wrap(),

                Tables\Columns\TextColumn::make('name')
                    ->label('اسم الخطة')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('type')
                    ->label('النوع')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'free' => 'gray',
                        'basic' => 'info',
                        'pro' => 'warning',
                        'business' => 'success',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'free' => 'مجاني',
                        'basic' => 'أساسي',
                        'pro' => 'احترافي',
                        'business' => 'الأعمال',
                        default => $state,
                    }),

                Tables\Columns\TextColumn::make('price')
                    ->label('السعر')
                    ->money('USD')
                    ->sortable(),

                Tables\Columns\TextColumn::make('status')
                    ->label('الحالة')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'active' => 'success',
                        'cancelled' => 'danger',
                        'expired' => 'warning',
                        'pending' => 'info',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'active' => 'نشط',
                        'cancelled' => 'ملغي',
                        'expired' => 'منتهي',
                        'pending' => 'معلق',
                        default => $state,
                    }),

                Tables\Columns\IconColumn::make('ai_features')
                    ->label('AI')
                    ->boolean()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\IconColumn::make('analytics')
                    ->label('تحليلات')
                    ->boolean()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\IconColumn::make('scheduling')
                    ->label('جدولة')
                    ->boolean()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('starts_at')
                    ->label('البدء')
                    ->date()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('ends_at')
                    ->label('الانتهاء')
                    ->date()
                    ->sortable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->since()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('الحالة')
                    ->options([
                        'active' => 'نشط',
                        'cancelled' => 'ملغي',
                        'expired' => 'منتهي',
                        'pending' => 'معلق',
                    ]),

                Tables\Filters\SelectFilter::make('type')
                    ->label('النوع')
                    ->options([
                        'free' => 'مجاني',
                        'basic' => 'أساسي',
                        'pro' => 'احترافي',
                        'business' => 'الأعمال',
                    ]),

                Tables\Filters\TernaryFilter::make('ai_features')
                    ->label('مميزات AI'),

                Tables\Filters\Filter::make('active')
                    ->label('النشطة فقط')
                    ->query(fn ($query) => $query->where('status', 'active')),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('created_at', 'desc');
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListSubscriptions::route('/'),
            'create' => Pages\CreateSubscription::route('/create'),
            'view' => Pages\ViewSubscription::route('/{record}'),
            'edit' => Pages\EditSubscription::route('/{record}/edit'),
        ];
    }
}
