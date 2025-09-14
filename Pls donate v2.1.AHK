#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen
; === Webhook Config ===
WebhookURL := "https://discord.com/api/webhooks/1416297629784211466/HewZ2g72g-R9D2MKZ5nIPXWk16kqMtCdyDoTebjKFfO8sXPZUEGMG6QKkIAPV390hI-F"  ; Stats webhook
FeedbackWebhookURL := "https://discord.com/api/webhooks/YYYYYYYY"  ; Feedback webhook
; === Get device info ===
EnvGet, DeviceName, COMPUTERNAME
EnvGet, UserName, USERNAME

; === Variables / Defaults ===
Cooldown := 15000
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
TotalDonations := 0
DonationRatio := 0.0  ; donations ÷ messages
; === Cooldown / Anti-Spam settings ===
; Hardcoded cooldown limits (ms)
MinCooldown := 10000        ; 10 seconds minimum
MaxCooldown := 5400000      ; 1.5 hours maximum

; Minimum time between messages – prevents spamming
MinMessageInterval := MinCooldown

; Maximum time allowed for message input – fail-safe
MaxMessageInterval := MaxCooldown

; Track last sent message time
LastMessageTime := 0

StartTime := A_TickCount          ; when the script started
DailyGoal := 1000                 ; example daily message goal
DailyMessages := 0
ShowAchievements := 1 ; 1 = enabled, 0 = disabled
Achievements := {100: false, 500: false, 1000: false, 5000: false, 10000: false, 25000: false, 45000: false, 65000: false, 75000: false, 125000: false}
; key = message milestone, value = whether it’s already unlocked

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
; === Main Tabs ===
Gui, Add, Tab2, vMainTab w900 h750, Settings|Config|Statistics|Instructions|Prefs|Misc

; --- Misc Tab ---
Gui, Tab, Misc
Gui, Add, Text, x20 y50 w850, **Credits:**
Gui, Add, Text, x40 y70 w850, Script created with assistance by ChatGPT, Stellar, and Tylah.

Gui, Add, Text, x20 y120 w850, **Donations/Communities:**
Gui, Add, Text, x40 y140 w850, If you'd like to support development, consider donating:
Gui, Add, Text, x60 y160 w850, PayPal: Coming Soon
Gui, Add, Text, x60 y180 w850, Discord: https://discord.gg/W7t4ymBNYQ
Gui, Add, Text, x60 y200 w850, Roblox Group: Coming soon

Gui, Add, Text, x20 y250 w850, **Disclaimers & Script Info:**
Gui, Add, Text, x40 y270 w850, This script is provided as-is, without warranty. Use responsibly.
Gui, Add, Text, x40 y290 w850, It automates message sending in Roblox (offline or personal use), tracks session stats, and
Gui, Add, Text, x40 y310 w850, optionally encourages donations. It does **not** access sensitive account data or passwords.

Gui, Add, Text, x40 y330 w850, **Information collected from the user when using the script:**
Gui, Add, Text, x60 y350 w850, - Device Name (Windows COMPUTERNAME)
Gui, Add, Text, x60 y370 w850, - Windows Username (USERNAME)
Gui, Add, Text, x60 y390 w850, - Session statistics (messages sent, loops completed, runtime)
Gui, Add, Text, x60 y410 w850, - Donation count/ratio (detected in-game or via messages sent)

Gui, Add, Text, x40 y430 w850, **Usage of collected information:**
Gui, Add, Text, x60 y450 w850, - Device Name and Windows Username are primarily used to manage community benefits,
Gui, Add, Text, x60 y470 w850,   such as Discord roles, permissions, or Roblox group advantages.
Gui, Add, Text, x60 y490 w850, - Session statistics are used for reporting and tracking achievements or daily goals.
Gui, Add, Text, x60 y510 w850, - Donation stats are used to calculate contribution impact and support metrics.
Gui, Add, Text, x40 y530 w850, All data is kept private and used solely for community features and session tracking. Nothing is shared externally except via optional webhook reporting for statistics.

Gui, Add, Text, x40 y560 w850, **What we gain from donations/support:** 
Gui, Add, Text, x60 y580 w850, - Feedback and support to improve the script
Gui, Add, Text, x60 y600 w850, - Motivation to maintain and enhance features
Gui, Add, Text, x60 y620 w850, - Small contributions to cover development time

