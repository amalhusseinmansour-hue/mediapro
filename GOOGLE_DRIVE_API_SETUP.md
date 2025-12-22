# Google Drive API Setup Guide

## Overview

This guide explains how to set up Google Drive API integration for the Media Pro Social application to enable automated file uploads and management.

---

## Prerequisites

- Google Account
- Laravel application running
- Composer installed
- Access to Google Cloud Console

---

## Step 1: Create Google Cloud Project

### 1.1 Go to Google Cloud Console
Visit: https://console.cloud.google.com/

### 1.2 Create New Project
1. Click on project dropdown (top left)
2. Click "New Project"
3. Enter project name: `Media Pro Social`
4. Click "Create"
5. Wait for project creation
6. Select the new project

---

## Step 2: Enable Google Drive API

### 2.1 Navigate to APIs & Services
1. In Google Cloud Console, go to "APIs & Services" > "Library"
2. Search for "Google Drive API"
3. Click on "Google Drive API"
4. Click "Enable"

### 2.2 Wait for Activation
- API activation may take a few minutes
- You should see "API enabled" message

---

## Step 3: Create OAuth 2.0 Credentials

### 3.1 Go to Credentials Page
1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials"
3. Select "OAuth client ID"

### 3.2 Configure OAuth Consent Screen (First Time)
If prompted to configure OAuth consent screen:

1. Click "Configure Consent Screen"
2. Select "External" user type
3. Click "Create"
4. Fill in required information:
   - **App name**: Media Pro Social
   - **User support email**: Your email
   - **Developer contact**: Your email
5. Click "Save and Continue"
6. Skip "Scopes" (click "Save and Continue")
7. Skip "Test users" (click "Save and Continue")
8. Review and click "Back to Dashboard"

### 3.3 Create OAuth Client ID
1. Go back to "Credentials"
2. Click "Create Credentials" > "OAuth client ID"
3. Select "Web application"
4. Enter name: `Media Pro Social Backend`
5. Add Authorized redirect URIs:
   ```
   https://mediaprosocial.io/api/google/callback
   http://localhost:8000/api/google/callback (for testing)
   ```
6. Click "Create"
7. **Important**: Download the JSON file (credentials.json)

---

## Step 4: Create Service Account (Alternative Method)

### 4.1 Create Service Account
1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "Service Account"
3. Enter details:
   - **Service account name**: media-pro-social
   - **Service account ID**: (auto-generated)
4. Click "Create and Continue"
5. Skip "Grant this service account access to project"
6. Click "Done"

### 4.2 Create Service Account Key
1. Click on the created service account
2. Go to "Keys" tab
3. Click "Add Key" > "Create new key"
4. Select "JSON"
5. Click "Create"
6. **Important**: Download the JSON file (service-account.json)

---

## Step 5: Install PHP Google Client Library

### 5.1 Add Composer Package

```bash
cd /home/u126213189/domains/mediaprosocial.io/public_html
composer require google/apiclient:^2.0
```

### 5.2 Verify Installation

```bash
composer show google/apiclient
```

Expected output:
```
name     : google/apiclient
descrip. : Client library for Google APIs
versions : * v2.x.x
```

---

## Step 6: Configure Laravel Application

### 6.1 Upload Credentials File

Upload the downloaded JSON file to:
```
storage/app/google/credentials.json
```

Or via command line:
```bash
# Create directory
mkdir -p /home/u126213189/domains/mediaprosocial.io/public_html/storage/app/google

# Upload file (from local machine)
pscp -P 65002 -pw "PASSWORD" credentials.json user@server:/path/to/storage/app/google/
```

### 6.2 Set Folder Permissions

```bash
chmod 755 storage/app/google
chmod 644 storage/app/google/credentials.json
```

### 6.3 Update .env File

Add these variables to `.env`:

```env
# Google Drive API
GOOGLE_DRIVE_ENABLED=true
GOOGLE_DRIVE_FOLDER_ID=1YCGwbzPHcEvDv6pVxf1ZltGYOTKmwFr-
```

### 6.4 Clear Config Cache

```bash
php artisan config:cache
php artisan optimize:clear
```

---

## Step 7: Create Google Drive Folder

### 7.1 Create Folder
1. Go to https://drive.google.com
2. Create a new folder: `Media Pro Social`
3. Open the folder
4. Copy the folder ID from URL:
   ```
   https://drive.google.com/drive/folders/[FOLDER_ID]
   ```
5. Update `GOOGLE_DRIVE_FOLDER_ID` in `.env`

### 7.2 Share Folder with Service Account (if using Service Account)
1. Open the folder
2. Click "Share"
3. Enter the service account email:
   ```
   media-pro-social@project-id.iam.gserviceaccount.com
   ```
4. Grant "Editor" permission
5. Click "Share"

---

## Step 8: Add API Routes

### 8.1 Update routes/api.php

Add these routes:

