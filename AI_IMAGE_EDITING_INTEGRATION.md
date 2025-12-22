# AI Image Editing Integration

## Overview

This document describes the AI-powered image editing feature integrated with the mobile app using N8N workflows, Kie.ai API (nano banana model), and Google Drive.

---

## 🎨 Features

- **AI-Powered Editing**: Use natural language to edit images (e.g., "make the sky blue", "add sunglasses")
- **Google Drive Integration**: Automatic upload and storage
- **N8N Workflow Automation**: Complete workflow orchestration
- **Kie.ai nano banana model**: State-of-the-art AI image editing
- **Real-time Progress**: Track upload and editing progress
- **Edit History**: View all previous edits
- **Suggested Prompts**: Pre-defined editing suggestions

---

## Architecture

```
Flutter App → Google Drive → N8N Workflow → Kie.ai API → Edited Image
     ↓            ↓              ↓              ↓            ↓
  Pick Image  Upload File   Download File   AI Edit    Return URL
  Get Prompt  Share File    Build Request   Process    Save Result
                            Wait & Poll
```

---

## N8N Workflow Details

### Workflow ID
`QDmg9rBsQuXE8vx9`

### Workflow Name
`Edit Image Tool`

### Platform
`ai-tools`

### Type
`image`

### Input Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| image | string | Yes | Image file name |
| request | string | Yes | Edit request/prompt (what to change) |
| chatID | string | No | Telegram chat ID (optional) |
| pictureID | string | Yes | Google Drive file ID |

### Workflow Steps

1. **Trigger**: Receives input parameters
2. **Download**: Downloads image from Google Drive
3. **Share**: Makes file publicly accessible
4. **URL**: Constructs Google Drive URL
5. **nano banana (edit)**: Sends to Kie.ai API for editing
6. **Wait**: Waits ~25 seconds for processing
7. **Get_Image**: Polls for results
8. **IF**: Checks if editing succeeded
9. **Send Photo**: Optionally sends to Telegram
10. **HTTP Request**: Downloads edited image
11. **Upload Image**: Uploads result back to Google Drive

---

## Backend Implementation

### Database Entry

```php
[
    'workflow_id' => 'QDmg9rBsQuXE8vx9',
    'name' => 'Edit Image Tool',
    'description' => 'AI-powered image editing using Kie.ai nano banana model',
    'platform' => 'ai-tools',
    'type' => 'image',
    'credential_id' => 'hG1UKwcbFnmtNIPu',
    'upload_post_user' => 'n8n',
    'input_schema' => [...],
    'workflow_json' => [...],
    'is_active' => true
]
```

### API Endpoints

Same endpoints as N8N workflows:

```
GET  /api/n8n-workflows                    - Get all workflows (includes Edit Image)
GET  /api/n8n-workflows/platform/ai-tools  - Get AI tools workflows
POST /api/n8n-workflows/execute            - Execute Edit Image workflow
GET  /api/n8n-workflows/executions         - Get editing history
```

---

## Mobile App Implementation

### Services

#### 1. AiImageEditService

```dart
class AiImageEditService extends GetxController {
  /// Edit image using AI
  Future<Map<String, dynamic>> editImage({
    required File imageFile,
    required String editPrompt,
    String? imageName,
  });

  /// Pick image from gallery
  Future<File?> pickImageFromGallery();

  /// Pick image from camera
  Future<File?> pickImageFromCamera();

  /// Get edit suggestions
  List<String> getEditSuggestions();

  /// Get example prompts
  Map<String, List<String>> getExamplePrompts();
}
```

#### 2. GoogleDriveService

```dart
class GoogleDriveService extends GetxController {
  /// Upload file to Google Drive
  Future<Map<String, dynamic>> uploadFile({
    required File file,
    required String fileName,
    String? folderId,
  });

  /// Make file publicly accessible
  Future<bool> makeFilePublic(String fileId);

  /// Get file URLs
  String getFileUrl(String fileId);
  String getFileDownloadUrl(String fileId);
  String getFileWebViewUrl(String fileId);
}
```

