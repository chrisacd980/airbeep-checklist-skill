@echo off
chcp 65001 >nul
setlocal
set SRC=%~dp0
set DEST=%USERPROFILE%\AirBeepTest
if not exist "%DEST%" mkdir "%DEST%"
xcopy "%SRC%*" "%DEST%\" /E /I /Y >nul
powershell -NoProfile -ExecutionPolicy Bypass -File "%DEST%\create-shortcuts.ps1"
start "" "%DEST%\airbeep-checklist.html"
endlocal
