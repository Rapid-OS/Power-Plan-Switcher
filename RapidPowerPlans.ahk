#NoEnv
#include ListView.ahk
#SingleInstance force
#include osd.ahk
Menu, Tray, NoStandard
Menu, Tray, Add, &Show Power Modes, showAndMonitor
Menu, Tray, Default, &Show Power Modes
Menu, Tray, Add, Exit, Exit
Menu, Tray, Click, 1

IfPlanListShowing := 0
planListObj := 0
focusedSchemeName := ""
GUI_ID := 0
nameAndCommand := {"RapidOS Optimized":"C:\Windows\RPPS\vbs\RapidOS_Optimized.vbs"
    ,"RapidOS Competitive":"C:\Windows\RPPS\vbs\RapidOS_Competitive.vbs"
    ,"any":"C:\Windows\RPPS\vbs\any.vbs"}
nameAndIcon := {"RapidOS Optimized":"C:\Windows\RPPS\icons\RapidOS Optimized.ico"
    ,"RapidOS Competitive":"C:\Windows\RPPS\icons\RapidOS Competitive.ico"
	,"Power saver":"C:\Windows\RPPS\icons\Power saver.ico"
    ,"any":"C:\Windows\RPPS\icons\any.ico"}


; en
nameAndGUID := {}
; not en
initializeProgram()

#If IfPlanListShowing
Esc::
    closePlanList(){
        global planListObj
        global IfPlanListShowing
        ; global ifMonitoring
        global focusedSchemeName
        planListObj.hide()
        planListObj.destroy()
        planListObj := 0
        IfPlanListShowing := 0
        ; ifMonitoring := 0
        focusedSchemeName := ""
        SetTimer, monitorForSelection, Off
    }
    closePlanList()
return

; #If IfPlanListShowing
Enter::
    setPlan(){
        SetTimer, monitorForSelection, Off
        global planListObj
        global IfPlanListShowing
        ; global ifMonitoring
        global focusedSchemeName
        global nameAndCommand
        global nameAndGUID

        ; close the plan list ui earlier, or it may seems too slow
        planListObj.hide()
        planListObj.destroy()
        planListObj := 0

        if (focusedSchemeName != ""){
            focusedSchemeName_en := translateToEn(focusedSchemeName)
            osdTemp := New OSD
            if (focusedSchemeName_en != "RapidOS Optimized" || focusedSchemeName_en != "RapidOS Competitive" ){
                Run, % nameAndCommand["any"] . nameAndGUID[focusedSchemeName_en] . 0
            }
            else if (focusedSchemeName_en != "RapidOS Optimized") {
                Run, % "RapidOS_Optimized.vbs"
            }
            else if (focusedSchemeName_en != "RapidOS Competitive") {
                Run, % "RapidOS_Competitive.vbs"
            }
            DisplayOSD(osdTemp, focusedSchemeName)
            ; sleep, 500
            ; DisplayOSD(osdTemp, getActiveScheme())
        }
        
        IfPlanListShowing := 0
        ; ifMonitoring := 0
        focusedSchemeName := ""
    }
    setPlan()
return

; #If IfPlanListShowing
~LWin Up::
    setPlan()
return
#If

initializeProgram(){
    global nameAndIcon
    global GUI_ID
    global nameAndGUID

    ; initialize tray icon
    M1 := getActiveScheme()
    M1_en := translateToEn(M1)
    if (FileExist(nameAndIcon[M1_en])){
        Menu, Tray, Icon, % nameAndIcon[M1_en]
    }
    else {
        Menu, Tray, Icon, % nameAndIcon["any"]
    }
}
showAndMonitor(){
    ; global ifMonitoring
    getAllPowerSchemes()
    ; ifMonitoring := 1
    SetTimer, monitorForSelection, 100
}
getAllPowerSchemes(){
    global IfPlanListShowing
    global planListObj
    global nameAndCommand
    global GUI_ID

    powerSchemeArray := ["Power saver", "RapidOS Optimized", "RapidOS Competitive", ""]

    if (IfPlanListShowing = 1){
        planListObj.destroy()
        planListObj := 0
        IfPlanListShowing := 0
        return
    }
    else {
        IfPlanListShowing := 1
    }

    planListObj := New PlanList
    planListObj.show(powerSchemeArray)
    GUI_ID := planListObj.getID()
}

