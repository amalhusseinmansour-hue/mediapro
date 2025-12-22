<?php

namespace App\Services;

use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Collection;

class ExportService
{
    /**
     * Export data to CSV
     */
    public function exportToCsv(Collection $data, array $headers, string $filename): array
    {
        try {
            $csvContent = $this->generateCsv($data, $headers);
            $path = "exports/{$filename}.csv";

            Storage::disk('public')->put($path, $csvContent);

            return [
                'success' => true,
                'path' => $path,
                'url' => Storage::disk('public')->url($path),
                'filename' => "{$filename}.csv",
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Export data to JSON
     */
    public function exportToJson(Collection $data, string $filename): array
    {
        try {
            $jsonContent = json_encode($data->toArray(), JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
            $path = "exports/{$filename}.json";

            Storage::disk('public')->put($path, $jsonContent);

            return [
                'success' => true,
                'path' => $path,
                'url' => Storage::disk('public')->url($path),
                'filename' => "{$filename}.json",
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Export users report
     */
    public function exportUsersReport(Collection $users, string $format = 'csv'): array
    {
        $filename = 'users_report_' . date('Y-m-d_His');

        $headers = [
            'ID', 'الاسم', 'البريد الإلكتروني', 'الهاتف', 'النوع',
            'الحالة', 'تاريخ التسجيل', 'آخر دخول'
        ];

        $data = $users->map(function ($user) {
            return [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone_number ?? '-',
                'type' => $user->user_type ?? 'user',
                'status' => $user->is_active ? 'نشط' : 'غير نشط',
                'created_at' => $user->created_at?->format('Y-m-d H:i'),
                'last_login' => $user->last_login_at?->format('Y-m-d H:i') ?? '-',
            ];
        });

        return $format === 'json'
            ? $this->exportToJson($data, $filename)
            : $this->exportToCsv($data, $headers, $filename);
    }

    /**
     * Export payments report
     */
    public function exportPaymentsReport(Collection $payments, string $format = 'csv'): array
    {
        $filename = 'payments_report_' . date('Y-m-d_His');

        $headers = [
            'ID', 'المستخدم', 'المبلغ', 'العملة', 'الحالة',
            'طريقة الدفع', 'تاريخ الإنشاء', 'تاريخ الدفع'
        ];

        $data = $payments->map(function ($payment) {
            return [
                'id' => $payment->id,
                'user' => $payment->user?->name ?? 'غير معروف',
                'amount' => $payment->amount,
                'currency' => $payment->currency ?? 'AED',
                'status' => $this->translateStatus($payment->status),
                'method' => $payment->payment_method ?? '-',
                'created_at' => $payment->created_at?->format('Y-m-d H:i'),
                'paid_at' => $payment->paid_at?->format('Y-m-d H:i') ?? '-',
            ];
        });

        return $format === 'json'
            ? $this->exportToJson($data, $filename)
            : $this->exportToCsv($data, $headers, $filename);
    }

    /**
     * Export posts report
     */
    public function exportPostsReport(Collection $posts, string $format = 'csv'): array
    {
        $filename = 'posts_report_' . date('Y-m-d_His');

        $headers = [
            'ID', 'المستخدم', 'المحتوى', 'المنصات', 'الحالة',
            'تاريخ الإنشاء', 'تاريخ النشر'
        ];

        $data = $posts->map(function ($post) {
            return [
                'id' => $post->id,
                'user' => $post->user?->name ?? 'غير معروف',
                'content' => mb_substr($post->content ?? '', 0, 100) . '...',
                'platforms' => is_array($post->platforms) ? implode(', ', $post->platforms) : $post->platforms,
                'status' => $this->translateStatus($post->status),
                'created_at' => $post->created_at?->format('Y-m-d H:i'),
                'published_at' => $post->published_at?->format('Y-m-d H:i') ?? '-',
            ];
        });

        return $format === 'json'
            ? $this->exportToJson($data, $filename)
            : $this->exportToCsv($data, $headers, $filename);
    }

    /**
     * Export subscriptions report
     */
    public function exportSubscriptionsReport(Collection $subscriptions, string $format = 'csv'): array
    {
        $filename = 'subscriptions_report_' . date('Y-m-d_His');

        $headers = [
            'ID', 'المستخدم', 'الخطة', 'الحالة', 'المبلغ',
            'تاريخ البدء', 'تاريخ الانتهاء'
        ];

        $data = $subscriptions->map(function ($sub) {
            return [
                'id' => $sub->id,
                'user' => $sub->user?->name ?? 'غير معروف',
                'plan' => $sub->plan?->name ?? 'غير معروف',
                'status' => $this->translateStatus($sub->status),
                'amount' => $sub->amount ?? '-',
                'starts_at' => $sub->starts_at?->format('Y-m-d'),
                'ends_at' => $sub->ends_at?->format('Y-m-d') ?? '-',
            ];
        });

        return $format === 'json'
            ? $this->exportToJson($data, $filename)
            : $this->exportToCsv($data, $headers, $filename);
    }

    /**
     * Export analytics data
     */
    public function exportAnalytics(array $data, string $reportType, string $format = 'csv'): array
    {
        $filename = "{$reportType}_analytics_" . date('Y-m-d_His');

        $collection = collect($data);

        if ($format === 'json') {
            return $this->exportToJson($collection, $filename);
        }

        // Generate headers from first item
        $headers = !empty($data) ? array_keys($data[0]) : [];

        return $this->exportToCsv($collection, $headers, $filename);
    }

    /**
     * Generate CSV content
     */
    protected function generateCsv(Collection $data, array $headers): string
    {
        $output = fopen('php://temp', 'r+');

        // Add BOM for Excel UTF-8 compatibility
        fprintf($output, chr(0xEF) . chr(0xBB) . chr(0xBF));

        // Write headers
        fputcsv($output, $headers);

        // Write data
        foreach ($data as $row) {
            fputcsv($output, array_values(is_array($row) ? $row : $row->toArray()));
        }

        rewind($output);
        $content = stream_get_contents($output);
        fclose($output);

        return $content;
    }

    /**
     * Translate status to Arabic
     */
    protected function translateStatus(string $status): string
    {
        return match ($status) {
            'active' => 'نشط',
            'inactive' => 'غير نشط',
            'pending' => 'قيد الانتظار',
            'completed' => 'مكتمل',
            'failed' => 'فاشل',
            'cancelled' => 'ملغي',
            'published' => 'منشور',
            'scheduled' => 'مجدول',
            'draft' => 'مسودة',
            default => $status,
        };
    }

    /**
     * Clean old export files
     */
    public function cleanOldExports(int $daysOld = 7): int
    {
        $files = Storage::disk('public')->files('exports');
        $deleted = 0;

        foreach ($files as $file) {
            $lastModified = Storage::disk('public')->lastModified($file);
            if ($lastModified < now()->subDays($daysOld)->timestamp) {
                Storage::disk('public')->delete($file);
                $deleted++;
            }
        }

        return $deleted;
    }
}
