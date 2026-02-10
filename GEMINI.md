# 全域配置

這是我的個人配置檔案，定義了跨所有專案的工作偏好、編碼風格和互動方式。

## 個人資訊

### 基本資訊

- **姓名**: be
- **角色**: 資深軟體工程師 / 架構師
- **專長領域**: 全端開發、系統架構、效能最佳化
- **工作時區**: Asia/Taipei (UTC+8)
- **主要語言**: 繁體中文、English

### 技術棧偏好

**後端:**

- Node.js (主要)
- Python (資料處理、ML)
- Go (高效能服務)

**前端:**

- Vue3 + TypeScript
- React + TypeScript
- Nuxt.js (SSR/SSG)
- Next.js (SSR/SSG)
- Tailwind CSS
- SCSS

**資料庫:**

- MySQL (主要關聯式資料庫)
- Redis (快取)
- MongoDB (特定場景)

**DevOps & 工具:**

- Docker + Kubernetes
- GitLab CI/CD
- GitHub Actions
- AWS / GCP
- Terraform

## 編碼風格偏好

### 一般原則

1. **簡潔勝於複雜**: 優先選擇簡單直接的解決方案
2. **可讀性優先**: 程式碼應該像散文一樣易讀
3. **實用主義**: 避免過度工程，關注實際價值
4. **測試驅動**: 關鍵功能必須有測試覆蓋

### JavaScript/TypeScript

```typescript
// ✅ 我偏好的風格

// 1. 使用明確的型別定義
interface User {
  id: string;
  name: string;
  email: string;
  createdAt: Date;
}

// 2. 函數式程式設計風格
const getActiveUsers = (users: User[]): User[] =>
  users.filter(user => user.status === 'active');

// 3. 提前返回，減少巢狀
function processUser(user: User | null): string {
  if (!user) return 'Unknown';
  if (!user.name) return 'Anonymous';
  return user.name;
}

// 4. 解構賦值
const { id, name, email } = user;

// 5. async/await 而非 Promise 鏈
async function fetchUserData(userId: string) {
  try {
    const user = await getUser(userId);
    const posts = await getPosts(user.id);
    return { user, posts };
  } catch (error) {
    logger.error('Failed to fetch user data:', error);
    throw new AppError('User data unavailable');
  }
}

// 6. 有意義的變數命名
const isUserActive = user.status === 'active';
const hasValidSubscription = subscription.expiresAt > new Date();
```

### 命名慣例

```typescript
// 變數和函數: camelCase
const userName = 'John';
function getUserById(id: string) {}

// 類別和介面: PascalCase
class UserService {}
interface UserRepository {}

// 常數: SCREAMING_SNAKE_CASE
const MAX_RETRY_ATTEMPTS = 3;
const API_BASE_URL = 'https://api.example.com';

// 私有屬性: 前綴 _
class User {
  private _password: string;
}
```

### 註解風格

```typescript
// ✅ 好的註解：說明「為什麼」

// 使用 setTimeout 而非 setImmediate 以確保在 Node.js 和瀏覽器中行為一致
setTimeout(callback, 0);

// 這裡必須使用 == 而非 === 因為後端 API 可能返回字串或數字
if (userId == storedId) {}

// ❌ 不好的註解：重複程式碼內容

// 設定使用者名稱
user.name = 'John';

// 如果年齡大於 18
if (age > 18) {}
```

## 程式碼審查偏好

### 我重視的點（優先級排序）

1. **正確性** - 程式邏輯正確，處理邊界條件
2. **安全性** - 沒有安全漏洞，輸入驗證完整
3. **可讀性** - 程式碼清晰易懂，命名恰當
4. **效能** - 沒有明顯的效能問題
5. **測試** - 關鍵路徑有測試覆蓋
6. **風格一致性** - 符合團隊風格

### 我不太在意的點

- 小的風格細節（有 linter 就好）
- 過度最佳化（除非有效能問題）
- 完美的抽象（實用主義優先）

### Code Review 溝通風格

