# Part 7：AI Agent 的 SEO 工具生態系 🛠️

> OpenCode 嘅能力可以透過各種工具大大擴展。以下係 SEO agency 最常用嘅工具分類，每個都可以俾你嘅 Agent 使用。

---

## 🔍 SERP 研究

### 1. Serper.dev

| 項目 | 說明 |
|---|---|
| 這是什麼 | Google 搜尋 API，專為 AI 設計，回傳結構化 SERP 結果 |
| 費用 | 2,500 次/月免費，之後 $0.30/1k 次 |
| 怎麼用 | Agent 可以即時搜尋 Google，取得排名數據、Featured Snippets、People Also Ask |
| SEO 使用情境 | 「幫我查『SEO 工具推薦』呢個關鍵字嘅 SERP，列出前 10 名網頁嘅 title 同 URL」 |

### 2. Brave Search

| 項目 | 說明 |
|---|---|
| 這是什麼 | Brave 自家獨立搜尋索引，唔依靠 Google |
| 費用 | 2,000 次/月免費（非商業），之後 $5/1k 次 |
| 怎麼用 | Agent 用獨立搜尋引擎做關鍵字研究，不受 Google API 限制 |
| SEO 使用情境 | 「幫我用 Brave Search 搜尋最新嘅 AI SEO 趨勢文章」 |

### 3. Tavily

| 項目 | 說明 |
|---|---|
| 這是什麼 | 專為 AI Agent 設計嘅搜尋引擎，支援內容提取 |
| 費用 | 1,000 次/月免費 |
| 怎麼用 | Agent 搜尋後自動提取網頁內容，適合同業研究 |
| SEO 使用情境 | 「幫我研究 competitor.com 呢個網站，搵出佢哋最近嘅內容策略」 |

### 4. Exa

| 項目 | 說明 |
|---|---|
| 這是什麼 | 神經語義搜尋引擎，用 Link Prediction 技術理解搜尋意圖 |
| 費用 | 1,000 次/月免費 |
| 怎麼用 | Agent 搵語義相似嘅內容，做 content gap analysis |
| SEO 使用情境 | 「幫我搵同我哋網站內容相似但排名更高嘅競爭對手」 |

---

## 🕷️ 網站擷取與技術 SEO

### 5. Firecrawl

| 項目 | 說明 |
|---|---|
| 這是什麼 | 爬全網站轉 Markdown，支援結構化資料提取 |
| 費用 | 有免費 tier，付費 $19/月起 |
| 怎麼用 | Agent 爬取競爭對手全網站內容做分析 |
| SEO 使用情境 | 「幫我爬 competitor.com 成個網站，分析佢哋嘅內容結構同 heading 策略」 |

### 6. Apify

| 項目 | 說明 |
|---|---|
| 這是什麼 | 網頁抓取同自動化平台，有大量預建 Actor |
| 費用 | 有免費 tier，付費按用量計 |
| 怎麼用 | Agent 自動化爬取 SERP、產品頁、評論、社交媒體 |
| SEO 使用情境 | 「幫我搵出呢個關鍵字嘅 Google Maps 本地商家資料」 |

### 7. Jina AI

| 項目 | 說明 |
|---|---|
| 這是什麼 | URL 前綴 `r.jina.ai/` 即轉 Markdown，唔使任何設定 |
| 費用 | 有免費 tier |
| 怎麼用 | Agent 快速擷取單一網頁內容做即時分析 |
| SEO 使用情境 | 「幫我讀取呢個網頁嘅內容，分析佢嘅 meta description 同 heading tags」 |

### 8. Screaming Frog

| 項目 | 說明 |
|---|---|
| 這是什麼 | 技術 SEO 爬蟲，分析網站架構同 SEO 問題 |
| 費用 | 免費版可爬 500 個 URLs，付費 £149/年 |
| 怎麼用 | Agent 分析網站架構、Redirect Chain、Broken Links、Meta Tags |
| SEO 使用情境 | 「幫我分析呢個網站嘅 redirect chain，搵出有冇 redirect loops」 |

---

## 📊 Google 生態系

### 9. gws（Google Workspace CLI）✅ 已安裝

