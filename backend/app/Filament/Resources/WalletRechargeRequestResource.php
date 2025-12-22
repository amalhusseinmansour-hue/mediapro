<?php

namespace App\Filament\Resources;

use App\Filament\Resources\WalletRechargeRequestResource\Pages;
use App\Models\WalletRechargeRequest;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Notifications\Notification;
use Illuminate\Database\Eloquent\Builder;

class WalletRechargeRequestResource extends Resource
{
    protected static ?string $model = WalletRechargeRequest::class;

    protected static ?string $navigationIcon = 'heroicon-o-banknotes';

    protected static ?string $navigationLabel = 'طلبات شحن المحفظة';

    protected static ?string $modelLabel = 'طلب شحن';

    protected static ?string $pluralModelLabel = 'طلبات الشحن';

    protected static ?string $navigationGroup = 'المحفظة والمدفوعات';

    protected static ?int $navigationSort = 2;

    public static function getNavigationBadge(): ?string
    {
        try {
            return static::getModel()::pending()->count();
        } catch (\Exception $e) {
            return null;
        }
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'warning';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('معلومات المستخدم')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->label('المستخدم')
                            ->relationship('user', 'name')
                            ->searchable()
                            ->required()
                            ->disabled(fn (?WalletRechargeRequest $record) => $record !== null),
                    ]),

                Forms\Components\Section::make('تفاصيل الطلب')
                    ->schema([
                        Forms\Components\TextInput::make('amount')
                            ->label('المبلغ')
                            ->numeric()
                            ->required()
                            ->suffix('ريال')
                            ->disabled(fn (?WalletRechargeRequest $record) => $record !== null),

                        Forms\Components\Select::make('currency')
                            ->label('العملة')
                            ->options([
                                'SAR' => 'ريال سعودي',
                                'AED' => 'درهم إماراتي',
                                'USD' => 'دولار أمريكي',
                            ])
                            ->default('SAR')
                            ->required()
                            ->disabled(fn (?WalletRechargeRequest $record) => $record !== null),

                        Forms\Components\TextInput::make('payment_method')
                            ->label('طريقة الدفع')
                            ->maxLength(255)
                            ->disabled(fn (?WalletRechargeRequest $record) => $record !== null),

                        Forms\Components\TextInput::make('bank_name')
                            ->label('اسم البنك')
                            ->maxLength(255)
                            ->disabled(fn (?WalletRechargeRequest $record) => $record !== null),

                        Forms\Components\TextInput::make('transaction_reference')
                            ->label('رقم المرجع')
                            ->maxLength(255)
                            ->disabled(fn (?WalletRechargeRequest $record) => $record !== null),

                        Forms\Components\Textarea::make('notes')
                            ->label('ملاحظات المستخدم')
                            ->rows(3)
                            ->disabled(fn (?WalletRechargeRequest $record) => $record !== null),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('الإيصال')
                    ->schema([
                        Forms\Components\FileUpload::make('receipt_image')
                            ->label('صورة الإيصال')
                            ->image()
                            ->directory('wallet_receipts')
                            ->visibility('public')
                            ->disabled(fn (?WalletRechargeRequest $record) => $record !== null)
                            ->downloadable()
                            ->openable(),
                    ]),

                Forms\Components\Section::make('حالة الطلب')
                    ->schema([
                        Forms\Components\Select::make('status')
                            ->label('الحالة')
                            ->options([
                                'pending' => 'قيد الانتظار',
                                'approved' => 'مقبول',
                                'rejected' => 'مرفوض',
                            ])
                            ->required()
                            ->disabled(),

                        Forms\Components\Textarea::make('admin_notes')
                            ->label('ملاحظات الإدارة')
                            ->rows(3),

                        Forms\Components\Select::make('processed_by')
                            ->label('تمت المعالجة بواسطة')
                            ->relationship('processedBy', 'name')
                            ->disabled(),

                        Forms\Components\DateTimePicker::make('processed_at')
                            ->label('تاريخ المعالجة')
                            ->disabled(),
                    ])
                    ->columns(2)
                    ->visible(fn (?WalletRechargeRequest $record) => $record !== null),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('رقم الطلب')
                    ->sortable()
                    ->searchable(),

                Tables\Columns\TextColumn::make('user.name')
                    ->label('المستخدم')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('user.phone_number')
                    ->label('رقم الهاتف')
                    ->searchable(),

                Tables\Columns\TextColumn::make('amount')
                    ->label('المبلغ')
                    ->money('SAR')
                    ->sortable(),

                Tables\Columns\TextColumn::make('payment_method')
                    ->label('طريقة الدفع')
                    ->searchable()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('bank_name')
                    ->label('البنك')
                    ->searchable()
                    ->toggleable(),

                Tables\Columns\ImageColumn::make('receipt_image')
                    ->label('الإيصال')
                    ->disk('public')
                    ->square()
                    ->toggleable(),

                Tables\Columns\BadgeColumn::make('status')
                    ->label('الحالة')
                    ->colors([
                        'warning' => 'pending',
                        'success' => 'approved',
                        'danger' => 'rejected',
                    ])
                    ->formatStateUsing(fn (string $state): string => match($state) {
                        'pending' => 'قيد الانتظار',
                        'approved' => 'مقبول',
                        'rejected' => 'مرفوض',
                        default => $state,
                    })
                    ->sortable(),

                Tables\Columns\TextColumn::make('processedBy.name')
                    ->label('تمت المعالجة بواسطة')
                    ->toggleable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الطلب')
                    ->dateTime('Y-m-d H:i')
                    ->sortable(),

                Tables\Columns\TextColumn::make('processed_at')
                    ->label('تاريخ المعالجة')
                    ->dateTime('Y-m-d H:i')
                    ->sortable()
                    ->toggleable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('الحالة')
                    ->options([
                        'pending' => 'قيد الانتظار',
                        'approved' => 'مقبول',
                        'rejected' => 'مرفوض',
                    ]),

                Tables\Filters\Filter::make('created_at')
                    ->form([
                        Forms\Components\DatePicker::make('created_from')
                            ->label('من تاريخ'),
                        Forms\Components\DatePicker::make('created_until')
                            ->label('إلى تاريخ'),
                    ])
                    ->query(function (Builder $query, array $data): Builder {
                        return $query
                            ->when(
                                $data['created_from'],
                                fn (Builder $query, $date): Builder => $query->whereDate('created_at', '>=', $date),
                            )
                            ->when(
                                $data['created_until'],
                                fn (Builder $query, $date): Builder => $query->whereDate('created_at', '<=', $date),
                            );
                    }),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),

                Tables\Actions\Action::make('approve')
                    ->label('قبول')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->requiresConfirmation()
                    ->modalHeading('قبول طلب الشحن')
                    ->modalDescription('هل أنت متأكد من قبول هذا الطلب؟ سيتم إضافة المبلغ إلى محفظة المستخدم.')
                    ->form([
                        Forms\Components\Textarea::make('admin_notes')
                            ->label('ملاحظات الإدارة (اختياري)')
                            ->rows(3),
                    ])
                    ->action(function (WalletRechargeRequest $record, array $data) {
                        $admin = auth()->user();

                        if ($record->approve($admin->id, $data['admin_notes'] ?? null)) {
                            Notification::make()
                                ->title('تم قبول الطلب بنجاح')
                                ->success()
                                ->send();
                        } else {
                            Notification::make()
                                ->title('فشل قبول الطلب')
                                ->danger()
                                ->send();
                        }
                    })
                    ->visible(fn (WalletRechargeRequest $record): bool => $record->isPending()),

                Tables\Actions\Action::make('reject')
                    ->label('رفض')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->requiresConfirmation()
                    ->modalHeading('رفض طلب الشحن')
                    ->modalDescription('هل أنت متأكد من رفض هذا الطلب؟')
                    ->form([
                        Forms\Components\Textarea::make('admin_notes')
                            ->label('سبب الرفض (اختياري)')
                            ->rows(3),
                    ])
                    ->action(function (WalletRechargeRequest $record, array $data) {
                        $admin = auth()->user();

                        if ($record->reject($admin->id, $data['admin_notes'] ?? null)) {
                            Notification::make()
                                ->title('تم رفض الطلب')
                                ->success()
                                ->send();
                        } else {
                            Notification::make()
                                ->title('فشل رفض الطلب')
                                ->danger()
                                ->send();
                        }
                    })
                    ->visible(fn (WalletRechargeRequest $record): bool => $record->isPending()),
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
            'index' => Pages\ListWalletRechargeRequests::route('/'),
            'view' => Pages\ViewWalletRechargeRequest::route('/{record}'),
        ];
    }

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->with(['user', 'processedBy']);
    }
}
