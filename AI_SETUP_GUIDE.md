# 🤖 دليل تفعيل مزودي الذكاء الاصطناعي

## 1️⃣ OpenAI (GPT-4, GPT-4 Turbo)

### الخطوات:
1. اذهب إلى: https://platform.openai.com/signup
2. قم بالتسجيل أو الدخول
3. اذهب إلى: https://platform.openai.com/api-keys
4. اضغط "Create new secret key"
5. انسخ المفتاح (سيظهر مرة واحدة فقط)
6. ضعه في `.env`:

```env
OPENAI_API_KEY=sk-proj-your_full_key_here
```

### النماذج المتاحة:
- `gpt-4-turbo` (أسرع وأرخص من GPT-4)
- `gpt-4` (الأفضل للمحادثات المعقدة)
- `gpt-3.5-turbo` (الأسرع والأرخص)

### الاستخدام:
```bash
POST /api/ai/social-content
{
  "topic": "منتج جديد",
  "platform": "instagram",
  "ai_provider": "openai"
}
```

### الأسعار:
- GPT-4 Turbo: $0.01 لكل 1K tokens (input), $0.03 (output)
- GPT-3.5-turbo: $0.001 input, $0.002 output

---

## 2️⃣ Claude (Anthropic)

### الخطوات:
1. اذهب إلى: https://www.anthropic.com/
2. ادخل إلى: https://console.anthropic.com/
3. سجل حساباً جديداً
4. اذهب إلى "API Keys"
5. أنشئ مفتاح جديد
6. ضعه في `.env`:

```env
CLAUDE_API_KEY=sk-ant-your_full_key_here
CLAUDE_MODEL=claude-3-5-sonnet-20241022
```

### النماذج المتاحة:
- `claude-3-5-sonnet-20241022` (الأفضل للمحتوى العربي)
- `claude-3-opus-20250219` (الأقوى)
- `claude-3-haiku-20250307` (الأسرع والأرخص)

### الاستخدام:
```bash
POST /api/ai/social-content
{
  "topic": "تسويق المنتجات",
  "platform": "instagram",
  "ai_provider": "claude"
}
```

### المميزات الخاصة:
- ✅ دعم ممتاز للعربية
- ✅ فهم عميق للسياق
- ✅ محادثات طبيعية جداً
- ✅ أكثر أماناً وموثوقية

### الأسعار:
- Sonnet: $0.003 input, $0.015 output
- Opus: $0.015 input, $0.075 output
- Haiku: $0.00080 input, $0.0024 output

---

## 3️⃣ Google Gemini

### الخطوات:
1. اذهب إلى: https://ai.google.dev/
2. اضغط "Get API Key"
3. سجل أو ادخل بحسابك Google
4. أنشئ مفتاح جديد
5. ضعه في `.env`:

```env
GEMINI_API_KEY=AIzaSy...
GEMINI_MODEL=gemini-2.0-flash
```

### النماذج المتاحة:
- `gemini-2.0-flash` (الأسرع)
- `gemini-pro` (الأقوى)
- `gemini-pro-vision` (للصور)

### الاستخدام:
```bash
POST /api/ai/social-content
{
  "topic": "تطبيق جديد",
  "platform": "instagram",
  "ai_provider": "gemini"
}
```

### الأسعار:
- **مجاني** حتى 60 طلب/دقيقة
- بعدها: $1.50 لكل مليون input tokens

---

## 4️⃣ Kie AI (للفيديو)

### الخطوات:
1. اذهب إلى: https://kie.ai/
2. سجل حساباً
3. اذهب إلى "API Settings"
4. انسخ المفاتيح:

```env
KIE_AI_API_KEY=your_api_key
KIE_AI_SECRET_KEY=your_secret_key
```

### الميزات:
- ✅ توليد فيديوهات من النصوص
- ✅ توليد فيديوهات من الصور
- ✅ محرر الفيديو الذكي
- ✅ دعم العربية والإنجليزية

### الاستخدام:
```bash
POST /api/video/generate
{
  "prompt": "اصنع فيديو عن التسويق الرقمي",
  "duration": 30,
  "style": "professional"
}
```

---

## 🔄 اختبار جميع المزودين

### الكود:
```php
// app/Http/Controllers/Api/AiController.php
// أضف هذا الـ endpoint:

public function testAllProviders()
{
    $aiService = app(AdvancedAIContentService::class);
    
    $prompt = "أكتب جملة تسويقية قصيرة ومؤثرة";
    
    $results = [];
    
    foreach (['openai', 'claude', 'gemini'] as $provider) {
        try {
            $result = $aiService->generateText($prompt, [
                'provider' => $provider,
            ]);
            $results[$provider] = $result;
        } catch (\Exception $e) {
            $results[$provider] = ['error' => $e->getMessage()];
        }
    }
    
    return response()->json($results);
}
```

