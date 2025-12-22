<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class ApifyService
{
    protected $apiToken;
    protected $baseUrl = 'https://api.apify.com/v2';

    public function __construct()
    {
        $this->apiToken = env('APIFY_API_TOKEN');
    }

    /**
     * Scrape Instagram posts by hashtag
     */
    public function scrapeInstagramHashtag($hashtag, $maxPosts = 20, $contentType = 'posts')
    {
        try {
            $actorId = 'apify/instagram-hashtag-scraper';

            $input = [
                'hashtags' => [$hashtag],
                'resultsLimit' => $maxPosts,
                'searchType' => $contentType === 'reels' ? 'reels' : 'posts',
            ];

            Log::info('Starting Instagram hashtag scrape', [
                'hashtag' => $hashtag,
                'maxPosts' => $maxPosts,
                'contentType' => $contentType
            ]);

            // Run the Actor and wait for results
            $response = Http::withHeaders([
                'Content-Type' => 'application/json',
            ])->post("{$this->baseUrl}/acts/{$actorId}/run-sync-get-dataset-items?token={$this->apiToken}", $input);

            if ($response->successful()) {
                $data = $response->json();
                Log::info('Instagram hashtag scrape completed', [
                    'results_count' => count($data)
                ]);

                return [
                    'success' => true,
                    'data' => $this->formatInstagramData($data),
                    'count' => count($data)
                ];
            }

            Log::error('Instagram hashtag scrape failed', [
                'status' => $response->status(),
                'body' => $response->body()
            ]);

            return [
                'success' => false,
                'error' => 'Failed to scrape Instagram data',
                'details' => $response->body()
            ];

        } catch (\Exception $e) {
            Log::error('Instagram hashtag scrape exception', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Scrape Instagram by keyword
     */
    public function scrapeInstagramByKeyword($keyword, $maxPosts = 20)
    {
        try {
            $actorId = 'apify/instagram-hashtag-scraper';

            $input = [
                'searchKeyword' => $keyword,
                'resultsLimit' => $maxPosts,
            ];

            Log::info('Starting Instagram keyword scrape', [
                'keyword' => $keyword,
                'maxPosts' => $maxPosts
            ]);

            $response = Http::withHeaders([
                'Content-Type' => 'application/json',
            ])->post("{$this->baseUrl}/acts/{$actorId}/run-sync-get-dataset-items?token={$this->apiToken}", $input);

            if ($response->successful()) {
                $data = $response->json();

                return [
                    'success' => true,
                    'data' => $this->formatInstagramData($data),
                    'count' => count($data)
                ];
            }

            return [
                'success' => false,
                'error' => 'Failed to scrape Instagram data'
            ];

        } catch (\Exception $e) {
            Log::error('Instagram keyword scrape exception', [
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Get last run results
     */
    public function getLastRunResults($actorId = 'apify/instagram-hashtag-scraper')
    {
        try {
            $response = Http::get("{$this->baseUrl}/acts/{$actorId}/runs/last/dataset/items?token={$this->apiToken}&status=SUCCEEDED");

            if ($response->successful()) {
                $data = $response->json();

                return [
                    'success' => true,
                    'data' => $this->formatInstagramData($data),
                    'count' => count($data)
                ];
            }

            return [
                'success' => false,
                'error' => 'No results found'
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Format Instagram data for consistent output
     */
    protected function formatInstagramData($data)
    {
        if (!is_array($data)) {
            return [];
        }

        return array_map(function ($item) {
            return [
                'id' => $item['id'] ?? null,
                'shortCode' => $item['shortCode'] ?? null,
                'caption' => $item['caption'] ?? '',
                'hashtags' => $item['hashtags'] ?? [],
                'mentions' => $item['mentions'] ?? [],
                'url' => $item['url'] ?? null,
                'commentsCount' => $item['commentsCount'] ?? 0,
                'likesCount' => $item['likesCount'] ?? 0,
                'timestamp' => $item['timestamp'] ?? null,
                'displayUrl' => $item['displayUrl'] ?? null,
                'images' => $item['images'] ?? [],
                'videoUrl' => $item['videoUrl'] ?? null,
                'videoViewCount' => $item['videoViewCount'] ?? 0,
                'videoPlayCount' => $item['videoPlayCount'] ?? 0,
                'isVideo' => $item['isVideo'] ?? false,
                'type' => $item['type'] ?? 'post',
                'ownerUsername' => $item['ownerUsername'] ?? null,
                'ownerFullName' => $item['ownerFullName'] ?? null,
                'locationName' => $item['locationName'] ?? null,
                'locationId' => $item['locationId'] ?? null,
            ];
        }, $data);
    }

    /**
     * Get trending hashtags analysis
     */
    public function getTrendingHashtags($hashtags = [], $maxPosts = 10)
    {
        $results = [];

        foreach ($hashtags as $hashtag) {
            $scrapeResult = $this->scrapeInstagramHashtag($hashtag, $maxPosts);

            if ($scrapeResult['success']) {
                $posts = $scrapeResult['data'];

                $results[] = [
                    'hashtag' => $hashtag,
                    'total_posts' => count($posts),
                    'total_likes' => array_sum(array_column($posts, 'likesCount')),
                    'total_comments' => array_sum(array_column($posts, 'commentsCount')),
                    'avg_likes' => count($posts) > 0 ? array_sum(array_column($posts, 'likesCount')) / count($posts) : 0,
                    'avg_comments' => count($posts) > 0 ? array_sum(array_column($posts, 'commentsCount')) / count($posts) : 0,
                    'engagement_rate' => $this->calculateEngagementRate($posts),
                    'posts' => $posts,
                ];
            }
        }

        return [
            'success' => true,
            'data' => $results,
            'analyzed_hashtags' => count($results)
        ];
    }

    /**
     * Calculate engagement rate
     */
    protected function calculateEngagementRate($posts)
    {
        if (empty($posts)) {
            return 0;
        }

        $totalEngagement = array_sum(array_column($posts, 'likesCount')) +
                          array_sum(array_column($posts, 'commentsCount'));

        return round($totalEngagement / count($posts), 2);
    }
}
