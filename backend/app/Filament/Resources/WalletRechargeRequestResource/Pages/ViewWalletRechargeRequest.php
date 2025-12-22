<?php

namespace App\Filament\Resources\WalletRechargeRequestResource\Pages;

use App\Filament\Resources\WalletRechargeRequestResource;
use App\Models\WalletRechargeRequest;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;
use Filament\Notifications\Notification;
use Filament\Forms;

class ViewWalletRechargeRequest extends ViewRecord
{
    protected static string $resource = WalletRechargeRequestResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\Action::make('approve')
                ->label('قبول الطلب')
                ->icon('heroicon-o-check-circle')
                ->color('success')
                ->requiresConfirmation()
                ->modalHeading('قبول طلب الشحن')
                ->modalDescription('هل أنت متأكد من قبول هذا الطلب؟ سيتم إضافة المبلغ إلى محفظة المستخدم.')
                ->form([
                    Forms\Components\Textarea::make('admin_notes')
                        ->label('ملاحظات الإدارة (اختياري)')
                        ->rows(3),
                ])
                ->action(function (array $data) {
                    $admin = auth()->user();
                    $record = $this->record;

                    if ($record->approve($admin->id, $data['admin_notes'] ?? null)) {
                        Notification::make()
                            ->title('تم قبول الطلب بنجاح')
                            ->success()
                            ->send();

                        $this->refreshFormData([
                            'status',
                            'admin_notes',
                            'processed_by',
                            'processed_at',
                        ]);
                    } else {
                        Notification::make()
                            ->title('فشل قبول الطلب')
                            ->danger()
                            ->send();
                    }
                })
                ->visible(fn (): bool => $this->record->isPending()),

            Actions\Action::make('reject')
                ->label('رفض الطلب')
                ->icon('heroicon-o-x-circle')
                ->color('danger')
                ->requiresConfirmation()
                ->modalHeading('رفض طلب الشحن')
                ->modalDescription('هل أنت متأكد من رفض هذا الطلب؟')
                ->form([
                    Forms\Components\Textarea::make('admin_notes')
                        ->label('سبب الرفض (اختياري)')
                        ->rows(3),
                ])
                ->action(function (array $data) {
                    $admin = auth()->user();
                    $record = $this->record;

                    if ($record->reject($admin->id, $data['admin_notes'] ?? null)) {
                        Notification::make()
                            ->title('تم رفض الطلب')
                            ->success()
                            ->send();

                        $this->refreshFormData([
                            'status',
                            'admin_notes',
                            'processed_by',
                            'processed_at',
                        ]);
                    } else {
                        Notification::make()
                            ->title('فشل رفض الطلب')
                            ->danger()
                            ->send();
                    }
                })
                ->visible(fn (): bool => $this->record->isPending()),
        ];
    }
}
