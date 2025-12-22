#!/bin/bash

# 🔐 سكريبت تحديث OAuth Credentials
# استخدم هذا السكريبت لتحديث الـ credentials بسرعة

echo "🔐 تحديث OAuth Credentials"
echo "================================"
echo ""

# تفاصيل الاتصال
SERVER="u126213189@82.25.83.217"
PORT="65002"
PASSWORD="Alenwanapp33510421@"
ENV_PATH="/home/u126213189/domains/mediaprosocial.io/public_html/.env"

# دالة لتحديث قيمة في .env
update_env_value() {
    local key=$1
    local value=$2

    echo "📝 تحديث $key..."

    # استخدام sed لتحديث القيمة
    plink -batch -P $PORT -pw "$PASSWORD" $SERVER "sed -i 's/^${key}=.*/${key}=${value}/' $ENV_PATH 2>&1"

    if [ $? -eq 0 ]; then
        echo "✅ تم تحديث $key بنجاح"
    else
        echo "❌ فشل تحديث $key"
    fi
}

# دالة لمسح الكاش
clear_cache() {
    echo ""
    echo "🧹 مسح الكاش..."
    plink -batch -P $PORT -pw "$PASSWORD" $SERVER "cd /home/u126213189/domains/mediaprosocial.io/public_html && php artisan config:clear && php artisan cache:clear && php artisan route:clear 2>&1"
    echo "✅ تم مسح الكاش"
}

# القائمة الرئيسية
echo "اختر المنصة التي تريد تحديثها:"
echo ""
echo "1. Facebook"
echo "2. Instagram"
echo "3. LinkedIn"
echo "4. Twitter/X"
echo "5. Google/YouTube"
echo "6. TikTok"
echo "7. Snapchat"
echo "8. تحديث جميع المنصات"
echo "9. عرض القيم الحالية"
echo "0. خروج"
echo ""
read -p "اختر رقم (0-9): " choice

case $choice in
    1)
        echo ""
        echo "📘 Facebook OAuth"
        read -p "أدخل Facebook Client ID: " fb_id
        read -p "أدخل Facebook Client Secret: " fb_secret
        update_env_value "FACEBOOK_CLIENT_ID" "$fb_id"
        update_env_value "FACEBOOK_CLIENT_SECRET" "$fb_secret"
        clear_cache
        ;;
    2)
        echo ""
        echo "📸 Instagram OAuth"
        read -p "أدخل Instagram Client ID: " ig_id
        read -p "أدخل Instagram Client Secret: " ig_secret
        update_env_value "INSTAGRAM_CLIENT_ID" "$ig_id"
        update_env_value "INSTAGRAM_CLIENT_SECRET" "$ig_secret"
        clear_cache
        ;;
    3)
        echo ""
        echo "💼 LinkedIn OAuth"
        read -p "أدخل LinkedIn Client ID: " li_id
        read -p "أدخل LinkedIn Client Secret: " li_secret
        update_env_value "LINKEDIN_CLIENT_ID" "$li_id"
        update_env_value "LINKEDIN_CLIENT_SECRET" "$li_secret"
        clear_cache
        ;;
    4)
        echo ""
        echo "🐦 Twitter/X OAuth"
        read -p "أدخل Twitter Client ID (API Key): " tw_id
        read -p "أدخل Twitter Client Secret (API Secret): " tw_secret
        update_env_value "TWITTER_CLIENT_ID" "$tw_id"
        update_env_value "TWITTER_CLIENT_SECRET" "$tw_secret"
        clear_cache
        ;;
    5)
        echo ""
        echo "🎥 Google/YouTube OAuth"
        read -p "أدخل Google Client ID: " g_id
        read -p "أدخل Google Client Secret: " g_secret
        update_env_value "GOOGLE_CLIENT_ID" "$g_id"
        update_env_value "GOOGLE_CLIENT_SECRET" "$g_secret"
        clear_cache
        ;;
    6)
        echo ""
        echo "🎵 TikTok OAuth"
        read -p "أدخل TikTok Client ID: " tt_id
        read -p "أدخل TikTok Client Secret: " tt_secret
        update_env_value "TIKTOK_CLIENT_ID" "$tt_id"
        update_env_value "TIKTOK_CLIENT_SECRET" "$tt_secret"
        clear_cache
        ;;
    7)
        echo ""
        echo "👻 Snapchat OAuth"
        read -p "أدخل Snapchat Client ID: " sc_id
        read -p "أدخل Snapchat Client Secret: " sc_secret
        update_env_value "SNAPCHAT_CLIENT_ID" "$sc_id"
        update_env_value "SNAPCHAT_CLIENT_SECRET" "$sc_secret"
        clear_cache
        ;;
    8)
        echo ""
        echo "🌐 تحديث جميع المنصات"
        echo "هذا سيطلب منك إدخال credentials لجميع المنصات"
        echo ""

        # Facebook
        read -p "Facebook Client ID: " fb_id
        read -p "Facebook Client Secret: " fb_secret

        # Instagram
        read -p "Instagram Client ID: " ig_id
        read -p "Instagram Client Secret: " ig_secret

        # LinkedIn
        read -p "LinkedIn Client ID: " li_id
        read -p "LinkedIn Client Secret: " li_secret

        # Twitter
        read -p "Twitter Client ID: " tw_id
        read -p "Twitter Client Secret: " tw_secret

        # Google
        read -p "Google Client ID: " g_id
        read -p "Google Client Secret: " g_secret

        echo ""
        echo "📝 جاري التحديث..."

        update_env_value "FACEBOOK_CLIENT_ID" "$fb_id"
        update_env_value "FACEBOOK_CLIENT_SECRET" "$fb_secret"
        update_env_value "INSTAGRAM_CLIENT_ID" "$ig_id"
        update_env_value "INSTAGRAM_CLIENT_SECRET" "$ig_secret"
        update_env_value "LINKEDIN_CLIENT_ID" "$li_id"
        update_env_value "LINKEDIN_CLIENT_SECRET" "$li_secret"
        update_env_value "TWITTER_CLIENT_ID" "$tw_id"
        update_env_value "TWITTER_CLIENT_SECRET" "$tw_secret"
        update_env_value "GOOGLE_CLIENT_ID" "$g_id"
        update_env_value "GOOGLE_CLIENT_SECRET" "$g_secret"

        clear_cache
        echo ""
        echo "✅ تم تحديث جميع المنصات!"
        ;;
    9)
        echo ""
        echo "📋 القيم الحالية:"
        echo "================================"
        plink -batch -P $PORT -pw "$PASSWORD" $SERVER "cat $ENV_PATH | grep -E '(CLIENT_ID|CLIENT_SECRET)' 2>&1"
        ;;
    0)
        echo "👋 وداعاً!"
        exit 0
        ;;
    *)
        echo "❌ اختيار غير صحيح"
        exit 1
        ;;
esac

echo ""
echo "✅ تم بنجاح!"
echo ""
echo "🔄 الخطوات التالية:"
echo "1. افتح التطبيق على هاتفك"
echo "2. اذهب إلى إعدادات > ربط الحسابات"
echo "3. اضغط على المنصة التي قمت بتحديثها"
echo "4. سجل دخول ووافق على الصلاحيات"
echo ""
