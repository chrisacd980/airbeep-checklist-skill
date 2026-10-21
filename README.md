# AirBeep 操作检查卡 · WorkBuddy 技能

> 🌍 Languages: [English](README.en.md) | 简体中文

一个用于 **iOS 通话录音提示音消除（AirBeep）** 的 WorkBuddy 技能，附带一张可直接在浏览器打开的「交互式操作检查卡」（**支持中英双语切换**）。

## 这是什么

AirBeep 通过 macOS / Windows 端的 AirTraffic 沙盒逃逸路线，把 iOS 系统里「开始 / 停止通话录音」的提示音文件替换为等时长静音件，从而消除通话录音提示音。本技能把**部署**与**分步操作**打包成一张网页卡片，照着点就能走完整个流程。

> ⚠️ 法律与伦理：移除录音披露提示音会影响对方是否收到"正在录音"的通知。仅可在本人设备、当地法律允许、并已获对方知情 / 同意的情况下使用。

## 安装（作为 WorkBuddy 用户级技能）

```bash
git clone https://github.com/chrisacd980/airbeep-checklist-skill.git \
  ~/.workbuddy/skills/airbeep
```

克隆后重启 / 刷新 WorkBuddy 会话即可在「我的技能」中看到 `airbeep`。

## 使用

直接用浏览器打开技能目录里的检查卡（右上角可切换 中文 / EN）：

```
open ~/.workbuddy/skills/airbeep/airbeep-checklist.html
```

检查卡包含：

1. **红色警示牌**：提醒关闭 iPhone 自动升级（升级到 iOS 27.2 正式版会导致方案失效）。
2. **两个部署选项卡**（带 Logo）：
   - 🍎 **Mac（M 芯片）** → 下载 `deploy-airbeep-mac.sh`
   - 🪟 **Win 系统** → 下载 `deploy-airbeep-win.ps1`
3. **6 步操作检查卡**：手动检查 → 开发者模式 → 执行 AirBeep → 自行通话测试 → 重启后测试 → 恢复原生方案。前 5 步按序点击；第 6 列独立，「恢复原生方案」点后除版本号与「已恢复」外全部变红。

## 关键事实

- 当前支持区间：**iOS/iPadOS 27.0 – 27.2 Beta 2**（来自上游仓库 README Requirements）。
- 漏洞会在 **iOS 27.2 正式版** 修补；正式版发布前务必关闭自动更新。
- 静音件不能照搬上游配套件，需按真机原件实际时长 / 格式生成。
- Windows 是上游**原生、作者端到端验证过**的路线（`source-patched/`）；macOS 路线为后续补充。

## 上游参考

- https://github.com/jiutinglifeng/airbeep-calltone-research （fork / 研究仓，含 macOS 路线实测与中文文档）
- License：GPL-3.0
