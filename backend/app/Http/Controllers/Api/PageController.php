<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Page;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class PageController extends Controller
{
    /**
     * عرض جميع الصفحات المنشورة
     */
    public function index(Request $request): JsonResponse
    {
        $query = Page::published();

        // البحث
        if ($request->has('search')) {
            $query->search($request->search);
        }

        // الصفحات في القائمة فقط
        if ($request->has('menu_only') && $request->menu_only) {
            $query->inMenu();
        }

        $pages = $query->orderBy('menu_order')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($pages);
    }

    /**
     * عرض صفحة واحدة
     */
    public function show(string $slug): JsonResponse
    {
        $page = Page::where('slug', $slug)
            ->published()
            ->firstOrFail();

        return response()->json($page);
    }

    /**
     * الحصول على صفحات القائمة
     */
    public function menu(): JsonResponse
    {
        $pages = Page::published()
            ->inMenu()
            ->select('id', 'title', 'slug', 'menu_order')
            ->get();

        return response()->json($pages);
    }

    /**
     * البحث في الصفحات
     */
    public function search(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'q' => 'required|string|min:2',
        ]);

        $pages = Page::published()
            ->search($validated['q'])
            ->select('id', 'title', 'slug', 'excerpt')
            ->limit(10)
            ->get();

        return response()->json($pages);
    }
}
