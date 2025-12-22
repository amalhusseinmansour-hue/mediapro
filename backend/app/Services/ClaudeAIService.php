<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;
use Exception;

/**
 * Claude AI Service - خدمة Claude AI الشاملة
 *
 * تدعم جميع احتياجات توليد المحتوى:
 * - توليد منشورات لكل المنصات
 * - توليد الهاشتاقات
 * - تحسين المحتوى
 * - توليد أفكار المحتوى
 * - توليد سكريبت الفيديو
 * - تحليل المحتوى
 */
class ClaudeAIService
{
    protected string $apiKey;
    protected string $baseUrl = 'https://api.anthropic.com/v1';
    protected string $defaultModel = 'claude-3-5-sonnet-20241022';

    // Platform specific prompts
    protected array $platformPrompts;

    public function __construct()
    {
        $this->apiKey = env('CLAUDE_API_KEY', '');
        $this->initializePlatformPrompts();
    }

    /**
     * Initialize platform-specific master prompts
     */
    protected function initializePlatformPrompts(): void
    {
        $this->platformPrompts = [
            'instagram' => [
                'post' => $this->getInstagramPostPrompt(),
                'story' => $this->getInstagramStoryPrompt(),
                'reel' => $this->getInstagramReelPrompt(),
                'carousel' => $this->getInstagramCarouselPrompt(),
            ],
            'facebook' => [
                'post' => $this->getFacebookPostPrompt(),
                'story' => $this->getFacebookStoryPrompt(),
                'video' => $this->getFacebookVideoPrompt(),
            ],
            'twitter' => [
                'tweet' => $this->getTwitterTweetPrompt(),
                'thread' => $this->getTwitterThreadPrompt(),
            ],
            'tiktok' => [
                'video' => $this->getTikTokVideoPrompt(),
                'caption' => $this->getTikTokCaptionPrompt(),
            ],
            'linkedin' => [
                'post' => $this->getLinkedInPostPrompt(),
                'article' => $this->getLinkedInArticlePrompt(),
            ],
            'youtube' => [
                'title' => $this->getYouTubeTitlePrompt(),
                'description' => $this->getYouTubeDescriptionPrompt(),
                'script' => $this->getYouTubeScriptPrompt(),
            ],
            'snapchat' => [
                'story' => $this->getSnapchatStoryPrompt(),
            ],
        ];
    }

    /**
     * Check if service is configured
     */
    public function isConfigured(): bool
    {
        return !empty($this->apiKey);
    }

    /**
     * Main method to call Claude API
     */
    protected function callClaude(
        string $userPrompt,
        string $systemPrompt = '',
        float $temperature = 0.7,
        int $maxTokens = 4000
    ): array {
        if (!$this->isConfigured()) {
            throw new Exception('Claude API key not configured');
        }

        $cacheKey = 'claude_' . md5($userPrompt . $systemPrompt . $temperature);

        // Check cache first
        if (Cache::has($cacheKey)) {
            Log::info('Claude: Using cached response');
            return Cache::get($cacheKey);
        }

        try {
            $response = Http::withHeaders([
                'x-api-key' => $this->apiKey,
                'anthropic-version' => '2023-06-01',
                'content-type' => 'application/json',
            ])->timeout(120)->post("{$this->baseUrl}/messages", [
                'model' => $this->defaultModel,
                'max_tokens' => $maxTokens,
                'temperature' => $temperature,
                'system' => $systemPrompt ?: $this->getMasterSystemPrompt(),
                'messages' => [
                    ['role' => 'user', 'content' => $userPrompt],
                ],
            ]);

            if ($response->successful()) {
                $data = $response->json();
                $content = $data['content'][0]['text'] ?? '';

                $result = [
                    'success' => true,
                    'content' => $content,
                    'provider' => 'claude',
                    'model' => $this->defaultModel,
                    'usage' => [
                        'input_tokens' => $data['usage']['input_tokens'] ?? 0,
                        'output_tokens' => $data['usage']['output_tokens'] ?? 0,
                    ],
                ];

                // Cache for 1 hour
                Cache::put($cacheKey, $result, 3600);

                Log::info('Claude: Content generated successfully', [
                    'tokens' => $result['usage'],
                ]);

                return $result;
            }

            throw new Exception('Claude API error: ' . $response->body());
        } catch (Exception $e) {
            Log::error('Claude API error', ['error' => $e->getMessage()]);
            throw $e;
        }
    }

