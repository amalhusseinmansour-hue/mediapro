<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SponsoredAdRequestResource\Pages;
use App\Models\SponsoredAdRequest;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Infolists;
use Filament\Infolists\Infolist;

class SponsoredAdRequestResource extends Resource
{
    protected static ?string $model = SponsoredAdRequest::class;

    protected static ?string $navigationIcon = 'heroicon-o-megaphone';

    protected static ?string $navigationGroup = 'إدارة الطلبات';

    protected static ?string $navigationLabel = 'الإعلانات الممولة';

    protected static ?string $modelLabel = 'طلب إعلان';

    protected static ?string $pluralModelLabel = 'طلبات الإعلانات الممولة';

    protected static ?int $navigationSort = 2;

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

                Forms\Components\Section::make('تفاصيل الإعلان')
                    ->schema([
                        Forms\Components\Select::make('ad_platform')
                            ->label('المنصة')
                            ->required()
                            ->options([
                                'facebook' => 'فيسبوك',
                                'instagram' => 'إنستغرام',
                                'google' => 'جوجل',
                                'tiktok' => 'تيك توك',
                                'twitter' => 'تويتر (X)',
                                'linkedin' => 'لينكد إن',
                                'snapchat' => 'سناب شات',
                                'multiple' => 'عدة منصات',
                            ])
                            ->native(false),

                        Forms\Components\Select::make('ad_type')
                            ->label('هدف الحملة')
                            ->required()
                            ->options([
                                'awareness' => 'زيادة الوعي بالعلامة التجارية',
                                'traffic' => 'زيادة الزيارات للموقع',
                                'engagement' => 'زيادة التفاعل والمشاركة',
                                'leads' => 'جمع بيانات العملاء المحتملين',
                                'sales' => 'زيادة المبيعات والتحويلات',
                                'app_installs' => 'تثبيت التطبيق',
                            ])
                            ->native(false),

                        Forms\Components\TextInput::make('budget')
                            ->label('الميزانية')
                            ->required()
                            ->numeric()
                            ->step(0.01)
                            ->minValue(1),

                        Forms\Components\Select::make('currency')
                            ->label('العملة')
                            ->required()
                            ->default('AED')
                            ->options([
                                'AED' => 'درهم إماراتي',
                                'SAR' => 'ريال سعودي',
                                'USD' => 'دولار أمريكي',
                                'EUR' => 'يورو',
                            ])
                            ->native(false),

                        Forms\Components\TextInput::make('duration_days')
                            ->label('مدة الحملة (بالأيام)')
                            ->numeric()
                            ->suffix('يوم')
                            ->minValue(1),

                        Forms\Components\DatePicker::make('start_date')
                            ->label('تاريخ البدء المطلوب')
                            ->native(false)
                            ->minDate(now()),

                        Forms\Components\Textarea::make('target_audience')
                            ->label('الجمهور المستهدف')
                            ->required()
                            ->rows(3)
                            ->columnSpanFull(),

                        Forms\Components\Textarea::make('ad_content')
                            ->label('محتوى ووصف الإعلان')
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
                                'running' => 'قيد التنفيذ',
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

                Tables\Columns\TextColumn::make('ad_platform')
                    ->label('المنصة')
                    ->formatStateUsing(fn ($state) => match($state) {
                        'facebook' => 'فيسبوك',
                        'instagram' => 'إنستغرام',
                        'google' => 'جوجل',
                        'tiktok' => 'تيك توك',
                        'twitter' => 'تويتر (X)',
                        'linkedin' => 'لينكد إن',
                        'snapchat' => 'سناب شات',
                        'multiple' => 'عدة منصات',
                        default => $state,
                    })
                    ->badge()
                    ->color(fn ($state) => match($state) {
                        'facebook' => 'primary',
                        'instagram' => 'danger',
                        'google' => 'success',
                        'tiktok' => 'info',
                        'twitter' => 'gray',
                        'linkedin' => 'primary',
                        default => 'gray',
                    })
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('ad_type')
                    ->label('هدف الحملة')
                    ->formatStateUsing(fn ($state) => match($state) {
                        'awareness' => 'الوعي',
                        'traffic' => 'الزيارات',
                        'engagement' => 'التفاعل',
                        'leads' => 'عملاء محتملين',
                        'sales' => 'مبيعات',
                        'app_installs' => 'تثبيت تطبيق',
                        default => $state,
                    })
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('budget')
                    ->label('الميزانية')
                    ->money(fn ($record) => $record->currency ?? 'AED')
                    ->sortable(),

                Tables\Columns\TextColumn::make('duration_days')
                    ->label('المدة')
                    ->suffix(' يوم')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('start_date')
                    ->label('تاريخ البدء')
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
                        'running' => 'primary',
                        'completed' => 'gray',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn ($state) => match($state) {
                        'pending' => 'قيد الانتظار',
                        'reviewing' => 'قيد المراجعة',
                        'accepted' => 'مقبول',
                        'rejected' => 'مرفوض',
                        'running' => 'قيد التنفيذ',
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
                        'running' => 'قيد التنفيذ',
                        'completed' => 'مكتمل',
                    ])
                    ->native(false),

                Tables\Filters\SelectFilter::make('ad_platform')
                    ->label('المنصة')
                    ->options([
                        'facebook' => 'فيسبوك',
                        'instagram' => 'إنستغرام',
                        'google' => 'جوجل',
                        'tiktok' => 'تيك توك',
                        'twitter' => 'تويتر (X)',
                        'linkedin' => 'لينكد إن',
                        'snapchat' => 'سناب شات',
                        'multiple' => 'عدة منصات',
                    ])
                    ->native(false),

                Tables\Filters\SelectFilter::make('ad_type')
                    ->label('هدف الحملة')
                    ->options([
                        'awareness' => 'زيادة الوعي',
                        'traffic' => 'زيادة الزيارات',
                        'engagement' => 'زيادة التفاعل',
                        'leads' => 'جمع العملاء',
                        'sales' => 'زيادة المبيعات',
                        'app_installs' => 'تثبيت التطبيق',
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
                        ->action(fn (SponsoredAdRequest $record) => $record->update(['status' => 'accepted']))
                        ->visible(fn (SponsoredAdRequest $record) => $record->status === 'pending'),
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
                        ->action(function (SponsoredAdRequest $record, array $data) {
                            $record->update([
                                'status' => 'rejected',
                                'admin_notes' => $data['admin_notes'],
                            ]);
                        })
                        ->visible(fn (SponsoredAdRequest $record) => $record->status === 'pending'),
                    Tables\Actions\Action::make('start_running')
                        ->label('بدء التنفيذ')
                        ->icon('heroicon-m-play')
                        ->color('primary')
                        ->requiresConfirmation()
                        ->action(fn (SponsoredAdRequest $record) => $record->update(['status' => 'running']))
                        ->visible(fn (SponsoredAdRequest $record) => $record->status === 'accepted'),
                    Tables\Actions\Action::make('complete')
                        ->label('إكمال')
                        ->icon('heroicon-m-check-badge')
                        ->color('success')
                        ->requiresConfirmation()
                        ->action(fn (SponsoredAdRequest $record) => $record->update(['status' => 'completed']))
                        ->visible(fn (SponsoredAdRequest $record) => $record->status === 'running'),
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

                Infolists\Components\Section::make('تفاصيل الإعلان')
                    ->schema([
                        Infolists\Components\TextEntry::make('ad_platform')
                            ->label('المنصة')
                            ->badge()
                            ->formatStateUsing(fn ($state) => match($state) {
                                'facebook' => 'فيسبوك',
                                'instagram' => 'إنستغرام',
                                'google' => 'جوجل',
                                'tiktok' => 'تيك توك',
                                'twitter' => 'تويتر (X)',
                                'linkedin' => 'لينكد إن',
                                'snapchat' => 'سناب شات',
                                'multiple' => 'عدة منصات',
                                default => $state,
                            }),
                        Infolists\Components\TextEntry::make('ad_type')
                            ->label('هدف الحملة')
                            ->badge()
                            ->formatStateUsing(fn ($state) => match($state) {
                                'awareness' => 'زيادة الوعي',
                                'traffic' => 'زيادة الزيارات',
                                'engagement' => 'زيادة التفاعل',
                                'leads' => 'جمع العملاء',
                                'sales' => 'زيادة المبيعات',
                                'app_installs' => 'تثبيت التطبيق',
                                default => $state,
                            }),
                        Infolists\Components\TextEntry::make('budget')
                            ->label('الميزانية')
                            ->money('currency'),
                        Infolists\Components\TextEntry::make('duration_days')
                            ->label('المدة')
                            ->suffix(' يوم'),
                        Infolists\Components\TextEntry::make('start_date')
                            ->label('تاريخ البدء')
                            ->date('Y-m-d'),
                        Infolists\Components\TextEntry::make('target_audience')
                            ->label('الجمهور المستهدف')
                            ->columnSpanFull(),
                        Infolists\Components\TextEntry::make('ad_content')
                            ->label('محتوى الإعلان')
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
            'index' => Pages\ListSponsoredAdRequests::route('/'),
            'create' => Pages\CreateSponsoredAdRequest::route('/create'),
            'view' => Pages\ViewSponsoredAdRequest::route('/{record}'),
            'edit' => Pages\EditSponsoredAdRequest::route('/{record}/edit'),
        ];
    }
}
