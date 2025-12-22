<?php

namespace App\Filament\Resources;

use App\Filament\Resources\AutoScheduledPostResource\Pages;
use App\Models\ScheduledPost;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class AutoScheduledPostResource extends Resource
{
    protected static ?string $model = ScheduledPost::class;

    protected static ?string $navigationIcon = 'heroicon-o-calendar';

    protected static ?string $navigationLabel = 'المنشورات المجدولة';

    protected static ?string $navigationGroup = 'Content';

    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('معلومات المنشور')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->label('المستخدم')
                            ->relationship('user', 'name')
                            ->required()
                            ->searchable(),

                        Forms\Components\Textarea::make('content_text')
                            ->label('المحتوى')
                            ->required()
                            ->rows(5)
                            ->columnSpanFull(),

                        Forms\Components\FileUpload::make('media_urls')
                            ->label('الوسائط')
                            ->directory('scheduled-posts')
                            ->multiple()
                            ->maxFiles(10)
                            ->columnSpanFull(),

                        Forms\Components\TagsInput::make('platforms')
                            ->label('المنصات')
                            ->placeholder('اختر المنصات')
                            ->suggestions([
                                'facebook',
                                'instagram',
                                'twitter',
                                'linkedin',
                                'tiktok',
                                'youtube',
                            ])
                            ->columnSpanFull(),

                        Forms\Components\DateTimePicker::make('scheduled_at')
                            ->label('موعد النشر')
                            ->required()
                            ->native(false)
                            ->minDate(now()),

                        Forms\Components\Select::make('status')
                            ->label('الحالة')
                            ->options([
                                'pending' => 'معلق',
                                'sent' => 'مرسل',
                                'failed' => 'فشل',
                            ])
                            ->default('pending')
                            ->required(),

                        Forms\Components\TextInput::make('attempts')
                            ->label('عدد المحاولات')
                            ->numeric()
                            ->default(0)
                            ->disabled(),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('معلومات إضافية')
                    ->schema([
                        Forms\Components\Textarea::make('error_message')
                            ->label('رسالة الخطأ')
                            ->rows(3)
                            ->disabled()
                            ->columnSpanFull(),

                        Forms\Components\Placeholder::make('last_attempt_at')
                            ->label('آخر محاولة')
                            ->content(fn ($record) => $record?->last_attempt_at?->diffForHumans() ?? '-'),

                        Forms\Components\Placeholder::make('sent_at')
                            ->label('تاريخ الإرسال')
                            ->content(fn ($record) => $record?->sent_at?->diffForHumans() ?? '-'),
                    ])
                    ->columns(2)
                    ->collapsible()
                    ->hidden(fn ($livewire) => $livewire instanceof Pages\CreateAutoScheduledPost),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->label('المستخدم')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('content_text')
                    ->label('المحتوى')
                    ->searchable()
                    ->limit(50)
                    ->wrap()
                    ->sortable(),

                Tables\Columns\TagsColumn::make('platforms')
                    ->label('المنصات')
                    ->separator(','),

                Tables\Columns\BadgeColumn::make('status')
                    ->label('الحالة')
                    ->colors([
                        'warning' => 'pending',
                        'success' => 'sent',
                        'danger' => 'failed',
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'pending' => 'معلق',
                        'sent' => 'مرسل',
                        'failed' => 'فشل',
                        default => $state,
                    })
                    ->sortable(),

                Tables\Columns\TextColumn::make('scheduled_at')
                    ->label('موعد النشر')
                    ->dateTime('Y-m-d H:i')
                    ->sortable()
                    ->since(),

                Tables\Columns\TextColumn::make('sent_at')
                    ->label('تاريخ الإرسال')
                    ->dateTime('Y-m-d H:i')
                    ->sortable()
                    ->since()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('attempts')
                    ->label('المحاولات')
                    ->numeric()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime('Y-m-d H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('user')
                    ->relationship('user', 'name')
                    ->label('المستخدم'),

                Tables\Filters\SelectFilter::make('status')
                    ->label('الحالة')
                    ->options([
                        'pending' => 'معلق',
                        'sent' => 'مرسل',
                        'failed' => 'فشل',
                    ]),
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
            ->defaultSort('scheduled_at', 'asc');
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListAutoScheduledPosts::route('/'),
            'create' => Pages\CreateAutoScheduledPost::route('/create'),
            'view' => Pages\ViewAutoScheduledPost::route('/{record}'),
            'edit' => Pages\EditAutoScheduledPost::route('/{record}/edit'),
        ];
    }
}
