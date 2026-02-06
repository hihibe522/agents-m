#!/bin/bash

# AI 配置文件連結管理腳本
# 用途：統一管理 Claude、Gemini、Codex 的配置文件

set -e  # 遇到錯誤時停止執行

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 腳本所在目錄（.agents 目錄）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 工具函數
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# 建立符號連結的函數
# 參數: $1=源路徑, $2=目標路徑, $3=描述
create_symlink() {
    local source="$1"
    local target="$2"
    local description="$3"

    # 檢查源文件/目錄是否存在
    if [ ! -e "$source" ]; then
        log_warning "源不存在，跳過: $description"
        log_warning "  源: $source"
        return 1
    fi

    # 確保目標目錄存在
    local target_dir=$(dirname "$target")
    if [ ! -d "$target_dir" ]; then
        log_info "建立目標目錄: $target_dir"
        mkdir -p "$target_dir"
    fi

    # 檢查目標是否已存在
    if [ -e "$target" ] || [ -L "$target" ]; then
        # 檢查是否已經是正確的符號連結
        if [ -L "$target" ]; then
            local current_source=$(readlink "$target")
            if [ "$current_source" = "$source" ]; then
                log_success "已存在正確的連結: $description"
                return 0
            fi
        fi

        # 備份現有文件
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        log_warning "目標已存在，備份至: $backup"
        mv "$target" "$backup"
    fi

    # 建立符號連結
    ln -s "$source" "$target"
    log_success "建立連結: $description"
    log_info "  $source → $target"
}

# 建立帶後備選項的連結
# 優先使用特定文件，不存在時使用 AGENTS.md
create_config_link_with_fallback() {
    local specific_file="$1"
    local fallback_file="$2"
    local target="$3"
    local description="$4"

    if [ -e "$specific_file" ]; then
        create_symlink "$specific_file" "$target" "$description (專用)"
    elif [ -e "$fallback_file" ]; then
        create_symlink "$fallback_file" "$target" "$description (使用 AGENTS.md)"
    else
        log_warning "找不到配置文件: $description"
    fi
}

echo "=========================================="
echo "  AI 配置文件連結管理"
echo "=========================================="
echo ""

# 1. 配置文件連結
log_info "步驟 1/4: 建立配置文件連結"
echo ""

create_config_link_with_fallback \
    "$SCRIPT_DIR/CLAUDE.md" \
    "$SCRIPT_DIR/AGENTS.md" \
    "$HOME/.claude/CLAUDE.md" \
    "Claude 配置文件"

create_config_link_with_fallback \
    "$SCRIPT_DIR/GEMINI.md" \
    "$SCRIPT_DIR/AGENTS.md" \
    "$HOME/.gemini/GEMINI.md" \
    "Gemini 配置文件"

create_symlink \
    "$SCRIPT_DIR/AGENTS.md" \
    "$HOME/.codex/AGENTS.md" \
    "Codex 配置文件"

echo ""

# 2. Commands 目錄連結
log_info "步驟 2/4: 建立 commands 目錄連結"
echo ""

if [ -d "$SCRIPT_DIR/commands" ]; then
    create_symlink \
        "$SCRIPT_DIR/commands" \
        "$HOME/.claude/commands" \
        "Claude commands"

    create_symlink \
        "$SCRIPT_DIR/commands" \
        "$HOME/.codex/prompts" \
        "Codex prompts"

    create_symlink \
        "$SCRIPT_DIR/commands" \
        "$HOME/.gemini/commands" \
        "Gemini commands"
else
    log_warning "找不到 commands 目錄: $SCRIPT_DIR/commands"
fi

echo ""

# 3. Hooks 目錄連結
log_info "步驟 3/4: 建立 hooks 目錄連結"
echo ""

if [ -d "$SCRIPT_DIR/hooks" ]; then
    create_symlink \
        "$SCRIPT_DIR/hooks" \
        "$HOME/.claude/hooks" \
        "Claude hooks"
else
    log_warning "找不到 hooks 目錄: $SCRIPT_DIR/hooks"
fi

echo ""

# 4. Skills 目錄連結
log_info "步驟 4/4: 建立 skills 目錄連結"
echo ""

if [ -d "$SCRIPT_DIR/skills/_claude" ]; then
    create_symlink \
        "$SCRIPT_DIR/skills/_claude" \
        "$HOME/.claude/skills" \
        "Claude skills"
else
    log_warning "找不到 Claude skills 目錄: $SCRIPT_DIR/skills/_claude"
fi

if [ -d "$SCRIPT_DIR/skills" ]; then
    create_symlink \
        "$SCRIPT_DIR/skills" \
        "$HOME/.codex/skills" \
        "Codex skills"

    create_symlink \
        "$SCRIPT_DIR/skills" \
        "$HOME/.gemini/skills" \
        "Gemini skills"
else
    log_warning "找不到 skills 目錄: $SCRIPT_DIR/skills"
fi

echo ""
echo "=========================================="
log_success "配置連結建立完成！"
echo "=========================================="
