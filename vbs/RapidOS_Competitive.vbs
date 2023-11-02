if WScript.Arguments.Count = 0 then
    WScript.Echo "Missing parameters"
Else
targetGUID = "99999999-9999-9999-9999-999999999999"
set ws = createobject("wscript.shell") 
ws.run "cmd.exe /c powercfg -s " & targetGUID,vbhide
end if