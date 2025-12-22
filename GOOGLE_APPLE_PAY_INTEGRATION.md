# دليل دمج Google Pay و Apple Pay

## 📱 نظرة عامة

تم إضافة دعم كامل لـ Google Pay و Apple Pay في التطبيق والباك اند.

---

## 🎯 الميزات المتاحة

### 1. **لوحة التحكم (Admin Panel)**

صفحة إعدادات الدفع: `https://mediaprosocial.io/admin/payment-settings`

#### تبويب Google Pay:
- ✅ تفعيل/تعطيل Google Pay
- ✅ Merchant ID (معرف التاجر)
- ✅ Merchant Name (اسم التاجر)
- ✅ Environment (TEST أو PRODUCTION)
- ✅ Gateway (Stripe, Paymob, Adyen, CyberSource)
- ✅ Gateway Merchant ID
- ✅ متطلبات إضافية (عنوان الفوترة، الشحن، البريد، الهاتف)
- ✅ تخصيص الزر (اللون، النوع)

#### تبويب Apple Pay:
- ✅ تفعيل/تعطيل Apple Pay
- ✅ Merchant ID من Apple Developer
- ✅ Merchant Name
- ✅ Country Code & Currency Code
- ✅ Gateway (Stripe, Paymob, Adyen, Square)
- ✅ متطلبات إضافية (عنوان الفوترة، الشحن، البريد، الهاتف)
- ✅ تخصيص الزر (النمط، النوع)

---

## 🔧 الإعداد في الباك اند

### 1. **جدول الإعدادات (Settings Table)**

تم إضافة 24 إعداد جديد:

**Google Pay:**
- `google_pay_enabled`
- `google_pay_merchant_id`
- `google_pay_merchant_name`
- `google_pay_environment`
- `google_pay_gateway`
- `google_pay_gateway_merchant_id`
- `google_pay_billing_address_required`
- `google_pay_shipping_address_required`
- `google_pay_email_required`
- `google_pay_phone_required`
- `google_pay_button_color`
- `google_pay_button_type`

**Apple Pay:**
- `apple_pay_enabled`
- `apple_pay_merchant_id`
- `apple_pay_merchant_name`
- `apple_pay_country_code`
- `apple_pay_currency_code`
- `apple_pay_gateway`
- `apple_pay_require_billing`
- `apple_pay_require_shipping`
- `apple_pay_require_email`
- `apple_pay_require_phone`
- `apple_pay_button_style`
- `apple_pay_button_type`

### 2. **API Endpoint**

```bash
GET /api/settings/app-config
```

**الاستجابة:**
```json
{
  "success": true,
  "data": {
    "payment": {
      "google_pay_enabled": false,
      "google_pay_merchant_id": "",
      "google_pay_merchant_name": "Media Pro Social",
      "google_pay_environment": "TEST",
      "google_pay_gateway": "stripe",
      // ... المزيد من الإعدادات

      "apple_pay_enabled": false,
      "apple_pay_merchant_id": "",
      "apple_pay_merchant_name": "Media Pro Social",
      "apple_pay_country_code": "AE",
      "apple_pay_currency_code": "AED",
      // ... المزيد من الإعدادات
    }
  }
}
```

---

## 📱 الاستخدام في Flutter

### 1. **إضافة Package**

أضف إلى `pubspec.yaml`:

```yaml
dependencies:
  pay: ^2.0.0  # Official Google/Apple Pay package
```

### 2. **تهيئة Service**

في `main.dart`:

```dart
import 'services/google_apple_pay_service.dart';

void main() async {
  // ... التهيئات الأخرى

  // تهيئة SettingsService أولاً
  Get.put(SettingsService());
  await Get.find<SettingsService>().fetchAppConfig();

  // ثم تهيئة GoogleApplePayService
  Get.put(GoogleApplePayService());

  runApp(MyApp());
}
```

### 3. **استخدام الإعدادات**

```dart
import 'package:get/get.dart';
import 'services/settings_service.dart';

final settings = Get.find<SettingsService>();

// Google Pay
bool googlePayEnabled = settings.googlePayEnabled;
String merchantId = settings.googlePayMerchantId;
String environment = settings.googlePayEnvironment;
String gateway = settings.googlePayGateway;

// Apple Pay
bool applePayEnabled = settings.applePayEnabled;
String appleMerchantId = settings.applePayMerchantId;
String countryCode = settings.applePayCountryCode;
String currencyCode = settings.applePayCurrencyCode;
```

### 4. **استخدام Widget**

