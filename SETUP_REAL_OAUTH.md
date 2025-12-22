# 🔐 إعداد OAuth الفعلي للحصول على تحليلات دقيقة 100%

## 📊 لماذا نحتاج OAuth الحقيقي؟

لربط حساباتك الفعلية والحصول على:
- ✅ تحليلات دقيقة من حساباتك
- ✅ عدد المتابعين الحقيقي
- ✅ معدل التفاعل (Likes, Comments, Shares)
- ✅ إحصائيات المنشورات
- ✅ بيانات الجمهور

---

## 🚀 البدء السريع - الأولويات

### المنصات الأساسية (ابدأ بها):
1. **Facebook** (سهل - 10 دقائق) ⭐⭐⭐⭐⭐
2. **Instagram** (يعتمد على Facebook) ⭐⭐⭐⭐⭐
3. **LinkedIn** (سهل - 5 دقائق) ⭐⭐⭐⭐
4. **Twitter/X** (متوسط - 10 دقائق) ⭐⭐⭐

### المنصات المتقدمة (اختياري):
5. **YouTube/Google** (متوسط - 15 دقيقة)
6. **TikTok** (يحتاج موافقة - 3-7 أيام)
7. **Snapchat** (يحتاج Business Account)

---

## 1️⃣ Facebook + Instagram (معاً)

### الخطوة 1: إنشاء تطبيق Facebook

1. **افتح**: https://developers.facebook.com/apps/create/
2. **سجل دخول** بحسابك على Facebook
3. اختر **Business** ثم **Next**
4. املأ البيانات:
   ```
   App name: M PRO Social Manager
   App contact email: بريدك الإلكتروني
   ```
5. اضغط **Create App**

### الخطوة 2: إعداد Facebook Login

1. في Dashboard، اضغط **Add Product**
2. اختر **Facebook Login** > **Set Up**
3. اختر **Web**
4. في **Site URL**:
   ```
   https://mediaprosocial.io
   ```
5. احفظ

### الخطوة 3: إعداد Instagram Basic Display

1. في نفس التطبيق، اضغ **Add Product**
2. اختر **Instagram Basic Display**
3. اضغط **Create New App**
4. املأ:
   ```
   Display Name: M PRO
   Valid OAuth Redirect URIs: https://mediaprosocial.io/api/auth/instagram/callback
   Deauthorize Callback URL: https://mediaprosocial.io/api/auth/instagram/deauthorize
   Data Deletion Request URL: https://mediaprosocial.io/api/auth/instagram/delete
   ```
5. احفظ

### الخطوة 4: الحصول على App ID & Secret

1. اذهب إلى **Settings** > **Basic**
2. انسخ:
   - **App ID** (هذا هو FACEBOOK_CLIENT_ID)
   - **App Secret** (اضغط Show وانسخه - هذا هو FACEBOOK_CLIENT_SECRET)

3. من **Instagram Basic Display** > **Basic Display**:
   - **Instagram App ID** (هذا هو INSTAGRAM_CLIENT_ID)
   - **Instagram App Secret** (هذا هو INSTAGRAM_CLIENT_SECRET)

### الخطوة 5: إضافة Redirect URLs

1. في **Facebook Login** > **Settings**
2. أضف في **Valid OAuth Redirect URIs**:
   ```
   https://mediaprosocial.io/api/auth/facebook/callback
   ```
3. احفظ

### الخطوة 6: طلب Permissions

1. في **App Review** > **Permissions and Features**
2. اطلب:
   - `pages_show_list` (لعرض الصفحات)
   - `pages_read_engagement` (للتحليلات)
   - `instagram_basic` (لـ Instagram)
   - `instagram_manage_insights` (لتحليلات Instagram)

### الخطوة 7: تحديث .env

```bash
ssh u126213189@82.25.83.217 -p 65002
cd /home/u126213189/domains/mediaprosocial.io/public_html
nano .env
```

أضف:
```env
FACEBOOK_CLIENT_ID=your_app_id_here
FACEBOOK_CLIENT_SECRET=your_app_secret_here
INSTAGRAM_CLIENT_ID=your_instagram_app_id_here
INSTAGRAM_CLIENT_SECRET=your_instagram_app_secret_here
```

احفظ بـ `Ctrl+O` ثم `Enter` ثم `Ctrl+X`

امسح الكاش:
```bash
php artisan config:clear
php artisan cache:clear
```

---

