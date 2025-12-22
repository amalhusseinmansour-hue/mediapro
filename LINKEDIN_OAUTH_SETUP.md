# LinkedIn OAuth Setup - MediaPro Social

## الخطوات:

### 1. إنشاء LinkedIn App
1. اذهب إلى: https://www.linkedin.com/developers/apps
2. سجل دخول بحساب LinkedIn الخاص بك
3. اضغط **Create app**
4. املأ النموذج:
   - **App name**: MediaPro Social Manager
   - **LinkedIn Page**: اختر صفحة شركتك أو أنشئ صفحة جديدة
     - (إذا لم يكن لديك، اذهب إلى https://www.linkedin.com/company/setup/new/ وأنشئ صفحة)
   - **Privacy policy URL**: `https://mediaprosocial.io/privacy`
   - **App logo**: ارفع شعار التطبيق (يجب أن يكون 300x300px على الأقل)
   - **Legal agreement**: ✅ وافق على الشروط
5. اضغط **Create app**

---

### 2. التحقق من التطبيق (Verify)
1. بعد إنشاء التطبيق، ستجد تحذير **Verify**
2. اضغط **Verify** → اتبع التعليمات
3. طرق التحقق:
   - **URL verification**: أضف verification URL في موقعك
   - **Email verification**: استخدم بريد نفس domain الموقع
4. بعد التحقق، ستحصل على ✅ **Verified** badge

---

### 3. طلب Products (Permissions)
1. من تبويب **Products**
2. اطلب **Share on LinkedIn** (مجاني):
   - اضغط **Request access**
   - عادة تتم الموافقة فوراً
3. (اختياري) اطلب **Sign In with LinkedIn** إذا أردت:
   - اضغط **Request access**

بعد الموافقة ستظهر ✅ **Added** بجانب المنتج

---

### 4. إعدادات Auth
1. من تبويب **Auth**
2. في قسم **OAuth 2.0 settings**:

   **Redirect URLs**:
   - اضغط **Add redirect URL**
   - أضف:
     ```
     https://mediaprosocial.io/api/auth/linkedin/callback
     ```
   - اضغط **Update**

3. تحقق من **OAuth 2.0 scopes** - يجب أن تكون موجودة:
   - ✅ `r_liteprofile` أو `r_basicprofile` - لقراءة الملف الشخصي
   - ✅ `w_member_social` - للنشر على LinkedIn

---

### 5. نسخ Credentials
1. من تبويب **Auth**
2. في قسم **Application credentials**:
   - **Client ID**: `1234567890abcdef` (مثال)
   - **Client Secret**: اضغط **Show** ثم انسخ

**احفظها بأمان!**

---

### 6. إعدادات إضافية (اختياري)
1. من تبويب **Settings**:
   - يمكنك تعديل:
     - App logo
     - Privacy policy
     - Terms of service
2. من تبويب **Analytics**:
   - يمكنك متابعة استخدام الـ OAuth

---

## ✅ الناتج النهائي

احفظ هذه القيم:
```
LINKEDIN_CLIENT_ID=YOUR_CLIENT_ID_HERE
LINKEDIN_CLIENT_SECRET=YOUR_CLIENT_SECRET_HERE
LINKEDIN_REDIRECT_URI=https://mediaprosocial.io/api/auth/linkedin/callback
```

---

## 🧪 اختبار سريع

اختبر OAuth URL:
```
https://www.linkedin.com/oauth/v2/authorization?client_id=YOUR_CLIENT_ID&redirect_uri=https://mediaprosocial.io/api/auth/linkedin/callback&scope=r_liteprofile%20w_member_social&response_type=code&state=test123
```

افتح هذا الرابط في المتصفح - يجب أن يطلب منك Authorize the app.

---

## 📌 ملاحظات مهمة

### Scopes المتاحة:

**مع Share on LinkedIn Product**:
- `r_liteprofile` - معلومات أساسية (اسم، صورة)
- `r_emailaddress` - البريد الإلكتروني
- `w_member_social` - النشر على LinkedIn profile/page

**مع Sign In with LinkedIn Product**:
- `r_basicprofile` - معلومات موسعة
- `r_liteprofile` - معلومات أساسية

### API Versions:
- LinkedIn تستخدم **API v2**
- endpoint للنشر: `https://api.linkedin.com/v2/ugcPosts`
- endpoint للملف الشخصي: `https://api.linkedin.com/v2/me`

### Limitations:
- **Free tier** بدون حدود واضحة للنشر
- لكن يجب التقيد بـ **LinkedIn API Terms**
- لا تنشر spam أو محتوى مكرر

---

## 🔧 Troubleshooting

**إذا لم تستطع Verify التطبيق**:
1. تأكد أن domain موقعك نشط وصالح
2. أضف صفحة privacy policy على الموقع
3. استخدم بريد إلكتروني بنفس domain الموقع

**إذا لم تحصل على "Share on LinkedIn"**:
1. تأكد أن التطبيق **Verified** ✅
2. حاول مرة أخرى بعد التحقق
3. LinkedIn قد تطلب معلومات إضافية عن الاستخدام
