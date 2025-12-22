<?php

namespace App\Filament\Resources\ConnectedAccountResource\Pages;

use App\Filament\Resources\ConnectedAccountResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;
use Filament\Infolists;
use Filament\Infolists\Infolist;

class ViewConnectedAccount extends ViewRecord
{
    protected static string $resource = ConnectedAccountResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make()
                ->label('تعديل'),
            Actions\DeleteAction::make()
                ->label('حذف'),
        ];
    }

    public function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                Infolists\Components\Section::make('معلومات المستخدم')
                    ->schema([
                        Infolists\Components\TextEntry::make('user.name')
                            ->label('المستخدم'),
                        Infolists\Components\TextEntry::make('user.email')
                            ->label('البريد الإلكتروني'),
                    ])
                    ->columns(2),

                Infolists\Components\Section::make('معلومات الحساب المربوط')
                    ->schema([
                        Infolists\Components\TextEntry::make('platform_name')
                            ->label('المنصة')
                            ->badge()
                            ->color(fn ($record): string => match ($record->platform) {
                                'facebook' => 'info',
                                'instagram' => 'danger',
                                'twitter' => 'primary',
                                'linkedin' => 'info',
                                'tiktok' => 'gray',
                                'youtube' => 'danger',
                                default => 'gray',
                            }),

                        Infolists\Components\TextEntry::make('platform_user_id')
                            ->label('معرف المنصة')
                            ->copyable(),

                        Infolists\Components\TextEntry::make('username')
                            ->label('اسم المستخدم')
                            ->copyable(),

                        Infolists\Components\TextEntry::make('display_name')
                            ->label('الاسم المعروض'),

                        Infolists\Components\TextEntry::make('email')
                            ->label('البريد الإلكتروني'),

                        Infolists\Components\ImageEntry::make('profile_picture')
                            ->label('الصورة الشخصية')
                            ->circular(),

                        Infolists\Components\IconEntry::make('is_active')
                            ->label('الحالة')
                            ->boolean()
                            ->trueIcon('heroicon-o-check-circle')
                            ->falseIcon('heroicon-o-x-circle')
                            ->trueColor('success')
                            ->falseColor('danger'),
                    ])
                    ->columns(3),

                Infolists\Components\Section::make('معلومات الـ Token')
                    ->schema([
                        Infolists\Components\TextEntry::make('access_token')
                            ->label('Access Token')
                            ->columnSpanFull()
                            ->copyable()
                            ->limit(50),

                        Infolists\Components\TextEntry::make('token_expires_at')
                            ->label('تاريخ انتهاء Token')
                            ->dateTime('Y-m-d H:i:s')
                            ->color(fn ($record): string =>
                                $record->isTokenExpired() ? 'danger' : 'success'
                            )
                            ->icon(fn ($record): string =>
                                $record->isTokenExpired() ? 'heroicon-o-exclamation-triangle' : 'heroicon-o-check-circle'
                            ),

                        Infolists\Components\TextEntry::make('scopes')
                            ->label('الصلاحيات')
                            ->badge()
                            ->columnSpanFull(),
                    ])
                    ->columns(2),

                Infolists\Components\Section::make('التواريخ')
                    ->schema([
                        Infolists\Components\TextEntry::make('connected_at')
                            ->label('تاريخ الربط')
                            ->dateTime('Y-m-d H:i:s'),

                        Infolists\Components\TextEntry::make('last_used_at')
                            ->label('آخر استخدام')
                            ->dateTime('Y-m-d H:i:s')
                            ->since(),

                        Infolists\Components\TextEntry::make('created_at')
                            ->label('تاريخ الإنشاء')
                            ->dateTime('Y-m-d H:i:s'),

                        Infolists\Components\TextEntry::make('updated_at')
                            ->label('آخر تحديث')
                            ->dateTime('Y-m-d H:i:s'),
                    ])
                    ->columns(2),

                Infolists\Components\Section::make('البيانات الإضافية')
                    ->schema([
                        Infolists\Components\KeyValueEntry::make('metadata')
                            ->label('Metadata')
                            ->columnSpanFull(),
                    ])
                    ->collapsible()
                    ->collapsed(),
            ]);
    }
}
