/**
 * MediaPro AI Proxy - Cloudflare Worker
 * يعمل كبروكسي للذكاء الاصطناعي مع Rate Limiting و Caching
 *
 * المزودين: Gemini (أساسي - الأرخص) → Claude (احتياطي)
 */

// حدود الاشتراكات
const SUBSCRIPTION_LIMITS = {
  free: { daily: 10, monthly: 100 },
  individual: { daily: 50, monthly: 1500 },
  business: { daily: 200, monthly: 6000 },
  enterprise: { daily: 1000, monthly: 30000 }
};

// مدة الكاش (ساعة واحدة)
const CACHE_TTL = 3600;

export default {
  async fetch(request, env, ctx) {
    // CORS headers
    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-User-Id, X-Subscription-Tier',
    };

    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    try {
      const url = new URL(request.url);
      const path = url.pathname;

      // Health check
      if (path === '/health') {
        return jsonResponse({ status: 'ok', timestamp: new Date().toISOString() }, corsHeaders);
      }

      // API endpoints
      if (path === '/api/generate') {
        return await handleGenerate(request, env, corsHeaders);
      }

      if (path === '/api/generate-image') {
        return await handleImageGenerate(request, env, corsHeaders);
      }

      if (path === '/api/usage') {
        return await handleUsage(request, env, corsHeaders);
      }

      return jsonResponse({ error: 'Not found' }, corsHeaders, 404);

    } catch (error) {
      console.error('Worker error:', error);
      return jsonResponse({ error: error.message }, corsHeaders, 500);
    }
  }
};

/**
 * معالجة طلبات توليد المحتوى
 */
async function handleGenerate(request, env, corsHeaders) {
  const body = await request.json();
  const { prompt, type, platform, language, tone, userId, subscriptionTier } = body;

  if (!prompt) {
    return jsonResponse({ error: 'Prompt is required' }, corsHeaders, 400);
  }

  // التحقق من Rate Limit
  const rateLimitResult = await checkRateLimit(env, userId || 'anonymous', subscriptionTier || 'free');
  if (!rateLimitResult.allowed) {
    return jsonResponse({
      error: 'Rate limit exceeded',
      message_ar: 'تم تجاوز الحد المسموح. يرجى الترقية أو الانتظار.',
      remaining: rateLimitResult.remaining,
      resetAt: rateLimitResult.resetAt
    }, corsHeaders, 429);
  }

  // التحقق من الكاش
  const cacheKey = generateCacheKey(prompt, type, platform, language);
  const cachedResponse = await getCachedResponse(env, cacheKey);
  if (cachedResponse) {
    return jsonResponse({
      success: true,
      content: cachedResponse,
      cached: true,
      provider: 'cache'
    }, corsHeaders);
  }

  // توليد المحتوى - Gemini أولاً (الأرخص)
  let result = await generateWithGemini(env, prompt, type, platform, language, tone);

  // إذا فشل Gemini، جرب Claude
  if (!result.success && env.CLAUDE_API_KEY) {
    console.log('Gemini failed, trying Claude...');
    result = await generateWithClaude(env, prompt, type, platform, language, tone);
  }

  if (result.success) {
    // حفظ في الكاش
    await setCachedResponse(env, cacheKey, result.content);

    // تحديث الاستخدام
    await incrementUsage(env, userId || 'anonymous');
  }

  return jsonResponse({
    success: result.success,
    content: result.content,
    provider: result.provider,
    cached: false,
    usage: rateLimitResult
  }, corsHeaders, result.success ? 200 : 500);
}

/**
 * توليد المحتوى باستخدام Gemini (الأرخص)
 */
async function generateWithGemini(env, prompt, type, platform, language, tone) {
  try {
    const systemPrompt = buildSystemPrompt(type, platform, language, tone);

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${env.GEMINI_API_KEY}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{
            parts: [{ text: `${systemPrompt}\n\n${prompt}` }]
          }],
          generationConfig: {
            temperature: 0.7,
            maxOutputTokens: 2048,
          }
        })
      }
    );

    if (!response.ok) {
      throw new Error(`Gemini API error: ${response.status}`);
    }

    const data = await response.json();
    const content = data.candidates?.[0]?.content?.parts?.[0]?.text;

    if (!content) {
      throw new Error('Empty response from Gemini');
    }

    return { success: true, content, provider: 'gemini' };

  } catch (error) {
    console.error('Gemini error:', error);
    return { success: false, error: error.message, provider: 'gemini' };
  }
}

/**
 * توليد المحتوى باستخدام Claude (احتياطي)
 */
async function generateWithClaude(env, prompt, type, platform, language, tone) {
  try {
    const systemPrompt = buildSystemPrompt(type, platform, language, tone);

    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': env.CLAUDE_API_KEY,
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model: 'claude-3-haiku-20240307', // الأرخص
        max_tokens: 2048,
        system: systemPrompt,
        messages: [{ role: 'user', content: prompt }]
      })
    });

    if (!response.ok) {
      throw new Error(`Claude API error: ${response.status}`);
    }

    const data = await response.json();
    const content = data.content?.[0]?.text;

    if (!content) {
      throw new Error('Empty response from Claude');
    }

    return { success: true, content, provider: 'claude' };

  } catch (error) {
    console.error('Claude error:', error);
    return { success: false, error: error.message, provider: 'claude' };
  }
}

/**
 * بناء System Prompt حسب النوع والمنصة
 */
