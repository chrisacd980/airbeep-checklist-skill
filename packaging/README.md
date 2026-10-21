# packaging — 安装包构建脚本（维护者用）

产物发布在 GitHub Releases：https://github.com/chrisacd980/airbeep-checklist-skill/releases

## macOS（AirBeep-macOS.dmg）
1. `osacompile -o "AirBeep 操作台.app" build-app.applescript`
2. 把最新 `airbeep-checklist.html` 拷入 `AirBeep 操作台.app/Contents/Resources/`
3. 暂存目录放 app + 使用说明.txt，`hdiutil create -volname "AirBeep 操作台" -srcfolder <staging> -fs HFS+ -format UDZO AirBeep-macOS.dmg`

## Windows（AirBeep-Setup.exe）
1. 打包载荷目录：技能全部文件 + `setup.bat` + `open-card.bat` + `create-shortcuts.ps1`（文件名全 ASCII）
2. `7za a -t7z -mx=5 payload-clean.7z <载荷文件…>`（用新包名！7za 的 `a` 是追加不是覆盖）
3. `cat 7z.sfx sfx-config.txt payload-clean.7z > AirBeep-Setup.exe`
   - `7z.sfx` 取自 7-Zip 官方安装包内嵌存档（见 7-zip.org），是 GUI 自解压模块
   - `sfx-config.txt` 里 InstallPath=%USERPROFILE%\AirBeep，RunProgram=setup.bat
   - setup.bat 装后自动：复制到 %USERPROFILE%\AirBeep → PowerShell 建桌面/开始菜单快捷方式 → 打开卡片
