#!/bin/bash
# سكريبت نشر نظام Analytics على السيرفر
# Deploy Analytics System to Server

echo "🚀 بدء نشر نظام Analytics..."
echo "================================"

# التأكد من المسار
cd /home/u126213189/domains/mediaprosocial.io/public_html || exit

# 1. فك الضغط
echo ""
echo "📦 فك ضغط الملفات..."
tar -xzf analytics_tracking_system.tar.gz

if [ $? -eq 0 ]; then
    echo "✅ تم فك الضغط بنجاح"
else
    echo "❌ فشل فك الضغط"
    exit 1
fi

# 2. التحقق من الملفات
echo ""
echo "🔍 التحقق من الملفات..."
if [ -f "app/Models/Subscription.php" ]; then
    echo "✅ Subscription.php موجود"
else
    echo "❌ Subscription.php غير موجود"
fi

if [ -f "app/Http/Controllers/Api/AnalyticsController.php" ]; then
    echo "✅ AnalyticsController.php موجود"
else
    echo "❌ AnalyticsController.php غير موجود"
fi

if [ -f "app/Http/Middleware/TrackUsage.php" ]; then
    echo "✅ TrackUsage.php موجود"
else
    echo "❌ TrackUsage.php غير موجود"
fi

# 3. تشغيل Migrations
echo ""
echo "⚙️ تشغيل Migrations..."
php artisan migrate --force

if [ $? -eq 0 ]; then
    echo "✅ Migrations تمت بنجاح"
else
    echo "❌ فشلت Migrations"
    exit 1
fi

# 4. مسح Cache
echo ""
echo "🧹 مسح Cache..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

echo "✅ تم مسح Cache"

# 5. إعادة بناء Cache
echo ""
echo "🔨 إعادة بناء Cache..."
php artisan config:cache
php artisan route:cache

echo "✅ تم إعادة بناء Cache"

# 6. التحقق من Routes
echo ""
echo "🛣️ التحقق من Routes..."
php artisan route:list | grep analytics

# 7. التحقق من Database
echo ""
echo "🗄️ التحقق من Database..."
php artisan tinker --execute="echo Schema::hasColumn('subscriptions', 'current_posts_count') ? '✅ current_posts_count موجود' : '❌ current_posts_count غير موجود'; echo PHP_EOL;"
php artisan tinker --execute="echo Schema::hasColumn('users', 'connected_accounts_count') ? '✅ connected_accounts_count موجود' : '❌ connected_accounts_count غير موجود'; echo PHP_EOL;"

# 8. حذف الأرشيف
echo ""
echo "🧹 حذف الأرشيف..."
rm -f analytics_tracking_system.tar.gz
echo "✅ تم حذف الأرشيف"

# 9. التحقق من الصلاحيات
echo ""
echo "🔐 التحقق من الصلاحيات..."
chmod -R 755 storage bootstrap/cache
echo "✅ تم ضبط الصلاحيات"

# النهاية
echo ""
echo "================================"
echo "🎉 اكتمل النشر بنجاح!"
echo ""
echo "📊 الخطوات القادمة:"
echo "1. افتح https://mediaprosocial.io/api/analytics/usage"
echo "2. تحقق من استجابة API"
echo "3. افتح التطبيق واختبر Analytics Screen"
echo ""
echo "✅ نظام Analytics جاهز للعمل!"
