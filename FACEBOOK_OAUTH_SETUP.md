# Facebook OAuth Setup - MediaPro Social

## الخطوات:

### 1. إنشاء Facebook App
1. اذهب إلى: https://developers.facebook.com/apps
2. اضغط **Create App**
3. اختر **Business** أو **Consumer**
4. املأ المعلومات:
   - **App Name**: MediaPro Social Manager
   - **App Contact Email**: بريدك الإلكتروني
5. اضغط **Create App**

---

### 2. إضافة Facebook Login
1. من Dashboard، اضغط **Add Product**
2. اختر **Facebook Login** → **Set Up**
3. اختر **Web**
4. اترك الإعدادات الافتراضية واضغط **Save**

---

### 3. إعدادات Basic Settings
1. من القائمة اليسرى → **Settings** → **Basic**
2. املأ:
   - **App Domains**: `mediaprosocial.io`
   - **Privacy Policy URL**: `https://mediaprosocial.io/privacy`
   - **Terms of Service URL**: `https://mediaprosocial.io/terms`
3. احفظ التغييرات

---

### 4. إعدادات Facebook Login
1. من القائمة اليسرى → **Facebook Login** → **Settings**
2. في **Valid OAuth Redirect URIs** أضف:
   ```
   https://mediaprosocial.io/api/auth/facebook/callback
   ```
3. في **Valid Deauthorize Callback URL** أضف (اختياري):
   ```
   https://mediaprosocial.io/api/auth/facebook/deauthorize
   ```
4. في **Valid Data Deletion URL** أضف (اختياري):
   ```
   https://mediaprosocial.io/api/auth/facebook/delete
   ```
5. احفظ التغييرات

---

### 5. طلب Permissions (للنشر على Facebook Pages)
1. من القائمة اليسرى → **App Review** → **Permissions and Features**
2. اطلب الـ Permissions التالية:
   - ✅ **pages_manage_posts** - للنشر على الصفحات
   - ✅ **pages_read_engagement** - لقراءة التفاعلات
   - ✅ **pages_show_list** - لعرض قائمة الصفحات
3. اضغط **Get Advanced Access** لكل permission

**ملاحظة**: قد تحتاج إلى App Review من Facebook إذا لم تحصل على الموافقة التلقائية

---

### 6. للنشر على Instagram (اختياري)
إذا أردت دعم Instagram أيضاً:
1. في **App Review** → اطلب:
   - ✅ **instagram_basic**
   - ✅ **instagram_content_publish**

---

### 7. نسخ Credentials
1. ارجع إلى **Settings** → **Basic**
2. انسخ:
   - **App ID**: `1234567890123456` (مثال)
   - **App Secret**: اضغط **Show** ثم انسخ

---

### 8. تفعيل التطبيق (Live Mode)
1. في أعلى الصفحة، ستجد **App Mode: Development**
2. اضغط على الزر واختر **Switch to Live**
3. وافق على الشروط

---

## ✅ الناتج النهائي

احفظ هذه القيم:
```
FACEBOOK_APP_ID=YOUR_APP_ID_HERE
FACEBOOK_APP_SECRET=YOUR_APP_SECRET_HERE
FACEBOOK_REDIRECT_URI=https://mediaprosocial.io/api/auth/facebook/callback
```

---

## 🧪 اختبار سريع

بعد الإعداد، اختبر OAuth URL:
```
https://www.facebook.com/v18.0/dialog/oauth?client_id=YOUR_APP_ID&redirect_uri=https://mediaprosocial.io/api/auth/facebook/callback&scope=pages_manage_posts,pages_read_engagement,pages_show_list
```

افتح هذا الرابط في المتصفح - يجب أن يطلب منك تسجيل الدخول والموافقة.