function buildSystemPrompt(type, platform, language, tone) {
  const lang = language === 'ar' ? 'Arabic' : 'English';
  const toneMap = {
    professional: 'professional and formal',
    casual: 'casual and friendly',
    funny: 'humorous and entertaining',
    inspiring: 'inspiring and motivational'
  };
  const toneStyle = toneMap[tone] || 'professional';

  const platformLimits = {
    twitter: 280,
    instagram: 2200,
    facebook: 63206,
    linkedin: 3000,
    tiktok: 2200
  };

  let systemPrompt = `You are an expert social media content creator. Write in ${lang} with a ${toneStyle} tone.`;

  if (platform && platformLimits[platform]) {
    systemPrompt += ` The content is for ${platform} (max ${platformLimits[platform]} characters).`;
  }

  if (type === 'hashtags') {
    systemPrompt += ' Generate relevant hashtags only, no other text.';
  } else if (type === 'ideas') {
    systemPrompt += ' Generate creative content ideas as a numbered list.';
  } else if (type === 'improve') {
    systemPrompt += ' Improve the given content while maintaining its core message.';
  }

  return systemPrompt;
}

/**
 * التحقق من Rate Limit
 */
async function checkRateLimit(env, userId, tier) {
  const limits = SUBSCRIPTION_LIMITS[tier] || SUBSCRIPTION_LIMITS.free;
  const today = new Date().toISOString().split('T')[0];
  const key = `usage:${userId}:${today}`;

  try {
    const usage = await env.AI_CACHE.get(key);
    const currentUsage = usage ? parseInt(usage) : 0;

    if (currentUsage >= limits.daily) {
      return {
        allowed: false,
        remaining: 0,
        limit: limits.daily,
        resetAt: getEndOfDay()
      };
    }

    return {
      allowed: true,
      remaining: limits.daily - currentUsage - 1,
      limit: limits.daily,
      used: currentUsage + 1
    };
  } catch (error) {
    // إذا فشل KV، اسمح بالطلب
    console.error('Rate limit check error:', error);
    return { allowed: true, remaining: -1, limit: limits.daily };
  }
}

/**
 * زيادة عداد الاستخدام
 */
async function incrementUsage(env, userId) {
  const today = new Date().toISOString().split('T')[0];
  const key = `usage:${userId}:${today}`;

  try {
    const usage = await env.AI_CACHE.get(key);
    const currentUsage = usage ? parseInt(usage) : 0;
    await env.AI_CACHE.put(key, String(currentUsage + 1), { expirationTtl: 86400 });
  } catch (error) {
    console.error('Increment usage error:', error);
  }
}

/**
 * الحصول على استجابة مخبأة
 */
async function getCachedResponse(env, cacheKey) {
  try {
    return await env.AI_CACHE.get(cacheKey);
  } catch (error) {
    return null;
  }
}

/**
 * حفظ استجابة في الكاش
 */
async function setCachedResponse(env, cacheKey, content) {
  try {
    await env.AI_CACHE.put(cacheKey, content, { expirationTtl: CACHE_TTL });
  } catch (error) {
    console.error('Cache set error:', error);
  }
}

/**
 * توليد مفتاح الكاش
 */
function generateCacheKey(prompt, type, platform, language) {
  const hash = hashString(`${prompt}:${type}:${platform}:${language}`);
  return `cache:${hash}`;
}

/**
 * Simple hash function
 */
function hashString(str) {
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    const char = str.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash;
  }
  return Math.abs(hash).toString(36);
}

/**
 * الحصول على نهاية اليوم
 */
function getEndOfDay() {
  const now = new Date();
  const endOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1);
  return endOfDay.toISOString();
}

/**
 * معالجة طلب الاستخدام
 */
async function handleUsage(request, env, corsHeaders) {
  const url = new URL(request.url);
  const userId = url.searchParams.get('userId') || 'anonymous';
  const tier = url.searchParams.get('tier') || 'free';

  const result = await checkRateLimit(env, userId, tier);

  return jsonResponse({
    userId,
    tier,
    ...result
  }, corsHeaders);
}

/**
 * معالجة توليد الصور
 */
async function handleImageGenerate(request, env, corsHeaders) {
  const body = await request.json();
  const { prompt, userId, subscriptionTier } = body;

  // التحقق من Rate Limit
  const rateLimitResult = await checkRateLimit(env, userId || 'anonymous', subscriptionTier || 'free');
  if (!rateLimitResult.allowed) {
    return jsonResponse({
      error: 'Rate limit exceeded',
      message_ar: 'تم تجاوز الحد المسموح للصور'
    }, corsHeaders, 429);
  }

  // استخدام Gemini لتوليد الصور
  try {
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=${env.GEMINI_API_KEY}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{
            parts: [{ text: `Generate an image: ${prompt}` }]
          }],
          generationConfig: {
            responseModalities: ['image', 'text']
          }
        })
      }
    );

    const data = await response.json();

    // تحديث الاستخدام
    await incrementUsage(env, userId || 'anonymous');

    return jsonResponse({
      success: true,
      data,
      provider: 'gemini'
    }, corsHeaders);

  } catch (error) {
    return jsonResponse({
      success: false,
      error: error.message
    }, corsHeaders, 500);
  }
}

/**
 * إرسال JSON response
 */
function jsonResponse(data, corsHeaders, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json',
      ...corsHeaders
    }
  });
}
