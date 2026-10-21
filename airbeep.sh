#!/usr/bin/env bash
# AirBeep 可执行版 —— 直接在你的 Mac 上改写 iPhone 通话录音提示音
# 用法:  airbeep [status|apply|restore|verify]
#   status  读取手机当前文件并与静音件/原生件比对，报告 SILENT/NATIVE/其他
#   apply   用技能自带静音件替换（带 --backup 自动备份），再校验
#   restore 用技能自带真·原生件还原（带 --backup 自动备份），再校验
#   verify  仅读回比对哈希
# 依赖: 本项目 .venv 已装 pymobiledevice3；iPhone 用数据线连 Mac 并已信任。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS="$SCRIPT_DIR/silence-assets"

# --- 可移植路径解析（不写死任何机器绝对路径）---
# 上游研究仓与 Python venv 的位置优先用环境变量覆盖：
#   AIRBEEP_PROJ  指向克隆的 airbeep-calltone-research 仓库目录
#   AIRBEEP_VENV  指向已安装 pymobiledevice3 的 python 解释器
# 未设置时，从脚本目录 / 当前目录 / 家目录向上自动搜索常见位置。
find_repo() {
  local d="$1"
  while [ -n "$d" ] && [ "$d" != "/" ]; do
    if [ -d "$d/airbeep-calltone-research/artifacts/airliftsilence/macos-port" ]; then
      echo "$d/airbeep-calltone-research"; return 0
    fi
    d="$(dirname "$d")"
  done
  return 1
}
PROJ="${AIRBEEP_PROJ:-}"
if [ -z "$PROJ" ]; then
  for base in "$SCRIPT_DIR" "$PWD" "$HOME"; do
    if PROJ="$(find_repo "$base")"; then break; fi
  done
fi
if [ -z "$PROJ" ]; then
  echo "✗ 未找到 airbeep-calltone-research 仓库。" >&2
  echo "  请先运行卡片里的部署脚本克隆上游，或设置： export AIRBEEP_PROJ=/你的/项目路径" >&2
  exit 1
fi

AIRLIFT="$PROJ/artifacts/airliftsilence/macos-port/airlift.py"
BAK="$PROJ/artifacts/airliftsilence"

VENV="${AIRBEEP_VENV:-}"
if [ -z "$VENV" ]; then
  for cand in "$PROJ/.venv/bin/python" "$(dirname "$PROJ")/.venv/bin/python" "$SCRIPT_DIR/.venv/bin/python" "$(command -v python3)"; do
    if [ -n "$cand" ] && "$cand" -c "import pymobiledevice3" >/dev/null 2>&1; then VENV="$cand"; break; fi
  done
fi
if [ -z "$VENV" ]; then
  echo "✗ 未找到已安装 pymobiledevice3 的 Python。" >&2
  echo "  请运行卡片部署脚本创建 venv，或设置： export AIRBEEP_VENV=/path/to/venv/bin/python" >&2
  exit 1
fi
UDID="${AIRBEEP_UDID:-}"

START_PATH="/var/mobile/Library/CallServices/Greetings/default/StartDisclosureWithTone.m4a"
STOP_PATH="/var/mobile/Library/CallServices/Greetings/default/StopDisclosure.caf"

PYRUN() { "$VENV" "$AIRLIFT" "$@"; }
hash_of() { shasum "$1" 2>/dev/null | awk '{print $1}'; }

detect_udid() {
  if [ -z "$UDID" ]; then
    UDID=$("$VENV" -m pymobiledevice3 usbmux list 2>/dev/null | grep -oE '[a-fA-F0-9]{8}-[a-fA-F0-9]{16}' | head -1 || true)
  fi
  if [ -z "$UDID" ]; then echo "✗ 未检测到 iPhone（请连数据线并信任本机）" >&2; exit 1; fi
  echo "设备 UDID: $UDID" >&2
}

