<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SupportTicket;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class SupportTicketController extends Controller
{
    /**
     * Display a listing of support tickets
     */
    public function index(Request $request)
    {
        $query = SupportTicket::with(['user', 'assignedAdmin']);

        // Filter by status
        if ($request->has('status')) {
            $query->byStatus($request->status);
        }

        // Filter by priority
        if ($request->has('priority')) {
            $query->byPriority($request->priority);
        }

        // Filter by category
        if ($request->has('category')) {
            $query->where('category', $request->category);
        }

        // Filter by assigned admin
        if ($request->has('assigned_to')) {
            $query->where('assigned_to', $request->assigned_to);
        }

        // Get only unresolved tickets
        if ($request->has('unresolved') && $request->unresolved) {
            $query->unresolved();
        }

        // Search
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%")
                  ->orWhere('subject', 'like', "%{$search}%")
                  ->orWhere('phone', 'like', "%{$search}%")
                  ->orWhere('whatsapp_number', 'like', "%{$search}%");
            });
        }

        $tickets = $query->latest()->paginate($request->per_page ?? 15);

        return response()->json([
            'success' => true,
            'data' => $tickets
        ]);
    }

    /**
     * Store a newly created support ticket
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'nullable|exists:users,id',
            'name' => 'required|string|max:255',
            'email' => 'required|email|max:255',
            'phone' => 'nullable|string|max:20',
            'whatsapp_number' => 'nullable|string|max:20',
            'subject' => 'required|string|max:255',
            'message' => 'required|string',
            'category' => 'required|in:technical,billing,feature,bug,account,other',
            'priority' => 'nullable|in:low,medium,high,urgent',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صحيحة',
                'errors' => $validator->errors()
            ], 422);
        }

        $ticketData = $request->all();

        // Set default priority if not provided
        if (!isset($ticketData['priority'])) {
            $ticketData['priority'] = 'medium';
        }

        $ticket = SupportTicket::create($ticketData);

        return response()->json([
            'success' => true,
            'message' => 'تم إرسال تذكرة الدعم بنجاح! سنتواصل معك قريباً.',
            'data' => $ticket
        ], 201);
    }

    /**
     * Display the specified support ticket
     */
    public function show($id)
    {
        $ticket = SupportTicket::with(['user', 'assignedAdmin'])->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $ticket
        ]);
    }

    /**
     * Update the specified support ticket
     */
    public function update(Request $request, $id)
    {
        $ticket = SupportTicket::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'status' => 'sometimes|in:open,in_progress,resolved,closed',
            'priority' => 'sometimes|in:low,medium,high,urgent',
            'category' => 'sometimes|in:technical,billing,feature,bug,account,other',
            'admin_notes' => 'nullable|string',
            'assigned_to' => 'nullable|exists:users,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات غير صحيحة',
                'errors' => $validator->errors()
            ], 422);
        }

        $updateData = $request->all();

        // Set resolved_at timestamp when status is changed to resolved
        if (isset($updateData['status']) && $updateData['status'] === 'resolved' && $ticket->status !== 'resolved') {
            $updateData['resolved_at'] = now();
        }

        $ticket->update($updateData);

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث التذكرة بنجاح',
            'data' => $ticket->load(['user', 'assignedAdmin'])
        ]);
    }

    /**
     * Remove the specified support ticket
     */
    public function destroy($id)
    {
        $ticket = SupportTicket::findOrFail($id);
        $ticket->delete();

        return response()->json([
            'success' => true,
            'message' => 'تم حذف التذكرة بنجاح'
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
                'total' => SupportTicket::count(),
                'open' => SupportTicket::open()->count(),
                'in_progress' => SupportTicket::byStatus('in_progress')->count(),
                'resolved' => SupportTicket::byStatus('resolved')->count(),
                'closed' => SupportTicket::byStatus('closed')->count(),
                'unresolved' => SupportTicket::unresolved()->count(),
                'by_priority' => [
                    'low' => SupportTicket::byPriority('low')->count(),
                    'medium' => SupportTicket::byPriority('medium')->count(),
                    'high' => SupportTicket::byPriority('high')->count(),
                    'urgent' => SupportTicket::byPriority('urgent')->count(),
                ],
                'by_category' => [
                    'technical' => SupportTicket::where('category', 'technical')->count(),
                    'billing' => SupportTicket::where('category', 'billing')->count(),
                    'feature' => SupportTicket::where('category', 'feature')->count(),
                    'bug' => SupportTicket::where('category', 'bug')->count(),
                    'account' => SupportTicket::where('category', 'account')->count(),
                    'other' => SupportTicket::where('category', 'other')->count(),
                ]
            ]
        ]);
    }
}
