#!/bin/bash
# Final Admin Login Test

echo "========================================="
echo "Testing Admin Login - Final Test"
echo "========================================="
echo ""

# Clean start
rm -f /tmp/test_cookies.txt

# Step 1: Access login page
echo "[1] Accessing login page..."
LOGIN_PAGE=$(curl -s -c /tmp/test_cookies.txt -b /tmp/test_cookies.txt https://mediaprosocial.io/admin/login 2>&1)

# Check if page loaded
if echo "$LOGIN_PAGE" | grep -q "admin" ; then
    echo "✅ Login page loaded successfully"
else
    echo "❌ Failed to load login page"
    exit 1
fi

# Step 2: Extract CSRF token
CSRF=$(echo "$LOGIN_PAGE" | grep -o 'csrf-token" content="[^"]*"' | cut -d'"' -f4)
echo "CSRF Token: ${CSRF:0:20}..."

# Step 3: Try login with empty/wrong credentials first
echo ""
echo "[2] Testing login POST (should not get 419)..."
RESPONSE=$(curl -s -L -w "\nHTTP_CODE:%{http_code}" \
    -b /tmp/test_cookies.txt \
    -c /tmp/test_cookies.txt \
    -X POST \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "email=test@test.com" \
    -d "password=wrongpass" \
    https://mediaprosocial.io/admin/login 2>&1)

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d':' -f2)

echo "Response Code: $HTTP_CODE"

if [ "$HTTP_CODE" = "419" ]; then
    echo ""
    echo "❌❌❌ STILL GETTING 419 ERROR ❌❌❌"
    echo "CSRF protection is still blocking the request"
    exit 1
elif [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ] || [ "$HTTP_CODE" = "422" ]; then
    echo ""
    echo "✅✅✅ SUCCESS! NO 419 ERROR! ✅✅✅"
    echo "Code $HTTP_CODE means:"
    if [ "$HTTP_CODE" = "422" ]; then
        echo "  - Validation error (wrong credentials) - This is EXPECTED and GOOD!"
    elif [ "$HTTP_CODE" = "302" ]; then
        echo "  - Redirect - checking authentication"
    else
        echo "  - Processing login request"
    fi
    echo ""
    echo "The 419 Page Expired error is FIXED!"
else
    echo "Unexpected code: $HTTP_CODE"
fi

echo ""
echo "========================================="
echo "Test Complete"
echo "========================================="
