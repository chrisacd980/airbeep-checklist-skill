#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""AirBeep 本地运行时 / AirBeep local runtime.

让检查卡（airbeep-checklist.html）可以直接在本机执行真机操作：
  设备状态(status) / 执行静音(apply) / 恢复原生(restore) / 校验(verify)
以及环境检测与一键配置(env / setup)。

只用 Python 标准库；通过调用同目录的 airbeep.sh 完成实际操作。

用法：
  python3 airbeep-desktop.py [--port 8765]
  然后浏览器打开 http://127.0.0.1:8765/airbeep-checklist.html
"""
import json
import os
import shutil
import subprocess
import sys
import threading
import time
import webbrowser
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from urllib.parse import urlparse

HERE = os.path.dirname(os.path.abspath(__file__))
PORT = int(os.environ.get("AIRBEEP_PORT", "8765"))
VENV = os.path.join(HERE, ".venv-desktop")                 # 本运行时自建的 venv
UPSTREAM = os.path.join(HERE, "airbeep-calltone-research")  # 上游研究仓（含 airlift.py）
UPSTREAM_URL = "https://github.com/jiutinglifeng/airbeep-calltone-research"


def sh(cmd, timeout=900, env=None):
    """运行命令，返回 (输出, 返回码)。"""
    try:
        p = subprocess.run(cmd, capture_output=True, text=True,
                           timeout=timeout, cwd=HERE, env=env)
        return (p.stdout or "") + (p.stderr or ""), p.returncode
    except Exception as e:  # noqa: BLE001
        return "%s: %s" % (type(e).__name__, e), 1


def skill_env():
    """给 airbeep.sh 注入本运行时的 venv 与上游仓路径。"""
    env = dict(os.environ)
    if os.path.isdir(VENV):
        env["AIRBEEP_VENV"] = VENV
    if os.path.isdir(UPSTREAM):
        env["AIRBEEP_PROJ"] = UPSTREAM
    return env


def run_skill(sub):
    out, rc = sh(["bash", os.path.join(HERE, "airbeep.sh"), sub], env=skill_env())
    return out, rc


def probe(cmd):
    out, rc = sh(cmd, timeout=30)
    return rc == 0, out.strip()


def env_report():
    """环境检测：python / venv+pymobiledevice3 / 上游仓 airlift.py / ffmpeg。"""
    rep = {
        "python": False, "pythonVersion": "",
        "venv": os.path.isdir(VENV),
        "pymobiledevice3": False,
        "upstream": os.path.isdir(UPSTREAM),
        "airlift": os.path.isfile(os.path.join(UPSTREAM, "artifacts", "airliftsilence", "macos-port", "airlift.py")),
        "ffmpeg": False,
        "hints": [],
    }
    ok, out = probe(["python3", "--version"])
    rep["python"], rep["pythonVersion"] = ok, out
    if not ok:
        rep["hints"].append("未找到 python3（无法自动安装）：macOS 运行 xcode-select --install；Windows 到 python.org 安装并勾选 Add to PATH。")
        return rep
    # venv 内或系统内的 pymobiledevice3
    py = os.path.join(VENV, "bin", "python3") if rep["venv"] else "python3"
    if not os.path.isfile(py):
        py = os.path.join(VENV, "Scripts", "python.exe")
    ok, _ = probe([py, "-c", "import pymobiledevice3"])
    rep["pymobiledevice3"] = ok
    ok, _ = probe(["ffmpeg", "-version"])
    rep["ffmpeg"] = ok
    if not (rep["pymobiledevice3"] and rep["airlift"]):
        rep["hints"].append("点「⚙️ 一键配置环境」，由软件自动安装修复（无需手动复制命令）。")
    if not rep["ffmpeg"]:
        rep["hints"].append("ffmpeg 缺失：点「⚙️ 一键配置环境」将自动通过 brew / winget 安装。")
    return rep


def do_setup():
    """一键配置：克隆上游仓 → 建 venv → 装 pymobiledevice3 → 自动装 ffmpeg。
    幂等：已就绪的步骤会跳过，可反复调用。返回 (日志, 是否成功)。"""
    logs = []

    def log(s):
        logs.append(s)

    ok, out = probe(["python3", "--version"])
    if not ok:
        log("❌ 未找到 python3，无法自动配置。")
        log("   macOS 请运行：xcode-select --install")
        log("   Windows 请到 python.org 安装并勾选 Add to PATH")
        return "\n".join(logs), False
    log("✅ python3: " + out)

    # 1) 上游仓库（airlift.py 来源）
    if os.path.isdir(UPSTREAM):
        log("✅ 上游仓库已存在，跳过克隆")
    else:
        log("⏳ 克隆上游仓库 airbeep-calltone-research ...")
        out, rc = sh(["git", "clone", "--depth", "1", UPSTREAM_URL, UPSTREAM], timeout=600)
        if out.strip():
            log(out.strip()[-1500:])
        if rc != 0:
            log("❌ 克隆失败（检查网络后重试）。")
            return "\n".join(logs), False
        log("✅ 上游仓库就绪")

    # 2) venv + pymobiledevice3（缺什么装什么）
    venv_py = os.path.join(VENV, "bin", "python3")
    if not os.path.isfile(venv_py):
        venv_py = os.path.join(VENV, "Scripts", "python.exe")
    need_pkg = (not os.path.isfile(venv_py)) or (probe([venv_py, "-c", "import pymobiledevice3"])[0] is False)
    if not need_pkg:
        log("✅ pymobiledevice3 已就绪，跳过安装")
    else:
        log("⏳ 创建虚拟环境并安装 pymobiledevice3 ...")
        out, rc = sh(["python3", "-m", "venv", VENV], timeout=300)
        if rc != 0:
            log(out[-1000:])
            log("❌ venv 创建失败。")
            return "\n".join(logs), False
        pip = os.path.join(VENV, "bin", "pip")
        if not os.path.isfile(pip):
            pip = os.path.join(VENV, "Scripts", "pip.exe")
        out, rc = sh([pip, "install", "pymobiledevice3"], timeout=900)
        if out.strip():
            log(out.strip()[-1200:])
        if rc != 0:
            log("❌ pymobiledevice3 安装失败。")
            return "\n".join(logs), False
        log("✅ pymobiledevice3 安装完成")

    # 3) ffmpeg：缺失则按平台自动安装（brew / winget）
    if probe(["ffmpeg", "-version"])[0]:
        log("✅ ffmpeg 已就绪")
    else:
        log("⏳ 未检测到 ffmpeg，开始自动安装 ...")
        installed = False
        if sys.platform == "darwin" and shutil.which("brew"):
            log("   使用 Homebrew 安装（可能需要输入密码）...")
            out, rc = sh(["brew", "install", "ffmpeg"], timeout=1800)
            if out.strip():
                log(out.strip()[-1200:])
            installed = rc == 0 and probe(["ffmpeg", "-version"])[0]
            if installed:
                log("✅ ffmpeg 安装完成（brew）")
        elif sys.platform.startswith("win") and shutil.which("winget"):
            log("   使用 winget 安装（可能弹出 UAC 确认）...")
            out, rc = sh(["winget", "install", "--id", "Gyan.FFmpeg", "-e",
                          "--accept-source-agreements", "--accept-package-agreements"],
                         timeout=1800)
            if out.strip():
                log(out.strip()[-1200:])
            installed = rc == 0 and probe(["ffmpeg", "-version"])[0]
            if installed:
                log("✅ ffmpeg 安装完成（winget）")
            else:
                log("ℹ️ winget 已执行；若仍检测不到 ffmpeg，请重开本应用后再试（PATH 需刷新）。")
        if not installed and not probe(["ffmpeg", "-version"])[0]:
            if sys.platform == "darwin":
                log("⚠️ 未能自动安装 ffmpeg：请先安装 Homebrew（brew.sh），或手动运行 brew install ffmpeg。")
            elif sys.platform.startswith("win"):
                log("⚠️ 未能自动安装 ffmpeg：请手动运行 winget install Gyan.FFmpeg。")
            else:
                log("⚠️ 未能自动安装 ffmpeg：请用系统包管理器安装（如 sudo apt install ffmpeg）。")
            log("   （ffmpeg 仅在为其他机型重新生成静音件时才需要；同机型用附带静音件可忽略。）")

    log("🎉 环境配置完成，可以开始「设备状态 → 执行静音 → 校验」。")
    return "\n".join(logs), True


class Handler(SimpleHTTPRequestHandler):
    def log_message(self, fmt, *args):  # 静音默认访问日志
        pass

    def _json(self, obj, code=200):
        body = json.dumps(obj, ensure_ascii=False).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        path = urlparse(self.path).path
        if path == "/api/env":
            self._json(env_report())
            return
        if path in ("/api/status", "/api/apply", "/api/restore", "/api/verify"):
            sub = path.rsplit("/", 1)[1]
            out, rc = run_skill(sub)
            self._json({"ok": rc == 0, "cmd": sub, "output": out})
            return
        if path in ("/", "/index.html"):
            self.send_response(302)
            self.send_header("Location", "/airbeep-checklist.html")
            self.end_headers()
            return
        return SimpleHTTPRequestHandler.do_GET(self)

    def do_POST(self):
        path = urlparse(self.path).path
        if path == "/api/setup":
            out, ok = do_setup()
            self._json({"ok": ok, "output": out})
            return
        if path in ("/api/status", "/api/apply", "/api/restore", "/api/verify"):
            sub = path.rsplit("/", 1)[1]
            out, rc = run_skill(sub)
            self._json({"ok": rc == 0, "cmd": sub, "output": out})
            return
        self._json({"error": "not found"}, 404)


def main():
    port = PORT
    for i, a in enumerate(sys.argv):
        if a == "--port" and i + 1 < len(sys.argv):
            port = int(sys.argv[i + 1])
    os.chdir(HERE)
    server = ThreadingHTTPServer(("127.0.0.1", port), Handler)
    url = "http://127.0.0.1:%d/airbeep-checklist.html" % port
    print("AirBeep 本地运行时已启动 / local runtime started:")
    print("  " + url)
    print("  按 Ctrl+C 停止 / press Ctrl+C to stop")
    try:
        threading.Timer(1.0, lambda: webbrowser.open(url)).start()
    except Exception:  # noqa: BLE001
        pass
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
