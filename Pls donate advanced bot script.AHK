#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen
; === Webhook Config ===
WebhookURL := "https://discord.com/api/webhooks/1416297629784211466/HewZ2g72g-R9D2MKZ5nIPXWk16kqMtCdyDoTebjKFfO8sXPZUEGMG6QKkIAPV390hI-F"  ; Stats webhook
FeedbackWebhookURL := "https://discord.com/api/webhooks/1416391483627540624/mRPTSwaEDISGhArtkVc9bz3wupLVXdqjtfCYLHgJHwssdzeMke_vNF2aSxkXEHAeEXVt"  ; Feedback webhook
Global LeaderboardWebhookURL := "https://discord.com/api/webhooks/1416603247258370079/8DBSBwLJl5yhWF-0Ox3EEIzDoV0Zhi1AmDulSC3D34MN0lZnHEzguU0l2GIh2KeLECy3"    ; leaderboard webhook
Global StatsFile
StatsFile := A_ScriptDir "\stats.ini"
LogDebug(msg) {
    debugFile := A_ScriptDir "\DebugLog.txt"
    timestamp := A_Now
    FileAppend, [%timestamp%] %msg%`n, %debugFile%
}

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
currentPage := 1
currentStat := "TotalMessages"
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

StatsFile := A_ScriptDir "\stats.ini"
StatsSection := "Stats"

SaveStats() {
    Global StatsFile, StatsSection
    Global TotalMessages, TotalLoops, TotalRuntime, TotalDonations, DonationRatio

    IniWrite, %TotalMessages%, %StatsFile%, %StatsSection%, TotalMessages
    IniWrite, %TotalLoops%, %StatsFile%, %StatsSection%, TotalLoops
    IniWrite, %TotalRuntime%, %StatsFile%, %StatsSection%, TotalRuntime
    IniWrite, %TotalDonations%, %StatsFile%, %StatsSection%, TotalDonations
    IniWrite, %DonationRatio%, %StatsFile%, %StatsSection%, DonationRatio
}

LoadStats() {
    Global StatsFile, StatsSection
    Global TotalMessages, TotalLoops, TotalRuntime, TotalDonations, DonationRatio

    IniRead, TotalMessages, %StatsFile%, %StatsSection%, TotalMessages, 0
    IniRead, TotalLoops, %StatsFile%, %StatsSection%, TotalLoops, 0
    IniRead, TotalRuntime, %StatsFile%, %StatsSection%, TotalRuntime, 0
    IniRead, TotalDonations, %StatsFile%, %StatsSection%, TotalDonations, 0
    IniRead, DonationRatio, %StatsFile%, %StatsSection%, DonationRatio, 0
}

; Load stats on script start
LoadStats()

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
Gui, Add, Tab2, vMainTab w900 h750, Settings|Config|Statistics|Instructions|Prefs|Info|Leaderboard|Misc

; =========================
; MISC TAB
; =========================
Gui, Tab, Misc

; --- Credits ---
Gui, Add, Text, x20 y20 w850, Credits:
Gui, Add, Text, x40 y40 w850, Script created with assistance by ChatGPT, Stellar, and Tylah.

; --- Donations / Communities ---
Gui, Add, Text, x20 y80 w850, Donations/Communities:
Gui, Add, Text, x40 y100 w850, If you would like to support development, consider donating or joining:
Gui, Add, Text, x60 y120 w850, PayPal: Coming Soon
Gui, Add, Text, x60 y140 w850, Discord: https://discord.gg/W7t4ymBNYQ
Gui, Add, Text, x60 y160 w850, Roblox Group: Coming Soon

; --- Disclaimers & Script Info ---
Gui, Add, Text, x20 y200 w850, Disclaimers and Script Info:
Gui, Add, Text, x40 y220 w850, This script is provided as-is, without warranty. Use responsibly.
Gui, Add, Text, x40 y240 w850, It automates message sending in Roblox (offline or personal use), tracks session stats, and
Gui, Add, Text, x40 y260 w850, optionally encourages donations. It does not access sensitive account data or passwords.

; --- Benefits of Support ---
Gui, Add, Text, x20 y300 w850, What we gain from donations/support: 
Gui, Add, Text, x40 y320 w850, - Feedback and support to improve the script
Gui, Add, Text, x40 y340 w850, - Motivation to maintain and enhance features
Gui, Add, Text, x40 y360 w850, - Small contributions to cover development time

; --- Responsible Use ---
Gui, Add, Text, x20 y400 w850, Responsible Use:
Gui, Add, Text, x40 y420 w850, Please use the script responsibly and do not harass others or violate platform rules.

; --- Feedback Instructions ---
Gui, Add, Text, x20 y460 w850, Feedback Instructions:
Gui, Add, Text, x40 y480 w850, - Open Notepad or txt file and type messages, feedback, or issues one per line.
Gui, Add, Text, x40 y500 w850, - Feedback helps prioritize updates and fixes.
Gui, Add, Text, x40 y520 w850, - You can share feedback via Discord or optional form provided.

; --- Feedback Form ---
Gui, Add, Text, x20 y560 w850 cRed, Note: Feedback cannot include quotes ("), backslashes (\), control characters, null characters, or emojis.
Gui, Add, Text, x20 y580 w850, Submit Feedback:
Gui, Add, Edit, vFeedbackInput w600 h75
Gui, Add, Button, gSendFeedback x640 y615 w120 h45, Send
Gui, Add, Text, vFeedbackStatus x20 y670 w800, Status: Waiting for feedback...

; =========================
; SETTINGS TAB (Cleaned)
; =========================
Gui, Tab, Settings
Gui, Font, s10 Bold, Segoe UI
Gui, Add, Text, x30 y40, General Options
Gui, Font, s9 Norm

; General checkboxes
Gui, Add, Checkbox, vRandomCooldownCheckbox x50 y70, Randomize cooldown
GuiControl,, RandomCooldownCheckbox, %RandomCooldown%

Gui, Add, Checkbox, vUseNotepadCheckbox gToggleNotepad x50 y100, Copy line from Notepad
GuiControl,, UseNotepadCheckbox, %UseNotepad%

Gui, Add, Checkbox, vShuffleMessagesCheckbox x50 y130, Shuffle messages
GuiControl,, ShuffleMessagesCheckbox, %ShuffleMessages%

Gui, Add, Checkbox, vSynonymsOptionCheckbox x50 y160, Replace words with synonyms
GuiControl,, SynonymsOptionCheckbox, %SynonymsOption%

Gui, Add, Checkbox, vAutoRejoinCheckbox x50 y190, Enable Auto Rejoin
GuiControl,, AutoRejoinCheckbox, %AutoRejoin%

; Extra visual polish
Gui, Font, s9 Italic
Gui, Add, Text, x50 y230 cGray, (Tip: Use these toggles to fine-tune behavior quickly.)
Gui, Font

; =========================
; CONFIG TAB (Cleaned)
; =========================
Gui, Tab, Config
Gui, Font, s10 Bold, Segoe UI
Gui, Add, Text, x30 y40, General Configuration  ; ↑ increased y to avoid overlap
Gui, Font, s9 Norm

; Cooldown
Gui, Add, Text, x50 y60, Cooldown (ms):
Gui, Add, Edit, vCooldownInput w150 x180 y55, %Cooldown%
Gui, Add, Text, x340 y60 cGray, (Time between actions)

; Number of lines
Gui, Add, Text, x50 y90, Number of lines in Notepad:
Gui, Add, Edit, vLineCountInput w150 x220 y85, %LineCount%

; Custom Messages
Gui, Add, Text, x50 y120, Custom Messages (n/ separated for random):
Gui, Add, Edit, vCustomMessageInput w600 h80 x50 y145, %CustomMessage%

; Loops per session
Gui, Add, Text, x50 y240, Loops per Session:
Gui, Add, Edit, vLoopsPerSessionInput w150 x200 y235, %LoopsPerSession%

; Rejoin delay
Gui, Add, Text, x50 y270, Rejoin Delay (ms):
Gui, Add, Edit, vRejoinDelayInput w150 x200 y265, %RejoinDelay%

; File input
Gui, Add, Text, x50 y300, Load messages from file (txt):
Gui, Add, Edit, vMessageFileInput w400 x250 y295, %MessageFile%
Gui, Add, Button, gBrowseFile x660 y295, Browse

; =========================
; Multi-choice Options
; =========================
Gui, Add, Text, x30 y340, Multi-choice Options
Gui, Add, Text, x50 y370, Roblox Version:
Gui, Add, DropDownList, vRobloxVersionChoice w300 x200 y365, PC Client|MS Store|Alt Accounts|Bloxstrap
GuiControl, ChooseString, RobloxVersionChoice, %RobloxVersion%

Gui, Add, Text, x50 y400, Speed Mode:
Gui, Add, DropDownList, vSpeedModeChoice w180 x200 y395, Slow|Normal|Fast
GuiControl, ChooseString, SpeedModeChoice, %SpeedMode%
; =========================
; PREFS TAB (User-editable)
; =========================
Gui, Tab, Prefs
Gui, Font, s10 Bold, Segoe UI
Gui, Add, Text, x30 y40, User Preferences
Gui, Font, s9 Norm

; Achievement popups
Gui, Add, Checkbox, vShowAchievementsCheckbox x50 y60, Show Achievement Popups
GuiControl,, ShowAchievementsCheckbox, %ShowAchievements%

; Daily message goal
Gui, Add, Text, x50 y90, Daily Message Goal:
Gui, Add, Edit, vDailyGoalInput w100 x200 y85, %DailyGoal%

; Messages per hour tracking
Gui, Add, Checkbox, vTrackMessagesCheckbox x50 y120, Track Messages per Hour/Day
GuiControl,, TrackMessagesCheckbox, 1

; Donation conversion ratio
Gui, Add, Checkbox, vTrackDonationsCheckbox x50 y150, Track Donation Conversion Ratio
GuiControl,, TrackDonationsCheckbox, 1

; =========================
; INFO TAB (Read-only)
; =========================
Gui, Tab, Info
Gui, Font, s10 Bold, Segoe UI
Gui, Add, Text, x30 y40, Script Information
Gui, Font, s9 Norm

; Minimum cooldown
Gui, Add, Text, x50 y60, Minimum Cooldown (ms):
Gui, Add, Text, x250 y60, %MinCooldown%

; Maximum cooldown
Gui, Add, Text, x50 y90, Maximum Cooldown (ms):
Gui, Add, Text, x250 y90, %MaxCooldown%

; --- User Collected Information ---
Gui, Font, s10 Bold, Segoe UI
Gui, Add, Text, x30 y130, Information collected from the user
Gui, Font, s9 Norm
Gui, Add, Text, x50 y160, - Device Name (Windows COMPUTERNAME)
Gui, Add, Text, x50 y180, - Windows Username (USERNAME)
Gui, Add, Text, x50 y200, - Session statistics (messages sent, loops completed, runtime)
Gui, Add, Text, x50 y220, - Donation count/ratio (detected in-game or via messages sent)

Gui, Add, Text, x30 y260, Usage of collected information
Gui, Add, Text, x50 y290, - Device Name and Windows Username are primarily used to manage community benefits,
Gui, Add, Text, x50 y310,   such as Discord roles, permissions, or Roblox group advantages.
Gui, Add, Text, x50 y330, - Session statistics are used for reporting and tracking achievements or daily goals.
Gui, Add, Text, x50 y350, - Donation stats are used to calculate contribution impact and support metrics.
Gui, Add, Text, x50 y370, All data is kept private and used solely for community features and session tracking.

; =========================
; STATISTICS TAB
; =========================
Gui, Tab, Statistics

; --- Session Stats ---
Gui, Add, GroupBox, x20 y40 w400 h220, Session Stats
Gui, Add, Text, x40 y70, Messages Sent:
Gui, Add, Text, vSessionMessagesSent x200 y70, 0
Gui, Add, Text, x40 y100, Loops Completed:
Gui, Add, Text, vSessionLoops x200 y100, 0
Gui, Add, Text, x40 y130, Runtime (min):
Gui, Add, Text, vSessionRuntime x200 y130, 0
Gui, Add, Text, x40 y160, Messages per Hour:
Gui, Add, Text, vMessagesPerHourText x200 y160, 0
Gui, Add, Text, x40 y190, Latest Achievement:
Gui, Add, Text, vLatestAchievement x200 y190, None

; --- Daily Goal ---
Gui, Add, Progress, vDailyGoalProgress x40 y220 w350 h20, 0
Gui, Add, Text, x385 y275, Daily Goal: %DailyGoal% msgs

; --- Total Stats ---
Gui, Add, GroupBox, x450 y40 w400 h220, Total Stats
Gui, Add, Text, x470 y70, Total Messages Sent:
Gui, Add, Text, vTotalMessagesSent x700 y70, %TotalMessages%
Gui, Add, Text, x470 y100, Total Loops Completed:
Gui, Add, Text, vTotalLoops x700 y100, %TotalLoops%
Gui, Add, Text, x470 y130, Total Runtime (min):
Gui, Add, Text, vTotalRuntime x700 y130, %TotalRuntime%
Gui, Add, Text, x470 y160, Total Donations:
Gui, Add, Text, vTotalDonationsText x700 y160, %TotalDonations%
Gui, Add, Text, x470 y190, Donation Conversion Ratio:
Gui, Add, Text, vDonationRatioText x700 y190, % Round(DonationRatio*100,1) . "%"

; --- Refresh Button ---
Gui, Add, Button, gRefreshStats x470 y220 w150 h30, Refresh Stats

; =========================
; LEADERBOARD TAB
; =========================
Gui, Tab, Leaderboard
Gui, Add, GroupBox, x20 y40 w850 h600, Global Leaderboard
Gui, Add, Edit, vLeaderboardOutput x40 y70 w800 h500 ReadOnly +Center
Gui, Add, Button, gPrevPage x40 y580 w150 h30, Previous Page
Gui, Add, Button, gNextPage x200 y580 w150 h30, Next Page
Gui, Add, Button, gRefreshLeaderboard x40 y620 w150 h30, Refresh Leaderboard

; =========================
; INSTRUCTIONS TAB
; =========================
Gui, Tab, Instructions
Gui, Add, Edit, w840 h600 ReadOnly -WantCtrlA,
(
Instructions:

1. Prepare your messages:
   - Open Notepad or any .txt file.
   - Type one message per line.

2. Configure total lines:
   - Go to the Config tab.
   - Enter the number of lines in your file (or total lines you want to process).

3. Adjust settings:
   - Open the Settings tab.
   - Choose toggles such as:
     * Shuffle - randomize message order.
     * Random cooldown - vary time between messages.
     * Synonyms - replace words with alternatives.
     * AutoRejoin - automatically rejoin sessions if disconnected.

4. Set precise values:
   - Back in Config tab, enter exact numbers for:
     * Cooldown between messages (ms)
     * Loops to run
     * Rejoin delay (if AutoRejoin is on)
     * Number of messages per session

5. Start / Stop / Pause:
   - Start: Press F6 (if F6 does not work, try Fn + F6 or check your keyboard and use function lock).
   - Stop: Press F7 (or use the Stop button in GUI).
   - Pause / Resume: Press F8.

6. Export session log:
   - Use the menu option to save/export your session log.
   - Recommended for tracking stats or achievements.

Tips and Alternatives:
- If hotkeys do not respond, make sure the script is running and GUI is active.
- For laptops, some function keys require Fn + key combination.
- Always save your messages file before starting to avoid missing lines.
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
; After Gui, Show
SetTimer, AutoSaveStats, 60000
AutoSaveStats:
    SaveStats()
return
ShowLeaderboardPage() {
    Global currentPage, StatsFile
    statsList := ["TotalMessages","TotalLoops","TotalRuntime","TotalDonations","DonationRatio"]
    text := "Global Leaderboard`n`n"
GuiControl,, LeaderboardOutput, %text%
LogDebug("Leaderboard displayed: Page " currentPage " for stat " statsList*)

    for _, stat in statsList {
        text .= stat "`n"
        text .= "Rank | Username | Value`n"
        text .= "----------------------`n"

        users := GetTopUsers(stat)
        startIdx := (currentPage-1)*10 + 1
        endIdx := Min(startIdx + 9, users.MaxIndex())

        Loop, % endIdx - startIdx + 1 {
            idx := startIdx + A_Index - 1
            u := users[idx]
            text .= A_Index + ((currentPage-1)*10) ". " u.name " | " u.value "`n"
        }
        text .= "`n"
    }

    GuiControl,, LeaderboardOutput, %text%
}

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
    if (!Running) ; already stopped
        return
    Running := false
    Paused := false
    SetTimer, RunLoop, Off
    TotalRuntime += Floor((A_TickCount - SessionStartTime)/60000) ; Add session runtime
    GuiControl,, StatusLabel, Status: Stopped
    GuiControl,, LoopCounterLabel, Loop: %LoopCounter%/%LoopsPerSession%
    SaveStats()
    SendLeaderboard()