```php
use App\Http\Controllers\Api\GoogleDriveController;

// Google Drive API Routes (Protected)
Route::middleware(['auth:sanctum'])->prefix('google-drive')->group(function () {
    Route::post('/upload', [GoogleDriveController::class, 'upload']);
    Route::post('/share', [GoogleDriveController::class, 'share']);
    Route::delete('/delete', [GoogleDriveController::class, 'delete']);
    Route::get('/file/{fileId}', [GoogleDriveController::class, 'getFile']);
    Route::get('/status', [GoogleDriveController::class, 'status']);
});
```

### 8.2 Clear Route Cache

```bash
php artisan route:cache
```

---

## Step 9: Test Integration

### 9.1 Check Status

```bash
curl https://mediaprosocial.io/api/google-drive/status
```

Expected response:
```json
{
  "success": true,
  "data": {
    "configured": true,
    "credentials_exists": true,
    "token_exists": true,
    "folder_id": "1YCGwbzPHcEvDv6pVxf1ZltGYOTKmwFr-"
  }
}
```

### 9.2 Test File Upload

```bash
curl -X POST https://mediaprosocial.io/api/google-drive/upload \
  -H "Authorization: Bearer YOUR_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "file_data": "BASE64_ENCODED_FILE",
    "file_name": "test.jpg",
    "mime_type": "image/jpeg"
  }'
```

Expected response:
```json
{
  "success": true,
  "message": "تم رفع الملف بنجاح",
  "data": {
    "file_id": "1abc123xyz456",
    "file_name": "test.jpg",
    "file_url": "https://drive.google.com/uc?export=view&id=1abc123xyz456",
    "web_view_link": "https://drive.google.com/file/d/1abc123xyz456/view"
  }
}
```

---

## Step 10: Verify in Google Drive

1. Go to https://drive.google.com
2. Navigate to your "Media Pro Social" folder
3. Verify the uploaded file appears
4. Check file permissions are set to "Anyone with the link"

---

## Troubleshooting

### Issue 1: "Credentials file not found"

**Solution:**
- Verify file exists at `storage/app/google/credentials.json`
- Check file permissions (should be readable)
- Verify path is correct in controller

### Issue 2: "Invalid credentials"

**Solution:**
- Re-download credentials from Google Cloud Console
- Ensure using correct JSON file (OAuth or Service Account)
- Check JSON file is valid (open in text editor)

### Issue 3: "Permission denied"

**Solution:**
- Check folder permissions in Google Drive
- Ensure service account has access to folder
- Verify API scopes include Google Drive

### Issue 4: "Token expired"

**Solution:**
- Delete `storage/app/google/token.json`
- Re-authenticate via OAuth flow
- Check refresh token is present

### Issue 5: "API not enabled"

**Solution:**
- Go to Google Cloud Console
- Enable Google Drive API
- Wait a few minutes for propagation

---

## Security Best Practices

### 1. Protect Credentials
```bash
# Set strict permissions
chmod 600 storage/app/google/credentials.json
chmod 600 storage/app/google/token.json

# Add to .gitignore
echo "storage/app/google/*.json" >> .gitignore
```

### 2. Use Environment Variables
Never commit credentials to version control. Always use `.env` file.

### 3. Limit API Scopes
Only request necessary scopes:
- `https://www.googleapis.com/auth/drive.file`
- `https://www.googleapis.com/auth/drive.readonly`

### 4. Implement Rate Limiting
Add rate limiting to upload endpoint:
```php
Route::post('/upload', [GoogleDriveController::class, 'upload'])
    ->middleware('throttle:10,1'); // 10 requests per minute
```

### 5. Validate File Types
Always validate and sanitize uploaded files.

---

## Cost Considerations

### Google Drive API Quotas

**Free Tier:**
- 1 billion queries per day
- 10,000 queries per 100 seconds per user

**Storage:**
- 15 GB free per Google Account
- Paid plans available via Google Workspace

### Recommendations

1. **Monitor Usage**: Check quotas in Google Cloud Console
2. **Implement Caching**: Cache file lists and metadata
3. **Batch Operations**: Group multiple operations when possible
4. **Clean Up**: Delete old/unused files regularly

---

## Next Steps

After completing Google Drive setup:

1. ✅ Test file upload from Flutter app
2. ✅ Test file sharing functionality
3. ✅ Integrate with N8N workflows
4. ✅ Enable Kie.ai image editing
5. ✅ Deploy to production

---

## Support

### Resources
- **Google Drive API Docs**: https://developers.google.com/drive
- **PHP Client Library**: https://github.com/googleapis/google-api-php-client
- **OAuth 2.0 Guide**: https://developers.google.com/identity/protocols/oauth2

### Common Commands

```bash
# Check API status
php artisan tinker
>>> app(App\Http\Controllers\Api\GoogleDriveController::class)->status()

# Clear all caches
php artisan optimize:clear

# View logs
tail -f storage/logs/laravel.log | grep "Google Drive"
```

---

## Conclusion

Google Drive API is now configured and ready to use for:
- ✅ Automated file uploads
- ✅ Public file sharing
- ✅ File management
- ✅ Integration with AI image editing
- ✅ N8N workflow automation

**Remember**: Keep your credentials secure and never commit them to version control!
