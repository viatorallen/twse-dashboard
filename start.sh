#!/bin/bash
# Linux 啟動腳本
cd "$(dirname "$0")"

if ! command -v node &> /dev/null; then
  echo "找不到 Node.js，請先安裝：https://nodejs.org"
  exit 1
fi

PORT=8888
while lsof -i :$PORT &>/dev/null 2>&1; do
  PORT=$((PORT + 1))
done

export PORT=$PORT
node server.js &
SERVER_PID=$!

# 等待伺服器就緒
for i in {1..20}; do
  sleep 0.3
  curl -s "http://localhost:$PORT" -o /dev/null 2>&1 && break
done

URL="http://localhost:$PORT"
echo "台股看板：$URL"

# 嘗試開啟瀏覽器（依序試各種指令）
if command -v xdg-open &>/dev/null; then
  xdg-open "$URL"
elif command -v google-chrome &>/dev/null; then
  google-chrome "$URL"
elif command -v chromium-browser &>/dev/null; then
  chromium-browser "$URL"
else
  echo "請手動開啟瀏覽器前往：$URL"
fi

echo "按 Ctrl+C 停止伺服器"
trap "kill $SERVER_PID 2>/dev/null" EXIT
wait $SERVER_PID
