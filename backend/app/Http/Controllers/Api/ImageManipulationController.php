<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\N8nService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class ImageManipulationController extends Controller
{
    protected $n8nService;

    public function __construct(N8nService $n8nService)
    {
        $this->n8nService = $n8nService;
    }

    /**
     * Handle the request from the Flutter app to edit an image.
     * This acts as a secure proxy to the N8N workflow.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function editImage(Request $request)
    {
        // Validate the incoming request data
        $validator = Validator::make($request->all(), [
            'pictureID' => 'required|string',
            'edit_prompt' => 'required|string|min:3',
            'image_name' => 'required|string',
            'chatID' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        try {
            $data = $validator->validated();

            // Call the N8nService to trigger the workflow
            $result = $this->n8nService->triggerImageEditWorkflow($data);

            if (!$result['success']) {
                return response()->json($result, 502); // 502 Bad Gateway if N8N fails
            }

            // Return a success response to the Flutter app
            return response()->json(['success' => true, 'message' => 'تم إرسال طلب تعديل الصورة بنجاح.', 'data' => $result['data']]);

        } catch (\Exception $e) {
            Log::error('Image Edit Workflow Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'حدث خطأ في الخادم أثناء معالجة الطلب.'], 500);
        }
    }
}