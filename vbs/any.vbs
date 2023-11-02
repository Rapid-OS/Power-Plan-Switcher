if WScript.Arguments.Count = 0 then
    WScript.Echo "Missing parameters"
Else
targetGUID = "a1841308-3541-4fab-bc81-f71556f20b4a"
set ws = createobject("wscript.shell") 
ws.run "cmd.exe /c powercfg -s " & targetGUID,vbhide
end if