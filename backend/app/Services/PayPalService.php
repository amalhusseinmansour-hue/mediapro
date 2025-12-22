<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Http\Request;

class PayPalService
{
    protected string $baseUrl;
    protected string $clientId;
    protected string $secret;

    public function __construct()
    {
        $this->baseUrl = config('services.paypal.mode') === 'live'
            ? 'https://api-m.paypal.com'
            : 'https://api-m.sandbox.paypal.com';

        $this->clientId = config('services.paypal.client_id');
        $this->secret = config('services.paypal.secret');
    }

    /**
     * الحصول على Access Token
     */
    protected function getAccessToken(): string
    {
        $response = Http::asForm()
            ->withBasicAuth($this->clientId, $this->secret)
            ->post($this->baseUrl . '/v1/oauth2/token', [
                'grant_type' => 'client_credentials',
            ]);

        if ($response->failed()) {
            throw new \Exception('فشل الحصول على PayPal access token');
        }

        return $response->json()['access_token'];
    }

    /**
     * إنشاء طلب
     */
    public function createOrder(float $amount, string $currency = 'USD'): array
    {
        $token = $this->getAccessToken();

        $response = Http::withToken($token)
            ->post($this->baseUrl . '/v2/checkout/orders', [
                'intent' => 'CAPTURE',
                'purchase_units' => [
                    [
                        'amount' => [
                            'currency_code' => $currency,
                            'value' => number_format($amount, 2, '.', ''),
                        ],
                    ],
                ],
                'application_context' => [
                    'return_url' => config('app.url') . '/api/v1/payments/paypal/success',
                    'cancel_url' => config('app.url') . '/api/v1/payments/paypal/cancel',
                ],
            ]);

        if ($response->failed()) {
            throw new \Exception('فشل إنشاء طلب PayPal: ' . $response->body());
        }

        return $response->json();
    }

    /**
     * إلتقاط طلب
     */
    public function captureOrder(string $orderId): array
    {
        $token = $this->getAccessToken();

        $response = Http::withToken($token)
            ->post($this->baseUrl . "/v2/checkout/orders/{$orderId}/capture");

        if ($response->failed()) {
            throw new \Exception('فشل التقاط طلب PayPal: ' . $response->body());
        }

        return $response->json();
    }

    /**
     * استرداد دفعة
     */
    public function refund(string $captureId, ?float $amount = null): array
    {
        $token = $this->getAccessToken();

        $data = [];
        if ($amount) {
            $data['amount'] = [
                'value' => number_format($amount, 2, '.', ''),
                'currency_code' => 'USD',
            ];
        }

        $response = Http::withToken($token)
            ->post($this->baseUrl . "/v2/payments/captures/{$captureId}/refund", $data);

        if ($response->failed()) {
            throw new \Exception('فشل استرداد دفعة PayPal: ' . $response->body());
        }

        return $response->json();
    }

    /**
     * معالجة Webhook
     */
    public function handleWebhook(Request $request)
    {
        $payload = $request->all();

        // التحقق من صحة الـ webhook
        if (!$this->verifyWebhook($request)) {
            throw new \Exception('فشل التحقق من PayPal webhook');
        }

        // معالجة الأحداث المختلفة
        $eventType = $payload['event_type'] ?? null;

        switch ($eventType) {
            case 'PAYMENT.CAPTURE.COMPLETED':
                $this->handlePaymentCaptured($payload);
                break;

            case 'PAYMENT.CAPTURE.REFUNDED':
                $this->handlePaymentRefunded($payload);
                break;

            default:
                \Log::info('PayPal webhook event', ['type' => $eventType]);
                break;
        }

        return $payload;
    }

    /**
     * التحقق من Webhook
     */
    protected function verifyWebhook(Request $request): bool
    {
        // يمكن إضافة منطق التحقق من الـ webhook هنا
        // PayPal يستخدم cert_url و transmission_sig للتحقق
        return true;
    }

    /**
     * معالجة نجاح الدفع
     */
    protected function handlePaymentCaptured(array $payload)
    {
        \Log::info('PayPal payment captured', $payload);
    }

    /**
     * معالجة الاسترداد
     */
    protected function handlePaymentRefunded(array $payload)
    {
        \Log::info('PayPal payment refunded', $payload);
    }
}
