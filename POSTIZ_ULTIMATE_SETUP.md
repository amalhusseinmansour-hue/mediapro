# 🚀 إعداد Postiz Ultimate Plan - دليل سريع

## ✅ رائع! لديك Ultimate Plan 🎉

أنت الآن تملك أقوى خطة في Postiz مع:
- ✅ منشورات غير محدودة
- ✅ حسابات غير محدودة
- ✅ جميع المنصات (13+ منصة)
- ✅ AI Features
- ✅ Analytics متقدمة
- ✅ API Access

---

## 📋 الخطوات (5 دقائق):

### الخطوة 1: احصل على API Key من Postiz Dashboard

#### طريقة 1: من Settings (الأكثر شيوعاً)

```
1. اذهب إلى: https://platform.postiz.com
2. سجل الدخول
3. اضغط على أيقونة Settings ⚙️ (أعلى اليمين أو اليسار)
4. ابحث عن "API" أو "API Keys" أو "Integrations"
5. اضغط "Generate API Key" أو "Create New Key"
6. اختر اسم للـ Key (مثلاً: "MediaProSocial")
7. اضغط Create
8. انسخ الـ API Key (يبدأ بـ pk_live_... أو api_...)
```

#### طريقة 2: من Profile/Account Settings

```
1. https://platform.postiz.com
2. اضغط على صورة الملف الشخصي أو Avatar
3. Settings → API Keys
4. Create New API Key
5. انسخه
```

#### طريقة 3: من Developer Section

```
1. https://platform.postiz.com
2. Developer أو API Documentation
3. Generate API Key
4. انسخه
```

---

### الخطوة 2: تحديث Laravel Backend (2 دقيقة)

#### اتصل بالخادم:

```bash
ssh u126213189@82.25.83.217 -p 65002
```

#### عدّل .env:

```bash
cd /home/u126213189/domains/mediaprosocial.io/public_html
nano .env
```

#### ابحث عن:
```env
POSTIZ_API_KEY=
POSTIZ_BASE_URL=https://api.postiz.com/public/v1
```

#### غيّره إلى:
```env
POSTIZ_API_KEY=pk_live_xxxxxxxxxxxxxxxxxxxxxxxx
POSTIZ_BASE_URL=https://api.postiz.com/public/v1
```
*أو قد يكون:*
```env
POSTIZ_BASE_URL=https://platform.postiz.com/api/v1
```

#### احفظ:
```
Ctrl + O → Enter → Ctrl + X
```

#### نظّف Cache:
```bash
php artisan config:clear
php artisan route:clear
```

---

### الخطوة 3: تحديث Flutter App (1 دقيقة)

```bash
cd C:\Users\HP\social_media_manager
notepad .env
```

#### غيّر:
```env
POSTIZ_API_KEY=pk_live_xxxxxxxxxxxxxxxxxxxxxxxx
POSTIZ_BASE_URL=https://api.postiz.com/public/v1
```

#### احفظ

---

### الخطوة 4: تحديث backend_config.dart (1 دقيقة)

```bash
notepad lib\core\config\backend_config.dart
```

#### ابحث عن السطر 68:
```dart
static const String postizBaseUrl = 'https://api.postiz.com/public/v1';
```

#### تأكد أنه صحيح (أو غيّره إذا كان مختلفاً)

#### احفظ

---

### الخطوة 5: اختبار الاتصال (1 دقيقة)

#### من الخادم:

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
  https://api.postiz.com/public/v1/integrations
