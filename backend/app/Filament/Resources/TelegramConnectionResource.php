<?php

namespace App\Filament\Resources;

use App\Filament\Resources\TelegramConnectionResource\Pages;
use App\Models\TelegramConnection;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Infolists;
use Filament\Infolists\Infolist;

class TelegramConnectionResource extends Resource
{
    protected static ?string $model = TelegramConnection::class;

    protected static ?string $navigationIcon = 'heroicon-o-chat-bubble-left-right';

    protected static ?string $navigationGroup = 'Content';

    protected static ?string $navigationLabel = 'اتصالات Telegram';

    protected static ?string $modelLabel = 'اتصال Telegram';

    protected static ?string $pluralModelLabel = 'اتصالات Telegram';

    protected static ?int $navigationSort = 11;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('معلومات الاتصال')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->label('المستخدم')
                            ->relationship('user', 'name')
                            ->required()
                            ->searchable(),

                        Forms\Components\TextInput::make('chat_id')
                            ->label('Chat ID')
                            ->required()
                            ->unique(ignoreRecord: true),

                        Forms\Components\TextInput::make('username')
                            ->label('Username')
                            ->prefixIcon('heroicon-o-at-symbol'),

                        Forms\Components\TextInput::make('first_name')
                            ->label('الاسم الأول'),

                        Forms\Components\TextInput::make('last_name')
                            ->label('الاسم الأخير'),

                        Forms\Components\Toggle::make('is_active')
                            ->label('نشط')
                            ->default(true),

                        Forms\Components\Toggle::make('notifications_enabled')
                            ->label('الإشعارات مفعلة')
                            ->default(true),

                        Forms\Components\Select::make('language')
                            ->label('اللغة')
                            ->options([
                                'ar' => 'العربية',
                                'en' => 'English',
                            ])
                            ->default('ar'),

                        Forms\Components\KeyValue::make('preferences')
                            ->label('التفضيلات')
                            ->columnSpanFull(),

                        Forms\Components\DateTimePicker::make('last_interaction_at')
                            ->label('آخر تفاعل')
                            ->disabled(),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('#')
                    ->sortable(),

                Tables\Columns\TextColumn::make('user.name')
                    ->label('المستخدم')
                    ->searchable()
                    ->sortable()
                    ->limit(20),

                Tables\Columns\TextColumn::make('full_name')
                    ->label('الاسم')
                    ->searchable(['first_name', 'last_name', 'username'])
                    ->limit(25),

                Tables\Columns\TextColumn::make('username')
                    ->label('Username')
                    ->searchable()
                    ->prefix('@')
                    ->limit(20)
                    ->toggleable(),

                Tables\Columns\TextColumn::make('chat_id')
                    ->label('Chat ID')
                    ->searchable()
                    ->copyable()
                    ->toggleable(),

                Tables\Columns\IconColumn::make('is_active')
                    ->label('نشط')
                    ->boolean()
                    ->sortable(),

