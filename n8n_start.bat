@echo off
echo ====================================
echo   Starting n8n...
echo ====================================
echo.
echo Access n8n at: http://localhost:5678
echo Username: admin
echo Password: mediapro2025
echo.
echo Press Ctrl+C to stop n8n
echo.

cd n8n_workspace 2>nul
n8n start
