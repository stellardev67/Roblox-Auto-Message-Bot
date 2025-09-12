#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; === Force screen-relative coordinates for mouse ===
CoordMode, Mouse, Screen

; === Variables / Defaults ===
Cooldown := 5000
Running := false
UseNotepad := 0
LineCount := 5
Mode := "Paste"
SpeedMode := "Normal"
CustomMessage := ""
currentLine := 1
RobloxVersion := "PC Client"
AltToggle := 0
LoopsPerSession := 20
LoopCounter := 0
AutoRejoin := 0
RejoinDelay := 10000   ; default 10s
FirstRejoin := true

; === Click positions (absolute screen coords) ===
LeaveBtnX := 960
LeaveBtnY := 540
ConfirmBtnX := 960
ConfirmBtnY := 600
PlayBtnX := 866
PlayBtnY := 340

; Generic PLS DONATE messages
DonateMessages := Object()
DonateMessages[1] := "Please donate if you can 💖"
DonateMessages[2] := "Every donation helps 🙏"
DonateMessages[3] := "Donating = instant good luck 🍀"
DonateMessages[4] := "Road to 100 Robux, help me out 🚀"
DonateMessages[5] := "Spare some Robux? :)"
DonateMessagesCount := 5

; === Load Saved Settings ===
ConfigFile := A_ScriptDir "\AutoClickerSettings.ini"
IniRead, tmp, %ConfigFile%, Settings, Cooldown, %Cooldown%
if tmp !=
    Cooldown := tmp
IniRead, tmp, %ConfigFile%, Settings, LineCount, %LineCount%
if tmp !=
    LineCount := tmp
IniRead, tmp, %ConfigFile%, Settings, UseNotepad, %UseNotepad%
if tmp !=
    UseNotepad := tmp
IniRead, tmp, %ConfigFile%, Settings, Mode, %Mode%
if tmp !=
    Mode := tmp
IniRead, tmp, %ConfigFile%, Settings, SpeedMode, %SpeedMode%
if tmp !=
    SpeedMode := tmp
IniRead, tmp, %ConfigFile%, Settings, CustomMessage, %CustomMessage%
if tmp !=
    CustomMessage := tmp
IniRead, tmp, %ConfigFile%, Settings, RobloxVersion, %RobloxVersion%
if tmp !=
    RobloxVersion := tmp
IniRead, tmp, %ConfigFile%, Settings, LoopsPerSession, %LoopsPerSession%
if tmp !=
    LoopsPerSession := tmp
IniRead, tmp, %ConfigFile%, Settings, AutoRejoin, %AutoRejoin%
if tmp !=
    AutoRejoin := tmp
IniRead, tmp, %ConfigFile%, Settings, RejoinDelay, %RejoinDelay%
if tmp !=
    RejoinDelay := tmp

; === GUI Setup ===
Gui, +AlwaysOnTop +Resize +MinimizeBox
Gui, Add, Tab2, vMainTab w900 h645, Settings|Instructions

; Settings tab
Gui, Tab, Settings
Gui, Add, Text,, Cooldown (ms):
Gui, Add, Edit, vCooldownInput w150, %Cooldown%
Gui, Add, Checkbox, vUseNotepadCheckbox gToggleNotepad, Copy line from Notepad
GuiControl,, UseNotepadCheckbox, %UseNotepad%
Gui, Add, Text,, Number of lines in Notepad:
Gui, Add, Edit, vLineCountInput w150, %LineCount%
Gui, Add, Text,, Mode:
Gui, Add, DropDownList, vModeChoice gModeChanged w300, Paste|Type|CustomType|RandomLines
GuiControl, ChooseString, ModeChoice, %Mode%
Gui, Add, Text,, Custom Messages (separate with n/ for random):
Gui, Add, Edit, vCustomMessageInput w600 h60, %CustomMessage%
Gui, Add, Text,, Speed Mode:
Gui, Add, DropDownList, vSpeedModeChoice w180, Slow|Normal|Fast
GuiControl, ChooseString, SpeedModeChoice, %SpeedMode%

; Roblox version selector
Gui, Add, Text,, Roblox Version:
Gui, Add, DropDownList, vRobloxVersionChoice w300, PC Client|MS Store|Alt Accounts
GuiControl, ChooseString, RobloxVersionChoice, %RobloxVersion%

; Loops & AutoRejoin
Gui, Add, Text,, Loops per Session:
Gui, Add, Edit, vLoopsPerSessionInput w150, %LoopsPerSession%
Gui, Add, Checkbox, vAutoRejoinCheckbox, Enable Auto Rejoin
GuiControl,, AutoRejoinCheckbox, %AutoRejoin%
Gui, Add, Text,, Rejoin Delay (ms):
Gui, Add, Edit, vRejoinDelayInput w150, %RejoinDelay%