| 項目 | 說明 |
|---|---|
| 這是什麼 | 命令列工具，管理 Gmail、Google Drive、Calendar、Sheets |
| 費用 | 免費，跟 Google Workspace 帳號 |
| 怎麼用 | Agent 直接讀寫 Google Sheets、收發 Email、管理雲端硬碟 |
| SEO 使用情境 | 「幫我將呢個 keyword report 整理好，存入 Google Sheets」 |

### 10. gcloud（Google Cloud CLI）✅ 已安裝

| 項目 | 說明 |
|---|---|
| 這是什麼 | Google Cloud 命令列工具 |
| 費用 | 免費，跟 GCP 帳號 |
| 怎麼用 | Agent 操作 Search Console API、GA4 API、Cloud Functions |
| SEO 使用情境 | 「幫我由 Search Console 下載過去 3 個月嘅搜尋查詢數據」 |

### 11. Google Search Console API

| 項目 | 說明 |
|---|---|
| 這是什麼 | Google Search Console 嘅 API 接口 |
| 費用 | 免費 |
| 怎麼用 | Agent 查詢點擊率、曝光次數、平均排名、關鍵字表現 |
| SEO 使用情境 | 「幫我搵出過去 30 日曝光高但點擊率低嘅關鍵字」 |

### 12. Google Analytics Data API

| 項目 | 說明 |
|---|---|
| 這是什麼 | Google Analytics 4 嘅 API 接口 |
| 費用 | 免費 |
| 怎麼用 | Agent 分析流量來源、使用者行為、轉換率、頁面表現 |
| SEO 使用情境 | 「幫我分析邊啲 landing page 嘅 bounce rate 最高，俾改善建議」 |

---

## 📈 SEO 平台

### 13. Ahrefs API

| 項目 | 說明 |
|---|---|
| 這是什麼 | Ahrefs 嘅 API，存取反向連結、關鍵字、內容數據 |
| 費用 | 需有 Ahrefs 付費方案，API 另計 |
| 怎麼用 | Agent 分析 Backlink Profile、競爭對手網域、關鍵字難度 |
| SEO 使用情境 | 「幫我分析 competitor.com 嘅 top 20 backlinks，睇下佢哋嘅 link building 策略」 |

### 14. Semrush API

| 項目 | 說明 |
|---|---|
| 這是什麼 | Semrush 嘅 API，存取 SEO 套件數據 |
| 費用 | 需有 Semrush 付費方案 |
| 怎麼用 | Agent 做關鍵字難度分析、Site Audit、競爭對手追蹤 |
| SEO 使用情境 | 「幫我對呢個網站做一次 Site Audit，列出所有技術 SEO 錯誤」 |

### 15. Frase

| 項目 | 說明 |
|---|---|
| 這是什麼 | 全流程 AI SEO Agent：研究、寫作、優化、監控、修正 |
| 費用 | $49/月起，所有功能包晒 |
| 怎麼用 | Agent 自動化內容研究、SERP 分析、內容生成、排名監控 |
| SEO 使用情境 | 「幫我用 Frase 研究『AI SEO 工具』呢個主題，生成一份內容 brief」 |

### 16. Surfer SEO

| 項目 | 說明 |
|---|---|
| 這是什麼 | 內容優化工具，用 NLP 即時評分內容 |
| 費用 | $49/月起 |
| 怎麼用 | Agent 分析 SERP 競爭者內容結構，俾出優化建議 |
| SEO 使用情境 | 「幫我分析呢篇文對比 SERP 前 10 名，俾出實體密度同 heading 結構建議」 |

---

## 📝 內容優化與品質控制

### 17. Clearscope

| 項目 | 說明 |
|---|---|
| 這是什麼 | 內容評分平台，分析主題覆蓋率同實體使用 |
| 費用 | $129/月起 |
| 怎麼用 | Agent 分析內容是否覆蓋足夠主題實體，俾 A-F 評分 |
| SEO 使用情境 | 「幫我用 Clearscope 分析呢篇文，俾出主題覆蓋率報告」 |

### 18. Originality.ai

