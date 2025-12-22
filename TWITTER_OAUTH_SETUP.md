# Twitter (X) OAuth Setup - MediaPro Social

## الخطوات:

### 1. إنشاء Twitter Developer Account
1. اذهب إلى: https://developer.twitter.com/portal
2. سجل دخول بحساب Twitter الخاص بك
3. إذا لم يكن لديك حساب مطور، اضغط **Sign up for a developer account**
4. املأ النموذج:
   - **What's your use case?**: Building tools for other Twitter users
   - **Will you make Twitter content available to government entities?**: No

---

### 2. إنشاء Project & App
1. من Dashboard اضغط **+ Create Project**
2. املأ المعلومات:
   - **Project Name**: MediaPro Social Manager
   - **Use Case**: Making a bot (اختر أي خيار مناسب)
   - **Project Description**: Social media management platform
3. اضغط **Next**
4. **App Name**: mediapro-social-app
5. اضغط **Complete**

---

### 3. إعدادات OAuth 2.0
1. من App Dashboard → **Settings**
2. اضغط **Set up** في قسم **User authentication settings**
3. اختر **OAuth 2.0**
4. املأ الإعدادات:

   **App permissions**:
   - ✅ **Read and write** (للنشر على Twitter)

   **Type of App**:
   - ✅ **Web App** (اختار هذا)

   **App info**:
   - **Callback URI / Redirect URL**:
     ```
     https://mediaprosocial.io/api/auth/twitter/callback
     ```
   - **Website URL**:
     ```
     https://mediaprosocial.io
     ```
   - **Terms of service**:
     ```
     https://mediaprosocial.io/terms
     ```
   - **Privacy policy**:
     ```
     https://mediaprosocial.io/privacy
     ```

5. اضغط **Save**

---

### 4. نسخ Credentials
بعد الحفظ، ستظهر لك:
- **Client ID**: `xxxxxxxxxxxxxxxxxxxxxxxx`
- **Client Secret**: `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

**مهم**: احفظ **Client Secret** الآن! لن تستطيع رؤيته مرة أخرى.

---

### 5. إعدادات إضافية (اختياري)
1. من **Keys and tokens** tab:
   - يمكنك إنشاء **API Key & Secret** (للاستخدامات المتقدمة)
   - يمكنك إنشاء **Bearer Token** (للقراءة فقط)

لكن **للـ OAuth 2.0** نحتاج فقط **Client ID** و **Client Secret** من الخطوة السابقة.

---

### 6. رفع Access Level (إذا لزم الأمر)
1. من Dashboard الرئيسي → اذهب إلى **Projects & Apps**
2. اضغط على App الخاص بك
3. من **Settings** → تحقق من **Access Level**:
   - إذا كان **Read only** → اضغط **Edit** وغيره إلى **Read and write**

---

## ✅ الناتج النهائي

احفظ هذه القيم:
```
TWITTER_CLIENT_ID=YOUR_CLIENT_ID_HERE
TWITTER_CLIENT_SECRET=YOUR_CLIENT_SECRET_HERE
TWITTER_REDIRECT_URI=https://mediaprosocial.io/api/auth/twitter/callback
```

---

## 🧪 اختبار سريع

اختبر OAuth URL:
```
https://twitter.com/i/oauth2/authorize?client_id=YOUR_CLIENT_ID&redirect_uri=https://mediaprosocial.io/api/auth/twitter/callback&scope=tweet.read%20tweet.write%20users.read%20offline.access&response_type=code&state=test123&code_challenge=challenge&code_challenge_method=plain
```

افتح هذا الرابط في المتصفح - يجب أن يطلب منك Authorize the app.

---

## 📌 ملاحظات مهمة

1. **Free Tier Limitations**:
   - Twitter Developer Free tier يسمح بـ 1,500 tweet/month
   - للاستخدام الأكبر، ستحتاج **Basic** ($100/month) أو **Pro** plan

2. **Scopes المطلوبة**:
   - `tweet.read` - قراءة التغريدات
   - `tweet.write` - كتابة تغريدات جديدة
   - `users.read` - قراءة معلومات المستخدم
   - `offline.access` - للحصول على refresh token

3. **Code Challenge**:
   - Controller الخاص بي يستخدم `code_challenge=challenge` و `code_challenge_method=plain`
   - هذا للأمان (PKCE flow)
