@echo off
echo ====================================
echo   n8n Installation and Setup Script
echo ====================================
echo.

REM Check if Node.js is installed
echo [1/5] Checking Node.js installation...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed!
    echo Please install Node.js 18+ from: https://nodejs.org/
    pause
    exit /b 1
)

echo [OK] Node.js is installed
node --version
echo.

REM Check npm
echo [2/5] Checking npm...
npm --version
echo.

REM Install n8n globally
echo [3/5] Installing n8n globally (this may take a few minutes)...
npm install -g n8n
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install n8n
    pause
    exit /b 1
)
echo [OK] n8n installed successfully
echo.

REM Create n8n directory
echo [4/5] Creating n8n workspace...
if not exist "n8n_workspace" mkdir n8n_workspace
cd n8n_workspace
echo [OK] Workspace created at: %CD%
echo.

REM Create configuration file
echo [5/5] Creating configuration file...
(
echo # n8n Configuration
echo N8N_HOST=localhost
echo N8N_PORT=5678
echo N8N_PROTOCOL=http
echo WEBHOOK_URL=http://localhost:5678/
echo.
echo # Database (default: SQLite^)
echo DB_TYPE=sqlite
echo.
echo # Timezone
echo GENERIC_TIMEZONE=Asia/Dubai
echo TZ=Asia/Dubai
echo.
echo # Security
echo N8N_BASIC_AUTH_ACTIVE=true
echo N8N_BASIC_AUTH_USER=admin
echo N8N_BASIC_AUTH_PASSWORD=mediapro2025
echo.
echo # Execution
echo EXECUTIONS_PROCESS=main
echo N8N_PAYLOAD_SIZE_MAX=16
) > .env

echo [OK] Configuration created
echo.

echo ====================================
echo   Installation Complete!
echo ====================================
echo.
echo To start n8n, run:
echo   n8n start
echo.
echo Or use the quick start script:
echo   n8n_start.bat
echo.
echo Access n8n at: http://localhost:5678
echo Username: admin
echo Password: mediapro2025
echo.
pause
