<?php

namespace App\Services;

use App\Models\Setting;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class PaymobService
{
    protected $publicKey;
    protected $secretKey;
    protected $integrationId;
    protected $hmacSecret;
    protected $currency;
    protected $baseUrl;

    public function __construct()
    {
        // Get credentials from .env (Paymob UAE API v2)
        $this->publicKey = env('PAYMOB_PUBLIC_KEY');
        $this->secretKey = env('PAYMOB_SECRET_KEY');
        $this->integrationId = env('PAYMOB_INTEGRATION_ID');
        $this->hmacSecret = env('PAYMOB_HMAC_SECRET');
        $this->currency = env('PAYMOB_CURRENCY', 'AED');

        // UAE Paymob API
        $this->baseUrl = 'https://uae.paymob.com';
    }

    /**
     * إنشاء Payment Intention (API v2 الجديد)
     */
    public function createPaymentIntention($amount, $billingData, $items = [])
    {
        try {
            // تحويل المبلغ لـ cents (فلس)
            $amountCents = (int)($amount * 100);

            $payload = [
                'amount' => $amountCents,
                'currency' => $this->currency,
                'payment_methods' => [(int)$this->integrationId],
                'billing_data' => [
                    'email' => $billingData['email'] ?? 'customer@example.com',
                    'first_name' => $billingData['first_name'] ?? 'Customer',
                    'last_name' => $billingData['last_name'] ?? $billingData['first_name'] ?? 'Customer',
                    'phone_number' => $billingData['phone_number'] ?? '+971500000000',
                    'apartment' => $billingData['apartment'] ?? 'NA',
                    'floor' => $billingData['floor'] ?? 'NA',
                    'street' => $billingData['street'] ?? 'NA',
                    'building' => $billingData['building'] ?? 'NA',
                    'city' => $billingData['city'] ?? 'Dubai',
                    'country' => $billingData['country'] ?? 'AE',
                    'state' => $billingData['state'] ?? 'NA',
                    'postal_code' => $billingData['postal_code'] ?? 'NA',
                ],
                'items' => $items,
            ];

            Log::info('Paymob Payment Intention Request', ['payload' => $payload]);

            $response = Http::withHeaders([
                'Authorization' => 'Token ' . $this->secretKey,
                'Content-Type' => 'application/json',
            ])->post("{$this->baseUrl}/v1/intention/", $payload);

            if ($response->successful()) {
                $data = $response->json();
                Log::info('Paymob Payment Intention Success', ['response' => $data]);
                return $data;
            }

            Log::error('Paymob Payment Intention Error', [
                'status' => $response->status(),
                'response' => $response->json()
            ]);
            return null;

        } catch (\Exception $e) {
            Log::error('Paymob Payment Intention Exception', ['error' => $e->getMessage()]);
            return null;
        }
    }

    /**
     * إنشاء رابط الدفع الكامل
     */
    public function createPaymentUrl($subscriptionId, $amount, $userEmail, $userName, $userPhone)
    {
        try {
            // تجهيز بيانات الفوترة
            $billingData = [
                'email' => $userEmail,
                'first_name' => $userName,
                'last_name' => $userName,
                'phone_number' => $userPhone,
            ];

            // تجهيز عناصر الطلب
            $items = [
                [
                    'name' => "اشتراك #{$subscriptionId}",
                    'amount' => (int)($amount * 100),
                    'description' => 'اشتراك في Social Media Manager',
                    'quantity' => 1,
                ]
            ];

            // إنشاء Payment Intention
            $intention = $this->createPaymentIntention($amount, $billingData, $items);

            if (!$intention) {
                throw new \Exception('فشل في إنشاء Payment Intention');
            }

            // الحصول على payment key من الاستجابة
            $paymentKey = $intention['payment_keys'][0]['key'] ?? null;
            $orderId = $intention['intention_order_id'] ?? null;
            $clientSecret = $intention['client_secret'] ?? null;
            $redirectionUrl = $intention['payment_keys'][0]['redirection_url'] ?? null;

            if (!$paymentKey) {
                throw new \Exception('فشل في الحصول على Payment Key');
            }

            // إنشاء رابط الدفع
            $paymentUrl = "{$redirectionUrl}?payment_token={$paymentKey}";

            return [
                'success' => true,
                'payment_url' => $paymentUrl,
                'order_id' => $orderId,
                'payment_token' => $paymentKey,
                'client_secret' => $clientSecret,
                'intention_id' => $intention['id'] ?? null,
            ];

        } catch (\Exception $e) {
            Log::error('Paymob Create Payment URL Exception', ['error' => $e->getMessage()]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * التحقق من صحة HMAC
     */
    public function verifyHmac($data)
    {
        try {
            // For API v2, HMAC verification is different
            $hmacData = [
                'amount_cents' => $data['obj']['amount_cents'] ?? $data['amount_cents'] ?? '',
                'created_at' => $data['obj']['created_at'] ?? $data['created_at'] ?? '',
                'currency' => $data['obj']['currency'] ?? $data['currency'] ?? '',
                'error_occured' => $data['obj']['error_occured'] ?? $data['error_occured'] ?? 'false',
                'has_parent_transaction' => $data['obj']['has_parent_transaction'] ?? $data['has_parent_transaction'] ?? 'false',
                'id' => $data['obj']['id'] ?? $data['id'] ?? '',
                'integration_id' => $data['obj']['integration_id'] ?? $data['integration_id'] ?? '',
                'is_3d_secure' => $data['obj']['is_3d_secure'] ?? $data['is_3d_secure'] ?? 'false',
                'is_auth' => $data['obj']['is_auth'] ?? $data['is_auth'] ?? 'false',
                'is_capture' => $data['obj']['is_capture'] ?? $data['is_capture'] ?? 'false',
                'is_refunded' => $data['obj']['is_refunded'] ?? $data['is_refunded'] ?? 'false',
                'is_standalone_payment' => $data['obj']['is_standalone_payment'] ?? $data['is_standalone_payment'] ?? 'false',
                'is_voided' => $data['obj']['is_voided'] ?? $data['is_voided'] ?? 'false',
                'order' => $data['obj']['order']['id'] ?? $data['order']['id'] ?? $data['order'] ?? '',
                'owner' => $data['obj']['owner'] ?? $data['owner'] ?? '',
                'pending' => $data['obj']['pending'] ?? $data['pending'] ?? 'false',
                'source_data_pan' => $data['obj']['source_data']['pan'] ?? $data['source_data']['pan'] ?? '',
                'source_data_sub_type' => $data['obj']['source_data']['sub_type'] ?? $data['source_data']['sub_type'] ?? '',
                'source_data_type' => $data['obj']['source_data']['type'] ?? $data['source_data']['type'] ?? '',
                'success' => $data['obj']['success'] ?? $data['success'] ?? 'false',
            ];

            // Convert boolean values to strings
            foreach ($hmacData as $key => $value) {
                if (is_bool($value)) {
                    $hmacData[$key] = $value ? 'true' : 'false';
                }
            }

            $concatenatedString = implode('', $hmacData);
            $hash = hash_hmac('sha512', $concatenatedString, $this->hmacSecret);

            $receivedHmac = $data['hmac'] ?? '';

            Log::info('HMAC Verification', [
                'calculated' => $hash,
                'received' => $receivedHmac,
                'match' => $hash === $receivedHmac,
            ]);

            return $hash === $receivedHmac;

        } catch (\Exception $e) {
            Log::error('Paymob HMAC Verification Exception', ['error' => $e->getMessage()]);
            return false;
        }
    }

    /**
     * التحقق من حالة الدفع
     */
    public function getTransactionDetails($transactionId)
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Token ' . $this->secretKey,
            ])->get("{$this->baseUrl}/api/acceptance/transactions/{$transactionId}");

            if ($response->successful()) {
                return $response->json();
            }

            Log::error('Paymob Get Transaction Error', ['response' => $response->json()]);
            return null;

        } catch (\Exception $e) {
            Log::error('Paymob Get Transaction Exception', ['error' => $e->getMessage()]);
            return null;
        }
    }

    /**
     * التحقق من حالة Payment Intention
     */
    public function getPaymentIntentionStatus($intentionId)
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Token ' . $this->secretKey,
            ])->get("{$this->baseUrl}/v1/intention/{$intentionId}/");

            if ($response->successful()) {
                return $response->json();
            }

            Log::error('Paymob Get Intention Status Error', ['response' => $response->json()]);
            return null;

        } catch (\Exception $e) {
            Log::error('Paymob Get Intention Status Exception', ['error' => $e->getMessage()]);
            return null;
        }
    }

    /**
     * استرداد مبلغ (Refund)
     */
    public function refund($transactionId, $amountCents = null)
    {
        try {
            $payload = [
                'transaction_id' => $transactionId,
            ];

            if ($amountCents) {
                $payload['amount_cents'] = $amountCents;
            }

            $response = Http::withHeaders([
                'Authorization' => 'Token ' . $this->secretKey,
                'Content-Type' => 'application/json',
            ])->post("{$this->baseUrl}/api/acceptance/void_refund/refund", $payload);

            if ($response->successful()) {
                return $response->json();
            }

            Log::error('Paymob Refund Error', ['response' => $response->json()]);
            return null;

        } catch (\Exception $e) {
            Log::error('Paymob Refund Exception', ['error' => $e->getMessage()]);
            return null;
        }
    }
}