return

ExitScript:
    TotalRuntime += Floor((A_TickCount - SessionStartTime)/60000)
    SaveStats()
    SendLeaderboard() ; send global update
    ExitApp
return
PrevPage:
    if (currentPage > 1)
        currentPage--
    ShowLeaderboardPage()
return

NextPage:
    users := GetTopUsers(currentStat)
    maxPage := Ceil(users.MaxIndex()/10)
    if (currentPage < maxPage)
        currentPage++
    ShowLeaderboardPage()
return

RefreshLeaderboard:
    currentPage := 1
    ShowLeaderboardPage()
return
RefreshStats:
    ; Load latest stats from INI
    LoadStats()

    ; Update Session stats
    GuiControl,, SessionMessagesSent, %SessionMessages%
    GuiControl,, SessionLoops, %SessionLoops%
GuiControl,, SessionRuntime, % Floor((A_TickCount - SessionStartTime)/60000)

    ; Update Total stats
    GuiControl,, TotalMessagesSent, %TotalMessages%
    GuiControl,, TotalLoops, %TotalLoops%
    GuiControl,, TotalRuntime, %TotalRuntime%
    GuiControl,, TotalDonationsText, %TotalDonations%
    GuiControl,, DonationRatioText, % Round(DonationRatio*100,1) . "%"

    ; Optional: recalc Messages per hour
    ElapsedTime := (A_TickCount - StartTime) / 3600000  ; hours
    MessagesPerHour := DailyMessages / ElapsedTime
    GuiControl,, MessagesPerHourText, % "Msgs/Hr: " . Floor(MessagesPerHour)

    ; Update progress bar
    ProgressPercent := Min(Floor((DailyMessages / DailyGoal) * 100), 100)
    GuiControl,, DailyGoalProgress, %ProgressPercent%

    ; Debug log
    LogDebug("Statistics refreshed manually.")

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
    if (!Running) ; stop immediately if stopped
    {
        SetTimer, RunLoop, Off
        GuiControl,, StatusLabel, Status: Stopped
        return
    }
    if (Paused)
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
GuiControl,, SessionMessagesSent, %SessionMessages%
TotalMessages++
GuiControl,, TotalMessagesSent, %TotalMessages%
TotalLoops++
GuiControl,, TotalLoops, %TotalLoops%
TotalRuntime := Floor((A_TickCount - SessionStartTime)/60000) + TotalRuntime
GuiControl,, TotalRuntime, %TotalRuntime%

