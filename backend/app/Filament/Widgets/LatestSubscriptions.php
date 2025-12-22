<?php

namespace App\Filament\Widgets;

use App\Models\Subscription;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class LatestSubscriptions extends BaseWidget
{
    protected int | string | array $columnSpan = 'full';

    protected static ?int $sort = 2;

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Subscription::query()
                    ->with(['user'])
                    ->where('is_plan', false) // فقط الاشتراكات وليس الخطط
                    ->latest()
                    ->limit(10)
            )
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->label('المستخدم')
                    ->searchable()
                    ->sortable()
                    ->default('غير محدد'),

                Tables\Columns\TextColumn::make('name')
                    ->label('الخطة')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'الباقة المجانية', 'Free Plan' => 'gray',
                        'الباقة الأساسية', 'Basic Plan' => 'info',
                        'الباقة الاحترافية', 'Pro Plan' => 'warning',
                        'باقة الأعمال', 'Business Plan' => 'success',
                        default => 'primary',
                    }),

                Tables\Columns\TextColumn::make('status')
                    ->label('الحالة')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'active' => 'success',
                        'cancelled' => 'danger',
                        'expired' => 'warning',
                        'pending' => 'info',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'active' => 'نشط',
                        'cancelled' => 'ملغي',
                        'expired' => 'منتهي',
                        'pending' => 'معلق',
                        default => $state,
                    }),

                Tables\Columns\TextColumn::make('starts_at')
                    ->label('تاريخ البدء')
                    ->dateTime()
                    ->sortable(),

                Tables\Columns\TextColumn::make('ends_at')
                    ->label('تاريخ الانتهاء')
                    ->dateTime()
                    ->sortable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->since()
                    ->sortable(),
            ])
            ->heading('أحدث الاشتراكات');
    }
}
