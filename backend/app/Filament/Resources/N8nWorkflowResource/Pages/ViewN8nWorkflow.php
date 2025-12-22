<?php

namespace App\Filament\Resources\N8nWorkflowResource\Pages;

use App\Filament\Resources\N8nWorkflowResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;
use Filament\Infolists;
use Filament\Infolists\Infolist;

class ViewN8nWorkflow extends ViewRecord
{
    protected static string $resource = N8nWorkflowResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
            Actions\DeleteAction::make(),
        ];
    }

    public function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                Infolists\Components\Section::make('معلومات Workflow')
                    ->schema([
                        Infolists\Components\TextEntry::make('name')
                            ->label('الاسم'),
                        Infolists\Components\TextEntry::make('workflow_id')
                            ->label('Workflow ID')
                            ->copyable()
                            ->copyMessage('تم النسخ!'),
                        Infolists\Components\TextEntry::make('description')
                            ->label('الوصف'),
                        Infolists\Components\TextEntry::make('platform')
                            ->label('المنصة')
                            ->badge()
                            ->color(fn (string $state): string => match ($state) {
                                'instagram' => 'success',
                                'tiktok' => 'warning',
                                'youtube' => 'danger',
                                'facebook' => 'primary',
                                default => 'gray',
                            }),
                        Infolists\Components\TextEntry::make('type')
                            ->label('نوع المحتوى')
                            ->badge(),
                        Infolists\Components\IconEntry::make('is_active')
                            ->label('نشط')
                            ->boolean(),
                    ])
                    ->columns(2),

                Infolists\Components\Section::make('إعدادات N8N')
                    ->schema([
                        Infolists\Components\TextEntry::make('n8n_url')
                            ->label('N8N URL')
                            ->placeholder('غير مكون'),
                        Infolists\Components\TextEntry::make('credential_id')
                            ->label('Credential ID'),
                        Infolists\Components\TextEntry::make('upload_post_user')
                            ->label('Upload Post User'),
                    ])
                    ->columns(3),

                Infolists\Components\Section::make('إحصائيات')
                    ->schema([
                        Infolists\Components\TextEntry::make('execution_count')
                            ->label('عدد مرات التنفيذ')
                            ->numeric(),
                        Infolists\Components\TextEntry::make('last_executed_at')
                            ->label('آخر تنفيذ')
                            ->dateTime('Y-m-d H:i:s')
                            ->placeholder('لم يتم التنفيذ بعد'),
                        Infolists\Components\TextEntry::make('created_at')
                            ->label('تاريخ الإنشاء')
                            ->dateTime('Y-m-d H:i:s'),
                        Infolists\Components\TextEntry::make('updated_at')
                            ->label('آخر تحديث')
                            ->dateTime('Y-m-d H:i:s'),
                    ])
                    ->columns(2),

                Infolists\Components\Section::make('Workflow JSON')
                    ->schema([
                        Infolists\Components\TextEntry::make('workflow_json')
                            ->label('Workflow JSON')
                            ->formatStateUsing(fn ($state) => json_encode($state, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE))
                            ->markdown()
                            ->copyable(),
                    ])
                    ->collapsible()
                    ->collapsed(true),

                Infolists\Components\Section::make('Input Schema')
                    ->schema([
                        Infolists\Components\TextEntry::make('input_schema')
                            ->label('Input Schema')
                            ->formatStateUsing(fn ($state) => json_encode($state, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE))
                            ->markdown()
                            ->copyable(),
                    ])
                    ->collapsible()
                    ->collapsed(true),
            ]);
    }
}
