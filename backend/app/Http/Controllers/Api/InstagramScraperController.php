<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ApifyService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class InstagramScraperController extends Controller
{
    protected $apifyService;

    public function __construct(ApifyService $apifyService)
    {
        $this->apifyService = $apifyService;
    }

    /**
     * Scrape Instagram posts by hashtag
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function scrapeByHashtag(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'hashtag' => 'required|string|max:100',
            'max_posts' => 'nullable|integer|min:1|max:100',
            'content_type' => 'nullable|in:posts,reels'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $hashtag = str_replace('#', '', $request->hashtag);
        $maxPosts = $request->max_posts ?? 20;
        $contentType = $request->content_type ?? 'posts';

        $result = $this->apifyService->scrapeInstagramHashtag($hashtag, $maxPosts, $contentType);

        if ($result['success']) {
            return response()->json([
                'success' => true,
                'message' => 'Instagram posts scraped successfully',
                'data' => $result['data'],
                'count' => $result['count'],
                'hashtag' => '#' . $hashtag,
                'content_type' => $contentType
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'Failed to scrape Instagram data',
            'error' => $result['error'] ?? 'Unknown error'
        ], 500);
    }

    /**
     * Scrape Instagram by keyword
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function scrapeByKeyword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'keyword' => 'required|string|max:100',
            'max_posts' => 'nullable|integer|min:1|max:100'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $keyword = $request->keyword;
        $maxPosts = $request->max_posts ?? 20;

        $result = $this->apifyService->scrapeInstagramByKeyword($keyword, $maxPosts);

        if ($result['success']) {
            return response()->json([
                'success' => true,
                'message' => 'Instagram posts scraped successfully',
                'data' => $result['data'],
                'count' => $result['count'],
                'keyword' => $keyword
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'Failed to scrape Instagram data',
            'error' => $result['error'] ?? 'Unknown error'
        ], 500);
    }

    /**
     * Get trending hashtags analysis
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function analyzeTrendingHashtags(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'hashtags' => 'required|array|min:1|max:10',
            'hashtags.*' => 'required|string|max:100',
            'max_posts_per_hashtag' => 'nullable|integer|min:1|max:50'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $hashtags = array_map(function($tag) {
            return str_replace('#', '', $tag);
        }, $request->hashtags);

        $maxPostsPerHashtag = $request->max_posts_per_hashtag ?? 10;

        $result = $this->apifyService->getTrendingHashtags($hashtags, $maxPostsPerHashtag);

        if ($result['success']) {
            return response()->json([
                'success' => true,
                'message' => 'Hashtags analyzed successfully',
                'data' => $result['data'],
                'analyzed_count' => $result['analyzed_hashtags']
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'Failed to analyze hashtags',
            'error' => 'Analysis failed'
        ], 500);
    }

    /**
     * Get last scraping results
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function getLastResults()
    {
        $result = $this->apifyService->getLastRunResults();

        if ($result['success']) {
            return response()->json([
                'success' => true,
                'message' => 'Last results retrieved successfully',
                'data' => $result['data'],
                'count' => $result['count']
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'No results found',
            'error' => $result['error'] ?? 'No data available'
        ], 404);
    }

    /**
     * Get hashtag suggestions based on content
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function suggestHashtags(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'content' => 'required|string|min:10',
            'limit' => 'nullable|integer|min:5|max:30'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $content = $request->content;
        $limit = $request->limit ?? 15;

        // Extract keywords from content
        $words = str_word_count(strtolower($content), 1);
        $commonWords = ['the', 'is', 'at', 'which', 'on', 'a', 'an', 'and', 'or', 'but', 'in', 'with', 'to', 'for'];
        $keywords = array_diff($words, $commonWords);
        $keywords = array_unique($keywords);
        $keywords = array_slice($keywords, 0, 5);

        // Generate hashtag suggestions
        $suggestions = [];
        foreach ($keywords as $keyword) {
            $suggestions[] = '#' . $keyword;
            $suggestions[] = '#' . ucfirst($keyword);
        }

        // Add popular general hashtags
        $popularHashtags = [
            '#instagood', '#photooftheday', '#beautiful', '#happy', '#love',
            '#fashion', '#style', '#inspiration', '#motivation', '#success'
        ];

        $suggestions = array_merge($suggestions, $popularHashtags);
        $suggestions = array_unique($suggestions);
        $suggestions = array_slice($suggestions, 0, $limit);

        return response()->json([
            'success' => true,
            'message' => 'Hashtag suggestions generated',
            'suggestions' => $suggestions,
            'count' => count($suggestions)
        ]);
    }
}
