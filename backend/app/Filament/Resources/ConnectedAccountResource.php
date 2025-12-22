<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ConnectedAccountResource\Pages;
use App\Models\ConnectedAccount;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class ConnectedAccountResource extends Resource
{
    protected static ?string $model = ConnectedAccount::class;

    protected static ?string $navigationIcon = 'heroicon-o-link';

    protected static ?string $navigationLabel = 'حسابات المستخدمين المربوطة';

    protected static ?string $modelLabel = 'حساب مربوط';

    protected static ?string $pluralModelLabel = 'الحسابات المربوطة';

    protected static ?string $navigationGroup = 'المستخدمين';

    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('معلومات الحساب')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->label('المستخدم')
                            ->relationship('user', 'name')
                            ->searchable()
                            ->preload()
                            ->required()
                            ->columnSpanFull(),

                        Forms\Components\Select::make('platform')
                            ->label('المنصة')
                            ->options([
                                'facebook' => 'Facebook',
                                'instagram' => 'Instagram',
                                'twitter' => 'Twitter (X)',
                                'linkedin' => 'LinkedIn',
                                'tiktok' => 'TikTok',
                                'youtube' => 'YouTube',
                                'pinterest' => 'Pinterest',
                                'telegram' => 'Telegram',
                            ])
                            ->required()
                            ->searchable(),

                        Forms\Components\TextInput::make('platform_user_id')
                            ->label('معرف المستخدم في المنصة')
                            ->maxLength(255),

                        Forms\Components\TextInput::make('username')
                            ->label('اسم المستخدم')
                            ->maxLength(255),

                        Forms\Components\TextInput::make('display_name')
                            ->label('الاسم المعروض')
                            ->maxLength(255),

                        Forms\Components\TextInput::make('email')
                            ->label('البريد الإلكتروني')
                            ->email()
                            ->maxLength(255),

                        Forms\Components\FileUpload::make('profile_picture')
                            ->label('صورة الملف الشخصي')
                            ->image()
                            ->maxSize(2048)
                            ->columnSpanFull(),
                    ])->columns(2),

                Forms\Components\Section::make('معلومات الاتصال')
                    ->schema([
                        Forms\Components\Textarea::make('access_token')
                            ->label('Access Token')
                            ->rows(3)
                            ->columnSpanFull()
                            ->password()
                            ->revealable(),

                        Forms\Components\Textarea::make('refresh_token')
                            ->label('Refresh Token')
                            ->rows(3)
                            ->columnSpanFull()
                            ->password()
                            ->revealable(),

                        Forms\Components\DateTimePicker::make('token_expires_at')
                            ->label('تاريخ انتهاء الـ Token'),

                        Forms\Components\TagsInput::make('scopes')
                            ->label('الصلاحيات (Scopes)')
                            ->placeholder('أضف صلاحية')
                            ->columnSpanFull(),

                        Forms\Components\Toggle::make('is_active')
                            ->label('الحساب نشط')
                            ->default(true),

                        Forms\Components\DateTimePicker::make('connected_at')
                            ->label('تاريخ الربط')
                            ->default(now()),

                        Forms\Components\DateTimePicker::make('last_used_at')
                            ->label('آخر استخدام')
                            ->disabled(),
                    ])->columns(2),

                Forms\Components\Section::make('بيانات إضافية')
                    ->schema([
                        Forms\Components\KeyValue::make('metadata')
                            ->label('بيانات إضافية (Metadata)')
                            ->keyLabel('المفتاح')
                            ->valueLabel('القيمة')
                            ->columnSpanFull(),
                    ])->collapsible(),
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

                Tables\Columns\TextColumn::make('platform')
                    ->label('المنصة')
                    ->badge()
                    ->color(fn (ConnectedAccount $record): string => match ($record->platform) {
                        'facebook' => 'info',
                        'instagram' => 'danger',
                        'twitter' => 'primary',
                        'linkedin' => 'info',
                        'tiktok' => 'gray',
                        'youtube' => 'danger',
                        'pinterest' => 'danger',
                        'telegram' => 'primary',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'facebook' => '📘 Facebook',
                        'instagram' => '📸 Instagram',
                        'twitter' => '🐦 Twitter',
                        'linkedin' => '💼 LinkedIn',
                        'tiktok' => '🎵 TikTok',
                        'youtube' => '📺 YouTube',
                        'pinterest' => '📌 Pinterest',
                        'telegram' => '✈️ Telegram',
                        default => ucfirst($state),
                    })
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('username')
                    ->label('اسم المستخدم')
                    ->searchable()
                    ->copyable()
                    ->copyMessage('تم نسخ اسم المستخدم'),

                Tables\Columns\TextColumn::make('display_name')
                    ->label('الاسم المعروض')
                    ->searchable()
                    ->limit(30),

                Tables\Columns\ImageColumn::make('profile_picture')
                    ->label('الصورة')
                    ->circular()
                    ->defaultImageUrl(fn () => 'https://ui-avatars.com/api/?name=User'),

                Tables\Columns\IconColumn::make('is_active')
                    ->label('نشط')
                    ->boolean()
                    ->trueIcon('heroicon-o-check-circle')
                    ->falseIcon('heroicon-o-x-circle')
                    ->trueColor('success')
                    ->falseColor('danger'),

                Tables\Columns\TextColumn::make('token_expires_at')
                    ->label('انتهاء Token')
                    ->dateTime('Y-m-d H:i')
                    ->sortable()
                    ->color(fn (ConnectedAccount $record): string =>
                        $record->isTokenExpired() ? 'danger' : 'success'
                    )
                    ->icon(fn (ConnectedAccount $record): string =>
                        $record->isTokenExpired() ? 'heroicon-o-exclamation-triangle' : 'heroicon-o-check-circle'
                    )
                    ->tooltip(fn (ConnectedAccount $record): string =>
                        $record->isTokenExpired() ? 'Token منتهي - يحتاج تجديد' : 'Token صالح'
                    ),

                Tables\Columns\TextColumn::make('connected_at')
                    ->label('تاريخ الربط')
                    ->dateTime('Y-m-d H:i')
                    ->sortable()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('last_used_at')
                    ->label('آخر استخدام')
                    ->dateTime('Y-m-d H:i')
                    ->sortable()
                    ->since()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime('Y-m-d H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('platform')
                    ->label('المنصة')
                    ->options([
                        'facebook' => 'Facebook',
                        'instagram' => 'Instagram',
                        'twitter' => 'Twitter (X)',
                        'linkedin' => 'LinkedIn',
                        'tiktok' => 'TikTok',
                        'youtube' => 'YouTube',
                        'pinterest' => 'Pinterest',
                        'telegram' => 'Telegram',
                    ])
                    ->multiple(),

                Tables\Filters\SelectFilter::make('user')
                    ->label('المستخدم')
                    ->relationship('user', 'name')
                    ->searchable()
                    ->preload()
                    ->multiple(),

                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('الحالة')
                    ->placeholder('الكل')
                    ->trueLabel('نشط')
                    ->falseLabel('غير نشط'),

                Tables\Filters\Filter::make('token_expired')
                    ->label('Token منتهي')
                    ->query(fn (Builder $query): Builder => $query->where('token_expires_at', '<', now()))
                    ->toggle(),

                Tables\Filters\Filter::make('recently_used')
                    ->label('مستخدم مؤخراً')
                    ->query(fn (Builder $query): Builder => $query->where('last_used_at', '>=', now()->subDays(7)))
                    ->toggle(),
            ])
            ->actions([
                Tables\Actions\ActionGroup::make([
                    Tables\Actions\ViewAction::make()
                        ->label('عرض'),

                    Tables\Actions\EditAction::make()
                        ->label('تعديل'),

                    Tables\Actions\Action::make('toggle_active')
                        ->label(fn (ConnectedAccount $record): string =>
                            $record->is_active ? 'تعطيل' : 'تفعيل'
                        )
                        ->icon(fn (ConnectedAccount $record): string =>
                            $record->is_active ? 'heroicon-o-x-circle' : 'heroicon-o-check-circle'
                        )
                        ->color(fn (ConnectedAccount $record): string =>
                            $record->is_active ? 'warning' : 'success'
                        )
                        ->requiresConfirmation()
                        ->action(fn (ConnectedAccount $record) =>
                            $record->update(['is_active' => !$record->is_active])
                        ),

                    Tables\Actions\Action::make('refresh_token')
                        ->label('تحديث Token')
                        ->icon('heroicon-o-arrow-path')
                        ->color('info')
                        ->form([
                            Forms\Components\Textarea::make('access_token')
                                ->label('Access Token الجديد')
                                ->required()
                                ->rows(3),
                            Forms\Components\Textarea::make('refresh_token')
                                ->label('Refresh Token الجديد')
                                ->rows(3),
                            Forms\Components\DateTimePicker::make('token_expires_at')
                                ->label('تاريخ الانتهاء الجديد')
                                ->required(),
                        ])
                        ->action(function (ConnectedAccount $record, array $data): void {
                            $record->update($data);
                        }),

                    Tables\Actions\DeleteAction::make()
                        ->label('حذف'),
                ]),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\BulkAction::make('activate')
                        ->label('تفعيل المحدد')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->requiresConfirmation()
                        ->action(fn ($records) => $records->each->update(['is_active' => true])),

                    Tables\Actions\BulkAction::make('deactivate')
                        ->label('تعطيل المحدد')
                        ->icon('heroicon-o-x-circle')
                        ->color('warning')
                        ->requiresConfirmation()
                        ->action(fn ($records) => $records->each->update(['is_active' => false])),

                    Tables\Actions\DeleteBulkAction::make()
                        ->label('حذف المحدد'),
                ]),
            ])
            ->defaultSort('created_at', 'desc')
            ->poll('30s'); // Auto refresh every 30 seconds
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
            'index' => Pages\ListConnectedAccounts::route('/'),
            'create' => Pages\CreateConnectedAccount::route('/create'),
            'view' => Pages\ViewConnectedAccount::route('/{record}'),
            'edit' => Pages\EditConnectedAccount::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::active()->count();
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'success';
    }
}
