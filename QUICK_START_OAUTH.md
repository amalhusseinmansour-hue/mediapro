# 🚀 دليل سريع لإعداد OAuth - خطوة بخطوة

## 📋 ما تحتاجه:
1. حساب على كل منصة (LinkedIn, Facebook, Twitter, Instagram, TikTok, Snapchat, YouTube)
2. 30-60 دقيقة من وقتك
3. هذا الدليل

---

## 🔥 البدء السريع

### الخطوة 1️⃣: LinkedIn (الأسهل - ابدأ به)

**الوقت المتوقع:** 5 دقائق

1. افتح: https://www.linkedin.com/developers/apps/new
2. سجل دخول بحسابك
3. املأ:
   - **App name**: `M PRO Social Manager`
   - **LinkedIn Page**: أنشئ صفحة مؤقتة إذا لم يكن لديك
   - **Privacy policy**: `https://mediaprosocial.io/privacy`
   - **App logo**: أي صورة (يمكن تغييرها لاحقاً)
4. اضغط **Create app**
5. انتقل إلى تبويب **Auth**
6. في **Redirect URLs** أضف:
   ```
   https://mediaprosocial.io/api/auth/linkedin/callback
   ```
7. احفظ
8. انسخ:
   - **Client ID**: `78xxxxxxxxxxxxx`
   - **Client Secret**: اضغط "Show" وانسخه

✅ **الآن قم بما يلي:**

افتح موقعك وقم بتشغيل هذا الأمر:
```bash
ssh u126213189@82.25.83.217 -p 65002
cd /home/u126213189/domains/mediaprosocial.io/public_html
nano .env
```

ابحث عن السطور التالية وحدثها:
```env
LINKEDIN_CLIENT_ID=الصق_Client_ID_هنا
LINKEDIN_CLIENT_SECRET=الصق_Client_Secret_هنا
```

احفظ بـ `Ctrl+O` ثم `Enter` ثم `Ctrl+X`

امسح الكاش:
```bash
php artisan config:clear
php artisan cache:clear
```

🎉 **تم! LinkedIn جاهز الآن!**

---

### الخطوة 2️⃣: Facebook (مهم - Instagram يعتمد عليه)

**الوقت المتوقع:** 10 دقائق

1. افتح: https://developers.facebook.com/apps/create/
2. سجل دخول
3. اختر **Business** > **Next**
4. املأ:
   - **App name**: `M PRO Social Manager`
   - **App contact email**: بريدك
5. اضغط **Create App**
6. من Dashboard:
   - اضغط **Add Product**
   - اختر **Facebook Login** > **Set Up**
7. في Settings > Basic:
   - انسخ **App ID** (هذا هو Client ID)
   - انسخ **App Secret** (اضغط Show)
8. في Facebook Login > Settings:
   - في **Valid OAuth Redirect URIs** أضف:
     ```
     https://mediaprosocial.io/api/auth/facebook/callback
     ```
9. احفظ

✅ **حدث .env:**
```env
FACEBOOK_CLIENT_ID=App_ID_هنا
FACEBOOK_CLIENT_SECRET=App_Secret_هنا
```

🎉 **Facebook جاهز!**

---

### الخطوة 3️⃣: Instagram (يستخدم Facebook)

**الوقت المتوقع:** 5 دقائق

1. في نفس تطبيق Facebook أعلاه
2. اضغ **Add Product**
3. اختر **Instagram Basic Display**
4. اضغط **Create New App**
5. املأ:
   - **Display Name**: `M PRO`
   - **Valid OAuth Redirect URIs**:
     ```
     https://mediaprosocial.io/api/auth/instagram/callback
     ```
6. احفظ
7. انسخ:
   - **Instagram App ID**
   - **Instagram App Secret**

✅ **حدث .env:**
```env
INSTAGRAM_CLIENT_ID=Instagram_App_ID_هنا
INSTAGRAM_CLIENT_SECRET=Instagram_App_Secret_هنا
```

🎉 **Instagram جاهز!**

---

### الخطوة 4️⃣: Twitter/X

**الوقت المتوقع:** 10 دقائق

1. افتح: https://developer.twitter.com/en/portal/dashboard
2. سجل دخول
3. اضغط **+ Create Project**
4. املأ المعلومات المطلوبة
5. أنشئ **App** داخل المشروع
6. في App Settings:
   - انتقل إلى **User authentication settings**
   - اضغط **Set up**
   - Type: **Web App, Automated App or Bot**
   - **Callback URI**:
     ```
     https://mediaprosocial.io/api/auth/twitter/callback
     ```
   - **Website URL**:
     ```
     https://mediaprosocial.io
     ```
7. احفظ
8. انسخ:
   - **API Key** (Client ID)
   - **API Key Secret** (Client Secret)

✅ **حدث .env:**
```env
TWITTER_CLIENT_ID=API_Key_هنا
TWITTER_CLIENT_SECRET=API_Key_Secret_هنا
```

🎉 **Twitter جاهز!**

---

### الخطوة 5️⃣: YouTube (Google)

**الوقت المتوقع:** 10 دقائق