Gui, Add, Button, gStartLoop w180 h40, Start
Gui, Add, Button, gStopLoop w180 h40, Stop
Gui, Add, Button, gExitScript w180 h40, Exit
Gui, Add, Text, vStatusLabel w600, Status: Stopped

; Instructions tab
Gui, Tab, Instructions
Gui, Add, Edit, w840 h510 ReadOnly -WantCtrlA,
(
Instructions:

1. Open Notepad and type your messages one per line.
2. Enter the number of lines in the GUI.
3. Choose Mode:
   - Paste = paste from clipboard or Notepad
   - Type = type from Notepad or fallback generic messages
   - CustomType = randomly type from your custom messages (n/ separated)
   - RandomLines = copy a random line from Notepad each loop
4. Choose Speed Mode: Slow, Normal, or Fast.
5. Choose Roblox Version: PC Client, MS Store, or Alt Accounts.
6. Choose Loops per Session and tick Auto Rejoin if you want it to rejoin automatically.
7. Rejoin Delay sets how long to wait (ms) before clicking Play again.
8. Press Start or F6 to begin. Stop with Stop or F7.
)

; Show GUI
Gui, Show, x100 y100 w900 h645, Auto Clicker Settings
return

; === GUI Callbacks ===
ToggleNotepad:
    Gui, Submit, NoHide
    UseNotepad := UseNotepadCheckbox
return

ModeChanged:
    Gui, Submit, NoHide
    Mode := ModeChoice
return

StartLoop:
    Gui, Submit, NoHide
    Cooldown := CooldownInput
    LineCount := LineCountInput
    Mode := ModeChoice
    SpeedMode := SpeedModeChoice
    CustomMessage := CustomMessageInput
    RobloxVersion := RobloxVersionChoice
    LoopsPerSession := LoopsPerSessionInput
    AutoRejoin := AutoRejoinCheckbox
    RejoinDelay := RejoinDelayInput

    ; save
    IniWrite, %Cooldown%, %ConfigFile%, Settings, Cooldown
    IniWrite, %LineCount%, %ConfigFile%, Settings, LineCount
    IniWrite, %UseNotepad%, %ConfigFile%, Settings, UseNotepad
    IniWrite, %Mode%, %ConfigFile%, Settings, Mode
    IniWrite, %SpeedMode%, %ConfigFile%, Settings, SpeedMode
    IniWrite, %CustomMessage%, %ConfigFile%, Settings, CustomMessage
    IniWrite, %RobloxVersion%, %ConfigFile%, Settings, RobloxVersion
    IniWrite, %LoopsPerSession%, %ConfigFile%, Settings, LoopsPerSession
    IniWrite, %AutoRejoin%, %ConfigFile%, Settings, AutoRejoin
    IniWrite, %RejoinDelay%, %ConfigFile%, Settings, RejoinDelay

    if (Running)
        return
    Running := true
    LoopCounter := 0
    GuiControl,, StatusLabel, Status: Running (0/%LoopsPerSession%)
    SetTimer, RunLoop, 100
return

StopLoop:
    Running := false
    GuiControl,, StatusLabel, Status: Stopped
    SetTimer, RunLoop, Off
return

ExitScript:
    ExitApp
return

; Hotkeys
F6::Gosub, StartLoop
F7::Gosub, StopLoop

