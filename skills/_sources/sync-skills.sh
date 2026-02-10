#!/bin/bash
# 自動同步 personal 技能到根目錄和 _claude/ 目錄
# 位置：~/.agents/skills/_sources/sync-skills.sh
# 使用：bash sync-skills.sh

SKILLS_DIR="$HOME/.agents/skills"
SOURCE_DIR="$SKILLS_DIR"
CLAUDE_DIR="$SKILLS_DIR/_claude"
SUPERPOWERS_DIR="$SKILLS_DIR/_sources/superpowers/skills"

# 顏色定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 同步 personal 技能...${NC}"
echo ""

# ========================================
# 自動更新 superpowers symlink
# ========================================
echo -e "${BLUE}🔗 檢查 superpowers 連結...${NC}"

SUPERPOWERS_LINK="$SKILLS_DIR/_sources/superpowers"
CLAUDE_PLUGINS_DIR="$HOME/.claude/plugins/cache/claude-plugins-official/superpowers"

if [ -L "$SUPERPOWERS_LINK" ]; then
  current_target=$(readlink "$SUPERPOWERS_LINK")

  # 檢查是否指向 Claude Code 的 superpowers
  if [[ "$current_target" == *".claude/plugins/cache"*"superpowers"* ]]; then
    echo "  ℹ️  偵測到 superpowers 連結到 Claude Code"

    # 檢查 Claude plugins 目錄是否存在
    if [ -d "$CLAUDE_PLUGINS_DIR" ]; then
      # 找出最新版本（按修改時間排序）
      latest_version=$(ls -t "$CLAUDE_PLUGINS_DIR" 2>/dev/null | head -1)

      if [ -n "$latest_version" ]; then
        latest_path="$CLAUDE_PLUGINS_DIR/$latest_version"

        # 檢查當前連結是否指向最新版本
        if [ "$current_target" != "$latest_path" ]; then
          echo -e "  ${YELLOW}📦 發現新版本: $latest_version${NC}"
          echo "     當前: $(basename "$current_target")"
          echo "     最新: $latest_version"

          # 更新 symlink
          rm "$SUPERPOWERS_LINK"
          ln -s "$latest_path" "$SUPERPOWERS_LINK"
          echo -e "  ${GREEN}✅ 已更新 superpowers 連結到 v$latest_version${NC}"
        else
          echo "  ✓ superpowers 已是最新版本 ($latest_version)"
        fi
      else
        echo -e "  ${RED}❌ 找不到 Claude Code superpowers 版本${NC}"
      fi
    else
      echo -e "  ${YELLOW}⚠️  Claude Code plugins 目錄不存在${NC}"
    fi
  else
    echo "  ℹ️  superpowers 使用獨立 git repo"
  fi
elif [ -d "$SUPERPOWERS_LINK" ]; then
  echo "  ℹ️  superpowers 是獨立目錄（非 symlink）"
else
  echo -e "  ${RED}❌ superpowers 目錄不存在${NC}"
fi

echo ""

# ========================================
# 檢查目錄是否存在
# ========================================
if [ ! -d "$SKILLS_DIR" ]; then
  echo -e "${RED}❌ 錯誤：找不到 ~/.agents/skills 目錄${NC}"
  exit 1
fi

if [ ! -d "$CLAUDE_DIR" ]; then
  mkdir -p "$CLAUDE_DIR"
  echo -e "${GREEN}✅ 已建立 _claude/ 目錄${NC}"
fi

if [ ! -d "$SUPERPOWERS_DIR" ]; then
  echo -e "${RED}❌ 錯誤：找不到 ~/.agents/skills/_sources/superpowers/skills 目錄${NC}"
  exit 1
fi

# 1. 清理失效的符號連結
echo -e "${BLUE}📝 清理失效的符號連結...${NC}"
cleaned_claude=0
cleaned_superpowers=0

