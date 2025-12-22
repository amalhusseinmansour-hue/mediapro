#!/bin/bash
# Test Admin Login Script

echo "========================================="
echo "Testing Admin Panel Login"
echo "========================================="
echo ""

# Step 1: Get login page and CSRF token
echo "[1] Getting login page and CSRF token..."
RESPONSE=$(curl -s -c /tmp/cookies.txt -b /tmp/cookies.txt https://mediaprosocial.io/admin/login)
CSRF_TOKEN=$(echo "$RESPONSE" | grep -o 'csrf-token" content="[^"]*"' | cut -d'"' -f4)

echo "CSRF Token: $CSRF_TOKEN"
echo ""

# Step 2: Check if we got a token
if [ -z "$CSRF_TOKEN" ]; then
    echo "❌ ERROR: Could not get CSRF token"
    exit 1
else
    echo "✅ CSRF token received successfully"
fi
echo ""

# Step 3: Get session cookie
SESSION_COOKIE=$(grep -o 'social-media-manager-session[^;]*' /tmp/cookies.txt | tail -1)
echo "Session Cookie: ${SESSION_COOKIE:0:50}..."
echo ""

# Step 4: Try to login
echo "[2] Attempting login with credentials..."
LOGIN_RESPONSE=$(curl -s -L \
    -b /tmp/cookies.txt \
    -c /tmp/cookies.txt \
    -X POST \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -H "X-CSRF-TOKEN: $CSRF_TOKEN" \
    -d "email=admin@example.com" \
    -d "password=password" \
    -d "_token=$CSRF_TOKEN" \
    https://mediaprosocial.io/admin/login \
    -w "\nHTTP_CODE:%{http_code}")

HTTP_CODE=$(echo "$LOGIN_RESPONSE" | grep "HTTP_CODE" | cut -d':' -f2)
echo "HTTP Response Code: $HTTP_CODE"
echo ""

# Step 5: Check result
if [ "$HTTP_CODE" = "419" ]; then
    echo "❌ ERROR 419: Page Expired - CSRF token issue"
    exit 1
elif [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
    echo "✅ Login request successful (Code: $HTTP_CODE)"

    # Check if redirected to dashboard
    if echo "$LOGIN_RESPONSE" | grep -q "dashboard\|admin" ; then
        echo "✅ Successfully logged in!"
    else
        echo "⚠️  Login processed but check credentials"
    fi
else
    echo "⚠️  Unexpected response: $HTTP_CODE"
fi

echo ""
echo "========================================="
echo "Test Complete"
echo "========================================="
