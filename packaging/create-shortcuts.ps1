# AirBeep测试 - 创建快捷方式（桌面 + 开始菜单）/ create Desktop + Start Menu shortcuts
param([string]$CardPath = (Join-Path $PSScriptRoot "airbeep-checklist.html"), [string]$LauncherPath = "")
$ErrorActionPreference = "SilentlyContinue"
# 优先指向启动器（会拉起本地运行时再开卡）；找不到启动器才直接指向卡片
if (-not $LauncherPath) {
  foreach ($c in @((Join-Path $PSScriptRoot "start-airbeep.bat"), (Join-Path (Split-Path $PSScriptRoot -Parent) "start-airbeep.bat"))) {
    if (Test-Path $c) { $LauncherPath = $c; break }
  }
}
$target = $CardPath
if ($LauncherPath -and (Test-Path $LauncherPath)) { $target = $LauncherPath }
$WshShell = New-Object -ComObject WScript.Shell
$name = "AirBeep测试"
$desc = "AirBeep 通话免提示音 · 操作检查卡（双击打开，可在本机直接执行）"
# 桌面快捷方式 / Desktop
$lnk = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\$name.lnk")
$lnk.TargetPath = $target
$lnk.Description = $desc
$lnk.Save()
# 开始菜单快捷方式 / Start Menu
$sm = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\$name.lnk"
$lnk2 = $WshShell.CreateShortcut($sm)
$lnk2.TargetPath = $target
$lnk2.Description = $desc
$lnk2.Save()
