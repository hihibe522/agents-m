# Conventional Commits 規範參考

> 本文件基於 `@commitlint/config-conventional` 的預設規則。
> 票號小寫呈現（`pi-12345`），不使用 scope。

---

## Commit Message 格式

```
<type>: <ticket> <subject>
                                    ← 必須空一行
[optional body]
                                    ← 必須空一行
[optional footer]
```

範例：
```
fix: pi-12345 handle null response from user endpoint
```

---

## 自定義 commitlint 配置

票號 `pi-12345` 小寫開頭，不會觸發預設的 `subject-case` 規則。
唯一需要自定義的是拔掉 scope：

```js
// commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'scope-empty': [2, 'always'],   // 本項目不使用 scope
  },
};
```

---

## commitlint Rules 對照表

### ❌ 會導致 lint 失敗的規則 (error)

| Rule | 限制 | 說明 |
|------|------|------|
| `header-max-length` | ≤ 72 字元 | `type: pi-xxxxx subject` 整段加起來 |
| `type-case` | lowercase | `feat` ✅ `Feat` ❌ |
| `type-empty` | 不能為空 | `: something` ❌ |
| `type-enum` | 見下方列表 | 不在列表內會失敗 |
| `scope-empty` | 不能有 scope | `feat(auth):` ❌ |
| `subject-empty` | 不能為空 | `feat:` ❌ |
| `subject-case` | 不能是 sentence/start/pascal/upper case | `pi-12345 ...` 小寫開頭 ✅ |
| `subject-full-stop` | 不能以 `.` 結尾 | `fix: pi-12345 handle it.` ❌ |
| `body-max-line-length` | 每行 ≤ 72 字元 | body 裡每一行都要限制 |
| `footer-max-line-length` | 每行 ≤ 72 字元 | footer 裡每一行都要限制 |

### ⚠️ 警告規則 (warning，應遵守)

| Rule | 限制 | 說明 |
|------|------|------|
| `body-leading-blank` | body 前必須空一行 | subject 和 body 之間不能直接連 |
| `footer-leading-blank` | footer 前必須空一行 | body 和 footer 之間不能直接連 |

---

## Type 類型

必須是以下之一（`type-enum`），且必須小寫（`type-case`）：

| Type | 說明 | 範例 |
|------|------|------|
| `feat` | 新功能 | `feat: pi-12345 add password reset` |
| `fix` | Bug 修復 | `fix: pi-12345 handle null response` |
| `docs` | 文件更新 | `docs: pi-12345 update README` |
| `style` | 格式調整（不影響功能） | `style: pi-12345 fix indentation` |
| `refactor` | 重構（不是新功能/修復） | `refactor: pi-12345 simplify query` |
| `test` | 測試相關 | `test: pi-12345 add unit tests` |
| `chore` | 維護任務 | `chore: pi-12345 update dependencies` |
| `perf` | 性能優化 | `perf: pi-12345 optimize image loading` |
| `ci` | CI/CD 相關 | `ci: pi-12345 add github actions` |
| `build` | 建立系統相關 | `build: pi-12345 update webpack config` |
| `revert` | 回滾變更 | `revert: pi-12345 undo commit abc123` |

---

## Subject 主題

- 開頭必須是小寫票號：`pi-xxxxx`
- 票號後接一個空格，再寫說明
- 說明動詞開頭，用現在進時態
- **不能以句號結尾**（`subject-full-stop`）
- 配合 `type: ` 前綴，整個 header 不超過 72 字元（`header-max-length`）

| ✅ 正確 | ❌ 錯誤 |
|---------|---------|
| `fix: pi-12345 handle null response` | `fix: pi-12345 handle null response.` (句號) |
| `feat: pi-12345 add login flow` | `feat(auth): pi-12345 add login` (不該有 scope) |
| `feat: pi-12345 implement oauth2` | `feat: PI-12345 add login` (票號大寫) |

---

## Body 說明

- subject 和 body 之間**必須空一行**（`body-leading-blank`）
- 說明「為什麼」而不只是「什麼」
- **每行最大 72 字元**（`body-max-line-length`）

---

## Footer

- body 和 footer 之間**必須空一行**（`footer-leading-blank`）
- **每行最大 72 字元**（`footer-max-line-length`）
- 票號已經在 subject 裡了，footer 視需要加 `Closes #123` 等

---

## 判斷範例

### 看 diff 判斷 type 的準則

| diff 特徵 | 推薦 type |
|-----------|-----------|
| 新增功能程式碼 | `feat` |
| 修改現有功能修復問題 | `fix` |
| 只修改 .md / .txt 等文件 | `docs` |
| 只改了格式/空白/縮排 | `style` |
| 改了架構但功能不變 | `refactor` |
| 新增或修改測試檔案 | `test` |
| 改了 package.json / requirements | `chore` |
| 混合了多種變更 | 用最主要的類型 |

---

### ✅ 通過 commitlint 的範例

```
feat: pi-12345 implement oauth2 login flow

Added Google and GitHub OAuth2 authentication.
Users can now sign in using their existing
accounts without creating a new one.

Closes #45
```

```
fix: pi-12346 handle null response from user endpoint

The /api/users/:id endpoint was returning 500
when user not found. Now correctly returns 404
with a structured error message.
```

```
docs: pi-12347 update API usage examples in README
```

```
feat: pi-12348 add stripe payment integration

- implement Stripe checkout flow
- add payment webhook handler
- add unit tests for payment module
```

---

### 🌏 多語言範例（同一個 diff，切語言後的輸出）

`type` 永遠英文，票號原樣，subject 和 body 隨語言切換：

**繁體中文 (zh) — 預設**
```
feat: pi-12345 新增密碼重置功能

- 實現重置令牌生成與驗證
- 新增重置連接郵件通知
- 新增重置流程單元測試
```

**英文 (en)**
```
feat: pi-12345 add password reset flow

- implement reset token generation and validation
- add email notification for reset link
- add unit tests for reset workflow
```

> 注意：中文語義密度高，同樣的功能說明字元數比英文少，
> 兩種語言版本的 header 都在 72 字元以內。

---

### ❌ 會失敗的範例

```
feat(auth): pi-12345 add login
     ↑ 不該有 scope → scope-empty 失敗

Feat: pi-12345 add login
↑ type 大寫 → type-case 失敗

feat: pi-12345 add login.
                       ↑ 句號結尾 → subject-full-stop 失敗

feat: PI-12345 add login
      ↑ 票號大寫 → subject-case 失敗

fix: handle null response
     ↑ 沒有票號 → 不符合此項目規範

feat: pi-12345 add a very long subject that will exceed the seventy two character header limit here
      ↑ header 超過 72 字元 → header-max-length 失敗
```
