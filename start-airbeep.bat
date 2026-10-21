@echo off
chcp 65001 >nul
cd /d %~dp0
where python >nul 2>nul
if errorlevel 1 (
  where python3 >nul 2>nul
  if errorlevel 1 (
    start "" "%~dp0airbeep-checklist.html"
    exit /b 0
  )
  set PY=python3
) else (
  set PY=python
)
start /b "" %PY% airbeep-desktop.py
timeout /t 1 /nobreak >nul
start "" http://127.0.0.1:8765/
exit /b 0
