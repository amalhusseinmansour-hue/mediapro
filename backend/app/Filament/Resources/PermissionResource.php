<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PermissionResource\Pages;
use App\Filament\Resources\PermissionResource\RelationManagers;
use App\Models\Permission;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class PermissionResource extends Resource
{
    protected static ?string $model = Permission::class;

    protected static ?string $navigationIcon = 'heroicon-o-key';

    protected static ?string $modelLabel = 'صلاحية';

    protected static ?string $pluralModelLabel = 'الصلاحيات';

    protected static ?string $navigationGroup = 'إدارة الصلاحيات';

    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('معلومات الصلاحية')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('اسم الصلاحية (بالإنجليزية)')
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->maxLength(255)
                            ->placeholder('users.view')
                            ->helperText('استخدم الصيغة: group.action (مثل: users.view)'),

                        Forms\Components\TextInput::make('display_name')
                            ->label('الاسم المعروض')
                            ->required()
                            ->maxLength(255)
                            ->placeholder('عرض المستخدمين'),

                        Forms\Components\Select::make('group')
                            ->label('المجموعة')
                            ->required()
                            ->options([
                                'users' => 'إدارة المستخدمين',
                                'roles' => 'إدارة الأدوار',
                                'permissions' => 'إدارة الصلاحيات',
                                'subscriptions' => 'إدارة الاشتراكات',
                                'payments' => 'إدارة المدفوعات',
                                'settings' => 'إدارة الإعدادات',
                                'content' => 'إدارة المحتوى',
                                'reports' => 'التقارير',
                                'dashboard' => 'لوحة التحكم',
                                'apikeys' => 'إدارة مفاتيح API',
                                'pages' => 'إدارة الصفحات',
                                'brandkits' => 'Brand Kits',
                                'aigenerations' => 'AI Generations',
                                'earnings' => 'الأرباح',
                                'notifications' => 'الإشعارات',
                                'general' => 'عام',
                            ])
                            ->default('general')
                            ->searchable(),

                        Forms\Components\Textarea::make('description')
                            ->label('الوصف')
                            ->rows(3)
                            ->columnSpanFull()
                            ->placeholder('وصف مختصر للصلاحية وما تسمح به'),
                    ])
                    ->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('اسم الصلاحية')
                    ->searchable()
                    ->sortable()
                    ->copyable()
                    ->badge()
                    ->color('primary'),

                Tables\Columns\TextColumn::make('display_name')
                    ->label('الاسم المعروض')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('group')
                    ->label('المجموعة')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'users' => 'success',
                        'roles' => 'warning',
                        'permissions' => 'danger',
                        'subscriptions' => 'info',
                        'payments' => 'success',
                        'settings' => 'gray',
                        'content' => 'primary',
                        'reports' => 'info',
                        'dashboard' => 'warning',
                        'apikeys' => 'danger',
                        'pages' => 'primary',
                        'brandkits' => 'success',
                        'aigenerations' => 'info',
                        'earnings' => 'success',
                        'notifications' => 'warning',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'users' => 'إدارة المستخدمين',
                        'roles' => 'إدارة الأدوار',
                        'permissions' => 'إدارة الصلاحيات',
                        'subscriptions' => 'إدارة الاشتراكات',
                        'payments' => 'إدارة المدفوعات',
                        'settings' => 'إدارة الإعدادات',
                        'content' => 'إدارة المحتوى',
                        'reports' => 'التقارير',
                        'dashboard' => 'لوحة التحكم',
                        'apikeys' => 'إدارة مفاتيح API',
                        'pages' => 'إدارة الصفحات',
                        'brandkits' => 'Brand Kits',
                        'aigenerations' => 'AI Generations',
                        'earnings' => 'الأرباح',
                        'notifications' => 'الإشعارات',
                        default => $state,
                    })
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('description')
                    ->label('الوصف')
                    ->limit(50)
                    ->toggleable(),

                Tables\Columns\TextColumn::make('roles_count')
                    ->label('عدد الأدوار')
                    ->counts('roles')
                    ->badge()
                    ->color('info')
                    ->sortable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('updated_at')
                    ->label('تاريخ التحديث')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('group')
                    ->label('المجموعة')
                    ->options([
                        'users' => 'إدارة المستخدمين',
                        'roles' => 'إدارة الأدوار',
                        'permissions' => 'إدارة الصلاحيات',
                        'subscriptions' => 'إدارة الاشتراكات',
                        'payments' => 'إدارة المدفوعات',
                        'settings' => 'إدارة الإعدادات',
                        'content' => 'إدارة المحتوى',
                        'reports' => 'التقارير',
                        'dashboard' => 'لوحة التحكم',
                        'apikeys' => 'إدارة مفاتيح API',
                        'pages' => 'إدارة الصفحات',
                        'brandkits' => 'Brand Kits',
                        'aigenerations' => 'AI Generations',
                        'earnings' => 'الأرباح',
                        'notifications' => 'الإشعارات',
                        'general' => 'عام',
                    ])
                    ->multiple(),
            ])
            ->actions([
                Tables\Actions\EditAction::make()
                    ->label('تعديل'),
                Tables\Actions\DeleteAction::make()
                    ->label('حذف'),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make()
                        ->label('حذف المحدد'),
                ]),
            ])
            ->defaultSort('group', 'asc')
            ->groups([
                Tables\Grouping\Group::make('group')
                    ->label('المجموعة')
                    ->collapsible()
                    ->getTitleFromRecordUsing(fn (Permission $record): string => match ($record->group) {
                        'users' => 'إدارة المستخدمين',
                        'roles' => 'إدارة الأدوار',
                        'permissions' => 'إدارة الصلاحيات',
                        'subscriptions' => 'إدارة الاشتراكات',
                        'payments' => 'إدارة المدفوعات',
                        'settings' => 'إدارة الإعدادات',
                        'content' => 'إدارة المحتوى',
                        'reports' => 'التقارير',
                        'dashboard' => 'لوحة التحكم',
                        'apikeys' => 'إدارة مفاتيح API',
                        'pages' => 'إدارة الصفحات',
                        'brandkits' => 'Brand Kits',
                        'aigenerations' => 'AI Generations',
                        'earnings' => 'الأرباح',
                        'notifications' => 'الإشعارات',
                        default => $record->group,
                    }),
            ]);
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
            'index' => Pages\ListPermissions::route('/'),
            'create' => Pages\CreatePermission::route('/create'),
            'edit' => Pages\EditPermission::route('/{record}/edit'),
        ];
    }
}
