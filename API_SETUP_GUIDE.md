# دليل الحصول على API Keys للتكاملات

## 1. Upload-Post.com API Setup

### الخطوات:

1. **إنشاء حساب**
   - زيارة: https://www.upload-post.com/
   - إنشاء حساب جديد أو تسجيل الدخول
   - اختيار الباقة المناسبة (يوجد خطة مجانية للتجربة)

2. **الحصول على API Key**
   - بعد تسجيل الدخول، اذهب إلى: **Settings** → **API Integration**
   - أو مباشرة: https://www.upload-post.com/settings/api
   - انقر على "Generate API Key"
   - احفظ الـ API Key في مكان آمن

3. **معلومات API المطلوبة:**
   ```
   API_KEY: سيظهر لك بعد التسجيل
   API_ENDPOINT: https://api.upload-post.com/v1
   ```

4. **ربط منصات السوشيال ميديا:**
   - من لوحة التحكم، اذهب إلى "Social Accounts"
   - اربط الحسابات التالية:
     - Facebook
     - Instagram
     - Twitter/X
     - LinkedIn
     - TikTok
     - YouTube
     - Pinterest

### وثائق API:
- الوثائق الرسمية: https://docs.upload-post.com/api
- المنصات المدعومة: https://www.upload-post.com/supported-platforms

---

## 2. Kie.ai API Setup

### الخطوات:

1. **إنشاء حساب**
   - زيارة: https://kie.ai/
   - تسجيل حساب جديد (يمكنك استخدام Google للتسجيل السريع)
   - تأكيد البريد الإلكتروني

2. **الحصول على API Credentials**
   - اذهب إلى: **Dashboard** → **API Keys**
   - أو: https://kie.ai/dashboard/api
   - انقر على "Create New API Key"
   - اختر الصلاحيات:
     - ✅ Video Generation
     - ✅ Image Generation
     - ✅ Image Editing
   - احفظ API Key و Secret Key

3. **معلومات API المطلوبة:**
   ```
   API_KEY: سيظهر بعد الإنشاء
   SECRET_KEY: سيظهر مرة واحدة فقط - احفظه!
   API_ENDPOINT: https://api.kie.ai/v1
   ```

4. **اختبار API:**
   يمكنك اختبار API من خلال:
   ```bash
   curl -X POST https://api.kie.ai/v1/generate/image \
     -H "Authorization: Bearer YOUR_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"prompt": "test image", "size": "1024x1024"}'
   ```

### وثائق API:
- الوثائق الرسمية: https://docs.kie.ai/
- أمثلة الاستخدام: https://kie.ai/examples

---

## 3. إعداد المتغيرات في Laravel

بعد الحصول على API Keys، أضفها إلى ملف `.env`:

```env
# Upload-Post Configuration
UPLOAD_POST_API_KEY=your_upload_post_api_key_here
UPLOAD_POST_ENDPOINT=https://api.upload-post.com/v1

# Kie.ai Configuration
KIE_AI_API_KEY=your_kie_ai_api_key_here
KIE_AI_SECRET_KEY=your_kie_ai_secret_key_here
KIE_AI_ENDPOINT=https://api.kie.ai/v1
```

---

## 4. n8n Setup (سيتم التثبيت محلياً)

### المتطلبات:
- Node.js 16+ (يفضل 18 أو 20)
- npm أو pnpm

### التثبيت:
```bash
# باستخدام npm
npm install -g n8n

# أو باستخدام pnpm (أسرع)
pnpm install -g n8n

# تشغيل n8n
n8n start
```

سيفتح على: http://localhost:5678

---

## 5. ملاحظات مهمة

### Upload-Post.com:
- ⚠️ لديهم حدود للطلبات (Rate Limits) حسب الباقة
- 📊 الباقة المجانية: 100 منشور/شهر
- 💰 الباقة المدفوعة: منشورات غير محدودة

### Kie.ai:
- ⚠️ كل طلب يستهلك credits
- 🎁 رصيد مجاني عند التسجيل: 100 credits
- 📸 صورة واحدة ≈ 1-2 credits
- 🎥 فيديو قصير ≈ 5-10 credits

### الأمان:
- ❌ لا تشارك API Keys أبداً
- ✅ احفظها في `.env` فقط
- ✅ أضف `.env` إلى `.gitignore`
- ✅ استخدم `.env.example` للمشاركة مع الفريق

---

## 6. الخطوات التالية

بعد الحصول على جميع API Keys:

1. ✅ تحديث ملف `.env` بالمعلومات
2. ✅ تشغيل n8n محلياً
3. ✅ سأقوم ببناء التكاملات في Laravel
4. ✅ إنشاء واجهات Filament للإدارة
5. ✅ بناء workflows في n8n للأتمتة الكاملة

---

## 🆘 محتاج مساعدة؟

إذا واجهت أي مشكلة:
- Upload-Post Support: https://www.upload-post.com/support
- Kie.ai Support: support@kie.ai
- n8n Community: https://community.n8n.io/