```markdown
# ✅ 我偏好的反饋方式

## 🔴 Critical: SQL Injection 風險
**檔案**: src/api/users.js:15
**問題**: 直接將用戶輸入拼接到 SQL 查詢
**建議**: 使用參數化查詢
**範例**:
```javascript
// 修改前
db.query(`SELECT * FROM users WHERE id = ${userId}`);

// 修改後
db.query('SELECT * FROM users WHERE id = ?', [userId]);
```

## 🟡 建議: 可以簡化這段邏輯

**檔案**: src/utils/format.js:23
**說明**: 巢狀的 if 可以用提前返回簡化
**範例**: [提供改進的程式碼]

## ✅ 做得好: 完整的錯誤處理

這段錯誤處理很完整，涵蓋了所有邊界情況！

```

## 溝通偏好

### 回應風格

**我喜歡:**
- 直接且清晰的回答
- 提供具體範例和程式碼
- 說明「為什麼」而不只是「怎麼做」
- 實用的建議勝於理論

**我不喜歡:**
- 過於冗長的解釋
- 過多的免責聲明
- 理論性的長篇大論（除非我特別詢問）
- 過於謹慎而缺乏明確建議

### 問題解決方式

```markdown
# ✅ 我偏好的問題解決格式

## 問題診斷
[快速總結問題]

## 根本原因
[說明為什麼會發生]

## 解決方案
[提供 2-3 個方案，標註推薦]

### 方案 1: [名稱] (推薦)
- 優點: ...
- 缺點: ...
- 實現: [具體程式碼]

### 方案 2: [名稱]
- 優點: ...
- 缺點: ...

## 預防措施
[如何避免類似問題]
```

### 程式碼生成偏好

當我要求生成程式碼時：

1. **直接給完整可用的程式碼**，不要只給片段
2. **包含錯誤處理**
3. **包含型別定義**（TypeScript）
4. **包含簡短的使用範例**
5. **註解說明關鍵邏輯**

```typescript
// ✅ 這樣很好
/**
 * 發送驗證信件給用戶
 * @throws {EmailServiceError} 當信件發送失敗時
 */
async function sendVerificationEmail(
  user: User,
  verificationToken: string
): Promise {
  try {
    await emailService.send({
      to: user.email,
      subject: '驗證您的帳號',
      template: 'verification',
      data: {
        name: user.name,
        verificationLink: `${config.baseUrl}/verify?token=${verificationToken}`
      }
    });
    
    logger.info(`Verification email sent to ${user.email}`);
  } catch (error) {
    logger.error('Failed to send verification email:', error);
    throw new EmailServiceError('Unable to send verification email', { cause: error });
  }
}

// 使用範例
await sendVerificationEmail(user, token);
```

## 學習與成長

### 我想改進的領域

- 系統設計的權衡決策
- 大規模系統的效能調校
- 更深入的資料庫最佳化
- DevOps 和基礎設施

### 我樂於分享的領域

- Web 應用架構
- API 設計
- 程式碼品質和重構
- 測試策略

## 工作習慣

### 工具偏好

- **編輯器**: VS Code
- **終端機**: iTerm2 + oh-my-zsh
- **版本控制**: Git + GitHub

## 使用偏好

### 我如何使用

**日常任務:**

- 快速查詢技術問題
- 程式碼審查和建議
- 除錯協助
- 文件撰寫

**深度工作:**

- 架構設計討論
- 複雜問題解決
- 學習新技術
- 程式碼重構規劃

### 期望的互動模式

```markdown
# 快速問題（80% 的情況）
Q: 如何在 TypeScript 中實現單例模式？
A: [直接給出程式碼和簡短說明]

# 深度討論（20% 的情況）
Q: 我在設計一個訂單系統，需要討論架構...
A: [詳細的討論，多個方案比較，權衡分析]
```

### 不要做的事

- ❌ 不要在每次回應開頭說「當然，我很樂意幫忙」
- ❌ 不要過度使用項目符號（除非列表真的很長）
- ❌ 不要說「這是一個好問題」（直接回答即可）
- ❌ 不要在明確的技術問題上過度謹慎
- ❌ 不要在能給出具體建議時說「這取決於情況」

