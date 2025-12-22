<?php

namespace App\Filament\Resources;

use App\Filament\Resources\N8nWorkflowResource\Pages;
use App\Models\N8nWorkflow;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Support\Enums\FontWeight;
use Filament\Tables\Filters\SelectFilter;

class N8nWorkflowResource extends Resource
{
    protected static ?string $model = N8nWorkflow::class;

    protected static ?string $navigationIcon = 'heroicon-o-bolt';

    protected static ?string $navigationLabel = 'N8N Workflows';

    protected static ?string $modelLabel = 'N8N Workflow';

    protected static ?string $pluralModelLabel = 'N8N Workflows';

    protected static ?string $navigationGroup = 'Social Media';

    protected static ?int $navigationSort = 3;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('معلومات Workflow')
                    ->schema([
                        Forms\Components\TextInput::make('workflow_id')
                            ->label('Workflow ID')
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->maxLength(255),

                        Forms\Components\TextInput::make('name')
                            ->label('اسم Workflow')
                            ->required()
                            ->maxLength(255),

                        Forms\Components\Textarea::make('description')
                            ->label('الوصف')
                            ->maxLength(65535)
                            ->rows(2),

                        Forms\Components\Select::make('platform')
                            ->label('المنصة')
                            ->options([
                                'instagram' => 'Instagram',
                                'tiktok' => 'TikTok',
                                'youtube' => 'YouTube',
                                'facebook' => 'Facebook',
                                'twitter' => 'Twitter',
                                'linkedin' => 'LinkedIn',
                            ])
                            ->required(),

                        Forms\Components\Select::make('type')
                            ->label('نوع المحتوى')
                            ->options([
                                'video' => 'Video',
                                'image' => 'Image',
                                'text' => 'Text',
                                'carousel' => 'Carousel',
                            ])
                            ->default('video')
                            ->required(),

                        Forms\Components\Toggle::make('is_active')
                            ->label('نشط')
                            ->default(true),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('إعدادات N8N')
                    ->schema([
                        Forms\Components\TextInput::make('n8n_url')
                            ->label('N8N URL')
                            ->url()
                            ->placeholder('https://your-n8n-instance.com')
                            ->maxLength(255),

                        Forms\Components\TextInput::make('credential_id')
                            ->label('Upload Post Credential ID')
                            ->maxLength(255),

                        Forms\Components\TextInput::make('upload_post_user')
                            ->label('Upload Post Username')
                            ->default('uploadn8n')
                            ->maxLength(255),
                    ])
                    ->columns(3),

                Forms\Components\Section::make('Workflow JSON')
                    ->schema([
                        Forms\Components\Textarea::make('workflow_json')
                            ->label('Workflow JSON')
                            ->required()
                            ->rows(10)
                            ->formatStateUsing(fn ($state) => is_array($state) ? json_encode($state, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) : $state)
                            ->dehydrateStateUsing(fn ($state) => json_decode($state, true)),
                    ])
                    ->collapsible()
                    ->collapsed(true),

                Forms\Components\Section::make('Input Schema')
                    ->schema([
                        Forms\Components\Textarea::make('input_schema')
                            ->label('Input Schema (JSON)')
                            ->rows(8)
                            ->formatStateUsing(fn ($state) => is_array($state) ? json_encode($state, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) : $state)
                            ->dehydrateStateUsing(fn ($state) => json_decode($state, true)),
                    ])
                    ->collapsible()
                    ->collapsed(true),

                Forms\Components\Section::make('إحصائيات')
                    ->schema([
                        Forms\Components\TextInput::make('execution_count')
                            ->label('عدد مرات التنفيذ')
                            ->numeric()
                            ->default(0)
                            ->disabled()
                            ->dehydrated(false),

                        Forms\Components\DateTimePicker::make('last_executed_at')
                            ->label('آخر تنفيذ')
                            ->disabled()
                            ->dehydrated(false),
                    ])
                    ->columns(2)
                    ->visibleOn('edit'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('الاسم')
                    ->searchable()
                    ->sortable()
                    ->weight(FontWeight::Bold),

                Tables\Columns\TextColumn::make('workflow_id')
                    ->label('Workflow ID')
                    ->searchable()
                    ->copyable()
                    ->copyMessage('تم النسخ!')
                    ->fontFamily('mono')
                    ->color('gray'),

                Tables\Columns\BadgeColumn::make('platform')
                    ->label('المنصة')
                    ->colors([
                        'danger' => 'youtube',
                        'warning' => 'tiktok',
                        'success' => 'instagram',
                        'primary' => 'facebook',
                        'info' => 'twitter',
                    ])
                    ->icons([
                        'heroicon-o-video-camera' => 'youtube',
                        'heroicon-o-musical-note' => 'tiktok',
                        'heroicon-o-camera' => 'instagram',
                        'heroicon-o-user-group' => 'facebook',
                        'heroicon-o-chat-bubble-left' => 'twitter',
                    ])
                    ->sortable(),

                Tables\Columns\BadgeColumn::make('type')
                    ->label('النوع')
                    ->colors([
                        'success' => 'video',
                        'warning' => 'image',
                        'info' => 'text',
                    ]),

                Tables\Columns\IconColumn::make('is_active')
                    ->label('نشط')
                    ->boolean()
                    ->sortable(),

                Tables\Columns\TextColumn::make('execution_count')
                    ->label('التنفيذات')
                    ->numeric()
                    ->sortable()
                    ->alignCenter(),

                Tables\Columns\TextColumn::make('last_executed_at')
                    ->label('آخر تنفيذ')
                    ->dateTime('Y-m-d H:i')
                    ->sortable()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime('Y-m-d H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                SelectFilter::make('platform')
                    ->label('المنصة')
                    ->options([
                        'instagram' => 'Instagram',
                        'tiktok' => 'TikTok',
                        'youtube' => 'YouTube',
                        'facebook' => 'Facebook',
                        'twitter' => 'Twitter',
                    ]),

                SelectFilter::make('type')
                    ->label('النوع')
                    ->options([
                        'video' => 'Video',
                        'image' => 'Image',
                        'text' => 'Text',
                    ]),

                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('نشط')
                    ->placeholder('الكل')
                    ->trueLabel('نشط فقط')
                    ->falseLabel('غير نشط فقط'),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('created_at', 'desc');
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
            'index' => Pages\ListN8nWorkflows::route('/'),
            'create' => Pages\CreateN8nWorkflow::route('/create'),
            'view' => Pages\ViewN8nWorkflow::route('/{record}'),
            'edit' => Pages\EditN8nWorkflow::route('/{record}/edit'),
        ];
    }
}
