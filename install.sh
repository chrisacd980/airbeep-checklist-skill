#!/usr/bin/env bash
# ==============================================================================
#  AirBeep 技能一键安装器 / One-line installer for the AirBeep skill
#  用法 / Usage:
#    curl -fsSL https://raw.githubusercontent.com/chrisacd980/airbeep-checklist-skill/main/install.sh | bash
#  适配任意本地智能体（具备终端/代码执行能力），自动探测其技能目录。
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

# 兜底：未探测到已知技能目录时，装到中性目录并提示 / fallback when no known skills dir found
if [ -z "$TARGET" ]; then
  TARGET="$HOME/.skills"
  mkdir -p "$TARGET"
  echo "ℹ️  未探测到已知智能体技能目录，已选择 $TARGET 作为安装位置。"
  echo "    / No known agent skills directory detected; using $TARGET."
  echo "    如你的智能体有专属技能目录，可随后将 airbeep 文件夹移动过去。"
  echo "    / If your agent has its own skills directory, move the airbeep folder there."
fi

# 3) 复制技能到 skills 目录 / copy the skill into the skills directory
mkdir -p "$TARGET/$SKILL_NAME"
cp -R "$TMP/repo/." "$TARGET/$SKILL_NAME/" 2>/dev/null || cp -R "$TMP/repo"/* "$TARGET/$SKILL_NAME/"

# 让 CLI 可执行 / make the CLI executable
chmod +x "$TARGET/$SKILL_NAME/airbeep.sh" 2>/dev/null || true

# 5) 在系统生成入口（openfilm 模式）：macOS 编译 AirBeep测试.app；Windows 创建快捷方式
#    create the system entry: macOS builds AirBeep测试.app; Windows creates shortcuts
APP_NAME="AirBeep测试"
case "$(uname -s)" in
  Darwin)
    if command -v osacompile >/dev/null 2>&1 && [ -f "$TARGET/$SKILL_NAME/packaging/build-app.applescript" ]; then
      APPDIR="$HOME/Applications"
      mkdir -p "$APPDIR"
      TMPAPP="$(mktemp -d)/$APP_NAME.app"
      if osacompile -o "$TMPAPP" "$TARGET/$SKILL_NAME/packaging/build-app.applescript" >/dev/null 2>&1; then
        mkdir -p "$TMPAPP/Contents/Resources"
        cp "$TARGET/$SKILL_NAME/airbeep-checklist.html" "$TMPAPP/Contents/Resources/"
        rm -rf "$APPDIR/$APP_NAME.app" 2>/dev/null || true
        if cp -R "$TMPAPP" "$APPDIR/$APP_NAME.app"; then
          echo "🖥️  已在 ~/Applications 生成「$APP_NAME.app」——以后双击它即可打开检查卡"
          echo "    / Created $APP_NAME.app in ~/Applications — double-click it to open the checklist."
        fi
      fi
    fi
    ;;
  MINGW*|MSYS*|CYGWIN*)
    if command -v powershell.exe >/dev/null 2>&1 && [ -f "$TARGET/$SKILL_NAME/packaging/create-shortcuts.ps1" ]; then
      if powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(cygpath -w "$TARGET/$SKILL_NAME/packaging/create-shortcuts.ps1")" -CardPath "$(cygpath -w "$TARGET/$SKILL_NAME/airbeep-checklist.html")" >/dev/null 2>&1; then
        echo "🖥️  已在桌面和开始菜单创建「$APP_NAME」快捷方式——以后双击它即可打开检查卡"
        echo "    / Created \"$APP_NAME\" shortcuts on Desktop and Start Menu — double-click to open the checklist."
      fi
    fi
    ;;
esac

# 6) 装完直接用默认浏览器打开检查卡 / open the checklist in the default browser right away
CARD="$TARGET/$SKILL_NAME/airbeep-checklist.html"
echo ""
echo "🌐 正在打开操作检查卡 / Opening the operation checklist..."
if command -v open >/dev/null 2>&1; then
  open "$CARD" 2>/dev/null || true                    # macOS
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$CARD" >/dev/null 2>&1 || true            # Linux
elif command -v powershell >/dev/null 2>&1; then
  powershell -NoProfile -Command "Start-Process '$CARD'" >/dev/null 2>&1 || true  # Windows
else
  echo "ℹ️  未能自动打开，请手动用浏览器打开 / open it manually:"
  echo "    $CARD"
fi

echo ""
echo "✅ 已安装到 / Installed to: $TARGET/$SKILL_NAME"
echo "🔄 请重启（或刷新）你的智能体，技能即可生效 / Please restart/refresh your agent to load the skill."
echo "📑 之后在对话里说：\"用 airbeep 技能消除 iPhone 通话录音提示音\""
echo "    / Then say: use the airbeep skill to silence iOS call-recording tones."
