set appPath to POSIX path of (path to me as text)
set resDir to appPath & "Contents/Resources/"
-- 启动本地运行时（后台），再打开卡片；python3 不存在则直接开内置卡片
do shell script "cd " & quoted form of resDir & " && if command -v python3 >/dev/null 2>&1; then (nohup python3 airbeep-desktop.py >/tmp/airbeep-desktop.log 2>&1 &); sleep 1; open http://127.0.0.1:8765/; else open " & quoted form of (resDir & "airbeep-checklist.html") & "; fi"