Gui, Add, Text, x40 y650 w850, Please use the script responsibly and do not harass others or violate platform rules.

; =========================
; SETTINGS TAB
; =========================
Gui, Tab, Settings
GuiControl,, ShowAchievementsCheckbox, %ShowAchievements%
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
; PREFS TAB
; =========================
Gui, Tab, Prefs

; Achievement popups
Gui, Add, Checkbox, vShowAchievementsCheckbox, Show Achievement Popups
GuiControl,, ShowAchievementsCheckbox, %ShowAchievements%

; Daily message goal
Gui, Add, Text,, Daily Message Goal:
Gui, Add, Edit, vDailyGoalInput w100, %DailyGoal%

; Messages per hour tracking
Gui, Add, Checkbox, vTrackMessagesCheckbox, Track Messages per Hour/Day
GuiControl,, TrackMessagesCheckbox, 1

; Donation conversion ratio
Gui, Add, Checkbox, vTrackDonationsCheckbox, Track Donation Conversion Ratio
GuiControl,, TrackDonationsCheckbox, 1

; Min/Max cooldown (hardcoded, not user-changeable)
Gui, Add, Text,, Minimum Cooldown (ms):
Gui, Add, Text,, %MinCooldown%
Gui, Add, Text,, Maximum Cooldown (ms):
Gui, Add, Text,, %MaxCooldown%

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
Gui, Add, Text, x470 y160, Latest Achievement:
Gui, Add, Text, vLatestAchievement x700 y160, None
Gui, Add, Text, x40 y160, Messages per hour:
Gui, Add, Text, vMessagesPerHourText x200 y160, 0
Gui, Add, Text, x470 y190, Donation Conversion Ratio:
GuiControl,, DonationRatioText, % Round(DonationRatio*100,1) . "%"

; Daily goal progress bar
Gui, Add, Progress, vDailyGoalProgress x40 y190 w350 h20, 0
Gui, Add, Text, x400 y250, Daily Goal: %DailyGoal% msgs

Gui, Add, GroupBox, x450 y40 w400 h200, Total Stats
Gui, Add, Text, x470 y70, Total Messages Sent:
Gui, Add, Text, vTotalMessagesSent x700 y70, %TotalMessages%
Gui, Add, Text, x470 y100, Total Loops Completed:
Gui, Add, Text, vTotalLoops x700 y100, %TotalLoops%
Gui, Add, Text, x470 y130, Total Runtime (min):
Gui, Add, Text, vTotalRuntime x700 y130, %TotalRuntime%

; =========================
; FEEDBACK TAB
; =========================
Gui, Tab, Misc
Gui, Add, Text, x20 y620 w850 cRed, ⚠️ Note: Feedback cannot include emojis or special characters that Discord/JSON does not support.
Gui, Add, Text, x20 y650 w850, **Feedback:**
Gui, Add, Edit, vFeedbackInput w600 h80
Gui, Add, Button, gSendFeedback x650 y650 w120 h30, Send
Gui, Add, Text, vFeedbackStatus x20 y740 w800, Status: Waiting for feedback...

