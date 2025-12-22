# ⚡ حل سريع - مشكلة Paymob (دقيقتان)

## ❌ المشكلة:
```
فشل في تجهيز الدفع
فشل المصادقة مع Paymob
```

---

## ✅ الحل السريع:

### 1️⃣ احصل على API Key الجديد

اذهب إلى: https://accept.paymob.com/portal2/en/login

ثم: **Settings → Account Info** → انسخ **API Key**

---

### 2️⃣ حدّث المفتاح في التطبيق

**الملف:** `lib/core/config/api_config.dart`

**السطر:** 94

```dart
// قبل:
defaultValue: 'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5...',

// بعد:
defaultValue: 'YOUR_NEW_API_KEY_HERE', // ← ضع المفتاح الجديد هنا
```

---

### 3️⃣ أعد بناء التطبيق

```bash
flutter clean
flutter pub get
flutter run
```

---

### 4️⃣ اختبر!

اذهب للتطبيق → **الاشتراكات** → **اشترك الآن**

يجب أن تفتح صفحة الدفع! ✅

---

## 🧪 اختبار سريع للمفتاح

قبل تحديث التطبيق، اختبر المفتاح:

```bash
curl -X POST https://accept.paymob.com/api/auth/tokens \
  -H "Content-Type: application/json" \
  -d '{"api_key":"YOUR_NEW_API_KEY"}'
```

**النتيجة المتوقعة:**
```json
{
  "token": "eyJ0eXAiOiJKV1QiLC...",
  "profile": {...}
}
```

إذا حصلت على `{"detail":"incorrect credentials"}` → المفتاح خطأ ❌

---

## 📞 ملاحظات مهمة:

1. **المفتاح المطلوب:** API Key (وليس Public Key أو Secret Key)
2. **الوضع:** Live Mode (وليس Test Mode)
3. **المكان:** Settings → Account Info في لوحة تحكم Paymob

---

**للدليل الكامل:** اقرأ `PAYMOB_FIX_GUIDE_AR.md`