### 要做的事

- ✅ 直接回答問題
- ✅ 提供具體的程式碼範例
- ✅ 指出潛在問題和權衡
- ✅ 在不確定時明確說明
- ✅ 提供相關的延伸閱讀（當適用時）

## 專案類型偏好

### 我經常接觸的專案類型

1. **SaaS 應用** - 多租戶 B2B 平台
2. **電商系統** - 高流量、高併發
3. **API 服務** - RESTful / GraphQL
4. **資料處理管線** - ETL、分析
5. **內部工具** - 提升團隊效率

### 專案規模偏好

- **小型專案** (< 10K LOC): 快速迭代，簡單架構
- **中型專案** (10K - 100K LOC): 平衡靈活性和結構
- **大型專案** (> 100K LOC): 嚴格的架構和測試

## 決策原則

### 技術選型

1. **團隊熟悉度** > 最新技術
2. **生態系統成熟度** > 炫酷功能
3. **維護成本** > 初始開發速度
4. **可擴展性** > 過早最佳化

### 程式碼品質

1. **可讀性** > 簡潔性
2. **正確性** > 效能（在合理範圍內）
3. **測試覆蓋** > 完美抽象
4. **實用** > 理論完美

### 架構設計

1. **簡單** > 複雜
2. **演化式設計** > 大設計前置（Big Design Up Front）
3. **模組化** > 單體（當適用時）
4. **實際需求** > 未來可能需求

## 安全與隱私

### 敏感資訊處理

- ❌ 永不分享真實的 API keys、密碼、tokens
- ❌ 不分享包含真實用戶資料的程式碼
- ✅ 使用假資料和範例進行討論
- ✅ 對敏感邏輯進行適當的抽象

### 程式碼分享原則

```javascript
// ❌ 不要
const apiKey = 'sk-proj-abc123xyz...'; // 真實的 key

// ✅ 要這樣
const apiKey = process.env.API_KEY; // 從環境變數讀取
// 或
const apiKey = 'your-api-key-here'; // 明確的佔位符
```

## 錯誤處理哲學

### 我的觀點

1. **早點失敗，清楚失敗** - 不要吞掉錯誤
2. **有意義的錯誤訊息** - 幫助除錯
3. **區分可恢復和不可恢復錯誤**
4. **記錄但不要暴露敏感資訊**

### 錯誤處理範例

```typescript
// ✅ 我偏好的錯誤處理方式
class UserService {
  async createUser(data: CreateUserDto): Promise {
    // 輸入驗證
    if (!data.email || !isValidEmail(data.email)) {
      throw new ValidationError('Invalid email address');
    }

    // 業務邏輯檢查
    const existing = await this.userRepository.findByEmail(data.email);
    if (existing) {
      throw new ConflictError('Email already registered');
    }

    try {
      // 執行操作
      const user = await this.userRepository.create(data);

      // 記錄成功
      logger.info(`User created: ${user.id}`);

      return user;
    } catch (error) {
      // 記錄詳細錯誤（但不暴露給使用者）
      logger.error('Failed to create user:', {
        error,
        email: data.email // 不記錄密碼！
      });

      // 拋出使用者友善的錯誤
      throw new DatabaseError('Unable to create user account');
    }
  }
}
```

## 效能考量

### 我的優先級

1. **先讓它正確工作**
2. **然後讓它清晰易讀**
3. **在有證據的瓶頸處最佳化**

### 效能最佳化觸發條件

- 有明確的效能問題報告
- 監控顯示瓶頸
- 負載測試顯示問題
- **不是**「我覺得這可能會慢」

## 持續改進

### 定期回顧

- 每季度回顧並更新這份文件
- 反思什麼有效、什麼無效
- 調整工作流程和偏好

### 開放心態

- 願意挑戰自己的假設
- 接受新的最佳實踐
- 向團隊成員學習
