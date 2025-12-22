<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SettingResource\Pages;
use App\Models\Setting;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class SettingResource extends Resource
{
    protected static ?string $model = Setting::class;

    protected static ?string $navigationIcon = 'heroicon-o-cog-6-tooth';

    protected static ?string $navigationGroup = 'Settings';

    protected static ?string $navigationLabel = 'الإعدادات العامة';

    protected static ?string $modelLabel = 'إعداد';

    protected static ?string $pluralModelLabel = 'الإعدادات';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make()
                    ->schema([
                        Forms\Components\TextInput::make('key')
                            ->label('المفتاح')
                            ->required()
                            ->maxLength(255)
                            ->unique(ignoreRecord: true),

                        Forms\Components\Select::make('group')
                            ->label('المجموعة')
                            ->options([
                                'general' => 'عام',
                                'app' => 'التطبيق',
                                'payment' => 'بوابات الدفع',
                                'sms' => 'خدمات الرسائل',
                                'email' => 'البريد الإلكتروني',
                                'social' => 'وسائل التواصل',
                                'ai' => 'خدمات الذكاء الاصطناعي',
                                'external' => 'الخدمات الخارجية',
                                'seo' => 'تحسين محركات البحث',
                                'firebase' => 'Firebase',
                            ])
                            ->required()
                            ->default('general'),

                        Forms\Components\Select::make('type')
                            ->label('النوع')
                            ->options([
                                'string' => 'نص',
                                'integer' => 'رقم صحيح',
                                'boolean' => 'منطقي',
                                'json' => 'JSON',
                                'array' => 'مصفوفة',
                            ])
                            ->required()
                            ->default('string')
                            ->reactive(),

                        Forms\Components\Textarea::make('value')
                            ->label('القيمة')
                            ->rows(3)
                            ->visible(fn ($get) => in_array($get('type'), ['string', 'integer', 'json', 'array'])),

                        Forms\Components\Toggle::make('value')
                            ->label('القيمة')
                            ->visible(fn ($get) => $get('type') === 'boolean'),

                        Forms\Components\Textarea::make('description')
                            ->label('الوصف')
                            ->rows(2),

                        Forms\Components\Toggle::make('is_public')
                            ->label('عام (يمكن الوصول إليه من API)')
                            ->default(false),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('key')
                    ->label('المفتاح')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('group')
                    ->label('المجموعة')
                    ->badge()
                    ->sortable(),

                Tables\Columns\TextColumn::make('type')
                    ->label('النوع')
                    ->badge()
                    ->color('gray'),

                Tables\Columns\TextColumn::make('value')
                    ->label('القيمة')
                    ->limit(50)
                    ->wrap(),

                Tables\Columns\IconColumn::make('is_public')
                    ->label('عام')
                    ->boolean(),

                Tables\Columns\TextColumn::make('updated_at')
                    ->label('آخر تحديث')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('group')
                    ->label('المجموعة')
                    ->options([
                        'general' => 'عام',
                        'app' => 'التطبيق',
                        'payment' => 'بوابات الدفع',
                        'sms' => 'خدمات الرسائل',
                        'email' => 'البريد الإلكتروني',
                        'social' => 'وسائل التواصل',
                        'ai' => 'خدمات الذكاء الاصطناعي',
                        'external' => 'الخدمات الخارجية',
                        'seo' => 'تحسين محركات البحث',
                        'firebase' => 'Firebase',
                    ]),

                Tables\Filters\SelectFilter::make('type')
                    ->label('النوع')
                    ->options([
                        'string' => 'نص',
                        'integer' => 'رقم صحيح',
                        'boolean' => 'منطقي',
                        'json' => 'JSON',
                        'array' => 'مصفوفة',
                    ]),

                Tables\Filters\TernaryFilter::make('is_public')
                    ->label('عام'),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListSettings::route('/'),
            'create' => Pages\CreateSetting::route('/create'),
            'edit' => Pages\EditSetting::route('/{record}/edit'),
        ];
    }
}