| 項目 | 說明 |
|---|---|
| 這是什麼 | AI 內容偵測工具，檢測文章是否由 AI 生成 |
| 費用 | $14.95/月起 |
| 怎麼用 | Agent 檢測內容嘅 AI 生成機率，確保品質達標 |
| SEO 使用情境 | 「幫我檢測呢 10 篇文章嘅 AI 生成分數，標記出高風險嘅文章」 |

### 19. Grammarly

| 項目 | 說明 |
|---|---|
| 這是什麼 | 寫作品質檢查工具 |
| 費用 | 免費版夠用，付費 $12/月 |
| 怎麼用 | Agent 檢查文法、語氣、可讀性、清晰度 |
| SEO 使用情境 | 「幫我檢查呢篇 blog 嘅可讀性分數，建議改善語氣一致性」 |

### 20. Copyscape

| 項目 | 說明 |
|---|---|
| 這是什麼 | 抄襲檢測工具，檢查內容是否有重複 |
| 費用 | $0.03/次檢查 |
| 怎麼用 | Agent 檢查內容是否原創，避免重複內容問題 |
| SEO 使用情境 | 「幫我檢查呢篇新文章嘅原創性，確保冇 plagiarize 其他網站」 |

---

## 📊 排名追蹤與監控

### 21. AccuRanker

| 項目 | 說明 |
|---|---|
| 這是什麼 | 即時排名追蹤工具，更新速度快 |
| 費用 | 按關鍵字數量計費 |
| 怎麼用 | Agent 監控關鍵字排名變化，做即時報告 |
| SEO 使用情境 | 「幫我 check 呢批關鍵字今日嘅排名變化，highlight 有明顯變動嘅」 |

### 22. Nightwatch

| 項目 | 說明 |
|---|---|
| 這是什麼 | 多維度排名追蹤，支援地區、裝置、語言 |
| 費用 | 按關鍵字數量計費 |
| 怎麼用 | Agent 追蹤唔同地區、裝置、語言嘅排名差異 |
| SEO 使用情境 | 「幫我比較呢批關鍵字喺 desktop 同 mobile 嘅排名差異」 |

### 23. Pro Rank Tracker

| 項目 | 說明 |
|---|---|
| 這是什麼 | 性價比高嘅排名追蹤工具 |
| 費用 | 按關鍵字數量計費 |
| 怎麼用 | Agent 每日監控數千關鍵字排名變化 |
| SEO 使用情境 | 「幫我每日監控呢 500 個關鍵字，每週出一份 ranking report」 |

---

## ⚡ 網站速度與 Core Web Vitals

### 24. Google PageSpeed Insights API

| 項目 | 說明 |
|---|---|
| 這是什麼 | Google 官方網站效能分析 API |
| 費用 | 免費 |
| 怎麼用 | Agent 檢查 LCP、CLS、INP 等 Core Web Vitals 指標 |
| SEO 使用情境 | 「幫我 check 呢 10 個頁面嘅 Core Web Vitals，列出需要改善嘅頁面」 |

### 25. Lighthouse

| 項目 | 說明 |
|---|---|
| 這是什麼 | Google 開源網站審計工具 |
| 費用 | 免費 |
| 怎麼用 | Agent 自動化審計 SEO、效能、可訪問性、最佳實踐 |
| SEO 使用情境 | 「幫我對呢個網站做一次完整 Lighthouse audit，俾改善建議」 |

### 26. WebPageTest

| 項目 | 說明 |
|---|---|
| 這是什麼 | 深入網站效能測試，支援多地區多裝置 |
| 費用 | 免費版夠用 |
| 怎麼用 | Agent 多地區、多裝置測試網站載入速度 |
| SEO 使用情境 | 「幫我測試呢個網頁喺美國同亞洲嘅載入速度比較」 |

---

## 🤖 AI Search 優化

### 27. Perplexity

| 項目 | 說明 |
|---|---|
| 這是什麼 | AI 搜尋引擎，附來源引用 |
| 費用 | 免費版夠用，Pro $20/月 |
| 怎麼用 | Agent 監測品牌喺 AI Search 嘅可見度、研究競爭對手 |
| SEO 使用情境 | 「幫我研究我哋品牌喺 Perplexity 嘅出現情況，睇下有冇被引用」 |