### الاستخدام:
```bash
GET /api/ai/test-providers
```

### النتيجة المتوقعة:
```json
{
  "openai": {
    "success": true,
    "content": "اكتشف المنتج الذي سيغير حياتك! جودة عالية، سعر معقول، خدمة ممتازة.",
    "provider": "openai",
    "tokens_used": 45
  },
  "claude": {
    "success": true,
    "content": "انضم إلينا اليوم واستمتع بتجربة لا تُنسى مع أفضل المنتجات في السوق.",
    "provider": "claude",
    "tokens_used": 52
  },
  "gemini": {
    "success": true,
    "content": "اختر الأفضل، اختر منتجاتنا المميزة بأسعار خاصة الآن!",
    "provider": "gemini",
    "tokens_used": 0
  }
}
```

---

## 💰 مقارنة الأسعار والأداء

| المزود | السرعة | الجودة | السعر | العربية | الموصى به |
|-------|--------|--------|-------|---------|----------|
| **OpenAI** | ⚡⚡⚡ | ⭐⭐⭐⭐⭐ | $$$ | جيد | للمحتوى الاحترافي |
| **Claude** | ⚡⚡ | ⭐⭐⭐⭐⭐ | $$ | ممتاز ✅ | للمحتوى العربي |
| **Gemini** | ⚡⚡⚡⚡ | ⭐⭐⭐⭐ | مجاني* | جيد | للاختبار والبدء |
| **Kie AI** | ⚡⚡ | ⭐⭐⭐⭐ | $$ | ممتاز | للفيديوهات |

---

## 🎯 التوصيات

### للمحتوى العربي 🇸🇦:
```env
# الخيار الأول (الأفضل):
CLAUDE_API_KEY=sk-ant-...

# الخيار الثاني (البديل):
OPENAI_API_KEY=sk-proj-...

# الخيار الثالث (المجاني):
GEMINI_API_KEY=AIzaSy...
```

### للفيديوهات:
```env
KIE_AI_API_KEY=...
KIE_AI_SECRET_KEY=...
```

### للصور:
```env
REPLICATE_API_TOKEN=...
```

---

## 🚀 البدء السريع

### 1. اختبر بـ Gemini (مجاني):
```bash
# أضف المفتاح:
GEMINI_API_KEY=AIzaSyBLA_SRIy50VCg_xyjlH9Oe-igIybLYAKs

# جرب:
POST /api/ai/social-content
{
  "topic": "اختبر هذا",
  "platform": "instagram"
}
```

### 2. أضف Claude (للعربية):
```bash
# احصل على مفتاح من:
https://console.anthropic.com/

# أضفه:
CLAUDE_API_KEY=sk-ant-...

# جرب:
POST /api/ai/social-content
{
  "topic": "منتج جديد",
  "platform": "instagram",
  "ai_provider": "claude"
}
```

### 3. أضف OpenAI (للجودة):
```bash
# احصل على مفتاح من:
https://platform.openai.com/api-keys

# أضفه:
OPENAI_API_KEY=sk-proj-...

# جرب:
POST /api/ai/social-content
{
  "topic": "حملة تسويقية",
  "platform": "instagram",
  "ai_provider": "openai"
}
```

---

## ✅ خطوات التفعيل الكاملة

### في `/backend/.env`:
```env
# Gemini (مجاني للبدء)
GEMINI_API_KEY=AIzaSy...

# Claude (للعربية)
CLAUDE_API_KEY=sk-ant-...

# OpenAI (للجودة العالية)
OPENAI_API_KEY=sk-proj-...

# Kie AI (للفيديو)
KIE_AI_API_KEY=...
KIE_AI_SECRET_KEY=...
```

### اختبر:
```bash
php artisan tinker

# ادخل:
$service = app(\App\Services\AdvancedAIContentService::class);
$result = $service->generateText('اختبر هذا', ['provider' => 'claude']);
echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
```

---

## 🔗 الروابط المهمة

| الخدمة | الرابط | المفتاح |
|--------|--------|--------|
| **OpenAI** | https://platform.openai.com | API Keys |
| **Claude** | https://console.anthropic.com | API Keys |
| **Gemini** | https://ai.google.dev | Get API Key |
| **Kie AI** | https://kie.ai | API Settings |
| **Replicate** | https://replicate.com | API Tokens |

---

## 📞 الدعم والمساعدة

**للأسئلة والمشاكل:**
1. تحقق من المفاتيح في `.env`
2. تأكد من أنك موصول بالإنترنت
3. راجع السجلات: `storage/logs/laravel.log`
4. جرب مزود آخر إذا فشل واحد

**رسالة خطأ شائعة:**
```
"Gemini API error: Invalid API key"
↓
الحل: تحقق من المفتاح في console.anthropic.com
```

---

**🎉 الآن أنت جاهز لاستخدام الذكاء الاصطناعي في تطبيقك!**