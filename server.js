const http  = require('http');
const https = require('https');
const fs    = require('fs');
const path  = require('path');
const url   = require('url');

const PORT = process.env.PORT || 8888;
const DIR  = __dirname;

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.css' : 'text/css',
  '.js'  : 'application/javascript',
  '.ico' : 'image/x-icon',
};

function proxyTo(targetUrl, res) {
  const p = url.parse(targetUrl);
  const opts = {
    hostname: p.hostname,
    port: 443,
    path: p.path,
    method: 'GET',
    headers: {
      'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)',
      'Referer': 'https://' + p.hostname + '/',
      'Accept': 'application/json, text/plain, */*',
    },
  };
  const req = https.request(opts, proxyRes => {
    res.writeHead(200, {
      'Content-Type': 'application/json; charset=utf-8',
      'Access-Control-Allow-Origin': '*',
      'Cache-Control': 'no-cache',
    });
    proxyRes.pipe(res);
  });
  req.setTimeout(10000, () => { req.destroy(); res.writeHead(504); res.end('{"error":"timeout"}'); });
  req.on('error', e => { res.writeHead(502); res.end(JSON.stringify({error: e.message})); });
  req.end();
}

http.createServer((req, res) => {
  const parsed = url.parse(req.url, true);
  const pathname = parsed.pathname;

  // ── API proxy ─────────────────────────────────────────────
  if (pathname === '/api/openapi') {
    proxyTo('https://openapi.twse.com.tw/v1/exchangeReport/STOCK_DAY_ALL', res);
    return;
  }
  if (pathname === '/api/mis') {
    const exCh = parsed.query.ex_ch || '';
    proxyTo(
      'https://mis.twse.com.tw/stock/api/getStockInfo.jsp' +
      '?ex_ch=' + encodeURIComponent(exCh) + '&json=1&delay=0&_=' + Date.now(),
      res
    );
    return;
  }

  // ── Static files ───────────────────────────────────────────
  let filePath;
  if (pathname === '/') {
    filePath = path.join(DIR, '台股看板.html');
  } else {
    filePath = path.join(DIR, decodeURIComponent(pathname));
    // 防止路徑穿越
    if (!filePath.startsWith(DIR)) { res.writeHead(403); res.end(); return; }
  }

  fs.readFile(filePath, (err, data) => {
    if (err) { res.writeHead(404); res.end('Not found'); return; }
    const ext = path.extname(filePath).toLowerCase();
    res.writeHead(200, { 'Content-Type': MIME[ext] || 'text/plain' });
    res.end(data);
  });

}).listen(PORT, '127.0.0.1', () => {
  console.log('台股看板：http://localhost:' + PORT);
});
