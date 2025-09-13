#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen

; === Variables / Defaults ===
Cooldown := 5000
RandomCooldown := 0
Running := false
Paused := false
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
RejoinDelay := 10000
FirstRejoin := true
ShuffleMessages := false
SynonymsOption := false
MessageFile := ""
FileLines := []
SessionMessages := 0
SessionLoops := 0
SessionStartTime := 0
TotalMessages := 0
TotalLoops := 0
TotalRuntime := 0

; === Click positions ===
LeaveBtnX := 960
LeaveBtnY := 540
ConfirmBtnX := 960
ConfirmBtnY := 600
PlayBtnX := 866
PlayBtnY := 340
ReconnectBtnX := 1055
ReconnectBtnY := 625

; Generic donate messages
DonateMessages := Object()
DonateMessages[1] := "Please donate if you can"
DonateMessages[2] := "Every donation helps"
DonateMessages[3] := "Donating = instant good luck"
DonateMessages[4] := "Road to 100 Robux, help me out"
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
IniRead, tmp, %ConfigFile%, Settings, ShuffleMessages, %ShuffleMessages%
if tmp !=
    ShuffleMessages := tmp
IniRead, tmp, %ConfigFile%, Settings, SynonymsOption, %SynonymsOption%
if tmp !=
    SynonymsOption := tmp
IniRead, tmp, %ConfigFile%, Settings, MessageFile, %MessageFile%
if tmp !=
    MessageFile := tmp
IniRead, tmp, %ConfigFile%, Stats, TotalMessages, 0
TotalMessages := tmp
IniRead, tmp, %ConfigFile%, Stats, TotalLoops, 0
TotalLoops := tmp
IniRead, tmp, %ConfigFile%, Stats, TotalRuntime, 0
TotalRuntime := tmp

; === GUI Setup with multiple tabs ===
Gui, +AlwaysOnTop +Resize +MinimizeBox
Gui, Add, Tab2, vMainTab w900 h750, Settings|Config|Statistics|Instructions

; =========================
; SETTINGS TAB
; =========================
Gui, Tab, Settings
Gui, Add, Checkbox, vRandomCooldownCheckbox, Randomize cooldown
GuiControl,, RandomCooldownCheckbox, %RandomCooldown%

Gui, Add, Checkbox, vUseNotepadCheckbox gToggleNotepad, Copy line from Notepad
GuiControl,, UseNotepadCheckbox, %UseNotepad%

Gui, Add, Checkbox, vShuffleMessagesCheckbox, Shuffle messages
GuiControl,, ShuffleMessagesCheckbox, %ShuffleMessages%

Gui, Add, Checkbox, vSynonymsOptionCheckbox, Replace words with synonyms
GuiControl,, SynonymsOptionCheckbox, %SynonymsOption%

Gui, Add, Checkbox, vAutoRejoinCheckbox, Enable Auto Rejoin
GuiControl,, AutoRejoinCheckbox, %AutoRejoin%

; Roblox version selector
Gui, Add, Text,, Roblox Version:
Gui, Add, DropDownList, vRobloxVersionChoice w300, PC Client|MS Store|Alt Accounts|Bloxstrap
GuiControl, ChooseString, RobloxVersionChoice, %RobloxVersion%

; Speed Mode
Gui, Add, Text,, Speed Mode:
Gui, Add, DropDownList, vSpeedModeChoice w180, Slow|Normal|Fast
GuiControl, ChooseString, SpeedModeChoice, %SpeedMode%

; =========================
; CONFIG TAB
; =========================
Gui, Tab, Config
Gui, Add, Text,, Cooldown (ms):
Gui, Add, Edit, vCooldownInput w150, %Cooldown%

Gui, Add, Text,, Number of lines in Notepad:
Gui, Add, Edit, vLineCountInput w150, %LineCount%

Gui, Add, Text,, Custom Messages (n/ separated for random):
Gui, Add, Edit, vCustomMessageInput w600 h80, %CustomMessage%

