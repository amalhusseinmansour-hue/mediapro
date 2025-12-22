<?php

namespace App\Filament\Resources;

use App\Filament\Resources\AgentExecutionResource\Pages;
use App\Models\AgentExecution;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Infolists;
use Filament\Infolists\Infolist;

class AgentExecutionResource extends Resource
{
    protected static ?string $model = AgentExecution::class;

    protected static ?string $navigationIcon = 'heroicon-o-cpu-chip';

    protected static ?string $navigationGroup = 'Content';

    protected static ?string $navigationLabel = 'تنفيذات الـ Agent';

    protected static ?string $modelLabel = 'تنفيذ Agent';

    protected static ?string $pluralModelLabel = 'تنفيذات الـ Agent';

    protected static ?int $navigationSort = 10;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('معلومات التنفيذ')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->label('المستخدم')
                            ->relationship('user', 'name')
                            ->disabled(),

                        Forms\Components\TextInput::make('agent_type_name')
                            ->label('نوع الـ Agent')
                            ->disabled(),

                        Forms\Components\TextInput::make('action')
                            ->label('الإجراء')
                            ->disabled(),

                        Forms\Components\Badge::make('status')
                            ->label('الحالة')
                            ->color(fn (AgentExecution $record) => match($record->status) {
                                'completed' => 'success',
                                'processing' => 'warning',
                                'failed' => 'danger',
                                default => 'gray',
                            }),

                        Forms\Components\TextInput::make('duration_human')
                            ->label('مدة التنفيذ')
                            ->disabled(),

                        Forms\Components\TextInput::make('credits_used')
                            ->label('الأرصدة المستخدمة')
                            ->disabled(),

                        Forms\Components\TextInput::make('telegram_chat_id')
                            ->label('Telegram Chat ID')
                            ->disabled(),

                        Forms\Components\TextInput::make('google_drive_file_id')
                            ->label('Google Drive File ID')
                            ->disabled()
                            ->url(fn ($state) => $state ? "https://drive.google.com/file/d/{$state}/view" : null),

                        Forms\Components\TextInput::make('result_url')
                            ->label('رابط النتيجة')
                            ->disabled()
                            ->url(fn ($state) => $state),

                        Forms\Components\DateTimePicker::make('started_at')
                            ->label('بدأ في')
                            ->disabled(),

