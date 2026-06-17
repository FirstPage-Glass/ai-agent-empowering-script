# Part 2：安裝與設定

## 第一步：執行安裝腳本

我們已經準備好一鍵安裝腳本，會幫你裝好 opencode Desktop 以及其他常用工具。

### Mac 使用者

開啟「終端機」（Terminal），貼上以下指令後按 Enter：

```bash
curl -fsSL https://raw.githubusercontent.com/FirstPage-Glass/ai-agent-empowering-script/main/install-dev-tools-macos.sh | bash
```

> 如果出現密碼提示，請輸入你的電腦密碼（輸入時不會顯示字元，這是正常的）。

### Windows 使用者

1. 在工作列搜尋「PowerShell」
2. 在「Windows PowerShell」上按右鍵，選擇「以系統管理員身分執行」
3. 貼上以下指令後按 Enter：

```powershell
irm https://raw.githubusercontent.com/FirstPage-Glass/ai-agent-empowering-script/main/install-dev-tools-windows.ps1 | iex
```

---

## 第二步：註冊並取得 API Key

1. 開啟 opencode Desktop
2. 你會看到一個歡迎畫面，選擇「Connect」
3. 瀏覽器會自動開啟 [opencode.ai/auth](https://opencode.ai/auth)
4. 登入或註冊一個新帳號
5. 選擇付費方案（有免費額度可以試用）
6. 複製畫面顯示的 API Key
7. 回到 opencode Desktop，貼上 API Key

> 💡 **什麼是 API Key？** 它就像一組密碼，讓 opencode 可以連接 AI 服務。你只需要設定一次。

---

## 第三步：確認安裝成功

1. 開啟 opencode Desktop
2. 你應該會看到一個對話視窗
3. 輸入「Hello」或「你好」，看看它是否會回覆你

如果它回覆了，恭喜你，安裝成功！🎉
