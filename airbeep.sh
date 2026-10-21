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
PROJ="/Users/chris/WorkBuddy/2026-10-21-13-40-57"
AIRLIFT="$PROJ/airbeep-calltone-research/artifacts/airliftsilence/macos-port/airlift.py"
VENV="$PROJ/.venv/bin/python"
BAK="$PROJ/airbeep-calltone-research/artifacts/airliftsilence"
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
