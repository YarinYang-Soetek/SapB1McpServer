@echo off
setlocal EnableExtensions
chcp 65001 > nul
cd /d "%~dp0"

echo =======================================================================
echo SAP Business One Enterprise AI Gateway - Automated Setup
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
echo [OK] Configuration templates initialized.

:: 3. Install dependencies
echo [INFO] Installing project dependencies (npm install)...
call npm install --omit=dev
if %errorlevel% neq 0 goto ERR_NPM_FAIL
echo [OK] Dependencies installed successfully.

:: 4. Windows Firewall Rule for Port 5005
netsh advfirewall firewall show rule name="SAP_B1_MCP_GATEWAY_5005" >nul 2>nul
if %errorlevel% equ 0 goto FIREWALL_DONE
netsh advfirewall firewall add rule name="SAP_B1_MCP_GATEWAY_5005" dir=in action=allow protocol=TCP localport=5005 >nul 2>nul
echo [OK] Windows Firewall rule added for Port 5005.
:FIREWALL_DONE

:: 5. Launch Background Server
echo [INFO] Starting background server...
call "%~dp0stop-server.bat" /silent
wscript.exe "%~dp0scripts\run-background.vbs"

echo [INFO] Waiting for server to initialize...
timeout /t 3 /nobreak >nul

:: 6. Check status
netstat -ano | findstr ":5005" | findstr "LISTENING" >nul 2>nul
if %errorlevel% equ 0 goto SETUP_SUCCESS
goto SETUP_WARN

:SETUP_SUCCESS
echo.
echo =======================================================================
echo [SUCCESS] SAP B1 MCP Server setup and started successfully!
echo =======================================================================
goto SUMMARY

:SETUP_WARN
echo.
echo =======================================================================
echo [WARN] Server did not listen on Port 5005 immediately.
echo Check logs\server.log for details.
echo =======================================================================
goto SUMMARY

:ERR_NO_NODE
echo.
echo [ERROR] Node.js not found! Please install Node.js 18+ (LTS).
echo Download URL: https://nodejs.org/
echo.
goto END_SETUP

:ERR_NPM_FAIL
echo.
echo [ERROR] npm install failed. Please check network or proxy settings.
echo.
goto END_SETUP

:SUMMARY
echo.
echo Health endpoint: http://localhost:5005/health
echo SSE endpoint   : http://localhost:5005/sse
echo Log file       : logs\server.log
echo.
echo Quick Management Commands:
echo   - Check status  : double-click check-status.bat
echo   - Foreground run: double-click start-server.bat
echo   - Background run: double-click start-background.bat
echo   - Stop server   : double-click stop-server.bat
echo =======================================================================
echo.

:END_SETUP
pause