## 2️⃣ LinkedIn

### الخطوة 1: إنشاء تطبيق LinkedIn

1. **افتح**: https://www.linkedin.com/developers/apps/new
2. **سجل دخول** بحسابك
3. املأ:
   ```
   App name: M PRO Social Manager
   LinkedIn Page: أنشئ صفحة مؤقتة إذا لم يكن لديك
   Privacy policy URL: https://mediaprosocial.io/privacy
   App logo: أي صورة (200x200 بكسل)
   ```
4. اضغط **Create app**

### الخطوة 2: إعداد OAuth

1. انتقل إلى تبويب **Auth**
2. في **Redirect URLs** أضف:
   ```
   https://mediaprosocial.io/api/auth/linkedin/callback
   ```
3. احفظ

### الخطوة 3: الحصول على Credentials

1. في نفس تبويب **Auth**
2. انسخ:
   - **Client ID**
   - **Client Secret** (اضغط Show)

### الخطوة 4: طلب Products

1. اذهب إلى تبويب **Products**
2. اطلب:
   - **Sign In with LinkedIn using OpenID Connect**
   - **Share on LinkedIn**
   - **Marketing Developer Platform** (للتحليلات)

### الخطوة 5: تحديث .env

```env
LINKEDIN_CLIENT_ID=your_client_id_here
LINKEDIN_CLIENT_SECRET=your_client_secret_here
```

---

## 3️⃣ Twitter/X

### الخطوة 1: إنشاء تطبيق Twitter

1. **افتح**: https://developer.twitter.com/en/portal/dashboard
2. **سجل دخول**
3. اضغط **+ Create Project**
4. املأ المعلومات المطلوبة
5. أنشئ **App** داخل المشروع

### الخطوة 2: إعداد OAuth 2.0

1. في App Settings
2. انتقل إلى **User authentication settings**
3. اضغط **Set up**
4. اختر:
   ```
   Type: Web App, Automated App or Bot
   App permissions: Read and write

   Callback URI: https://mediaprosocial.io/api/auth/twitter/callback
   Website URL: https://mediaprosocial.io
   ```
5. احفظ

### الخطوة 3: الحصول على Credentials

1. في **Keys and tokens**
2. انسخ:
   - **API Key** (هذا هو CLIENT_ID)
   - **API Key Secret** (هذا هو CLIENT_SECRET)
   - **Bearer Token** (اختياري للتحليلات)

### الخطوة 4: Elevated Access (اختياري)

للحصول على تحليلات متقدمة:
1. في Developer Portal، اذهب إلى **Products**
2. اطلب **Elevated** access
3. أجب على الأسئلة عن استخدامك للـ API

### الخطوة 5: تحديث .env

```env
TWITTER_CLIENT_ID=your_api_key_here
TWITTER_CLIENT_SECRET=your_api_secret_here
TWITTER_BEARER_TOKEN=your_bearer_token_here
```

---

## 4️⃣ YouTube/Google

### الخطوة 1: Google Cloud Console

1. **افتح**: https://console.cloud.google.com/
2. أنشئ **New Project**:
   ```
   Project name: M PRO Social Manager
   ```

### الخطوة 2: تفعيل YouTube Data API

1. من القائمة: **APIs & Services** > **Library**
2. ابحث عن: **YouTube Data API v3**
3. اضغط **Enable**

### الخطوة 3: OAuth Consent Screen

1. اذهب إلى: **APIs & Services** > **OAuth consent screen**
2. اختر **External**
3. املأ:
   ```
   App name: M PRO Social Manager
   User support email: بريدك
   Developer contact: بريدك
   ```
4. في **Scopes**، أضف:
   - `youtube.readonly` (لقراءة البيانات)
   - `youtube.force-ssl` (للتحليلات)
5. احفظ

### الخطوة 4: Create OAuth Client ID

1. **APIs & Services** > **Credentials**
2. **Create Credentials** > **OAuth client ID**
3. اختر:
   ```
   Application type: Web application
   Name: M PRO Web Client

   Authorized redirect URIs:
   https://mediaprosocial.io/api/auth/youtube/callback
   https://mediaprosocial.io/api/auth/google/callback
   ```
4. اضغط **Create**

### الخطوة 5: الحصول على Credentials

انسخ:
- **Client ID**
- **Client secret**

### الخطوة 6: تحديث .env

```env
GOOGLE_CLIENT_ID=your_client_id_here
GOOGLE_CLIENT_SECRET=your_client_secret_here
```