    /**
     * Master System Prompt - البرومبت الرئيسي
     */
    protected function getMasterSystemPrompt(): string
    {
        return <<<PROMPT
أنت مساعد ذكاء اصطناعي متخصص في إنشاء محتوى وسائل التواصل الاجتماعي. لديك خبرة واسعة في:

🎯 **تخصصاتك:**
1. كتابة محتوى جذاب ومؤثر لجميع منصات التواصل الاجتماعي
2. فهم خوارزميات كل منصة وتحسين المحتوى لها
3. إنشاء هاشتاقات استراتيجية وفعالة
4. كتابة نصوص فيديو احترافية
5. تحليل الجمهور واقتراح المحتوى المناسب

📝 **قواعد الكتابة:**
- اكتب بأسلوب طبيعي وجذاب، ليس مبالغاً فيه
- استخدم الإيموجي بشكل متوازن ومناسب
- احترم حدود الأحرف لكل منصة
- اكتب محتوى أصلي وغير منسوخ
- راعِ الثقافة والسياق العربي عند الكتابة بالعربية

🌍 **اللغات:**
- تتقن العربية والإنجليزية والفرنسية والإسبانية
- تفهم الفروق الثقافية بين المناطق المختلفة

📊 **تعليمات الإخراج:**
- قدم المحتوى بتنسيق واضح ومنظم
- استخدم JSON عند الطلب
- قدم خيارات متعددة عند الإمكان
PROMPT;
    }

    // ============================================
    // 📱 INSTAGRAM PROMPTS
    // ============================================

    protected function getInstagramPostPrompt(): string
    {
        return <<<PROMPT
أنت خبير في إنشاء محتوى Instagram. المنشور المثالي يجب أن:

📐 **المواصفات:**
- طول الكابشن: 125-2200 حرف (الأمثل: 150-500 حرف)
- الهاشتاقات: 5-30 (الأمثل: 11-15)
- أول جملة جذابة (Hook) - تظهر قبل "المزيد"
- Call-to-action واضح

✨ **البنية المثالية:**
1. Hook جذاب في أول سطر
2. القصة أو المحتوى الرئيسي
3. قيمة مضافة للقارئ
4. Call-to-action
5. الهاشتاقات (مزيج من شائعة ومتخصصة)

🎯 **نصائح الخوارزمية:**
- شجع على التفاعل (سؤال، رأي)
- استخدم line breaks للقراءة السهلة
- ضع الهاشتاقات المهمة في البداية
PROMPT;
    }

    protected function getInstagramStoryPrompt(): string
    {
        return <<<PROMPT
أنت خبير في إنشاء محتوى Instagram Stories. القصة المثالية:

📐 **المواصفات:**
- نص قصير ومباشر (2-3 أسطر)
- مدة المشاهدة: 5-15 ثانية
- Stickers وpolls لزيادة التفاعل

✨ **أنواع القصص:**
1. Behind the scenes
2. Polls & Questions
3. Quick tips
4. User-generated content
5. Product showcase
6. Countdowns
PROMPT;
    }

    protected function getInstagramReelPrompt(): string
    {
        return <<<PROMPT
أنت خبير في إنشاء سكريبتات Instagram Reels. الريل المثالي:

📐 **المواصفات:**
- المدة: 15-90 ثانية (الأمثل: 30-60 ثانية)
- Hook في أول 3 ثواني
- الكابشن: 125 حرف قبل "المزيد"

✨ **بنية السكريبت:**
1. [0-3 ثواني] Hook قوي - "توقف! هل تعرف..."
2. [3-15 ثواني] المشكلة أو السياق
3. [15-45 ثواني] الحل أو المحتوى الرئيسي
4. [45-60 ثواني] CTA + مفاجأة

🎬 **عناصر النجاح:**
- موسيقى ترند
- نص على الشاشة
- انتقالات سريعة
- Loops (النهاية تعود للبداية)
PROMPT;
    }

