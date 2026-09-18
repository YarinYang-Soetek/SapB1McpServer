@echo off
setlocal EnableExtensions
chcp 65001 > nul
cd /d "%~dp0"

echo =======================================================================
echo SAP Business One Enterprise AI Gateway - Update and Reload
echo =======================================================================
echo.

echo [INFO] Pulling latest code from Git (git pull)...
call git pull
if %errorlevel% neq 0 goto ERR_PULL

echo [INFO] Updating dependencies (npm install)...
call npm install --omit=dev
if %errorlevel% neq 0 goto ERR_NPM

echo [INFO] Restarting background server...
call "%~dp0stop-server.bat" /silent
wscript.exe "%~dp0scripts\run-background.vbs"

echo [SUCCESS] Update completed and background server reloaded!
goto END

:ERR_PULL
echo [ERROR] Git pull failed. Please check network connection or git state.
goto END

:ERR_NPM
echo [ERROR] npm install failed.
goto END

:END
echo.
pause