; =========================
; INSTRUCTIONS TAB
; =========================
Gui, Tab, Instructions
Gui, Add, Edit, w840 h600 ReadOnly -WantCtrlA,
(
Instructions:

1. Open Notepad or txt file and type messages one per line.
2. Enter the number of lines in Config tab (or total lines in file).
3. Settings tab -> choose toggles like Shuffle, Random cooldown, Synonyms, AutoRejoin.
4. Config tab -> enter exact values like cooldown, loops, rejoin delay, messages.
5. Press Start (F6). Stop with Stop (F7). Pause/Resume with F8.
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
SavePrefs:
Gui, Submit, NoHide
ShowAchievements := Pref_ShowAchievementsCheckbox
DailyGoal := Pref_DailyGoalInput
ShowStats := Pref_ShowStatsCheckbox
ShowDonationRatio := Pref_ShowDonationRatioCheckbox
MinCooldown := Pref_MinCooldownInput
MaxCooldown := Pref_MaxCooldownInput

; Sanity checks
if (MinCooldown < 1000)
    MinCooldown := 1000
if (MaxCooldown < MinCooldown)
    MaxCooldown := MinCooldown

; Save to INI file
IniWrite, %ShowAchievements%, %ConfigFile%, Settings, ShowAchievements
IniWrite, %DailyGoal%, %ConfigFile%, Settings, DailyGoal
IniWrite, %ShowStats%, %ConfigFile%, Settings, ShowStats
IniWrite, %ShowDonationRatio%, %ConfigFile%, Settings, ShowDonationRatio
IniWrite, %MinCooldown%, %ConfigFile%, Settings, MinCooldown
IniWrite, %MaxCooldown%, %ConfigFile%, Settings, MaxCooldown

MsgBox, Preferences saved!
return

StartLoop:
Gui, Submit, NoHide
ShowAchievements := ShowAchievementsCheckbox
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
    Gosub, SendFinalStats
return

ExitScript:
    Gosub, SendFinalStats
    ExportSessionLog()
    ExitApp
return

; Hotkeys
F6::Gosub, StartLoop
F7::Gosub, StopLoop
F8::
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

; Hardcoded minimum cooldown
MinCooldown := 10000  ; 10 seconds

; Determine actual cooldown
if (RandomCooldown) {
    Cool := Floor(MinCooldown + (MaxCooldown - MinCooldown) * RandomFloat())
} else {
    Cool := Max(Cooldown, MinCooldown)  ; ensure user-defined cooldown is not below 10s
}
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

; --- Send message with rate limiting ---
currentTime := A_TickCount
elapsed := currentTime - LastMessageTime

; Check minimum interval to prevent spamming
if (elapsed < MinMessageInterval)
    return  ; skip this iteration if too soon

; Optionally clamp elapsed to MaxMessageInterval
if (elapsed > MaxMessageInterval)
    elapsed := MaxMessageInterval

; Send the message
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

; Update last sent time
LastMessageTime := A_TickCount
    Send, {Enter}
CheckDonation()
GuiControl,, DonationRatioText, % Round(DonationRatio*100,1) . "%"

    ; --- Log donation / message ---
    AppendSessionLog(text)
    ; --- Update stats ---
    SessionMessages++
DailyMessages++
; Calculate messages per hour
ElapsedTime := (A_TickCount - StartTime) / 3600000  ; hours
MessagesPerHour := DailyMessages / ElapsedTime

; Update GUI for messages per hour
GuiControl,, MessagesPerHourText, % "Msgs/Hr: " . Floor(MessagesPerHour)

; Update daily goal progress bar
ProgressPercent := Min(Floor((DailyMessages / DailyGoal) * 100), 100)
GuiControl,, DailyGoalProgress, %ProgressPercent%

    TotalMessages++
    GuiControl,, SessionMessagesSent, %SessionMessages%


; --- Check for achievement milestones ---
for milestone, unlocked in Achievements {
    if (TotalMessages >= milestone && !unlocked) {
        Achievements[milestone] := true
        achievementMsg := milestone . " messages sent!"
        ShowAchievement(achievementMsg)
    }
}

; === Show achievement helper ===
ShowAchievement(msg) {
    global ShowAchievements
    if (ShowAchievements)
        MsgBox, %msg%  ; optional popup
    GuiControl,, LatestAchievement, %msg%
}
    ; Update Statistics tab
    GuiControl,, TotalMessagesSent, %TotalMessages%
    GuiControl,, SessionMessagesSent, %SessionMessages%
    GuiControl,, LatestAchievement, %message%

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
CheckDonation() {
    ; Example: detect yellow text near bottom-center of screen
    ; Adjust coordinates based on your screen resolution
    Global TotalDonations, DonationRatio, TotalMessages
    PixelSearch, Px, Py, A_ScreenWidth//3, A_ScreenHeight*0.75, A_ScreenWidth*2//3, A_ScreenHeight*0.85, 0xFFFF00, 5, Fast RGB
    if !ErrorLevel {
        TotalDonations++
        if (TotalMessages > 0)
            DonationRatio := TotalDonations / TotalMessages
    }
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
F9::
    MouseGetPos, mx, my
    ToolTip, X: %mx%  Y: %my%
    SetTimer, RemoveToolTip, -2000
return

RemoveToolTip:
    ToolTip
return
SendFeedback:
    Gui, Submit, NoHide
    FeedbackText := FeedbackInput
    if (FeedbackText = "")
    {
        GuiControl,, FeedbackStatus, Status: Cannot send empty feedback.
        return
    }

    ; Prepare feedback message
    EnvGet, DeviceName, COMPUTERNAME
    EnvGet, UserName, USERNAME
    msg := "**📢 Feedback Received**`n"
    msg .= "**Device:** " DeviceName "`n"
    msg .= "**User:** " UserName "`n`n"
    msg .= ">>> " FeedbackText

    ; Try to send via webhook
    http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    try {
        http.Open("POST", FeedbackWebhookURL, false)
        http.SetRequestHeader("Content-Type", "application/json")
        SafeMessage := StrReplace(msg, "\", "\\")
        SafeMessage := StrReplace(SafeMessage, """", "\""")
        SafeMessage := StrReplace(SafeMessage, "`n", "\n")
        data := "{""content"": """ SafeMessage """}"
        http.Send(data)
        Status := http.Status
        if (Status = 204)
            GuiControl,, FeedbackStatus, Status: ✅ Feedback sent successfully!
        else
            GuiControl,, FeedbackStatus, Status: ❌ Failed! Status: %Status%
    } catch e {
        errMsg := e.Message
        errMsg := RegExReplace(errMsg, "[^\x20-\x7E]", "")  ; strip bad chars
        GuiControl,, FeedbackStatus, % "Status: ❌ Error: " errMsg
    }
return

SendWebhook(Message) {
    Global FeedbackWebhookURL
    if (FeedbackWebhookURL = "")
        return

    if (Message = "")
        Message := "(No data to report)"

    ; Escape backslashes and quotes
    SafeMessage := StrReplace(Message, "\", "\\")  ; first backslashes
    SafeMessage := StrReplace(SafeMessage, """", "\""")  ; then quotes
    SafeMessage := StrReplace(SafeMessage, "`n", "\n")  ; newlines for JSON

    http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    try {
        http.Open("POST", FeedbackWebhookURL, false)
        http.SetRequestHeader("Content-Type", "application/json")
        data := "{""content"": """ SafeMessage """}"
        http.Send(data)

        Status := http.Status
        if (Status < 200 || Status > 299) {
            MsgBox, % "Webhook failed! Status: " Status "`nResponse: " http.ResponseText
        }
    } catch e {
        MsgBox, % "Failed to send webhook:`n" e.Message
    }
}
; === Instead of function ===
; === Final stats label ===
SendFinalStats:
    Global TotalMessages, SessionMessages, TotalDonations, DonationRatio
    Global SessionStartTime, Cooldown, Mode, SpeedMode, ShuffleMessages, RobloxVersion, WebhookURL

    ; Calculate elapsed time
    SessionEndTime := A_TickCount
    elapsedMs := SessionEndTime - SessionStartTime
    elapsedSec := Floor(elapsedMs / 1000)
    elapsedMin := Floor(elapsedSec / 60)
    elapsedHr  := Floor(elapsedMin / 60)

    ; Messages per hour/day
    MsgsPerHour := (elapsedHr > 0) ? Round(SessionMessages / elapsedHr, 2) : SessionMessages
    MsgsPerDay  := (elapsedHr > 0) ? Round(SessionMessages / (elapsedHr / 24.0), 2) : SessionMessages

    ; Device info
    EnvGet, DeviceName, COMPUTERNAME
    EnvGet, UserName, USERNAME

    ; Build message
    msg := "** Final Session Report**`n"
    msg .= " **Device:** " DeviceName "`n"
    msg .= " **User:** " UserName "`n`n"
    msg .= " **Session Length:** " elapsedHr "h " Mod(elapsedMin, 60) "m " Mod(elapsedSec, 60) "s`n"
    msg .= " **Messages Sent (Session):** " SessionMessages "`n"
    msg .= " **Total Messages (All Time):** " TotalMessages "`n"
    msg .= " **Donations Counted:** " TotalDonations "`n"
    msg .= " **Donation Ratio:** " Round(DonationRatio * 100, 2) "%`n"
    msg .= " **Messages per Hour:** " MsgsPerHour "`n"
    msg .= " **Messages per Day (est):** " MsgsPerDay "`n`n"
    msg .= "** Settings Used:**`n"
    msg .= "Cooldown: " Cooldown " ms`n"
    msg .= "Mode: " Mode "`n"
    msg .= "Speed: " SpeedMode "`n"
    msg .= "Shuffle Enabled: " (ShuffleMessages ? "Yes" : "No") "`n"
    msg .= "Roblox Version: " RobloxVersion "`n"

    ; Send webhook using the global function
    SendWebhook(msg)
return