    protected function getInstagramCarouselPrompt(): string
    {
        return <<<PROMPT
أنت خبير في إنشاء محتوى Instagram Carousel. الكاروسيل المثالي:

📐 **المواصفات:**
- عدد الصور: 2-10 (الأمثل: 7-8)
- أول صورة = Hook جذاب
- آخر صورة = CTA قوي

✨ **بنية المحتوى:**
Slide 1: العنوان الجذاب + Hook بصري
Slide 2-8: المحتوى التعليمي/القصة
Slide 9: ملخص أو Key Takeaways
Slide 10: CTA (Save, Share, Follow)

📝 **نص كل Slide:**
- عنوان رئيسي (2-4 كلمات)
- نص فرعي (1-2 جملة)
- تصميم بسيط وواضح
PROMPT;
    }

    // ============================================
    // 📘 FACEBOOK PROMPTS
    // ============================================

    protected function getFacebookPostPrompt(): string
    {
        return <<<PROMPT
أنت خبير في إنشاء محتوى Facebook. المنشور المثالي:

📐 **المواصفات:**
- طول المنشور: 40-500 حرف (الأمثل: 80-150)
- الهاشتاقات: 1-3 فقط
- الرابط يفضل في التعليق الأول

✨ **أنواع المنشورات الناجحة:**
1. أسئلة تفاعلية
2. قصص شخصية
3. محتوى تعليمي قصير
4. Behind the scenes
5. User-generated content

🎯 **نصائح الخوارزمية:**
- تجنب الروابط الخارجية في المنشور
- شجع على التعليقات الطويلة
- انشر في أوقات الذروة
PROMPT;
    }

    protected function getFacebookStoryPrompt(): string
    {
        return <<<PROMPT
أنت خبير في إنشاء Facebook Stories:

📐 **المواصفات:**
- نص قصير ومؤثر
- مدة العرض: 5-20 ثانية
- استخدم Stickers للتفاعل

✨ **الأنواع الفعالة:**
- Flash sales
- Quick announcements
- Polls
- Behind the scenes
PROMPT;
    }

    protected function getFacebookVideoPrompt(): string
    {
        return <<<PROMPT
أنت خبير في إنشاء سكريبتات Facebook Video:

📐 **المواصفات:**
- المدة المثالية: 1-3 دقائق
- Hook في أول 3 ثواني
- Subtitles ضرورية (85% يشاهدون بدون صوت)

✨ **بنية الفيديو:**
1. Hook (0-3 ثواني)
2. المقدمة (3-15 ثواني)
3. المحتوى الرئيسي
4. CTA (آخر 10 ثواني)
PROMPT;
    }

    // ============================================
    // 🐦 TWITTER/X PROMPTS
    // ============================================

    protected function getTwitterTweetPrompt(): string
    {
        return <<<PROMPT
أنت خبير في كتابة Twitter/X. التغريدة المثالية:

📐 **المواصفات:**
- الحد: 280 حرف
- الطول المثالي: 100-150 حرف
- الهاشتاقات: 1-2 فقط

✨ **أنواع التغريدات الناجحة:**
1. Hot takes / آراء جريئة
2. Quick tips
3. One-liners
4. Questions
5. Quotes with commentary

🎯 **نصائح:**
- ابدأ بقوة
- كن مباشراً
- استخدم الأرقام
- تجنب الروابط في التغريدة الرئيسية
PROMPT;
    }

    protected function getTwitterThreadPrompt(): string
    {
        return <<<PROMPT
أنت خبير في كتابة Twitter Threads:

📐 **المواصفات:**
- طول Thread: 5-15 تغريدة
- كل تغريدة: حد 280 حرف
- الأولى = Hook قوي

✨ **بنية Thread:**
Tweet 1: Hook + وعد بالقيمة
Tweet 2-X: المحتوى (نقطة واحدة لكل تغريدة)
Tweet الأخير: CTA + طلب Retweet

📝 **التنسيق:**
- رقم كل تغريدة (1/, 2/...)
- فراغات للقراءة
- Emojis للتنظيم
PROMPT;
    }

    // ============================================
    // 🎵 TIKTOK PROMPTS
    // ============================================

