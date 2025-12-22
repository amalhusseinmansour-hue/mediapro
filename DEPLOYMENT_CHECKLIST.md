═══════════════════════════════════════════════════════════════
                   DEPLOYMENT CHECKLIST
═══════════════════════════════════════════════════════════════

🟢 PRE-DEPLOYMENT CHECKLIST
───────────────────────────────────────────────────────────────
☐ All local .env fixes verified (DB_HOST, SESSION_*, COOKIE_*, CACHE_STORE)
☐ Flutter registration code fixed (auth_service.dart verified)
☐ Deployment scripts created (Deploy-Fixes.ps1, deploy_fixes.sh)
☐ SSH credentials available:
    ✓ Host: 82.25.83.217
    ✓ Port: 65002
    ✓ User: u126213189
    ✓ Password: Alenwanapp33510421@
☐ Admin credentials ready:
    ✓ Email: admin@mediapro.com / admin@example.com
    ✓ Password: Admin@12345 / password


🟡 DEPLOYMENT PHASE
───────────────────────────────────────────────────────────────

☐ STEP 1: Choose deployment method
   Option A (Recommended): PowerShell
   Option B: Manual SSH
   Option C: Git Push
   
   SELECTED METHOD: _____________________

☐ STEP 2: Execute deployment
   Command/Script: _____________________
   Time: _________ (started)
   
☐ STEP 3: Verify caches cleared
   ✓ php artisan config:clear
   ✓ php artisan cache:clear
   ✓ php artisan view:clear
   
   Status: _____________ (Completed at ______)

☐ STEP 4: Backup creation
   Backup file created: _____________________
   Date/Time: __________


🔍 POST-DEPLOYMENT TESTING
───────────────────────────────────────────────────────────────

TEST 1: Admin Login
   ☐ URL: https://mediaprosocial.io/admin/login
   ☐ Email: admin@mediapro.com
   ☐ Password: Admin@12345
   ☐ Result:
      ✓ Login successful → PASS
      ✗ 419 error → FAIL (troubleshoot)
      ✗ Other error → Note: _________________
   ☐ Dashboard accessible: Yes / No
   ☐ Test time: ____________

TEST 2: Flutter Web Registration
   ☐ Click: "سجل حساب جديد"
   ☐ Email: testuser@example.com
   ☐ Password: TestPass123!
   ☐ Phone: +971501234567
   ☐ Result:
      ✓ Registration successful → PASS
      ✗ Failed → Error: _____________________
   ☐ User appears in database: Yes / No
   ☐ Test time: ____________

TEST 3: Database Connection
   ☐ SSH connected: Yes / No
   ☐ Command: php artisan db:show
   ☐ Result:
      ✓ Database connected → PASS
      ✗ Connection failed → Run: php artisan cache:table
   ☐ Cache table created: Yes / No
   ☐ Migrations run: Yes / No
   ☐ Test time: ____________


🔧 TROUBLESHOOTING LOG
───────────────────────────────────────────────────────────────

Issue 1: 419 Page Expired Still Shows
   Date/Time: __________
   Action taken: ___________________________
   Result: ___________________________________
   
Issue 2: Database Connection Fails
   Date/Time: __________
   Action taken: ___________________________
   Result: ___________________________________
   
Issue 3: Other Issues
   Date/Time: __________
   Issue: ____________________________________
   Action taken: ___________________________
   Result: ___________________________________


✅ FINAL VALIDATION
───────────────────────────────────────────────────────────────

☐ Admin login works without 419 error
☐ Admin dashboard displays correctly
☐ Flutter app registration works
☐ User data persists in database
☐ No errors in storage/logs/laravel.log
☐ Session cookies set correctly
☐ All HTTPS connections working

OVERALL STATUS:
   ☐ ALL TESTS PASSED ✅
   ☐ MINOR ISSUES (describe): _________________
   ☐ CRITICAL ISSUES (describe): _________________


📝 DEPLOYMENT NOTES
───────────────────────────────────────────────────────────────

Date: ___________________
Deployed by: ___________________
Method used: ___________________

Changes applied:
✓ Database host: 82.25.83.217
✓ Session configuration: Cookie-based
✓ Cache store: Database-backed
✓ Flutter registration: Fixed API endpoint
✓ All cache cleared on server

Next actions (if any):
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________


🎯 SIGN-OFF
───────────────────────────────────────────────────────────────

Deployment successful: □ Yes  □ No
Date/Time completed: ___________________
Verified by: ___________________

Issues remaining:
☐ None - System fully operational
☐ Minor (describe): _____________________
☐ Critical (describe): _____________________

═══════════════════════════════════════════════════════════════