```dart
import 'widgets/google_apple_pay_button.dart';

class PaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الدفع')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // عرض معلومات الطلب
            Text('المبلغ: \$50.00'),
            SizedBox(height: 20),

            // زر Google Pay أو Apple Pay
            GoogleApplePayButton(
              amount: 50.00,
              description: 'شراء باقة مميزة',
              orderId: 'ORDER_12345',
              onPaymentSuccess: (result) {
                print('✅ تم الدفع بنجاح: $result');
                // انتقل لصفحة التأكيد
                Get.to(() => PaymentSuccessScreen());
              },
              onPaymentError: (error) {
                print('❌ فشل الدفع: $error');
                // عرض رسالة خطأ
                Get.snackbar('خطأ', error);
              },
              width: double.infinity,
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🎨 مثال عملي كامل

### شاشة الدفع الكاملة:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'widgets/google_apple_pay_button.dart';
import 'services/google_apple_pay_service.dart';

class CheckoutScreen extends StatelessWidget {
  final double totalAmount;
  final String orderDescription;

  const CheckoutScreen({
    required this.totalAmount,
    required this.orderDescription,
  });

  @override
  Widget build(BuildContext context) {
    final payService = Get.find<GoogleApplePayService>();

    return Scaffold(
      appBar: AppBar(
        title: Text('إتمام الدفع'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ملخص الطلب
            _buildOrderSummary(),

            SizedBox(height: 30),

            // طرق الدفع المتاحة
            Text(
              'اختر طريقة الدفع',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 16),

            // Google Pay / Apple Pay
            if (payService.isGooglePayAvailable ||
                payService.isApplePayAvailable)
              Column(
                children: [
                  GoogleApplePayButton(
                    amount: totalAmount,
                    description: orderDescription,
                    onPaymentSuccess: _handlePaymentSuccess,
                    onPaymentError: _handlePaymentError,
                  ),

                  SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('أو'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),

                  SizedBox(height: 16),
                ],
              ),

            // Stripe / Paymob / PayPal
            _buildOtherPaymentMethods(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملخص الطلب',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(orderDescription),
                Text(
                  '\$${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherPaymentMethods() {
    final payService = Get.find<GoogleApplePayService>();
    final availableMethods = payService.getAvailablePaymentMethods();

    return Column(
      children: availableMethods
          .where((m) => m != 'google_pay' && m != 'apple_pay')
          .map((method) => ListTile(
                leading: Icon(_getPaymentIcon(method)),
                title: Text(_getPaymentName(method)),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => _selectPaymentMethod(method),
              ))
          .toList(),
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'stripe':
        return Icons.credit_card;
      case 'paymob':
        return Icons.account_balance_wallet;
      case 'paypal':
        return Icons.payment;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentName(String method) {
    switch (method) {
      case 'stripe':
        return 'Stripe';
      case 'paymob':
        return 'Paymob';
      case 'paypal':
        return 'PayPal';
      default:
        return method;
    }
  }

  void _selectPaymentMethod(String method) {
    print('Selected payment method: $method');
    // Navigate to specific payment method screen
  }

  void _handlePaymentSuccess(Map<String, dynamic> result) {
    Get.snackbar(
      'نجح الدفع',
      'تم الدفع بنجاح بمبلغ \$${result['amount']}',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );

    // Navigate to success screen
    // Get.off(() => PaymentSuccessScreen(result: result));
  }

  void _handlePaymentError(String error) {
    Get.snackbar(
      'فشل الدفع',
      error,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 5),
    );
  }
}
```

---

## 🔒 الأمان

1. **Merchant IDs**: يتم تخزينها في قاعدة البيانات فقط
2. **Secret Keys**: لا يتم إرسالها للتطبيق أبداً
3. **Payment Processing**: يتم عبر Gateway آمن (Stripe, Paymob, etc.)
4. **Public Keys Only**: فقط المفاتيح العامة يتم إرسالها للتطبيق

---

## ✅ التحقق من التكامل

### 1. **التحقق من الإعدادات في لوحة التحكم**

```bash
curl -s 'https://mediaprosocial.io/api/settings/app-config' | grep "google_pay\|apple_pay"
```

**النتيجة المتوقعة:**
```json
"google_pay_enabled": false,
"google_pay_merchant_id": "",
"apple_pay_enabled": false,
"apple_pay_merchant_id": "",
```

### 2. **التحقق من SettingsService**

```dart
final settings = Get.find<SettingsService>();
print('Google Pay enabled: ${settings.googlePayEnabled}');
print('Apple Pay enabled: ${settings.applePayEnabled}');
```

### 3. **التحقق من GoogleApplePayService**

```dart
final payService = Get.find<GoogleApplePayService>();
print('Google Pay available: ${payService.isGooglePayAvailable}');
print('Apple Pay available: ${payService.isApplePayAvailable}');
print('Available methods: ${payService.getAvailablePaymentMethods()}');
```

---

## 📝 ملاحظات مهمة

1. **Google Pay**:
   - يعمل فقط على Android
   - يتطلب Merchant ID من Google Pay Console
   - يتطلب تكوين Gateway (Stripe, Paymob, etc.)

2. **Apple Pay**:
   - يعمل فقط على iOS
   - يتطلب Merchant ID من Apple Developer
   - يتطلب إعداد Apple Pay في Xcode

3. **Testing**:
   - استخدم Environment: TEST للاختبار
   - استخدم Environment: PRODUCTION للإنتاج

4. **الحد الأدنى للدفع**:
   - يمكن تحديده من الإعدادات العامة
   - الافتراضي: $10

---

## 🎯 الخلاصة

✅ **تم إضافة:**
- صفحة إعدادات Google Pay و Apple Pay في لوحة التحكم
- API endpoint يُرجع جميع إعدادات الدفع
- SettingsService مع 24 getter جديد
- GoogleApplePayService لمعالجة الدفع
- GoogleApplePayButton widget جاهز للاستخدام
- مثال كامل لشاشة الدفع

✅ **جاهز للاستخدام:**
- افتح لوحة التحكم وفعّل Google Pay أو Apple Pay
- أضف Merchant ID الخاص بك
- استخدم Widget في أي مكان في التطبيق
- المستخدمون يمكنهم الدفع بنقرة واحدة!

---

🎉 **كل شيء جاهز!**
