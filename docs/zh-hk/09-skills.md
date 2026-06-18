# Part 9：技能（Skills）🧩

> 技能是可以重複使用的指令包，讓你的 AI agent 變成專家。放進專案裡，agent 就會自動載入。

---

## 什麼是技能？🤔

把技能想像成 AI agent 的**工作說明書**。

沒有技能的話，每次你要 agent 做事，都得從頭解釋一遍。有了技能，你只需要寫一次指令——agent 就會永遠記住。

**舉個例子：** 不用每天這樣說：
```
連到我的 Gmail，讀取未讀郵件，按緊急程度分類...
```

你只要安裝一次 **email-planner** 技能，下次直接說：
```
幫我看看信箱
```

Agent 就知道該怎麼做了。

---

## 技能怎麼運作 ⚙️

一個技能就是一個資料夾，裡面有兩樣東西：

```
email-planner/
├── SKILL.md          ← 給 agent 的指令
└── scripts/
    └── email_planner.py  ← 預先寫好的腳本（可選）
```

**`SKILL.md`** 告訴 agent：
- 🏷️ **名稱** — 技能叫什麼
- 📝 **描述** — 什麼時候該用它（agent 靠這個決定要不要啟動技能）
- 📋 **指令** — 一步步該做什麼

**`scripts/`**（可選）放的是預先寫好的程式碼，agent 直接執行——不需要再產生程式碼。

> 💡 **提示：** Agent 會讀描述來判斷技能是否符合你的需求。好的描述 = 技能在對的時間被觸發。

---

## 技能結構 🔬

每個 `SKILL.md` 都會以 YAML frontmatter 開頭：

```yaml
---
name: email-planner
description: >
  讀取並分類 Gmail 未讀郵件。
  當使用者想要整理信箱或查看未讀郵件時使用。
---
```

然後是 markdown 內容，包含詳細指令：

```markdown
# Email Planner

## 工作流程

### 步驟 1：檢查環境變數
...

### 步驟 2：詢問憑證
...

### 步驟 3：執行腳本
...
```

---

## 實戰：Email Planner 技能 📬

讓我們來看看這個專案內建的一個真實技能。

### 它做什麼

**email-planner** 技能會做三件事：

1. 📬 **抓取**最近 24 小時的郵件（可調整）
2. 🔍 **找出**需要你處理的事項
3. ✍️ **草擬**回覆郵件，讓你直接發送

它會把郵件分成四類：

| 分類 | 圖示 | 觸發條件 |
|---|---|---|
| 緊急 | 🔴 | "urgent"、"asap"、"critical" |
| 待辦 | 🟡 | "please review"、"could you"、"follow up" |
| 會議 | 🔵 | "meeting"、"call"、"schedule"、"zoom" |
| 參考 | ⚪ | 其他所有郵件 |

### 怎麼用

這個技能在你執行安裝腳本時**自動安裝**。只要打開 opencode 然後說：

```
幫我看看信箱
```

或者：

```
哪些郵件需要我回覆？
```

Agent 會：
1. 📧 問你的 email 和應用程式密碼（只需一次）
2. ⚡ 抓取並分類你的郵件
3. 🎯 找出需要處理的事項
4. ✍️ 為每個待辦項目草擬回覆

### 取得應用程式密碼

這個技能需要一個**應用程式密碼**來連接 Gmail（不是你的平常密碼）：

1. 前往 https://myaccount.google.com/apppasswords
2. 如果提示，先啟用兩步驟驗證
3. 取名為「Email Planner」→ 產生
4. 複製 16 個字元的密碼

> ⚠️ 你的應用程式密碼只用於連接信箱。Agent 絕不會儲存、記錄或顯示它。

### 輸出範例

```
📬 找到 12 封郵件（最近 24 小時）。

🔴 緊急 (1)

  1. Server outage — ops@company.com
     → 動作：回覆確認你正在處理
     → 草稿：
       "Hi team, I'm on it. Investigating the root cause now
        and will update within the hour."

🟡 待辦 (2)

  2. Q3 budget proposal — finance@company.com
     → 動作：審閱提案並在 [日期] 前回覆意見
     → 草稿：
       "Hi, thanks for sending this over. I'll review the proposal
        and get back to you with feedback by [date]."

  3. Client follow-up — sales@company.com
     → 動作：回覆確認後續步驟
     → 草稿：
       "Hi [name], thanks for the call earlier. To confirm, our
        next steps are: [list steps]. Let me know if I missed anything."

🔵 會議 (1)

  4. Team standup Tuesday — calendar@company.com
     → 動作：確認出席（如果自動接受則不需回覆）

⚪ 參考 (8) — 不需處理
```

---

## 建立你自己的技能 🛠️

建立技能很簡單。這是範本：

### 步驟 1：建立資料夾

```bash
mkdir -p skills/my-skill/scripts
```

### 步驟 2：寫 SKILL.md

```yaml
---
name: my-skill
description: >
  這個技能做什麼。當使用者要求...時使用。
  也可以在他們提到...時觸發。
---

# My Skill

## 工作流程

### 步驟 1：詢問使用者...
### 步驟 2：執行腳本...
### 步驟 3：呈現結果...
```

### 步驟 3：加入腳本（可選）

如果你的技能需要執行程式碼，放在 `scripts/` 裡：

```
skills/my-skill/
├── SKILL.md
└── scripts/
    └── my_script.py
```

Agent 會直接執行——不需要再產生程式碼。

### 步驟 4：測試

在 OpenCode 裡打開你的專案，問一些符合技能描述的問題。Agent 應該會自動載入技能。

> 💡 **提示：** 讓你的描述「主動一點」——包含使用者可能用的多種說法。這能幫助 agent 更可靠地觸發技能。

---

## 寫好技能的秘訣 ✨

**1️⃣ 描述要具體** 🎯
- ❌ 「處理資料」
- ✅ 「讀取 CSV 檔案、計算總數、產生摘要報告。當使用者提到資料分析、CSV 處理或報告生成時使用。」

**2️⃣ 盡量預先寫好腳本** 📦
- 如果 agent 每次都寫一樣的 helper 腳本，不如直接放進 `scripts/`
- 預先寫好的腳本比產生的程式碼更快、更可靠

**3️⃣ 優雅地處理錯誤** 🛡️
- 告訴 agent 出錯時該怎麼辦
- 例如：「如果登入失敗，引導使用者重新產生應用程式密碼」

**4️⃣ 指令要精簡** ✂️
- 解釋**為什麼**，而不是死板的步驟規則
- Agent 很聰明——給它情境，不要給它緊箍咒

**5️⃣ 用真實的提示測試** 🧪
- 試試 2-3 種不同的說法
- 「幫我看看信箱」/「我有什麼郵件？」/「整理我的郵件」

---

## 技能放在哪裡 📁

**使用者範圍**（每個專案都能用）— 安裝腳本會放在這裡：

```
~/.config/opencode/skills/
├── email-planner/
│   ├── SKILL.md
│   └── scripts/
│       └── email_planner.py
└── my-other-skill/
    └── SKILL.md
```

**專案範圍**（只在該專案中可用）：

```
my-project/
├── skills/
│   └── my-skill/
│       └── SKILL.md
├── src/
└── ...
```

Agent 會自動發現兩個位置的技能。

> 💡 **提示：** 使用者範圍的技能適合你在哪裡都会用到的個人工具（像是 email planner）。專案範圍的技能比較適合專案特定的工作流程。
