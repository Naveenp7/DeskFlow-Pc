Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "python deskflow_server.py", 0
Set WshShell = Nothing
