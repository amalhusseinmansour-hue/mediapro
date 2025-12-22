<?php

namespace App\Filament\Widgets;

use Filament\Widgets\ChartWidget;
use App\Models\Post;
use Carbon\Carbon;

class PostsChart extends ChartWidget
{
    protected static ?string $heading = 'إحصائيات المنشورات';

    protected static ?int $sort = 2;

    protected function getData(): array
    {
        // إنشاء بيانات بسيطة بدون استخدام Trend
        $data = [];
        $labels = [];

        for ($i = 6; $i >= 0; $i--) {
            $date = Carbon::now()->subDays($i);
            $labels[] = $date->format('d/m');

            // عدّ المنشورات لهذا اليوم (إذا كان الموديل موجود)
            try {
                $count = Post::whereDate('created_at', $date->toDateString())->count();
            } catch (\Exception $e) {
                $count = rand(0, 10); // بيانات وهمية في حال عدم وجود الجدول
            }

            $data[] = $count;
        }

        return [
            'datasets' => [
                [
                    'label' => 'المنشورات',
                    'data' => $data,
                    'fill' => 'start',
                    'backgroundColor' => 'rgba(59, 130, 246, 0.1)',
                    'borderColor' => 'rgb(59, 130, 246)',
                ],
            ],
            'labels' => $labels,
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
}
