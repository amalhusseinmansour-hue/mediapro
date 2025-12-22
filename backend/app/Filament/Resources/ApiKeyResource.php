<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ApiKeyResource\Pages;
use App\Models\ApiKey;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Notifications\Notification;

class ApiKeyResource extends Resource
{
    protected static ?string $model = ApiKey::class;

    protected static ?string $navigationIcon = 'heroicon-o-key';

    protected static ?string $navigationGroup = 'System';

    protected static ?string $navigationLabel = 'مفاتيح API';

    protected static ?string $modelLabel = 'مفتاح API';

    protected static ?string $pluralModelLabel = 'مفاتيح API';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('معلومات المفتاح')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->label('المستخدم')
                            ->options(User::pluck('name', 'id'))
                            ->searchable()
                            ->nullable()
                            ->helperText('اختياري - اربط المفتاح بمستخدم معين'),

                        Forms\Components\TextInput::make('name')
                            ->label('اسم المفتاح')
                            ->required()
                            ->maxLength(255)
                            ->placeholder('مفتاح التطبيق الرئيسي'),

                        Forms\Components\Textarea::make('description')
                            ->label('الوصف')
                            ->rows(3)
                            ->placeholder('وصف استخدام هذا المفتاح...'),

                        Forms\Components\TextInput::make('key')
                            ->label('المفتاح')
                            ->disabled()
                            ->dehydrated(false)
                            ->placeholder('سيتم توليده تلقائياً')
                            ->helperText('سيتم إنشاء المفتاح تلقائياً عند الحفظ')
                            ->hidden(fn ($operation) => $operation === 'create'),
                    ])->columns(2),

                Forms\Components\Section::make('الصلاحيات والقيود')
                    ->schema([
                        Forms\Components\TagsInput::make('permissions')
                            ->label('الصلاحيات')
                            ->placeholder('أضف صلاحية')
                            ->helperText('اتركها فارغة للسماح بجميع الصلاحيات، أو أضف "*" للكل')
                            ->suggestions([
                                'users.read',
                                'users.write',
                                'subscriptions.read',
                                'subscriptions.write',
                                'payments.read',
                                'pages.read',
                                'notifications.read',
                                '*',
                            ]),

                        Forms\Components\TagsInput::make('allowed_ips')
                            ->label('عناوين IP المسموح بها')
                            ->placeholder('192.168.1.1')
                            ->helperText('اتركها فارغة للسماح من جميع العناوين'),

                        Forms\Components\TextInput::make('rate_limit')
                            ->label('حد الطلبات (في الدقيقة)')
                            ->numeric()
                            ->default(60)
                            ->required()
                            ->minValue(1)
                            ->maxValue(1000)
                            ->suffix('طلب/دقيقة'),

                        Forms\Components\DateTimePicker::make('expires_at')
                            ->label('تاريخ الانتهاء')
                            ->nullable()
                            ->helperText('اتركه فارغاً إذا كان المفتاح لا ينتهي'),
                    ])->columns(2),

                Forms\Components\Section::make('الحالة')
                    ->schema([
                        Forms\Components\Toggle::make('is_active')
                            ->label('نشط')
                            ->default(true)
                            ->inline(false),
                    ]),

                Forms\Components\Section::make('إحصائيات الاستخدام')
                    ->schema([
                        Forms\Components\Placeholder::make('total_requests')
                            ->label('إجمالي الطلبات')
                            ->content(fn ($record) => $record ? number_format($record->total_requests) : '0'),

                        Forms\Components\Placeholder::make('last_used_at')
                            ->label('آخر استخدام')
                            ->content(fn ($record) => $record?->last_used_at ? $record->last_used_at->diffForHumans() : 'لم يستخدم بعد'),

                        Forms\Components\Placeholder::make('created_at')
                            ->label('تاريخ الإنشاء')
                            ->content(fn ($record) => $record?->created_at?->format('Y-m-d H:i:s') ?? '-'),
                    ])->columns(3)->visible(fn ($operation) => $operation === 'edit'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('الاسم')
                    ->searchable()
                    ->sortable()
                    ->weight('bold')
                    ->limit(25)
                    ->wrap(),

                Tables\Columns\TextColumn::make('user.name')
                    ->label('المستخدم')
                    ->searchable()
                    ->sortable()
                    ->default('غير محدد')
                    ->limit(20)
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('masked_key')
                    ->label('المفتاح')
                    ->copyable()
                    ->copyMessage('تم نسخ المفتاح!')
                    ->copyMessageDuration(1500)
                    ->tooltip('انقر للنسخ')
                    ->limit(25),

                Tables\Columns\IconColumn::make('is_active')
                    ->label('نشط')
                    ->boolean(),

                Tables\Columns\TextColumn::make('total_requests')
                    ->label('الطلبات')
                    ->numeric()
                    ->sortable()
                    ->badge()
                    ->color('info'),

                Tables\Columns\TextColumn::make('rate_limit')
                    ->label('الحد')
                    ->suffix('/دقيقة')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('last_used_at')
                    ->label('آخر استخدام')
                    ->dateTime()
                    ->since()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('expires_at')
                    ->label('الانتهاء')
                    ->dateTime()
                    ->sortable()
                    ->badge()
                    ->color(fn ($record) => $record->expires_at && $record->expires_at->isPast() ? 'danger' : 'success')
                    ->formatStateUsing(fn ($state) => $state ? $state->format('Y-m-d') : 'لا ينتهي')
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime()
                    ->since()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('نشط'),

                Tables\Filters\Filter::make('expired')
                    ->label('منتهي')
                    ->query(fn ($query) => $query->expired()),

                Tables\Filters\SelectFilter::make('user_id')
                    ->label('المستخدم')
                    ->options(User::pluck('name', 'id'))
                    ->searchable(),
            ])
            ->actions([
                Tables\Actions\Action::make('copy_key')
                    ->label('نسخ المفتاح')
                    ->icon('heroicon-o-clipboard')
                    ->color('gray')
                    ->action(function (ApiKey $record) {
                        Notification::make()
                            ->title('المفتاح الكامل')
                            ->body($record->key)
                            ->persistent()
                            ->send();
                    }),
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
            'index' => Pages\ListApiKeys::route('/'),
            'create' => Pages\CreateApiKey::route('/create'),
            'edit' => Pages\EditApiKey::route('/{record}/edit'),
        ];
    }
}
