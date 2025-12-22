<?php

namespace App\Filament\Widgets;

use App\Models\AgentExecution;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class LatestAgentExecutions extends BaseWidget
{
    protected static ?int $sort = 3;

    protected int | string | array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                AgentExecution::query()
                    ->latest()
                    ->limit(10)
            )
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('#')
                    ->sortable(),

                Tables\Columns\TextColumn::make('user.name')
                    ->label('المستخدم')
                    ->limit(15)
                    ->searchable()
                    ->sortable(),

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
                    }),

                Tables\Columns\TextColumn::make('action')
                    ->label('الإجراء')
                    ->limit(20)
                    ->searchable(),

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
                    }),

                Tables\Columns\TextColumn::make('duration_human')
                    ->label('المدة'),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('التاريخ')
                    ->since()
                    ->sortable(),
            ])
            ->actions([
                Tables\Actions\Action::make('view')
                    ->label('عرض')
                    ->icon('heroicon-o-eye')
                    ->url(fn (AgentExecution $record): string => route('filament.admin.resources.agent-executions.view', ['record' => $record]))
                    ->openUrlInNewTab(),
            ])
            ->defaultSort('created_at', 'desc')
            ->poll('5s');
    }

    public function getHeading(): string
    {
        return 'آخر تنفيذات الـ Agent';
    }
}
