# = Security Notes - ED'-8'* #EFJ) EGE)

##   %,1'!'* #EFJ) 9',D) B(D 'DF41

### 1. */HJ1 (J'F'* 'D'9*E'/ (Rotate Credentials)

**J,( 9DJC *:JJ1 ,EJ9 (J'F'* 'D'9*E'/ 'D*'DJ) B(D F41 'D*7(JB:**

#### = Laravel Application Key
```bash
php artisan key:generate
```

#### =ñ Twilio Credentials
- *3,JD 'D/.HD %DI: https://console.twilio.com
- %F4'! E41H9 ,/J/ #H */HJ1 'DEA'*J- 'D-'DJ)
- *-/J+ AJ `.env`:
  - `TWILIO_ACCOUNT_SID`
  - `TWILIO_AUTH_TOKEN`
  - `TWILIO_FROM_NUMBER`

#### =³ Paymob Credentials
- *3,JD 'D/.HD %DI: https://accept.paymob.com
- 'D'F*B'D %DI Settings ’ API Keys
- %F4'! EA'*J- ,/J/)
- *-/J+ AJ `.env`:
  - `PAYMOB_API_KEY`
  - `PAYMOB_PUBLIC_KEY`
  - `PAYMOB_SECRET_KEY`
  - `PAYMOB_HMAC_SECRET`
  - `PAYMOB_INTEGRATION_ID`
  - `PAYMOB_IFRAME_ID`

#### =% Firebase Configuration
- *3,JD 'D/.HD %DI: https://console.firebase.google.com
- %F4'! E41H9 ,/J/ #H *-/J+ 'DBH'9/ 'D#EFJ)
- *-/J+ EDA'*:
  - `lib/firebase_options.dart`
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`

#### =Ä Database Credentials
- **EGE ,/'K**: *:JJ1 CDE) E1H1 B'9/) 'D(J'F'*
- *-/J+ AJ `.env`:
  - `DB_PASSWORD`

#### =° Payment Gateways ('.*J'1J)
- Stripe: https://dashboard.stripe.com
- PayPal: https://developer.paypal.com

#### > AI Services ('.*J'1J)
- OpenAI: https://platform.openai.com/api-keys
- Google Gemini: https://makersuite.google.com/app/apikey

---

## =Ë B'&E) 'D*-BB 'D#EFJ)

### B(D 'D1A9 9DI 'D3J1A1
- [ ] *-/J+ `APP_ENV=production` AJ `.env`
- [ ] *-/J+ `APP_DEBUG=false` AJ `.env`
- [ ] *-/J+ `LOG_LEVEL=error` AJ `.env`
- [ ] 'D*#C/ EF CORS E-// DD/HEJF'* 'DE3EH-) AB7
- [ ] 'D*#C/ EF Rate Limiting EA9D 9DI ,EJ9 'D@ API routes
- [ ] E1',9) `.gitignore` DD*#C/ EF 9/E 1A9 `.env`

### (9/ 'D1A9 9DI 'D3J1A1
- [ ] *4:JD `php artisan key:generate` 9DI 'D3J1A1
- [ ] *4:JD `php artisan config:cache`
- [ ] *4:JD `php artisan route:cache`
- [ ] *4:JD `php artisan view:cache`
- [ ] 6(7 5D'-J'* 'DE,D/'*:
  ```bash
  chmod -R 755 storage bootstrap/cache
  chown -R www-data:www-data storage bootstrap/cache
  ```

### 'DE1'B() 'DE3*E1)
- [ ] E1'B() logs (4CD /H1J: `storage/logs/laravel.log`
- [ ] E1',9) Firebase Security Rules 4G1J'K
- [ ] *-/J+ 'DEC*('* H'D@ dependencies /H1J'K
- [ ] 9ED Backup DD@ Database JHEJ'K
- [ ] E1',9) API rate limit logs

---

## =¨ ED'-8'* G'E)

### -E'J) 'D@ API Keys
1. **D' *4'1C** EDA `.env` E9 #J 4.5
2. **D' *1A9** EDA `.env` 9DI GitHub #H #J version control
3. '3*./E **Environment Variables** 9DI 'D3J1A1
4. '3*./E **Secrets Management** DDE4'1J9 'DC(J1) (AWS Secrets Manager, HashiCorp Vault)

### Firebase Security Rules
*#C/ EF *-/J+ Firebase Security Rules D-E'J) 'D(J'F'*:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // E+'D: 'D3E'- AB7 DDE3*./EJF 'DE5'/B 9DJGE
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Rate Limiting 'D-'DJ
- **Authentication Routes**: 5 requests/minute
- **OTP Routes**: 3 requests/minute
- **Public Submission**: 5 requests/minute
- **Subscription Plans**: 60 requests/minute
- **Authenticated Routes**: 120 requests/minute

**JECFC *9/JDG' AJ:** `backend/routes/api.php`

### CORS 'D-'DJ
'DEH'B9 'DE3EH- DG' ('DH5HD DD@ API:
- https://www.mediapro.social
- https://mediapro.social
- https://mediaprosocial.io
- https://www.mediaprosocial.io

**JECFC *9/JDG' AJ:** `backend/config/cors.php`

---

## =Þ AJ -'D) '.*1'B #EFJ

### 'D.7H'* 'DAH1J):
1. **%JB'A 'D*7(JB AH1'K**
   ```bash
   php artisan down --secret="your-secret-key"
   ```

2. ***:JJ1 ,EJ9 (J'F'* 'D'9*E'/**
   - Database passwords
   - API keys (Twilio, Paymob, Firebase)
   - Application key

3. **E1',9) Logs**
   ```bash
   tail -f storage/logs/laravel.log
   ```

4. **%9'/) F41 'D*7(JB**
   ```bash
   php artisan up
   ```

5. **%.7'1 'DE3*./EJF** (%0' *E *31J( (J'F'* -3'3))

---

## =Ú EH'1/ %6'AJ)

- [Laravel Security Best Practices](https://laravel.com/docs/11.x/security)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Firebase Security Rules Guide](https://firebase.google.com/docs/rules)
- [Twilio Security Best Practices](https://www.twilio.com/docs/usage/security)

---

##  *E *7(JB 'D%,1'!'* 'D#EFJ) 'D*'DJ)

-  *-/J+ `APP_ENV=production`
-  *-/J+ `APP_DEBUG=false`
-  *-/J+ `LOG_LEVEL=error`
-  *#EJF CORS (E-// DD/HEJF'* 'DE3EH-) AB7)
-  %6'A) Rate Limiting 9DI ,EJ9 'D@ API routes
-  %F4'! `.env.example` (/HF (J'F'* -3'3)
-  %5D'- .7# duplicate definition AJ 'DCH/

---

**".1 *-/J+:** 2025-11-11
***E %F4'$G (H'37):** Claude Code Security Audit