    protected function getTikTokVideoPrompt(): string
    {
        return <<<PROMPT
أنت خبير في إنشاء سكريبتات TikTok:

📐 **المواصفات:**
- المدة: 15-60 ثانية (الأمثل: 21-34 ثانية)
- Hook في أول 1-3 ثواني
- Pattern interrupts كل 2-3 ثواني

✨ **بنية السكريبت:**
[0-1s] HOOK - "POV: أنت..."
[1-3s] Setup - تحديد السياق
[3-20s] المحتوى - معلومات سريعة
[20-30s] Payoff - النتيجة/المفاجأة
[30s] CTA - "Follow for more"

🎬 **عناصر النجاح:**
- Text on screen
- Trending sounds
- Fast cuts
- Relatable content
- Satisfying endings
PROMPT;
    }

    protected function getTikTokCaptionPrompt(): string
    {
        return <<<PROMPT
أنت خبير في كتابة TikTok Captions:

📐 **المواصفات:**
- الحد: 2200 حرف
- الأمثل: 100-150 حرف
- الهاشتاقات: 3-5

✨ **البنية:**
- Hook قصير
- CTA مباشر
- هاشتاقات ترند + متخصصة

🎯 **أمثلة فعالة:**
- "Wait for it..."
- "This changed everything"
- "POV: ..."
- "Reply to @..."
PROMPT;
    }

    // ============================================
    // 💼 LINKEDIN PROMPTS
    // ============================================

    protected function getLinkedInPostPrompt(): string
    {
        return <<<PROMPT
أنت خبير في كتابة LinkedIn Posts:

📐 **المواصفات:**
- الحد: 3000 حرف
- الأمثل: 1200-1500 حرف
- الهاشتاقات: 3-5

✨ **البنية المثالية (Hook Model):**
Line 1-2: Hook قوي
[فراغ]
Line 3-5: القصة/السياق
[فراغ]
Lines 6-15: المحتوى الرئيسي (bullet points)
[فراغ]
Last lines: CTA + سؤال

🎯 **أنواع المحتوى الناجح:**
1. Personal stories + lessons learned
2. Contrarian opinions
3. Step-by-step guides
4. Industry insights
5. Career advice
PROMPT;
    }

    protected function getLinkedInArticlePrompt(): string
    {
        return <<<PROMPT
أنت خبير في كتابة LinkedIn Articles:

📐 **المواصفات:**
- الطول: 800-2000 كلمة
- عنوان جذاب: 40-49 حرف
- صورة غلاف احترافية

✨ **البنية:**
1. مقدمة جذابة (100-150 كلمة)
2. المشكلة/السياق
3. الحل/الخطوات (مع subheadings)
4. أمثلة عملية
5. الخلاصة + CTA

📝 **SEO:**
- Keywords في العنوان
- Subheadings واضحة
- Links داخلية وخارجية
PROMPT;
    }

    // ============================================
    // 🎬 YOUTUBE PROMPTS
    // ============================================

    protected function getYouTubeTitlePrompt(): string
    {
        return <<<PROMPT
أنت خبير في كتابة YouTube Titles:

📐 **المواصفات:**
- الحد: 100 حرف
- الأمثل: 50-60 حرف
- Keywords في البداية

✨ **صيغ ناجحة:**
- "How to [X] in [Time]"
- "[Number] [Things] That [Result]"
- "I Tried [X] for [Time] - Here's What Happened"
- "[X] vs [Y] - Which is Better?"
- "The Truth About [X]"

🎯 **عناصر العنوان القوي:**
- Numbers
- Power words
- Brackets [2024]
- Curiosity gap
PROMPT;
    }

    protected function getYouTubeDescriptionPrompt(): string
    {
        return <<<PROMPT
أنت خبير في كتابة YouTube Descriptions:

📐 **المواصفات:**
- الحد: 5000 حرف
- أول 150 حرف = الأهم (تظهر في البحث)

✨ **البنية المثالية:**
Line 1-2: ملخص الفيديو + Keywords
[فراغ]
Timestamps:
0:00 - Intro
1:30 - [Section 1]
...
[فراغ]
Links:
- [Resource 1]
- [Related video]
[فراغ]
About:
نبذة عن القناة
[فراغ]
#hashtags (3-5)
PROMPT;
    }

