# AirBeep Operation Checklist · WorkBuddy Skill

> 🌍 Languages: English | [简体中文](README.md)

A WorkBuddy skill for **silencing iOS call-recording disclosure tones (AirBeep)**, bundled with an interactive browser checklist (**Chinese / English toggle**).

## What is this

AirBeep uses the AirTraffic sandbox-escape route (macOS / Windows) to replace the iOS system's "start / stop call recording" tone files with equal-length silent assets, removing the disclosure tones. This skill packs **deployment** and **step-by-step operation** into a single web card.

> ⚠️ Legal & ethics: removing the disclosure tone affects whether the other party is notified that a call is being recorded. Use only on your own device, where local law permits, and with the other party's informed consent.

## Install — one line for ANY local agent

If your local agent (WorkBuddy / CodeBuddy / Claude Code / Cursor / Tongyi Qianwen / Aider, etc.) has a terminal, just send this line in its chat — it auto-clones and installs:

```bash
curl -fsSL https://raw.githubusercontent.com/chrisacd980/airbeep-checklist-skill/main/install.sh | bash
```

`install.sh` auto-detects common agents' skills directories (`.workbuddy` / `.codebuddy` / `.claude` / `.cursor` / `.qwen` / `.aider`) and falls back to the WorkBuddy path. Restart / refresh the agent afterward.

> Or clone manually (equivalent to the script's fallback path):
> ```bash
> git clone https://github.com/chrisacd980/airbeep-checklist-skill.git \
>   ~/.workbuddy/skills/airbeep
> ```

Restart / refresh your WorkBuddy session and `airbeep` appears under “My Skills”.

## Usage

Open the checklist in a browser (use the 中文 / EN toggle at the top right):

```
open ~/.workbuddy/skills/airbeep/airbeep-checklist.html
```

The checklist (at the very top of the page) also includes:

- **Credit text box**: notes that this card only adds a card-style operation shell on top of the original author's work (now a text box, not a popup, so it never blocks the buttons).

The checklist body includes:

1. **Red warning banner**: keep iPhone automatic updates OFF (upgrading to iOS 27.2 final breaks the method).
2. **Two deploy tabs** (with logos):
   - 🍎 **Mac (M-series)** → download `deploy-airbeep-mac.sh`
   - 🪟 **Windows** → download `deploy-airbeep-win.ps1`
3. **7-step operation checklist**: Check → Developer Mode → Run AirBeep → Call Test → Reboot Test → Turn Dev Mode Off → Restore Original. The first 6 must be clicked in order; column 7 is independent — clicking “Restore Original” turns everything red except the version number and “Restored”.

## Key facts

- Current supported range: **iOS/iPadOS 27.0 – 27.2 Beta 2** (from the upstream repo README Requirements).
- The vulnerability is patched in **iOS 27.2 final**; keep automatic updates off until then.
- Silent assets must be generated from your own device's dumped originals (duration/format must match).
- Windows is the upstream's **original, author-verified** route (`source-patched/`); the macOS route was added later.

## Open source & cross-agent portability

This repo is **GPL-3.0** open source — forks and redistribution are welcome. Agent compatibility:

- **Checklist (airbeep-checklist.html)**: pure frontend, zero local dependencies, self-contained. Any agent that can open a web page (Doubao / Kimi / ChatGPT / Claude, etc.) or any browser can **display it directly**, with no platform lock-in.
- **Knowledge text (SKILL.md / README)**: after stripping WorkBuddy's frontmatter, it can be pasted wholesale into any agent's "knowledge base / system prompt / custom instructions" as an operating guide.
- **Actually modifying the phone (airbeep.sh + silent assets)**: requires a **local** agent running on your own machine (Mac / Win) — e.g. WorkBuddy, Claude Code — because it must reach the iPhone connected to your computer. Pure cloud chat agents (web Kimi, Doubao) can "know how" but have **no hands** to touch the phone.
- The repo bundles `silence-assets/` (silent assets + true native restore files), so a single clone completes both "apply" and "restore" — no need to generate assets yourself.

> Local execution: after cloning the upstream repo and creating the venv, run `bash airbeep.sh [status|apply|restore|verify]`. The script **hardcodes no paths** and auto-detects the upstream repo and Python environment.

## Upstream reference

- https://github.com/jiutinglifeng/airbeep-calltone-research (fork / research repo, macOS route field notes)
- License: GPL-3.0
