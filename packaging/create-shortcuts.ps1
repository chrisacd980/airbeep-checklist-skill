# AirBeep 检查卡 - 创建快捷方式（桌面 + 开始菜单）
$ErrorActionPreference = "SilentlyContinue"
$card = Join-Path $PSScriptRoot "airbeep-checklist.html"
$WshShell = New-Object -ComObject WScript.Shell

# 桌面快捷方式
$lnk = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\AirBeep 检查卡.lnk")
$lnk.TargetPath = $card
$lnk.WorkingDirectory = $PSScriptRoot
$lnk.Description = "AirBeep 通话免提示音 · 操作检查卡（点击在浏览器打开）"
$lnk.Save()

# 开始菜单快捷方式
$sm = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\AirBeep 检查卡.lnk"
$lnk2 = $WshShell.CreateShortcut($sm)
$lnk2.TargetPath = $card
$lnk2.WorkingDirectory = $PSScriptRoot
$lnk2.Description = "AirBeep 通话免提示音 · 操作检查卡（点击在浏览器打开）"
$lnk2.Save()