```

**يجب أن يرجع JSON بدون أخطاء ✅**

---

### الخطوة 6: Build & Run Flutter App

```bash
cd C:\Users\HP\social_media_manager
flutter pub get
flutter run
```

---

## 🧪 الاختبار الكامل

### اختبار 1: من Postiz Dashboard مباشرة

```
1. اذهب إلى: https://platform.postiz.com
2. Channels أو Integrations
3. اضغط "Connect" بجانب Facebook
4. سجل دخول وأعط الصلاحيات
5. يجب أن يظهر الحساب مربوط ✅
```

### اختبار 2: نشر منشور من Postiz

```
1. في Postiz Dashboard
2. اضغط "New Post" أو "Create"
3. اكتب نص
4. اختر الحساب المربوط
5. اضغط "Publish Now"
6. تحقق من ظهوره على Facebook ✅
```

### اختبار 3: من Flutter App

```
1. افتح التطبيق
2. اذهب "إدارة Social Media"
3. يجب أن ترى الحسابات المربوطة من Postiz ✅
4. اضغط "إنشاء منشور"
5. اكتب محتوى
6. اختر الحساب
7. اضغط "نشر"
8. تحقق من ظهوره على Facebook ✅
```

---

## 🔍 إذا لم تجد API Key

### جرب هذه الروابط:

```
https://platform.postiz.com/settings
https://platform.postiz.com/settings/api
https://platform.postiz.com/api
https://platform.postiz.com/developer
https://platform.postiz.com/account/api-keys
```

### أو تحقق من:

1. **Dashboard Sidebar** - ابحث عن:
   - Settings
   - API
   - Developer
   - Integrations
   - Account

2. **Profile Menu** (أعلى اليمين):
   - Settings
   - API Keys

3. **Help/Support**:
   - اضغط على أيقونة المساعدة
   - ابحث عن "API Key"

---

## 📱 معلومات الاتصال بـ Postiz Support

إذا لم تجد API Key:

**Email:** support@postiz.com
**الطريقة:**
```
1. في https://platform.postiz.com
2. ابحث عن أيقونة Chat أو Help
3. اسألهم: "How do I get my API key?"
```

---

## 🎯 نقاط مهمة

### Base URL الصحيح:

Postiz Platform قد يستخدم أحد هذه:
- `https://api.postiz.com/public/v1`
- `https://platform.postiz.com/api/v1`
- `https://api.platform.postiz.com/v1`

**جرّب الأول، إذا لم يعمل، جرّب الباقي**

### API Key Format:

قد يبدأ بـ:
- `pk_live_...`
- `api_...`
- `postiz_...`
- أو string عشوائي طويل

---

## ✅ Checklist

- [ ] حصلت على API Key من Postiz Dashboard
- [ ] حدّثت Laravel `.env` (POSTIZ_API_KEY)
- [ ] حدّثت Flutter `.env` (POSTIZ_API_KEY)
- [ ] نظّفت Laravel cache (config:clear)
- [ ] ربطت حساب واحد على الأقل في Postiz Dashboard
- [ ] اختبرت النشر من Postiz Dashboard
- [ ] شغّلت Flutter App
- [ ] اختبرت عرض الحسابات في التطبيق
- [ ] اختبرت النشر من التطبيق

---

## 🎉 بعد الانتهاء

عند نجاح كل الاختبارات:

```
✅ Postiz Ultimate Active
✅ API Key Working
✅ Laravel Backend Connected
✅ Flutter App Connected
✅ يمكن ربط الحسابات
✅ يمكن النشر
✅ يمكن الجدولة
✅ يمكن عرض Analytics

🚀 كل شيء يعمل!
```

---

## 💡 Tips للاستفادة من Ultimate Plan

### 1. ربط جميع الحسابات:
```
- Facebook Pages
- Instagram Business
- Twitter/X
- LinkedIn
- TikTok
- YouTube
- Reddit
- Pinterest
```

### 2. استخدام AI Features:
```
- AI Content Generation
- AI Image Generation
- Best Time to Post
- Hashtag Suggestions
```

### 3. Advanced Analytics:
```
- Track all metrics
- Compare platforms
- Engagement reports
- Growth tracking
```

---

## 🆘 المساعدة

إذا واجهت مشكلة:

1. **تحقق من API Key:**
   ```bash
   curl -H "Authorization: Bearer YOUR_KEY" https://api.postiz.com/public/v1/integrations
   ```

2. **تحقق من Laravel:**
   ```bash
   curl https://mediaprosocial.io/api/postiz/status
   ```

3. **تحقق من Flutter logs:**
   ```bash
   flutter run --verbose
   ```

---

**آخر تحديث:** 2025-11-15
**الحالة:** ✅ Ultimate Plan Active - يحتاج API Key فقط
**الوقت المتبقي:** 5 دقائق
