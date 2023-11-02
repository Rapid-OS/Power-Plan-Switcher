if WScript.Arguments.Count = 0 then
    WScript.Echo "Missing parameters"
Else
targetGUID = "11111111-1111-1111-1111-111111111111"
set ws = createobject("wscript.shell") 
ws.run "cmd.exe /c powercfg -s " & targetGUID,vbhide
end if