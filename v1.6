#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; === Variables / Defaults ===
Cooldown := 5000           ; ms
Running := false
UseNotepad := 0
LineCount := 5
Mode := "Paste"            ; "Paste", "Type", "CustomType", "RandomLines"
SpeedMode := "Normal"      ; "Slow", "Normal", "Fast"
CustomMessage := ""
currentLine := 1

; Generic PLS DONATE messages (object for v1.1 reliability)
DonateMessages := Object()
DonateMessages[1] := "Please donate if you can 💖"
DonateMessages[2] := "Every donation helps 🙏"
DonateMessages[3] := "Donating = instant good luck 🍀"
DonateMessages[4] := "Road to 100 Robux, help me out 🚀"
DonateMessages[5] := "Spare some Robux? :)"
DonateMessagesCount := 5

; === Load Saved Settings (if present) ===
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

; === Version Check ===
CurrentVersion := "1.6"
VersionCheckURL := "https://raw.githubusercontent.com/stellardev67/Roblox-Auto-Message-Bot/main/latest.txt"
UpdatePage := "https://github.com/stellardev67/Roblox-Auto-Message-Bot"

CheckForUpdates() {
    global CurrentVersion, VersionCheckURL, UpdatePage
    TempFile := A_Temp "\latest_version.txt"
    UrlDownloadToFile, %VersionCheckURL%, %TempFile%
    if ErrorLevel
        return
    FileRead, LatestVer, %TempFile%
    if (LatestVer = "")
        return
    ; clean up
    LatestVer := RegExReplace(LatestVer, "[^\d\.]")   ; keep only digits & dots
    CurrentVerNum := RegExReplace(CurrentVersion, "[^\d\.]")
    if (LatestVer != "" && LatestVer != CurrentVerNum) {
        MsgBox, 4, Update Available, A new version (v%LatestVer%) is available.`nYou have v%CurrentVerNum%`nOpen releases page?
        IfMsgBox Yes
            Run, %UpdatePage%
    }
}
CheckForUpdates()

; === GUI Setup ===
Gui, +AlwaysOnTop +Resize +MinimizeBox

Gui, Add, Tab2, vMainTab w600 h400, Settings|Instructions

; Settings
Gui, Tab, Settings
Gui, Add, Text,, Cooldown (ms):
Gui, Add, Edit, vCooldownInput w100, %Cooldown%
Gui, Add, Checkbox, vUseNotepadCheckbox gToggleNotepad, Copy line from Notepad
GuiControl,, UseNotepadCheckbox, %UseNotepad%
Gui, Add, Text,, Number of lines in Notepad:
Gui, Add, Edit, vLineCountInput w100, %LineCount%
Gui, Add, Text,, Mode:
Gui, Add, DropDownList, vModeChoice gModeChanged w200, Paste|Type|CustomType|RandomLines
GuiControl, ChooseString, ModeChoice, %Mode%
Gui, Add, Text,, Custom Message (only for CustomType):
Gui, Add, Edit, vCustomMessageInput w400, %CustomMessage%
Gui, Add, Text,, Speed Mode:
Gui, Add, DropDownList, vSpeedModeChoice w120, Slow|Normal|Fast
GuiControl, ChooseString, SpeedModeChoice, %SpeedMode%
Gui, Add, Button, gStartLoop w120, Start
Gui, Add, Button, gStopLoop w120, Stop
Gui, Add, Button, gExitScript w120, Exit
Gui, Add, Text, vStatusLabel w400, Status: Stopped

; Instructions (read-only)
Gui, Tab, Instructions
Gui, Add, Edit, w560 h320 ReadOnly -WantCtrlA, 
(
Instructions:

1. Open Notepad (the default one on Windows).
2. Maximize the Notepad window with default font/size.
3. Type your messages one per line (no extra spacing).
4. Enter the number of lines in the GUI.
5. Choose Mode:
   - Paste = paste from clipboard or Notepad
   - Type = type from Notepad or fallback generic messages
   - CustomType = repeatedly type your custom message
   - RandomLines = copy a random line from Notepad each loop
6. Choose Speed Mode: Slow, Normal, or Fast.
7. Press Start or F6 to begin. Stop with Stop or F7.
8. Exit closes the script. Cooldown is in milliseconds.
)

; Show GUI in top-right
GuiWidth := 600
GuiHeight := 400
GuiX := A_ScreenWidth - GuiWidth
GuiY := 50
Gui, Show, x%GuiX% y%GuiY% w%GuiWidth% h%GuiHeight%, Auto Clicker Settings
return

; === GUI callbacks ===
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
    if (CooldownInput != "")
        Cooldown := CooldownInput
    if (LineCountInput != "")
        LineCount := LineCountInput
    Mode := ModeChoice
    SpeedMode := SpeedModeChoice
    CustomMessage := CustomMessageInput

    ; save settings
    IniWrite, %Cooldown%, %ConfigFile%, Settings, Cooldown
    IniWrite, %LineCount%, %ConfigFile%, Settings, LineCount
    IniWrite, %UseNotepad%, %ConfigFile%, Settings, UseNotepad
    IniWrite, %Mode%, %ConfigFile%, Settings, Mode
    IniWrite, %SpeedMode%, %ConfigFile%, Settings, SpeedMode
    IniWrite, %CustomMessage%, %ConfigFile%, Settings, CustomMessage

    if (Running)
        return
    Running := true
    GuiControl,, StatusLabel, Status: Running
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

    ; speed multiplier
    if (SpeedMode = "Slow")
        Delay := 1.5
    else if (SpeedMode = "Fast")
        Delay := 0.5
    else
        Delay := 1.0

    text := ""

    if (Mode = "CustomType") {
        text := CustomMessage
    }
    else if (Mode = "RandomLines" && UseNotepad) {
        if WinExist("ahk_class Notepad")
        {
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
    }
    else if (UseNotepad) {
        if WinExist("ahk_class Notepad")
        {
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
    }
    else {
        if (Mode = "Type") {
            Random, idx, 1, %DonateMessagesCount%
            text := DonateMessages[idx]
        } else {
            text := Clipboard
        }
    }

    ; ---- Send to game/chat ----
    if WinExist("ahk_exe RobloxPlayerBeta.exe")
    {
        WinActivate
        Sleep, % Floor(200 * Delay)
    }

    Send, /
    Sleep, % Floor(120 * Delay)

    if (Mode = "Paste" || Mode = "RandomLines")
    {
        OldClip2 := ClipboardAll
        Clipboard := text
        Sleep, % Floor(80 * Delay)
        Send, ^v
        Sleep, % Floor(120 * Delay)
        Clipboard := OldClip2
        VarSetCapacity(OldClip2, 0)
    }
    else
    {
        Loop, Parse, text
        {
            Send, %A_LoopField%
            Sleep, % Floor(40 * Delay)
        }
    }

    Send, {Enter}
    Sleep, % Floor(220 * Delay)

    ScreenWidth := A_ScreenWidth
    ScreenHeight := A_ScreenHeight
    CenterX := Floor(ScreenWidth / 2)
    CenterY := Floor(ScreenHeight / 2)
    MouseMove, %CenterX%, %CenterY%, 20
    Sleep, % Floor(60 * Delay)
    Click
    Sleep, % Floor(80 * Delay)
    Click

    Sleep, %Cooldown%
return

GuiClose:
ExitApp
