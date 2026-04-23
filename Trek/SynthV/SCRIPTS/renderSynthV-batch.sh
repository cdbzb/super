#!/bin/bash
# Renders multiple SVP files sequentially in a single SynthV Studio session.
# Usage: renderSynthV-batch.sh file1.svp file2.svp ...
# Each SVP must already have renderConfig.destination set.

APP_NAME="Synthesizer V Studio 2 Pro"

if [ $# -eq 0 ]; then
    echo "Usage: $0 file1.svp [file2.svp ...]"
    exit 1
fi

# Open the first file to launch the app
open -a "$APP_NAME" "$1"
sleep 3

osascript - "$@" <<'APPLESCRIPT'
on run argv
    set appName to "Synthesizer V Studio 2 Pro"
    tell application appName to activate

    tell application "System Events"
        tell process appName
            -- Wait until a window is visible
            repeat until (count of windows) > 0
                delay 0.5
            end repeat

            -- Ensure Render Panel is visible
            try
                if not (exists button "Bounce to Files" of front window) then
                    click menu item "Render Panel" of menu "View" of menu bar 1
                    delay 0.5
                end if
            end try
        end tell
    end tell

    -- Process each file
    repeat with i from 1 to (count of argv)
        set svpPath to item i of argv

        -- Derive expected wav path from SVP path:
        -- /private/tmp/HASH.svp -> frozenDir/HASH/synthV_MixDown.wav
        set svpName to do shell script "basename " & quoted form of svpPath & " .svp"
        set frozenDir to do shell script "dirname $(dirname " & quoted form of svpPath & ")" & "/tank/super/Trek/SynthV/frozen"
        -- Actually, read destination from the SVP JSON
        set wavPath to do shell script "python3 -c \"import json,sys; d=json.load(open(sys.argv[1])); print(d['renderConfig']['destination'])\" " & quoted form of svpPath & " 2>/dev/null || echo ''"
        if wavPath is not "" then
            set wavPath to wavPath & "/synthV_MixDown.wav"
        end if

        -- For files after the first, open via File > Open
        if i > 1 then
            tell application appName
                activate
                open POSIX file svpPath
            end tell
            -- Dismiss any "Save changes?" dialog
            tell application "System Events"
                tell process appName
                    delay 0.5
                    try
                        if exists sheet 1 of front window then
                            click button "Don't Save" of sheet 1 of front window
                            delay 0.5
                        end if
                    end try
                    -- Also check for standalone dialog
                    try
                        if exists button "Don't Save" of front window then
                            click button "Don't Save" of front window
                            delay 0.5
                        end if
                    end try
                end tell
            end tell
        end if

        -- Click Bounce to Files immediately
        tell application "System Events"
            tell process appName
                -- Ensure Render Panel is visible
                try
                    if not (exists button "Bounce to Files" of front window) then
                        click menu item "Render Panel" of menu "View" of menu bar 1
                        delay 0.5
                    end if
                end try

                try
                    click button "Bounce to Files" of front window
                on error errMsg
                    log "Error bouncing " & svpPath & ": " & errMsg
                end try
            end tell
        end tell

        -- Poll for wav file to appear
        if wavPath is not "" then
            set maxWait to 120
            set waited to 0
            repeat while waited < maxWait
                set fileExists to do shell script "test -f " & quoted form of wavPath & " && echo yes || echo no"
                if fileExists is "yes" then exit repeat
                delay 1
                set waited to waited + 1
            end repeat
            -- Small extra delay to ensure file is fully written
            delay 1
        else
            delay 5
        end if
    end repeat

    -- Save and quit after all files are done
    tell application "System Events"
        tell process appName
            try
                click menu item "Save" of menu "File" of menu bar 1
                delay 0.5
            end try
            click menu item "Quit Synthesizer V Studio 2 Pro" of menu "Synthesizer V Studio 2 Pro" of menu bar 1
        end tell
    end tell

    return "Batch render complete: " & (count of argv) & " files"
end run
APPLESCRIPT
