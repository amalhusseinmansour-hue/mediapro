#!/bin/bash

# 🎯 سكريبت تجهيز نظام OTP Firebase - تنفيذ تلقائي

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                 Firebase OTP Setup Script                      ║"
echo "║              سكريبت تجهيز نظام OTP مع Firebase                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# الألوان
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# الدوال
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# 1. تنظيف المشروع
echo -e "\n${BLUE}Step 1: تنظيف المشروع${NC}"
echo "▶▶▶ Running: flutter clean"
flutter clean
if [ $? -eq 0 ]; then
    print_success "Project cleaned successfully"
else
    print_error "Failed to clean project"
    exit 1
fi

# 2. الحصول على المكتبات
echo -e "\n${BLUE}Step 2: الحصول على المكتبات${NC}"
echo "▶▶▶ Running: flutter pub get"
flutter pub get
if [ $? -eq 0 ]; then
    print_success "Dependencies fetched successfully"
else
    print_error "Failed to fetch dependencies"
    exit 1
fi

# 3. التحقق من الملفات
echo -e "\n${BLUE}Step 3: التحقق من وجود الملفات${NC}"

FILES=(
    "lib/screens/auth/phone_registration_screen.dart"
    "lib/services/firebase_phone_auth_service.dart"
    "lib/screens/auth/firebase_otp_verification_screen.dart"
    "lib/screens/auth/login_screen.dart"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        print_success "Found: $file"
    else
        print_error "Missing: $file"
    fi
done

# 4. التحقق من Firebase
echo -e "\n${BLUE}Step 4: التحقق من Firebase${NC}"
if grep -q "firebase_core" pubspec.yaml; then
    print_success "Firebase dependencies found"
else
    print_warning "Firebase dependencies may not be installed"
fi

# 5. تشغيل التطبيق
echo -e "\n${BLUE}Step 5: تشغيل التطبيق${NC}"
echo ""
echo "الآن سيتم تشغيل التطبيق..."
echo "اختر جهاز الاختبار من القائمة أدناه:"
echo ""

flutter devices

echo ""
read -p "هل تريد تشغيل التطبيق الآن؟ (y/n): " run_app

if [ "$run_app" = "y" ]; then
    print_info "Starting application..."
    flutter run
else
    print_info "Skipped running the application"
fi

# الملخص النهائي
echo -e "\n${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    Setup Complete! 🎉                         ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"

echo ""
echo -e "${BLUE}📋 ملخص الإجراءات المنجزة:${NC}"
print_success "Project cleaned"
print_success "Dependencies fetched"
print_success "Verified essential files"
print_success "Firebase configuration checked"

echo ""
echo -e "${BLUE}🎯 الخطوات التالية:${NC}"
echo "1. تفعيل Phone Authentication في Firebase Console"
echo "2. اختبار التسجيل برقم الهاتف"
echo "3. استقبال OTP عبر SMS"
echo "4. التحقق من الرمز والدخول"

echo ""
echo -e "${BLUE}📖 الملفات المرجعية:${NC}"
echo "├─ OTP_FIREBASE_FINAL_SUMMARY.md       (الملخص الشامل)"
echo "├─ FIREBASE_OTP_COMPLETE_SOLUTION.md   (الحل الكامل)"
echo "├─ FIREBASE_OTP_QUICK_SETUP.md         (البدء السريع)"
echo "└─ FIREBASE_OTP_PHONE_REGISTRATION_FIX.md (تفاصيل الإصلاح)"

echo ""
echo -e "${YELLOW}💡 نصيحة: اقرأ OTP_FIREBASE_FINAL_SUMMARY.md أولاً${NC}"
echo ""