Gui, Add, Text,, Loops per Session:
Gui, Add, Edit, vLoopsPerSessionInput w150, %LoopsPerSession%

Gui, Add, Text,, Rejoin Delay (ms):
Gui, Add, Edit, vRejoinDelayInput w150, %RejoinDelay%

; File input
Gui, Add, Text,, Load messages from file (txt):
Gui, Add, Edit, vMessageFileInput w400, %MessageFile%
Gui, Add, Button, gBrowseFile, Browse

; =========================
; STATISTICS TAB
; =========================
Gui, Tab, Statistics
Gui, Add, GroupBox, x20 y40 w400 h200, Session Stats
Gui, Add, Text, x40 y70, Messages Sent:
Gui, Add, Text, vSessionMessagesSent x200 y70, 0
Gui, Add, Text, x40 y100, Loops Completed:
Gui, Add, Text, vSessionLoops x200 y100, 0
Gui, Add, Text, x40 y130, Runtime (min):
Gui, Add, Text, vSessionRuntime x200 y130, 0

Gui, Add, GroupBox, x450 y40 w400 h200, Total Stats
Gui, Add, Text, x470 y70, Total Messages Sent:
Gui, Add, Text, vTotalMessagesSent x700 y70, %TotalMessages%
Gui, Add, Text, x470 y100, Total Loops Completed:
Gui, Add, Text, vTotalLoops x700 y100, %TotalLoops%
Gui, Add, Text, x470 y130, Total Runtime (min):
Gui, Add, Text, vTotalRuntime x700 y130, %TotalRuntime%


; =========================
; INSTRUCTIONS TAB
; =========================
Gui, Tab, Instructions
Gui, Add, Edit, w840 h600 ReadOnly -WantCtrlA,
(
Instructions:

1. Open Notepad or txt file and type messages one per line.
2. Enter the number of lines in Config tab (or total lines in file).
3. Settings tab → choose toggles like Shuffle, Random cooldown, Synonyms, AutoRejoin.
4. Config tab → enter exact values like cooldown, loops, rejoin delay, messages.
5. Press Start (F6). Stop with Stop (F7). Pause/Resume with F9.
6. Export session log via menu.
)

; =========================
; BUTTONS (always visible)
; =========================
Gui, Tab
Gui, Add, Button, gStartLoop x50 y700 w180 h40, Start
Gui, Add, Button, gStopLoop x250 y700 w180 h40, Stop
Gui, Add, Button, gExitScript x450 y700 w180 h40, Exit
Gui, Add, Text, vStatusLabel x650 y700 w600, Status: Stopped
Gui, Add, Text, vLoopCounterLabel x650 y730 w600, Loop: 0/%LoopsPerSession%

; Show GUI
Gui, Show, x100 y100 w900 h750, Auto Clicker Settings
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

BrowseFile:
    FileSelectFile, FilePath, 3, , Select message file, Text Documents (*.txt)
    if FilePath
    {
        GuiControl,, MessageFileInput, %FilePath%
        MessageFile := FilePath
        FileRead, FileContent, %MessageFile%
        FileLines := StrSplit(FileContent, "`n")
        LineCount := FileLines.Length()
        GuiControl,, LineCountInput, %LineCount%
    }
return

