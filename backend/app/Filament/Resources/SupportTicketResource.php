<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SupportTicketResource\Pages;
use App\Models\SupportTicket;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Infolists;
use Filament\Infolists\Infolist;

class SupportTicketResource extends Resource
{
    protected static ?string $model = SupportTicket::class;

    protected static ?string $navigationIcon = 'heroicon-o-ticket';

    protected static ?string $navigationGroup = 'إدارة الطلبات';

    protected static ?string $navigationLabel = 'تذاكر الدعم';

    protected static ?string $modelLabel = 'تذكرة دعم';

    protected static ?string $pluralModelLabel = 'تذاكر الدعم الفني';

    protected static ?int $navigationSort = 3;

    public static function getNavigationBadge(): ?string
    {
        try {
            return static::getModel()::whereIn('status', ['open', 'in_progress'])->count() ?: null;
        } catch (\Exception $e) {
            return null;
        }
    }

    public static function getNavigationBadgeColor(): ?string
    {
        try {
            $urgentCount = static::getModel()::where('priority', 'urgent')
                ->whereIn('status', ['open', 'in_progress'])
                ->count();

            return $urgentCount > 0 ? 'danger' : 'warning';
        } catch (\Exception $e) {
            return 'warning';
        }
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

                        Forms\Components\TextInput::make('whatsapp_number')
                            ->label('رقم الواتساب')
                            ->tel()
                            ->maxLength(20),
                    ])->columns(2),

                Forms\Components\Section::make('تفاصيل التذكرة')
                    ->schema([
                        Forms\Components\TextInput::make('subject')
                            ->label('الموضوع')
                            ->required()
                            ->maxLength(255)
                            ->columnSpanFull(),

                        Forms\Components\Select::make('category')
                            ->label('التصنيف')
                            ->required()
                            ->options([
                                'technical' => 'دعم تقني',
                                'billing' => 'فواتير ومدفوعات',
                                'feature' => 'طلب ميزة جديدة',
                                'bug' => 'الإبلاغ عن خطأ',
                                'account' => 'مشاكل الحساب',
                                'other' => 'أخرى',
                            ])
                            ->native(false),

                        Forms\Components\Select::make('priority')
                            ->label('الأولوية')
                            ->required()
                            ->default('medium')
                            ->options([
                                'low' => 'منخفضة',
                                'medium' => 'متوسطة',
                                'high' => 'عالية',
                                'urgent' => 'عاجلة',
                            ])
                            ->native(false),

                        Forms\Components\Textarea::make('message')
                            ->label('الرسالة')
                            ->required()
                            ->rows(5)
                            ->columnSpanFull(),
                    ])->columns(2),

                Forms\Components\Section::make('إدارة التذكرة')
                    ->schema([
                        Forms\Components\Select::make('status')
                            ->label('الحالة')
                            ->required()
                            ->default('open')
                            ->options([
                                'open' => 'مفتوحة',
                                'in_progress' => 'قيد المعالجة',
                                'resolved' => 'محلولة',
                                'closed' => 'مغلقة',
                            ])
                            ->native(false)
                            ->live(),

                        Forms\Components\Select::make('assigned_to')
                            ->label('مُعينة إلى')
                            ->options(fn () => User::where('is_admin', true)->pluck('name', 'id'))
                            ->searchable()
                            ->preload()
                            ->nullable(),

                        Forms\Components\DateTimePicker::make('resolved_at')
                            ->label('تاريخ الحل')
                            ->visible(fn (Forms\Get $get) => $get('status') === 'resolved')
                            ->nullable(),

                        Forms\Components\Textarea::make('admin_notes')
                            ->label('ملاحظات الإدارة')
                            ->rows(4)
                            ->columnSpanFull(),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('#')
                    ->sortable()
                    ->searchable(),

                Tables\Columns\TextColumn::make('subject')
                    ->label('الموضوع')
                    ->searchable()
                    ->sortable()
                    ->weight('bold')
                    ->limit(40)
                    ->wrap(),

                Tables\Columns\TextColumn::make('name')
                    ->label('المستخدم')
                    ->searchable()
                    ->sortable()
                    ->limit(25),

                Tables\Columns\TextColumn::make('email')
                    ->label('البريد')
                    ->searchable()
                    ->copyable()
                    ->limit(30)
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('category')
                    ->label('التصنيف')
                    ->formatStateUsing(fn ($state) => match($state) {
                        'technical' => 'دعم تقني',
                        'billing' => 'فواتير',
                        'feature' => 'ميزة جديدة',
                        'bug' => 'خطأ',
                        'account' => 'حساب',
                        'other' => 'أخرى',
                        default => $state,
                    })
                    ->badge()
                    ->color(fn ($state) => match($state) {
                        'technical' => 'primary',
                        'billing' => 'success',
                        'feature' => 'info',
                        'bug' => 'danger',
                        'account' => 'warning',
                        default => 'gray',
                    })
                    ->sortable(),

                Tables\Columns\TextColumn::make('priority')
                    ->label('الأولوية')
                    ->formatStateUsing(fn ($state) => match($state) {
                        'low' => 'منخفضة',
                        'medium' => 'متوسطة',
                        'high' => 'عالية',
                        'urgent' => 'عاجلة',
                        default => $state,
                    })
                    ->badge()
                    ->color(fn ($state) => match($state) {
                        'low' => 'gray',
                        'medium' => 'info',
                        'high' => 'warning',
                        'urgent' => 'danger',
                        default => 'gray',
                    })
                    ->sortable(),

                Tables\Columns\TextColumn::make('status')
                    ->label('الحالة')
                    ->badge()
                    ->color(fn ($state) => match($state) {
                        'open' => 'danger',
                        'in_progress' => 'primary',
                        'resolved' => 'success',
                        'closed' => 'gray',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn ($state) => match($state) {
                        'open' => 'مفتوحة',
                        'in_progress' => 'قيد المعالجة',
                        'resolved' => 'محلولة',
                        'closed' => 'مغلقة',
                        default => $state,
                    })
                    ->sortable(),

                Tables\Columns\TextColumn::make('assignedAdmin.name')
                    ->label('المسؤول')
                    ->default('غير مُعين')
                    ->sortable()
                    ->toggleable(),

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
                        'open' => 'مفتوحة',
                        'in_progress' => 'قيد المعالجة',
                        'resolved' => 'محلولة',
                        'closed' => 'مغلقة',
                    ])
                    ->native(false),

                Tables\Filters\SelectFilter::make('priority')
                    ->label('الأولوية')
                    ->options([
                        'low' => 'منخفضة',
                        'medium' => 'متوسطة',
                        'high' => 'عالية',
                        'urgent' => 'عاجلة',
                    ])
                    ->native(false),

                Tables\Filters\SelectFilter::make('category')
                    ->label('التصنيف')
                    ->options([
                        'technical' => 'دعم تقني',
                        'billing' => 'فواتير',
                        'feature' => 'ميزة جديدة',
                        'bug' => 'خطأ',
                        'account' => 'حساب',
                        'other' => 'أخرى',
                    ])
                    ->native(false),

                Tables\Filters\SelectFilter::make('assigned_to')
                    ->label('المسؤول')
                    ->relationship('assignedAdmin', 'name')
                    ->searchable()
                    ->preload(),
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
            ->defaultSort('priority', 'desc')
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
                        Infolists\Components\TextEntry::make('whatsapp_number')
                            ->label('واتساب')
                            ->copyable(),
                    ])->columns(2),

                Infolists\Components\Section::make('تفاصيل التذكرة')
                    ->schema([
                        Infolists\Components\TextEntry::make('subject')
                            ->label('الموضوع')
                            ->size('lg')
                            ->weight('bold')
                            ->columnSpanFull(),
                        Infolists\Components\TextEntry::make('category')
                            ->label('التصنيف')
                            ->badge(),
                        Infolists\Components\TextEntry::make('priority')
                            ->label('الأولوية')
                            ->badge(),
                        Infolists\Components\TextEntry::make('message')
                            ->label('الرسالة')
                            ->columnSpanFull(),
                    ])->columns(2),

                Infolists\Components\Section::make('حالة التذكرة')
                    ->schema([
                        Infolists\Components\TextEntry::make('status')
                            ->label('الحالة')
                            ->badge(),
                        Infolists\Components\TextEntry::make('assignedAdmin.name')
                            ->label('المسؤول')
                            ->default('غير مُعين'),
                        Infolists\Components\TextEntry::make('resolved_at')
                            ->label('تاريخ الحل')
                            ->dateTime()
                            ->placeholder('لم يتم الحل بعد'),
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
            'index' => Pages\ListSupportTickets::route('/'),
            'create' => Pages\CreateSupportTicket::route('/create'),
            'view' => Pages\ViewSupportTicket::route('/{record}'),
            'edit' => Pages\EditSupportTicket::route('/{record}/edit'),
        ];
    }
}