; --- Debug log for stats ---
LogDebug("Stats Update: SessionMessages=" SessionMessages ", TotalMessages=" TotalMessages ", TotalLoops=" TotalLoops ", TotalRuntime=" TotalRuntime)

; Update GUI for messages per hour
GuiControl,, MessagesPerHourText, % "Msgs/Hr: " . Floor(MessagesPerHour)

; Update daily goal progress bar
ProgressPercent := Min(Floor((DailyMessages / DailyGoal) * 100), 100)
GuiControl,, DailyGoalProgress, %ProgressPercent%

TotalMessages++
GuiControl,, TotalMessagesSent, %TotalMessages%
TotalLoops++
GuiControl,, TotalLoops, %TotalLoops%
TotalRuntime := Floor((A_TickCount - SessionStartTime)/60000) + TotalRuntime
GuiControl,, TotalRuntime, %TotalRuntime%


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
        MsgBox, %msg%
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
    msg := "**Feedback Received**`n"
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
            GuiControl,, FeedbackStatus, Status: Feedback sent successfully!
        else
            GuiControl,, FeedbackStatus, Status: Failed! Status: %Status%
    } catch e {
        errMsg := e.Message
        errMsg := RegExReplace(errMsg, "[^\x20-\x7E]", "")  ; strip bad chars
        GuiControl,, FeedbackStatus, % "Status: Error: " errMsg
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
    ; Also update leaderboard
    SendLeaderboard()
return
LeaderboardWebhookURL := "https://discord.com/api/webhooks/1416603247258370079/8DBSBwLJl5yhWF-0Ox3EEIzDoV0Zhi1AmDulSC3D34MN0lZnHEzguU0l2GIh2KeLECy3"

SendLeaderboard() {
    Global LeaderboardWebhookURL
    Global TotalMessages, TotalLoops, TotalRuntime, TotalDonations, DonationRatio

    msg := "**Global Stats Update**`n"
    msg .= "Total Messages: " TotalMessages "`n"
    msg .= "Total Loops: " TotalLoops "`n"
    msg .= "Total Runtime (min): " TotalRuntime "`n"
    msg .= "Total Donations: " TotalDonations "`n"
    msg .= "Donation Ratio: " Round(DonationRatio*100,1) "%`n"

    http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    try {
        http.Open("POST", LeaderboardWebhookURL, false)
        http.SetRequestHeader("Content-Type", "application/json")
        SafeMessage := StrReplace(msg, "\", "\\")
        SafeMessage := StrReplace(SafeMessage, """", "\""")
        SafeMessage := StrReplace(SafeMessage, "`n", "\n")
        data := "{""content"": """ SafeMessage """}"
        http.Send(data)
    } catch e {
        MsgBox % "Failed to send leaderboard!`n" e.Message
    }
}

    msg := "**Global Leaderboard**`n"
    msg .= "Most Messages: " bestMsgsUser " (" bestMsgs ")`n"
    msg .= "Most Donations: " bestDonosUser " (" bestDonos ")`n"
    msg .= "Best Donation Ratio: " bestRatioUser " (" Round(bestRatio*100,2) "%)`n"

    ; Send webhook
    http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    try {
        http.Open("POST", LeaderboardWebhookURL, false)
        http.SetRequestHeader("Content-Type", "application/json")
        SafeMessage := StrReplace(msg, "\", "\\")
        SafeMessage := StrReplace(SafeMessage, """", "\""")
        SafeMessage := StrReplace(SafeMessage, "`n", "\n")
        data := "{""content"": """ SafeMessage """}"
        http.Send(data)
    } catch e {
        MsgBox % "Failed to send leaderboard!`n" e.Message
    }

GetTopUsers(stat) {
    Global StatsFile
    users := []

    IniRead, sections, %StatsFile%
    Loop, Parse, sections, `n
    {
        device := A_LoopField
        if (device = "")
            continue
        IniRead, value, %StatsFile%, %device%, %stat%, 0
        users.Push({name: device, value: value})
    }

    users.Sort("CompareDesc")
    return users
}

CompareDesc(a, b) {
    return b.value - a.value
}

