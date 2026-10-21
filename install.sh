#!/usr/bin/env bash
# ==============================================================================
#  AirBeep 技能一键安装器 / One-line installer for the AirBeep skill
#  用法 / Usage:
#    curl -fsSL https://raw.githubusercontent.com/chrisacd980/airbeep-checklist-skill/main/install.sh | bash
#  适配任意本地智能体（具备终端/代码执行能力）：
#    WorkBuddy · CodeBuddy · Claude Code · Cursor · 通义灵码 · Aider 等
#  纯云端聊天机器人（如豆包网页版 / Kimi 网页版）无法执行 Shell，
#  但可按 README 手动克隆仓库使用卡片与脚本。
# ==============================================================================
set -euo pipefail

REPO="https://github.com/chrisacd980/airbeep-checklist-skill"
SKILL_NAME="airbeep"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "📦 AirBeep 技能安装器 / AirBeep skill installer"

# 1) 克隆技能仓库 / clone the skill repo
git clone --depth 1 "$REPO" "$TMP/repo" >/dev/null 2>&1 || {
  echo "❌ git clone 失败，请检查网络或仓库地址 / git clone failed"; exit 1
}
rm -rf "$TMP/repo/.git"

# 2) 探测本地智能体的 skills 目录 / detect the local agent's skills directory
TARGET=""
if [ -d "$HOME/.workbuddy/skills" ]; then TARGET="$HOME/.workbuddy/skills"; fi
if [ -d "$HOME/.codebuddy/skills" ];  then TARGET="$HOME/.codebuddy/skills"; fi
if [ -d "$HOME/.claude/skills" ];     then TARGET="$HOME/.claude/skills"; fi
if [ -d "$HOME/.cursor/skills" ];     then TARGET="$HOME/.cursor/skills"; fi
if [ -d "$HOME/.qwen/skills" ];       then TARGET="$HOME/.qwen/skills"; fi
if [ -d "$HOME/.aider/skills" ];      then TARGET="$HOME/.aider/skills"; fi

# 兜底：使用 WorkBuddy 路径（最通用）/ fallback to the most common path
if [ -z "$TARGET" ]; then
  TARGET="$HOME/.workbuddy/skills"
  mkdir -p "$TARGET"
fi

# 3) 复制技能到 skills 目录 / copy the skill into the skills directory
mkdir -p "$TARGET/$SKILL_NAME"
cp -R "$TMP/repo/." "$TARGET/$SKILL_NAME/" 2>/dev/null || cp -R "$TMP/repo"/* "$TARGET/$SKILL_NAME/"

# 让 CLI 可执行 / make the CLI executable
chmod +x "$TARGET/$SKILL_NAME/airbeep.sh" 2>/dev/null || true

echo "✅ 已安装到 / Installed to: $TARGET/$SKILL_NAME"
echo "🔄 请重启（或刷新）你的智能体，技能即可生效 / Please restart/refresh your agent to load the skill."
echo "📑 之后在对话里说：\"用 airbeep 技能消除 iPhone 通话录音提示音\""
echo "    / Then say: use the airbeep skill to silence iOS call-recording tones."
