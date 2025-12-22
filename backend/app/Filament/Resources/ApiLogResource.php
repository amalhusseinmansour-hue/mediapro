<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ApiLogResource\Pages;
use App\Models\ApiLog;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class ApiLogResource extends Resource
{
    protected static ?string $model = ApiLog::class;

    protected static ?string $navigationIcon = 'heroicon-o-document-text';

    protected static ?string $navigationGroup = 'System';

    protected static ?string $navigationLabel = 'سجلات API';

    protected static ?string $modelLabel = 'سجل API';

    protected static ?string $pluralModelLabel = 'سجلات API';

    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('معلومات الطلب')
                    ->schema([
                        Forms\Components\TextInput::make('method')
                            ->label('الطريقة')
                            ->disabled(),

                        Forms\Components\TextInput::make('endpoint')
                            ->label('المسار')
                            ->disabled()
                            ->columnSpanFull(),

                        Forms\Components\TextInput::make('ip_address')
                            ->label('عنوان IP')
                            ->disabled(),

                        Forms\Components\TextInput::make('response_status')
                            ->label('حالة الاستجابة')
                            ->disabled(),

                        Forms\Components\TextInput::make('formatted_response_time')
                            ->label('وقت الاستجابة')
                            ->disabled(),

                        Forms\Components\Select::make('api_key_id')
                            ->label('مفتاح API')
                            ->relationship('apiKey', 'name')
                            ->disabled(),

                        Forms\Components\Select::make('user_id')
                            ->label('المستخدم')
                            ->relationship('user', 'name')
                            ->disabled(),

                        Forms\Components\DateTimePicker::make('created_at')
                            ->label('التاريخ')
                            ->disabled(),
                    ])->columns(2),

                Forms\Components\Section::make('تفاصيل الطلب')
                    ->schema([
                        Forms\Components\KeyValue::make('request_headers')
                            ->label('Headers')
                            ->disabled(),

                        Forms\Components\KeyValue::make('request_body')
                            ->label('Request Body')
                            ->disabled(),
                    ])->collapsible(),

                Forms\Components\Section::make('تفاصيل الاستجابة')
                    ->schema([
                        Forms\Components\KeyValue::make('response_body')
                            ->label('Response Body')
                            ->disabled(),
                    ])->collapsible(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('method')
                    ->label('الطريقة')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'GET' => 'info',
                        'POST' => 'success',
                        'PUT', 'PATCH' => 'warning',
                        'DELETE' => 'danger',
                        default => 'gray',
                    })
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('endpoint')
                    ->label('المسار')
                    ->searchable()
                    ->limit(30)
                    ->wrap()
                    ->tooltip(function (Tables\Columns\TextColumn $column): ?string {
                        $state = $column->getState();
                        return strlen($state) > 30 ? $state : null;
                    }),

                Tables\Columns\TextColumn::make('apiKey.name')
                    ->label('المفتاح')
                    ->searchable()
                    ->sortable()
                    ->default('غير محدد')
                    ->limit(20)
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('user.name')
                    ->label('المستخدم')
                    ->searchable()
                    ->sortable()
                    ->default('غير محدد')
                    ->limit(20)
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('ip_address')
                    ->label('IP')
                    ->searchable()
                    ->limit(15)
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('response_status')
                    ->label('الحالة')
                    ->badge()
                    ->color(fn ($record) => $record->status_color)
                    ->sortable(),

                Tables\Columns\TextColumn::make('formatted_response_time')
                    ->label('الوقت')
                    ->sortable(query: function ($query, string $direction) {
                        return $query->orderBy('response_time', $direction);
                    })
                    ->toggleable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('التاريخ')
                    ->dateTime()
                    ->since()
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('method')
                    ->label('الطريقة')
                    ->options([
                        'GET' => 'GET',
                        'POST' => 'POST',
                        'PUT' => 'PUT',
                        'PATCH' => 'PATCH',
                        'DELETE' => 'DELETE',
                    ]),

                Tables\Filters\SelectFilter::make('response_status')
                    ->label('حالة الاستجابة')
                    ->options([
                        '200' => '200 - OK',
                        '201' => '201 - Created',
                        '400' => '400 - Bad Request',
                        '401' => '401 - Unauthorized',
                        '403' => '403 - Forbidden',
                        '404' => '404 - Not Found',
                        '422' => '422 - Validation Error',
                        '429' => '429 - Too Many Requests',
                        '500' => '500 - Server Error',
                    ]),

                Tables\Filters\Filter::make('successful')
                    ->label('ناجح')
                    ->query(fn ($query) => $query->successful()),

                Tables\Filters\Filter::make('failed')
                    ->label('فاشل')
                    ->query(fn ($query) => $query->failed()),

                Tables\Filters\Filter::make('today')
                    ->label('اليوم')
                    ->query(fn ($query) => $query->today()),

                Tables\Filters\SelectFilter::make('api_key_id')
                    ->label('مفتاح API')
                    ->relationship('apiKey', 'name')
                    ->searchable(),
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
            ->poll('10s'); // Auto-refresh every 10 seconds
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListApiLogs::route('/'),
            'view' => Pages\ViewApiLog::route('/{record}'),
        ];
    }

    public static function canCreate(): bool
    {
        return false;
    }
}
