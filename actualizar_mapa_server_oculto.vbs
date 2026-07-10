Set WshShell = CreateObject("WScript.Shell")
Set FSO = CreateObject("Scripting.FileSystemObject")

carpeta = FSO.GetParentFolderName(WScript.ScriptFullName)
bat = carpeta & "\actualizar_mapa_server.bat"

WshShell.Run """" & bat & """", 0, False
