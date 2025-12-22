<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Services\AdvancedAIContentService;

class AIServicesTest extends TestCase
{
    private AdvancedAIContentService $aiService;

    protected function setUp(): void
    {
        parent::setUp();
        $this->aiService = app(AdvancedAIContentService::class);
    }

    /**
     * Test if Claude provider is configured
     */
    public function test_claude_provider_configuration()
    {
        $status = $this->aiService->getProvidersStatus();
        
        $this->assertArrayHasKey('claude', $status);
        
        if (env('CLAUDE_API_KEY')) {
            $this->assertTrue($status['claude']['configured']);
            echo "✅ Claude is configured\n";
        } else {
            echo "⚠️ Claude API key not found\n";
        }
    }

    /**
     * Test if Gemini provider is configured
     */
    public function test_gemini_provider_configuration()
    {
        $status = $this->aiService->getProvidersStatus();
        
        $this->assertArrayHasKey('gemini', $status);
        
        if (env('GEMINI_API_KEY')) {
            $this->assertTrue($status['gemini']['configured']);
            echo "✅ Gemini is configured\n";
        } else {
            echo "⚠️ Gemini API key not found\n";
        }
    }

    /**
     * Test if OpenAI provider is configured
     */
    public function test_openai_provider_configuration()
    {
        $status = $this->aiService->getProvidersStatus();
        
        $this->assertArrayHasKey('openai', $status);
        
        if (env('OPENAI_API_KEY')) {
            $this->assertTrue($status['openai']['configured']);
            echo "✅ OpenAI is configured\n";
        } else {
            echo "⚠️ OpenAI API key not found\n";
        }
    }

    /**
     * Test get configured providers
     */
    public function test_get_configured_providers()
    {
        $providers = $this->aiService->getConfiguredProviders();
        
        $this->assertIsArray($providers);
        echo "Configured providers: " . implode(', ', $providers) . "\n";
    }

    /**
     * Test text generation with Gemini (usually free)
     */
    public function test_text_generation_with_gemini()
    {
        if (!env('GEMINI_API_KEY')) {
            $this->markTestSkipped('GEMINI_API_KEY not configured');
        }

        $result = $this->aiService->generateText(
            'اكتب جملة تسويقية قصيرة عن منتج جديد',
            ['provider' => 'gemini']
        );

        $this->assertTrue($result['success']);
        $this->assertArrayHasKey('content', $result);
        $this->assertNotEmpty($result['content']);
        echo "✅ Gemini text generation successful\n";
        echo "Content: " . $result['content'] . "\n";
    }

    /**
     * Test social media content generation
     */
    public function test_social_media_content_generation()
    {
        if (!env('GEMINI_API_KEY') && !env('OPENAI_API_KEY') && !env('CLAUDE_API_KEY')) {
            $this->markTestSkipped('No AI provider configured');
        }

        $result = $this->aiService->generateSocialMediaContent([
            'topic' => 'منتج جديد رائع',
            'platform' => 'instagram',
            'language' => 'ar',
        ]);

        if ($result['success']) {
            echo "✅ Social media content generated\n";
            echo "Content: " . substr($result['content'], 0, 100) . "...\n";
        } else {
            echo "⚠️ Content generation failed: " . ($result['error'] ?? 'Unknown error') . "\n";
        }
    }

    /**
     * Test all configured providers
     */
    public function test_all_providers_status()
    {
        $status = $this->aiService->getProvidersStatus();
        
        echo "\n📊 AI Providers Status:\n";
        echo "========================\n";
        
        foreach ($status as $provider => $info) {
            $configured = $info['configured'] ? '✅' : '❌';
            $key = $info['key_preview'];
            echo "{$configured} {$provider}: {$key}\n";
        }
    }
}
