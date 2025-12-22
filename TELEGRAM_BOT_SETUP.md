# 🤖 Telegram Admin Bot Setup

## نظام إدارة متكامل عبر Telegram Bot

تم تطوير بوت تلجرام متقدم لإدارة المنصة بالكامل بدون الحاجة لـ Admin Panel في الموقع.

---

## ⚙️ التفعيل السريع

### 1. إضافة معلومات البوت في `.env`

```env
# Telegram Bot Configuration
TELEGRAM_BOT_TOKEN=your_bot_token_here
TELEGRAM_ADMIN_CHAT_IDS=123456789,987654321
```

**كيفية الحصول على:**
- **Bot Token**: تحدث مع [@BotFather](https://t.me/BotFather) على تلجرام:
  1. أرسل `/newbot`
  2. اختر اسم للبوت
  3. انسخ الـ Token

- **Chat ID**: تحدث مع [@userinfobot](https://t.me/userinfobot) لمعرفة الـ Chat ID الخاص بك

---

### 2. تسجيل Observer في `AppServiceProvider`

افتح `app/Providers/AppServiceProvider.php` وأضف:

```php
use App\Models\User;
use App\Models\Subscription;
use App\Models\SupportTicket;
use App\Models\WalletRechargeRequest;
use App\Models\WebsiteRequest;
use App\Models\SponsoredAdRequest;
use App\Observers\AdminNotificationObserver;

public function boot(): void
{
    // Register observers for automatic admin notifications
    User::observe(AdminNotificationObserver::class);
    Subscription::observe(AdminNotificationObserver::class);
    SupportTicket::observe(AdminNotificationObserver::class);
    WalletRechargeRequest::observe(AdminNotificationObserver::class);
    WebsiteRequest::observe(AdminNotificationObserver::class);
    SponsoredAdRequest::observe(AdminNotificationObserver::class);
}
```

---

### 3. تفعيل Webhook

استخدم هذا الـ Endpoint لتفعيل الـ webhook:

```bash
curl -X POST https://mediaprosocial.io/api/telegram/set-webhook \
  -H "Content-Type: application/json" \
  -d '{"webhook_url": "https://mediaprosocial.io/api/telegram/webhook"}'
```

أو استخدم Postman:
- **Method**: POST
- **URL**: `https://mediaprosocial.io/api/telegram/set-webhook`
- **Body** (JSON):
```json
{
  "webhook_url": "https://mediaprosocial.io/api/telegram/webhook"
}
```

---

### 4. اختبر البوت

1. ابحث عن البوت الخاص بك على تلجرام
2. أرسل `/start` أو `/menu`
3. يجب أن تظهر لك لوحة التحكم

---

## 🎯 الأوامر المتاحة

### إدارة النظام
- `/start` أو `/menu` - عرض القائمة الرئيسية
- `/stats` - إحصائيات المنصة الكاملة
- `/settings` - إعدادات النظام

### إدارة المستخدمين
- `/users` - عرض المستخدمين الجدد
- `/subscriptions` - إدارة الاشتراكات

### إدارة الطلبات
- `/support` - تذاكر الدعم (موافقة/رفض)
- `/wallet` - طلبات شحن المحفظة (موافقة/رفض)
- `/requests` - طلبات المواقع والإعلانات

### المحتوى
- `/posts` - عرض المنشورات المجدولة

---

## 🔔 الإشعارات التلقائية

يتم إرسال إشعارات فورية للأدمن عند:

✅ **تسجيل مستخدم جديد**
```
🆕 New User Registered

👤 Name: Ahmed Ali
📧 Email: ahmed@example.com
📱 Phone: +971501234567
🆔 ID: 123
📅 Date: 2024-01-15 10:30
```

✅ **اشتراك جديد**
```
💳 New Subscription

👤 User: Ahmed Ali
📦 Plan: Business Plan
💰 Amount: AED 199
📅 Period: 2024-01-15 to 2024-02-15
🆔 ID: 45
```

✅ **تذكرة دعم جديدة**
```
🎫 New Support Ticket

👤 Name: Sara Mohammed
📧 Email: sara@example.com
🏷️ Category: Technical Issue
⚡ Priority: High
📝 Message: Cannot connect Instagram...
🆔 ID: 67

👉 Use /support to view and manage
```

✅ **طلب شحن محفظة**
```
💰 New Wallet Recharge Request

👤 User: Ahmed Ali
💵 Amount: AED 500
🏦 Method: Bank Transfer
📝 Notes: Transferred from Emirates NBD
🆔 ID: 89

👉 Use /wallet to approve or reject
```

---

## 🎨 الميزات الرئيسية

### 1. لوحة تحكم تفاعلية
- أزرار Inline Keyboard لسهولة الاستخدام
- ردود فورية على الأحداث
- معلومات منسقة بشكل جميل

### 2. موافقة/رفض مباشر
- اضغط على "✅ Approve" مباشرة من الإشعار
- اضغط على "❌ Reject" للرفض
- تحديث فوري للحالة في قاعدة البيانات

### 3. إحصائيات شاملة
- عدد المستخدمين النشطين
- الإيرادات الكلية
- الطلبات المعلقة
- الحسابات المتصلة

### 4. أمان عالي
- التحقق من Chat ID للأدمن فقط
- لا يستجيب البوت إلا للأدمن المصرح لهم
- Logging لكل العمليات

---

## 🔧 استكشاف الأخطاء

### البوت لا يرد
1. تأكد من تفعيل الـ webhook بشكل صحيح
2. تحقق من Logs: `storage/logs/laravel.log`
3. اختبر البوت: `GET /api/telegram/test`

### لا تصل الإشعارات
1. تأكد من أن `TELEGRAM_ADMIN_CHAT_IDS` صحيح
2. تأكد من تسجيل الـ Observers في `AppServiceProvider`
3. تحقق من الـ Logs

### الأزرار لا تعمل
1. تأكد من أن الـ webhook يستقبل `callback_query`
2. تحقق من الـ webhook info: `GET /api/telegram/webhook-info`

---

## 📊 API Endpoints

### إدارة Webhook
```
POST   /api/telegram/set-webhook       - تفعيل webhook
GET    /api/telegram/webhook-info      - معلومات webhook
DELETE /api/telegram/webhook           - حذف webhook
```

### اختبار
```
GET    /api/telegram/test              - اختبار البوت
GET    /api/telegram/bot-config        - معلومات البوت
```

### الإشعارات (Internal)
```
POST   /api/telegram/notify-admins     - إرسال إشعار للأدمن
```

---

## 🚀 الخطوات التالية

بعد تفعيل البوت:

1. ✅ حذف Admin Panel من Laravel Filament (غير مطلوب)
2. ✅ إزالة صفحات الإدارة من Flutter App
3. ✅ التركيز على تجربة المستخدم النهائي فقط
4. ✅ تبسيط الـ API وإزالة endpoints غير مستخدمة

---

## 💡 نصائح مهمة

1. **احفظ Bot Token في مكان آمن** - لا تشاركه أبداً
2. **استخدم HTTPS فقط** - Telegram يرفض HTTP webhooks
3. **راقب الـ Logs** - لمعرفة أي مشاكل فوراً
4. **اختبر كل شيء** - قبل الانتقال للـ Production

---

## 🎯 الفوائد

✅ **بدون Admin Panel** - لا حاجة لـ Filament أو أي نظام إدارة
✅ **إدارة من أي مكان** - فقط افتح تلجرام
✅ **إشعارات فورية** - بدون الحاجة للتحقق من Dashboard
✅ **موافقة سريعة** - زر واحد للموافقة أو الرفض
✅ **أمان عالي** - فقط الأدمن المصرح لهم
✅ **مجاني تماماً** - بدون تكاليف إضافية

---

## 📞 الدعم

إذا واجهت أي مشكلة:
1. راجع الـ Logs في `storage/logs/laravel.log`
2. تأكد من صحة الإعدادات في `.env`
3. اختبر البوت باستخدام `/api/telegram/test`

---

تم التطوير بعقلية **SaaS Business** - بسيط، فعّال، ومركز على القيمة الأساسية! 🚀