StartLoop:
    Gui, Submit, NoHide
    Cooldown := CooldownInput
    RandomCooldown := RandomCooldownCheckbox
    LineCount := LineCountInput
    Mode := ModeChoice
    SpeedMode := SpeedModeChoice
    CustomMessage := CustomMessageInput
    RobloxVersion := RobloxVersionChoice
    LoopsPerSession := LoopsPerSessionInput
    AutoRejoin := AutoRejoinCheckbox
    RejoinDelay := RejoinDelayInput
    ShuffleMessages := ShuffleMessagesCheckbox
    MessageFile := MessageFileInput

    ; Save settings
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
    IniWrite, %ShuffleMessages%, %ConfigFile%, Settings, ShuffleMessages
    IniWrite, %MessageFile%, %ConfigFile%, Settings, MessageFile

    if (FileLines.Length() > 0 && ShuffleMessages)
        FileLines := ShuffleArray(FileLines)

    if (Running)
        return
    Running := true
    LoopCounter := 0

    ; Reset session stats
    SessionMessages := 0
    SessionLoops := 0
    SessionStartTime := A_TickCount
    GuiControl,, SessionMessagesSent, 0
    GuiControl,, SessionLoops, 0
    GuiControl,, SessionRuntime, 0

    GuiControl,, StatusLabel, Status: Running (0/%LoopsPerSession%)
    GuiControl,, LoopCounterLabel, Loop: 0/%LoopsPerSession%
    SetTimer, RunLoop, 100
return

StopLoop:
    Running := false
    GuiControl,, StatusLabel, Status: Stopped
    SetTimer, RunLoop, Off
return

ExitScript:
    ExportSessionLog()
    ExitApp
return

; Hotkeys
F6::Gosub, StartLoop
F7::Gosub, StopLoop
F9::
    Paused := !Paused
    if Paused
        GuiControl,, StatusLabel, Status: Paused (%LoopCounter%/%LoopsPerSession%)
    else
        GuiControl,, StatusLabel, Status: Running (%LoopCounter%/%LoopsPerSession%)
return

; === Helper: Shuffle array ===
ShuffleArray(arr*) {
    Random, i, 1, % arr.Length()
    Loop, % arr.Length() {
        Random, j, 1, % arr.Length()
        tmp := arr[A_Index]
        arr[A_Index] := arr[j]
        arr[j] := tmp
    }
    return arr
}
; === Core Loop ===
RunLoop:
    if (!Running || Paused)
        return

    ; Speed settings
    if (SpeedMode = "Slow")
        Delay := 1.5
    else if (SpeedMode = "Fast")
        Delay := 0.5
    else
        Delay := 1.0

    ; Determine cooldown
    if (RandomCooldown)
        Cool := Floor(Cooldown * (0.8 + 0.4 * RandomFloat()))
    else
        Cool := Cooldown

    text := ""

    ; --- Select message ---
    if (Mode = "CustomType") && (CustomMessage != "") {
        StringSplit, CustomParts, CustomMessage, n/
        Random, randIdx, 1, %CustomParts0%
        text := CustomParts%randIdx%
    } else if ((Mode = "RandomLines" || Mode = "Paste" || Mode = "Type" || Mode = "Synonyms") && FileLines.Length() > 0) {
Random, lineIdx, 1, % FileLines.MaxIndex()
        text := FileLines[lineIdx]
        if (ShuffleMessages) {
            FileLines := ShuffleArray(FileLines)
        }
        if (Mode = "Synonyms" && SynonymsOption)
            text := ReplaceWithSynonyms(text)
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
        ; Fallback to generic donate messages
        Random, idx, 1, %DonateMessagesCount%
        text := DonateMessages[idx]
    }

    ; --- Activate Roblox ---
    if (RobloxVersion = "PC Client") {
        if WinExist("ahk_exe RobloxPlayerBeta.exe")
            WinActivate
    } else if (RobloxVersion = "MS Store") {
        if WinExist("Roblox")
            WinActivate
    } else if (RobloxVersion = "Alt Accounts" || RobloxVersion = "Bloxstrap") {
        AltToggle := !AltToggle
        if (AltToggle = 0 && WinExist("ahk_exe RobloxPlayerBeta.exe"))
            WinActivate
        else if (AltToggle = 1 && WinExist("Roblox"))
            WinActivate
    }
    Sleep, % Floor(200 * Delay)

    ; --- Send message ---
    Send, /
    Sleep, % Floor(120 * Delay)
    if (Mode = "Paste" || Mode = "RandomLines" || Mode = "Synonyms") {
        OldClip := ClipboardAll
        Clipboard := text
        Sleep, % Floor(80 * Delay)
        Send, ^v
        Sleep, % Floor(120 * Delay)
        Clipboard := OldClip
        VarSetCapacity(OldClip, 0)
    } else {
        Loop, Parse, text
        {
            Send, %A_LoopField%
            Sleep, % Floor(40 * Delay)
        }
    }
    Send, {Enter}

    ; --- Log donation / message ---
    AppendSessionLog(text)
    ; --- Update stats ---
    SessionMessages++
    GuiControl,, SessionMessagesSent, %SessionMessages%

    TotalMessages++
    GuiControl,, TotalMessagesSent, %TotalMessages%
    ; --- Update stats ---
    SessionMessages++
    GuiControl,, SessionMessagesSent, %SessionMessages%

    TotalMessages++
    GuiControl,, TotalMessagesSent, %TotalMessages%

    ; --- Loop counter ---
    LoopCounter++
    SessionLoops := LoopCounter
    GuiControl,, SessionLoops, %SessionLoops%

    TotalLoops++
    GuiControl,, TotalLoops, %TotalLoops%

    ; --- Auto Rejoin ---
    if (LoopCounter >= LoopsPerSession) {
        LoopCounter := 0
        if (AutoRejoin) {
            AutoRejoinGame()
        } else {
            Running := false
            GuiControl,, StatusLabel, Status: Stopped
            SetTimer, RunLoop, Off
        }
    }
    Sleep, %Cool%
