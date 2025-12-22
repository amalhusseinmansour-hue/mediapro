@echo off
echo ========================================
echo MediaPro Social - Post-Removal Testing
echo ========================================
echo.

echo [1/5] Checking Flutter environment...
call flutter doctor -v
echo.

echo [2/5] Cleaning Flutter project...
call flutter clean
echo.

echo [3/5] Getting dependencies...
call flutter pub get
echo.

echo [4/5] Running Flutter analyze...
call flutter analyze
echo.

echo [5/5] Checking for import errors...
echo If you see errors about gamification_service or laravel_community_service,
echo that's expected - they've been removed!
echo.

echo ========================================
echo Testing Complete!
echo ========================================
echo.
echo Next Steps:
echo 1. If no critical errors, try: flutter run
echo 2. Setup Telegram Bot (see TELEGRAM_BOT_SETUP.md)
echo 3. Replace main.dart with main_simplified.dart
echo.

pause
