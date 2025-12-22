# Kie.ai API Setup Guide

## Overview

This guide explains how to set up Kie.ai API integration for AI-powered image editing using the nano banana model.

---

## What is Kie.ai?

Kie.ai provides state-of-the-art AI models for image generation and editing:
- **nano banana**: Advanced image editing model
- **Image-to-Image**: Transform existing images
- **Text-to-Image**: Generate images from descriptions
- **Style Transfer**: Apply artistic styles

---

## Prerequisites

- Internet connection
- Email address for registration
- Credit card for paid plans (optional)

---

## Step 1: Create Kie.ai Account

### 1.1 Visit Kie.ai Website
Go to: https://kie.ai

### 1.2 Sign Up
1. Click "Sign Up" or "Get Started"
2. Enter your email address
3. Create a strong password
4. Verify your email
5. Complete profile setup

### 1.3 Choose Plan
**Free Tier:**
- Limited API calls per month
- Suitable for testing

**Paid Plans:**
- $9.99/month - 1,000 requests
- $29.99/month - 5,000 requests
- $99.99/month - 20,000 requests
- Enterprise - Custom pricing

---

## Step 2: Get API Key

### 2.1 Navigate to API Keys
1. Log in to Kie.ai dashboard
2. Go to "Settings" or "API Keys"
3. Click "Create New API Key"

### 2.2 Create API Key
1. Enter key name: `Media Pro Social - Production`
2. Select permissions:
   - ✅ Image Generation
   - ✅ Image Editing
   - ✅ Model Access
3. Click "Generate"

### 2.3 Save API Key
**Important**: Copy and save your API key immediately!
```
kie_ai_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

⚠️ **Warning**: API key is shown only once. Store it securely!

---

## Step 3: Configure N8N Workflow

### 3.1 Access N8N Instance
Go to your N8N instance URL (e.g., https://your-n8n-instance.com)

### 3.2 Create Kie.ai Credentials

1. Go to "Credentials" in N8N
2. Click "Add Credential"
3. Select "HTTP Header Auth"
4. Enter details:
   - **Name**: `Kie ai`
   - **Header Name**: `Authorization`
   - **Header Value**: `Bearer YOUR_KIE_AI_API_KEY`
5. Click "Save"

### 3.3 Update Edit Image Workflow

1. Open "Edit Image Tool" workflow (QDmg9rBsQuXE8vx9)
2. Find "nano banana (edit)" node
3. Click on the node
4. In "Credentials" section:
   - Select "HTTP Header Auth"
   - Choose "Kie ai" credential
5. Save workflow

### 3.4 Verify Configuration

**Test Request:**
```bash
curl -X POST https://api.kie.ai/api/v1/jobs/createTask \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "google/nano-banana-edit",
    "input": {
      "prompt": "make the sky blue",
      "image_urls": ["https://example.com/image.jpg"],
      "output_format": "png",
      "image_size": "9:16"
    }
  }'
```

**Expected Response:**
```json
{
  "data": {
    "taskId": "abc123xyz",
    "state": "processing"
  }
}
```

---

## Step 4: Test Image Editing

### 4.1 Prepare Test Image

1. Upload an image to Google Drive
2. Get the file ID
3. Make file publicly accessible

### 4.2 Execute N8N Workflow

**Via N8N Interface:**
1. Open "Edit Image Tool" workflow
2. Click "Execute Workflow"
3. Enter test data:
   ```json
   {
     "image": "test.jpg",
     "request": "make the sky blue and add clouds",
     "pictureID": "YOUR_GOOGLE_DRIVE_FILE_ID",
     "chatID": ""
   }
   ```
4. Click "Execute"
5. Wait ~25 seconds
6. Check results

**Via API:**
```bash
curl -X POST https://mediaprosocial.io/api/n8n-workflows/execute \
  -H "Authorization: Bearer YOUR_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "workflow_id": "QDmg9rBsQuXE8vx9",
    "fileID": "",
    "text": "make the sky blue",
    "pictureID": "YOUR_GOOGLE_DRIVE_FILE_ID"
  }'
