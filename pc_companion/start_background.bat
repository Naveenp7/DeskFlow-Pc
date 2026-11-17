@echo off
setlocal
title Start DeskFlow in Background
color 0B

echo Starting DeskFlow silently in background...
cd /d "%~dp0"
start "" pythonw.exe deskflow_server.py
echo [SUCCESS] DeskFlow is now running silently in the background!
timeout /t 3 >nul