    protected function getYouTubeScriptPrompt(): string
    {
        return <<<PROMPT
أنت خبير في كتابة YouTube Scripts:

📐 **المواصفات:**
- 150 كلمة ≈ 1 دقيقة
- Hook في أول 30 ثانية
- Pattern interrupt كل 30-60 ثانية

✨ **بنية السكريبت:**
[0:00-0:30] HOOK
- مشكلة/سؤال مثير
- وعد بالقيمة
- "Stay until the end for..."

[0:30-1:00] INTRO
- تقديم نفسك
- ماذا سيتعلم المشاهد

[1:00-END] CONTENT
- قسم المحتوى لأجزاء
- B-roll suggestions
- Graphics/animations notes

[LAST 30s] OUTRO
- Recap
- CTA (Subscribe, Like, Comment)
- End screen suggestions
PROMPT;
    }

    // ============================================
    // 👻 SNAPCHAT PROMPTS
    // ============================================

    protected function getSnapchatStoryPrompt(): string
    {
        return <<<PROMPT
أنت خبير في إنشاء Snapchat Stories:

📐 **المواصفات:**
- مدة Snap: 1-60 ثانية
- نص قصير ومؤثر
- استخدم Lenses و Filters

✨ **أنواع المحتوى:**
1. Quick tutorials
2. Day in the life
3. Product reveals
4. Flash promotions
5. Behind the scenes

🎯 **نصائح:**
- Vertical video only
- Raw/authentic feel
- Urgency (24hr expiry)
PROMPT;
    }

    // ============================================
    // 🎯 MAIN GENERATION METHODS
    // ============================================

    /**
     * Generate complete social media content
     */
    public function generateContent(array $options): array
    {
        $platform = $options['platform'] ?? 'instagram';
        $contentType = $options['content_type'] ?? 'post';
        $topic = $options['topic'] ?? '';
        $language = $options['language'] ?? 'ar';
        $tone = $options['tone'] ?? 'professional';
        $includeHashtags = $options['include_hashtags'] ?? true;
        $includeEmojis = $options['include_emojis'] ?? true;
        $targetAudience = $options['target_audience'] ?? 'general';
        $brand = $options['brand'] ?? null;
        $keywords = $options['keywords'] ?? [];
        $variations = $options['variations'] ?? 1;

        // Get platform-specific prompt
        $platformPrompt = $this->platformPrompts[$platform][$contentType] ?? $this->platformPrompts[$platform]['post'] ?? '';

        // Build the user prompt
        $userPrompt = $this->buildContentPrompt([
            'topic' => $topic,
            'platform' => $platform,
            'content_type' => $contentType,
            'language' => $language,
            'tone' => $tone,
            'include_hashtags' => $includeHashtags,
            'include_emojis' => $includeEmojis,
            'target_audience' => $targetAudience,
            'brand' => $brand,
            'keywords' => $keywords,
            'variations' => $variations,
        ]);

        // System prompt combines master + platform specific
        $systemPrompt = $this->getMasterSystemPrompt() . "\n\n" . $platformPrompt;

        return $this->callClaude($userPrompt, $systemPrompt, 0.8, 4000);
    }

