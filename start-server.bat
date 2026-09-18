@echo off
setlocal EnableExtensions
chcp 65001 > nul
cd /d "%~dp0"

echo =======================================================================
echo SAP Business One Enterprise AI Gateway - Direct Server Mode
echo Working Directory: %CD%
echo =======================================================================
echo.

:: 1. Check Node.js
where node >nul 2>nul
if %errorlevel% neq 0 goto ERR_NO_NODE
echo [OK] Node.js is installed.

:: 2. Initialize directories and configs
if not exist "logs" mkdir "logs"
if not exist "config" mkdir "config"
if not exist "scripts" mkdir "scripts"

if not exist "config\server.json" copy /y "config\server.example.json" "config\server.json" >nul 2>nul
if not exist "config\environments.json" copy /y "config\environments.example.json" "config\environments.json" >nul 2>nul
if not exist "config\plugins.json" copy /y "config\plugins.example.json" "config\plugins.json" >nul 2>nul
if not exist "config\devops.json" copy /y "config\devops.example.json" "config\devops.json" >nul 2>nul

:: 3. Check dependencies
if exist "node_modules\express" goto START_NODE
echo [INFO] Installing dependencies (npm install)...
call npm install --omit=dev
if %errorlevel% neq 0 goto ERR_NPM_FAIL

:START_NODE
echo.
echo =======================================================================
echo [INFO] Starting Server (Port 5005, SSE Mode)...
echo Health URL  : http://localhost:5005/health
echo SSE URL     : http://localhost:5005/sse
echo Note: Keep this window open. Press Ctrl+C to stop.
echo =======================================================================
echo.
node src/server.js
echo.
echo [INFO] Server process terminated.
goto END_SCRIPT

:ERR_NO_NODE
echo [ERROR] Node.js not found! Please install Node.js 18+ (LTS).
echo Download from: https://nodejs.org/
echo.
goto END_SCRIPT

:ERR_NPM_FAIL
echo [ERROR] npm install failed.
echo.
goto END_SCRIPT

:END_SCRIPT
pause
