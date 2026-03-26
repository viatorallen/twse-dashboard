#!/bin/bash
cd "$(dirname "$0")"

if ! command -v node &> /dev/null; then
  osascript -e 'display alert "找不到 Node.js" message "請先安裝 Node.js：https://nodejs.org"'
  exit 1
fi

PORT=8888
while lsof -i :$PORT &>/dev/null; do
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

open -a "Google Chrome" "http://localhost:$PORT" 2>/dev/null || open "http://localhost:$PORT"

echo "台股看板：http://localhost:$PORT"
echo "關閉此視窗停止伺服器"
trap "kill $SERVER_PID 2>/dev/null" EXIT
wait $SERVER_PID
