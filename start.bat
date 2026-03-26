@echo off
chcp 65001 >nul
cd /d "%~dp0"

where node >nul 2>&1
if %errorlevel% neq 0 (
  echo 找不到 Node.js，請先安裝：https://nodejs.org
  pause
  exit /b 1
)

set PORT=8888
:check_port
netstat -ano | findstr ":%PORT% " >nul 2>&1
if %errorlevel% equ 0 (
  set /a PORT=%PORT%+1
  goto check_port
)

echo 台股看板：http://localhost:%PORT%
echo 關閉此視窗停止伺服器

start /b node server.js

:: 等待伺服器就緒
timeout /t 2 /nobreak >nul

start "" "http://localhost:%PORT%"

:: 保持視窗開啟（server.js 會持續執行）
node server.js
