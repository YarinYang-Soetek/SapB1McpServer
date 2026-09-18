@echo off
setlocal EnableExtensions
chcp 65001 > nul
cd /d "%~dp0"

echo =======================================================================
echo SAP Business One Enterprise AI Gateway - Starting in Background
echo Working Directory: %CD%
echo =======================================================================
echo.

:: 1. Check Node.js
where node >nul 2>nul
if %errorlevel% neq 0 goto ERR_NO_NODE

:: 2. Initialize directories and configs
if not exist "logs" mkdir "logs"
if not exist "config" mkdir "config"
if not exist "scripts" mkdir "scripts"

if not exist "config\server.json" copy /y "config\server.example.json" "config\server.json" >nul 2>nul
if not exist "config\environments.json" copy /y "config\environments.example.json" "config\environments.json" >nul 2>nul
if not exist "config\plugins.json" copy /y "config\plugins.example.json" "config\plugins.json" >nul 2>nul
if not exist "config\devops.json" copy /y "config\devops.example.json" "config\devops.json" >nul 2>nul

:: 3. Check dependencies
if exist "node_modules\express" goto LAUNCH_BG
echo [INFO] Installing dependencies (npm install)...
call npm install --omit=dev
if %errorlevel% neq 0 goto ERR_NPM_FAIL

:LAUNCH_BG
:: 4. Stop existing instance on Port 5005
call "%~dp0stop-server.bat" /silent

:: 5. Launch background VBS
echo [INFO] Launching background server process...
wscript.exe "%~dp0scripts\run-background.vbs"

echo [INFO] Waiting for server to initialize...
timeout /t 3 /nobreak >nul

:: 6. Verify
netstat -ano | findstr ":5005" | findstr "LISTENING" >nul 2>nul
if %errorlevel% equ 0 goto RUNNING_OK
goto RUNNING_WARN

:RUNNING_OK
echo [SUCCESS] Server is now RUNNING in background on Port 5005!
goto END_MSG

:RUNNING_WARN
echo [WARN] Server did not respond on Port 5005 yet.
echo Checking logs\server.log:
echo -----------------------------------------------------------------------
if exist "logs\server.log" type "logs\server.log"
echo -----------------------------------------------------------------------
goto END_MSG

:ERR_NO_NODE
echo [ERROR] Node.js not found! Please install Node.js 18+ (LTS).
echo Download from: https://nodejs.org/
echo.
goto END_MSG

:ERR_NPM_FAIL
echo [ERROR] npm install failed.
goto END_MSG

:END_MSG
echo.
echo =======================================================================
echo Check Status : double-click check-status.bat
echo Stop Server  : double-click stop-server.bat
echo Health URL   : http://localhost:5005/health
echo Log File     : logs\server.log
echo =======================================================================
echo.
pause
