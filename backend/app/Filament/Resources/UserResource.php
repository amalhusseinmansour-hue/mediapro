<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UserResource\Pages;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Support\Facades\Hash;

class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static ?string $navigationIcon = 'heroicon-o-users';

    protected static ?string $navigationGroup = 'النظام';

    protected static ?string $navigationLabel = 'المستخدمون';

    protected static ?string $modelLabel = 'مستخدم';

    protected static ?string $pluralModelLabel = 'المستخدمون';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('معلومات المستخدم')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('الاسم')
                            ->required()
                            ->maxLength(255),

                        Forms\Components\TextInput::make('email')
                            ->label('البريد الإلكتروني')
                            ->email()
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->maxLength(255),

                        Forms\Components\TextInput::make('password')
                            ->label('كلمة المرور')
                            ->password()
                            ->required(fn ($operation) => $operation === 'create')
                            ->dehydrateStateUsing(fn ($state) => $state ? Hash::make($state) : null)
                            ->dehydrated(fn ($state) => filled($state))
                            ->maxLength(255)
                            ->helperText('اتركها فارغة إذا كنت لا تريد تغييرها'),

                        Forms\Components\Toggle::make('is_admin')
                            ->label('مدير النظام')
                            ->default(false)
                            ->helperText('المدراء لديهم صلاحية الوصول الكامل'),

                        Forms\Components\DateTimePicker::make('email_verified_at')
                            ->label('تاريخ التحقق من البريد')
                            ->nullable(),
                    ])->columns(2),

                Forms\Components\Section::make('الاشتراكات والأرباح')
                    ->schema([
                        Forms\Components\Placeholder::make('subscriptions_count')
                            ->label('عدد الاشتراكات')
                            ->content(fn ($record) => $record ? $record->subscriptions()->count() : 0),

                        Forms\Components\Placeholder::make('earnings_total')
                            ->label('إجمالي الأرباح')
                            ->content(fn ($record) => $record ? number_format($record->earnings()->sum('amount'), 2) . ' USD' : '0.00 USD'),

                        Forms\Components\Placeholder::make('payments_count')
                            ->label('عدد المدفوعات')
                            ->content(fn ($record) => $record ? $record->payments()->count() : 0),
                    ])->columns(3)->visible(fn ($operation) => $operation === 'edit'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('الرقم')
                    ->sortable()
                    ->searchable()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('name')
                    ->label('الاسم')
                    ->searchable()
                    ->sortable()
                    ->weight('bold')
                    ->limit(30)
                    ->wrap(),

                Tables\Columns\TextColumn::make('email')
                    ->label('البريد الإلكتروني')
                    ->searchable()
                    ->sortable()
                    ->copyable()
                    ->limit(40),

                Tables\Columns\IconColumn::make('is_admin')
                    ->label('مدير')
                    ->boolean()
                    ->toggleable(),

                Tables\Columns\IconColumn::make('email_verified_at')
                    ->label('تم التحقق')
                    ->boolean()
                    ->getStateUsing(fn ($record) => $record->email_verified_at !== null)
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('subscriptions_count')
                    ->label('الاشتراكات')
                    ->counts('subscriptions')
                    ->badge()
                    ->color('info'),

                Tables\Columns\TextColumn::make('earnings_sum_amount')
                    ->label('الأرباح')
                    ->sum('earnings', 'amount')
                    ->money('USD')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ التسجيل')
                    ->dateTime()
                    ->sortable()
                    ->since()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_admin')
                    ->label('مدير النظام'),

                Tables\Filters\TernaryFilter::make('email_verified_at')
                    ->label('تم التحقق')
                    ->nullable(),

                Tables\Filters\Filter::make('has_subscriptions')
                    ->label('لديه اشتراكات')
                    ->query(fn ($query) => $query->has('subscriptions')),
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
            'index' => Pages\ListUsers::route('/'),
            'create' => Pages\CreateUser::route('/create'),
            'edit' => Pages\EditUser::route('/{record}/edit'),
        ];
    }
}