---

## 🧪 اختبار OAuth

بعد إعداد كل منصة:

1. **افتح التطبيق** على هاتفك
2. اذهب إلى **إعدادات** > **ربط الحسابات**
3. اضغط على المنصة (مثلاً Facebook)
4. سيفتح متصفح لتسجيل الدخول
5. وافق على الصلاحيات
6. سيتم إعادتك للتطبيق مع حسابك مربوط

### التحقق من نجاح الربط:

```bash
# على السيرفر
ssh u126213189@82.25.83.217 -p 65002
cd /home/u126213189/domains/mediaprosocial.io/public_html

# تحقق من الحسابات المربوطة
php artisan tinker
>>> App\Models\SocialAccount::all();
```

---

## 🔍 استخراج التحليلات

بعد ربط الحسابات، سيبدأ التطبيق بجلب:

### Facebook & Instagram:
- عدد المتابعين
- Reach & Impressions
- Engagement Rate
- Post Performance
- Audience Demographics

### LinkedIn:
- Profile Views
- Post Impressions
- Engagement
- Follower Growth

### Twitter:
- Followers Count
- Tweet Impressions
- Engagement Rate
- Retweets & Likes

### YouTube:
- Subscribers
- Views
- Watch Time
- Engagement Rate

---

## ⚠️ ملاحظات مهمة

### 1. وضع Development vs Production

معظم التطبيقات تبدأ في وضع **Development**:
- ✅ يمكنك اختبارها بحسابك
- ⚠️ محدودة بعدد قليل من المستخدمين
- 🔄 للإنتاج الكامل، قدم للمراجعة

### 2. Permissions & Scopes

كل منصة تطلب موافقة على الصلاحيات:
- **Basic**: معلومات الملف الشخصي
- **Read**: قراءة المنشورات والتحليلات
- **Write**: نشر محتوى (اختياري)

### 3. Rate Limits

كل API له حدود:
- Facebook: 200 calls/hour/user
- LinkedIn: 500 calls/day
- Twitter: 500,000 tweets/month (Free tier)
- YouTube: 10,000 units/day

### 4. الأمان

🔒 **مهم جداً**:
- لا تشارك Client Secret مع أحد
- لا تنشره على GitHub
- استخدم HTTPS دائماً
- راجع الصلاحيات دورياً

---

## 🆘 حل المشاكل

### خطأ "Invalid Redirect URI"
- تأكد أن الـ URL في التطبيق يطابق تماماً الـ URL في الكود
- استخدم `https://` وليس `http://`

### خطأ "Invalid Client ID"
- تأكد من نسخ الـ ID بشكل صحيح (بدون مسافات)
- امسح الكاش: `php artisan config:clear`

### "This app is in development mode"
- طبيعي في البداية
- قدم للمراجعة عندما تكون جاهزاً للإنتاج

### لا يتم جلب التحليلات
- تأكد من طلب الـ Permissions الصحيحة
- بعض المنصات تحتاج وقت لتفعيل الصلاحيات
- راجع الـ Logs: `tail -f storage/logs/laravel.log`

---

## 📝 Checklist

قبل البدء، تأكد أن لديك:

- [ ] حساب فعال على كل منصة
- [ ] بريد إلكتروني موثق
- [ ] رقم هاتف (بعض المنصات تطلبه)
- [ ] صورة لوجو التطبيق (200x200)
- [ ] Privacy Policy URL
- [ ] Terms of Service URL (اختياري)

---

## 🎯 الخطوات التالية

1. **ابدأ بـ Facebook** (الأسهل والأسرع)
2. **ثم Instagram** (يعتمد على Facebook)
3. **ثم LinkedIn** (سهل جداً)
4. **Twitter** (متوسط الصعوبة)
5. **YouTube** (إذا كنت تستخدمه)
6. **TikTok & Snapchat** (اختياري)

---

## 💡 نصيحة احترافية

**لا تحاول عمل كل شيء مرة واحدة!**

- ابدأ بمنصة واحدة (Facebook مثلاً)
- اختبرها جيداً
- تأكد أن التحليلات تظهر بشكل صحيح
- ثم انتقل للمنصة التالية

هذا سيوفر عليك الكثير من الوقت في حل المشاكل!

---

حظاً موفقاً! 🚀

إذا واجهت أي مشكلة، راجع قسم "حل المشاكل" أعلاه.
