<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Models\Subscription;
use App\Services\StripeService;
use App\Services\PayPalService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class PaymentController extends Controller
{
    protected StripeService $stripeService;
    protected PayPalService $paypalService;

    public function __construct(StripeService $stripeService, PayPalService $paypalService)
    {
        $this->stripeService = $stripeService;
        $this->paypalService = $paypalService;
    }

    /**
     * عرض جميع المدفوعات
     */
    public function index(Request $request): JsonResponse
    {
        $payments = Payment::where('user_id', $request->user()->id)
            ->with('subscription')
            ->orderBy('created_at', 'desc')
            ->paginate(15);

        return response()->json($payments);
    }

    /**
     * عرض مدفوعة واحدة
     */
    public function show(string $id): JsonResponse
    {
        $payment = Payment::with('subscription')->findOrFail($id);

        return response()->json($payment);
    }

    /**
     * إنشاء نية دفع Stripe
     */
    public function createStripePaymentIntent(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'subscription_id' => 'required|exists:subscriptions,id',
        ]);

        $subscription = Subscription::findOrFail($validated['subscription_id']);

        try {
            $paymentIntent = $this->stripeService->createPaymentIntent(
                $subscription->price,
                $subscription->currency
            );

            return response()->json([
                'client_secret' => $paymentIntent->client_secret,
                'payment_intent_id' => $paymentIntent->id,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'فشل إنشاء نية الدفع',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * تأكيد دفع Stripe
     */
    public function confirmStripePayment(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'payment_intent_id' => 'required|string',
            'subscription_id' => 'required|exists:subscriptions,id',
        ]);

        $subscription = Subscription::findOrFail($validated['subscription_id']);

        try {
            $paymentIntent = $this->stripeService->retrievePaymentIntent($validated['payment_intent_id']);

            if ($paymentIntent->status === 'succeeded') {
                $payment = Payment::create([
                    'user_id' => $request->user()->id,
                    'subscription_id' => $subscription->id,
                    'amount' => $subscription->price,
                    'currency' => $subscription->currency,
                    'gateway' => 'stripe',
                    'gateway_transaction_id' => $paymentIntent->id,
                    'status' => 'completed',
                    'payment_method' => 'card',
                    'paid_at' => now(),
                ]);

                $subscription->update(['status' => 'active']);

                return response()->json([
                    'message' => 'تم الدفع بنجاح',
                    'payment' => $payment
                ]);
            }

            return response()->json(['error' => 'فشل الدفع'], 400);
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'فشل تأكيد الدفع',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * إنشاء طلب PayPal
     */
    public function createPayPalOrder(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'subscription_id' => 'required|exists:subscriptions,id',
        ]);

        $subscription = Subscription::findOrFail($validated['subscription_id']);

        try {
            $order = $this->paypalService->createOrder(
                $subscription->price,
                $subscription->currency
            );

            return response()->json([
                'order_id' => $order['id'],
                'approval_url' => $order['links'][1]['href'] ?? null,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'فشل إنشاء طلب PayPal',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * إلتقاط طلب PayPal
     */
    public function capturePayPalOrder(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'order_id' => 'required|string',
            'subscription_id' => 'required|exists:subscriptions,id',
        ]);

        $subscription = Subscription::findOrFail($validated['subscription_id']);

        try {
            $result = $this->paypalService->captureOrder($validated['order_id']);

            if ($result['status'] === 'COMPLETED') {
                $payment = Payment::create([
                    'user_id' => $request->user()->id,
                    'subscription_id' => $subscription->id,
                    'amount' => $subscription->price,
                    'currency' => $subscription->currency,
                    'gateway' => 'paypal',
                    'gateway_transaction_id' => $validated['order_id'],
                    'status' => 'completed',
                    'payment_method' => 'paypal',
                    'paid_at' => now(),
                ]);

                $subscription->update(['status' => 'active']);

                return response()->json([
                    'message' => 'تم الدفع بنجاح',
                    'payment' => $payment
                ]);
            }

            return response()->json(['error' => 'فشل الدفع'], 400);
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'فشل التقاط طلب PayPal',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * استرداد مدفوعة
     */
    public function refund(string $id): JsonResponse
    {
        $payment = Payment::findOrFail($id);

        if ($payment->status === 'refunded') {
            return response()->json(['error' => 'تم استرداد هذه المدفوعة بالفعل'], 400);
        }

        try {
            if ($payment->gateway === 'stripe') {
                $this->stripeService->refund($payment->gateway_transaction_id);
            } elseif ($payment->gateway === 'paypal') {
                $this->paypalService->refund($payment->gateway_transaction_id);
            }

            $payment->refund();

            if ($payment->subscription) {
                $payment->subscription->cancel();
            }

            return response()->json([
                'message' => 'تم استرداد المدفوعة بنجاح',
                'payment' => $payment
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'فشل استرداد المدفوعة',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Stripe Webhook
     */
    public function stripeWebhook(Request $request): JsonResponse
    {
        try {
            $this->stripeService->handleWebhook($request);
            return response()->json(['status' => 'success']);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 400);
        }
    }

    /**
     * PayPal Webhook
     */
    public function paypalWebhook(Request $request): JsonResponse
    {
        try {
            $this->paypalService->handleWebhook($request);
            return response()->json(['status' => 'success']);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 400);
        }
    }
}
