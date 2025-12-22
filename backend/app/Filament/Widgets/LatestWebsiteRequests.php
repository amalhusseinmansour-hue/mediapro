<?php

namespace App\Filament\Widgets;

use App\Filament\Resources\WebsiteRequestResource;
use App\Models\WebsiteRequest;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class LatestWebsiteRequests extends BaseWidget
{
    protected static ?int $sort = 3;

    protected int | string | array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                WebsiteRequest::query()
                    ->latest()
                    ->limit(10)
            )
            ->heading('أحدث طلبات المواقع الإلكترونية')
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('#')
                    ->sortable(),

                Tables\Columns\TextColumn::make('name')
                    ->label('الاسم')
                    ->searchable()
                    ->weight('bold')
                    ->limit(20),

                Tables\Columns\TextColumn::make('email')
                    ->label('البريد الإلكتروني')
                    ->searchable()
                    ->copyable()
                    ->limit(25)
                    ->icon('heroicon-m-envelope'),

                Tables\Columns\TextColumn::make('phone')
                    ->label('الهاتف')
                    ->searchable()
                    ->copyable()
                    ->icon('heroicon-m-phone'),

                Tables\Columns\TextColumn::make('company_name')
                    ->label('الشركة')
                    ->limit(20)
                    ->toggleable(),

                Tables\Columns\TextColumn::make('website_type')
                    ->label('النوع')
                    ->formatStateUsing(fn ($state) => match($state) {
                        'corporate' => 'موقع شركة',
                        'ecommerce' => 'متجر',
                        'blog' => 'مدونة',
                        'portfolio' => 'معرض',
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
                    }),

                Tables\Columns\TextColumn::make('budget')
                    ->label('الميزانية')
                    ->money(fn ($record) => $record->currency ?? 'SAR')
                    ->sortable(),

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
                    }),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الطلب')
                    ->since()
                    ->sortable(),
            ])
            ->actions([
                Tables\Actions\Action::make('view')
                    ->label('عرض')
                    ->icon('heroicon-m-eye')
                    ->url(fn (WebsiteRequest $record): string => WebsiteRequestResource::getUrl('view', ['record' => $record])),
            ]);
    }
}