# 清理 _claude/ 中指向 ../<skill> 的失效連結
for link in "$CLAUDE_DIR"/*; do
  [ -L "$link" ] || continue
  target=$(readlink "$link")
  # 只處理指向 ../<skill> 的連結
  if [[ "$target" == ../* ]] && [ -d "$SKILLS_DIR/${target#../}" ] && [ ! -e "$link" ]; then
    rm "$link"
    echo -e "  ${YELLOW}🗑️  _claude/：已刪除失效連結 $(basename "$link")${NC}"
    ((cleaned_claude++))
  fi
done

if [ $cleaned_claude -eq 0 ]; then
  echo "  ✓ 無失效連結"
fi

# 清理根目錄中指向 _sources/superpowers/skills/ 的失效連結
for link in "$SKILLS_DIR"/*; do
  [ -L "$link" ] || continue
  target=$(readlink "$link")
  if [[ "$target" == _sources/superpowers/skills/* ]] && [ ! -e "$link" ]; then
    rm "$link"
    echo -e "  ${YELLOW}🗑️  根目錄：已刪除失效連結 $(basename "$link")${NC}"
    ((cleaned_superpowers++))
  fi
done

if [ $cleaned_superpowers -eq 0 ]; then
  echo "  ✓ 根目錄無失效 superpowers 連結"
fi

# 2. 掃描根目錄技能並建立 _claude 連結
echo ""
echo -e "${BLUE}📝 同步 personal 技能...${NC}"

synced_claude=0

for item in "$SOURCE_DIR"/*; do
  # 只處理目錄
  [ -d "$item" ] || continue
  [ -L "$item" ] && continue

  skill_name=$(basename "$item")

  # 跳過隱藏目錄
  if [[ "$skill_name" == .* ]]; then
    continue
  fi
  # 跳過非技能目錄
  if [[ "$skill_name" == "_sources" ]] || [[ "$skill_name" == "_claude" ]] || [[ "$skill_name" == "claude" ]] || [[ "$skill_name" == ".system" ]] || [[ "$skill_name" == ".venv" ]]; then
    continue
  fi
  # 只處理含 SKILL.md 的目錄
  if [ ! -f "$item/SKILL.md" ]; then
    continue
  fi

  # === _claude/ 連結 ===
  claude_link="$CLAUDE_DIR/$skill_name"
  claude_target="../$skill_name"

  if [ -L "$claude_link" ] && [ "$(readlink "$claude_link")" = "$claude_target" ]; then
    echo "  ✓ _claude/：$skill_name (已存在)"
  else
    [ -L "$claude_link" ] && rm "$claude_link"
    ln -sf "$claude_target" "$claude_link"
    echo -e "  ${GREEN}✅ _claude/：$skill_name (已建立)${NC}"
    ((synced_claude++))
  fi
done

# 3. 掃描 superpowers 並建立根目錄連結
echo ""
echo -e "${BLUE}📝 同步 superpowers 技能到根目錄...${NC}"

synced_superpowers=0

for item in "$SUPERPOWERS_DIR"/*; do
  [ -d "$item" ] || continue

  skill_name=$(basename "$item")

  if [[ "$skill_name" == .* ]]; then
    continue
  fi
  if [ ! -f "$item/SKILL.md" ]; then
    continue
  fi

  root_link="$SKILLS_DIR/$skill_name"
  root_target="_sources/superpowers/skills/$skill_name"

  if [ -L "$root_link" ] && [ "$(readlink "$root_link")" = "$root_target" ]; then
    echo "  ✓ 根目錄：$skill_name (已存在)"
    continue
  fi

  if [ -e "$root_link" ] && [ ! -L "$root_link" ]; then
    echo -e "  ${YELLOW}⚠️  根目錄：$skill_name 已存在且非連結，略過${NC}"
    continue
  fi

  [ -L "$root_link" ] && rm "$root_link"
  ln -sf "$root_target" "$root_link"
  echo -e "  ${GREEN}✅ 根目錄：$skill_name (已建立)${NC}"
  ((synced_superpowers++))
done

# 4. 統計資訊
echo ""
echo -e "${GREEN}✅ 同步完成！${NC}"
echo ""
echo "📊 統計資訊："

# 計算 personal 技能數量（根目錄實體目錄且含 SKILL.md）
personal_count=$(find "$SOURCE_DIR" -mindepth 1 -maxdepth 1 -type d ! -name ".*" ! -name "_sources" ! -name "_claude" ! -name "claude" ! -name ".system" ! -name ".venv" -exec test -f "{}/SKILL.md" \; -print 2>/dev/null | wc -l | xargs)

# 計算 _claude 目錄中的連結數量
claude_links=$(find "$CLAUDE_DIR" -type l 2>/dev/null | wc -l | xargs)

# 計算根目錄中的 superpowers 符號連結數量
superpowers_links=$(find "$SKILLS_DIR" -maxdepth 1 -type l -exec readlink {} \; 2>/dev/null | grep "^_sources/superpowers" | wc -l | xargs)

echo "  - Personal 技能: $personal_count 個 (根目錄)"
echo "  - _claude/ 連結: $claude_links 個"
echo "  - 根目錄 superpowers 連結: $superpowers_links 個"

if [ $synced_claude -gt 0 ] || [ $synced_superpowers -gt 0 ]; then
  echo ""
  echo -e "${YELLOW}💡 提示：重新啟動 Claude Code 後生效${NC}"
fi
