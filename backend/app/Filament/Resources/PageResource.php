<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PageResource\Pages;
use App\Models\Page;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Support\Str;

class PageResource extends Resource
{
    protected static ?string $model = Page::class;

    protected static ?string $navigationIcon = 'heroicon-o-document-text';

    protected static ?string $navigationGroup = 'Content';

    protected static ?string $navigationLabel = 'الصفحات';

    protected static ?string $modelLabel = 'صفحة';

    protected static ?string $pluralModelLabel = 'الصفحات';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('المحتوى الأساسي')
                    ->schema([
                        Forms\Components\TextInput::make('title')
                            ->label('العنوان')
                            ->required()
                            ->maxLength(255)
                            ->live(onBlur: true)
                            ->afterStateUpdated(function (string $operation, $state, Forms\Set $set) {
                                if ($operation === 'create') {
                                    $set('slug', Str::slug($state));
                                }
                            }),

                        Forms\Components\TextInput::make('slug')
                            ->label('الرابط المختصر')
                            ->required()
                            ->maxLength(255)
                            ->unique(ignoreRecord: true)
                            ->helperText('سيتم استخدامه في URL الصفحة'),

                        Forms\Components\Textarea::make('excerpt')
                            ->label('مقتطف')
                            ->rows(3)
                            ->helperText('ملخص قصير للصفحة'),

                        Forms\Components\RichEditor::make('content')
                            ->label('المحتوى')
                            ->required()
                            ->columnSpanFull(),

                        Forms\Components\FileUpload::make('featured_image')
                            ->label('الصورة البارزة')
                            ->image()
                            ->directory('pages')
                            ->maxSize(2048),
                    ])->columns(2),

                Forms\Components\Section::make('إعدادات SEO')
                    ->schema([
                        Forms\Components\TextInput::make('meta_title')
                            ->label('عنوان SEO')
                            ->maxLength(60)
                            ->helperText('اتركه فارغاً لاستخدام العنوان الرئيسي'),

                        Forms\Components\Textarea::make('meta_description')
                            ->label('وصف SEO')
                            ->rows(3)
                            ->maxLength(160)
                            ->helperText('اتركه فارغاً لاستخدام المقتطف'),

                        Forms\Components\TextInput::make('meta_keywords')
                            ->label('الكلمات المفتاحية')
                            ->helperText('افصل الكلمات بفواصل'),
                    ])->columns(2)->collapsible(),

                Forms\Components\Section::make('إعدادات العرض')
                    ->schema([
                        Forms\Components\Select::make('template')
                            ->label('القالب')
                            ->options([
                                'default' => 'افتراضي',
                                'full-width' => 'عرض كامل',
                                'sidebar' => 'مع شريط جانبي',
                                'landing' => 'صفحة هبوط',
                            ])
                            ->default('default')
                            ->required(),

                        Forms\Components\Toggle::make('is_published')
                            ->label('منشور')
                            ->default(false),

                        Forms\Components\Toggle::make('show_in_menu')
                            ->label('إظهار في القائمة')
                            ->default(false),

                        Forms\Components\TextInput::make('menu_order')
                            ->label('ترتيب القائمة')
                            ->numeric()
                            ->default(0)
                            ->helperText('الأرقام الأصغر تظهر أولاً'),

                        Forms\Components\DateTimePicker::make('published_at')
                            ->label('تاريخ النشر')
                            ->nullable()
                            ->helperText('اتركه فارغاً للنشر فوراً'),
                    ])->columns(3),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('featured_image')
                    ->label('الصورة')
                    ->circular()
                    ->defaultImageUrl(url('/images/placeholder.png'))
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('title')
                    ->label('العنوان')
                    ->searchable()
                    ->sortable()
                    ->limit(30)
                    ->wrap(),

                Tables\Columns\TextColumn::make('slug')
                    ->label('الرابط')
                    ->searchable()
                    ->limit(25)
                    ->copyable()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('template')
                    ->label('القالب')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'default' => 'gray',
                        'full-width' => 'info',
                        'sidebar' => 'warning',
                        'landing' => 'success',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'default' => 'افتراضي',
                        'full-width' => 'عرض كامل',
                        'sidebar' => 'مع شريط',
                        'landing' => 'هبوط',
                        default => $state,
                    })
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\IconColumn::make('is_published')
                    ->label('منشور')
                    ->boolean(),

                Tables\Columns\IconColumn::make('show_in_menu')
                    ->label('في القائمة')
                    ->boolean()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('menu_order')
                    ->label('الترتيب')
                    ->sortable()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('published_at')
                    ->label('تاريخ النشر')
                    ->dateTime()
                    ->sortable()
                    ->since()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime()
                    ->sortable()
                    ->since()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_published')
                    ->label('منشور'),

                Tables\Filters\TernaryFilter::make('show_in_menu')
                    ->label('في القائمة'),

                Tables\Filters\SelectFilter::make('template')
                    ->label('القالب')
                    ->options([
                        'default' => 'افتراضي',
                        'full-width' => 'عرض كامل',
                        'sidebar' => 'مع شريط جانبي',
                        'landing' => 'صفحة هبوط',
                    ]),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
                Tables\Actions\Action::make('publish')
                    ->label('نشر')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->hidden(fn (Page $record) => $record->is_published)
                    ->action(fn (Page $record) => $record->publish())
                    ->requiresConfirmation(),
                Tables\Actions\Action::make('unpublish')
                    ->label('إلغاء النشر')
                    ->icon('heroicon-o-x-circle')
                    ->color('warning')
                    ->visible(fn (Page $record) => $record->is_published)
                    ->action(fn (Page $record) => $record->unpublish())
                    ->requiresConfirmation(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('menu_order')
            ->defaultSort('created_at', 'desc');
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListPages::route('/'),
            'create' => Pages\CreatePage::route('/create'),
            'edit' => Pages\EditPage::route('/{record}/edit'),
        ];
    }
}
