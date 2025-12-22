# =€ /DJD 'D1A9 H'DF41 'D4'ED
# Comprehensive Deployment Guide

## =Ë ,/HD 'DE-*HJ'*

1. ['DE*7D('* 'D#3'3J)](#'DE*7D('*-'D#3'3J))
2. ['D*-6J1 DDF41](#'D*-6J1-DDF41)
3. [F41 Backend (Laravel)](#F41-backend-laravel)
4. [F41 Flutter App](#F41-flutter-app)
5. ['D'.*('1 (9/ 'DF41](#'D'.*('1-(9/-'DF41)
6. ['3*C4'A 'D#.7'!](#'3*C4'A-'D#.7'!)

---

## <¯ 'DE*7D('* 'D#3'3J)

### 9DI ,G'2C 'DE-DJ
-  PuTTY E+(* (pscp H plink)
-  Git Bash #H Command Prompt
-  Flutter SDK
-  Composer
-  E9DHE'* 'D'*5'D ('D3J1A1

### 9DI 'D3J1A1
-  PHP >= 8.2
-  Composer
-  MySQL/MariaDB
-  Node.js ('.*J'1J)
-  SSL Certificate (DD@ HTTPS)

### E9DHE'* 'D3J1A1
```
Host: 82.25.83.217
Port: 65002
User: u126213189
Domain: mediaprosocial.io
Path: /home/u126213189/domains/mediaprosocial.io/public_html
```

---

## =' 'D*-6J1 DDF41

### 1. E1',9) 'D#E'F
B(D #J 4J! 1',9 EDA `SECURITY_NOTES.md` H'D*#C/ EF:

- [ ] *-/J+ `APP_ENV=production`
- [ ] *-/J+ `APP_DEBUG=false`
- [ ] *-/J+ `LOG_LEVEL=error`
- [ ] E1',9) CORS settings
- [ ] E1',9) Rate Limiting settings
- [ ] *,GJ2 API keys ,/J/) DD@ production

### 2. *-/J+ 'D%9/'/'*

#### Backend .env
```bash
cd backend
cp .env.example .env
nano .env  # #H '3*./E #J E-11 F5H5
```

*#C/ EF *-/J+:
```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://mediaprosocial.io

DB_DATABASE=your_production_db
DB_USERNAME=your_production_user
DB_PASSWORD=your_production_password

# Update all API keys with production credentials
TWILIO_ACCOUNT_SID=your_production_sid
TWILIO_AUTH_TOKEN=your_production_token
PAYMOB_API_KEY=your_production_key
# ... etc
```

#### Flutter App
*-/J+ `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'https://mediaprosocial.io/api';
static const bool isProduction = true;
```

### 3. '.*('1 E-DJ
B(D 'D1A9 *#C/ EF 9ED CD 4J! E-DJ'K:

```bash
# Backend
cd backend
php artisan test
php artisan serve

# Flutter
cd ..
flutter analyze
flutter test
flutter run
```

---

## =€ F41 Backend (Laravel)

### 71JB) 1: '3*./'E 'D3C1J(* 'D*DB'&J (EH5I (G)

#### 9DI Windows:
```bash
# 'A*- Command Prompt AJ E,D/ 'DE41H9
deploy_backend.bat
```

#### 9DI Linux/Mac:
```bash
# 'A*- Terminal AJ E,D/ 'DE41H9
chmod +x deploy_backend.sh
./deploy_backend.sh
```

'D3C1J(* 3JBHE (@:
1.  %F4'! #14JA EF EDA'* Backend
2.  1A9 'D#14JA 9DI 'D3J1A1
3.  AC 6:7 'DEDA'*
4.  *+(J* dependencies
5.  *4:JD migrations
6.  9ED cache DD@ config
7.  6(7 'D5D'-J'*
8.  'D*F8JA H'D*-BB

### 71JB) 2: 'D1A9 'DJ/HJ

#### 'D.7H) 1: %F4'! 'D#14JA
```bash
cd backend
tar -czf ../backend_deployment.tar.gz \
    --exclude='.env' \
    --exclude='node_modules' \
    --exclude='vendor' \
    --exclude='storage/logs/*' \
    --exclude='.git' \
    .
cd ..
```

#### 'D.7H) 2: 1A9 9DI 'D3J1A1
```bash
"C:\Program Files\PuTTY\pscp" -P 65002 -pw "PASSWORD" \
    backend_deployment.tar.gz \
    u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/
```

#### 'D.7H) 3: AC 'D6:7 H%9/'/ 'D3J1A1
```bash
"C:\Program Files\PuTTY\plink" -batch -P 65002 -pw "PASSWORD" \
    u126213189@82.25.83.217
```

(9/ 'D'*5'D ('D3J1A1:
```bash
cd /home/u126213189/domains/mediaprosocial.io/public_html

# AC 6:7 'DEDA'*
tar -xzf backend_deployment.tar.gz

# *+(J* dependencies
composer install --no-dev --optimize-autoloader

# F3. EDA 'D(J&)
cp .env.example .env
nano .env  # BE (*-/J+ 'D%9/'/'*

# *HDJ/ Application Key
php artisan key:generate

# 6(7 'D5D'-J'*
chmod -R 755 storage bootstrap/cache
chmod -R 775 storage/logs
chown -R www-data:www-data storage bootstrap/cache

# *4:JD migrations
php artisan migrate --force

# 9ED cache
php artisan config:cache
php artisan route:cache
php artisan view:cache

# %F4'! storage link
php artisan storage:link

# 'D*F8JA
rm backend_deployment.tar.gz
```

### 'D.7H) 4: 'D*-BB EF 'DF41
```bash
# '.*('1 Laravel
php artisan --version
php artisan route:list

# '.*('1 API
curl https://mediaprosocial.io/api/health
```

---

## =ñ F41 Flutter App

### 1. (F'! 'D*7(JB DD%F*',

#### Android APK
```bash
# *F8JA 'D(F'! 'D3'(B
flutter clean
flutter pub get

# (F'! APK
flutter build apk --release

# APK EH,H/ AJ:
# build/app/outputs/flutter-apk/app-release.apk
```

#### Android App Bundle (DD@ Google Play)
```bash
flutter build appbundle --release

# Bundle EH,H/ AJ:
# build/app/outputs/bundle/release/app-release.aab
```

#### iOS (9DI Mac AB7)
```bash
flutter build ios --release

# (9/ 0DC 'A*- Xcode:
open ios/Runner.xcworkspace
# +E Archive EF Xcode
```

### 2. '.*('1 APK
```bash
# *+(J* 9DI ,G'2 A9DJ
adb install build/app/outputs/flutter-apk/app-release.apk

# #H F3. 'DEDA J/HJ'K
copy "build\app\outputs\flutter-apk\app-release.apk" "SocialMediaManager_v1.0.apk"
```

### 3. 1A9 9DI Play Store

#### 'D*-6J1:
1. %F4'! -3'( Google Play Console
2. /A9 13HE 'D*3,JD ($25)
3. %9/'/ Store Listing
4. *-6J1 Screenshots
5. C*'() 'DH5A

#### 'D1A9:
1. /.HD 9DI Play Console
2. %F4'! *7(JB ,/J/
3. 1A9 App Bundle (app-release.aab)
4. ED! E9DHE'* 'D*7(JB
5. %13'D DDE1',9)

---

##  'D'.*('1 (9/ 'DF41

### 1. '.*('1 Backend API

#### Health Check
```bash
curl https://mediaprosocial.io/api/health
```

'D'3*,'() 'DE*HB9):
```json
{
  "status": "ok",
  "timestamp": "2025-11-11T10:30:00Z"
}
```

#### '.*('1 Authentication
```bash
# Register
curl -X POST https://mediaprosocial.io/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@test.com","password":"password123"}'

# Login
curl -X POST https://mediaprosocial.io/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"password123"}'
```

#### '.*('1 Subscription Plans
```bash
curl https://mediaprosocial.io/api/subscription-plans
```

### 2. '.*('1 Flutter App

B'&E) 'D'.*('1'*:
- [ ] *3,JD 'D/.HD
- [ ] %F4'! -3'( ,/J/
- [ ] OTP verification
- [ ] 916 ('B'* 'D'4*1'C
- [ ] 1(7 -3'('* 'D3H4'D EJ/J'
- [ ] %F4'! EF4H1
- [ ] ,/HD) EF4H1 *DB'&J
- [ ] 916 'DE-A8)
- [ ] 4-F 'DE-A8)
- [ ] EHD/'* 'D@ AI
- [ ] 'D%49'1'* Push
- [ ] 'DE,*E9 (Groups & Events)

### 3. E1'B() 'D#/'!

#### 9DI 'D3J1A1:
```bash
# E1'B() logs
tail -f storage/logs/laravel.log

# E1'B() CPU & Memory
top
htop

# E1'B() Database
mysql -u user -p
> SHOW PROCESSLIST;
```

#### EF 'D@ App:
- Firebase Analytics
- Crashlytics
- Performance Monitoring

---

## = '3*C4'A 'D#.7'!

### E4'CD Backend

#### .7# 500 - Internal Server Error
```bash
# 'A-5 logs
tail -100 storage/logs/laravel.log

# *#C/ EF 'D5D'-J'*
chmod -R 755 storage bootstrap/cache

# 'E3- 'D@ cache
php artisan config:clear
php artisan cache:clear
php artisan view:clear
```

#### .7# 404 - Not Found
```bash
# *#C/ EF .htaccess
# J,( #F JCHF AJ public/

# #9/ cache 'D@ routes
php artisan route:clear
php artisan route:cache
```

#### .7# Database Connection
```bash
# *#C/ EF .env
cat .env | grep DB_

# '.*(1 'D'*5'D
php artisan tinker
> DB::connection()->getPdo();
```

#### .7# CORS
```bash
# 'A-5 config/cors.php
# *#C/ EF 'D3E'- D@ domain 'D*7(JB

# 'E3- 'D@ config cache
php artisan config:clear
php artisan config:cache
```

### E4'CD Flutter App

#### .7# API Connection
```dart
// *#C/ EF baseUrl AJ app_constants.dart
static const String baseUrl = 'https://mediaprosocial.io/api';

// A9QD debug mode E$B*'K D1$J) 'D#.7'!
dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
));
```

#### .7# Build
```bash
# F8A 'D(F'!
flutter clean
rm -rf build/

# '-0A pubspec.lock
rm pubspec.lock

# #9/ 'D*+(J*
flutter pub get

# #9/ 'D(F'!
flutter build apk --release
```

#### E4'CD Firebase
```bash
# *#C/ EF *CHJF Firebase
flutter pub run firebase_tools:init

# #9/ *CHJF FlutterFire
flutterfire configure --project=mediapro-77297
```

---

## =Ê 'DE1'B() H'D5J'F)

### JHEJ'K
- [ ] E1',9) logs DD#.7'!
- [ ] E1'B() #/'! 'D3J1A1
- [ ] 'D*-BB EF API uptime

### #3(H9J'K
- [ ] Backup DD@ Database
- [ ] E1',9) Firebase Usage
- [ ] E1',9) API Analytics

### 4G1J'K
- [ ] *-/J+ Dependencies
- [ ] E1',9) Security
- [ ] */HJ1 API Keys
- [ ] E1',9) Costs

---

## =Þ 'D/9E H'DE3'9/)

### 'DEH'1/
- [Laravel Documentation](https://laravel.com/docs)
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)

### AJ -'D) 'DE4'CD
1. 1',9 `PRODUCTION_READINESS_REPORT.md`
2. 1',9 `SECURITY_NOTES.md`
3. 'A-5 logs 9DI 'D3J1A1
4. 1',9 Firebase Console
5. '3*./E Flutter DevTools

---

## ( F5'&- DDF,'-

### 'D#E'F
- = D' *4'1C EDA `.env` #(/'K
- = /HQ1 API keys ('F*8'E
- =á '3*./E HTTPS /'&E'K
- = A9QD 2FA DD-3'('* 'D-3'3)

### 'D#/'!
- ¡ '3*./E Laravel Cache
- =Ä A9QD Database Indexing
- < '3*./E CDN DD@ Assets
- =Ê 1'B( 'D#/'! ('3*E1'1

### 'DEH+HBJ)
- =¾ Backup JHEJ DD@ Database
- =Ý '-*A8 (@ logs DE/) 30 JHE
- = '.*(1 9EDJ) 'D@ Restore
- =¨ A9QD Monitoring & Alerts

---

## <‰ E(1HC!

%0' H5D* GF' A#F* 'D"F ,'G2 D%7D'B *7(JBC! =€

*0C1:
- '(/# (@ Soft Launch (9// E-/H/ EF 'DE3*./EJF)
- 1'B( 'D#/'! H'D#.7'!
- ',E9 feedback EF 'DE3*./EJF
- -3QF H'7DB 'DF3.) 'DC'ED)

**Good Luck! <@**

---

**".1 *-/J+:** 2025-11-11
**'D%5/'1:** 1.0
***E %F4'$G (H'37):** Claude Code Deployment Assistant
