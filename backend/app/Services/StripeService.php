<?php

namespace App\Services;

use Stripe\Stripe;
use Stripe\PaymentIntent;
use Stripe\Refund;
use Stripe\Webhook;
use Illuminate\Http\Request;

class StripeService
{
    public function __construct()
    {
        Stripe::setApiKey(config('services.stripe.secret'));
    }

    /**
     * إنشاء نية دفع
     */
    public function createPaymentIntent(float $amount, string $currency = 'USD')
    {
        return PaymentIntent::create([
            'amount' => $amount * 100, // Convert to cents
            'currency' => strtolower($currency),
            'automatic_payment_methods' => [
                'enabled' => true,
            ],
        ]);
    }

    /**
     * استرجاع نية دفع
     */
    public function retrievePaymentIntent(string $paymentIntentId)
    {
        return PaymentIntent::retrieve($paymentIntentId);
    }

    /**
     * استرداد دفعة
     */
    public function refund(string $paymentIntentId, ?float $amount = null)
    {
        $params = ['payment_intent' => $paymentIntentId];

        if ($amount) {
            $params['amount'] = $amount * 100;
        }

        return Refund::create($params);
    }

    /**
     * معالجة Webhook
     */
    public function handleWebhook(Request $request)
    {
        $payload = $request->getContent();
        $sigHeader = $request->header('Stripe-Signature');
        $webhookSecret = config('services.stripe.webhook_secret');

        try {
            $event = Webhook::constructEvent($payload, $sigHeader, $webhookSecret);
        } catch (\Exception $e) {
            throw new \Exception('Webhook signature verification failed');
        }

        // معالجة الأحداث المختلفة
        switch ($event->type) {
            case 'payment_intent.succeeded':
                $this->handlePaymentIntentSucceeded($event->data->object);
                break;

            case 'payment_intent.payment_failed':
                $this->handlePaymentIntentFailed($event->data->object);
                break;

            case 'charge.refunded':
                $this->handleChargeRefunded($event->data->object);
                break;

            default:
                // Handle other event types
                break;
        }

        return $event;
    }

    /**
     * معالجة نجاح الدفع
     */
    protected function handlePaymentIntentSucceeded($paymentIntent)
    {
        // يمكن إضافة منطق إضافي هنا
        \Log::info('Payment succeeded', ['payment_intent_id' => $paymentIntent->id]);
    }

    /**
     * معالجة فشل الدفع
     */
    protected function handlePaymentIntentFailed($paymentIntent)
    {
        \Log::error('Payment failed', ['payment_intent_id' => $paymentIntent->id]);
    }

    /**
     * معالجة الاسترداد
     */
    protected function handleChargeRefunded($charge)
    {
        \Log::info('Charge refunded', ['charge_id' => $charge->id]);
    }
}