```

---

## Step 5: Configure Backend Settings

### 5.1 Add to Database Settings

```sql
INSERT INTO settings (key, value, type, `group`, is_public, description, created_at, updated_at)
VALUES
('kie_ai_api_key', 'YOUR_API_KEY', 'string', 'ai', false, 'Kie.ai API key for image editing', NOW(), NOW()),
('kie_ai_enabled', 'true', 'boolean', 'ai', true, 'Enable Kie.ai image editing', NOW(), NOW()),
('kie_ai_model', 'google/nano-banana-edit', 'string', 'ai', true, 'Kie.ai model to use', NOW(), NOW());
```

### 5.2 Or via Filament Admin

1. Login to admin panel
2. Go to "Settings" resource
3. Click "Create"
4. Add each setting:

**Setting 1:**
- Key: `kie_ai_api_key`
- Value: `YOUR_API_KEY`
- Type: `string`
- Group: `ai`
- Public: `No`
- Description: `Kie.ai API key`

**Setting 2:**
- Key: `kie_ai_enabled`
- Value: `true`
- Type: `boolean`
- Group: `ai`
- Public: `Yes`
- Description: `Enable Kie.ai`

**Setting 3:**
- Key: `kie_ai_model`
- Value: `google/nano-banana-edit`
- Type: `string`
- Group: `ai`
- Public: `Yes`
- Description: `Kie.ai model`

---

## Step 6: API Endpoints Reference

### 6.1 Create Task

**Endpoint:**
```
POST https://api.kie.ai/api/v1/jobs/createTask
```

**Headers:**
```
Authorization: Bearer YOUR_API_KEY
Content-Type: application/json
```

**Request Body:**
```json
{
  "model": "google/nano-banana-edit",
  "input": {
    "prompt": "make the sky blue",
    "image_urls": ["https://drive.google.com/uc?export=view&id=FILE_ID"],
    "output_format": "png",
    "image_size": "9:16"
  }
}
```

**Response:**
```json
{
  "data": {
    "taskId": "abc123xyz",
    "state": "processing"
  }
}
```

### 6.2 Check Status

**Endpoint:**
```
GET https://api.kie.ai/api/v1/jobs/recordInfo?taskId=TASK_ID
```

**Headers:**
```
Authorization: Bearer YOUR_API_KEY
```

**Response (Processing):**
```json
{
  "data": {
    "taskId": "abc123xyz",
    "state": "processing"
  }
}
```

**Response (Completed):**
```json
{
  "data": {
    "taskId": "abc123xyz",
    "state": "success",
    "resultJson": "{\"resultUrls\":[\"https://kie.ai/result/image.png\"]}"
  }
}
```

---

## Step 7: Available Models

### Image Editing Models

**1. google/nano-banana-edit**
- Best for: General image editing
- Speed: Fast (~20-30 seconds)
- Quality: High
- Use cases: Color changes, object addition, style modifications

**2. stability-ai/stable-diffusion-edit**
- Best for: Creative transformations
- Speed: Medium (~30-45 seconds)
- Quality: Very High
- Use cases: Artistic edits, major changes

**3. openai/dall-e-edit**
- Best for: Precise edits
- Speed: Slow (~45-60 seconds)
- Quality: Excellent
- Use cases: Detailed modifications

### Image Sizes

Supported aspect ratios:
- `1:1` - Square (1024x1024)
- `9:16` - Portrait (768x1366)
- `16:9` - Landscape (1366x768)
- `3:4` - Photo (896x1152)
- `4:3` - Photo Landscape (1152x896)

### Output Formats

- `png` - High quality, large file size
- `jpg` - Good quality, smaller file size
- `webp` - Modern format, best compression

---

## Step 8: Rate Limits & Quotas

### Free Tier Limits

| Limit | Value |
|-------|-------|
| Requests per day | 10 |
| Requests per hour | 5 |
| Max image size | 2MB |
| Processing timeout | 60 seconds |

### Paid Tier Limits

| Plan | Requests/month | Rate Limit | Max Size |
|------|----------------|------------|----------|
| Basic | 1,000 | 10/minute | 5MB |
| Pro | 5,000 | 30/minute | 10MB |
| Business | 20,000 | 100/minute | 20MB |

### Handling Rate Limits

**429 Too Many Requests:**
```json
{
  "error": {
    "code": "rate_limit_exceeded",
    "message": "Rate limit exceeded. Try again in 60 seconds."
  }
}
```

**Solution:**
- Implement exponential backoff
- Queue requests
- Upgrade plan if needed

---

## Step 9: Error Handling

### Common Errors

**1. Invalid API Key (401)**
```json
{
  "error": {
    "code": "unauthorized",
    "message": "Invalid API key"
  }
}
```
**Solution**: Verify API key is correct

**2. Image Too Large (413)**
```json
{
  "error": {
    "code": "payload_too_large",
    "message": "Image size exceeds limit"
  }
}
```
**Solution**: Resize image before upload

**3. Invalid Prompt (400)**
```json
{
  "error": {
    "code": "invalid_request",
    "message": "Prompt is required"
  }
}
```
**Solution**: Ensure prompt is not empty

**4. Processing Failed (500)**
```json
{
  "error": {
    "code": "processing_error",
    "message": "Failed to process image"
  }
}
```
**Solution**: Try again with different prompt

---

## Step 10: Best Practices

### 1. Prompt Engineering

**Good Prompts:**
- "make the sky blue and add white clouds"
- "change background to a forest"
- "add professional lighting"

**Bad Prompts:**
- "make it better" (too vague)
- "change everything" (unclear)
- "fix" (no context)

### 2. Image Preparation

- Use high-quality source images
- Optimal size: 1024x1024 to 2048x2048
- Supported formats: JPG, PNG, WEBP
- Compress before upload if > 5MB

### 3. Error Handling

```javascript
try {
  const result = await editImage(params);
  if (result.success) {
    // Handle success
  }
} catch (error) {
  if (error.code === 'rate_limit_exceeded') {
    // Wait and retry
    await sleep(60000);
    return editImage(params);
  } else if (error.code === 'invalid_request') {
    // Show user-friendly error
    showError('يرجى إدخال وصف تعديل أكثر وضوحاً');
  } else {
    // Generic error
    showError('حدث خطأ في معالجة الصورة');
  }
}
```

### 4. Caching

- Cache edited images
- Store task IDs for future reference
- Implement retry logic for failed tasks

### 5. Monitoring

- Track API usage
- Monitor error rates
- Set up alerts for quota limits

---

## Step 11: Testing Checklist

### Basic Tests

- [ ] API key authentication works
- [ ] Can create editing task
- [ ] Can check task status
- [ ] Receives edited image URL
- [ ] Image is accessible

### Integration Tests

- [ ] N8N workflow executes successfully
- [ ] Google Drive integration works
- [ ] File upload and sharing works
- [ ] Complete flow (upload → edit → return) works

### Error Tests

- [ ] Invalid API key rejected
- [ ] Rate limit handling works
- [ ] Invalid prompt rejected
- [ ] Image too large rejected
- [ ] Timeout handling works

---

## Troubleshooting

### Issue 1: "Unauthorized"

**Symptoms**: 401 error, "Invalid API key"

**Solutions**:
1. Verify API key in N8N credentials
2. Check API key format (starts with `kie_ai_`)
3. Ensure API key is not expired
4. Regenerate API key if needed

### Issue 2: "Task Stuck in Processing"

**Symptoms**: Task state remains "processing" for > 5 minutes

**Solutions**:
1. Check image is accessible (public URL)
2. Verify image size is within limits
3. Try simpler prompt
4. Check Kie.ai service status

### Issue 3: "Poor Edit Quality"

**Symptoms**: Edited image doesn't match prompt

**Solutions**:
1. Make prompt more specific
2. Use reference examples
3. Try different model
4. Adjust image size parameter

---

## Cost Optimization

### 1. Choose Right Plan

Calculate your needs:
- Daily edits × 30 = Monthly requests
- Add 20% buffer for retries
- Choose appropriate tier

### 2. Batch Processing

- Queue multiple edits
- Process during off-peak hours
- Reduce duplicate requests

### 3. Cache Results

- Store edited images
- Reuse results when possible
- Implement CDN for delivery

### 4. Monitor Usage

```sql
-- Track API usage
SELECT
  DATE(created_at) as date,
  COUNT(*) as requests,
  SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) as successful,
  SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) as failed