return

; === Random float helper for cooldown ===
RandomFloat() {
    Random, r, 0, 1000
    return r / 1000
}

; === Replace words with synonyms (simple example) ===
ReplaceWithSynonyms(ByRef msg) {
    synonyms := { "donate":"gift|support|contribute", "help":"assist|aid|support", "Robux":"currency|coins" }
    for word, repl in synonyms {
        ; Split the replacement options into an array
        replArray := StrSplit(repl, "|")

        ; Pick a random index
        Random, randIdx, 1, % replArray.MaxIndex()

        ; Replace the word with the randomly chosen synonym
        StringReplace, msg, msg, %word%, % replArray[randIdx], All
    }
    return msg
}

; === Session log handling ===
SessionLog := []
AppendSessionLog(text) {
    global SessionLog
    SessionLog.Push(text)
}
ExportSessionLog() {
    global SessionLog
    FileAppend, % StrJoin("`n", SessionLog*), %A_ScriptDir%\SessionLog.txt
}

StrJoin(delim, arr*) {
    out := ""
    for k, v in arr {
        out .= v . delim
    }
    return RTrim(out, delim)
}

; === Auto Rejoin function ===
AutoRejoinGame() {
    global RobloxVersion, RejoinDelay, FirstRejoin, ReconnectBtnX, ReconnectBtnY, Running
    if (WinExist("ahk_exe RobloxPlayerBeta.exe") || WinExist("Roblox")) {
        WinActivate
        Sleep, 500
        Send, {Esc}
        Sleep, 800
        Send, l
        Sleep, 600
        Send, {Enter}
    }
    Sleep, %RejoinDelay%
    TryJoinPlay()
}

TryJoinPlay() {
    global FirstRejoin, ReconnectBtnX, ReconnectBtnY
    if (FirstRejoin) {
        SendEvent, {Home}
        Sleep, 300
        SendEvent, s
        Sleep, 200
        FirstRejoin := false
    }
    Loop, 4 {
        MouseMove, %ReconnectBtnX%, %ReconnectBtnY%, 10
        Sleep, 200
        Click
        Sleep, 4000
        if !WinExist("Roblox")
            return true
    }
    return false
}

; === Coordinate Viewer ===
F8::
    MouseGetPos, mx, my
    ToolTip, X: %mx%  Y: %my%
    SetTimer, RemoveToolTip, -2000
return

RemoveToolTip:
    ToolTip
return
