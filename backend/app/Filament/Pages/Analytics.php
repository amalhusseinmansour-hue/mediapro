<?php

namespace App\Filament\Pages;

use App\Models\User;
use App\Models\SocialAccount;
use App\Models\SocialMediaPost;
use App\Models\PlatformPost;
use App\Models\Subscription;
use Filament\Pages\Page;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use Filament\Forms\Form;
use Illuminate\Support\Facades\DB;

class Analytics extends Page implements HasForms
{
    use InteractsWithForms;

    protected static ?string $navigationIcon = 'heroicon-o-chart-bar';

    protected static string $view = 'filament.pages.analytics';

    protected static ?string $navigationLabel = 'Analytics';

    protected static ?string $title = 'Analytics & Reports';

    protected static ?string $navigationGroup = 'Reports';

    protected static ?int $navigationSort = 1;

    public ?array $data = [];

    public ?string $period = 'month';
    public ?string $dateFrom = null;
    public ?string $dateTo = null;

    public function mount(): void
    {
        $this->form->fill([
            'period' => 'month',
            'date_from' => now()->subMonth(),
            'date_to' => now(),
        ]);
    }

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Select::make('period')
                    ->label('Time Period')
                    ->options([
                        'day' => 'Today',
                        'week' => 'This Week',
                        'month' => 'This Month',
                        'year' => 'This Year',
                        'custom' => 'Custom Range',
                    ])
                    ->default('month')
                    ->reactive()
                    ->native(false),

                DatePicker::make('date_from')
                    ->label('From Date')
                    ->visible(fn ($get) => $get('period') === 'custom')
                    ->native(false),

                DatePicker::make('date_to')
                    ->label('To Date')
                    ->visible(fn ($get) => $get('period') === 'custom')
                    ->native(false),
            ])
            ->statePath('data')
            ->columns(3);
    }

    public function getOverviewStats(): array
    {
        $period = $this->data['period'] ?? 'month';
        $dateRange = $this->getDateRange($period);

        return [
            'total_users' => User::count(),
            'new_users' => User::whereBetween('created_at', $dateRange)->count(),
            'total_posts' => SocialMediaPost::count(),
            'posts_in_period' => SocialMediaPost::whereBetween('created_at', $dateRange)->count(),
            'total_accounts' => SocialAccount::count(),
            'active_accounts' => SocialAccount::where('is_active', true)->count(),
            'total_subscriptions' => Subscription::count(),
            'active_subscriptions' => Subscription::where('status', 'active')->count(),
            'published_posts' => SocialMediaPost::where('status', 'published')->count(),
            'scheduled_posts' => SocialMediaPost::where('status', 'scheduled')->count(),
            'failed_posts' => SocialMediaPost::where('status', 'failed')->count(),
        ];
    }

    public function getPlatformStats(): array
    {
        return SocialAccount::select('platform', DB::raw('count(*) as total'))
            ->where('is_active', true)
            ->groupBy('platform')
            ->pluck('total', 'platform')
            ->toArray();
    }

    public function getTopUsers(): array
    {
        return User::select('users.id', 'users.name', 'users.email')
            ->leftJoin('social_media_posts', 'users.id', '=', 'social_media_posts.user_id')
            ->selectRaw('COUNT(social_media_posts.id) as posts_count')
            ->groupBy('users.id', 'users.name', 'users.email')
            ->orderByDesc('posts_count')
            ->limit(10)
            ->get()
            ->toArray();
    }

    public function getRecentPosts(): array
    {
        return SocialMediaPost::with('user')
            ->latest()
            ->limit(10)
            ->get()
            ->map(fn ($post) => [
                'id' => $post->id,
                'user' => $post->user->name ?? 'N/A',
                'content' => str($post->content)->limit(50),
                'status' => $post->status,
                'platforms' => $post->platforms,
                'created_at' => $post->created_at->format('Y-m-d H:i'),
            ])
            ->toArray();
    }

    public function getPlatformPerformance(): array
    {
        $period = $this->data['period'] ?? 'month';
        $dateRange = $this->getDateRange($period);

        return PlatformPost::select('platform',
            DB::raw('COUNT(*) as total'),
            DB::raw('SUM(CASE WHEN status = "published" THEN 1 ELSE 0 END) as published'),
            DB::raw('SUM(CASE WHEN status = "failed" THEN 1 ELSE 0 END) as failed'),
            DB::raw('SUM(CASE WHEN status = "pending" THEN 1 ELSE 0 END) as pending')
        )
        ->whereBetween('created_at', $dateRange)
        ->groupBy('platform')
        ->get()
        ->map(fn ($item) => [
            'platform' => ucfirst($item->platform),
            'total' => $item->total,
            'published' => $item->published,
            'failed' => $item->failed,
            'pending' => $item->pending,
            'success_rate' => $item->total > 0 ? round(($item->published / $item->total) * 100, 2) : 0,
        ])
        ->toArray();
    }

    protected function getDateRange(string $period): array
    {
        return match($period) {
            'day' => [now()->startOfDay(), now()->endOfDay()],
            'week' => [now()->startOfWeek(), now()->endOfWeek()],
            'month' => [now()->startOfMonth(), now()->endOfMonth()],
            'year' => [now()->startOfYear(), now()->endOfYear()],
            'custom' => [
                $this->data['date_from'] ?? now()->subMonth(),
                $this->data['date_to'] ?? now(),
            ],
            default => [now()->startOfMonth(), now()->endOfMonth()],
        };
    }

    public function exportCsv(): void
    {
        $stats = $this->getOverviewStats();
        $platformPerformance = $this->getPlatformPerformance();

        $filename = 'analytics_' . now()->format('Y-m-d_His') . '.csv';
        $handle = fopen('php://output', 'w');

        header('Content-Type: text/csv');
        header('Content-Disposition: attachment; filename="' . $filename . '"');

        // Overview Stats
        fputcsv($handle, ['Analytics Report - ' . now()->format('Y-m-d H:i:s')]);
        fputcsv($handle, []);
        fputcsv($handle, ['Overview Statistics']);
        foreach ($stats as $key => $value) {
            fputcsv($handle, [ucwords(str_replace('_', ' ', $key)), $value]);
        }

        // Platform Performance
        fputcsv($handle, []);
        fputcsv($handle, ['Platform Performance']);
        fputcsv($handle, ['Platform', 'Total', 'Published', 'Failed', 'Pending', 'Success Rate (%)']);
        foreach ($platformPerformance as $platform) {
            fputcsv($handle, [
                $platform['platform'],
                $platform['total'],
                $platform['published'],
                $platform['failed'],
                $platform['pending'],
                $platform['success_rate'],
            ]);
        }

        fclose($handle);
        exit;
    }
}
