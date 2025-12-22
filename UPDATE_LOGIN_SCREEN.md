name: Update Login Screen with Phone Registration

on:
  workflow_dispatch:

jobs:
  update-login-screen:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Update login_screen.dart
        run: |
          echo "✅ تحديث صفحة تسجيل الدخول جاري..."
          
          # إضافة استيراد الشاشة الجديدة
          sed -i "1a import 'phone_registration_screen.dart';" lib/screens/auth/login_screen.dart

echo "تم التحديث بنجاح!"
