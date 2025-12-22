<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\N8nWorkflow;
use App\Models\N8nWorkflowExecution;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;

class N8nWorkflowController extends Controller
{
    /**
     * Get all active workflows
     */
    public function index(): JsonResponse
    {
        try {
            $workflows = N8nWorkflow::where('is_active', true)
                ->select([
                    'id',
                    'workflow_id',
                    'name',
                    'description',
                    'platform',
                    'type',
                    'input_schema',
                    'execution_count',
                    'last_executed_at'
                ])
                ->get();

            return response()->json([
                'success' => true,
                'data' => $workflows
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل في جلب الـ Workflows',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get workflow by platform
     */
    public function getByPlatform(string $platform): JsonResponse
    {
        try {
            $workflow = N8nWorkflow::getByPlatform($platform);

            if (!$workflow) {
                return response()->json([
                    'success' => false,
                    'message' => "لا يوجد Workflow نشط لمنصة {$platform}"
                ], 404);
            }

            return response()->json([
                'success' => true,
                'data' => $workflow
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل في جلب الـ Workflow',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Execute a workflow (Post to social media)
     */
    public function execute(Request $request): JsonResponse
    {
        try {
            // Validate request
            $validator = Validator::make($request->all(), [
                'workflow_id' => 'required|string|exists:n8n_workflows,workflow_id',
                'fileID' => 'required|string',
                'text' => 'required|string|min:1',
                'n8n_url' => 'nullable|url'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'بيانات غير صحيحة',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Get workflow
            $workflow = N8nWorkflow::where('workflow_id', $request->workflow_id)->first();

            if (!$workflow->is_active) {
                return response()->json([
                    'success' => false,
                    'message' => 'هذا الـ Workflow غير نشط'
                ], 400);
            }

            // Create execution record
            $execution = N8nWorkflowExecution::create([
                'user_id' => auth()->id(),
                'workflow_id' => $workflow->workflow_id,
                'platform' => $workflow->platform,
                'status' => 'pending',
                'input_data' => [
                    'fileID' => $request->fileID,
                    'text' => $request->text
                ]
            ]);

            // Mark as started
            $execution->markAsStarted();

            // Execute workflow via N8N API
            $n8nUrl = $request->n8n_url ?? $workflow->n8n_url ?? env('N8N_URL');

            if (!$n8nUrl) {
                $execution->markAsFailed('N8N URL not configured');
                return response()->json([
                    'success' => false,
                    'message' => 'N8N URL غير مكون. يرجى إضافته في الإعدادات'
                ], 500);
            }

            try {
                // Execute N8N workflow
                $response = Http::timeout(60)
                    ->withHeaders([
                        'Content-Type' => 'application/json',
                    ])
                    ->post("{$n8nUrl}/webhook/{$workflow->workflow_id}", [
                        'fileID' => $request->fileID,
                        'text' => $request->text
                    ]);

                if ($response->successful()) {
                    $responseData = $response->json();

                    // Extract post URL if available
                    $postUrl = $responseData['post_url'] ?? $responseData['url'] ?? null;

                    // Mark as successful
                    $execution->markAsSuccess($responseData, $postUrl);

                    // Increment workflow execution count
                    $workflow->incrementExecutionCount();

                    return response()->json([
                        'success' => true,
                        'message' => 'تم النشر بنجاح على ' . ucfirst($workflow->platform),
                        'data' => [
                            'execution_id' => $execution->id,
                            'platform' => $workflow->platform,
                            'post_url' => $postUrl,
                            'response' => $responseData
                        ]
                    ]);
                } else {
                    $errorMessage = $response->body();
                    $execution->markAsFailed($errorMessage, [
                        'status_code' => $response->status(),
                        'response' => $response->json()
                    ]);

                    return response()->json([
                        'success' => false,
                        'message' => 'فشل في تنفيذ الـ Workflow',
                        'error' => $errorMessage
                    ], $response->status());
                }
            } catch (\Exception $e) {
                $execution->markAsFailed($e->getMessage(), [
                    'exception' => get_class($e)
                ]);

                Log::error('N8N Workflow Execution Failed', [
                    'workflow_id' => $workflow->workflow_id,
                    'execution_id' => $execution->id,
                    'error' => $e->getMessage()
                ]);

                return response()->json([
                    'success' => false,
                    'message' => 'فشل في الاتصال بـ N8N',
                    'error' => $e->getMessage()
                ], 500);
            }
        } catch (\Exception $e) {
            Log::error('N8N Workflow Controller Error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ غير متوقع',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Post to platform (Simplified endpoint)
     */
    public function postToPlatform(Request $request): JsonResponse
    {
        try {
            // Validate request
            $validator = Validator::make($request->all(), [
                'platform' => 'required|string|in:instagram,tiktok,youtube,facebook,twitter',
                'fileID' => 'required|string',
                'text' => 'required|string|min:1',
                'n8n_url' => 'nullable|url'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'بيانات غير صحيحة',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Get workflow by platform
            $workflow = N8nWorkflow::getByPlatform($request->platform);

            if (!$workflow) {
                return response()->json([
                    'success' => false,
                    'message' => "لا يوجد Workflow نشط لمنصة {$request->platform}"
                ], 404);
            }

            // Execute workflow
            $request->merge(['workflow_id' => $workflow->workflow_id]);
            return $this->execute($request);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ غير متوقع',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get execution history
     */
    public function executionHistory(Request $request): JsonResponse
    {
        try {
            $query = N8nWorkflowExecution::with('workflow:workflow_id,name,platform')
                ->orderBy('created_at', 'desc');

            // Filter by user if authenticated
            if (auth()->check()) {
                $query->where('user_id', auth()->id());
            }

            // Filter by platform
            if ($request->has('platform')) {
                $query->where('platform', $request->platform);
            }

            // Filter by status
            if ($request->has('status')) {
                $query->where('status', $request->status);
            }

            // Pagination
            $perPage = $request->get('per_page', 20);
            $executions = $query->paginate($perPage);

            return response()->json([
                'success' => true,
                'data' => $executions
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل في جلب سجل التنفيذات',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get workflow statistics
     */
    public function statistics(string $workflowId): JsonResponse
    {
        try {
            $workflow = N8nWorkflow::where('workflow_id', $workflowId)->first();

            if (!$workflow) {
                return response()->json([
                    'success' => false,
                    'message' => 'Workflow غير موجود'
                ], 404);
            }

            $stats = $workflow->getStatistics();

            return response()->json([
                'success' => true,
                'data' => $stats
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'فشل في جلب الإحصائيات',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
