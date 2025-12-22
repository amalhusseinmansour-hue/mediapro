#!/bin/bash

# 🧪 سكريبت سريع لاختبار Paymob API Key
# الاستخدام: bash test_paymob_quick.sh YOUR_API_KEY

echo "🔍 اختبار Paymob API Key..."
echo "================================"

# تحقق من وجود المفتاح كمعامل
if [ -z "$1" ]; then
    echo "❌ خطأ: يجب تمرير API Key كمعامل"
    echo ""
    echo "📝 الاستخدام:"
    echo "   bash test_paymob_quick.sh YOUR_API_KEY"
    echo ""
    echo "💡 مثال:"
    echo "   bash test_paymob_quick.sh ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1..."
    exit 1
fi

API_KEY="$1"

echo "📌 API Key: ${API_KEY:0:30}..."
echo "📏 Length: ${#API_KEY} characters"
echo ""
echo "🔗 Connecting to Paymob..."
echo ""

# إرسال الطلب
RESPONSE=$(curl -s -X POST https://accept.paymob.com/api/auth/tokens \
  -H "Content-Type: application/json" \
  -d "{\"api_key\":\"$API_KEY\"}")

echo "📥 Response:"
echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
echo ""

# تحليل النتيجة
if echo "$RESPONSE" | grep -q "token"; then
    echo "✅ SUCCESS! API Key is valid"
    echo "🎉 You can now use Paymob payment"
    TOKEN=$(echo "$RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
    echo "🎫 Token: ${TOKEN:0:50}..."
elif echo "$RESPONSE" | grep -q "incorrect credentials"; then
    echo "❌ FAILED: Incorrect API Key"
    echo ""
    echo "💡 Solutions:"
    echo "   1. Check your API Key from Paymob dashboard"
    echo "   2. Make sure you're using Live mode, not Test mode"
    echo "   3. Try regenerating a new API Key"
    echo ""
    echo "🔗 Go to: https://accept.paymob.com/portal2/en/settings"
elif echo "$RESPONSE" | grep -q "403"; then
    echo "❌ FAILED: Forbidden (403)"
    echo "   Your account might not have access"
else
    echo "⚠️  UNKNOWN RESPONSE"
    echo "   Please check manually"
fi

echo ""
echo "================================"
echo "✅ Test completed"