                Tables\Columns\IconColumn::make('notifications_enabled')
                    ->label('الإشعارات')
                    ->boolean()
                    ->sortable()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('language')
                    ->label('اللغة')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match($state) {
                        'ar' => 'العربية',
                        'en' => 'English',
                        default => $state,
                    })
                    ->color(fn (string $state): string => match($state) {
                        'ar' => 'success',
                        'en' => 'info',
                        default => 'gray',
                    })
                    ->toggleable(),

                Tables\Columns\TextColumn::make('last_interaction_at')
                    ->label('آخر تفاعل')
                    ->dateTime()
                    ->since()
                    ->sortable()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime()
                    ->since()
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('نشط')
                    ->placeholder('الكل')
                    ->trueLabel('النشطة فقط')
                    ->falseLabel('غير النشطة فقط'),

                Tables\Filters\TernaryFilter::make('notifications_enabled')
                    ->label('الإشعارات')
                    ->placeholder('الكل')
                    ->trueLabel('مفعلة')
                    ->falseLabel('معطلة'),

                Tables\Filters\SelectFilter::make('language')
                    ->label('اللغة')
                    ->options([
                        'ar' => 'العربية',
                        'en' => 'English',
                    ]),

                Tables\Filters\SelectFilter::make('user_id')
                    ->label('المستخدم')
                    ->relationship('user', 'name')
                    ->searchable(),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\ViewAction::make(),
                Tables\Actions\DeleteAction::make(),

                Tables\Actions\Action::make('toggle_active')
                    ->label(fn (TelegramConnection $record) => $record->is_active ? 'تعطيل' : 'تفعيل')
                    ->icon(fn (TelegramConnection $record) => $record->is_active ? 'heroicon-o-x-circle' : 'heroicon-o-check-circle')
                    ->color(fn (TelegramConnection $record) => $record->is_active ? 'danger' : 'success')
                    ->requiresConfirmation()
                    ->action(fn (TelegramConnection $record) => $record->update(['is_active' => !$record->is_active])),

                Tables\Actions\Action::make('toggle_notifications')
                    ->label('الإشعارات')
                    ->icon('heroicon-o-bell')
                    ->color(fn (TelegramConnection $record) => $record->notifications_enabled ? 'warning' : 'success')
                    ->requiresConfirmation()
                    ->action(function (TelegramConnection $record) {
                        $record->notifications_enabled ? $record->disableNotifications() : $record->enableNotifications();
                    }),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),

                    Tables\Actions\BulkAction::make('enable_all')
                        ->label('تفعيل المحددة')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->requiresConfirmation()
                        ->action(fn ($records) => $records->each->update(['is_active' => true])),

                    Tables\Actions\BulkAction::make('disable_all')
                        ->label('تعطيل المحددة')
                        ->icon('heroicon-o-x-circle')
                        ->color('danger')
                        ->requiresConfirmation()
                        ->action(fn ($records) => $records->each->update(['is_active' => false])),
                ]),
            ])
            ->defaultSort('created_at', 'desc');
    }

    public static function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                Infolists\Components\Section::make('معلومات الاتصال')
                    ->schema([
                        Infolists\Components\TextEntry::make('user.name')
                            ->label('المستخدم'),

                        Infolists\Components\TextEntry::make('full_name')
                            ->label('الاسم الكامل'),

                        Infolists\Components\TextEntry::make('username')
                            ->label('Username')
                            ->prefix('@'),

                        Infolists\Components\TextEntry::make('chat_id')
                            ->label('Chat ID')
                            ->copyable(),

                        Infolists\Components\IconEntry::make('is_active')
                            ->label('نشط')
                            ->boolean(),

                        Infolists\Components\IconEntry::make('notifications_enabled')
                            ->label('الإشعارات')
                            ->boolean(),

                        Infolists\Components\TextEntry::make('language')
                            ->label('اللغة')
                            ->badge()
                            ->formatStateUsing(fn (string $state): string => match($state) {
                                'ar' => 'العربية',
                                'en' => 'English',
                                default => $state,
                            })
                            ->color(fn (string $state): string => match($state) {
                                'ar' => 'success',
                                'en' => 'info',
                                default => 'gray',
                            }),

                        Infolists\Components\TextEntry::make('last_interaction_at')
                            ->label('آخر تفاعل')
                            ->dateTime(),

                        Infolists\Components\TextEntry::make('created_at')
                            ->label('تاريخ الإنشاء')
                            ->dateTime(),

                        Infolists\Components\TextEntry::make('updated_at')
                            ->label('تاريخ التحديث')
                            ->dateTime(),
                    ])->columns(2),

                Infolists\Components\Section::make('التفضيلات')
                    ->schema([
                        Infolists\Components\KeyValueEntry::make('preferences')
                            ->label(''),
                    ])
                    ->collapsible()
                    ->collapsed()
                    ->visible(fn (TelegramConnection $record) => $record->preferences),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListTelegramConnections::route('/'),
            'create' => Pages\CreateTelegramConnection::route('/create'),
            'edit' => Pages\EditTelegramConnection::route('/{record}/edit'),
            'view' => Pages\ViewTelegramConnection::route('/{record}'),
        ];
    }
}