    /**
     * Build content generation prompt
     */
    protected function buildContentPrompt(array $options): string
    {
        $languageNames = [
            'ar' => 'العربية',
            'en' => 'English',
            'fr' => 'Français',
            'es' => 'Español',
        ];

        $toneDescriptions = [
            'professional' => 'احترافي ورسمي',
            'casual' => 'غير رسمي وودود',
            'funny' => 'فكاهي ومرح',
            'inspiring' => 'ملهم ومحفز',
            'educational' => 'تعليمي ومفيد',
            'urgent' => 'عاجل ومثير',
            'friendly' => 'ودود وقريب',
            'formal' => 'رسمي جداً',
        ];

        $prompt = "اكتب محتوى لـ {$options['platform']} عن الموضوع التالي:\n\n";
        $prompt .= "📌 **الموضوع:** {$options['topic']}\n";
        $prompt .= "📱 **المنصة:** {$options['platform']}\n";
        $prompt .= "📝 **نوع المحتوى:** {$options['content_type']}\n";
        $prompt .= "🌍 **اللغة:** " . ($languageNames[$options['language']] ?? $options['language']) . "\n";
        $prompt .= "🎭 **النبرة:** " . ($toneDescriptions[$options['tone']] ?? $options['tone']) . "\n";
        $prompt .= "👥 **الجمهور المستهدف:** {$options['target_audience']}\n";

        if ($options['brand']) {
            $prompt .= "🏢 **العلامة التجارية:** {$options['brand']}\n";
        }

        if (!empty($options['keywords'])) {
            $prompt .= "🔑 **الكلمات المفتاحية:** " . implode(', ', $options['keywords']) . "\n";
        }

        $prompt .= "\n**التعليمات:**\n";

        if ($options['include_emojis']) {
            $prompt .= "- استخدم الإيموجي بشكل متوازن\n";
        } else {
            $prompt .= "- لا تستخدم الإيموجي\n";
        }

        if ($options['include_hashtags']) {
            $prompt .= "- أضف هاشتاقات مناسبة ومؤثرة\n";
        } else {
            $prompt .= "- لا تضف هاشتاقات\n";
        }

        if ($options['variations'] > 1) {
            $prompt .= "\n**قدم {$options['variations']} نسخ مختلفة من المحتوى**\n";
        }

        $prompt .= "\n**تنسيق الإخراج:**\n";
        $prompt .= "قدم المحتوى بتنسيق JSON كالتالي:\n";
        $prompt .= "```json\n";
        $prompt .= "{\n";
        $prompt .= '  "content": "المحتوى الرئيسي هنا",' . "\n";
        $prompt .= '  "hashtags": ["hashtag1", "hashtag2"],' . "\n";
        $prompt .= '  "hook": "أول جملة جذابة",' . "\n";
        $prompt .= '  "cta": "Call to action",' . "\n";
        $prompt .= '  "estimated_engagement": "high/medium/low",' . "\n";
        $prompt .= '  "best_posting_time": "الوقت المثالي للنشر"' . "\n";
        $prompt .= "}\n";
        $prompt .= "```";

        return $prompt;
    }

    /**
     * Generate hashtags only
     */
    public function generateHashtags(string $topic, string $platform = 'instagram', int $count = 15, string $language = 'ar'): array
    {
        $prompt = <<<PROMPT
اقترح {$count} هاشتاق لمنصة {$platform} عن الموضوع: "{$topic}"

**التعليمات:**
- مزيج من هاشتاقات شائعة (عالية المنافسة) ومتخصصة (منخفضة المنافسة)
- باللغة: {$language}
- تجنب الهاشتاقات المحظورة أو المشبوهة
- رتبها من الأكثر صلة للأقل

**أعد الهاشتاقات في JSON:**
```json
{
  "high_volume": ["#hashtag1", "#hashtag2"],
  "medium_volume": ["#hashtag3", "#hashtag4"],
  "niche": ["#hashtag5", "#hashtag6"],
  "trending": ["#hashtag7"],
  "all": ["#hashtag1", "#hashtag2", "..."]
}
```
PROMPT;

        return $this->callClaude($prompt, '', 0.6, 1000);
    }

    /**
     * Generate content ideas
     */
    public function generateContentIdeas(array $options): array
    {
        $niche = $options['niche'] ?? 'general';
        $platform = $options['platform'] ?? 'instagram';
        $count = $options['count'] ?? 10;
        $timeframe = $options['timeframe'] ?? 'week';

        $prompt = <<<PROMPT
اقترح {$count} فكرة محتوى لـ {$platform} في مجال: "{$niche}"

**المدة الزمنية:** {$timeframe}

**لكل فكرة قدم:**
1. العنوان/الفكرة
2. نوع المحتوى (post, reel, story, etc.)
3. وصف مختصر
4. سبب نجاحها المتوقع
5. أفضل وقت للنشر

**أعد الأفكار في JSON:**
```json
{
  "ideas": [
    {
      "title": "عنوان الفكرة",
      "content_type": "reel",
      "description": "وصف الفكرة",
      "why_it_works": "سبب النجاح",
      "best_day": "الأحد",
      "best_time": "8:00 PM",
      "difficulty": "easy/medium/hard",
      "estimated_reach": "high/medium/low"
    }
  ]
}
```
PROMPT;

        return $this->callClaude($prompt, '', 0.9, 3000);
    }

