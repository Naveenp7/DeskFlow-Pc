@echo off
setlocal
title Enable DeskFlow Auto-Start on Windows Boot
color 0A

echo ========================================================
echo       Enable DeskFlow Silent Auto-Start on Boot
echo ========================================================
echo.

set SCRIPT_DIR=%~dp0
set SCRIPT_PATH=%SCRIPT_DIR%deskflow_server.py
set STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
set SHORTCUT_PATH=%STARTUP_DIR%\DeskFlow.lnk

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ws = New-Object -ComObject WScript.Shell; " ^
  "$s = $ws.CreateShortcut('%SHORTCUT_PATH%'); " ^
  "$s.TargetPath = 'pythonw.exe'; " ^
  "$s.Arguments = '\"%SCRIPT_PATH%\"'; " ^
  "$s.WorkingDirectory = '%SCRIPT_DIR%'; " ^
  "$s.WindowStyle = 7; " ^
  "$s.Description = 'DeskFlow PC Companion Background Service'; " ^
  "$s.Save();"

if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] DeskFlow has been added to Windows Startup!
    echo.
    echo Next time you start or restart your PC:
    echo - DeskFlow starts automatically in the background.
    echo - No command prompt window will appear.
    echo - Takes 0%% CPU when idle.
    echo - Your phone will connect instantly whenever you open the app!
) else (
    echo [ERROR] Failed to create Startup shortcut.
)

echo.
pause