StdOutToVar(cmd)
{
	DllCall("CreatePipe", "PtrP", hReadPipe, "PtrP", hWritePipe, "Ptr", 0, "UInt", 0)
	DllCall("SetHandleInformation", "Ptr", hWritePipe, "UInt", 1, "UInt", 1)

	VarSetCapacity(PROCESS_INFORMATION, (A_PtrSize == 4 ? 16 : 24), 0)    ; http://goo.gl/dymEhJ
	cbSize := VarSetCapacity(STARTUPINFO, (A_PtrSize == 4 ? 68 : 104), 0) ; http://goo.gl/QiHqq9
	NumPut(cbSize, STARTUPINFO, 0, "UInt")                                ; cbSize
	NumPut(0x100, STARTUPINFO, (A_PtrSize == 4 ? 44 : 60), "UInt")        ; dwFlags
	NumPut(hWritePipe, STARTUPINFO, (A_PtrSize == 4 ? 60 : 88), "Ptr")    ; hStdOutput
	NumPut(hWritePipe, STARTUPINFO, (A_PtrSize == 4 ? 64 : 96), "Ptr")    ; hStdError
	
	if !DllCall(
	(Join Q C
		"CreateProcess",             ; http://goo.gl/9y0gw
		"Ptr",  0,                   ; lpApplicationName
		"Ptr",  &cmd,                ; lpCommandLine
		"Ptr",  0,                   ; lpProcessAttributes
		"Ptr",  0,                   ; lpThreadAttributes
		"UInt", true,                ; bInheritHandles
		"UInt", 0x08000000,          ; dwCreationFlags
		"Ptr",  0,                   ; lpEnvironment
		"Ptr",  0,                   ; lpCurrentDirectory
		"Ptr",  &STARTUPINFO,        ; lpStartupInfo
		"Ptr",  &PROCESS_INFORMATION ; lpProcessInformation
	)) {
		DllCall("CloseHandle", "Ptr", hWritePipe)
		DllCall("CloseHandle", "Ptr", hReadPipe)
		return ""
	}

	DllCall("CloseHandle", "Ptr", hWritePipe)
	VarSetCapacity(buffer, 4096, 0)
	while DllCall("ReadFile", "Ptr", hReadPipe, "Ptr", &buffer, "UInt", 4096, "UIntP", dwRead, "Ptr", 0)
		sOutput .= StrGet(&buffer, dwRead, "CP0")

	DllCall("CloseHandle", "Ptr", NumGet(PROCESS_INFORMATION, 0))         ; hProcess
	DllCall("CloseHandle", "Ptr", NumGet(PROCESS_INFORMATION, A_PtrSize)) ; hThread
	DllCall("CloseHandle", "Ptr", hReadPipe)
	return sOutput
}
Exit() {
    ExitApp
}
monitorForSelection(){
    global IfPlanListShowing
    global planListObj
    global nameAndCommand
    ; global ifMonitoring
    global GUI_ID
    global nameAndGUID

    ; SetTimer LoopStart, 100
    ; LoopStart:
    ; if (ifMonitoring = 0){
    ;     ifMonitoring := 1
    ;     return
    ; }
    ; Sleep, 100
    schemeTemp := planListObj.getSelectedScheme()
    if (schemeTemp != ""){
        schemeTemp_en := translateToEn(schemeTemp)
        osdTemp := New OSD
        if (nameAndCommand[schemeTemp_en] != ""){
            commandTemp := nameAndCommand[schemeTemp_en]
            Run, % commandTemp . nameAndGUID[schemeTemp_en] . " " . 0
        }
        else{
            commandTemp := nameAndCommand["any"]
            ; MsgBox % nameAndGUID[schemeTemp_en]
            Run, % commandTemp . nameAndGUID[schemeTemp_en] . " " . 0
        }
        DisplayOSD(osdTemp, schemeTemp)
        ; sleep, 500
        ; DisplayOSD(osdTemp, getActiveScheme())
        planListObj.hide()
        planListObj.destroy()
        planListObj := 0
        GUI_ID := 0
        IfPlanListShowing := 0
        SetTimer, monitorForSelection, Off
    }
    ; return
}
displayOSD(osdTemp, schemeTemp){
    global nameAndIcon
    if (schemeTemp = "Power saver"){
        osdTemp.showAndHide("🍃 Power Saver", 1) ; 
    }
    else if (schemeTemp = "节能"){
        osdTemp.showAndHide("🍃 节能", 1) ; 
    }
    else if (schemeTemp = "RapidOS Optimized"){
        osdTemp.showAndHide("🚀 RapidOS Optimized", 0)
    }
    else if (schemeTemp = "RapidOS Competitive"){
         osdTemp.showAndHide("☢ RapidOS Comp", 0)
         Sleep, 1500
         osdTemp.showAndHide("Not recommended", 0)
         Sleep, 1500
         osdTemp.showAndHide("to use while idle!", 0)
    }
    ; else if (schemeTemp = "卓越性能"){
    ;     osdTemp.showAndHide("☢ 卓越性能", 0)
    ; }
    else {
        osdTemp.showAndHide(schemeTemp)
    }
    schemeTemp_en := translateToEn(schemeTemp)
    if (FileExist(nameAndIcon[schemeTemp_en])){
        Menu, Tray, Icon, % nameAndIcon[schemeTemp_en]
    }
    else {
        Menu, Tray, Icon, % nameAndIcon["any"]
    }
}


GetInteger(ByRef @source, _offset = 0, _bIsSigned = false, _size = 4)
{
    local result
    Loop %_size%  ; Build the integer by adding up its bytes.
    {
        result += *(&@source + _offset + A_Index-1) << 8*(A_Index-1)
    }
    if (!_bIsSigned OR _size > 4 OR result < 0x80000000)
        Return result  ; Signed vs. unsigned doesn't matter in these cases.
    ; Otherwise, convert the value (now known to be 32-bit & negative) to its signed counterpart:
    return -(0xFFFFFFFF - result + 1)
}

getPowerState()
{
    Global
    VarSetCapacity(powerStatus, 1+1+1+1+4+4)
    success := DllCall("GetSystemPowerStatus", "UInt", &powerStatus)
    if (ErrorLevel != 0 OR success = 0) {
        MsgBox 16, Power Status, Can't get the power status...
        Exit
    }
    acLineStatus := GetInteger(powerStatus, 0, false, 1)
}

translateToEn(stringTemp){
    if (stringTemp = "节能" || stringTemp = "Risparmio di energia"){
        return "Power saver"
    }
    else {
        return stringTemp
    }
}

getActiveScheme(){
    currentPowerScheme := StdOutToVar("powercfg -getactivescheme")
    RegExMatch(currentPowerScheme, "\((.*?)\)", M, 1+StrLen(M1) )
    return M1
}

checkIfActivated(targetScheme){
    if (targetScheme = getActiveScheme()){
        return true
    }
    else {
        return false
    }
}