    /**
     * Improve existing content
     */
    public function improveContent(string $content, array $options = []): array
    {
        $platform = $options['platform'] ?? 'instagram';
        $improvements = $options['improvements'] ?? ['engagement', 'clarity', 'hashtags'];

        $prompt = <<<PROMPT
حسّن المحتوى التالي لمنصة {$platform}:

**المحتوى الأصلي:**
{$content}

**التحسينات المطلوبة:**
PROMPT;

        foreach ($improvements as $improvement) {
            switch ($improvement) {
                case 'engagement':
                    $prompt .= "\n- زيادة التفاعل (أضف سؤال، CTA قوي)";
                    break;
                case 'clarity':
                    $prompt .= "\n- تحسين الوضوح والقراءة";
                    break;
                case 'hashtags':
                    $prompt .= "\n- تحسين الهاشتاقات";
                    break;
                case 'hook':
                    $prompt .= "\n- تقوية الـ Hook (أول جملة)";
                    break;
                case 'length':
                    $prompt .= "\n- تعديل الطول ليناسب المنصة";
                    break;
            }
        }

        $prompt .= <<<PROMPT


**أعد المحتوى المحسن في JSON:**
```json
{
  "improved_content": "المحتوى المحسن",
  "changes_made": ["التغيير 1", "التغيير 2"],
  "improvement_score": "نسبة التحسين المتوقعة",
  "tips": ["نصيحة 1", "نصيحة 2"]
}
```
PROMPT;

        return $this->callClaude($prompt, '', 0.7, 2000);
    }

    /**
     * Generate video script
     */
    public function generateVideoScript(array $options): array
    {
        $topic = $options['topic'] ?? '';
        $platform = $options['platform'] ?? 'tiktok';
        $duration = $options['duration'] ?? 60;
        $style = $options['style'] ?? 'educational';
        $language = $options['language'] ?? 'ar';

        $prompt = <<<PROMPT
اكتب سكريبت فيديو لـ {$platform} عن: "{$topic}"

**المواصفات:**
- المدة: {$duration} ثانية
- الأسلوب: {$style}
- اللغة: {$language}

**أعد السكريبت في JSON:**
```json
{
  "script": {
    "hook": {
      "time": "0-3s",
      "text": "نص الـ Hook",
      "visual": "وصف المشهد"
    },
    "intro": {
      "time": "3-10s",
      "text": "نص المقدمة",
      "visual": "وصف المشهد"
    },
    "main_content": [
      {
        "time": "10-30s",
        "text": "النص",
        "visual": "وصف المشهد",
        "b_roll": "اقتراح B-roll"
      }
    ],
    "cta": {
      "time": "last 5s",
      "text": "نص الـ CTA",
      "visual": "وصف المشهد"
    }
  },
  "caption": "الكابشن المقترح",
  "hashtags": ["#hashtag1"],
  "music_suggestion": "نوع الموسيقى المقترحة",
  "tips": ["نصيحة للتصوير"]
}
```
PROMPT;

        return $this->callClaude($prompt, '', 0.8, 3000);
    }

    /**
     * Analyze content performance prediction
     */
    public function analyzeContent(string $content, string $platform = 'instagram'): array
    {
        $prompt = <<<PROMPT
حلل المحتوى التالي وتوقع أداءه على {$platform}:

**المحتوى:**
{$content}

**قدم التحليل في JSON:**
```json
{
  "overall_score": 85,
  "strengths": ["نقطة قوة 1", "نقطة قوة 2"],
  "weaknesses": ["نقطة ضعف 1"],
  "engagement_prediction": {
    "likes": "high/medium/low",
    "comments": "high/medium/low",
    "shares": "high/medium/low",
    "saves": "high/medium/low"
  },
  "hook_effectiveness": 80,
  "hashtag_analysis": {
    "count": 10,
    "quality": "good/average/poor",
    "suggestions": ["#better_hashtag"]
  },
  "improvements": [
    {
      "issue": "المشكلة",
      "suggestion": "الحل",
      "impact": "high/medium/low"
    }
  ],
  "best_posting_time": "8:00 PM",
  "target_audience_match": 75
}
```
PROMPT;

        return $this->callClaude($prompt, '', 0.6, 2000);
    }

