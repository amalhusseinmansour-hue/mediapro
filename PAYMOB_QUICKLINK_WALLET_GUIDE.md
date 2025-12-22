# =³ /DJD *A9JD Paymob: QuickLinks + 'DE-A8)

## =° 'D#39'1 'D,/J/)

### 'D('B) 'D#HDI: Basic Plan - 99.99 1J'D
- -*I 5 -3'('* 3H4'D EJ/J'
- ,/HD) :J1 E-/H/)
- *-DJD'* #3'3J)
- /9E AFJ

### 'D('B) 'D+'FJ): Pro Plan - 159.99 1J'D
- -3'('* :J1 E-/H/)
- *-DJD'* E*B/E) + AI
- *HDJ/ E-*HI ('D0C'! 'D'57F'9J
- /9E VIP
- *B'1J1 E.55)

---

## = 'D.7H) 1: %F4'! QuickLinks

### E' GH QuickLink
1'(7 /A9 31J9 (E(D: E-// - 'DE3*./E J6:7 9DJG HJ/A9 E('41)!

### %F4'! QuickLink DD('B) 1 (99.99 1J'D)

#### 1. 3,D /.HD Paymob
```
https://accept.paymob.com/portal2/en/login
```

#### 2. '0G( %DI Payment Links
EF 'DB'&E) ’ **Payment Links** #H **QuickLinks**

#### 3. #F4& 1'(7 ,/J/
'6:7 **+ Create New Link**

#### 4. 'ED# 'D(J'F'*:
```
Link Name: Basic Plan 99.99 SAR
Amount: 9999
ED'-8): 'DE(D: ('DGDD'* (99.99 1J'D = 9999 GDD))

Currency: SAR

Description: '4*1'C 4G1J - 'D('B) 'D#3'3J)
```

#### 5. %9/'/'* %6'AJ):
```
Success URL: https://mediaprosocial.io/payment/success?plan=basic
Failure URL: https://mediaprosocial.io/payment/failed
```

#### 6. '-A8
3*-5D 9DI 1'(7 E+D:
```
https://accept.paymob.com/i/ABC123DEF
```
**'-A8 G0' 'D1'(7!**

### %F4'! QuickLink DD('B) 2 (159.99 1J'D)

C11 FA3 'D.7H'* E9:
```
Link Name: Pro Plan 159.99 SAR
Amount: 15999 (159.99 1J'D ('DGDD'*)
Description: '4*1'C 4G1J - 'D('B) 'D'-*1'AJ)
Success URL: https://mediaprosocial.io/payment/success?plan=pro
```

---

## =¸ 'D.7H) 2: 1(7 'DE-A8) (Wallet)

### 'DE-'A8 'DE/9HE):
-  **STC Pay** ('D39H/J) - 'D#C+1 '3*./'E'K)
-  **Apple Pay**
-  **Mada** ((7'B'* E-DJ) 39H/J))

### %F4'! Wallet Integration

#### 1. '0G( %DI Payment Integrations
```
Dashboard ’ Settings ’ Payment Integrations
```

#### 2. #F4& Integration ,/J/
- '6:7 **+ Add Integration**
- '.*1 **Wallet**

#### 3. '.*1 'DE-'A8:
```
 STC Pay
 Apple Pay
 Mada
```

#### 4. 'ED# 'D(J'F'*:
```
Integration Name: M PRO Wallets
Currency: SAR
```

#### 5. '-A8
3*-5D 9DI **Wallet Integration ID** - '-A8G!
```
E+'D: 654321
```

---

## =' 'D.7H) 3: *-/J+ .env

AJ 'DEDA `.env`:

```env
# Paymob API Keys (EF Dashboard ’ Settings ’ Account Info)
PAYMOB_API_KEY=YOUR_API_KEY_HERE
PAYMOB_PUBLIC_KEY=YOUR_PUBLIC_KEY_HERE
PAYMOB_SECRET_KEY=YOUR_SECRET_KEY_HERE
PAYMOB_HMAC_SECRET=YOUR_HMAC_SECRET_HERE

# Integration IDs
PAYMOB_CARD_INTEGRATION_ID=81249
PAYMOB_WALLET_INTEGRATION_ID=654321
PAYMOB_IFRAME_ID=YOUR_IFRAME_ID

# QuickLinks ('D1H'(7 'D*J #F4#*G')
PAYMOB_QUICKLINK_BASIC=https://accept.paymob.com/i/ABC123DEF
PAYMOB_QUICKLINK_PRO=https://accept.paymob.com/i/XYZ789GHI

# Settings
PAYMOB_TEST_MODE=false
DEFAULT_CURRENCY=SAR

# Prices
BASIC_PLAN_PRICE=99.99
PRO_PLAN_PRICE=159.99
```

---

## >ê 'D.7H) 4: 'D'.*('1

### '.*('1 QuickLink

#### 1. 'A*- 'D1'(7 AJ 'DE*5A-:
```
https://accept.paymob.com/i/ABC123DEF
```

#### 2. '3*./E (7'B) '.*('1:
```
(7'B) F',-):
1BE: 4987654321098769
CVV: 123
*'1J. 'D'F*G'!: 05/25

(7'B) A'4D) (D'.*('1 'DA4D):
1BE: 4000000000000002
CVV: 123
*'1J.: 05/25
```

#### 3. #CED 'D/A9
- #/.D 'D(J'F'*
- '6:7 Pay
- J,( #F J*E 'D*-HJD %DI Success URL

### '.*('1 'DE-A8)

```
STC Pay DD'.*('1:
1BE 'DG'*A: 0500000000
OTP: 1234
```

---

## =ñ 'D.7H) 5: /E, AJ 'D*7(JB

### *-/J+ paymob_service.dart

#6A /'D) ,/J/) DD@ QuickLink:

```dart
// AJ lib/services/paymob_service.dart

class PaymobService {
  /// A*- QuickLink DD/A9
  Future<void> openQuickLink(String quickLink) async {
    if (await canLaunch(quickLink)) {
      await launch(quickLink, forceSafariVC: false);
    } else {
      throw 'Could not launch $quickLink';
    }
  }

  /// 'D-5HD 9DI QuickLink -3( 'D('B)
  String getQuickLinkForPlan(String planId) {
    switch (planId) {
      case 'basic':
        return env('PAYMOB_QUICKLINK_BASIC');
      case 'pro':
        return env('PAYMOB_QUICKLINK_PRO');
      default:
        throw 'Unknown plan: $planId';
    }
  }
}
```

### 4'4) '.*J'1 71JB) 'D/A9

```dart
// AJ lib/screens/payment/payment_method_screen.dart

class PaymentMethodScreen extends StatelessWidget {
  final String planId;
  final double price;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(''.*1 71JB) 'D/A9')),
      body: ListView(
        children: [
          // 1. QuickLink ('D#3GD)
          ListTile(
            leading: Icon(Icons.flash_on, color: Colors.orange),
            title: Text('1'(7 /A9 31J9'),
            subtitle: Text(''D71JB) 'D#319 - EH5I (G''),
            trailing: Container(
              padding: EdgeInsets.all(4),
              color: Colors.green,
              child: Text('31J9', style: TextStyle(color: Colors.white)),
            ),
            onTap: () => _payWithQuickLink(),
          ),

          // 2. STC Pay
          ListTile(
            leading: Icon(Icons.phone_android, color: Colors.purple),
            title: Text('STC Pay'),
            subtitle: Text(''D/A9 (E-A8) STC'),
            onTap: () => _payWithWallet('stc_pay'),
          ),

          // 3. Apple Pay
          ListTile(
            leading: Icon(Icons.apple, color: Colors.black),
            title: Text('Apple Pay'),
            subtitle: Text('/A9 31J9 H"EF'),
            onTap: () => _payWithWallet('apple_pay'),
          ),

          // 4. (7'B) '&*E'F
          ListTile(
            leading: Icon(Icons.credit_card, color: Colors.blue),
            title: Text('(7'B) '&*E'F/E/I'),
            subtitle: Text('VISA, Mastercard, Mada'),
            onTap: () => _payWithCard(),
          ),
        ],
      ),
    );
  }

  void _payWithQuickLink() async {
    final paymobService = PaymobService();
    final quickLink = paymobService.getQuickLinkForPlan(planId);
    await paymobService.openQuickLink(quickLink);
  }

  void _payWithWallet(String provider) {
    // A*- 5A-) 'D/A9 ('DE-A8)
  }

  void _payWithCard() {
    // A*- 5A-) 'D/A9 ('D(7'B)
  }
}
```

---

## = 'D.7H) 6: Webhook (*-/J+ *DB'&J)

### %9/'/ Webhook URL AJ Paymob

#### 1. '0G( %DI Webhooks
```
Dashboard ’ Developers ’ Webhooks
```

#### 2. #6A Webhook URL:
```
https://mediaprosocial.io/api/payment/webhook
```

#### 3. '.*1 Events:
```
 Transaction.success
 Transaction.failure
```

### AJ Laravel Backend

%F4'! Controller DD@ Webhook:

```php
<?php
// app/Http/Controllers/Api/PaymobWebhookController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class PaymobWebhookController extends Controller
{
    public function handle(Request $request)
    {
        $obj = $request->input('obj');

        if ($obj['success'] === true) {
            // '3*.1', 'D(J'F'*
            $orderId = $obj['order']['id'];
            $amount = $obj['amount_cents'] / 100;
            $planId = $obj['order']['items'][0]['description']; // basic #H pro

            // *A9JD 'D'4*1'C
            $this->activateSubscription($orderId, $planId, $amount);

            return response()->json(['status' => 'success']);
        }

        return response()->json(['status' => 'failed']);
    }

    private function activateSubscription($orderId, $planId, $amount)
    {
        // -A8 AJ B'9/) 'D(J'F'*
        // *A9JD EJ2'* 'DE3*./E
    }
}
```

---

##  Checklist 'DFG'&J

B(D 'D%7D'B *#C/ EF:

- [ ] **API Keys** E-AH8) AJ .env
- [ ] **QuickLink DD('B) 1** (99.99) ,'G2 HJ9ED
- [ ] **QuickLink DD('B) 2** (159.99) ,'G2 HJ9ED
- [ ] **Wallet Integration** EA9D (STC Pay, Apple Pay)
- [ ] **Webhook URL** E6'A AJ Paymob Dashboard
- [ ] **Test Mode** J9ED (F,'-
- [ ] **'D#39'1** E-/+) AJ 'D*7(JB (99.99 H 159.99)
- [ ] **Success/Failure URLs** *9ED (4CD 5-J-

---

## <‰ 'F*GI!

'D"F D/JC F8'E /A9 C'ED:

### 'D('B'*:
- =° **Basic**: 99.99 1J'D/4G1
- =° **Pro**: 159.99 1J'D/4G1

### 71B 'D/A9:
-  **QuickLink** ('D#319)
-  **STC Pay** (E-A8))
-  **Apple Pay** (E-A8))
-  **Mada** ((7'B'* E-DJ))
-  **VISA/Mastercard** ((7'B'* 9'DEJ))

---

## =Þ 'D/9E

%0' H',G* E4'CD:
- =Ö **Docs**: https://docs.paymob.com
- =¬ **Support**: support@paymob.com
- < **Dashboard**: https://accept.paymob.com/portal2

---

***'1J. 'D%F4'!**: 2025
**'D%5/'1**: 1.0
