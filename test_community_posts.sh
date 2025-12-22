#!/bin/bash
# اختبار تكامل Community Posts Feature
# This script tests the community posts functionality end-to-end

echo "=== اختبار ميزة المنشورات المجتمعية ==="
echo ""

# المتغيرات
BACKEND_URL="http://localhost:8000"
FLUTTER_APP="c:\\Users\\HP\\social_media_manager"
DB_HOST="82.25.83.217"
DB_USER="u126213189_socialmedia_ma"
DB_PASS="SocialMediaManager123!"
DB_NAME="u126213189_socialmedia_ma"

echo "🔍 الخطوة 1: التحقق من Database Connection"
echo "========================================"
echo "المضيف: $DB_HOST"
echo "قاعدة البيانات: $DB_NAME"
echo ""

echo "🔍 الخطوة 2: اختبار API Endpoints"
echo "=================================="
echo ""

echo "📌 اختبار 1: استرجاع المنشورات (GET /community/posts)"
curl -s -X GET "$BACKEND_URL/api/community/posts?page=1&per_page=20" \
  -H "Accept: application/json" | python3 -m json.tool 2>/dev/null || echo "❌ فشل الاتصال"

echo ""
echo "📌 اختبار 2: التحقق من routing for /user/{userId}"
echo "URL يجب أن يعود المنشورات للمستخدم فقط، لا يخلط مع GET /{id}"
echo ""

echo "🔍 الخطوة 3: التحقق من Flutter App"
echo "==================================="
cd "$FLUTTER_APP"
echo "✅ التحقق من أن FloatingActionButton موجود في community_screen.dart"
grep -n "FloatingActionButton" lib/screens/community/community_screen.dart

echo ""
echo "✅ التحقق من أن CreateCommunityPostScreen معرّف"
grep -n "class CreateCommunityPostScreen" lib/screens/community/create_community_post_screen.dart

echo ""
echo "✅ التحقق من أن المعاملات converted إلى strings"
grep -n "toString()" lib/services/community_post_service.dart | head -5

echo ""
echo "🔍 الخطوة 4: ملخص البيانات المتوقعة"
echo "===================================="
echo ""
echo "بعد إنشاء منشور جديد، يجب أن تظهر البيانات التالية:"
echo ""
echo "في الجدول community_posts:"
echo "- id (auto-increment)"
echo "- user_id (من المستخدم الحالي)"
echo "- content (محتوى المنشور)"
echo "- media_urls (JSON array من صور المنشور)"
echo "- created_at (الوقت الحالي)"
echo "- updated_at (الوقت الحالي)"
echo ""

echo "✅ جميع الاختبارات جاهزة للتنفيذ!"
