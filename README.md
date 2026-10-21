# AirBeep 通话免提示音 · 操作检查卡

> 🌍 Languages: [English](README.en.md) | 简体中文

一套用于 **iOS 通话录音提示音消除（AirBeep）** 的开源技能，附带一张可直接在浏览器打开的「交互式操作检查卡」（**支持中英双语切换**），可安装到任意本地智能体。

## 这是什么

AirBeep 通过 macOS / Windows 端的 AirTraffic 沙盒逃逸路线，把 iOS 系统里「开始 / 停止通话录音」的提示音文件替换为等时长静音件，从而消除通话录音提示音。本技能把**部署**与**分步操作**打包成一张网页卡片，照着点就能走完整个流程。

> ⚠️ 法律与伦理：移除录音披露提示音会影响对方是否收到"正在录音"的通知。仅可在本人设备、当地法律允许、并已获对方知情 / 同意的情况下使用。

## 安装 —— 一行命令装到任意本地智能体

只要你的本地智能体具备终端，在它的对话里直接发送这一行即可自动克隆并安装（`install.sh` 会自动探测该智能体的技能目录，无需手动指定路径）：

```bash
curl -fsSL https://raw.githubusercontent.com/chrisacd980/airbeep-checklist-skill/main/install.sh | bash
```

安装后卡片会在默认浏览器自动打开，**并在系统生成「AirBeep测试」入口**（macOS：`~/Applications/AirBeep测试.app`；Windows：桌面 / 开始菜单「AirBeep测试」快捷方式），以后双击入口即可打开检查卡；重启 / 刷新智能体后技能生效。也可以手动克隆到对应智能体的技能目录下（目录名用 `airbeep`）：

```bash
git clone https://github.com/chrisacd980/airbeep-checklist-skill.git \
  <你的智能体技能目录>/airbeep
```

### 图形化安装包（Releases）
不想用命令行？到 [Releases](https://github.com/chrisacd980/airbeep-checklist-skill/releases) 下载：
- **macOS**：`AirBeep-macOS.dmg` —— 内含「AirBeep测试.app」，双击即在默认浏览器打开检查卡；
- **Windows**：`AirBeep-Setup.exe` —— 双击安装，自动创建「AirBeep测试」桌面 / 开始菜单快捷方式打开卡片。

## 使用

直接用浏览器打开技能目录里的检查卡（右上角可切换 中文 / EN）：

```bash
open <技能目录>/airbeep-checklist.html
```

检查卡（页面最顶端）还包含：

- **致谢文本框**：说明本卡片仅为原作者成果之上的卡片式操作外壳（文本框形式，不再用弹窗，避免遮挡按钮）。

检查卡主体包含：

1. **红色警示牌**：提醒关闭 iPhone 自动升级（升级到 iOS 27.2 正式版会导致方案失效）。
1b. **「注意事项」深色框（带图标）**：🛡️ 首次修改前自动备份原始提示音；📶 起止提示音替换为等长静音；🌐 更改系统语言可强制恢复原始提示音；⚠️ 依赖非公开系统行为，请谨慎使用。
2. **两个部署选项卡**（带 Logo）：
   - 🍎 **Mac（M 芯片）** → 下载 `deploy-airbeep-mac.sh`
   - 🪟 **Win 系统** → 下载 `deploy-airbeep-win.ps1`
3. **7 步操作检查卡**：手动检查 → 开发者模式 → 执行 AirBeep → 自行通话测试 → 重启后测试 → 关闭开发者模式 → 恢复原生方案。前 6 步按序点击；第 7 列「恢复原生方案」独立，点后除版本号与「已恢复」外全部变红。

## 关键事实

- 当前支持区间：**iOS/iPadOS 27.0 – 27.2 Beta 2**（来自上游仓库 README Requirements）。
- 漏洞会在 **iOS 27.2 正式版** 修补；正式版发布前务必关闭自动更新。
- 静音件不能照搬上游配套件，需按真机原件实际时长 / 格式生成。
- Windows 是上游**原生、作者端到端验证过**的路线（`source-patched/`）；macOS 路线为后续补充。

## 开源与跨智能体 / 通用性

本仓库采用 **GPL-3.0** 开源协议，欢迎 fork 与再分发。各智能体适配情况：

- **检查卡（airbeep-checklist.html）**：纯前端、零本地依赖、自包含。任何能打开网页的智能体（豆包 / Kimi / ChatGPT / Claude 等）或浏览器都能**直接展示**，不依赖任何特定平台。
- **知识文本（SKILL.md / README）**：路径均为相对技能目录的自适应写法，可整段粘进任意智能体的「知识库 / 系统提示 / 自定义指令」当作操作指南。
- **真正改写手机（airbeep.sh + 静音件）**：需要**在本机**（Mac / Win）运行的本地智能体才能执行——因为它要访问你连在电脑上的 iPhone。纯云端对话智能体（网页版 Kimi、豆包）可以"知道怎么做"，但**没有手**去改手机。
- 仓库已自带 `silence-assets/`（静音件 + 真·原生还原件），clone 一次即可完成「应用 + 恢复」全部操作，无需自行生成。

> 本地执行：在装好上游仓库与 venv 后，`bash airbeep.sh [status|apply|restore|verify]`。脚本**不写死任何路径**，自动搜索上游仓与 Python 环境。

## 上游参考

- https://github.com/jiutinglifeng/airbeep-calltone-research （fork / 研究仓，含 macOS 路线实测与中文文档）
- License：GPL-3.0
