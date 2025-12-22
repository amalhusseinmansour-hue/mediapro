#!/bin/bash

# API Integration Testing Script

echo "🧪 Testing API Endpoints..."
echo ""

# Base URL - Replace with your actual backend URL
BASE_URL="http://localhost:8000/api"

# Test 1: Send OTP
echo "1️⃣ Testing /auth/send-otp endpoint..."
curl -X POST "$BASE_URL/auth/send-otp" \
  -H "Content-Type: application/json" \
  -d '{
    "phone_number": "+201234567890"
  }' \
  -w "\nStatus: %{http_code}\n\n"

# Test 2: Check response structure
echo "2️⃣ Expected Response Structure for /auth/send-otp:"
echo '{
  "success": true,
  "message": "رسالة النجاح",
  "otp": "123456" // في وضع التطوير فقط
}'
echo ""

# Test 3: Verify OTP endpoint exists
echo "3️⃣ Testing /auth/verify-otp endpoint..."
curl -X POST "$BASE_URL/auth/verify-otp" \
  -H "Content-Type: application/json" \
  -d '{
    "phone_number": "+201234567890",
    "otp": "123456"
  }' \
  -w "\nStatus: %{http_code}\n\n"

# Test 4: Check response structure for verify
echo "4️⃣ Expected Response Structure for /auth/verify-otp:"
echo '{
  "success": true,
  "message": "تم التحقق بنجاح",
  "data": {
    "user": {
      "id": 1,
      "name": "User",
      "phone_number": "+201234567890",
      ...
    },
    "access_token": "token_string",
    "token_type": "Bearer"
  }
}'
echo ""

# Test 5: Check register endpoint
echo "5️⃣ Testing /auth/register endpoint..."
curl -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "phone_number": "+201234567890",
    "user_type": "individual",
    "email": "test@example.com"
  }' \
  -w "\nStatus: %{http_code}\n\n"

echo "✅ API Testing Complete!"
