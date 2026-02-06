---
name: smart-git-commit
description: Intelligent Git commit workflow. Checks or creates feature branch, analyzes staged changes, and generates Conventional Commits message. Use when user inputs a ticket ID like pi-12345, or says "commit", "push", "提交變更".
disable-model-invocation: false
allowed-tools: Bash, Read
---

# Smart Git Commit

智能 Git 提交工作流程。輸入票號後自動處理分支、分析變更、生成 commit message、確認後推送。

> **參考文件**: `references/conventional-commits.md` — Commit message 規範和範例
> **操作腳本**: `scripts/git_operations.py` — 所有 Git 操作的封裝

---

## 使用方式

```
/smart-git-commit pi-12345
```

---

## 工作流程

### Step 1 — 檢查並確保分支存在

分支名稱直接使用使用者輸入的內容，原樣不做任何轉換。
例如輸入 `pi-12345`，分支就是 `pi-12345`。

執行腳本檢查分支狀況：

```bash
python3 scripts/git_operations.py check-branch <輸入的票號>
```

| 情況                    | 處理方式                                           |
| ----------------------- | -------------------------------------------------- |
| 本地分支存在            | 切換到該分支                                       |
| 本地不存在、remote 存在 | `git checkout <輸入的票號>`（會自動 track remote） |
| 本地、remote 都不存在   | 從 default branch 開新分支（見下）                 |

新分支建立流程（本地、remote 都不存在時）：

```bash
# 1. 動態取得 default branch 名稱
python3 scripts/git_operations.py get-default-branch

# 2. 從 default branch 開新分支（腳本內部自動 fetch 再開）
python3 scripts/git_operations.py create-branch <輸入的票號>
```

`create-branch` 內部會自動：先 `fetch` 確保 default branch 是最新的，再從 `origin/<default>` 開出新分支。無論使用者當前在哪個分支，新分支都是從 default 開。

---

### Step 2 — 檢查並整理變更內容

```bash
python3 scripts/git_operations.py status
```

根據輸出判斷：

| 狀況                                 | 處理方式                             |
| ------------------------------------ | ------------------------------------ |
| 有 staged 變更                       | 直接進入分析（不動 staging）         |
| 有 unstaged 或 untracked 但無 staged | 提問使用者：是否要把所有變更 stage？ |
| 完全無變更                           | 提示使用者，流程停止                 |

使用者確認後，若需要 stage：

```bash
python3 scripts/git_operations.py stage-all
```

---

### Step 3 — 分析 Diff 並生成 Commit Message

```bash
python3 scripts/git_operations.py diff
```

讀取 `references/conventional-commits.md` 參考規範，根據 diff 內容生成 commit message。

**語言規則**：

- `type` 永遠英文（commitlint 限制，如 `feat`, `fix`）
- 票號永遠原樣（如 `pi-12345`）
- `subject` 和 `body` 的語言由使用者選擇（見下）

生成格式：

```
<type>: <票號> <subject>
```

生成規則：

1. 判斷適合的 `type`（feat / fix / docs / refactor…）
2. **不使用 scope**
3. subject 開頭放票號（小寫，如 `pi-12345`），後接說明（動詞開頭、不以句號結尾）
4. `type: pi-12345 subject` 整段不超過 72 字元
5. 若變更較複雜，加入 `body` 說明（每行 ≤ 72 字元）

**預設用繁體中文生成。** 生成後附上語言切換選項，使用者可以在確認前切換：

```
確認 / 修改 / 取消 / 切語言: en, zh
```

使用者輸入語言代碼後，以相同的 diff 和 type，重新生成該語言版本的 subject 和 body。

---

### Step 4 — Commit 並推送

使用者確認後，執行：

```bash
python3 scripts/git_operations.py commit "<confirmed_message>"
python3 scripts/git_operations.py push <輸入的票號>
```

**重要**：Commit message 只使用確認的內容，**不要添加** `Co-Authored-By` 或任何額外的 footer。

推送完成後，顯示摘要：

```
✅ Commit 完成
   分支: pi-12345
   訊息: feat: pi-12345 新增密碼重置功能
   推送: origin/pi-12345
```

---

## 範例對話

### 繁體中文（預設）

```
User: /smart-git-commit pi-12345

Claude: 🔍 檢查分支 pi-12345…
        ✅ 已從 origin/main 建立並切換到 pi-12345

        📂 檢查變更狀況…
        Unstaged 變更: 3 個檔案
          src/auth/reset.py
          tests/test_reset.py
          README.md
        目前沒有 staged 變更。要把以上所有檔案 stage 吗？

User: 好

Claude: ✅ 已將所有變更加入 staging
        📊 分析 diff 中…

        以下是建議的 commit message：

        ─────────────────────────
        feat: pi-12345 新增密碼重置功能

        - 實現重置令牌生成與驗證
        - 新增重置連接郵件通知
        - 新增重置流程單元測試
        ─────────────────────────

        確認 / 修改 / 取消 / 切語言: en, zh

User: 確認

Claude: ✅ Commit 完成
        ✅ 推送到 origin/pi-12345 完成
```

### 英文版本（切語言後）

```
User: en

Claude: ─────────────────────────
        feat: pi-12345 add password reset flow

        - implement reset token generation and validation
        - add email notification for reset link
        - add unit tests for reset workflow
        ─────────────────────────

        確認 / 修改 / 取消 / 切語言: en, zh

User: 確認

Claude: ✅ Commit 完成
        ✅ 推送到 origin/pi-12345 完成
```

---

## 支持語言

| 代碼 | 語言             | 範例 subject                       |
| ---- | ---------------- | ---------------------------------- |
| `en` | 英文             | `pi-12345 add password reset flow` |
| `zh` | 繁體中文（預設） | `pi-12345 新增密碼重置功能`        |

> 使用者也可以直接說「用中文」「切英文」等，Claude 會自動理解並切換。

---

## 注意事項

- Push 之前一定經過使用者確認，不會自動推送
- 腳本直接執行本地 git 命令，不需要 MCP
- `type` 必須英文（commitlint `type-enum` 限制）
- 票號小寫呈現，不會觸發 commitlint 的 `subject-case`，參考 `references/conventional-commits.md`
- `header-max-length` 計算的是字元數（非位元組數），中文字元和英文一樣每個算 1 個字元
- **不要添加 `Co-Authored-By` 或其他 footer**，只使用生成並確認的 commit message
