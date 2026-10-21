# AirBeep Operation Checklist · WorkBuddy Skill

> 🌍 Languages: English | [简体中文](README.md)

A WorkBuddy skill for **silencing iOS call-recording disclosure tones (AirBeep)**, bundled with an interactive browser checklist (**Chinese / English toggle**).

## What is this

AirBeep uses the AirTraffic sandbox-escape route (macOS / Windows) to replace the iOS system's "start / stop call recording" tone files with equal-length silent assets, removing the disclosure tones. This skill packs **deployment** and **step-by-step operation** into a single web card.

> ⚠️ Legal & ethics: removing the disclosure tone affects whether the other party is notified that a call is being recorded. Use only on your own device, where local law permits, and with the other party's informed consent.

## Install (as a WorkBuddy user-level skill)

```bash
git clone https://github.com/ChrisCD/airbeep-checklist-skill.git \
  ~/.workbuddy/skills/airbeep
```

Restart / refresh your WorkBuddy session and `airbeep` appears under “My Skills”.

## Usage

Open the checklist in a browser (use the 中文 / EN toggle at the top right):

```
open ~/.workbuddy/skills/airbeep/airbeep-checklist.html
```

The checklist includes:

1. **Red warning banner**: keep iPhone automatic updates OFF (upgrading to iOS 27.2 final breaks the method).
2. **Two deploy tabs** (with logos):
   - 🍎 **Mac (M-series)** → download `deploy-airbeep-mac.sh`
   - 🪟 **Windows** → download `deploy-airbeep-win.ps1`
3. **6-step operation checklist**: Check → Developer Mode → Run AirBeep → Call Test → Reboot Test → Restore Original. The first 5 must be clicked in order; column 6 is independent — clicking “Restore Original” turns everything red except the version number and “Restored”.

## Key facts

- Current supported range: **iOS/iPadOS 27.0 – 27.2 Beta 2** (from the upstream repo README Requirements).
- The vulnerability is patched in **iOS 27.2 final**; keep automatic updates off until then.
- Silent assets must be generated from your own device's dumped originals (duration/format must match).
- Windows is the upstream's **original, author-verified** route (`source-patched/`); the macOS route was added later.

## Upstream reference

- https://github.com/jiutinglifeng/airbeep-calltone-research (fork / research repo, macOS route field notes)
- License: GPL-3.0
