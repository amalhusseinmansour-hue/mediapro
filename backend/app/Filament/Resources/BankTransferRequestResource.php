<?php

namespace App\Filament\Resources;

use App\Filament\Resources\BankTransferRequestResource\Pages;
use App\Models\BankTransferRequest;
use App\Models\Wallet;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Infolists;
use Filament\Infolists\Infolist;
use Filament\Notifications\Notification;
use Illuminate\Support\Facades\Auth;

class BankTransferRequestResource extends Resource
{
    protected static ?string $model = BankTransferRequest::class;

    protected static ?string $navigationIcon = 'heroicon-o-banknotes';

    protected static ?string $navigationGroup = 'إدارة الطلبات';

    protected static ?string $navigationLabel = 'التحويلات البنكية';

    protected static ?string $modelLabel = 'طلب تحويل بنكي';

    protected static ?string $pluralModelLabel = 'طلبات الشحن البنكي';

    protected static ?int $navigationSort = 4;

    public static function getNavigationBadge(): ?string
    {
        try {
            return static::getModel()::where('status', 'pending')->count() ?: null;
        } catch (\Exception $e) {
            return null;
        }
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'info';
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
                            ->preload()
                            ->required()
                            ->disabled(fn ($operation) => $operation === 'edit'),
                    ]),

                Forms\Components\Section::make('تفاصيل التحويل')
                    ->schema([
                        Forms\Components\TextInput::make('amount')
                            ->label('المبلغ')
                            ->required()
                            ->numeric()
                            ->prefix('$')
                            ->step(0.01)
                            ->minValue(1),

                        Forms\Components\Select::make('currency')
                            ->label('العملة')
                            ->required()
                            ->default('USD')
                            ->options([
                                'USD' => 'دولار أمريكي',
                                'EUR' => 'يورو',
                                'SAR' => 'ريال سعودي',
                                'AED' => 'درهم إماراتي',
                                'EGP' => 'جنيه مصري',
                            ])
                            ->native(false),

                        Forms\Components\TextInput::make('sender_name')
                            ->label('اسم المرسل')
                            ->required()
                            ->maxLength(255),

                        Forms\Components\TextInput::make('sender_bank')
                            ->label('البنك المرسل')
                            ->required()
                            ->maxLength(255),

                        Forms\Components\TextInput::make('sender_account_number')
                            ->label('رقم الحساب')
                            ->maxLength(255),

                        Forms\Components\TextInput::make('transfer_reference')
                            ->label('رقم المرجع / الإيصال')
                            ->maxLength(255),

                        Forms\Components\DatePicker::make('transfer_date')
                            ->label('تاريخ التحويل')
                            ->required()
                            ->native(false),

                        Forms\Components\FileUpload::make('receipt_image')
                            ->label('صورة الإيصال')
                            ->image()
                            ->directory('bank-transfer-receipts')
                            ->visibility('private')
                            ->downloadable()
                            ->openable()
                            ->columnSpanFull(),
                    ])->columns(2),

                Forms\Components\Section::make('حالة الطلب')
                    ->schema([
                        Forms\Components\Select::make('status')
                            ->label('الحالة')
                            ->required()
                            ->default('pending')
                            ->options([
                                'pending' => 'معلق',
                                'approved' => 'مقبول',
                                'rejected' => 'مرفوض',
                            ])
                            ->native(false)
                            ->live()
                            ->afterStateUpdated(function ($state, $record, Forms\Set $set) {
                                if ($state === 'approved' && $record && $record->status !== 'approved') {
                                    $set('reviewed_by', Auth::id());
                                    $set('reviewed_at', now());
                                }
                            }),

                        Forms\Components\Textarea::make('admin_notes')
                            ->label('ملاحظات الإدارة')
                            ->rows(3)
                            ->columnSpanFull(),

                        Forms\Components\Placeholder::make('reviewed_info')
                            ->label('معلومات المراجعة')
                            ->content(function ($record) {
                                if (!$record || !$record->reviewed_by) {
                                    return 'لم تتم المراجعة بعد';
                                }
                                return sprintf(
                                    'تمت المراجعة بواسطة: %s في %s',
                                    $record->reviewer?->name ?? 'غير معروف',
                                    $record->reviewed_at?->format('Y-m-d H:i') ?? '-'
                                );
                            })
                            ->visible(fn ($record) => $record && $record->reviewed_by)
                            ->columnSpanFull(),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('الرقم')
                    ->sortable()
                    ->searchable(),

                Tables\Columns\TextColumn::make('user.name')
                    ->label('المستخدم')
                    ->searchable()
                    ->sortable()
                    ->weight('bold')
                    ->limit(25),

                Tables\Columns\TextColumn::make('sender_name')
                    ->label('اسم المرسل')
                    ->searchable()
                    ->limit(25),

                Tables\Columns\TextColumn::make('amount')
                    ->label('المبلغ')
                    ->money(fn ($record) => $record->currency ?? 'USD')
                    ->sortable()
                    ->weight('bold'),

                Tables\Columns\TextColumn::make('sender_bank')
                    ->label('البنك')
                    ->searchable()
                    ->limit(20)
                    ->toggleable(),

                Tables\Columns\TextColumn::make('transfer_date')
                    ->label('تاريخ التحويل')
                    ->date('Y-m-d')
                    ->sortable(),

                Tables\Columns\ImageColumn::make('receipt_image')
                    ->label('الإيصال')
                    ->circular()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('status')
                    ->label('الحالة')
                    ->badge()
                    ->color(fn ($state) => match($state) {
                        'pending' => 'warning',
                        'approved' => 'success',
                        'rejected' => 'danger',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn ($state) => match($state) {
                        'pending' => 'معلق',
                        'approved' => 'مقبول',
                        'rejected' => 'مرفوض',
                        default => $state,
                    })
                    ->sortable(),

                Tables\Columns\TextColumn::make('reviewer.name')
                    ->label('تمت المراجعة بواسطة')
                    ->default('لم تتم')
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime('Y-m-d')
                    ->sortable()
                    ->since()
                    ->toggleable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('الحالة')
                    ->options([
                        'pending' => 'معلق',
                        'approved' => 'مقبول',
                        'rejected' => 'مرفوض',
                    ])
                    ->native(false),

                Tables\Filters\Filter::make('transfer_date')
                    ->form([
                        Forms\Components\DatePicker::make('from')
                            ->label('من تاريخ'),
                        Forms\Components\DatePicker::make('until')
                            ->label('إلى تاريخ'),
                    ])
                    ->query(function ($query, array $data) {
                        return $query
                            ->when($data['from'], fn ($q, $date) => $q->whereDate('transfer_date', '>=', $date))
                            ->when($data['until'], fn ($q, $date) => $q->whereDate('transfer_date', '<=', $date));
                    }),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),

                Tables\Actions\Action::make('approve')
                    ->label('قبول')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->requiresConfirmation()
                    ->modalHeading('قبول طلب التحويل البنكي')
                    ->modalDescription(fn ($record) => "هل أنت متأكد من قبول طلب التحويل بمبلغ {$record->amount} {$record->currency}؟ سيتم شحن المحفظة تلقائياً.")
                    ->action(function (BankTransferRequest $record) {
                        if ($record->status === 'approved') {
                            Notification::make()
                                ->warning()
                                ->title('تم القبول مسبقاً')
                                ->body('هذا الطلب تم قبوله مسبقاً.')
                                ->send();
                            return;
                        }

                        // Update status
                        $record->update([
                            'status' => 'approved',
                            'reviewed_by' => Auth::id(),
                            'reviewed_at' => now(),
                        ]);

                        // Credit wallet
                        $wallet = Wallet::firstOrCreate(
                            ['user_id' => $record->user_id],
                            ['balance' => 0, 'currency' => $record->currency]
                        );

                        $wallet->credit(
                            $record->amount,
                            'bank_transfer',
                            "شحن محفظة عبر تحويل بنكي - رقم الطلب: {$record->id}",
                            ['bank_transfer_request_id' => $record->id]
                        );

                        Notification::make()
                            ->success()
                            ->title('تم قبول الطلب')
                            ->body("تم شحن المحفظة بمبلغ {$record->amount} {$record->currency}")
                            ->send();
                    })
                    ->visible(fn ($record) => $record->status === 'pending'),

                Tables\Actions\Action::make('reject')
                    ->label('رفض')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->requiresConfirmation()
                    ->form([
                        Forms\Components\Textarea::make('admin_notes')
                            ->label('سبب الرفض')
                            ->required()
                            ->rows(3),
                    ])
                    ->action(function (BankTransferRequest $record, array $data) {
                        $record->update([
                            'status' => 'rejected',
                            'reviewed_by' => Auth::id(),
                            'reviewed_at' => now(),
                            'admin_notes' => $data['admin_notes'],
                        ]);

                        Notification::make()
                            ->warning()
                            ->title('تم رفض الطلب')
                            ->body('تم رفض طلب التحويل البنكي')
                            ->send();
                    })
                    ->visible(fn ($record) => $record->status === 'pending'),

                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('created_at', 'desc');
    }

    public static function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                Infolists\Components\Section::make('معلومات المستخدم')
                    ->schema([
                        Infolists\Components\TextEntry::make('user.name')
                            ->label('المستخدم'),
                        Infolists\Components\TextEntry::make('user.email')
                            ->label('البريد الإلكتروني')
                            ->copyable(),
                    ])->columns(2),

                Infolists\Components\Section::make('تفاصيل التحويل')
                    ->schema([
                        Infolists\Components\TextEntry::make('amount')
                            ->label('المبلغ')
                            ->money('currency')
                            ->size('lg')
                            ->weight('bold'),
                        Infolists\Components\TextEntry::make('sender_name')
                            ->label('اسم المرسل'),
                        Infolists\Components\TextEntry::make('sender_bank')
                            ->label('البنك المرسل'),
                        Infolists\Components\TextEntry::make('sender_account_number')
                            ->label('رقم الحساب')
                            ->copyable(),
                        Infolists\Components\TextEntry::make('transfer_reference')
                            ->label('رقم المرجع')
                            ->copyable(),
                        Infolists\Components\TextEntry::make('transfer_date')
                            ->label('تاريخ التحويل')
                            ->date('Y-m-d'),
                        Infolists\Components\ImageEntry::make('receipt_image')
                            ->label('صورة الإيصال')
                            ->columnSpanFull(),
                    ])->columns(2),

                Infolists\Components\Section::make('حالة الطلب')
                    ->schema([
                        Infolists\Components\TextEntry::make('status')
                            ->label('الحالة')
                            ->badge(),
                        Infolists\Components\TextEntry::make('reviewer.name')
                            ->label('تمت المراجعة بواسطة')
                            ->default('لم تتم'),
                        Infolists\Components\TextEntry::make('reviewed_at')
                            ->label('تاريخ المراجعة')
                            ->dateTime()
                            ->placeholder('لم تتم'),
                        Infolists\Components\TextEntry::make('admin_notes')
                            ->label('ملاحظات الإدارة')
                            ->placeholder('لا توجد ملاحظات')
                            ->columnSpanFull(),
                        Infolists\Components\TextEntry::make('created_at')
                            ->label('تاريخ الإنشاء')
                            ->dateTime(),
                        Infolists\Components\TextEntry::make('updated_at')
                            ->label('آخر تحديث')
                            ->dateTime(),
                    ])->columns(2),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListBankTransferRequests::route('/'),
            'create' => Pages\CreateBankTransferRequest::route('/create'),
            'view' => Pages\ViewBankTransferRequest::route('/{record}'),
            'edit' => Pages\EditBankTransferRequest::route('/{record}/edit'),
        ];
    }
}
