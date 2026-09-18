Set fso = CreateObject("Scripting.FileSystemObject")
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
projectDir = fso.GetAbsolutePathName(scriptDir & "\..")

Set WshShell = CreateObject("WScript.Shell")
WshShell.CurrentDirectory = projectDir
logPath = projectDir & "\logs\server.log"
cmdLine = "cmd.exe /c node src/server.js > """ & logPath & """ 2>&1"
WshShell.Run cmdLine, 0, False
