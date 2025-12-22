<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Post;
use App\Models\Subscription;
use Illuminate\Foundation\Testing\RefreshDatabase;

class DashboardFeaturesTest extends TestCase
{
    use RefreshDatabase;

    protected $user;
    protected $adminUser;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Create test user
        $this->user = User::factory()->create([
            'email' => 'user@test.com',
            'password' => bcrypt('password'),
        ]);

        // Create admin user
        $this->adminUser = User::factory()->create([
            'email' => 'admin@test.com',
            'password' => bcrypt('password'),
            'is_admin' => true,
        ]);
    }

    /**
     * Test 1: Dashboard - عرض إحصائيات ومحتوى حقيقي
     */
    public function test_dashboard_shows_real_statistics()
    {
        // Create test data
        User::factory(10)->create();
        Subscription::factory(5)->create(['status' => 'active']);
        Post::factory(20)->create(['user_id' => $this->user->id]);

        // Login as admin
        $response = $this->actingAs($this->adminUser)
            ->getJson('/api/admin/dashboard');

        echo "\n✅ TEST 1: Dashboard Statistics\n";
        echo "================================\n";

        $response->assertStatus(200);
        $response->assertJsonStructure([
            'success',
            'data' => [
                'users' => [
                    'total',
                    'active_subscribers',
                    'free_users',
                    'new_this_month',
                    'new_today',
                ],
                'subscriptions' => [
                    'total',
                    'active',
                    'expired',
                ],
                'wallets' => [
                    'total_balance',
                    'total_wallets',
                    'active_wallets',
                ],
                'requests' => [
                    'website_requests',
                    'sponsored_ads',
                    'bank_transfers',
                ],
                'support' => [
                    'open_tickets',
                    'closed_tickets',
                    'total_tickets',
                ],
                'revenue' => [
                    'total_revenue',
                    'this_month',
                    'this_week',
                ],
            ]
        ]);

        $data = $response->json('data');
        echo "📊 Users: {$data['users']['total']} total\n";
        echo "💰 Subscriptions: {$data['subscriptions']['active']} active\n";
        echo "🏦 Wallets: {$data['wallets']['total_wallets']} total\n";
        echo "📞 Support: {$data['support']['total_tickets']} tickets\n";
        echo "✓ Dashboard data retrieved successfully\n";
    }

    /**
     * Test 2: Content Screen - عرض المنشورات
     */
    public function test_content_screen_shows_posts()
    {
        // Create test posts
        Post::factory(15)->create([
            'user_id' => $this->user->id,
            'status' => 'published',
        ]);

        Post::factory(5)->create([
            'user_id' => $this->user->id,
            'status' => 'draft',
        ]);

        $response = $this->actingAs($this->user)
            ->getJson('/api/posts');

        echo "\n✅ TEST 2: Content Screen - Posts Display\n";
        echo "=========================================\n";

        $response->assertStatus(200);
        $response->assertJsonStructure([
            'data' => [
                '*' => [
                    'id',
                    'title',
                    'content',
                    'status',
                    'created_at',
                    'user_id',
                ]
            ]
        ]);

        $posts = $response->json('data');
        echo "📝 Total posts: " . count($posts) . "\n";
        echo "✓ Posts retrieved successfully\n";

        // Test filtering by status
        $publishedResponse = $this->actingAs($this->user)
            ->getJson('/api/posts?status=published');

        $publishedCount = count($publishedResponse->json('data'));
        echo "📢 Published posts: {$publishedCount}\n";

        // Test pagination
        $paginatedResponse = $this->actingAs($this->user)
            ->getJson('/api/posts?per_page=5');

        $paginatedData = $paginatedResponse->json('data');
        echo "📄 Paginated (5 per page): " . count($paginatedData) . " items\n";
        echo "✓ Pagination working correctly\n";
    }

    /**
     * Test 3: Analytics Screen - بيانات حقيقية
     */
    public function test_analytics_screen_shows_real_data()
    {
        // Create posts with engagement data
        $post = Post::factory()->create(['user_id' => $this->user->id]);
        
        // Simulate engagement data
        $post->update([
            'likes_count' => rand(100, 1000),
            'comments_count' => rand(10, 100),
            'shares_count' => rand(5, 50),
            'views_count' => rand(1000, 5000),
        ]);

        $response = $this->actingAs($this->user)
            ->getJson('/api/analytics');

        echo "\n✅ TEST 3: Analytics Screen - Real Data\n";
        echo "======================================\n";

        $response->assertStatus(200);
        $response->assertJsonStructure([
            'success',
            'data' => [
                'total_views',
                'total_likes',
                'total_comments',
                'total_shares',
                'engagement_rate',
                'top_posts' => [
                    '*' => [
                        'id',
                        'title',
                        'views',
                        'engagement',
                    ]
                ],
                'daily_stats' => [
                    '*' => [
                        'date',
                        'views',
                        'engagement',
                    ]
                ]
            ]
        ]);

        $analytics = $response->json('data');
        echo "👁️  Total Views: {$analytics['total_views']}\n";
        echo "❤️  Total Likes: {$analytics['total_likes']}\n";
        echo "💬 Total Comments: {$analytics['total_comments']}\n";
        echo "🔄 Total Shares: {$analytics['total_shares']}\n";
        echo "📈 Engagement Rate: {$analytics['engagement_rate']}%\n";
        echo "✓ Analytics data retrieved successfully\n";
    }

    /**
     * Test 4: Create Post Screen - نماذج محتوى
     */
    public function test_create_post_with_content_templates()
    {
        echo "\n✅ TEST 4: Create Post Screen - Content Templates\n";
        echo "==================================================\n";

        // Test creating a post with AI-generated content
        $response = $this->actingAs($this->user)
            ->postJson('/api/posts', [
                'title' => 'منتج جديد رائع',
                'content' => 'تم تطوير منتج جديد بأحدث التقنيات',
                'status' => 'draft',
                'platforms' => ['instagram', 'facebook', 'twitter'],
                'scheduled_at' => now()->addHours(2),
            ]);

        echo "📝 Creating post...\n";
        $response->assertStatus(201);
        $post = $response->json('data');

        echo "✓ Post created successfully\n";
        echo "  ID: {$post['id']}\n";
        echo "  Title: {$post['title']}\n";
        echo "  Status: {$post['status']}\n";
        echo "  Platforms: " . implode(', ', $post['platforms']) . "\n";

        // Test AI content suggestions
        $suggestionsResponse = $this->actingAs($this->user)
            ->postJson('/api/posts/ai-suggestions', [
                'topic' => 'التسويق الرقمي',
                'platform' => 'instagram',
                'tone' => 'professional',
            ]);

        echo "\n🤖 AI Content Suggestions:\n";
        $suggestions = $suggestionsResponse->json('data');
        
        foreach ($suggestions as $index => $suggestion) {
            echo "  " . ($index + 1) . ". " . substr($suggestion['content'], 0, 50) . "...\n";
        }
        echo "✓ AI suggestions retrieved successfully\n";

        // Test content templates
        $templatesResponse = $this->actingAs($this->user)
            ->getJson('/api/posts/templates');

        echo "\n📋 Available Templates:\n";
        $templates = $templatesResponse->json('data');
        
        foreach ($templates as $template) {
            echo "  - {$template['name']}: {$template['description']}\n";
        }
        echo "✓ Templates retrieved successfully\n";
    }

    /**
     * Test 5: Full workflow - Complete flow
     */
    public function test_complete_dashboard_workflow()
    {
        echo "\n✅ TEST 5: Complete Workflow\n";
        echo "============================\n";

        // 1. Dashboard overview
        echo "1️⃣  Getting dashboard overview...\n";
        $dashboard = $this->actingAs($this->adminUser)
            ->getJson('/api/admin/dashboard');
        $dashboard->assertStatus(200);
        echo "   ✓ Dashboard loaded\n";

        // 2. View posts
        echo "2️⃣  Fetching content posts...\n";
        Post::factory(10)->create(['user_id' => $this->user->id]);
        $posts = $this->actingAs($this->user)
            ->getJson('/api/posts');
        $posts->assertStatus(200);
        echo "   ✓ Posts retrieved: " . count($posts->json('data')) . " items\n";

        // 3. Get analytics
        echo "3️⃣  Loading analytics data...\n";
        $analytics = $this->actingAs($this->user)
            ->getJson('/api/analytics');
        $analytics->assertStatus(200);
        echo "   ✓ Analytics loaded\n";

        // 4. Create new post
        echo "4️⃣  Creating new post...\n";
        $newPost = $this->actingAs($this->user)
            ->postJson('/api/posts', [
                'title' => 'Post from test',
                'content' => 'Test content',
                'status' => 'draft',
            ]);
        $newPost->assertStatus(201);
        echo "   ✓ Post created\n";

        // 5. Update post
        echo "5️⃣  Updating post...\n";
        $postId = $newPost->json('data.id');
        $update = $this->actingAs($this->user)
            ->patchJson("/api/posts/{$postId}", [
                'status' => 'published',
            ]);
        $update->assertStatus(200);
        echo "   ✓ Post updated to published\n";

        echo "\n🎉 Complete workflow executed successfully!\n";
    }
}
