<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\WebsiteRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class WebsiteRequestController extends Controller
{
    /**
     * Display a listing of website requests
     */
    public function index(Request $request)
    {
        $query = WebsiteRequest::query();

        // Filter by status
        if ($request->has('status')) {
            $query->byStatus($request->status);
        }

        // Filter by website type
        if ($request->has('website_type')) {
            $query->where('website_type', $request->website_type);
        }

        // Search
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%")
                  ->orWhere('company_name', 'like', "%{$search}%");
            });
        }

        $requests = $query->latest()->paginate($request->per_page ?? 15);

        return response()->json([
            'success' => true,
            'data' => $requests
        ]);
    }

    /**
     * Store a newly created website request
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|email|max:255',
            'phone' => 'required|string|max:20',
            'company_name' => 'nullable|string|max:255',
            'website_type' => 'required|in:corporate,ecommerce,blog,portfolio,custom',
            'description' => 'required|string',
            'budget' => 'nullable|numeric|min:0',
            'currency' => 'nullable|string|max:3',
            'deadline' => 'nullable|date|after:today',
            'features' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صحيحة',
                'errors' => $validator->errors()
            ], 422);
        }

        $websiteRequest = WebsiteRequest::create($request->all());

        return response()->json([
            'success' => true,
            'message' => 'تم إرسال طلبك بنجاح! سنتواصل معك قريباً.',
            'data' => $websiteRequest
        ], 201);
    }

    /**
     * Display the specified website request
     */
    public function show($id)
    {
        $websiteRequest = WebsiteRequest::findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $websiteRequest
        ]);
    }

    /**
     * Update the specified website request
     */
    public function update(Request $request, $id)
    {
        $websiteRequest = WebsiteRequest::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'status' => 'sometimes|in:pending,reviewing,accepted,rejected,completed',
            'admin_notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صحيحة',
                'errors' => $validator->errors()
            ], 422);
        }

        $websiteRequest->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث الطلب بنجاح',
            'data' => $websiteRequest
        ]);
    }

    /**
     * Remove the specified website request
     */
    public function destroy($id)
    {
        $websiteRequest = WebsiteRequest::findOrFail($id);
        $websiteRequest->delete();

        return response()->json([
            'success' => true,
            'message' => 'تم حذف الطلب بنجاح'
        ]);
    }

    /**
     * Get statistics
     */
    public function statistics()
    {
        return response()->json([
            'success' => true,
            'data' => [
                'total' => WebsiteRequest::count(),
                'pending' => WebsiteRequest::pending()->count(),
                'reviewing' => WebsiteRequest::byStatus('reviewing')->count(),
                'accepted' => WebsiteRequest::byStatus('accepted')->count(),
                'rejected' => WebsiteRequest::byStatus('rejected')->count(),
                'completed' => WebsiteRequest::byStatus('completed')->count(),
            ]
        ]);
    }
}
