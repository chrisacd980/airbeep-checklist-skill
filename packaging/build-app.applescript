set appPath to POSIX path of (path to me as text)
set cardPath to appPath & "Contents/Resources/airbeep-checklist.html"
open location "file://" & cardPath
