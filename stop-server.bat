@echo off
setlocal EnableExtensions
chcp 65001 > nul
cd /d "%~dp0"

if "%1"=="/silent" goto DO_STOP

echo =======================================================================
echo Stopping SAP B1 MCP Gateway Server...
echo =======================================================================
echo.

:DO_STOP
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":5005" ^| findstr "LISTENING"') do (
    taskkill /F /PID %%a >nul 2>nul
)

if "%1"=="/silent" goto END_SILENT

echo [SUCCESS] Server process stopped.
echo.
pause

:END_SILENT
