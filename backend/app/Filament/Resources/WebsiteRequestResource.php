<?php

namespace App\Filament\Resources;

use App\Filament\Resources\WebsiteRequestResource\Pages;
use App\Models\WebsiteRequest;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Infolists;
use Filament\Infolists\Infolist;

class WebsiteRequestResource extends Resource
{
    protected static ?string $model = WebsiteRequest::class;

    protected static ?string $navigationIcon = 'heroicon-o-globe-alt';

    protected static ?string $navigationGroup = 'إدارة الطلبات';

    protected static ?string $navigationLabel = 'طلبات المواقع';

    protected static ?string $modelLabel = 'طلب موقع';

    protected static ?string $pluralModelLabel = 'طلبات المواقع الإلكترونية';

    protected static ?int $navigationSort = 1;

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
                            ->preload()
                            ->nullable(),

                        Forms\Components\TextInput::make('name')
                            ->label('الاسم')
                            ->required()
                            ->maxLength(255),

                        Forms\Components\TextInput::make('email')
                            ->label('البريد الإلكتروني')
                            ->email()
                            ->required()
                            ->maxLength(255),

                        Forms\Components\TextInput::make('phone')
                            ->label('رقم الهاتف')
                            ->tel()
                            ->maxLength(20),

                        Forms\Components\TextInput::make('company_name')
                            ->label('اسم الشركة')
                            ->maxLength(255),
                    ])->columns(2),

                Forms\Components\Section::make('تفاصيل الموقع')
                    ->schema([
                        Forms\Components\Select::make('website_type')
                            ->label('نوع الموقع')
                            ->required()
                            ->options([
                                'corporate' => 'موقع شركة',
                                'ecommerce' => 'متجر إلكتروني',
                                'blog' => 'مدونة',
                                'portfolio' => 'معرض أعمال',
                                'landing_page' => 'صفحة هبوط',
                                'custom' => 'مخصص',
                            ])
                            ->native(false),

                        Forms\Components\TextInput::make('budget')
                            ->label('الميزانية')
                            ->required()
                            ->numeric()
                            ->prefix('$')
                            ->step(0.01),

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

                        Forms\Components\DatePicker::make('deadline')
                            ->label('الموعد النهائي')
                            ->native(false),

                        Forms\Components\Textarea::make('description')
                            ->label('الوصف')
                            ->required()
                            ->rows(4)
                            ->columnSpanFull(),

                        Forms\Components\Textarea::make('features')
                            ->label('المميزات المطلوبة')
                            ->helperText('اذكر المميزات المطلوبة (كل ميزة في سطر جديد)')
                            ->rows(4)
                            ->columnSpanFull(),
                    ])->columns(2),

                Forms\Components\Section::make('حالة الطلب')
                    ->schema([
                        Forms\Components\Select::make('status')
                            ->label('الحالة')
                            ->required()
                            ->default('pending')
                            ->options([
                                'pending' => 'قيد الانتظار',
                                'reviewing' => 'قيد المراجعة',
                                'accepted' => 'مقبول',
                                'rejected' => 'مرفوض',
                                'completed' => 'مكتمل',
                            ])
                            ->native(false),

                        Forms\Components\Textarea::make('admin_notes')
                            ->label('ملاحظات الإدارة')
                            ->rows(3)
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

                Tables\Columns\TextColumn::make('name')
                    ->label('الاسم')
                    ->searchable()
                    ->sortable()
                    ->weight('bold')
                    ->limit(25),

                Tables\Columns\TextColumn::make('email')
                    ->label('البريد')
                    ->searchable()
                    ->copyable()
                    ->limit(30)
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('company_name')
                    ->label('الشركة')
                    ->searchable()
                    ->limit(25)
                    ->toggleable(),

                Tables\Columns\TextColumn::make('website_type')
                    ->label('نوع الموقع')
                    ->formatStateUsing(fn ($state) => match($state) {
                        'corporate' => 'موقع شركة',
                        'ecommerce' => 'متجر إلكتروني',
                        'blog' => 'مدونة',
                        'portfolio' => 'معرض أعمال',
                        'landing_page' => 'صفحة هبوط',
                        'custom' => 'مخصص',
                        default => $state,
                    })
                    ->badge()
                    ->color(fn ($state) => match($state) {
                        'corporate' => 'primary',
                        'ecommerce' => 'success',
                        'blog' => 'info',
                        'portfolio' => 'warning',
                        default => 'gray',
                    })
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('budget')
                    ->label('الميزانية')
                    ->money(fn ($record) => $record->currency ?? 'USD')
                    ->sortable(),

                Tables\Columns\TextColumn::make('deadline')
                    ->label('الموعد النهائي')
                    ->date('Y-m-d')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('status')
                    ->label('الحالة')
                    ->badge()
                    ->color(fn ($state) => match($state) {
                        'pending' => 'warning',
                        'reviewing' => 'info',
                        'accepted' => 'success',
                        'rejected' => 'danger',
                        'completed' => 'primary',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn ($state) => match($state) {
                        'pending' => 'قيد الانتظار',
                        'reviewing' => 'قيد المراجعة',
                        'accepted' => 'مقبول',
                        'rejected' => 'مرفوض',
                        'completed' => 'مكتمل',
                        default => $state,
                    })
                    ->sortable(),

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
                        'pending' => 'قيد الانتظار',
                        'reviewing' => 'قيد المراجعة',
                        'accepted' => 'مقبول',
                        'rejected' => 'مرفوض',
                        'completed' => 'مكتمل',
                    ])
                    ->native(false),

                Tables\Filters\SelectFilter::make('website_type')
                    ->label('نوع الموقع')
                    ->options([
                        'corporate' => 'موقع شركة',
                        'ecommerce' => 'متجر إلكتروني',
                        'blog' => 'مدونة',
                        'portfolio' => 'معرض أعمال',
                        'landing_page' => 'صفحة هبوط',
                        'custom' => 'مخصص',
                    ])
                    ->native(false),
            ])
            ->actions([
                Tables\Actions\ActionGroup::make([
                    Tables\Actions\ViewAction::make(),
                    Tables\Actions\EditAction::make(),
                    Tables\Actions\Action::make('accept')
                        ->label('قبول')
                        ->icon('heroicon-m-check-circle')
                        ->color('success')
                        ->requiresConfirmation()
                        ->action(fn (WebsiteRequest $record) => $record->update(['status' => 'accepted']))
                        ->visible(fn (WebsiteRequest $record) => $record->status === 'pending'),
                    Tables\Actions\Action::make('reject')
                        ->label('رفض')
                        ->icon('heroicon-m-x-circle')
                        ->color('danger')
                        ->requiresConfirmation()
                        ->form([
                            Forms\Components\Textarea::make('admin_notes')
                                ->label('سبب الرفض')
                                ->required()
                                ->rows(3),
                        ])
                        ->action(function (WebsiteRequest $record, array $data) {
                            $record->update([
                                'status' => 'rejected',
                                'admin_notes' => $data['admin_notes'],
                            ]);
                        })
                        ->visible(fn (WebsiteRequest $record) => $record->status === 'pending'),
                    Tables\Actions\Action::make('start_reviewing')
                        ->label('بدء المراجعة')
                        ->icon('heroicon-m-eye')
                        ->color('info')
                        ->requiresConfirmation()
                        ->action(fn (WebsiteRequest $record) => $record->update(['status' => 'reviewing']))
                        ->visible(fn (WebsiteRequest $record) => $record->status === 'pending'),
                    Tables\Actions\Action::make('complete')
                        ->label('إكمال')
                        ->icon('heroicon-m-check-badge')
                        ->color('success')
                        ->requiresConfirmation()
                        ->action(fn (WebsiteRequest $record) => $record->update(['status' => 'completed']))
                        ->visible(fn (WebsiteRequest $record) => $record->status === 'accepted'),
                    Tables\Actions\DeleteAction::make(),
                ]),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\BulkAction::make('accept_multiple')
                        ->label('قبول المحدد')
                        ->icon('heroicon-m-check-circle')
                        ->color('success')
                        ->requiresConfirmation()
                        ->action(fn ($records) => $records->each->update(['status' => 'accepted'])),
                    Tables\Actions\BulkAction::make('reject_multiple')
                        ->label('رفض المحدد')
                        ->icon('heroicon-m-x-circle')
                        ->color('danger')
                        ->requiresConfirmation()
                        ->form([
                            Forms\Components\Textarea::make('admin_notes')
                                ->label('سبب الرفض')
                                ->required()
                                ->rows(3),
                        ])
                        ->action(function ($records, array $data) {
                            $records->each->update([
                                'status' => 'rejected',
                                'admin_notes' => $data['admin_notes'],
                            ]);
                        }),
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
                        Infolists\Components\TextEntry::make('name')
                            ->label('الاسم'),
                        Infolists\Components\TextEntry::make('email')
                            ->label('البريد الإلكتروني')
                            ->copyable(),
                        Infolists\Components\TextEntry::make('phone')
                            ->label('الهاتف')
                            ->copyable(),
                        Infolists\Components\TextEntry::make('company_name')
                            ->label('الشركة'),
                    ])->columns(2),

                Infolists\Components\Section::make('تفاصيل الموقع')
                    ->schema([
                        Infolists\Components\TextEntry::make('website_type')
                            ->label('نوع الموقع')
                            ->badge(),
                        Infolists\Components\TextEntry::make('budget')
                            ->label('الميزانية')
                            ->money('currency'),
                        Infolists\Components\TextEntry::make('deadline')
                            ->label('الموعد النهائي')
                            ->date('Y-m-d'),
                        Infolists\Components\TextEntry::make('description')
                            ->label('الوصف')
                            ->columnSpanFull(),
                        Infolists\Components\TextEntry::make('features')
                            ->label('المميزات المطلوبة')
                            ->columnSpanFull(),
                    ])->columns(2),

                Infolists\Components\Section::make('حالة الطلب')
                    ->schema([
                        Infolists\Components\TextEntry::make('status')
                            ->label('الحالة')
                            ->badge(),
                        Infolists\Components\TextEntry::make('admin_notes')
                            ->label('ملاحظات الإدارة')
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
            'index' => Pages\ListWebsiteRequests::route('/'),
            'create' => Pages\CreateWebsiteRequest::route('/create'),
            'view' => Pages\ViewWebsiteRequest::route('/{record}'),
            'edit' => Pages\EditWebsiteRequest::route('/{record}/edit'),
        ];
    }
}
