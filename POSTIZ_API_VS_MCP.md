# 🔑 الفرق بين Postiz API Key و MCP Token

## ⚠️ مهم جداً!

ما وجدته هو **MCP Token** وليس **API Key**!

---

## 📊 الفرق:

### 1️⃣ MCP Token (ما وجدته):
```
059d262b954bb8956a6a7166639ae222d65866bdd38d8ee96e5cf95cf479136d
```

**الاستخدام:**
- ✅ لـ N8N Integration
- ✅ لـ MCP Server (Model Context Protocol)
- ✅ للدمج مع Claude Desktop أو أدوات AI
- ❌ **لا يعمل** مع REST API العادي

**URL:**
```
https://api.postiz.com/mcp/059d262b954bb8956a6a7166639ae222d65866bdd38d8ee96e5cf95cf479136d
```

---

### 2️⃣ API Key (ما نحتاجه):
```
شكله مختلف تماماً - عادة يبدأ بـ:
- pk_live_...
- sk_live_...
- Bearer_...
```

**الاستخدام:**
- ✅ REST API calls
- ✅ للدمج مع Laravel
- ✅ للدمج مع Flutter
- ✅ لنشر المنشورات برمجياً

**URL:**
```
https://api.postiz.com/public/v1/...
```

---

## 🔍 كيف تحصل على API Key الصحيح؟

### الطريقة 1: من نفس الصفحة

**ارجع لنفس صفحة "واجهة برمجة التطبيقات العامة":**

```
1. في https://platform.postiz.com
2. Settings → API أو Public API
3. ابحث عن قسم مختلف عن MCP
4. ابحث عن "API Key" أو "Bearer Token"
5. قد يكون هناك زر "+ Create API Key"
```

---

### الطريقة 2: من صفحة مختلفة

**جرّب هذه الروابط:**

```
https://platform.postiz.com/settings/api-keys
https://platform.postiz.com/settings/developer
https://platform.postiz.com/api/keys
https://platform.postiz.com/developer/api
```

---

### الطريقة 3: اتصل بـ Support

**في نفس صفحة Dashboard:**

```
1. ابحث عن أيقونة Chat 💬
2. اكتب:
   "Hi, I need the REST API key (not MCP token) for API integration.
   Where can I find it?"
```

---

## 📸 ما تبحث عنه:

### ✅ API Key يبدو هكذا:

```
┌─────────────────────────────────────────┐
│  REST API Keys                          │
│                                         │
│  Use these keys for API integration     │
│                                         │
│  ┌────────────────────────────────┐    │
│  │ + Create New API Key           │    │
│  └────────────────────────────────┘    │
│                                         │
│  Active Keys:                           │
│  ┌────────────────────────────────┐    │
│  │ Production Key                 │    │
│  │ pk_live_1a2b3c4d5e6f7g...      │    │
│  │ [Copy] [Revoke]                │    │
│  └────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

### ❌ MCP Token يبدو هكذا (ما وجدته):

```
┌─────────────────────────────────────────┐
│  MCP Integration                        │
│                                         │
│  Connect Postiz MCP to your client      │
│                                         │
│  Your MCP Token:                        │
│  059d262b954bb8956a6a7166639ae222...    │
│                                         │
│  MCP Server URL:                        │
│  https://api.postiz.com/mcp/...         │
└─────────────────────────────────────────┘
```

---

## 🎯 ماذا تفعل الآن؟

### الخطوة 1: ارجع لـ Postiz Dashboard

```
https://platform.postiz.com/settings
```

### الخطوة 2: ابحث عن قسم مختلف

**ابحث عن أحد هذه:**
- "REST API"
- "API Keys"
- "Developer Keys"
- "Authentication"
- "Bearer Tokens"

**لا تبحث عن:**
- ❌ "MCP"
- ❌ "N8N"
- ❌ "Model Context Protocol"

### الخطوة 3: أنشئ API Key

```
1. اضغط "Create API Key" أو "+ New Key"
2. قد يطلب منك:
   - الاسم: "MediaProSocial"
   - الصلاحيات: "Full Access"
3. اضغط Create
4. انسخ الـ key (يبدأ بـ pk_live_ أو sk_live_)
```

---

## 📞 إذا لم تجده - اتصل بـ Support

### البريد الإلكتروني:
```
To: support@postiz.com
Subject: Need REST API Key for Integration

Hi Postiz Team,

I have the Ultimate plan and I'm trying to integrate with your REST API.

I found the MCP token, but I need the REST API key (Bearer token)
for making HTTP requests to https://api.postiz.com/public/v1

Where can I find or generate the REST API key?

Thank you!
```

### Live Chat:
```
في Dashboard → 💬 Chat icon
"I need the REST API key (not MCP token) for API integration"
```

---

## 🔬 كيف تتحقق أن API Key صحيح؟

### اختبار سريع:

```bash
curl -H "Authorization: Bearer YOUR_ACTUAL_API_KEY" \
  https://api.postiz.com/public/v1/integrations
```

**✅ إذا عمل:**
```json
{
  "success": true,
  "data": []
}
```

**❌ إذا لم يعمل:**
```json
{
  "msg": "Invalid API key"
}
```

---

## 💡 نصيحة

**Postiz Ultimate** قد يستخدم نظام authentication مختلف:

### جرّب أيضاً:

1. **Personal Access Token**
2. **OAuth Token**
3. **Service Account Key**

**كل هذه قد تكون في قسم مختلف!**

---

## 📚 الوثائق

**اقرأ الوثائق الرسمية:**

```
https://docs.postiz.com/public-api
https://docs.postiz.com/authentication
```

**ابحث عن:**
- "Getting Started with API"
- "Authentication"
- "API Keys"

---

**آخر تحديث:** 2025-01-15
**الحالة:** ⚠️ يحتاج REST API Key (ليس MCP Token)
