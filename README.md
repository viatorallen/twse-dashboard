# 台股即時看板

即時監控台灣上市股票與 ETF，支援盤中即時報價與盤後收盤資料。

![preview](https://img.shields.io/badge/Node.js-≥18-339933?logo=node.js) ![license](https://img.shields.io/badge/license-MIT-blue)

---

## 功能

| 功能 | 說明 |
|------|------|
| 盤中即時 | 09:00–13:30 每 30 秒更新，來源：TWSE MIS API |
| 盤後收盤 | 顯示當日收盤價，來源：TWSE Open API |
| Sparkline | 累積本次開啟後的價格歷史，畫出波動折線圖 |
| 日內位置 | 小圓點在今日低點↔高點區間滑動 |
| 漲跌閃光 | 價格變動時卡片背景綠閃/紅閃 |
| 自訂股票 | 新增或移除任意上市股票代號與 ETF |
| 更新間隔 | 10 秒 / 30 秒 / 1 分鐘可選 |

---

## 檔案結構

```
即時台股面版/
├── 台股看板.html      # 主版本（需搭配 server.js，支援所有瀏覽器）
├── standalone.html    # 獨立版本（無需伺服器，需停用瀏覽器跨來源限制）
├── server.js          # Node.js 本機伺服器 + TWSE API proxy（零 npm 依賴）
├── package.json       # npm start 跨平台入口
├── launch.command     # macOS 雙擊啟動腳本
├── start.sh           # Linux 啟動腳本
├── start.bat          # Windows 啟動腳本
├── .gitignore
└── README.md
```

---

## 使用方式

### 需求

- **Node.js ≥ 18**（[下載](https://nodejs.org)）

### 啟動方式

| 平台 | 方法 |
|------|------|
| **macOS** | 雙擊 `launch.command` |
| **Linux** | `chmod +x start.sh && ./start.sh` |
| **Windows** | 雙擊 `start.bat` |
| **任意平台** | `npm start` 或 `node server.js`，再開瀏覽器前往 `http://localhost:8888` |

啟動腳本會自動：
1. 確認 Node.js 已安裝
2. 找到未被佔用的埠口（預設 8888）
3. 啟動伺服器並開啟瀏覽器

> 關閉終端機視窗即停止伺服器。

---

## 架構說明

```
瀏覽器 (localhost:8888)
    │
    ├─ GET /                → 回傳 台股看板.html
    ├─ GET /api/openapi     → proxy → openapi.twse.com.tw  (盤後)
    └─ GET /api/mis?ex_ch=… → proxy → mis.twse.com.tw       (盤中)
```

### 為什麼需要本機伺服器？

從 `file://` 開啟 HTML 時，Chrome 將 origin 視為 `null`，
CORS 規範明確禁止 `null` origin 存取外部 API（即使 API 有 `*` header）。
本機伺服器解決兩個問題：

1. **CORS**：伺服器替 TWSE API 加上 `Access-Control-Allow-Origin: *`
2. **Origin**：瀏覽器從 `http://localhost` 發出請求，origin 不再是 `null`

---

## 資料來源

| API | 用途 | 備註 |
|-----|------|------|
| [TWSE Open API](https://openapi.twse.com.tw) | 盤後全市場收盤資料 | 免費，無需金鑰 |
| [TWSE MIS](https://mis.twse.com.tw) | 盤中即時報價 | 免費，無需金鑰 |

---

---

## 無伺服器模式（standalone.html）

不想啟動伺服器時，可直接雙擊開啟 `standalone.html`，
但需先在瀏覽器停用跨來源限制。

| 瀏覽器 | 支援 | 方法 |
|--------|:----:|------|
| **Safari** | ✅ | 選單 › 開發 › 停用跨來源限制 |
| **Chrome** | ✅ | 命令列旗標（見下方） |
| **Edge** | ✅ | 命令列旗標（見下方） |
| **Firefox** | ❌ | 無內建支援，請改用伺服器模式 |

### Safari

```
選單列 › 開發 › 停用跨來源限制（Disable Cross-Origin Restrictions）
```

> 若沒有「開發」選單：Safari 偏好設定 › 進階 › 勾選「在選單列顯示開發選單」

---

### Chrome — 停用跨來源限制

> ⚠️ 必須額外指定 `--user-data-dir`，否則 Chrome 會忽略此旗標。

**macOS**
```bash
open -na "Google Chrome" --args \
  --disable-web-security \
  --user-data-dir="/tmp/chrome-no-cors"
```

**Windows（命令提示字元）**
```bat
"C:\Program Files\Google\Chrome\Application\chrome.exe" ^
  --disable-web-security ^
  --user-data-dir="C:\Temp\chrome-no-cors"
```

**Linux**
```bash
google-chrome --disable-web-security \
  --user-data-dir="/tmp/chrome-no-cors"
```

---

### Edge — 停用跨來源限制

**macOS**
```bash
open -na "Microsoft Edge" --args \
  --disable-web-security \
  --user-data-dir="/tmp/edge-no-cors"
```

**Windows（命令提示字元）**
```bat
"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" ^
  --disable-web-security ^
  --user-data-dir="C:\Temp\edge-no-cors"
```

> ⚠️ `--disable-web-security` 僅用於開啟本機 HTML，
> 停用後請勿同時瀏覽其他網站，用完後關閉該視窗即可回到正常模式。

---

## 注意事項

- 僅支援**上市（TWSE）**股票，不含上櫃（OTC）
- ETF 請直接輸入代號（如 `0050`、`00878`）
- 資料有約 15 秒延遲（TWSE MIS 規格）
