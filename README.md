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
├── 台股看板.html      # 前端主體（單一 HTML，無外部框架）
├── server.js          # Node.js 本機伺服器 + TWSE API proxy
├── 啟動看板.command   # macOS 雙擊啟動腳本
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
| **macOS** | 雙擊 `啟動看板.command` |
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

## 注意事項

- 僅支援**上市（TWSE）**股票，不含上櫃（OTC）
- ETF 請直接輸入代號（如 `0050`、`00878`）
- 資料有約 15 秒延遲（TWSE MIS 規格）
