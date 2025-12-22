<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SocialAccountResource\Pages;
use App\Models\SocialAccount;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class SocialAccountResource extends Resource
{
    protected static ?string $model = SocialAccount::class;

    protected static ?string $navigationIcon = 'heroicon-o-share';

    protected static ?string $navigationLabel = 'Social Accounts';

    protected static ?string $modelLabel = 'Social Account';

    protected static ?string $pluralModelLabel = 'Social Accounts';

    protected static ?string $navigationGroup = 'Social Media';

    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Account Information')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->label('User')
                            ->relationship('user', 'name')
                            ->searchable()
                            ->preload()
                            ->required()
                            ->disabled(fn ($record) => $record !== null),

                        Forms\Components\Select::make('platform')
                            ->label('Platform')
                            ->options([
                                'facebook' => 'Facebook',
                                'instagram' => 'Instagram',
                                'twitter' => 'Twitter / X',
                                'linkedin' => 'LinkedIn',
                                'tiktok' => 'TikTok',
                                'youtube' => 'YouTube',
                                'pinterest' => 'Pinterest',
                                'snapchat' => 'Snapchat',
                            ])
                            ->required()
                            ->disabled(fn ($record) => $record !== null)
                            ->native(false),

                        Forms\Components\TextInput::make('account_name')
                            ->label('Account Name')
                            ->required()
                            ->maxLength(255),

                        Forms\Components\TextInput::make('account_id')
                            ->label('Account ID')
                            ->required()
                            ->disabled(fn ($record) => $record !== null)
                            ->maxLength(255),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('Token Information')
                    ->schema([
                        Forms\Components\Textarea::make('access_token')
                            ->label('Access Token')
                            ->hint('Hidden for security')
                            ->disabled()
                            ->dehydrated(false)
                            ->default('""""""""""""""""')
                            ->rows(2),

                        Forms\Components\DateTimePicker::make('expires_at')
                            ->label('Token Expires At')
                            ->native(false)
                            ->disabled(),
                    ])
                    ->columns(2)
                    ->collapsed(),

                Forms\Components\Section::make('Status')
                    ->schema([
                        Forms\Components\Toggle::make('is_active')
                            ->label('Active')
                            ->default(true)
                            ->inline(false)
                            ->helperText('Enable or disable this social account connection'),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('ID')
                    ->sortable()
                    ->searchable(),

                Tables\Columns\TextColumn::make('user.name')
                    ->label('User')
                    ->sortable()
                    ->searchable()
                    ->url(fn ($record) => route('filament.admin.resources.users.view', $record->user_id))
                    ->color('primary'),

                Tables\Columns\TextColumn::make('platform')
                    ->label('Platform')
                    ->badge()
                    ->colors([
                        'primary' => 'facebook',
                        'danger' => 'instagram',
                        'info' => 'twitter',
                        'success' => 'linkedin',
                        'warning' => 'tiktok',
                        'danger' => 'youtube',
                        'primary' => 'pinterest',
                        'warning' => 'snapchat',
                    ])
                    ->icons([
                        'heroicon-o-globe-alt' => 'facebook',
                        'heroicon-o-camera' => 'instagram',
                        'heroicon-o-chat-bubble-left' => 'twitter',
                        'heroicon-o-briefcase' => 'linkedin',
                        'heroicon-o-musical-note' => 'tiktok',
                        'heroicon-o-video-camera' => 'youtube',
                        'heroicon-o-photo' => 'pinterest',
                        'heroicon-o-bolt' => 'snapchat',
                    ])
                    ->formatStateUsing(fn (string $state): string => ucfirst($state))
                    ->sortable()
                    ->searchable(),

                Tables\Columns\TextColumn::make('account_name')
                    ->label('Account Name')
                    ->searchable()
                    ->sortable()
                    ->weight('medium'),

                Tables\Columns\TextColumn::make('account_id')
                    ->label('Account ID')
                    ->searchable()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\IconColumn::make('is_active')
                    ->label('Status')
                    ->boolean()
                    ->trueIcon('heroicon-o-check-circle')
                    ->falseIcon('heroicon-o-x-circle')
                    ->trueColor('success')
                    ->falseColor('danger')
                    ->sortable(),

                Tables\Columns\TextColumn::make('expires_at')
                    ->label('Token Expires')
                    ->dateTime('Y-m-d H:i')
                    ->sortable()
                    ->color(fn ($record) => $record->expires_at && $record->expires_at->isPast() ? 'danger' : 'success')
                    ->icon(fn ($record) => $record->expires_at && $record->expires_at->isPast() ? 'heroicon-o-exclamation-triangle' : 'heroicon-o-check-circle')
                    ->toggleable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Connected At')
                    ->dateTime('Y-m-d H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('updated_at')
                    ->label('Updated At')
                    ->dateTime('Y-m-d H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('platform')
                    ->label('Platform')
                    ->options([
                        'facebook' => 'Facebook',
                        'instagram' => 'Instagram',
                        'twitter' => 'Twitter / X',
                        'linkedin' => 'LinkedIn',
                        'tiktok' => 'TikTok',
                        'youtube' => 'YouTube',
                        'pinterest' => 'Pinterest',
                        'snapchat' => 'Snapchat',
                    ])
                    ->multiple()
                    ->native(false),

                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Status')
                    ->boolean()
                    ->trueLabel('Active Only')
                    ->falseLabel('Inactive Only')
                    ->native(false),

                Tables\Filters\Filter::make('expired')
                    ->label('Token Expired')
                    ->query(fn (Builder $query) => $query->where('expires_at', '<', now()))
                    ->toggle(),

                Tables\Filters\SelectFilter::make('user')
                    ->label('User')
                    ->relationship('user', 'name')
                    ->searchable()
                    ->preload()
                    ->multiple()
                    ->native(false),

                Tables\Filters\Filter::make('created_at')
                    ->form([
                        Forms\Components\DatePicker::make('created_from')
                            ->label('Connected From')
                            ->native(false),
                        Forms\Components\DatePicker::make('created_until')
                            ->label('Connected Until')
                            ->native(false),
                    ])
                    ->query(function (Builder $query, array $data): Builder {
                        return $query
                            ->when(
                                $data['created_from'],
                                fn (Builder $query, $date): Builder => $query->whereDate('created_at', '>=', $date),
                            )
                            ->when(
                                $data['created_until'],
                                fn (Builder $query, $date): Builder => $query->whereDate('created_at', '<=', $date),
                            );
                    }),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),

                Tables\Actions\Action::make('toggle_status')
                    ->label(fn ($record) => $record->is_active ? 'Deactivate' : 'Activate')
                    ->icon(fn ($record) => $record->is_active ? 'heroicon-o-x-circle' : 'heroicon-o-check-circle')
                    ->color(fn ($record) => $record->is_active ? 'danger' : 'success')
                    ->action(function ($record) {
                        $record->update(['is_active' => !$record->is_active]);
                    })
                    ->requiresConfirmation()
                    ->modalHeading(fn ($record) => $record->is_active ? 'Deactivate Account' : 'Activate Account')
                    ->modalDescription(fn ($record) => $record->is_active
                        ? 'Are you sure you want to deactivate this social account connection?'
                        : 'Are you sure you want to activate this social account connection?'
                    ),

                Tables\Actions\DeleteAction::make()
                    ->modalHeading('Delete Social Account Connection')
                    ->modalDescription('Are you sure you want to delete this connection? This action cannot be undone.'),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\BulkAction::make('activate')
                        ->label('Activate Selected')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->action(function ($records) {
                            $records->each->update(['is_active' => true]);
                        })
                        ->requiresConfirmation()
                        ->deselectRecordsAfterCompletion(),

                    Tables\Actions\BulkAction::make('deactivate')
                        ->label('Deactivate Selected')
                        ->icon('heroicon-o-x-circle')
                        ->color('danger')
                        ->action(function ($records) {
                            $records->each->update(['is_active' => false]);
                        })
                        ->requiresConfirmation()
                        ->deselectRecordsAfterCompletion(),

                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->emptyStateHeading('No social accounts connected')
            ->emptyStateDescription('Users will see their connected social accounts here once they connect them from the app.')
            ->emptyStateIcon('heroicon-o-share');
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
            'index' => Pages\ListSocialAccounts::route('/'),
            'create' => Pages\CreateSocialAccount::route('/create'),

            'edit' => Pages\EditSocialAccount::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::where('is_active', true)->count();
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'success';
    }
}
