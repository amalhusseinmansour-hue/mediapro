@echo off
echo Uploading AuthController to production...
pscp -P 65002 -pw "gtWD8vyZBXT7qv$" "C:\Users\HP\social_media_manager\backend\app\Http\Controllers\Api\AuthController.php" u126213189@82.25.83.217:/home/u126213189/domains/mediaprosocial.io/public_html/app/Http/Controllers/Api/AuthController.php
echo Upload complete!
