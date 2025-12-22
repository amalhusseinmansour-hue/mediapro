# Admin Panel API Endpoints

This document describes the API endpoints required for the Admin Panel to function properly.

## Base URL
```
https://mediaprosocial.io/api
```

## Authentication
All admin endpoints require authentication with admin role.
Include the Bearer token in the Authorization header:
```
Authorization: Bearer {token}
```

---

## 1. Dashboard Statistics

### GET /admin/dashboard/stats
Returns statistics for the admin dashboard.

**Response:**
```json
{
  "success": true,
  "data": {
    "users": {
      "total": 1234,
      "trend": "+12%",
      "active": 1100,
      "new_today": 15
    },
    "ads": {
      "total": 89,
      "pending": 12,
      "approved": 70,
      "rejected": 7,
      "trend": "+5%"
    },
    "payments": {
      "total": 4567.50,
      "trend": "+18%",
      "today": 250.00,
      "month": 4567.50
    },
    "subscriptions": {
      "total": 456,
      "active": 400,
      "expired": 56,
      "trend": "+8%"
    }
  }
}
```

---

## 2. Users Management

### GET /admin/users
Get list of all users with pagination.

**Query Parameters:**
- `page` (int): Page number (default: 1)
- `per_page` (int): Items per page (default: 20)
- `search` (string): Search by name/email
- `status` (string): Filter by status (active/inactive/suspended)

**Response:**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "1",
        "name": "John Doe",
        "email": "john@example.com",
        "phone": "+971501234567",
        "status": "active",
        "subscription": "premium",
        "created_at": "2024-01-15T10:30:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 10,
      "total_items": 200
    }
  }
}
```

### PUT /admin/users/{id}/status
Update user status.

**Request Body:**
```json
{
  "status": "active|inactive|suspended"
}
```

### DELETE /admin/users/{id}
Delete a user account.

---

## 3. Ads Management

### GET /admin/ads
Get ads list with filtering.

**Query Parameters:**
- `status` (string): pending/approved/rejected
- `page` (int): Page number

**Response:**
```json
{
  "success": true,
  "data": {
    "ads": [
      {
        "id": "1",
        "title": "Ad Title",
        "description": "Ad description",
        "user_id": "123",
        "user_name": "John Doe",
        "status": "pending",
        "budget": 100.00,
        "created_at": "2024-01-15T10:30:00Z"
      }
    ]
  }
}
```

### POST /admin/ads/{id}/approve
Approve an ad.

### POST /admin/ads/{id}/reject
Reject an ad.

**Request Body:**
```json
{
  "reason": "Reason for rejection"
}
```

---

## 4. Payments Management

### GET /admin/payments
Get payments list.

**Query Parameters:**
- `page` (int): Page number
- `status` (string): completed/pending/failed/refunded
- `date_from` (string): Start date (YYYY-MM-DD)
- `date_to` (string): End date (YYYY-MM-DD)

**Response:**
```json
{
  "success": true,
  "data": {
    "payments": [
      {
        "id": "1",
        "user_id": "123",
        "user_name": "John Doe",
        "amount": 99.00,
        "currency": "AED",
        "status": "completed",
        "gateway": "paymob",
        "description": "Premium subscription",
        "created_at": "2024-01-15T10:30:00Z"
      }
    ]
  }
}
```

### POST /admin/payments/{id}/refund
Refund a payment.

---

## 5. Settings Management

### GET /admin/settings
Get all admin settings (includes sensitive data like API keys).

**Response:**
```json
{
  "success": true,
  "data": {
    "app": {
      "name": "ميديا برو",
      "name_en": "Media Pro",
      "version": "1.0.0",
      "maintenance_mode": false
    },
    "ai": {
      "image_generation_enabled": true,
      "video_generation_enabled": true,
      "image_provider": "replicate",
      "replicate_api_key": "r8_xxx...",
      "runway_api_key": "xxx...",
      "default_model": "gpt-4"
    },
    "otp": {
      "twilio_enabled": true,
      "twilio_account_sid": "ACxxx...",
      "twilio_auth_token": "xxx...",
      "twilio_phone_number": "+1234567890",
      "test_otp_enabled": true,
      "test_otp_code": "123456"
    },
    "payment": {
      "stripe_enabled": true,
      "paymob_enabled": true,
      "paypal_enabled": false,
      "apple_pay_enabled": true,
      "google_pay_enabled": false,
      "default_gateway": "paymob",
      "minimum_amount": 10
    },
    "analytics": {
      "enabled": true,
      "google_analytics_enabled": false,
      "facebook_pixel_enabled": false,
      "firebase_analytics_enabled": true,
      "google_analytics_tracking_id": "",
      "facebook_pixel_id": ""
    },
    "localization": {
      "currency": "AED",
      "default_language": "ar"
    },
    "features": {
      "firebase_enabled": true
    }
  }
}
```

### PUT /admin/settings
Update a single setting.

**Request Body:**
```json
{
  "group": "ai",
  "key": "image_generation_enabled",
  "value": true
}
```

### PUT /admin/settings/batch
Update multiple settings at once.

**Request Body:**
```json
{
  "settings": {
    "ai": {
      "image_generation_enabled": true,
      "replicate_api_key": "new_key"
    },
    "payment": {
      "stripe_enabled": false
    }
  }
}
```

---

## 6. Reports

### GET /admin/reports
Get reports data.

**Query Parameters:**
- `period` (string): day/week/month/year
- `type` (string): users/payments/ads/subscriptions

**Response:**
```json
{
  "success": true,
  "data": {
    "period": "month",
    "users": {
      "new": 150,
      "active": 1100,
      "chart_data": [
        {"date": "2024-01-01", "value": 10},
        {"date": "2024-01-02", "value": 15}
      ]
    },
    "revenue": {
      "total": 15000,
      "chart_data": [
        {"date": "2024-01-01", "value": 500},
        {"date": "2024-01-02", "value": 750}
      ]
    }
  }
}
```

---

## 7. Admin Access Check

### GET /admin/check-access
Check if the current user has admin access.

**Response:**
```json
{
  "success": true,
  "is_admin": true,
  "role": "super_admin"
}
```

---

## Laravel Route Setup

Add these routes to your `routes/api.php`:

```php
<?php

