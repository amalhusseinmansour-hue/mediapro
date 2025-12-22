# CSRF Token 419 Error - Fixed

## Problem
Admin login page at `https://mediaprosocial.io/admin/login` was showing HTTP 419 "Page Expired" error.

### Root Cause
The `.env` file had `SESSION_DRIVER=cookie` which stores sessions in encrypted cookies. In production with HTTPS and strict cookie settings, CSRF tokens in cookies were being rejected by Laravel's CSRF middleware.

## Solution Applied

### 1. Changed Session Driver
**File:** `backend/.env`

**Changed from:**
```
SESSION_DRIVER=cookie
```

**Changed to:**
```
SESSION_DRIVER=database
```

**Why:** Database-backed sessions are more reliable in production environments, especially with HTTPS and secure cookie settings.

### 2. Created Sessions Table Migration
**File:** `backend/database/migrations/2024_01_20_000000_create_sessions_table.php`

Created new migration file to define the `sessions` table schema required by Laravel when using `SESSION_DRIVER=database`.

### 3. Cleared Cache
Executed:
```bash
php artisan config:cache
php artisan route:cache
```

This ensures Laravel picks up the new `SESSION_DRIVER` configuration.

## Next Steps - IMPORTANT

The sessions migration needs to be run on the live server. Since direct database access from local IP is blocked, follow these steps via cPanel:

### Via cPanel Terminal or SSH:
```bash
cd /path/to/backend
php artisan migrate
```

### Via cPanel File Manager + MySQL:
1. Open cPanel → **Databases** → **phpMyAdmin**
2. Select your database (`u126213189_socialmedia_ma`)
3. Click **SQL** tab
4. Run this SQL to create the sessions table:

```sql
CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` longtext DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

## Testing

After running the migration, the admin login should work:
1. Visit: `https://mediaprosocial.io/admin/login`
2. The CSRF token will be properly stored in the database
3. Login should succeed without 419 errors

## Configuration Details

**Current Settings:**
- `SESSION_DRIVER=database` ← Now using database
- `SESSION_LIFETIME=480` (8 hours)
- `SESSION_ENCRYPT=true` (Sessions encrypted at rest)
- `COOKIE_SECURE=true` (HTTPS only)
- `COOKIE_SAME_SITE=Lax` (CSRF protection)

This is a production-ready configuration that balances security and reliability.

## Files Modified
1. `backend/.env` - Changed SESSION_DRIVER from cookie to database
2. `backend/database/migrations/2024_01_20_000000_create_sessions_table.php` - Created new migration
3. Cached configuration and routes

## Status
✅ Configuration updated
⏳ Waiting for sessions table migration to be run on live server
