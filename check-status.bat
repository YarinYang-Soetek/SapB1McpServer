@echo off
setlocal EnableExtensions
chcp 65001 > nul
cd /d "%~dp0"

echo =======================================================================
echo SAP Business One Enterprise AI Gateway - Server Status Check
echo =======================================================================
echo.

:: 1. Check Port 5005
echo [1] Checking Port 5005 (Listening Status):
netstat -ano | findstr ":5005" | findstr "LISTENING"
if %errorlevel% equ 0 goto PORT_OK
echo [WARN] Port 5005 is NOT listening. The server is currently stopped.
goto CHECK_HTTP

:PORT_OK
echo [OK] Port 5005 is active and LISTENING!

:CHECK_HTTP
echo.
:: 2. HTTP Health check via powershell script
echo [2] Testing HTTP Health Endpoint (http://localhost:5005/health):
if not exist "scripts\check-health.ps1" goto SKIP_PS
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\check-health.ps1"
goto CHECK_LOGS

:SKIP_PS
powershell -NoProfile -Command "try { $r = Invoke-RestMethod -Uri http://localhost:5005/health -TimeoutSec 3; Write-Host '[OK] Health:' $r } catch { Write-Host '[FAIL] ' $_.Exception.Message }"

:CHECK_LOGS
echo.
:: 3. Recent logs
if not exist "logs\server.log" goto SUMMARY
echo [3] Recent Server Log (last 10 lines of logs\server.log):
echo -----------------------------------------------------------------------
powershell -NoProfile -Command "Get-Content -Path 'logs\server.log' -Tail 10 -ErrorAction SilentlyContinue"
echo -----------------------------------------------------------------------

:SUMMARY
echo.
echo =======================================================================
echo Quick Actions:
echo   - Start background: double-click start-background.bat
echo   - Start foreground: double-click start-server.bat
echo   - Stop server     : double-click stop-server.bat
echo =======================================================================
echo.
pause
