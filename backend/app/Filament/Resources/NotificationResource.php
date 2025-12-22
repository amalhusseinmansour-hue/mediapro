<?php

namespace App\Filament\Resources;

use App\Filament\Resources\NotificationResource\Pages;
use App\Models\Notification;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class NotificationResource extends Resource
{
    protected static ?string $model = Notification::class;

    protected static ?string $navigationIcon = 'heroicon-o-bell';

    protected static ?string $navigationGroup = 'System';

    protected static ?string $navigationLabel = 'الإشعارات';

    protected static ?string $modelLabel = 'إشعار';

    protected static ?string $pluralModelLabel = 'الإشعارات';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('معلومات الإشعار')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->label('المستخدم')
                            ->options(User::pluck('name', 'id'))
                            ->searchable()
                            ->nullable()
                            ->helperText('اتركه فارغاً للإشعارات العامة'),

                        Forms\Components\Select::make('type')
                            ->label('النوع')
                            ->options([
                                'info' => 'معلومة',
                                'success' => 'نجاح',
                                'warning' => 'تحذير',
                                'error' => 'خطأ',
                                'subscription' => 'اشتراك',
                                'payment' => 'دفع',
                            ])
                            ->required()
                            ->default('info'),

                        Forms\Components\TextInput::make('title')
                            ->label('العنوان')
                            ->required()
                            ->maxLength(255),

                        Forms\Components\Textarea::make('message')
                            ->label('الرسالة')
                            ->required()
                            ->rows(3),
                    ])->columns(2),

                Forms\Components\Section::make('إعدادات إضافية')
                    ->schema([
                        Forms\Components\TextInput::make('action_url')
                            ->label('رابط الإجراء')
                            ->url()
                            ->maxLength(255),

                        Forms\Components\TextInput::make('action_text')
                            ->label('نص زر الإجراء')
                            ->maxLength(255),

                        Forms\Components\TextInput::make('icon')
                            ->label('أيقونة')
                            ->maxLength(255),

                        Forms\Components\KeyValue::make('data')
                            ->label('بيانات إضافية'),
                    ])->columns(2),

                Forms\Components\Section::make('حالة الإشعار')
                    ->schema([
                        Forms\Components\Toggle::make('is_global')
                            ->label('إشعار عام لجميع المستخدمين')
                            ->default(false),

                        Forms\Components\Toggle::make('is_read')
                            ->label('مقروء')
                            ->default(false),

                        Forms\Components\DateTimePicker::make('expires_at')
                            ->label('تاريخ انتهاء الصلاحية')
                            ->nullable(),
                    ])->columns(3),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->label('المستخدم')
                    ->searchable()
                    ->sortable()
                    ->default('إشعار عام')
                    ->icon(fn ($record) => $record->is_global ? 'heroicon-o-globe-alt' : null)
                    ->limit(20)
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('type')
                    ->label('النوع')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'info' => 'info',
                        'success' => 'success',
                        'warning' => 'warning',
                        'error' => 'danger',
                        'subscription' => 'purple',
                        'payment' => 'green',
                        default => 'gray',
                    }),

                Tables\Columns\TextColumn::make('title')
                    ->label('العنوان')
                    ->searchable()
                    ->limit(30)
                    ->wrap(),

                Tables\Columns\TextColumn::make('message')
                    ->label('الرسالة')
                    ->limit(40)
                    ->wrap()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\IconColumn::make('is_read')
                    ->label('مقروء')
                    ->boolean(),

                Tables\Columns\IconColumn::make('is_global')
                    ->label('عام')
                    ->boolean()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime()
                    ->sortable()
                    ->since(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('type')
                    ->label('النوع')
                    ->options([
                        'info' => 'معلومة',
                        'success' => 'نجاح',
                        'warning' => 'تحذير',
                        'error' => 'خطأ',
                        'subscription' => 'اشتراك',
                        'payment' => 'دفع',
                    ]),

                Tables\Filters\TernaryFilter::make('is_read')
                    ->label('مقروء'),

                Tables\Filters\TernaryFilter::make('is_global')
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
            ])
            ->defaultSort('created_at', 'desc');
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListNotifications::route('/'),
            'create' => Pages\CreateNotification::route('/create'),
            'edit' => Pages\EditNotification::route('/{record}/edit'),
        ];
    }
}
