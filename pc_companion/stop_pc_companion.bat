@echo off
setlocal
title Stop DeskFlow Companion
color 0E

echo Stopping any running DeskFlow processes...
powershell -NoProfile -Command ^
  "$main = Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like '*deskflow_server.py*' }; " ^
  "$mainIds = $main | Select-Object -ExpandProperty ProcessId; " ^
  "if ($mainIds) { " ^
  "  Get-CimInstance Win32_Process | Where-Object { $mainIds -contains $_.ParentProcessId -and $_.CommandLine -like '*multiprocessing*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue; Write-Host 'Stopped DeskFlow worker process ID:' $_.ProcessId }; " ^
  "  $main | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue; Write-Host 'Stopped DeskFlow Process ID:' $_.ProcessId }; " ^
  "} else { Write-Host 'No DeskFlow process found running.' }"
echo [DONE] DeskFlow companion stopped.
timeout /t 3 >nul