use Illuminate\Support\Facades\Route;

// Admin routes (requires auth and admin middleware)
Route::middleware(['auth:sanctum', 'admin'])->prefix('admin')->group(function () {

    // Dashboard
    Route::get('/dashboard/stats', [AdminController::class, 'dashboardStats']);
    Route::get('/check-access', [AdminController::class, 'checkAccess']);

    // Users
    Route::get('/users', [AdminUserController::class, 'index']);
    Route::put('/users/{id}/status', [AdminUserController::class, 'updateStatus']);
    Route::delete('/users/{id}', [AdminUserController::class, 'destroy']);

    // Ads
    Route::get('/ads', [AdminAdsController::class, 'index']);
    Route::post('/ads/{id}/approve', [AdminAdsController::class, 'approve']);
    Route::post('/ads/{id}/reject', [AdminAdsController::class, 'reject']);

    // Payments
    Route::get('/payments', [AdminPaymentController::class, 'index']);
    Route::post('/payments/{id}/refund', [AdminPaymentController::class, 'refund']);

    // Settings
    Route::get('/settings', [AdminSettingsController::class, 'index']);
    Route::put('/settings', [AdminSettingsController::class, 'update']);
    Route::put('/settings/batch', [AdminSettingsController::class, 'batchUpdate']);

    // Reports
    Route::get('/reports', [AdminReportsController::class, 'index']);
});
```

---

## Error Responses

All endpoints return errors in this format:

```json
{
  "success": false,
  "message": "Error description",
  "errors": {
    "field": ["Validation error message"]
  }
}
```

**Status Codes:**
- 200: Success
- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden (not admin)
- 404: Not Found
- 422: Validation Error
- 500: Server Error
