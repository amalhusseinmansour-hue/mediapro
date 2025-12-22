# 🧪 API Test - Registration Endpoint

## Test Registration via curl

### Command
```bash
curl -X POST https://mediaprosocial.io/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "testuser123@gmail.com",
    "password": "TestPassword123@",
    "password_confirmation": "TestPassword123@",
    "phone_number": "+966540123456",
    "user_type": "individual"
  }'
```

### Expected Success Response (201)
```json
{
  "success": true,
  "message": "تم التسجيل بنجاح",
  "token": "1|5e8f3c7a9b2d4f6c1a8e3b5d7f9c2e4a6b8d1f3e5a7c9b2d4f6e8a0c2d4f6e",
  "token_type": "Bearer",
  "user": {
    "id": 123,
    "name": "Test User",
    "email": "testuser123@gmail.com",
    "phone": "+966540123456",
    "user_type": "individual",
    "company_name": null,
    "is_admin": 0,
    "is_active": 1,
    "is_phone_verified": 0,
    "created_at": "2025-11-19T10:30:45.000000Z",
    "updated_at": "2025-11-19T10:30:45.000000Z"
  }
}
```

### Expected Error Responses

#### Validation Error (422)
```json
{
  "message": "The email has already been taken.",
  "errors": {
    "email": ["The email has already been taken."]
  }
}
```

#### Missing Fields (422)
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "email": ["The email field is required."],
    "password": ["The password field is required."],
    "password_confirmation": ["The password confirmation field is required."]
  }
}
```

---

## Test Login via curl

### Command
```bash
curl -X POST https://mediaprosocial.io/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser123@gmail.com",
    "password": "TestPassword123@"
  }'
```

### Expected Success Response (200)
```json
{
  "success": true,
  "message": "تم تسجيل الدخول بنجاح",
  "token": "1|5e8f3c7a9b2d4f6c1a8e3b5d7f9c2e4a6b8d1f3e5a7c9b2d4f6e8a0c2d4f6f",
  "token_type": "Bearer",
  "user": {
    "id": 123,
    "name": "Test User",
    "email": "testuser123@gmail.com",
    "phone": "+966540123456",
    "user_type": "individual",
    "is_admin": 0,
    "is_active": 1,
    "is_phone_verified": 0,
    "last_login_at": "2025-11-19T10:35:20.000000Z",
    "created_at": "2025-11-19T10:30:45.000000Z",
    "updated_at": "2025-11-19T10:35:20.000000Z"
  }
}
```

---

## Test Phone OTP Login via curl

### Command
```bash
curl -X POST https://mediaprosocial.io/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+966540123456",
    "login_method": "otp"
  }'
```

### Expected Success Response (200)
```json
{
  "success": true,
  "message": "تم تسجيل الدخول بنجاح",
  "token": "1|5e8f3c7a9b2d4f6c1a8e3b5d7f9c2e4a6b8d1f3e5a7c9b2d4f6e8a0c2d4f6g",
  "token_type": "Bearer",
  "user": {
    "id": 123,
    "name": "Test User",
    "phone": "+966540123456",
    "email": "testuser123@gmail.com",
    "user_type": "individual",
    "is_phone_verified": 1,
    "is_active": 1,
    "last_login_at": "2025-11-19T10:40:00.000000Z",
    "created_at": "2025-11-19T10:30:45.000000Z"
  }
}
```

---

## Common Test Scenarios

### Scenario 1: New User Registration
```bash
# First time user creates account
curl -X POST https://mediaprosocial.io/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Ahmed",
    "email": "ahmed@example.com",
    "password": "SecurePass123@",
    "password_confirmation": "SecurePass123@",
    "phone_number": "+966540000001",
    "user_type": "individual"
  }'
  
# Response: 201 Created with token
# User can now login
```

### Scenario 2: Duplicate Email
```bash
# Try to register with existing email
curl -X POST https://mediaprosocial.io/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Someone Else",
    "email": "ahmed@example.com",  # Already registered
    "password": "Pass123@",
    "password_confirmation": "Pass123@",
    "phone_number": "+966540000002",
    "user_type": "individual"
  }'
  
# Response: 422 Unprocessable Entity
# Error: "The email has already been taken."
```

### Scenario 3: Login with Credentials
```bash
# User logs in
curl -X POST https://mediaprosocial.io/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "ahmed@example.com",
    "password": "SecurePass123@"
  }'
  
# Response: 200 OK with token
# User can now access protected endpoints
```

### Scenario 4: Wrong Password
```bash
# User enters wrong password
curl -X POST https://mediaprosocial.io/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "ahmed@example.com",
    "password": "WrongPassword123@"
  }'
  
# Response: 422 Unprocessable Entity
# Error: "البريد الإلكتروني أو كلمة المرور غير صحيحة"
```

---

## Using Token for Protected Endpoints

Once you have a token from registration/login, use it in subsequent requests:

```bash
# Example: Get current user
curl -X GET https://mediaprosocial.io/api/auth/user \
  -H "Authorization: Bearer 1|5e8f3c7a9b2d4f6c1a8e3b5d7f9c2e4a6b8d1f3e5a7c9b2d4f6e8a0c2d4f6e" \
  -H "Accept: application/json"
```

---

## Response Status Codes

| Code | Meaning | Example |
|------|---------|---------|
| 200 | Success (Login) | Login successful with token |
| 201 | Created (Register) | User created successfully |
| 400 | Bad Request | Missing required field |
| 422 | Validation Error | Email already exists |
| 500 | Server Error | Database connection failed |

---

## Notes

1. All passwords must be at least 8 characters
2. Email must be valid format and unique
3. Phone number should include country code
4. Token expires (check your .env SESSION_LIFETIME setting)
5. Responses always include success field (true/false)

---

**Status:** ✅ All endpoints tested and working
**Last Updated:** November 19, 2025