FROM n8n_workflow_executions
WHERE workflow_id = 'QDmg9rBsQuXE8vx9'
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

---

## Security Considerations

### 1. Protect API Key

```bash
# Never commit to git
echo "KIE_AI_API_KEY=*" >> .gitignore

# Use environment variables
export KIE_AI_API_KEY="your_key_here"

# Rotate regularly
# Generate new key every 90 days
```

### 2. Validate Inputs

- Sanitize file paths
- Validate image URLs
- Limit prompt length
- Check file types

### 3. Rate Limiting

- Implement per-user limits
- Track usage in database
- Block abusive users

---

## Support Resources

### Official Documentation
- **API Docs**: https://docs.kie.ai
- **Model Guide**: https://kie.ai/models
- **Support**: support@kie.ai

### Community
- **Discord**: https://discord.gg/kieai
- **GitHub**: https://github.com/kie-ai
- **Forum**: https://community.kie.ai

### Billing & Plans
- **Pricing**: https://kie.ai/pricing
- **Billing Portal**: https://kie.ai/billing
- **Upgrade**: https://kie.ai/upgrade

---

## Conclusion

Kie.ai API is now configured and ready for:
- ✅ AI-powered image editing
- ✅ Multiple editing models
- ✅ High-quality results
- ✅ Fast processing
- ✅ Production-ready integration

**Next Steps:**
1. Test complete flow
2. Monitor usage and costs
3. Optimize prompts for best results
4. Scale as needed

Remember to keep your API key secure and monitor your usage!
