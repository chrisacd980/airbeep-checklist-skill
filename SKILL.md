---
name: airbeep
description: iOS 通话录音提示音消除（AirBeep）。当用户要在 iPhone 上消除/恢复通话录音的"开始/停止"提示音、提到 AirBeep / airlift / 静音件 / iOS 27.x 通话录音提示音，或想检查 AirBeep 对当前 iOS 版本的支持情况时，使用本技能。
---

# AirBeep — iOS 通话录音提示音消除

## 这是什么
AirBeep 通过 **macOS 端 AirTraffic 沙盒逃逸路线**，把 iOS 系统里"开始/停止通话录音"的提示音文件替换为等时长静音件，从而消除通话录音提示音。它不是普通 App，需要 **Mac + 数据线 + 已配对的 iPhone**，靠 `airlift.py` 改写手机系统文件。

## 上游参考仓库（每日监测来源）
- 仓库：https://github.com/jiutinglifeng/airbeep-calltone-research （fork/研究仓，含 macOS 路线实测与中文文档）
- 默认分支：`main`
- 上游依赖：AirliftSilence（静音件素材）、airlift（AirTraffic/Airlock 研究）、Placard（iOS 工程结构）
- 最新 release：v2.4.0（2026-10-10，"remove launch tone-state check; recovery via language change"）
- License：GPL-3.0

### 当前支持版本（2026-10-21 核对 README Requirements）
- **iOS/iPadOS 27.0 – 27.2 B2**
- 关键 commit（2026-10-16）：在真实 iPhone 19,7 / iOS 27.0.1 (24A446) 端到端跑通 macOS 路线；commit（2026-10-09）："fix iOS 27.0.1 read, support iOS 18-27.2B2"

## 必须遵守的关键事实
1. **漏洞会在 iOS 27.2 正式版修补**（预计 2026-10-26 那周）。升级到 27.2 正式版后方法失效，需作者更新绕过。→ 动手前必须确认设备仍是 27.2 B2 且**已关闭自动更新**。
2. **静音件不能照搬上游配套件**。必须先 `read` dump 真机原件，再按实际时长/格式生成静音件（否则时长不匹配——实测 StopDisclosure.caf 为 Opus 48k 1.52s，上游配套件 1.94s，差 420ms）。`静音件生成.sh` 是关键工具。
3. 设备实测（Chris）：iPhone17,1 · iOS 27.2 beta 2 (24B5089g)，macOS 路线端到端跑通，**重启后静音持久**。
4. 用 `silent-ios-format/` 的 iOS 格式静音件，不要用 `macos-port/silent/` 的 Windows 版。

## 本地项目结构（操作前需有项目副本）
- `AIRBEEP-RUN.md` — 完整步骤 0–5、回滚、失败救援、常见坑（**首选阅读**）
- `airbeep-calltone-research/macos-port/airlift.py` — macOS 路线脚本（已含 `from pathlib import Path` 与 `AIRLIFT_PAIRING_CACHE` 修复）
- `airbeep-calltone-research/artifacts/airliftsilence/`
  - `device-backup-*.caf / .m4a` — replace 前真机原件备份，**回滚唯一保障，必须保留**
  - `my-silent-*.caf / .m4a` — 按设备原件生成的静音件
  - `静音件生成.sh`、`设备体检.py`、`演练-救援流程.py` — 工具脚本

## macOS 路线核心命令（在装好 pymobiledevice3 的 venv 中运行）
```bash
# 1) 设备体检（确认无 airlift-* 残留、设备可连）
python 设备体检.py
# 2) read dump 原件（两条路径都读）
airlift.py read /var/mobile/Library/CallServices/Greetings/default/StartDisclosureWithTone.m4a start_dump.m4a --logging
airlift.py read /var/mobile/Library/CallServices/Greetings/default/StopDisclosure.caf stop_dump.caf --logging
# 3) 按 dump 实际时长/格式生成静音件（静音件生成.sh）
# 4) replace 替换（自动备份原件到 --backup）
airlift.py replace /var/mobile/Library/CallServices/Greetings/default/StartDisclosureWithTone.m4a my-silent-StartDisclosureWithTone.m4a --backup start_prev.m4a --logging
airlift.py replace /var/mobile/Library/CallServices/Greetings/default/StopDisclosure.caf my-silent-StopDisclosure.caf --backup stop_prev.caf --logging
# 5) 验证：再次 read 比对哈希
# 回滚（如需恢复）：
airlift.py write /var/mobile/Library/CallServices/Greetings/default/StartDisclosureWithTone.m4a device-backup-StartDisclosureWithTone.m4a --logging
airlift.py write /var/mobile/Library/CallServices/Greetings/default/StopDisclosure.caf device-backup-StopDisclosure.caf --logging
```

## 法律与伦理（务必告知用户）
移除录音披露提示音会影响对方是否收到"正在录音"通知。仅可在**本人设备**、且**当地法律允许**、并已获对方**知情/同意**的情况下使用。每次操作前都要提醒用户此风险。

## 交互式操作检查卡（airbeep-checklist.html）
随技能附带的 `airbeep-checklist.html` 是可直接在浏览器打开的操作向导，包含：
- 顶部红色警示牌：提醒**关闭 iPhone 自动升级**（升级到 iOS 27.2 正式版会导致方案失效）。
- 两个带 Logo 部署选项卡：**Mac（M 芯片）** 与 **Win 系统**，各自提供对应系统的「下载部署脚本」按钮（`.sh` / `.ps1`）。
- 下方 6 步操作检查卡：① 手动检查（自动抓取 GitHub README 显示支持版本区间，如 `27.0 – 27.2 Beta 2`）② 开发者模式（已开启并连接电脑）③ 执行 AirBeep（已执行）④ 自行通话测试（通话测试，二选一：成功／未成功）⑤ 重启后测试（重启测试，二选一）⑥ 恢复原生方案（已恢复，独立列）。前 5 步需按序点击；第 6 列随时可点，点后除版本号与「已恢复」外全部变红。
- 打开方式：浏览器直接打开 `airbeep-checklist.html` 即可（无需服务器）。

## 版本监测
不再依赖每日自动化。用户点检查卡里的「手动检查」按钮时，技能会实时抓取仓库 README 的 Requirements 支持区间并展示版本号；或需要时重新用 WebFetch 抓取仓库核对。用户问"AirBeep 现在支持哪个 iOS 版本"时，优先用「手动检查」结果或重新抓取仓库。
