<?php

namespace App\Http\Controllers;

use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use App\Models\Payment;
use App\Models\User;
use App\Services\PaymobService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class PaymentController extends Controller
{
    protected $paymobService;

    public function __construct(PaymobService $paymobService)
    {
        $this->paymobService = $paymobService;
    }

    /**
     * إنشاء عملية دفع جديدة (API)
     */
    public function initiatePayment(Request $request)
    {
        try {
            $request->validate([
                'plan_id' => 'required|exists:subscription_plans,id',
                'email' => 'nullable|email',
                'name' => 'nullable|string',
                'phone' => 'nullable|string',
            ]);

            $user = auth()->user();
            $plan = SubscriptionPlan::findOrFail($request->plan_id);

            // استخدام بيانات المستخدم الحالي إذا لم تُرسل البيانات
            $email = $request->email ?? $user->email ?? 'customer@example.com';
            $name = $request->name ?? $user->name ?? 'Customer';
            $phone = $request->phone ?? $user->phone ?? '+971500000000';

            // إنشاء رابط الدفع
            $result = $this->paymobService->createPaymentUrl(
                $plan->id,
                $plan->price,
                $email,
                $name,
                $phone
            );

            if (!$result['success']) {
                return response()->json([
                    'success' => false,
                    'message' => 'فشل في إنشاء رابط الدفع: ' . ($result['error'] ?? 'خطأ غير معروف'),
                ], 500);
            }

            // حفظ سجل الدفع في قاعدة البيانات
            $payment = Payment::create([
                'user_id' => $user->id ?? null,
                'subscription_id' => null,
                'amount' => $plan->price,
                'currency' => 'AED',
                'payment_method' => 'paymob',
                'gateway' => 'paymob',
                'status' => 'pending',
                'gateway_transaction_id' => $result['order_id'],
                'gateway_response' => [
                    'order_id' => $result['order_id'],
                    'payment_token' => $result['payment_token'],
                    'intention_id' => $result['intention_id'] ?? null,
                    'client_secret' => $result['client_secret'] ?? null,
                    'plan_id' => $plan->id,
                    'plan_name' => $plan->name,
                ],
            ]);

            return response()->json([
                'success' => true,
                'payment_url' => $result['payment_url'],
                'payment_id' => $payment->id,
                'order_id' => $result['order_id'],
                'client_secret' => $result['client_secret'] ?? null,
            ]);

        } catch (\Exception $e) {
            Log::error('Payment Initiation Error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء إنشاء عملية الدفع: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * الحصول على حالة الدفع
     */
    public function getPaymentStatus(Request $request, $paymentId)
    {
        try {
            $payment = Payment::findOrFail($paymentId);

            // تحقق من أن المستخدم هو صاحب الدفع
            if ($payment->user_id && $payment->user_id !== auth()->id()) {
                return response()->json([
                    'success' => false,
                    'message' => 'غير مصرح لك بالوصول لهذا الدفع',
                ], 403);
            }

            return response()->json([
                'success' => true,
                'payment' => [
                    'id' => $payment->id,
                    'status' => $payment->status,
                    'amount' => $payment->amount,
                    'currency' => $payment->currency,
                    'created_at' => $payment->created_at,
                    'paid_at' => $payment->paid_at,
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'الدفع غير موجود',
            ], 404);
        }
    }

    /**
     * قائمة مدفوعات المستخدم
     */
    public function getUserPayments(Request $request)
    {
        $payments = Payment::where('user_id', auth()->id())
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'payments' => $payments,
        ]);
    }

    /**
     * معالجة callback من Paymob (عند نجاح/فشل الدفع)
     */
    public function handleCallback(Request $request)
    {
        try {
            $success = $request->query('success') === 'true';
            $orderId = $request->query('order');

            if ($success) {
                return redirect('/payment/success?order=' . $orderId);
            } else {
                return redirect('/payment/failed?order=' . $orderId);
            }

        } catch (\Exception $e) {
            Log::error('Payment Callback Error', [
                'error' => $e->getMessage(),
            ]);

            return redirect('/payment/failed');
        }
    }

    /**
     * معالجة Webhook من Paymob
     */
    public function handleWebhook(Request $request)
    {
        try {
            $data = $request->all();

            Log::info('Paymob Webhook Received', ['data' => $data]);

            // التحقق من صحة HMAC
            if (!$this->paymobService->verifyHmac($data)) {
                Log::warning('Invalid HMAC from Paymob', ['data' => $data]);
                return response()->json(['message' => 'Invalid HMAC'], 403);
            }

            $orderId = $data['order']['id'] ?? null;
            $success = $data['success'] ?? false;
            $transactionId = $data['id'] ?? null;

            if (!$orderId) {
                return response()->json(['message' => 'Order ID not found'], 400);
            }

            // البحث عن الدفع
            $payment = Payment::where('gateway_transaction_id', $orderId)->first();

            if (!$payment) {
                Log::warning('Payment not found for order', ['order_id' => $orderId]);
                return response()->json(['message' => 'Payment not found'], 404);
            }

            // تحديث حالة الدفع
            DB::beginTransaction();

            try {
                $payment->update([
                    'status' => $success ? 'completed' : 'failed',
                    'gateway_transaction_id' => $transactionId,
                    'gateway_response' => array_merge(
                        $payment->gateway_response ?? [],
                        ['webhook_data' => $data]
                    ),
                    'paid_at' => $success ? now() : null,
                ]);

                // إذا نجح الدفع، تحديث اشتراك المستخدم
                if ($success && $payment->user_id) {
                    $user = User::find($payment->user_id);
                    if ($user) {
                        $user->update([
                            'subscription_id' => $payment->subscription_id,
                            'subscription_status' => 'active',
                            'subscription_started_at' => now(),
                            'subscription_ends_at' => now()->addMonth(),
                        ]);
                    }
                }

                DB::commit();

                return response()->json(['message' => 'Webhook processed successfully']);

            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }

        } catch (\Exception $e) {
            Log::error('Payment Webhook Error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json(['message' => 'Error processing webhook'], 500);
        }
    }

    /**
     * صفحة نجاح الدفع
     */
    public function success(Request $request)
    {
        $orderId = $request->query('order');

        return view('payment.success', [
            'order_id' => $orderId,
        ]);
    }

    /**
     * صفحة فشل الدفع
     */
    public function failed(Request $request)
    {
        $orderId = $request->query('order');

        return view('payment.failed', [
            'order_id' => $orderId,
        ]);
    }
}
