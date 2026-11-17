@echo off
setlocal
title Disable DeskFlow Auto-Start
color 0C

echo ========================================================
echo             Disable DeskFlow Windows Auto-Start
echo ========================================================
echo.

set SHORTCUT_PATH=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\DeskFlow.lnk

if exist "%SHORTCUT_PATH%" (
    del "%SHORTCUT_PATH%"
    echo [SUCCESS] DeskFlow has been removed from Windows Startup.
) else (
    echo [INFO] DeskFlow was not in Windows Startup.
)

echo.
pause