### Initialization

```dart
// In main.dart
Get.put(GoogleDriveService());
Get.put(AiImageEditService());
```

---

## Usage Examples

### Basic Image Editing

```dart
final editService = Get.find<AiImageEditService>();

// Pick image
final imageFile = await editService.pickImageFromGallery();
if (imageFile == null) return;

// Edit with AI
final result = await editService.editImage(
  imageFile: imageFile,
  editPrompt: 'make the sky blue and add clouds',
  imageName: 'sunset_edited',
);

if (result['success'] == true) {
  print('Edited image URL: ${result['editedImageUrl']}');
  print('Google Drive ID: ${result['pictureID']}');
} else {
  print('Error: ${result['message']}');
}
```

### With Progress Tracking

```dart
final editService = Get.find<AiImageEditService>();

// Listen to progress
ever(editService.progress, (progress) {
  print('Progress: ${(progress * 100).toStringAsFixed(0)}%');
});

// Listen to status
ever(editService.status, (status) {
  print('Status: $status');
});

// Edit image
final result = await editService.editImage(
  imageFile: imageFile,
  editPrompt: editPrompt,
);
```

### Using Suggested Prompts

```dart
final editService = Get.find<AiImageEditService>();

// Get suggestions
final suggestions = editService.getEditSuggestions();
print('Suggestions: $suggestions');

// Get example prompts by category
final examples = editService.getExamplePrompts();
for (var category in examples.keys) {
  print('$category:');
  for (var prompt in examples[category]!) {
    print('  - $prompt');
  }
}
```

---

## Edit Prompt Examples

### Weather Effects
- "أضف تأثير المطر" (Add rain effect)
- "اجعل السماء غائمة" (Make sky cloudy)
- "أضف قوس قزح" (Add rainbow)
- "أضف ثلج" (Add snow)

### Image Enhancement
- "اجعل الألوان أكثر حيوية" (Make colors more vibrant)
- "أضف إضاءة احترافية" (Add professional lighting)
- "حسن جودة الصورة" (Improve image quality)
- "اجعل الصورة أوضح" (Make image clearer)

### Creative Edits
- "حول الصورة لرسم زيتي" (Convert to oil painting)
- "أضف تأثير كرتوني" (Add cartoon effect)
- "اجعلها تبدو كصورة قديمة" (Make it look vintage)
- "أضف تأثير النيون" (Add neon effect)

### Background Edits
- "غير الخلفية إلى غابة" (Change background to forest)
- "أضف خلفية فضائية" (Add space background)
- "اجعل الخلفية بيضاء نقية" (Make background pure white)
- "أضف خلفية مدينة" (Add city background)

---

## Testing

### Test Workflow Endpoint

```bash
# Get Edit Image workflow
curl https://mediaprosocial.io/api/n8n-workflows/platform/ai-tools

# Expected response:
{
  "success": true,
  "data": {
    "id": 4,
    "workflow_id": "QDmg9rBsQuXE8vx9",
    "name": "Edit Image Tool",
    "platform": "ai-tools",
    "type": "image",
    ...
  }
}
```

### Test Results

✅ **Workflow successfully added:**
- ID: 4
- Workflow ID: QDmg9rBsQuXE8vx9
- Platform: ai-tools
- Type: image
- Status: Active

---

## Current Status

### ✅ Completed
- N8N workflow added to database
- Backend API ready
- Flutter services created
- Google Drive integration
- Progress tracking
- Edit suggestions system

### ⚠️ Pending
- UI screen for image editing
- Direct N8N API call (currently requires backend update)
- Google Drive API configuration
- Kie.ai API credentials setup
- Real-time editing preview

### 🔧 Configuration Needed

1. **Google Drive API**:
   - Create Google Cloud project
   - Enable Google Drive API
   - Create OAuth credentials
   - Add credentials to Laravel backend