status() {
  detect_udid
  local tmp; tmp=$(mktemp -d)
  PYRUN read "$START_PATH" "$tmp/s.m4a" --device "$UDID" --logging >/dev/null 2>&1
  PYRUN read "$STOP_PATH"  "$tmp/o.caf" --device "$UDID" --logging >/dev/null 2>&1
  local hs; hs=$(hash_of "$tmp/s.m4a"); local ho; ho=$(hash_of "$tmp/o.caf")
  local ss; ss=$(hash_of "$ASSETS/my-silent-StartDisclosureWithTone.m4a")
  local so; so=$(hash_of "$ASSETS/my-silent-StopDisclosure.caf")
  local ns; ns=$(hash_of "$ASSETS/native-restore-StartDisclosureWithTone.m4a")
  local no; no=$(hash_of "$ASSETS/native-restore-StopDisclosure.caf")
  echo "Start : device=$hs"; echo "         silent=$ss  native=$ns"
  echo "Stop  : device=$ho"; echo "         silent=$so  native=$no"
  if [ "$hs" = "$ss" ] && [ "$ho" = "$so" ]; then echo ">>> 当前状态：静音 (SILENT)"
  elif [ "$hs" = "$ns" ] && [ "$ho" = "$no" ]; then echo ">>> 当前状态：原生 (NATIVE)"
  else echo ">>> 当前状态：未知/其他"; fi
  rm -rf "$tmp"
}

verify() {
  detect_udid
  local tmp; tmp=$(mktemp -d)
  PYRUN read "$START_PATH" "$tmp/s.m4a" --device "$UDID" --logging >/dev/null 2>&1
  PYRUN read "$STOP_PATH"  "$tmp/o.caf" --device "$UDID" --logging >/dev/null 2>&1
  local hs; hs=$(hash_of "$tmp/s.m4a"); local ho; ho=$(hash_of "$tmp/o.caf")
  local ss; ss=$(hash_of "$ASSETS/my-silent-StartDisclosureWithTone.m4a")
  local so; so=$(hash_of "$ASSETS/my-silent-StopDisclosure.caf")
  echo "Start 回读=$hs  静音件=$ss  $([ "$hs" = "$ss" ] && echo OK || echo 不一致!)"
  echo "Stop  回读=$ho  静音件=$so  $([ "$ho" = "$so" ] && echo OK || echo 不一致!)"
  rm -rf "$tmp"
}

apply() {
  detect_udid
  echo "⚠ 法律提示：仅限本人设备、当地法律允许、且已获通话对方知情同意时使用。"
  echo ">> 应用静音件（replace + 自动备份）..."
  PYRUN replace "$START_PATH" "$ASSETS/my-silent-StartDisclosureWithTone.m4a" --backup "$BAK/apply_prev_Start.m4a" --device "$UDID" --logging 2>&1 | tail -2
  PYRUN replace "$STOP_PATH"  "$ASSETS/my-silent-StopDisclosure.caf"          --backup "$BAK/apply_prev_Stop.caf"  --device "$UDID" --logging 2>&1 | tail -2
  verify
}

restore() {
  detect_udid
  echo ">> 恢复原生件（replace + 自动备份）..."
  PYRUN replace "$START_PATH" "$ASSETS/native-restore-StartDisclosureWithTone.m4a" --backup "$BAK/restore_prev_Start.m4a" --device "$UDID" --logging 2>&1 | tail -2
  PYRUN replace "$STOP_PATH"  "$ASSETS/native-restore-StopDisclosure.caf"          --backup "$BAK/restore_prev_Stop.caf"  --device "$UDID" --logging 2>&1 | tail -2
  verify
}

case "${1:-status}" in
  status)  status ;;
  apply)   apply ;;
  restore) restore ;;
  verify)  verify ;;
  *) echo "用法: airbeep [status|apply|restore|verify]"; exit 1 ;;
esac
