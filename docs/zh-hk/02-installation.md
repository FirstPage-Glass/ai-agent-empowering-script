# Part 2：安裝與設定 🚀

## 第一步：執行安裝腳本 📥

我們已經準備好一鍵安裝腳本，會幫你裝好 opencode Desktop 以及其他常用工具。

### Mac 使用者 🍎

開啟「終端機」（Terminal），貼上以下指令後按 Enter：

```bash
curl -fsSL https://raw.githubusercontent.com/FirstPage-Glass/ai-agent-empowering-script/main/install-dev-tools-macos.sh | bash
```

> ⚠️ 如果出現密碼提示，請輸入你的電腦密碼（輸入時不會顯示字元，這是正常的）。

### Windows 使用者 🪟

1. 在工作列搜尋「PowerShell」
2. 在「Windows PowerShell」上按右鍵，選擇「以系統管理員身分執行」
3. 貼上以下指令後按 Enter：

```powershell
irm https://raw.githubusercontent.com/FirstPage-Glass/ai-agent-empowering-script/main/install-dev-tools-windows.ps1 | iex
```

---

## 第二步：開始使用 🎉

裝完之後，雙擊 opencode Desktop 圖示就開得。

**就是這麼簡單。** 不需要註冊、不需要 API Key、不需要信用卡。

開啟後你會看到一個對話視窗，裡面已經有免費模型可以直接使用。直接打字試試看：

```
你：Hello 👋
opencode：Hello! 有什麼我可以幫你的？
```

> 🎊 **恭喜你，你已經可以開始使用了！**

---

## 進階：使用更強的模型（選擇性） 🚀

如果你之後想試試更強大的模型（例如 Claude、GPT-5 等），有兩個選擇：

### 1️⃣ opencode Zen 🟢
opencode 官方提供的付費模型服務，品質有保證。
在 opencode Desktop 輸入 `/connect` 然後按 Enter，它會引導你完成設定。

### 2️⃣ 自己的 API Key 🔑
如果你本身有 OpenAI 或 Anthropic 的 API Key，
可以到 Settings（設定）頁面貼上即可使用。

> 💡 **什麼是 API Key？** 它就像一組密碼，讓 opencode 可以連接 AI 服務。不過你現在還不需要，先用免費模型就夠了。
