#!/bin/bash

# ==================================
# سكريبت اختبار API Keys
# ==================================

echo "🔍 فحص API Keys لمنصات السوشال ميديا..."
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counter
TOTAL=0
CONFIGURED=0
MISSING=0

check_key() {
    local key_name=$1
    local key_value=$2
    TOTAL=$((TOTAL + 1))

    if [ -z "$key_value" ] || [ "$key_value" = "your_"* ] || [ "$key_value" = "null" ]; then
        echo -e "${RED}❌ $key_name${NC} - غير مُعد"
        MISSING=$((MISSING + 1))
        return 1
    else
        echo -e "${GREEN}✅ $key_name${NC} - مُعد"
        CONFIGURED=$((CONFIGURED + 1))
        return 0
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📱 FACEBOOK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_key "FACEBOOK_APP_ID" "$FACEBOOK_APP_ID"
check_key "FACEBOOK_APP_SECRET" "$FACEBOOK_APP_SECRET"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📷 INSTAGRAM"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_key "INSTAGRAM_CLIENT_ID" "$INSTAGRAM_CLIENT_ID"
check_key "INSTAGRAM_CLIENT_SECRET" "$INSTAGRAM_CLIENT_SECRET"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🐦 TWITTER / X"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_key "TWITTER_API_KEY" "$TWITTER_API_KEY"
check_key "TWITTER_API_SECRET" "$TWITTER_API_SECRET"
check_key "TWITTER_BEARER_TOKEN" "$TWITTER_BEARER_TOKEN"
check_key "TWITTER_CLIENT_ID" "$TWITTER_CLIENT_ID"
check_key "TWITTER_CLIENT_SECRET" "$TWITTER_CLIENT_SECRET"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💼 LINKEDIN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_key "LINKEDIN_CLIENT_ID" "$LINKEDIN_CLIENT_ID"
check_key "LINKEDIN_CLIENT_SECRET" "$LINKEDIN_CLIENT_SECRET"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎥 YOUTUBE / GOOGLE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_key "YOUTUBE_CLIENT_ID" "$YOUTUBE_CLIENT_ID"
check_key "YOUTUBE_CLIENT_SECRET" "$YOUTUBE_CLIENT_SECRET"
check_key "GOOGLE_CLIENT_ID" "$GOOGLE_CLIENT_ID"
check_key "GOOGLE_CLIENT_SECRET" "$GOOGLE_CLIENT_SECRET"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎵 TIKTOK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_key "TIKTOK_APP_ID" "$TIKTOK_APP_ID"
check_key "TIKTOK_APP_SECRET" "$TIKTOK_APP_SECRET"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "👻 SNAPCHAT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_key "SNAPCHAT_CLIENT_ID" "$SNAPCHAT_CLIENT_ID"
check_key "SNAPCHAT_CLIENT_SECRET" "$SNAPCHAT_CLIENT_SECRET"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 النتيجة النهائية"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "إجمالي المتغيرات: ${YELLOW}$TOTAL${NC}"
echo -e "مُعدة: ${GREEN}$CONFIGURED${NC}"
echo -e "غير مُعدة: ${RED}$MISSING${NC}"
echo ""

PERCENTAGE=$((CONFIGURED * 100 / TOTAL))
echo -e "نسبة الاكتمال: ${YELLOW}$PERCENTAGE%${NC}"
echo ""

if [ $MISSING -eq 0 ]; then
    echo -e "${GREEN}🎉 جميع API Keys مُعدة بشكل صحيح!${NC}"
    exit 0
elif [ $PERCENTAGE -ge 70 ]; then
    echo -e "${YELLOW}⚠️  معظم API Keys مُعدة. يرجى إكمال الباقي.${NC}"
    exit 0
else
    echo -e "${RED}❌ العديد من API Keys غير مُعدة. يرجى إعدادها.${NC}"
    exit 1
fi
