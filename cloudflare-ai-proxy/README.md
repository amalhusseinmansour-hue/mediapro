# MediaPro AI Proxy - Cloudflare Worker

بروكسي AI لتطبيق MediaPro Social يعمل على Cloudflare Workers.

## المميزات

- ✅ **مجاني**: 100,000 طلب/يوم
- ✅ **Rate Limiting**: حسب مستوى الاشتراك
- ✅ **Caching**: تقليل التكلفة بالكاش
- ✅ **Multi-Provider**: Gemini (أساسي) → Claude (احتياطي)
- ✅ **أمان**: إخفاء API Keys من التطبيق

## حدود الاشتراكات

| الباقة | يومياً | شهرياً |
|--------|--------|--------|
| Free | 10 | 100 |
| Individual | 50 | 1,500 |
| Business | 200 | 6,000 |
| Enterprise | 1,000 | 30,000 |

## التثبيت

### 1. إنشاء حساب Cloudflare

1. اذهب إلى [dash.cloudflare.com](https://dash.cloudflare.com)
2. أنشئ حساب مجاني
3. فعّل Workers (مجاني)

### 2. تثبيت Wrangler CLI

```bash
npm install -g wrangler
wrangler login
```

### 3. إنشاء KV Namespace

```bash
wrangler kv:namespace create "AI_CACHE"
```

انسخ الـ ID واستبدله في `wrangler.toml`

### 4. إضافة API Keys

```bash
wrangler secret put GEMINI_API_KEY
# أدخل مفتاح Gemini

wrangler secret put CLAUDE_API_KEY
# أدخل مفتاح Claude
```

### 5. النشر

```bash
npm run deploy
```

## الاستخدام

### توليد محتوى

```bash
curl -X POST https://mediapro-ai-proxy.YOUR_SUBDOMAIN.workers.dev/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "اكتب بوست عن التسويق الرقمي",
    "type": "content",
    "platform": "instagram",
    "language": "ar",
    "tone": "professional",
    "userId": "user123",
    "subscriptionTier": "individual"
  }'
```

### التحقق من الاستخدام

```bash
curl "https://mediapro-ai-proxy.YOUR_SUBDOMAIN.workers.dev/api/usage?userId=user123&tier=individual"
```

## التكلفة

| الخدمة | التكلفة |
|--------|---------|
| Cloudflare Workers | **مجاني** (100K/يوم) |
| Gemini 1.5 Flash | **مجاني** (حد معين) |
| Claude Haiku | ~$0.00025/1K tokens |

## الدعم

للمساعدة، تواصل مع فريق الدعم.