    /**
     * Generate content calendar
     */
    public function generateContentCalendar(array $options): array
    {
        $niche = $options['niche'] ?? 'general';
        $platforms = $options['platforms'] ?? ['instagram'];
        $days = $options['days'] ?? 7;
        $postsPerDay = $options['posts_per_day'] ?? 1;

        $platformsStr = implode(', ', $platforms);

        $prompt = <<<PROMPT
أنشئ جدول محتوى لـ {$days} أيام في مجال: "{$niche}"

**المنصات:** {$platformsStr}
**عدد المنشورات يومياً:** {$postsPerDay}

**أعد الجدول في JSON:**
```json
{
  "calendar": [
    {
      "day": 1,
      "date_suggestion": "الأحد",
      "posts": [
        {
          "platform": "instagram",
          "content_type": "reel",
          "topic": "الموضوع",
          "brief": "وصف مختصر للمحتوى",
          "posting_time": "8:00 PM",
          "estimated_reach": "high",
          "hashtags_theme": "educational"
        }
      ]
    }
  ],
  "tips": ["نصيحة عامة"],
  "themes": {
    "monday": "Motivation Monday",
    "tuesday": "Tutorial Tuesday"
  }
}
```
PROMPT;

        return $this->callClaude($prompt, '', 0.9, 4000);
    }

    /**
     * Generate all content at once (comprehensive)
     */
    public function generateComprehensiveContent(array $options): array
    {
        $topic = $options['topic'] ?? '';
        $platforms = $options['platforms'] ?? ['instagram', 'facebook', 'twitter'];
        $language = $options['language'] ?? 'ar';
        $tone = $options['tone'] ?? 'professional';
        $brand = $options['brand'] ?? null;

        $platformsStr = implode(', ', $platforms);

        $prompt = <<<PROMPT
أنشئ محتوى شامل لجميع المنصات التالية عن الموضوع: "{$topic}"

**المنصات:** {$platformsStr}
**اللغة:** {$language}
**النبرة:** {$tone}
PROMPT;

        if ($brand) {
            $prompt .= "\n**العلامة التجارية:** {$brand}";
        }

        $prompt .= <<<PROMPT


**أعد المحتوى في JSON:**
```json
{
  "topic": "{$topic}",
  "content": {
    "instagram": {
      "post": {
        "caption": "الكابشن",
        "hashtags": ["#hashtag"],
        "image_suggestion": "وصف الصورة المقترحة"
      },
      "story": {
        "text": "نص القصة",
        "sticker_suggestion": "نوع الستيكر"
      },
      "reel": {
        "script": "سكريبت مختصر",
        "duration": "30s",
        "music_type": "نوع الموسيقى"
      }
    },
    "facebook": {
      "post": {
        "text": "نص المنشور",
        "cta": "Call to action"
      }
    },
    "twitter": {
      "tweet": "التغريدة",
      "thread": ["تغريدة 1", "تغريدة 2"]
    },
    "linkedin": {
      "post": "منشور LinkedIn"
    },
    "tiktok": {
      "script": "سكريبت TikTok",
      "caption": "الكابشن"
    }
  },
  "image_prompts": {
    "main": "برومبت لتوليد الصورة الرئيسية",
    "story": "برومبت لصورة القصة",
    "variations": ["برومبت 1", "برومبت 2"]
  },
  "video_prompts": {
    "main": "برومبت لتوليد الفيديو",
    "b_roll": ["برومبت B-roll 1"]
  },
  "best_posting_times": {
    "instagram": "8:00 PM",
    "facebook": "1:00 PM",
    "twitter": "12:00 PM"
  }
}
```
PROMPT;

        return $this->callClaude($prompt, '', 0.8, 6000);
    }
}