                        Forms\Components\DateTimePicker::make('completed_at')
                            ->label('انتهى في')
                            ->disabled(),
                    ])->columns(2),

                Forms\Components\Section::make('بيانات الإدخال')
                    ->schema([
                        Forms\Components\KeyValue::make('input_data')
                            ->label('Input Data')
                            ->disabled(),
                    ])->collapsible()->collapsed(),

                Forms\Components\Section::make('بيانات الإخراج')
                    ->schema([
                        Forms\Components\KeyValue::make('output_data')
                            ->label('Output Data')
                            ->disabled(),
                    ])->collapsible()->collapsed()
                    ->visible(fn (AgentExecution $record) => $record->status === 'completed'),

                Forms\Components\Section::make('بيانات الخطأ')
                    ->schema([
                        Forms\Components\KeyValue::make('error_data')
                            ->label('Error Data')
                            ->disabled(),
                    ])->collapsible()->collapsed()
                    ->visible(fn (AgentExecution $record) => $record->status === 'failed'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('#')
                    ->sortable(),

                Tables\Columns\TextColumn::make('user.name')
                    ->label('المستخدم')
                    ->searchable()
                    ->sortable()
                    ->limit(20),

                Tables\Columns\TextColumn::make('agent_type_name')
                    ->label('Agent')
                    ->badge()
                    ->color(fn (AgentExecution $record): string => match($record->agent_type) {
                        'content' => 'info',
                        'posting' => 'success',
                        'email' => 'warning',
                        'calendar' => 'primary',
                        'drive' => 'secondary',
                        'internet' => 'gray',
                        default => 'gray',
                    })
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('action')
                    ->label('الإجراء')
                    ->searchable()
                    ->limit(25)
                    ->tooltip(function (Tables\Columns\TextColumn $column): ?string {
                        $state = $column->getState();
                        return strlen($state) > 25 ? $state : null;
                    }),

                Tables\Columns\TextColumn::make('status')
                    ->label('الحالة')
                    ->badge()
                    ->color(fn (AgentExecution $record) => match($record->status) {
                        'completed' => 'success',
                        'processing' => 'warning',
                        'failed' => 'danger',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match($state) {
                        'pending' => 'قيد الانتظار',
                        'processing' => 'جاري التنفيذ',
                        'completed' => 'مكتمل',
                        'failed' => 'فشل',
                        default => $state,
                    })
                    ->sortable(),

                Tables\Columns\TextColumn::make('duration_human')
                    ->label('المدة')
                    ->sortable(query: function ($query, string $direction) {
                        return $query->orderBy('execution_time', $direction);
                    })
                    ->toggleable(),

                Tables\Columns\TextColumn::make('credits_used')
                    ->label('الأرصدة')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('التاريخ')
                    ->dateTime()
                    ->since()
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('agent_type')
                    ->label('نوع الـ Agent')
                    ->options([
                        'content' => 'Content Agent',
                        'posting' => 'Posting Agent',
                        'email' => 'Email Agent',
                        'calendar' => 'Calendar Agent',
                        'drive' => 'Google Drive Agent',
                        'contact' => 'Contact Agent',
                        'internet' => 'Internet Agent',
                    ]),

                Tables\Filters\SelectFilter::make('status')
                    ->label('الحالة')
                    ->options([
                        'pending' => 'قيد الانتظار',
                        'processing' => 'جاري التنفيذ',
                        'completed' => 'مكتمل',
                        'failed' => 'فشل',
                    ]),

                Tables\Filters\SelectFilter::make('user_id')
                    ->label('المستخدم')
                    ->relationship('user', 'name')
                    ->searchable(),

                Tables\Filters\Filter::make('completed')
                    ->label('مكتملة')
                    ->query(fn ($query) => $query->completed()),

                Tables\Filters\Filter::make('failed')
                    ->label('فاشلة')
                    ->query(fn ($query) => $query->failed()),

                Tables\Filters\Filter::make('today')
                    ->label('اليوم')
                    ->query(fn ($query) => $query->whereDate('created_at', today())),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('created_at', 'desc')
            ->poll('5s'); // Auto-refresh every 5 seconds for real-time monitoring
    }

    public static function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                Infolists\Components\Section::make('معلومات التنفيذ')
                    ->schema([
                        Infolists\Components\TextEntry::make('user.name')
                            ->label('المستخدم'),

                        Infolists\Components\TextEntry::make('agent_type_name')
                            ->label('نوع الـ Agent')
                            ->badge()
                            ->color(fn (AgentExecution $record): string => match($record->agent_type) {
                                'content' => 'info',
                                'posting' => 'success',
                                'email' => 'warning',
                                'calendar' => 'primary',
                                'drive' => 'secondary',
                                'internet' => 'gray',
                                default => 'gray',
                            }),

                        Infolists\Components\TextEntry::make('action')
                            ->label('الإجراء'),

                        Infolists\Components\TextEntry::make('status')
                            ->label('الحالة')
                            ->badge()
                            ->color(fn (AgentExecution $record) => match($record->status) {
                                'completed' => 'success',
                                'processing' => 'warning',
                                'failed' => 'danger',
                                default => 'gray',
                            })
                            ->formatStateUsing(fn (string $state): string => match($state) {
                                'pending' => 'قيد الانتظار',
                                'processing' => 'جاري التنفيذ',
                                'completed' => 'مكتمل',
                                'failed' => 'فشل',
                                default => $state,
                            }),

                        Infolists\Components\TextEntry::make('duration_human')
                            ->label('مدة التنفيذ'),

                        Infolists\Components\TextEntry::make('credits_used')
                            ->label('الأرصدة المستخدمة'),

                        Infolists\Components\TextEntry::make('telegram_chat_id')
                            ->label('Telegram Chat ID')
                            ->visible(fn ($state) => $state),

                        Infolists\Components\TextEntry::make('google_drive_file_id')
                            ->label('Google Drive File')
                            ->url(fn ($state) => $state ? "https://drive.google.com/file/d/{$state}/view" : null, true)
                            ->visible(fn ($state) => $state),

                        Infolists\Components\TextEntry::make('result_url')
                            ->label('رابط النتيجة')
                            ->url(fn ($state) => $state, true)
                            ->visible(fn ($state) => $state),

                        Infolists\Components\TextEntry::make('started_at')
                            ->label('بدأ في')
                            ->dateTime(),

                        Infolists\Components\TextEntry::make('completed_at')
                            ->label('انتهى في')
                            ->dateTime()
                            ->visible(fn ($state) => $state),

                        Infolists\Components\TextEntry::make('created_at')
                            ->label('تاريخ الإنشاء')
                            ->dateTime(),
                    ])->columns(2),

                Infolists\Components\Section::make('بيانات الإدخال')
                    ->schema([
                        Infolists\Components\KeyValueEntry::make('input_data')
                            ->label(''),
                    ])
                    ->collapsible()
                    ->collapsed(),

                Infolists\Components\Section::make('بيانات الإخراج')
                    ->schema([
                        Infolists\Components\KeyValueEntry::make('output_data')
                            ->label(''),
                    ])
                    ->collapsible()
                    ->collapsed()
                    ->visible(fn (AgentExecution $record) => $record->status === 'completed' && $record->output_data),

                Infolists\Components\Section::make('بيانات الخطأ')
                    ->schema([
                        Infolists\Components\KeyValueEntry::make('error_data')
                            ->label(''),
                    ])
                    ->collapsible()
                    ->collapsed()
                    ->visible(fn (AgentExecution $record) => $record->status === 'failed' && $record->error_data),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListAgentExecutions::route('/'),
            'view' => Pages\ViewAgentExecution::route('/{record}'),
        ];
    }

    public static function canCreate(): bool
    {
        return false;
    }
}
