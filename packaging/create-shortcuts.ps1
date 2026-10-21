# AirBeep测试 - 创建快捷方式（桌面 + 开始菜单）/ create Desktop + Start Menu shortcuts
param([string]$CardPath = (Join-Path $PSScriptRoot "airbeep-checklist.html"))
$ErrorActionPreference = "SilentlyContinue"
$WshShell = New-Object -ComObject WScript.Shell
$name = "AirBeep测试"
$desc = "AirBeep 通话免提示音 · 操作检查卡（点击在浏览器打开）"
# 桌面快捷方式 / Desktop
$lnk = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\$name.lnk")
$lnk.TargetPath = $CardPath
$lnk.Description = $desc
$lnk.Save()
# 开始菜单快捷方式 / Start Menu
$sm = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\$name.lnk"
$lnk2 = $WshShell.CreateShortcut($sm)
$lnk2.TargetPath = $CardPath
$lnk2.Description = $desc
$lnk2.Save()
