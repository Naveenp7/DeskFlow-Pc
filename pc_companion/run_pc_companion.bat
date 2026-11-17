@echo off
title DeskFlow PC Companion
color 0B
echo ========================================================
echo             DeskFlow PC Companion Launcher
echo ========================================================
echo.
echo Starting ultra-lightweight PC Companion...
echo.

python deskflow_server.py

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [Error] DeskFlow server exited with code %ERRORLEVEL%.
    pause
)
