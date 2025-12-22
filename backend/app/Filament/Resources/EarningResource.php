<?php
namespace App\Filament\Resources;
use App\Filament\Resources\EarningResource\Pages;
use App\Models\Earning;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class EarningResource extends Resource
{
    protected static ?string $model = Earning::class;
    protected static ?string $navigationIcon = 'heroicon-o-currency-dollar';
    protected static ?string $navigationGroup = 'المالية';
    protected static ?string $navigationLabel = 'الأرباح';
    protected static ?string $modelLabel = 'ربح';
    protected static ?string $pluralModelLabel = 'الأرباح';

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('#')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('user.name')
                    ->label('المستخدم')
                    ->searchable()
                    ->limit(25)
                    ->wrap(),
                Tables\Columns\TextColumn::make('subscription.plan.name')
                    ->label('الخطة')
                    ->limit(20)
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('amount')
                    ->label('المبلغ')
                    ->money('USD')
                    ->sortable(),
                Tables\Columns\TextColumn::make('type')
                    ->label('النوع')
                    ->badge(),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('التاريخ')
                    ->since()
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('type')->label('النوع')
                    ->options(['subscription' => 'اشتراك', 'renewal' => 'تجديد', 'upgrade' => 'ترقية']),
            ])
            ->defaultSort('created_at', 'desc');
    }

    public static function getPages(): array
    {
        return ['index' => Pages\ListEarnings::route('/'), 'view' => Pages\ViewEarning::route('/{record}')];
    }
    
    public static function canCreate(): bool { return false; }
}