1. افتح: https://console.cloud.google.com/
2. أنشئ **New Project**
3. من القائمة: **APIs & Services** > **Library**
4. ابحث عن: **YouTube Data API v3**
5. اضغط **Enable**
6. انتقل إلى: **Credentials** > **Create Credentials** > **OAuth client ID**
7. إذا طُلب منك، قم بإعداد **OAuth consent screen** أولاً:
   - User Type: **External**
   - املأ المعلومات الأساسية
   - احفظ
8. ارجع إلى **Create OAuth client ID**:
   - Application type: **Web application**
   - **Authorized redirect URIs**:
     ```
     https://mediaprosocial.io/api/auth/youtube/callback
     ```
9. اضغط **Create**
10. انسخ:
    - **Client ID**
    - **Client secret**

✅ **حدث .env:**
```env
GOOGLE_CLIENT_ID=Google_Client_ID_هنا
GOOGLE_CLIENT_SECRET=Google_Client_Secret_هنا
```

🎉 **YouTube جاهز!**

---

### الخطوة 6️⃣: TikTok

**الوقت المتوقع:** 15 دقيقة (يتطلب مراجعة)

⚠️ **ملاحظة:** TikTok يتطلب موافقة من فريقهم (قد يستغرق أيام)

1. افتح: https://developers.tiktok.com/
2. سجل دخول
3. اضغط **Create an app**
4. املأ المعلومات
5. في **Redirect URLs**:
   ```
   https://mediaprosocial.io/api/auth/tiktok/callback
   ```
6. قدم الطلب
7. انتظر الموافقة (1-7 أيام)
8. بعد الموافقة، انسخ:
   - **Client Key**
   - **Client Secret**

✅ **حدث .env:**
```env
TIKTOK_CLIENT_ID=Client_Key_هنا
TIKTOK_CLIENT_SECRET=Client_Secret_هنا
```

---

### الخطوة 7️⃣: Snapchat

**الوقت المتوقع:** 15 دقيقة (يتطلب حساب Business)

1. افتح: https://business.snapchat.com/
2. أنشئ حساب Business
3. انتقل إلى: https://kit.snapchat.com/portal
4. أنشئ OAuth App
5. في Redirect URLs:
   ```
   https://mediaprosocial.io/api/auth/snapchat/callback
   ```
6. انسخ:
   - **OAuth Client ID**
   - **OAuth Client Secret**

✅ **حدث .env:**
```env
SNAPCHAT_CLIENT_ID=OAuth_Client_ID_هنا
SNAPCHAT_CLIENT_SECRET=OAuth_Client_Secret_هنا
```

🎉 **Snapchat جاهز!**

---

## 🔄 بعد الانتهاء من كل منصة

**لا تنسى تشغيل هذه الأوامر في كل مرة:**

```bash
cd /home/u126213189/domains/mediaprosocial.io/public_html
php artisan config:clear
php artisan cache:clear
php artisan route:clear
```

---

## ✅ التحقق من أن كل شيء يعمل

1. افتح التطبيق على الهاتف
2. اذهب إلى **إعدادات** > **ربط الحسابات**
3. جرّب ربط كل منصة

إذا ظهر خطأ:
- تأكد من أن Redirect URL صحيح تماماً
- تأكد من نسخ Client ID و Secret بشكل صحيح
- تأكد من مسح الكاش

---

## 🆘 المساعدة

إذا واجهت مشاكل في أي منصة:

1. **تحقق من Logs:**
   ```bash
   tail -f /home/u126213189/domains/mediaprosocial.io/public_html/storage/logs/laravel.log
   ```

2. **راجع الدليل الكامل:**
   - افتح `OAUTH_SETUP_GUIDE.md` للتفاصيل الكاملة

3. **المنصات الأسهل للبدء:**
   - ✅ LinkedIn (5 دقائق، موافقة فورية)
   - ✅ Facebook (10 دقائق، موافقة فورية)
   - ✅ Google/YouTube (10 دقائق، موافقة فورية)

4. **المنصات التي تحتاج صبر:**
   - ⏳ TikTok (1-7 أيام للموافقة)
   - ⏳ Twitter (قد يحتاج Elevated Access)

---

## 📝 ملاحظات مهمة

1. **وضع Sandbox:**
   - معظم التطبيقات تبدأ في وضع Testing/Sandbox
   - يمكنك اختبارها بحسابك الشخصي
   - للإنتاج الكامل، قدم للمراجعة

2. **الأمان:**
   - لا تشارك Client Secret مع أحد
   - لا تنشره على GitHub
   - استخدم HTTPS دائماً

3. **تكاليف:**
   - جميع المنصات مجانية للاستخدام الأساسي
   - قد تحتاج لترقية للاستخدام المكثف

---

## 🎯 الأولويات

**ابدأ بهذا الترتيب:**

1. ✅ **LinkedIn** (الأسهل والأسرع)
2. ✅ **Facebook** (مهم لـ Instagram)
3. ✅ **Instagram** (يعتمد على Facebook)
4. ✅ **Google/YouTube** (سهل)
5. ⏳ **Twitter** (متوسط)
6. ⏳ **TikTok** (يحتاج وقت)
7. ⏳ **Snapchat** (يحتاج وقت)

---

## ✨ نصيحة أخيرة

**لا تحاول عمل كل شيء دفعة واحدة!**

- ابدأ بـ LinkedIn و Facebook
- اختبرهم
- ثم أضف الباقي تدريجياً

حظاً موفقاً! 🚀
