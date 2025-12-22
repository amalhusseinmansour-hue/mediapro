<?php

namespace App\Filament\Resources;

use App\Filament\Resources\CommunityPostResource\Pages;
use App\Models\CommunityPost;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class CommunityPostResource extends Resource
{
    protected static ?string $model = CommunityPost::class;

    protected static ?string $navigationIcon = 'heroicon-o-chat-bubble-left-right';

    protected static ?string $navigationLabel = 'منشورات المجتمع';

    protected static ?string $navigationGroup = 'Content';

    protected static ?int $navigationSort = 3;

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

                        Forms\Components\Textarea::make('content')
                            ->label('المحتوى')
                            ->required()
                            ->rows(5)
                            ->columnSpanFull(),

                        Forms\Components\FileUpload::make('media_urls')
                            ->label('الوسائط')
                            ->image()
                            ->multiple()
                            ->directory('community-posts')
                            ->maxSize(5120)
                            ->maxFiles(10),

                        Forms\Components\TagsInput::make('tags')
                            ->label('الوسوم')
                            ->placeholder('أدخل الوسوم')
                            ->columnSpanFull(),

                        Forms\Components\Select::make('visibility')
                            ->label('الخصوصية')
                            ->options([
                                'public' => 'عام',
                                'private' => 'خاص',
                                'followers' => 'المتابعون فقط',
                            ])
                            ->default('public')
                            ->required(),

                        Forms\Components\Toggle::make('is_pinned')
                            ->label('تثبيت المنشور')
                            ->default(false),

                        Forms\Components\DateTimePicker::make('published_at')
                            ->label('تاريخ النشر')
                            ->native(false),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('الإحصائيات')
                    ->schema([
                        Forms\Components\Placeholder::make('media_count')
                            ->label('عدد الوسائط')
                            ->content(fn ($record) => $record?->media_count ?? 0),

                        Forms\Components\Placeholder::make('created_at')
                            ->label('تاريخ الإنشاء')
                            ->content(fn ($record) => $record?->created_at?->diffForHumans() ?? '-'),

                        Forms\Components\Placeholder::make('updated_at')
                            ->label('آخر تحديث')
                            ->content(fn ($record) => $record?->updated_at?->diffForHumans() ?? '-'),
                    ])
                    ->columns(3)
                    ->hidden(fn ($livewire) => $livewire instanceof Pages\CreateCommunityPost),
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

                Tables\Columns\TextColumn::make('content')
                    ->label('المحتوى')
                    ->searchable()
                    ->limit(60)
                    ->wrap()
                    ->sortable(),

                Tables\Columns\BadgeColumn::make('visibility')
                    ->label('الخصوصية')
                    ->colors([
                        'success' => 'public',
                        'warning' => 'followers',
                        'danger' => 'private',
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'public' => 'عام',
                        'private' => 'خاص',
                        'followers' => 'المتابعون',
                        default => $state,
                    }),

                Tables\Columns\IconColumn::make('is_pinned')
                    ->label('مثبت')
                    ->boolean()
                    ->sortable(),

                Tables\Columns\TextColumn::make('media_count')
                    ->label('الوسائط')
                    ->badge()
                    ->color('info'),

                Tables\Columns\TextColumn::make('published_at')
                    ->label('تاريخ النشر')
                    ->dateTime('Y-m-d H:i')
                    ->sortable()
                    ->since(),

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

                Tables\Filters\SelectFilter::make('visibility')
                    ->label('الخصوصية')
                    ->options([
                        'public' => 'عام',
                        'private' => 'خاص',
                        'followers' => 'المتابعون',
                    ]),

                Tables\Filters\TernaryFilter::make('is_pinned')
                    ->label('المثبت'),
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

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListCommunityPosts::route('/'),
            'create' => Pages\CreateCommunityPost::route('/create'),
            'view' => Pages\ViewCommunityPost::route('/{record}'),
            'edit' => Pages\EditCommunityPost::route('/{record}/edit'),
        ];
    }
}
