<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\AutoScheduledPost;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class ProcessAutoScheduledPosts extends Command
{
    /**
     * The name and signature of the console command.
     */
    protected $signature = 'auto-posts:process';

    /**
     * The console command description.
     */
    protected $description = 'Process auto scheduled posts and publish them';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Starting auto scheduled posts processing...');

        // Get all posts that are due for posting
        $posts = AutoScheduledPost::dueForPosting()->get();

        if ($posts->isEmpty()) {
            $this->info('No posts due for posting.');
            return 0;
        }

        $this->info("Found {$posts->count()} post(s) to process.");

        foreach ($posts as $post) {
            try {
                $this->info("Processing post ID: {$post->id}");

                // Post to each platform
                $results = [];
                foreach ($post->platforms as $platform) {
                    try {
                        $result = $this->postToPlatform($post, $platform);
                        $results[$platform] = $result;
                        $this->info("Posted to {$platform}: " . ($result['success'] ? 'Success' : 'Failed'));
                    } catch (\Exception $e) {
                        $results[$platform] = [
                            'success' => false,
                            'error' => $e->getMessage(),
                        ];
                        $this->error("Failed to post to {$platform}: {$e->getMessage()}");
                    }
                }

                // Mark as posted
                $post->markAsPosted();

                // Update metadata with results
                $metadata = $post->metadata ?? [];
                $metadata['last_post_results'] = $results;
                $metadata['last_post_timestamp'] = now()->toIso8601String();
                $post->metadata = $metadata;
                $post->save();

                $this->info("Successfully processed post ID: {$post->id}");

                // Log the activity
                Log::info("Auto posted", [
                    'post_id' => $post->id,
                    'user_id' => $post->user_id,
                    'platforms' => $post->platforms,
                    'results' => $results,
                ]);
            } catch (\Exception $e) {
                $this->error("Error processing post ID {$post->id}: {$e->getMessage()}");

                Log::error("Auto post failed", [
                    'post_id' => $post->id,
                    'error' => $e->getMessage(),
                    'trace' => $e->getTraceAsString(),
                ]);

                // Mark as failed
                $post->status = AutoScheduledPost::STATUS_FAILED;
                $metadata = $post->metadata ?? [];
                $metadata['last_error'] = $e->getMessage();
                $metadata['last_error_timestamp'] = now()->toIso8601String();
                $post->metadata = $metadata;
                $post->save();
            }
        }

        $this->info('Auto scheduled posts processing completed.');
        return 0;
    }

    /**
     * Post to a specific platform
     */
    private function postToPlatform(AutoScheduledPost $post, string $platform): array
    {
        // This is where you integrate with your posting service
        // For now, we'll simulate the posting

        try {
            // Example: Using upload-post.com API or your own posting service
            // You can integrate with your MultiPlatformPostService here

            // Simulated posting
            // In production, replace this with actual API calls
            $response = [
                'success' => true,
                'platform' => $platform,
                'post_id' => 'simulated_' . uniqid(),
                'timestamp' => now()->toIso8601String(),
            ];

            // Example of actual implementation:
            /*
            $response = Http::post('https://api.upload-post.com/v1/publish', [
                'platform' => $platform,
                'content' => $post->content,
                'media_urls' => $post->media_urls,
                'access_token' => 'your_access_token',
            ]);

            return [
                'success' => $response->successful(),
                'platform' => $platform,
                'post_id' => $response->json('post_id'),
                'response' => $response->json(),
            ];
            */

            return $response;
        } catch (\Exception $e) {
            throw new \Exception("Failed to post to {$platform}: {$e->getMessage()}");
        }
    }
}
