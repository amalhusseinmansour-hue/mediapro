<?php

namespace App\Filament\Resources;

use App\Filament\Resources\LanguageResource\Pages;
use App\Models\Language;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class LanguageResource extends Resource
{
    protected static ?string $model = Language::class;

    protected static ?string $navigationIcon = 'heroicon-o-language';

    protected static ?string $navigationGroup = 'System';

    protected static ?string $navigationLabel = 'اللغات';

    protected static ?string $modelLabel = 'لغة';

    protected static ?string $pluralModelLabel = 'اللغات';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make()
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('الاسم')
                            ->required()
                            ->maxLength(255)
                            ->placeholder('العربية'),

                        Forms\Components\TextInput::make('code')
                            ->label('الكود')
                            ->required()
                            ->maxLength(10)
                            ->unique(ignoreRecord: true)
                            ->placeholder('ar'),

                        Forms\Components\Select::make('direction')
                            ->label('الاتجاه')
                            ->options([
                                'ltr' => 'من اليسار لليمين (LTR)',
                                'rtl' => 'من اليمين لليسار (RTL)',
                            ])
                            ->required()
                            ->default('rtl'),

                        Forms\Components\TextInput::make('flag')
                            ->label('الراية')
                            ->maxLength(255)
                            ->placeholder('🇸🇦'),

                        Forms\Components\TextInput::make('sort_order')
                            ->label('الترتيب')
                            ->numeric()
                            ->default(0),

                        Forms\Components\Toggle::make('is_active')
                            ->label('نشط')
                            ->default(true),

                        Forms\Components\Toggle::make('is_default')
                            ->label('افتراضي')
                            ->default(false)
                            ->helperText('سيتم إلغاء تحديد جميع اللغات الأخرى كافتراضية'),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('flag')
                    ->label('')
                    ->size(Tables\Columns\TextColumn\TextColumnSize::Large),

                Tables\Columns\TextColumn::make('name')
                    ->label('الاسم')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('code')
                    ->label('الكود')
                    ->searchable()
                    ->badge(),

                Tables\Columns\TextColumn::make('direction')
                    ->label('الاتجاه')
                    ->badge()
                    ->color(fn (string $state): string => $state === 'rtl' ? 'success' : 'info'),

                Tables\Columns\IconColumn::make('is_default')
                    ->label('افتراضي')
                    ->boolean(),

                Tables\Columns\IconColumn::make('is_active')
                    ->label('نشط')
                    ->boolean(),

                Tables\Columns\TextColumn::make('sort_order')
                    ->label('الترتيب')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('نشط'),

                Tables\Filters\TernaryFilter::make('is_default')
                    ->label('افتراضي'),
            ])
            ->actions([
                Tables\Actions\Action::make('setDefault')
                    ->label('تعيين كافتراضي')
                    ->icon('heroicon-o-star')
                    ->color('warning')
                    ->visible(fn ($record) => !$record->is_default)
                    ->requiresConfirmation()
                    ->action(fn ($record) => $record->setAsDefault()),

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
            'index' => Pages\ListLanguages::route('/'),
            'create' => Pages\CreateLanguage::route('/create'),
            'edit' => Pages\EditLanguage::route('/{record}/edit'),
        ];
    }
}
