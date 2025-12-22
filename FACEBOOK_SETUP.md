# Facebook & Instagram OAuth Setup Guide

## Overview

This guide will help you configure Facebook Login for your app. Once configured, both **Facebook** and **Instagram** OAuth will work (Instagram uses Facebook Login API).

---

## Step 1: Create Facebook App

1. **Go to Facebook Developers**:
   - Visit: https://developers.facebook.com/apps
   - Click **"Create App"**

2. **Choose App Type**:
   - Select: **"Consumer"** or **"Business"**
   - Click **"Next"**

3. **App Details**:
   - **App Name**: `Social Media Manager` (or your app name)
   - **App Contact Email**: Your email
   - Click **"Create App"**

4. **Save Your App ID**:
   - After creation, you'll see your **App ID** in the dashboard
   - **Copy this App ID** - you'll need it!

---

## Step 2: Configure Facebook Login

1. **Add Facebook Login Product**:
   - In your app dashboard, click **"Add Product"**
   - Find **"Facebook Login"** and click **"Set Up"**
   - Choose **"Android"** platform

2. **Android Settings**:

   **Package Name**:
   ```
   com.socialmedia.social_media_manager
   ```

   **Default Activity Class Name**:
   ```
   com.socialmedia.social_media_manager.MainActivity
   ```

   **Key Hashes**:
   - For debug builds, you can skip this for now
   - For release builds, generate using:
   ```bash
   keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
   ```
   Default password is: `android`

3. **Save Changes**

---

## Step 3: Configure App Settings

1. **Go to Settings → Basic**

2. **Fill Required Fields**:
   - **Privacy Policy URL**: Your privacy policy URL (required for production)
   - **App Domains**: `mediaprosocial.io` (or your domain)
   - **Category**: Choose appropriate category

3. **Save Changes**

---

## Step 4: Add Facebook App ID to Your Flutter App

### Location 1: strings.xml (Required)

Open file:
```
android/app/src/main/res/values/strings.xml
```

Update lines 13-14:

**Before:**
```xml
<string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
<string name="fb_login_protocol_scheme">fbYOUR_FACEBOOK_APP_ID</string>
```

**After:**
```xml
<string name="facebook_app_id">123456789012345</string>
<string name="fb_login_protocol_scheme">fb123456789012345</string>
```

Replace `123456789012345` with your actual Facebook App ID.

### Location 2: AndroidManifest.xml (Already Configured ✅)

The file `android/app/src/main/AndroidManifest.xml` is already configured. No changes needed!

---

## Step 5: Rebuild and Test

1. **Clean and rebuild**:
   ```bash
   flutter clean
   flutter pub get
   flutter run -d R9KY902X3HW
   ```

2. **Test Facebook Login**:
   - Open app
   - Go to **"Accounts"** screen
   - Tap **"Connect Facebook"**
   - You should see Facebook login screen
   - Login with your Facebook account
   - Account will be saved automatically

---

## Step 6: Enable Instagram (Optional)

If you want to connect Instagram Business accounts:

1. **Go to App Dashboard → Products**
2. **Add Product → Instagram Basic Display API** or **Instagram Graph API**
3. **Configure Settings**:
   - Add **Redirect URI**: `https://mediaprosocial.io/auth/callback`
   - Save changes

4. **Request Permissions**:
   - In App Review, request permissions:
     - `instagram_basic`
     - `instagram_content_publish`
     - `pages_show_list`

---

## Permissions Required

The app requests these Facebook permissions:
- `email` - User's email address
- `public_profile` - Public profile info
- `pages_show_list` - List of pages user manages
- `pages_read_engagement` - Page engagement data

For Instagram:
- `instagram_basic` - Basic Instagram profile
- `instagram_content_publish` - Publish content to Instagram

---

## Development vs Production

### Development Mode (Default)
- App is in **Development Mode** by default
- Only works for app developers/testers/admins (added in Roles)
- No app review required

### Production Mode
To make your app available to all users:

1. **Complete App Review**:
   - Go to **App Review**
   - Submit for review with required permissions
   - Provide use case explanation and demo video

2. **Make App Public**:
   - After approval, toggle **"App Mode"** to **"Live"**

---

## Troubleshooting

### Error: "SDK has not been initialized"
**Solution**: Make sure you've updated `strings.xml` with your actual Facebook App ID

### Error: "Invalid key hash"
**Solution**:
1. Generate correct key hash for your build
2. Add it to Facebook app settings under **Settings → Basic → Key Hashes**

### Error: "App not configured for Facebook Login"
**Solution**: Make sure you've added "Facebook Login" product to your app

### Error: "This app is still in development mode"
**Solution**:
- Add test users in **Roles → Test Users**, or
- Submit for App Review to go live

### Error: "Can't load URL: The domain is not included in app domains"
**Solution**: Add your domain to **Settings → Basic → App Domains**

---

## Testing with Test Users

1. **Create Test Users**:
   - Go to **Roles → Test Users**
   - Click **"Add"**
   - Create test users with Facebook accounts

2. **Use Test Accounts**:
   - Login with test user credentials
   - Test Facebook/Instagram connection

---

## Security Best Practices

1. **Never commit Facebook App ID to public repositories**
   - Add `strings.xml` to `.gitignore` if needed
   - Use environment variables for sensitive data

2. **Validate Server-Side**:
   - Always validate access tokens on your backend
   - Don't trust client-side tokens alone

3. **Use HTTPS**:
   - Always use HTTPS for callback URLs
   - Facebook requires secure connections

4. **Rotate App Secret Regularly**:
   - Change App Secret periodically
   - Available in **Settings → Basic → App Secret**

---

## Useful Links

- Facebook Developers Console: https://developers.facebook.com/apps
- Facebook Login Documentation: https://developers.facebook.com/docs/facebook-login
- Instagram Basic Display API: https://developers.facebook.com/docs/instagram-basic-display-api
- Instagram Graph API: https://developers.facebook.com/docs/instagram-api

---

## Quick Reference

**Required Files to Update:**
1. ✅ `android/app/src/main/res/values/strings.xml` - Add Facebook App ID
2. ✅ `android/app/src/main/AndroidManifest.xml` - Already configured

**Facebook App Settings:**
- Package Name: `com.socialmedia.social_media_manager`
- Main Activity: `com.socialmedia.social_media_manager.MainActivity`
- OAuth Redirect URI: `https://mediaprosocial.io/auth/callback`

---

💡 **Tip**: Keep your Facebook App ID in a secure password manager!