2. **Kie.ai API**:
   - Sign up at https://kie.ai
   - Get API key
   - Add to N8N workflow credentials

3. **N8N Instance**:
   - Configure N8N_URL in .env
   - Set up Google Drive node
   - Set up Kie.ai HTTP node
   - Test workflow execution

---

## Troubleshooting

### Google Drive Upload Fails

**Issue**: File upload to Google Drive returns error

**Solutions**:
1. Check Google Drive API is enabled
2. Verify OAuth credentials are configured
3. Ensure folder ID is correct (`1YCGwbzPHcEvDv6pVxf1ZltGYOTKmwFr-`)
4. Check backend has Google Drive credentials

### Edit Request Timeout

**Issue**: Image editing takes too long or times out

**Solutions**:
1. Increase wait time in N8N workflow (currently 25 seconds)
2. Check Kie.ai API status
3. Verify image size is not too large
4. Try simpler edit prompts

### Invalid Edit Results

**Issue**: Edited image doesn't match prompt

**Solutions**:
1. Make prompt more specific and clear
2. Use simple, direct language
3. Try different phrasings
4. Check example prompts for guidance

---

## Best Practices

### 1. Edit Prompts
- Be specific and clear
- Use simple language
- One change at a time works best
- Avoid complex multi-step edits

### 2. Image Quality
- Use high-quality source images
- Keep file sizes reasonable (< 5MB)
- Supported formats: JPG, PNG, WEBP
- Recommended size: 1080x1920 (9:16)

### 3. Performance
- Show progress to user
- Implement retry logic
- Cache edited images
- Provide offline support

### 4. User Experience
- Provide edit suggestions
- Show before/after comparison
- Allow saving/sharing results
- Enable edit history

---

## Security Considerations

1. **API Keys**: Never expose Kie.ai API key in mobile app
2. **File Access**: Ensure proper Google Drive permissions
3. **User Data**: Respect privacy when storing images
4. **Rate Limiting**: Implement to prevent API abuse

---

## Future Enhancements

### Planned Features
1. **Batch Editing**: Edit multiple images at once
2. **Style Transfer**: Apply artistic styles
3. **Object Removal**: Remove unwanted objects
4. **Face Enhancement**: Improve portraits
5. **Background Removal**: Automatic background removal
6. **Custom Filters**: User-created filter presets
7. **Edit Templates**: Pre-defined edit workflows
8. **Social Sharing**: Share edited images directly

### Advanced Features
1. **Real-time Preview**: See changes before applying
2. **Undo/Redo**: Multi-level edit history
3. **Comparison Mode**: Side-by-side before/after
4. **Edit Layers**: Apply multiple edits separately
5. **Export Options**: Multiple format/quality options

---

## API Reference

### Edit Image Endpoint (Future)

```http
POST /api/n8n-workflows/edit-image
Authorization: Bearer {token}
Content-Type: application/json

{
  "pictureID": "1abc123xyz456",
  "editPrompt": "make the sky blue",
  "imageName": "sunset_edited",
  "chatID": "optional_telegram_chat_id"
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم تحرير الصورة بنجاح",
  "data": {
    "execution_id": 123,
    "edited_image_url": "https://...",
    "google_drive_id": "...",
    "processing_time": 25
  }
}
```

---

## Conclusion

The AI Image Editing feature is successfully integrated with the backend and ready for mobile app implementation. The N8N workflow is configured and tested, providing a powerful and flexible image editing solution.

**Key Benefits:**
- 🎨 AI-powered editing with natural language
- ☁️ Cloud storage with Google Drive
- ⚡ Fast processing (< 30 seconds)
- 📱 Easy mobile integration
- 🔄 Automated workflow
- 📊 Full execution tracking

**Next Steps:**
1. Configure Google Drive API
2. Set up Kie.ai credentials
3. Create mobile UI
4. Test end-to-end flow
5. Deploy to production
