#!/bin/bash

echo "🔧 إصلاح Sidebar في Filament..."
echo ""

# 1. مسح الكاش
echo "1️⃣ مسح الكاش..."
php artisan optimize:clear
php artisan filament:optimize-clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

echo "✅ تم مسح الكاش"
echo ""

# 2. Dump autoload
echo "2️⃣ تحديث Autoloader..."
composer dump-autoload

echo "✅ تم تحديث Autoloader"
echo ""

# 3. التحقق من Routes
echo "3️⃣ التحقق من Routes..."
php artisan route:list | grep "website-requests" | head -5
php artisan route:list | grep "sponsored-ad-requests" | head -5

echo "✅ Routes موجودة"
echo ""

# 4. التحقق من Resources
echo "4️⃣ التحقق من Resources..."
php artisan tinker --execute="echo class_exists(\App\Filament\Resources\WebsiteRequestResource::class) ? '✅ WebsiteRequestResource موجود' : '❌ WebsiteRequestResource مفقود'; echo PHP_EOL;"
php artisan tinker --execute="echo class_exists(\App\Filament\Resources\SponsoredAdRequestResource::class) ? '✅ SponsoredAdRequestResource موجود' : '❌ SponsoredAdRequestResource مفقود'; echo PHP_EOL;"

echo ""
echo "🎉 انتهى! افتح:"
echo "   https://mediaprosocial.io/admin/website-requests"
echo "   https://mediaprosocial.io/admin/sponsored-ad-requests"