; === Core Loop ===
RunLoop:
    if (!Running)
        return

    ; Speed settings
    if (SpeedMode = "Slow")
        Delay := 1.5
    else if (SpeedMode = "Fast")
        Delay := 0.5
    else
        Delay := 1.0

    text := ""

    ; --- Message selection ---
    if (Mode = "CustomType") {
        if (CustomMessage != "") {
            StringSplit, CustomParts, CustomMessage, n/
            Random, randIdx, 1, %CustomParts0%
            text := CustomParts%randIdx%
        }
    } else if (Mode = "RandomLines" && UseNotepad) {
        if WinExist("ahk_class Notepad") {
            WinActivate
            Sleep, % Floor(200 * Delay)
            Random, randLine, 1, %LineCount%
            ScreenWidth := A_ScreenWidth
            NotepadX := Floor(ScreenWidth / 2)
            LineHeight := 20
            Ypos := 150 + ((randLine - 1) * LineHeight)
            MouseMove, %NotepadX%, %Ypos%, 10
            Sleep, % Floor(100 * Delay)
            Click, 3
            Sleep, % Floor(150 * Delay)
            Clipboard := ""
            Send, ^c
            ClipWait, 1
            if !ErrorLevel
                text := Clipboard
        }
    } else if (UseNotepad) {
        if WinExist("ahk_class Notepad") {
            WinActivate
            Sleep, % Floor(200 * Delay)
            if (currentLine > LineCount)
                currentLine := 1
            ScreenWidth := A_ScreenWidth
            NotepadX := Floor(ScreenWidth / 2)
            LineHeight := 20
            Ypos := 150 + ((currentLine - 1) * LineHeight)
            MouseMove, %NotepadX%, %Ypos%, 10
            Sleep, % Floor(80 * Delay)
            Click, 3
            Sleep, % Floor(150 * Delay)
            Clipboard := ""
            Send, ^c
            ClipWait, 1
            if !ErrorLevel
                text := Clipboard
            currentLine++
        }
    } else {
        if (Mode = "Type") {
            Random, idx, 1, %DonateMessagesCount%
            text := DonateMessages[idx]
        } else {
            text := Clipboard
        }
    }

    ; --- Activate Roblox ---
    if (RobloxVersion = "PC Client") {
        if WinExist("ahk_exe RobloxPlayerBeta.exe")
            WinActivate
    } else if (RobloxVersion = "MS Store") {
        if WinExist("Roblox")
            WinActivate
    } else if (RobloxVersion = "Alt Accounts") {
        AltToggle := !AltToggle
        if (AltToggle = 0) {
            if WinExist("ahk_exe RobloxPlayerBeta.exe")
                WinActivate
        } else {
            if WinExist("Roblox")
                WinActivate
        }
    }
    Sleep, % Floor(200 * Delay)

    ; --- Send message ---
    Send, /
    Sleep, % Floor(120 * Delay)
    if (Mode = "Paste" || Mode = "RandomLines") {
        OldClip2 := ClipboardAll
        Clipboard := text
        Sleep, % Floor(80 * Delay)
        Send, ^v
        Sleep, % Floor(120 * Delay)
        Clipboard := OldClip2
        VarSetCapacity(OldClip2, 0)
    } else {
        Loop, Parse, text
        {
            Send, %A_LoopField%
            Sleep, % Floor(40 * Delay)
        }
    }
    Send, {Enter}
    Sleep, %Cooldown%

    ; --- Loop counter ---
    LoopCounter++
    GuiControl,, StatusLabel, Status: Running (%LoopCounter%/%LoopsPerSession%)

; --- Auto Rejoin ---
if (LoopCounter >= LoopsPerSession) {
    LoopCounter := 0
    if (AutoRejoin) {
        ; Leave the game
        if (WinExist("ahk_exe RobloxPlayerBeta.exe") || WinExist("Roblox")) {
            WinActivate
            Sleep, 500
            Send, {Esc}
            Sleep, 800
            Send, l
            Sleep, 600
            Send, {Enter}
        }

        ; Wait before trying to rejoin
        Sleep, %RejoinDelay%

        ; === Function to retry Play join up to 4 times ===
TryJoinPlay() {
    global FirstRejoin
    ; If first rejoin: reset focus and press 's' once
    if (FirstRejoin) {
        SendEvent, {Home}
        Sleep, 300
        SendEvent, s
        Sleep, 200
        FirstRejoin := false
    }

    ; Always try Enter up to 4 times
    Loop, 4 {
        SendEvent, {Enter}
        Sleep, 3000
        if !WinExist("Roblox") ; Roblox menu gone -> joined
            return true
    }
    return false
}

        ; === Rejoin attempt ===
        if (RobloxVersion = "PC Client" && WinExist("ahk_exe RobloxPlayerBeta.exe")) {
            WinActivate
            WinWaitActive, ahk_exe RobloxPlayerBeta.exe, , 5
            Sleep, 2000
            TryJoinPlay()
        } else if (RobloxVersion = "MS Store" && WinExist("Roblox")) {
            WinActivate
            WinWaitActive, Roblox, , 5
            Sleep, 2000
            TryJoinPlay()
        } else if (RobloxVersion = "Alt Accounts") {
            AltToggle := !AltToggle
            if (AltToggle = 0 && WinExist("ahk_exe RobloxPlayerBeta.exe")) {
                WinActivate
                WinWaitActive, ahk_exe RobloxPlayerBeta.exe, , 5
                Sleep, 2000
                TryJoinPlay()
            } else if (AltToggle = 1 && WinExist("Roblox")) {
                WinActivate
                WinWaitActive, Roblox, , 5
                Sleep, 2000
                TryJoinPlay()
            }
        }
    } else {
        Running := false
        GuiControl,, StatusLabel, Status: Stopped
        SetTimer, RunLoop, Off
    }
}
return

; === Coordinate Viewer ===
F8::
    MouseGetPos, mx, my
    ToolTip, X: %mx%  Y: %my%
    SetTimer, RemoveToolTip, -2000
return

RemoveToolTip:
    ToolTip
return
